import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:states_rebuilder/states_rebuilder.dart';
import 'package:transoxiana/components/battle/battle.dart';
import 'package:transoxiana/components/battle/node.dart';
import 'package:transoxiana/components/battle/unit.dart';
import 'package:transoxiana/components/campaign/province.dart';
import 'package:transoxiana/components/game/game.dart';
import 'package:transoxiana/components/shared/army.dart';
import 'package:transoxiana/components/shared/events/events.dart';
import 'package:transoxiana/components/shared/nation.dart';
import 'package:transoxiana/data/army_modes.dart';
import 'package:transoxiana/data/army_templates.dart';
import 'package:transoxiana/data/campaign_data_source.dart';
import 'package:transoxiana/data/constants.dart';
import 'package:transoxiana/data/game_dates.dart';
import 'package:transoxiana/data/temporary_game_data.dart';
import 'package:transoxiana/data/unit_types.dart';
import 'package:transoxiana/services/battle_map_services.dart';
import 'package:transoxiana/services/python_interface.dart';
import 'package:transoxiana/widgets/base/dialogues.dart';
import 'package:utils/utils.dart';

part 'ai.g.dart';

typedef NationId = String;

@JsonSerializable()
class AiId with EquatableMixin {
  AiId({
    required final Id? aiId,
    required this.nationId,
  }) : aiId = aiId ?? uuid.v4();

  Map<String, dynamic> toJson() => _$AiIdToJson(this);

  static AiId fromJson(final Map<String, dynamic> json) => _$AiIdFromJson(json);
  final Id aiId;
  Id nationId;

  @override
  @JsonKey(ignore: true)
  List<Object?> get props => [aiId, nationId];

  @override
  @JsonKey(ignore: true)
  // ignore: hash_and_equals
  int get hashCode => super.hashCode;

  @override
  @JsonKey(ignore: true)
  bool? get stringify => true;
}

/// strategic AI that gives the orders at the same stage as human players do
@JsonSerializable(explicitToJson: true)
class AiData {
  AiData({
    required this.id,
    final Map<NationId, GameDate>? dateOfLastPeaceOffer,
  }) : dateOfLastPeaceOffer = dateOfLastPeaceOffer ?? {};

  Map<String, dynamic> toJson() => _$AiDataToJson(this);

  static AiData fromJson(final Map<String, dynamic> json) =>
      _$AiDataFromJson(json);

  Future<Ai> toAi({required final TransoxianaGame game}) async {
    final effectiveNation =
        await game.campaignRuntimeData.getNationById(id.nationId);

    final effectiveDateOfLastPeaceOffer =
        await dateOfLastPeaceOffer.convertKeys(
      (final nationId) async =>
          game.campaignRuntimeData.getNationById(nationId),
    );
    final ai = Ai._fromData(
      data: this,
      game: game,
      nation: effectiveNation,
      dateOfLastPeaceOffer: effectiveDateOfLastPeaceOffer,
    );
    effectiveNation.ai = ai;
    return ai;
  }

  final AiId id;
  final Map<NationId, GameDate> dateOfLastPeaceOffer;
}

class Ai with EquatableMixin implements GameRef, DataSourceRef<AiData, Ai> {
  Ai._fromData({
    required this.game,
    required this.nation,
    required this.dateOfLastPeaceOffer,
    required this.data,
  });

  @override
  AiData data;

  @override
  Future<void> refillData(final Ai otherType) async {
    assert(
      otherType == this,
      'You trying to update different Ai.',
    );
    final newData = await otherType.toData();
    data = newData;
    nation = otherType.nation;
    dateOfLastPeaceOffer = otherType.dateOfLastPeaceOffer;
  }

  @override
  Future<AiData> toData() async => AiData(
        id: data.id..nationId = nation.id,
      );

  AiId get id => data.id;
  Nation nation;

  @override
  TransoxianaGame game;

  ReactiveModel<TemporaryGameData> get temporaryData =>
      game.temporaryCampaignDataService;

  CampaignRuntimeData get runtimeData => game.campaignRuntimeData;

  static const int minimumTurnsBetweenPeaceOffers = 10;
  Map<Nation, GameDate> dateOfLastPeaceOffer;

  // int turnsSinceLastPeaceOffer = minimumTurnsBetweenPeaceOffers;

