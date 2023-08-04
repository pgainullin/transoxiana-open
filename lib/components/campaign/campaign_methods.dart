part of 'campaign.dart';

extension CampaignMethodsExtension on Campaign {
  GameDate get currentDate => runtimeData.currentDate;

  void endTurn() {
    final gameData = game.temporaryCampaignData;
    if (!gameData.inCommand) return;
    game.streamRunner.addEvent(CampaignEndTurn());
  }

  Future<void> prepareEndTurn() async {
    //should only be possible in the paused state of the game
    assert(
      game.temporaryCampaignData.isPaused,
      'game should be paused when calling prepareEndTurn',
    );
    if (game.isHeadless) {
      //get player orders from the AI training API
      await getCampaignOrdersFromApi(game.campaignRuntimeData);
      for (final ai in game.campaignRuntimeData.ais.values) {
        await ai.giveCampaignOrders();
      }
    } else {
      await giveAutomaticOrders();
      clearSelectionAndNotify();
      for (final ai in game.campaignRuntimeData.ais.values) {
        await ai.giveCampaignOrders();
      }
    }
  }

  /// automatic ordering for armies owned by the player that
  /// are not in fighter mode
  Future<void> giveAutomaticOrders() async {
    final Set<Army> armies = game.campaignRuntimeData.armies.values
        .where(
          (final element) =>
              element.nation == game.player &&
              element.defeated == false &&
              element.location != null &&
              element.mode != ArmyMode.fighter() &&
              element.destination == null,
        )
        .toSet();
    for (final army in armies) {
      switch (army.mode.enumValue) {
        case ArmyModeEnum.recruiter:
          {
            await Ai.recruiterCampaignMove(army);
          }
          break;
        case ArmyModeEnum.raider:
          {
            await Ai.raiderCampaignMove(army);
          }
          break;
        case ArmyModeEnum.taxCollector:
          {
            await Ai.taxCollectorCampaignMove(army);
          }
          break;
        case ArmyModeEnum.defender:
          {
            await Ai.defenderCampaignMove(army);
          }
          break;
        default:
          {
            // should not come up
            throw Exception('Incorrect player army mode ${army.mode}');
          }
      }
    }
  }

  /// got through provinces and check where hostile forces are engaged.
  ///collect these in a list and pass it on to processBattles() to play them out
  Future<void> processEngagements() async {
    final Map<Id, Battle> battles = {};

    for (final province in provinces) {
      final Set<Army> fightingArmies = province.armies.values
          .where(
            (final army) => army.isFighting,
          )
          .toSet();

      final Set<Army> hostileArmies = fightingArmies
          .where(
            (final army) => province.nation.isHostileTo(army.nation),
          )
          .toSet();
      final Set<Army> alliedArmies = fightingArmies
          .where(
            (final army) => province.nation.isFriendlyTo(army.nation),
          )
          .toSet();

      // armies that are neither at war nor allied to the province owner
      final Set<Army> neutralArmies = fightingArmies
          .toSet()
          .difference(hostileArmies)
          .difference(alliedArmies);

      bool siegeOverride = false;
      // if true the battle is not processed
      // as the attacker and defender both choose to sit out this season
      if (province.fort != null &&
          hostileArmies.isNotEmpty &&
          hostileArmies.firstWhereOrNull(
                (final element) => element.siegeMode == false,
              ) ==
              null &&
          alliedArmies.firstWhereOrNull(
                (final element) => element.siegeMode == false,
              ) ==
              null) {
        siegeOverride = true;
        // log('siegeOverride in effect for ${province.name}');

        processSiege(province);
      }

      if (fightingArmies.length > 1 &&
          hostileArmies.isNotEmpty &&
          alliedArmies.isNotEmpty &&
          siegeOverride == false) {
        final newBattleData = BattleData(
          armies: await hostileArmies
              .union(alliedArmies)
              .convert((final e) async => e.id),
          provinceId: province.id,
          mapPath: province.mapPath ?? Battle.getRandomMap(),
        );
        final newBattle = await newBattleData.toBattle(game: game);
        battles[newBattle.id] = newBattle;
      }

      // No battle involving province owner but neutral armies are present
      if (siegeOverride == false && neutralArmies.isNotEmpty) {
        final Set<Nation> neutralBattleNations = {};

        for (final neutralArmy in neutralArmies) {
          for (final provinceArmy in fightingArmies) {
            if (neutralBattleNations.isEmpty &&
                neutralArmy.nation.isHostileTo(provinceArmy.nation)) {
              neutralBattleNations
                  .addAll([provinceArmy.nation, neutralArmy.nation]);
            }
          }
        }

        if (neutralBattleNations.isNotEmpty) {
          // if the province belongs to an enemy of one of the combatants
          // but is undefended so friendly armies is empty and hostile armies
          // isn't and that hostile army is not in neutral armies
          final armies = neutralArmies
              .where(
                (final element) =>
                    element.nation.isFriendlyTo(neutralBattleNations.first) ||
                    element.nation.isFriendlyTo(neutralBattleNations.last),
              )
              .toSet()
              .union(
                fightingArmies
                    .where(
                      (final army) =>
                          army.nation.isFriendlyTo(neutralBattleNations.first),
                    )
                    .toSet(),
              );
          if (armies.length > 1) {
            final newBattleData = BattleData(
              armies: await armies.convert((final item) async => item.id),
              provinceId: province.id,
              mapPath: province.mapPath ?? Battle.getRandomMap(),
            );
            final newBattle = await newBattleData.toBattle(game: game);
            battles[newBattle.id] = newBattle;
          }
        }
      }
    }
    await game.campaignRuntimeDataService.state.battles.addAllNew(battles);
  }