  Future<void> giveCampaignOrders() async {
    if (nation.isDefeated == true) return;

    // if (this.game.isHeadless) {
    //   getCampaignOrdersFromApi(this.game);
    //   return;
    // }

    switchExcessDefendersToFighterMode();

    await performDiplomaticActions();

    await buildArmiesIfNoneFighting();

    final List<Army> myArmies = game.campaignRuntimeData.armies.values
        .where(
          (final army) =>
              army.nation == nation &&
              army.units.isNotEmpty &&
              army.location != null,
        )
        .toList();

    for (final army in myArmies) {
      if (army.defeated) continue;

      switch (army.mode.enumValue) {
        case ArmyModeEnum.fighter:
          {
            await fighterCampaignMove(army);
          }
          break;
        case ArmyModeEnum.recruiter:
          {
            await recruiterCampaignMove(army);
          }
          break;
        case ArmyModeEnum.taxCollector:
          {
            await taxCollectorCampaignMove(army);
          }
          break;
        case ArmyModeEnum.raider:
          {
            await raiderCampaignMove(army);
          }
          break;
        case ArmyModeEnum.defender:
          {
            await defenderCampaignMove(army);
          }
          break;
        default:
          {
            throw Exception('Unhandled ArmyMode ${army.mode} for $army in AI');
          }
      }
    }
  }

  /// Consider current status and declare war / make alliances where appropriate
  Future<void> performDiplomaticActions() async {
    final campaign = game.campaign;
    if (campaign == null) throw ArgumentError.notNull('campaign');
    if (nation.isIndependent) return;
    if (campaign.runtimeData.startYear == runtimeData.currentYear &&
        campaign.runtimeData.startSeason == runtimeData.currentSeason) {
      return;
    }

    if (currentlyAtWar() == false) {
      final Nation? target = weakestNeighbour();
      if (target != null &&
          target.unitCount * aiUnitAdvantageWarThreshold <
              nation.unitCountOffensive) {
        await addWarDeclarationEvent(target);
      }
    } else {
      // consider if peace is desirable
      if (totalEnemyUnitCount() >
          aiUnitDisadvantagePeaceThreshold * nation.unitCount) {
        final List<Nation> enemies = nation.diplomaticRelationships.entries
            .where((final element) => element.value == DiplomaticStatus.war)
            .map((final e) => e.key)
            .toList();
        for (final enemy in enemies) {
          if (enemy.unitCount > 0) {
            if (dateOfLastPeaceOffer[enemy] == null ||
                campaign.runtimeData.currentDate
                        .turnSinceDate(dateOfLastPeaceOffer[enemy]) >=
                    minimumTurnsBetweenPeaceOffers) {
              // log(
              //     '$nation sent peace offer to ${enemy} as
              //     ${totalEnemyUnitCount()} >
              //     ${aiUnitDisadvantagePeaceThreshold *
              //         nation.unitCount}');
              await nation.addPeaceOfferEvent(enemy);
              dateOfLastPeaceOffer[enemy] = campaign.runtimeData.currentDate;
            }
          }
        }
      }
    }
  }

  /// if at war, check if this nation has fighting armies.
  /// if not loop through provinces and train them
  Future<void> buildArmiesIfNoneFighting() async {
    if (!currentlyAtWar()) return;
    if (nation
        .getArmies()
        .where((final element) => element.isFighting)
        .isNotEmpty) return;

    for (final province in nation.getProvinces()) {
      if (province.getAvailableUnits().isNotEmpty) {
        if (game.campaignRuntimeData.rand.nextBool()) {
          final Unit? newUnit = await province.trainRandomUnit();
          if (newUnit != null) {
            newUnit.army!.data.mode =
                nation.isIndependent ? ArmyMode.raider() : ArmyMode.recruiter();
          }
        }
      }
    }
  }

  /// Check if peace is desirable with otherNation
  /// and return ConfirmAction.ACCEPT if so
  ConfirmAction evaluatePeaceOffer(final Nation otherNation) {
    if (totalEnemyUnitCount() >
            aiUnitDisadvantagePeaceThreshold * nation.unitCount &&
        otherNation.unitCount > 0) {
      // log('$nation evaluated peace offer from $otherNation favourably as
      // ${totalEnemyUnitCount()} > ${aiUnitDisadvantagePeaceThreshold *
      // nation.unitCount}');

      return ConfirmAction.accept;
    } else {
      return ConfirmAction.cancel;
    }
  }

  /// Returns the total number of units of enemy nations
  int totalEnemyUnitCount() {
    return nation.diplomaticRelationships.entries
        .where((final element) => element.value == DiplomaticStatus.war)
        .fold<int>(
          0,
          (final previousValue, final enemy) =>
              previousValue + enemy.key.unitCount,
        );
  }

  /// Create a new event declaring war on a neighbour. Done through events so
  /// that if the player is the target they would be notified in the usual way
  Future<void> addWarDeclarationEvent(final Nation otherNation) async {
    final eventData = EventData.fromConditionAndConsequenceTypes(
      nationId: nation.id,
      condition: EventConditionType.alwaysTrue,
      consequence: EventConsequenceType.declareWar,
      consequenceOtherNationId: otherNation.id,
    );
    final event = await eventData.toEvent(game: game);
    nation.events.add(event);
  }

  /// Return true is there are nations this nation is
  /// at war with that have not been defeated
  bool currentlyAtWar() => nation.diplomaticRelationships.entries
      .where(
        (final element) =>
            element.value == DiplomaticStatus.war &&
            element.key.isDefeated == false,
      )
      .isNotEmpty;

  /// Find and return the Nation bordering at least one Province of this Nation
  /// that has the lowest unit count
  Nation? weakestNeighbour() {
    final List<Nation> neighbours = [];

    for (final Province ownProvince in nation.getProvinces()) {
      for (final Province otherProvince in ownProvince.adjacentLocations) {
        if (otherProvince.nation.isDefeated == false &&
            !otherProvince.nation.isFriendlyTo(nation)) {
          neighbours.add(otherProvince.nation);
        }
      }
    }

    if (neighbours.isNotEmpty) {
      neighbours.sort((final a, final b) => a.unitCount.compareTo(b.unitCount));

      return neighbours.first;
    } else {
      return null;
    }
  }

  /// determines how closely a given army fits a given template
  static int armyTemplateFitnessScore(
    final Army army,
    final ArmyTemplate template,
  ) {
    int score = 0;

    final List<UnitType> armyTypes =
        army.units.map((final e) => e.type).toList();

    for (final unitTypes in template.types) {
      bool slotCovered = false;
      for (final unitType in unitTypes) {
        if (armyTypes.contains(unitType)) {
          score += 1;
          slotCovered = true;
          armyTypes.remove(unitType);
        }
      }

      if (slotCovered == false) {
        score -= 1;
      }
    }
    return score;
  }

  /// Go through the template UnitTypes removing types that are already present
  /// in the given army. Upon encountering a type that is not present check if
  /// it is available and train it if so.
  /// If no unit type results from this, return a random available unit type
  static UnitType pickUnitFromTemplate(
    final Army army,
    final ArmyTemplate targetTemplate,
  ) {
    if (army.location == null) {
      throw Exception('null location for $army in pickUnitFromTemplate');
    }
    final affordableUnits = army.location!.getAffordableUnits();
    if (affordableUnits.isEmpty) {
      throw Exception('no affordable units for $army in pickUnitFromTemplate');
    }

    final List<UnitType> armyTypes =
        army.units.map((final e) => e.type).toList();

    final List<List<UnitType>> unusedTemplateTypes =
        List.from(targetTemplate.types);

    int hits = 1;
    while (hits > 0) {
      final List<List<UnitType>> typesToCheck = List.from(unusedTemplateTypes);
      hits = 0;
      for (final templateTypeList in typesToCheck) {
        bool typeFound = false;
        for (final templateType in templateTypeList) {
          if (armyTypes.contains(templateType)) {
            typeFound = true;
            armyTypes.remove(templateType);
            unusedTemplateTypes.remove(templateTypeList);
            hits += 1;
          }
        }

        if (typeFound == false) {
          for (final templateType in templateTypeList) {
            if (affordableUnits.contains(templateType)) {
              return templateType;
            }
          }
        }
      }
    }

    return affordableUnits.randomElement()!;
  }

  /// for a given army which can train a unit - train one and
  /// depending on parent mode switch child mode
  static Future<void> trainChildUnit(final Army myArmy) async {
    if (myArmy.location == null) return;

    // train new units wherever available
    if (myArmy.location?.nation == myArmy.nation &&
        myArmy.location!.getAffordableUnits().isNotEmpty) {
      final ArmyTemplate targetTemplate = myArmy.nation.armyTemplates.reduce(
        (final value, final element) =>
            armyTemplateFitnessScore(myArmy, element) >
                    armyTemplateFitnessScore(myArmy, value)
                ? element
                : value,
      );

      final Unit? newUnit = await myArmy.location
          ?.trainUnit(pickUnitFromTemplate(myArmy, targetTemplate), myArmy);
      // myArmy.location!.trainMostExpensiveUnit(); //trainRandomUnit();

      if (newUnit != null) {
        // if(myArmy.mode == ArmyMode.recruiter){

        if (myArmy != newUnit.army) {
          // max army size exceeded so new army created taking over recruiting
          // or unit assigned to another smaller army

          // new AI armies start in recruiter mode to stimulate build out
          newUnit.army!.data.mode = ArmyMode.recruiter();

          // old army is full strength so switches to fighter/defender roles
          if (myArmy.mode == ArmyMode.recruiter()) {
            if (myArmy.nation.haveUndefendedForts) {
              myArmy.data.mode = ArmyMode.defender();
            } else {
              myArmy.data.mode = ArmyMode.fighter();
            }
          }
          if (newUnit.army!.units.length == 1) {
            //   if(newUnit.army.nation.haveUndefendedForts){
            //     newUnit.army.mode = ArmyMode.defender;
            //   } else {
            newUnit.army!.data.mode = ArmyMode.recruiter();
            // }
          }
        }
        // }
      }
    }
  }