  /// advance game season and year
  Future<void> advanceCampaignTime() async {
    if (runtimeData.currentSeason.index == Season.values.length - 1) {
      runtimeData
        ..currentSeason = Season.winter
        ..currentYear = runtimeData.currentYear + 1;
    } else {
      runtimeData.currentSeason =
          Season.values[runtimeData.currentSeason.index + 1];
    }
    runtimeDataService.notify();
  }

  void processSiege(final Province province) {
    final Set<Army> attackingArmies = province.armies.values
        .where((final army) => army.nation.isHostileTo(province.nation))
        .toSet();
    assert(
      attackingArmies.isNotEmpty,
      'attackingArmies should not be empty in processSiege',
    );

    // bombard walls
    final double attackingBombardStrength = attackingArmies.fold(
      0.0,
      (final previousValue, final army) =>
          previousValue +
          army.units.fold(
            0.0,
            (final previousUnitValue, final unit) =>
                previousUnitValue +
                unit.bombardFactor * unit.rangedStrength * unit.rangedSpeed,
          ),
    );
    final int segmentCount = province.fort!.segments.length;

    // log('Each segment is bombarded for ${seasonSiegeBombardDamageFactor *attackingBombardStrength /segmentCount} damage');
    for (final segment in province.fort!.segments) {
      segment.receiveDamage(
        seasonSiegeBombardDamageFactor *
            ((province.weather is Rain) ? rainBombardPenalty : 1.0) *
            ((province.weather is Snow) ? snowBombardPenalty : 1.0) *
            attackingBombardStrength /
            segmentCount,
      );
    }

    final Set<Army> defendingArmies = province.armies.values
        .where(
          (final army) =>
              army.nation == province.nation ||
              army.nation.diplomaticRelationships[province.nation] ==
                  DiplomaticStatus.alliance,
        )
        .toSet();
    assert(
      defendingArmies.isNotEmpty,
      'defendingArmies should not be empty in processSiege',
    );

    // harass attackers
    final double defendingRangedStrength = defendingArmies.fold(
      0.0,
      (final previousValue, final army) =>
          previousValue +
          army.units.fold(
            0.0,
            (final previousUnitValue, final unit) =>
                previousUnitValue + unit.rangedStrength * unit.rangedSpeed,
          ),
    );
    final int attackingUnitCount = attackingArmies.fold(
      0,
      (final previousValue, final army) => previousValue + army.units.length,
    );

    for (final army in attackingArmies) {
      for (final element in army.units) {
        element.receiveDamage(
          seasonSiegeRangedDamageFactor *
              ((province.weather is Rain) ? rangedRainPenalty : 1.0) *
              ((province.weather is Snow) ? rangedSnowPenalty : 1.0) *
              defendingRangedStrength /
              attackingUnitCount,
        );
      }
    }

    // traitors open gates
  }

  Future<void> seasonStartReport() async {
    log(
      'Reporting start of the season '
      '${game.campaignRuntimeData.currentDate}',
    );

    for (final province in provinces) {
      await province.consume();
    }
    if (game.campaignRuntimeData.currentSeason == Season.autumn) {
      for (final province in provinces) {
        province.harvest();
      }
    } //this includes trading between provinces so better to get the consume/harvest separately from other actions

    await Future.wait(
      [
        for (final province in provinces) province.seasonStartActions(),
      ],
    );

    //TODO: *report* sieges, harvests, population changes, famines etc.

    //processing sieges
    await Future.forEach<Province>(
        provinces.where(
          (final province) =>
              province.fort != null &&
              province.nation.isHostileTo(game.player!),
        ), (final besiegedProvince) async {
      final List<Army> besiegingArmies = besiegedProvince.armies.values
          .where(
            (final element) =>
                element.nation == game.player &&
                element.siegeMode == true &&
                element.nextProvince == null,
          )
          .toList();
      if (besiegingArmies.isNotEmpty) {
        //TODO: add a report on what the results of the siege were
        final List<String> options = [
          S.current.continueSiegeOption,
          S.current.assaultSiegeOption,
        ];
        if (await asyncMultipleChoiceDialog(
              getScaffoldKeyContext(),
              S.current.siegeContinueDialogueTitle(besiegedProvince.name),
              S.current.siegeContinueDialogueContent,
              options,
            ) ==
            1) {
          for (final army in besiegingArmies) {
            army.data.siegeMode = false;
          }
        }
      }
    });

    //undefended province capture
    for (final army in game.campaignRuntimeData.armies.values) {
      army.captureLocationIfUndefended();
    }

    //commander learning
    for (final army in game.campaignRuntimeData.armies.values) {
      if (!army.defeated) {
        army.commander?.learnAtSeasonEnd();
      }
    }

    unawaited(evaluateEvents());
  }

  void clearAndSetVisibleNationsInProvinces() {
    for (final province in provinces) {
      province.visibleForNations.clear();
    }
    for (final province in provinces) {
      province.setVisibleProvinces();
    }
  }
}