  static Future<void> fighterCampaignMove(final Army myArmy) async {
    if (myArmy.location == null) return;
    await trainChildUnit(myArmy);

    //TODO: assess relative strength
    //TODO: assess quick wins
    //TODO: choose attack or defend

    if ((myArmy.nextProvince == null ||
            myArmy.nextProvince!.nation.isFriendlyTo(myArmy.nation)) &&
        myArmy.location!.isEngagingToArmy(myArmy) == false) {
      if (myArmy.location!.isFortified &&
          myArmy.location!.nation == myArmy.nation &&
          myArmy.location!.armies.values
              .where((final element) => element.mode == ArmyMode.defender())
              .isEmpty) {
        // keep the one army in a fortified province to defend it
        myArmy.data.siegeMode = true;
        myArmy.clearOrders();
        myArmy.data.mode = ArmyMode.defender();
      } else {
        // if currently besieging, continue
        if (myArmy.siegeMode == true &&
            myArmy.location!.isFortified &&
            (myArmy.location!.nation.isHostileTo(myArmy.nation) ||
                myArmy.location!.nation.isFriendlyTo(myArmy.nation))) return;

        // be aggressive targeting armies in adjacent provinces as a priority
        if (await targetEnemyArmy(myArmy) == false) {
          if (await targetEnemyProvince(myArmy) == false) {
            await orderToAFriendlyProvince(myArmy);
          }
        }
      }
    }
  }

  static Future<void> defenderCampaignMove(final Army myArmy) async {
    if (myArmy.location == null) return;
    await trainChildUnit(myArmy);
    //TODO: consider provisions

    if ((myArmy.nextProvince == null ||
            myArmy.nextProvince!.nation.isFriendlyTo(myArmy.nation)) &&
        myArmy.location!.isEngagingToArmy(myArmy) == false) {
      final defenders = myArmy.location!.armies.values.where(
        (final element) =>
            element.nation == myArmy.nation &&
            element.mode == ArmyMode.defender(),
      );

      if (myArmy.location!.isFortified &&
          myArmy.location!.nation == myArmy.nation &&
          defenders.isNotEmpty &&
          defenders.first == myArmy) {
        // keep the army in a fortified province to defend it
        myArmy.data.siegeMode = true;
        myArmy.clearOrders();
      } else {
        // be defensive, targeting fortified friendly provinces
        await orderToAFriendlyFortifiedProvince(myArmy);
      }
    }
  }

  /// if there are mode defender armies than forts,
  /// set the excess ones to fighter mode
  void switchExcessDefendersToFighterMode() {
    if (nation
            .getProvinces()
            .where((final element) => element.isFortified)
            .length <
        nation
            .getArmies()
            .where(
              (final element) =>
                  element.mode == ArmyMode.defender() &&
                  element.location != null,
            )
            .length) {
      final defendersOutsideForts = nation.getArmies().where(
            (final element) =>
                element.mode == ArmyMode.defender() &&
                element.location != null &&
                !element.location!.isFortified,
          );

      if (defendersOutsideForts.isNotEmpty) {
        defendersOutsideForts.first.data.mode = ArmyMode.fighter();
      } else {
        final Iterable<Army> doubleDefenders = nation.getArmies().where(
              (final element) =>
                  element.mode == ArmyMode.defender() &&
                  element.location != null &&
                  element.location!.isFortified &&
                  element.location!.armies.values
                          .where(
                            (final element) =>
                                element.mode == ArmyMode.defender(),
                          )
                          .length >
                      1,
            );

        if (doubleDefenders.isNotEmpty) {
          doubleDefenders.first.data.mode = ArmyMode.fighter();
        }
      }
    }
  }

  /// finds an enemy army to go after and if found returns true, if not, false
  static Future<bool> targetEnemyArmy(final Army myArmy) async {
    if (myArmy.location == null) return false;

    final Set<Province> searchRegion = targetRegion(
      myArmy.location!,
      // range: 1,
    );

    final List<Army> targets = searchRegion
        .expand(
          (final element) => element.armies.values.where(
            (final otherArmy) => otherArmy.nation.isHostileTo(myArmy.nation),
          ),
        )
        .toList();

    if (targets.isEmpty) return false;

    targets
        .sort((final a, final b) => a.units.length.compareTo(b.units.length));

    if (targets.first.speed > myArmy.speed &&
        targets.first.nextProvince != null) {
      if (targets.first.nextProvince == myArmy.location) return true;
      await myArmy.orderToProvince(targets.first.nextProvince!);
    } else {
      await myArmy.orderToProvince(targets.first.location!);
    }

    if (myArmy.destination != null) {
      if (myArmy.destination!.isFortified) {
        if (targets.first.units.where((final unit) => unit.isFighting).length *
                strategicAiSiegeNumericAdvantageFactor >
            myArmy.strength + expectedAssaultStrength(myArmy.destination!)) {
          myArmy.data.siegeMode = true;
        } else {
          myArmy.data.siegeMode = false;
        }
      }

      return true;
    } else {
      return false;
    }
  }

  /// total strength of enemy armies currently assaulting
  /// or planning to assault a given Province
  static int expectedAssaultStrength(final Province province) {
    int combinedStrength = targetRegion(
      province,
      // range: 1,
    ).fold<int>(
      0,
      (final previousValue, final element) =>
          previousValue +
          element.armies.values
              .where(
                (final otherArmy) =>
                    otherArmy.nation.isHostileTo(province.nation) &&
                    otherArmy.nextProvince == province,
              )
              .fold<int>(
                0,
                (final previousValue, final alliedArmy) =>
                    previousValue + alliedArmy.strength,
              ),
    );
    // ignore: join_return_with_assignment
    combinedStrength += province.armies.values
        .where(
          (final element) =>
              element.nation.isHostileTo(province.nation) &&
              element.nextProvince == null,
        )
        .fold<int>(
          0,
          (final previousValue, final element) =>
              previousValue + element.strength,
        );
    return combinedStrength;
  }

  /// finds an enemy province to capture and if found returns true,
  /// if not, false
  static Future<bool> targetEnemyProvince(final Army myArmy) async {
    if (myArmy.location == null) return false;

    final Set<Province> searchRegion = targetRegion(myArmy.location!);

    final Set<Province> hostileRegion = searchRegion
        .where((final element) => element.nation.isHostileTo(myArmy.nation))
        .toSet();

    Province? enemyProvince;
    if (hostileRegion.isNotEmpty) {
      enemyProvince = hostileRegion.randomElement();
    }

    if (myArmy.location!.fort != null &&
        myArmy.location!.fort!.segments.isNotEmpty) {
      if (enemyProvince != null && enemyProvince.armies.isNotEmpty) {
        final int enemyStrength = enemyProvince.armies.values.fold(
          0,
          (final previousValue, final element) =>
              element.nation.diplomaticRelationships[myArmy.nation] ==
                      DiplomaticStatus.war
                  ? previousValue + element.units.length
                  : previousValue,
        );
        if (enemyStrength * strategicAiSiegeNumericAdvantageFactor >
            myArmy.units.length) {
          myArmy.data.siegeMode = true;
        } else {
          myArmy.data.siegeMode = false;
        }
      }
    } else {
      myArmy.data.siegeMode = false;
    }

    if (enemyProvince != null && myArmy.siegeMode == false) {
      // log(
      //     'AI orders ${myArmy.name} from ${myArmy.location?.name} to
      //     ${enemyProvince?.name} where fort = ${enemyProvince?.fort}');
      //TODO: fix orders that lead to travel through a Province
      // belonging to nations at Peace with this AI
      await myArmy.orderToProvince(enemyProvince);
      if (enemyProvince.fort != null) {
        myArmy.data.siegeMode = myArmy.game.rand.nextBool();
      }

      return true;
    }

    return false;
  }

  /// go to a random friendly province
  static Future<void> orderToAFriendlyProvince(final Army myArmy) async {
    if (myArmy.location == null) return;

    Set<Province> searchRegion = targetRegion(
      myArmy.location!,
      // range: 1,
    );
    Set<Province> friendlyRegion = searchRegion
        .where((final element) => element.nation.isFriendlyTo(myArmy.nation))
        .toSet();

    if (friendlyRegion.isNotEmpty) {
      await myArmy.orderToProvince(friendlyRegion.randomElement()!);
    } else {
      searchRegion = targetRegion(myArmy.location!, range: 3);
      friendlyRegion = searchRegion
          .where((final element) => element.nation.isFriendlyTo(myArmy.nation))
          .toSet();

      if (friendlyRegion.isNotEmpty) {
        await myArmy.orderToProvince(friendlyRegion.randomElement()!);
      } else {
        final Set<Province> neutralRegion = searchRegion
            .where(
              (final element) => !element.nation.isHostileTo(myArmy.nation),
            )
            .toSet();
        if (neutralRegion.isNotEmpty) {
          await myArmy.orderToProvince(neutralRegion.randomElement()!);
        }
      }
    }
  }

  /// go to a random friendly province that has a fort
  static Future<void> orderToAFriendlyFortifiedProvince(
    final Army myArmy,
  ) async {
    if (myArmy.location == null) return;

    Set<Province> searchRegion = targetRegion(
      myArmy.location!,
      range: 2,
    );
    Set<Province> friendlyRegion = searchRegion
        .where(
          (final element) =>
              element.nation.isFriendlyTo(myArmy.nation) && element.isFortified,
        )
        .toSet();

    if (friendlyRegion.isNotEmpty) {
      await myArmy.orderToProvince(friendlyRegion.randomElement()!);
    } else {
      searchRegion = targetRegion(myArmy.location!, range: 3);
      friendlyRegion = searchRegion
          .where(
            (final element) =>
                element.nation.isFriendlyTo(myArmy.nation) &&
                element.isFortified,
          )
          .toSet();

      if (friendlyRegion.isNotEmpty) {
        await myArmy.orderToProvince(friendlyRegion.randomElement()!);
      } else {
        await orderToAFriendlyProvince(myArmy);
      }
    }
  }

  /// campaign moves for an army that tries to build up to max strength
  /// before switching to fighting
  static Future<void> recruiterCampaignMove(final Army myArmy) async {
    if (myArmy.units.isEmpty || myArmy.location == null) return;
    //empty armies that have been merged within the same forEach are skipped

    await trainChildUnit(myArmy);

    // if any other recruiter armies in this province can be merged with, merge
    final List<Army> mergeableArmies = myArmy.location!.armies.values
        .where(
          (final element) =>
              element != myArmy &&
              element.nation == myArmy.nation &&
              element.mode == ArmyMode.recruiter() &&
              element.units.length <= (armyUnitLimit - myArmy.units.length),
        )
        .toList();
    if (mergeableArmies.isNotEmpty) {
      myArmy.absorbAnotherArmy(mergeableArmies.first);
    }

    final Set<Province> searchRegion = targetRegion(myArmy.location!);

    final List<Province> friendlyRegion = searchRegion
        .where((final element) => element.nation.isFriendlyTo(myArmy.nation))
        .toList();

    if (friendlyRegion.isNotEmpty) {
      friendlyRegion.sort(
        (final a, final b) => a
            .getAffordableUnits()
            .length
            .compareTo(b.getAffordableUnits().length),
      );

      if (friendlyRegion.last.getAffordableUnits().isEmpty) {
        // if no recruitable units, fight
        await fighterCampaignMove(myArmy);
      } else {
        // got to the province with the most units available
        await myArmy.orderToProvince(friendlyRegion.last);
      }
    } else {
      // if in enemy territory, fight
      await fighterCampaignMove(myArmy);
    }
  }

  /// campaign moves for an army that tries to build up to max strength
  /// before switching to fighting
  static Future<void> raiderCampaignMove(final Army myArmy) async {
    if (myArmy.location == null) return;
    await trainChildUnit(myArmy);

    //sack the current province
    if (myArmy.location!.nation.isHostileTo(myArmy.nation)) {
      myArmy.pillageProvinceGold(myArmy.location!);
    } else if (myArmy.location!.nation == myArmy.nation) {
      //recruitment already covered above
      if (!myArmy.location!.hasBeenTaxedThisSeason) {
        myArmy.taxProvince(myArmy.location!);
      }

      //TODO: determine if this province has just been captured
      // and should be sacked too
    }

    final Set<Province> searchRegion = targetRegion(myArmy.location!);

    //target undefended enemy provinces
    final List<Province> hostileRegion = searchRegion
        .where(
          (final element) =>
              element.nation.isHostileTo(myArmy.nation) &&
              element.armies.isEmpty,
        )
        .toList();

    if (hostileRegion.isNotEmpty) {
      hostileRegion
          .sort((final a, final b) => a.goldStored.compareTo(b.goldStored));

      // got to the province with the most gold
      await myArmy.orderToProvince(hostileRegion.last);
    } else {
      // if in friendly territory, recruit
      await recruiterCampaignMove(myArmy);
    }
  }

  /// campaign moves for an army that tries to collect as much gold as possible
  static Future<void> taxCollectorCampaignMove(final Army myArmy) async {
    if (myArmy.location == null) return;
    // trainChildUnit(myArmy);

    if (myArmy.location!.nation == myArmy.nation) {
      if (!myArmy.location!.hasBeenTaxedThisSeason) {
        myArmy.taxProvince(myArmy.location!);
      }
    }

    //TODO: consider depositing the gold carried

    final Set<Province> searchRegion = targetRegion(myArmy.location!);

    final List<Province> friendlyRegion = searchRegion
        .where((final element) => element.nation.isFriendlyTo(myArmy.nation))
        .toList();

    if (friendlyRegion.isNotEmpty) {
      friendlyRegion
          .sort((final a, final b) => a.goldStored.compareTo(b.goldStored));

      // got to the province with the most gold available
      await myArmy.orderToProvince(friendlyRegion.last);
    } else {
      // if in enemy territory, fight
      await fighterCampaignMove(myArmy);
    }
  }

  static const int maxRecursionLevel = 2;

  static Set<Province> targetRegion(
    final Province province, {
    final int recursionLevel = 0,
    final int range = maxRecursionLevel - 1,
  }) {
    // assert(province != null);

    final Set<Province> collector = province.edges
        .map((final id) => province.game.campaignRuntimeData.provinces[id]!)
        .toSet();
    if (recursionLevel < range) {
      final Set<Province> recursiveAdditions = {};

      for (final Province element in collector) {
        recursiveAdditions
            .addAll(targetRegion(element, recursionLevel: recursionLevel + 1));
      }

      collector.addAll(recursiveAdditions);
    }

    collector.remove(province);

    return collector;
  }

  void giveBattleOrders(final Battle battle) {
    //TODO: add position assessment

    if (game.isHeadless && game.player == nation) {
      getBattleOrdersFromApi(game.campaignRuntimeData);
      return;
    }

    List<Node>? fortifiedNodes;

    final bool fortDefense = battle.province.nation.isFriendlyTo(nation) &&
        battle.province.fort != null &&
        battle.province.fortIntegrity! > 0.0;
    final bool fortAttack = battle.province.nation.isHostileTo(nation) &&
        battle.province.fort != null &&
        battle.province.fortIntegrity! > 0.0;

    if (fortAttack || fortDefense) {
      fortifiedNodes = battle.nodes
          .where(
            (final node) =>
                node.fortificationSegment != null &&
                node.fortificationSegment!.life > 0.0,
          )
          .toList();
    }

    battle.units
        .where(
      (final u) => u.nation == nation && u.isFighting && u.location != null,
    )
        .forEach((final myUnit) {
      // log('Calculating moves for the unit at ${myUnit.location}');

      Node? newDestination;

      final List<Unit> enemies =
          nearestEnemies(battle, myUnit).toList(); //.reversed ?
      List<Node>? sortedFortifiedNodes;

      if (fortAttack || fortDefense) {
        sortedFortifiedNodes = fortifiedNodes;
        sortedFortifiedNodes!.remove(myUnit.location);
        sortedFortifiedNodes.sort(
          (final a, final b) =>
              travelCostComparatorByNodes(myUnit.location!, a, b),
        );
      }

      //TODO: focus on massing forces in a proper order at the right spot
      // and let tactical AI lead attacks

      if (myUnit.isMelee && !fortDefense) {
        //melee outside fort defence
        if (myUnit.meleeReach > 1) {
//          //pikeman tactics
          for (final Unit enemyUnit in enemies) {
            if (newDestination == null) {
              final Node? spearingLocation = shootingLocation(
                myUnit,
                enemyUnit.location!,
                myUnit.meleeReach,
              );
              if (spearingLocation != null) newDestination = spearingLocation;
            }
          }
//        } else if (myUnit.speed > 3) {
//          // cavalry tactics
        } else {
//          //regular melee
          if (enemies.isNotEmpty) newDestination = enemies.first.location;
        }
      } else if (!fortDefense) {
        //shooter outside fort defense

//        showTiles([myUnit.location.terrainTile,
//        enemies.last.location.terrainTile].toSet(), game);
        if (fortAttack && myUnit.bombardFactor > 0.0) {
          myUnit.data.stance = Stance.bombard;
          //attacking bombard units focus on fort destruction

          for (final Node fortifiedNode in sortedFortifiedNodes!) {
            if (newDestination == null) {
              final Node? potentialShootingLocation =
                  shootingLocation(myUnit, fortifiedNode, myUnit.shootingRange);

              if (potentialShootingLocation != null) {
                newDestination = potentialShootingLocation;
//              if (newDestination != myUnit.location)
//                log(
//                    'AI sends bombard with a range of ${myUnit.shootingRange}
//                    to ${potentialShootingLocation} to
//                    shoot at ${fortifiedNode}');
              }
            }
          }
        } else {
          for (final Unit enemyUnit in enemies) {
            if (newDestination == null) {
              final Node? potentialShootingLocation = shootingLocation(
                myUnit,
                enemyUnit.location!,
                myUnit.shootingRange,
              );

              if (potentialShootingLocation != null) {
                newDestination = potentialShootingLocation;
//              if (newDestination != myUnit.location)
//                log(
//                    'AI sends shooter with a range of ${myUnit.shootingRange}
//                    to ${potentialShootingLocation} to shoot at
//                    ${enemyUnit.location}');
              }
            }
          }
        }
      }

      if (fortDefense) {
        myUnit.data.stance = Stance.attack;
      } //prevent bombardment of own fortifications

      if (newDestination == null &&
          fortDefense &&
          myUnit.location!.fortificationSegment == null) {
        newDestination = sortedFortifiedNodes!.first;
        //TODO: pick fort segment that is under attack and least well defended
      }

      if (newDestination != null) {
        final List<Node>? path = pathToNodeWithUnitAvoidance(
          game.activeBattle!,
          myUnit.location!,
          newDestination,
        );
        if (path != null &&
            path.isNotEmpty &&
            !fortDefense &&
            path.length > 2) {
          // if closer than 2 tiles, let the tactical AI handle it

          if (fortAttack && myUnit.bombardFactor > 0.0) {
            myUnit.orderToNode(newDestination);
          } else {
            //unless this is a  bombard attacking a fort the destination is set
            // to the penultimate node on the path to let tactical AI make
            // the final moves
            myUnit.orderToNode(
              path.length > 3 ? path[path.length - 3] : path[path.length - 2],
            );
          }
        } else if (path != null && path.isNotEmpty) {
          //&& fortDefense
          myUnit.orderToNode(newDestination);
        } else {
          // log('Unit at ${myUnit.location.toString()} ordered to
          // $newDestination but path is null');
        }
      } else {
        // log('Unit at ${myUnit.location.toString()} has no AI orders');
      }
    });
  }

  // list of enemy units from closest to furthest away
  List<Unit> nearestEnemies(final Battle battle, final Unit myUnit) {
    final List<Unit> list = battle.units
        .where(
          (final u) =>
              u.nation.isHostileTo(myUnit.nation) &&
              u.isFighting &&
              u.location != null,
        )
        .toList();
    list.sort((final a, final b) => travelCostComparatorByUnits(myUnit, a, b));

    return list;
  }

  /// get the location on the path to the enemy unit that is within
  /// shooting range. return own location if within range
  Node? shootingLocation(
    final Unit myUnit,
    final Node enemyNode,
    final int range,
  ) {
    final List<Node> targetingArea = (myUnit.rangedStrength > 0
            ? targetAreaWithFortExtension(enemyNode, range)
            : targetArea(enemyNode, range))
        .toList();
    if (targetingArea.contains(myUnit.location)) return myUnit.location;

    targetingArea
      ..remove(enemyNode)
      ..removeWhere(
        (final element) =>
            !element.isTraversable ||
            (myUnit.location!.totalTravelCost(element) == null),
      );

    if (targetingArea.isNotEmpty) {
      targetingArea.sort(
        (final a, final b) =>
            travelCostComparatorByNodes(myUnit.location!, a, b),
      );

      return targetingArea.first;
    } else {
      // log('shootingLocation returned an empty targetingArea
      // for ${myUnit.location.toString()}');
      return null;
    }
  }

  @override
  List<Object?> get props => [id];
}

//player-accessible version used for debugging only
List<Unit> nearestEnemiesToPlayer(final Battle battle, final Unit myUnit) {
  final List<Unit> list = battle.units
      .where(
        (final u) =>
            u.nation.isHostileTo(battle.game.player!) && u.health > 0.0,
      )
      .toList();
  list.sort((final a, final b) => travelCostComparatorByUnits(myUnit, a, b));

  return list;
}
