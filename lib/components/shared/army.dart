import 'dart:async';
import 'dart:developer';
import 'dart:math' as math;

import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:transoxiana/components/battle/unit.dart';
import 'package:transoxiana/components/battle/unit_painters.dart';
import 'package:transoxiana/components/campaign/province.dart';
import 'package:transoxiana/components/game/game.dart';
import 'package:transoxiana/components/shared/commander.dart';
import 'package:transoxiana/components/shared/components_render_priority.dart';
import 'package:transoxiana/components/shared/nation.dart';
import 'package:transoxiana/components/shared/selector.dart';
import 'package:transoxiana/data/army_modes.dart';
import 'package:transoxiana/data/campaign_data_source.dart';
import 'package:transoxiana/data/constants.dart';
import 'package:transoxiana/data/direction.dart';
import 'package:transoxiana/generated/l10n.dart';
import 'package:transoxiana/widgets/base/dialogues.dart';
import 'package:transoxiana/widgets/ui_constants.dart';
import 'package:utils/utils.dart';

part 'army.g.dart';

typedef ProvinceName = String;

@JsonSerializable()
class ArmyId with EquatableMixin {
  ArmyId({
    required final Id? armyId,
    required this.nationId,
  }) : armyId = armyId ?? uuid.v4();
  Map<String, dynamic> toJson() => _$ArmyIdToJson(this);
  static ArmyId fromJson(final Map<String, dynamic> json) =>
      _$ArmyIdFromJson(json);
  final Id armyId;
  Id nationId;

  @override
  @JsonKey(ignore: true)
  List<Object?> get props => [armyId, nationId];

  @override
  @JsonKey(ignore: true)
  // ignore: hash_and_equals
  int get hashCode => super.hashCode;

  @override
  @JsonKey(ignore: true)
  bool? get stringify => true;
}

@JsonSerializable(explicitToJson: true)
class ArmyData with EquatableMixin {
  /// used for randomly generated armies or for Json constructor
  ArmyData({
    required this.id,
    final String? name,
    this.locationId,
    this.destinationId,
    this.nextProvinceId,
    this.commander,
    final int? mode,
    final double? progress,
    final double? goldCarried,
    final bool? defeated,
    final bool? siegeMode,
    final Set<UnitId>? unitIds,
  })  : name = name ?? 'Unknown army',
        mode = ArmyMode.fromJson(mode),
        progress = progress ?? 0.0,
        goldCarried = goldCarried ?? 0.0,
        defeated = defeated ?? false,
        siegeMode = siegeMode ?? false,
        unitIds = unitIds ?? {};

  static ArmyData fromJson(final Map<String, dynamic> json) =>
      _$ArmyDataFromJson(json);
  Map<String, dynamic> toJson() => _$ArmyDataToJson(this);

  Future<Army> toArmy({required final TransoxianaGame game}) async {
    final effectiveProvinceId = locationId;

    final effectiveLocation = effectiveProvinceId == null
        ? null
        : await _loadProvince(
            game: game,
            provinceId: effectiveProvinceId,
          );
    final effectiveNextLocationId = nextProvinceId;
    final effectiveNextLocation = effectiveNextLocationId == null
        ? null
        : await _loadProvince(
            game: game,
            provinceId: effectiveNextLocationId,
          );
    final effectiveDestinationId = destinationId;
    final effectiveDestination = effectiveDestinationId == null
        ? null
        : await _loadProvince(
            game: game,
            provinceId: effectiveDestinationId,
          );
    final effectiveNation = await _loadNation(game: game);
    final effectiveUnits = await _loadUnits(game: game);

    return Army._fromData(
      data: this,
      game: game,
      location: effectiveLocation,
      commander: await commander?.toCommander(game: game),
      nation: effectiveNation,
      units: effectiveUnits,
      nextProvince: effectiveNextLocation,
      destination: effectiveDestination,
    );
  }

  final ArmyId id;

  ProvinceName name;
  ArmyMode mode;

  @JsonKey(name: 'units')
  Set<UnitId>? unitIds;

  /// army commander that affects it on the field and in transit. always gets
  /// deployed to the *first* unit in the army.
  CommanderData? commander;
  Id? locationId;
  Id? destinationId;
  Id? nextProvinceId;

  /// movement progress to nextProvince where 1.0 means reaching it
  double progress;

  /// gold this unit is carrying that can be used in the location province.
  double goldCarried;

  /// Signifies that this army has been defeated and is not in the game any more
  bool defeated;

  /// if true will not assault the enemy forts encountered but besiege them.
  /// for defenders true = do not break out.
  bool siegeMode;

  Future<Province> _loadProvince({
    required final TransoxianaGame game,
    required final String provinceId,
  }) async {
    return game.campaignRuntimeData.getProvinceById(provinceId);
  }

  Future<Set<Unit>> _loadUnits({
    required final TransoxianaGame game,
  }) async {
    final list = await unitIds?.convert(
      (final unitId) async => game.campaignRuntimeData.getUnitById(
        unitId: unitId,
      ),
    );
    return list?.toSet() ?? {};
  }

  Future<Nation> _loadNation({required final TransoxianaGame game}) async {
    return game.campaignRuntimeData.getNationById(id.nationId);
  }

  @JsonKey(ignore: true)
  @override
  List<Object?> get props => [id];

  @JsonKey(ignore: true)
  @override
  bool? get stringify => true;

  @override
  @JsonKey(ignore: true)
  // ignore: hash_and_equals
  int get hashCode => super.hashCode;
}

class Army extends PositionComponent
    with EquatableMixin
    implements GameRef, DataSourceRef<ArmyData, Army> {
  Army._fromData({
    required this.data,
    required this.game,
    required this.location,
    required this.units,
    required this.commander,
    required this.nation,
    required this.destination,
    required this.nextProvince,
  }) : super(priority: ComponentsRenderPriority.campaignArmy.value);
  @override
  Future<void> onLoad() async {
    await _init();

    await super.onLoad();
  }

  Future<void> _init() async {
    setTranslationOffset();
    await appointNewCommander(replaceIfExists: false);
    pathSelector = ProvincePathSelector(this);
  }

  @override
  Future<void> refillData(final Army otherType) async {
    assert(
      otherType == this,
      'You trying to update different army.',
    );
    final newData = await otherType.toData();
    data = newData;
    nation = otherType.nation;
    location = otherType.location;
    units.assignAll(otherType.units);
    for (final unit in units) {
      unit.army = this;
    }
    commander = otherType.commander;
    destination = otherType.destination;
    nextProvince = otherType.nextProvince;
    await _init();
  }

  @override
  Future<ArmyData> toData() async => ArmyData(
        name: name,
        commander: commander?.data,
        defeated: defeated,
        goldCarried: goldCarried,
        mode: mode.toJson(),
        progress: progress,
        siegeMode: siegeMode,
        unitIds: units.map((final e) => e.id).toSet(),
        id: id..nationId = nation.id,
        locationId: location?.id,
        nextProvinceId: nextProvince?.id,
        destinationId: destination?.id,
      );

  @override
  TransoxianaGame game;
  @override
  ArmyData data;
  String get name => data.name;
  ArmyMode get mode => data.mode;
  ArmyId get id => data.id;

  Nation nation;

  final Set<Unit> units;

  Set<Unit> get fightingUnits =>
      units.where((final element) => element.isFighting).toSet();

  int get fightingUnitCount => fightingUnits.length;

  /// stored whenever path is recalculated, includes location and destination
  final List<Province> provincePath = [];

  /// This ability completely depends from units in army
  /// and shows how many provinces should be visible without
  /// a fog of war around this army
  int get visibleProvincesRange {
    if (units.isEmpty) return 0;
    return units.reduce((final maxUnit, final unit) {
      if (maxUnit.visionProvinceRange < unit.visionProvinceRange) return unit;
      return maxUnit;
    }).visionProvinceRange;
  }

  /// army commander that affects it on the field and in transit. always gets
  /// deployed to the *first* unit in the army.
  Commander? commander;
  Province? location;

  Province? destination;
  Province? nextProvince;

  /// movement progress to nextProvince where 1.0 means reaching it
  double get progress => data.progress;
  set progress(final double newProgress) => data.progress = newProgress;

  /// gold this unit is carrying that can be used in the location province.
  double get goldCarried => data.goldCarried;

  /// Signifies that this army has been defeated and is not in the game any more
  bool get defeated => data.defeated;

  /// if true will not assault the enemy forts encountered but besiege them.
  /// for defenders true = do not break out.
  bool get siegeMode => data.siegeMode;

  Sprite? get sprite =>
      units.firstWhere((final element) => element.isFighting).sprite;

  /// direction used to show the correct sprite depending on where
  /// this army is headed.
  Direction get direction => (location == null || nextProvince == null)
      ? Direction.south
      : offsetToDirection(
          location!.friendlyVector2 - nextProvince!.friendlyVector2,
        );

  /// component showing the army's path on the campaign map and its progress.
  /// Needs to be updated whenever orders are given or whenever visibility
  /// needs to be toggled
  late ProvincePathSelector pathSelector;

  /// offset added to army position to account for sprite size
  /// and possibly randomisation
  late Offset translationOffset;
  void setTranslationOffset() {
    // Offset(0 + this.game.rand.nextInt(50) /
    // 10.0, 0 + this.game.rand.nextInt(50) / 10.0);
    translationOffset = Offset.zero;
  }

  /// fills provincePath. Requires campaign to have loaded so cannot be called
  /// from _init
  void setProvincePath() {
    // if(location == null) return;
    if (destination != null && destination != location) {
      // upon loading provincePath will be empty so [_processMoveOrder] is
      // called to fill it
      _processMoveOrder(destination!);
    } else if (destination == location) {
      clearOrders();
    }
  }

  void appointCommanderUnit() {
    if (fightingUnits.isEmpty || commander?.unit != null) return;
    commander?.unit = fightingUnits.first;
  }

  Future<void> appointNewCommander({
    final bool replaceIfExists = true,
  }) async {
    if (commander == null || replaceIfExists) {
      if (nation.unemployedCommanders.isEmpty) {
        commander = await CommanderData().toCommander(game: game);
      } else {
        final newCommander = nation.unemployedCommanders.first;
        nation.unemployedCommanders.remove(newCommander);
        commander = newCommander;
      }
    }
    appointCommanderUnit();
  }

  void changeNation(final Nation newNation) {
    nation = newNation;
    id.nationId = newNation.id;

    for (final Unit unit in units) {
      unit.nation = newNation;
    }
    pathSelector.updatePainters();
  }

  /// top left coordinate is determined such that the center of the sprite
  /// lands on the given province coordinates (for friendly or hostile armies)
  Vector2? get topLeft => location == null
      ? null
      : (location!.nation.isFriendlyTo(nation)
              ? location!.friendlyVector2
              : location!.enemyVector2) -
          unitSize * 0.5;
  // -this.sizeOffset;

  Rect? get touchRect {
    if (location == null) return null;

    return Rect.fromPoints(
      topLeft!.toOffset(),
      (topLeft! + unitSize).toOffset(),
    );
  }

  /// unit whose sprite is used to render this army on the map
  Unit? get representativeUnit =>
      units.firstWhereOrNull((final element) => element.isFighting);

  Vector2 get unitSize {
    if (representativeUnit == null) {
      return Vector2(
        UiSizes.tileSize,
        UiSizes.tileSize,
      );
    }

    return representativeUnit!.unscaledSpriteSize * representativeUnitScale;
    // _unscaledSize *
    // (representativeUnit?.type.sprites[Direction.south] == null
    //     ? 1.0
    //     : unitSpriteScaleWithDirections);
  }

  double get representativeUnitScale =>
      unitSpriteCampaignScale *
      (representativeUnit!.type.sprites[representativeUnit!.direction] != null
          ? unitSpriteScaleWithDirections
          : 1.0);

  double get speed {
    if (units.isEmpty) return 0.0;
    // //lowest option
    // List<Unit> unitList = this.units.toList();
    // unitList.sort((a, b) => a.speed.compareTo(b.speed));
    // return unitList.first.speed.toDouble();
    //average option - more reflective of cavalry carrying siege equipment etc
    return units.fold<double>(
          0,
          (final previousValue, final element) => previousValue + element.speed,
        ) /
        units.length;
  }

  /// estimate of this army's total strength
  /// -> currently just sum of fighting units
  int get strength => units.where((final unit) => unit.isFighting).length;
  void renderUnit({required final Canvas canvas}) {
    if (location == null || location?.isNotVisibleToPlayer == true) return;
    final Unit? firstUnit =
        units.firstWhereOrNull((final element) => element.isFighting);

    if (firstUnit != null) {
      UnitPainter(
        game: game,
        center: topLeft! + unitSize * 0.5,
        scale: representativeUnitScale,
        diameter: unitSize.x,
        unit: firstUnit,
        spriteSize: unitSize,
        marker: markerType.army,
        overrideDirection: direction,
      ).paint(
        canvas,
        Size(unitSize.x, unitSize.y),
      );
    }
  }

  @override
  void render(final Canvas canvas) {
    super.render(canvas);
    renderUnit(canvas: canvas);
  }

  @override
  void update(final double dt) {
    super.update(dt);
    if (game.campaignRuntimeData.inCampaign) {
      if (game.temporaryCampaignData.isPaused == false) {
        if (location != null && !location!.isEngagingToArmy(this)) {
          //NOT ENGAGED

          //MOVE
          if (nextProvince != null) move(dt);

          //ARRIVE
          if (progress >= 1.0 && nextProvince != null) arrive(nextProvince!);
        }
      }

      if (location != null) pathSelector.update(dt);
    }
  }

  void move(final double dt) {
    if (location == null) return;
    progress = math.min(
      1.0,
      progress +
          ((speed * travelSpeedFactor) *
                  location!.weather.campaignSpeedFactor *
                  dt /
                  GameConsts.secondsToCommand) /
              location!.distanceToAdjacentLocation(nextProvince!),
    );
  }

  void arrive(final Province province) {
    if (location == null) return;
    if (!game.isHeadless && province.isVisibleToPlayer) {
      unawaited(representativeUnit?.playMoveSound());
    }

    log('$name reached ${province.name} from ${location!.name}');
    // if (provincePath.isNotEmpty)
    progress = 0.0;

    assert(provincePath.isNotEmpty);
    assert(provincePath.first == location);
    assert(provincePath.last == destination);

    provincePath.removeAt(0);
    location?.removeArmy(this);
    location = province;
    location!.setArmy(this);
    assert(location == province);

    if (location == destination) {
      clearOrders();
    } else {
      assert(provincePath.last == destination);

      if (provincePath.length >= 2) {
        assert(provincePath.first == province);
        nextProvince = provincePath[1];
      } else {
        throw Exception(
            'provincePath contains less than two elements before destination is'
            ' reached for $this ($location, $nextProvince, $destination), '
            '${provincePath.join(', ')}');
      }
    }

    //CAPTURE ENEMY PROVINCE
    captureLocationIfUndefended();
  }

  /// capture the current location if it is hostile and not defended
  void captureLocationIfUndefended() {
    if (location == null) return;

    if (location!.nation.isHostileTo(nation) &&
        location!.armies.values
            .where((final otherArmy) => otherArmy.nation.isHostileTo(nation))
            .isEmpty) {
      log('${location!.name} belongs to ${location!.nation} which is at '
          '${location!.nation.diplomaticRelationships[nation]} with $nation');
      // this.location.nation = this.nation;
      location!.capture(nation, autoAnnex: true); //
    }
  }

  /// add otherArmy's units to this army and then kill otherArmy
  void absorbAnotherArmy(final Army otherArmy) {
    for (final unit in otherArmy.units) {
      unit.army = this;
    }
    units.addAll(otherArmy.units);
    final otherCommander = otherArmy.commander;
    if (otherCommander != null) nation.unemployedCommanders.add(otherCommander);
    otherArmy.units.clear();
    data.goldCarried += otherArmy.goldCarried;
    // SchedulerBinding.instance
    //     .addPostFrameCallback((final timeStamp) => otherArmy.kill());
    otherArmy.kill();
  }

  void kill() {
    log('Killing Army $name');

    if (nation.getProvinces().isEmpty &&
        nation.getArmies().where((final element) => !element.defeated).length ==
            1) {
      nation.data.isDefeated = true;
    }

    data.defeated = true;

    for (final unit in units) {
      game.activeBattle?.units.remove(unit);
      game.campaignRuntimeData.units.remove(unit.id.unitId);
    }

    units.clear();

    location?.armies.remove(id);

    data.locationId = null;
    game.campaignRuntimeData.armies.remove(id.armyId);

    removeFromParent();

    if (game.temporaryCampaignData.selectedArmy == this) {
      game
        ..temporaryCampaignData.selectedArmy = null
        ..temporaryCampaignDataService.notify();
    }
  }

  /// total amount of provisions required to fully feed this army in a season
  double get provisionsDemand {
    return units.fold(
      0.0,
      (previousUnitValue, final unit) => previousUnitValue +=
          unit.health > 0.0 ? unitProvisionsConsumptionPerSeason : 0.0,
    );
  }

  bool get isFighting =>
      units.where((final unit) => unit.isFighting).isNotEmpty;

  /// suffer attrition due to only percentageSupplied
  /// of provisionsDemand being available
  Future<void> underSuppliedAttrition(final double percentageSupplied) async {
    assert(percentageSupplied >= 0.0);
    assert(percentageSupplied < 1.0);

    final double healthDamage = commander!.attritionMultiple *
        unitHealthAttritionFactor *
        (1 - percentageSupplied);
    final double moraleDamage = commander!.attritionMultiple *
        unitMoraleAttritionFactor *
        (1 - percentageSupplied);
    log('$name (of ${nation.name}) supplied $percentageSupplied suffering '
        '$healthDamage health and $moraleDamage morale '
        'damage in ${location?.name}');

    for (final Unit unit in units) {
      final double healthBefore = unit.health;
      unit
        ..receiveDamage(healthDamage)
        ..receiveMoraleDamage(moraleDamage);
      if (unit.health == 0.0 && healthBefore != 0.0) {
        location?.data.population += popsPerUnit * popsRecoveredInUnitAttrition;
      }
    }

    if (!isFighting) {
      final Province contestedProvince = location!;
      kill();
      final List<Army> hostileArmies = contestedProvince.armies.values
          .where(
            (final element) =>
                element.nation.isHostileTo(contestedProvince.nation) &&
                element.isFighting,
          )
          .toList();
      final List<Army> friendlyArmies = contestedProvince.armies.values
          .where(
            (final element) =>
                element.nation.isFriendlyTo(contestedProvince.nation) &&
                element.isFighting,
          )
          .toList();

      if (friendlyArmies.isEmpty && hostileArmies.isNotEmpty) {
        if (contestedProvince.nation.isHostileTo(hostileArmies.first.nation)) {
          await asyncInfoDialog(
            getScaffoldKeyContext(),
            S.current.siegeSuccessfulTitle,
            S.current.siegeSuccessfulContent(
              hostileArmies.first.nation.name,
              contestedProvince.name,
            ),
          );
          await contestedProvince.capture(hostileArmies.first.nation);
        }
      }
    }
  }

  /// heal units' health and morale
  void heal() {
    if (game.activeBattle == null) {
      //HEAL
      for (final Unit unit in units) {
        if (unit.health > 0.0) {
          //Heal health first
          unit.healDamage(unitHealingPerSeason);
          if (unit.health >= 100.0) {
            //Heal morale if at full health only
            unit.receiveMoraleBoost(unitMoraleRestorePerSeason);
          }
        }
        assert(unit.health <= 100.0);
        assert(unit.morale <= 100.0);
      }
    }
  }

  void taxLocation() {
    if (location == null) return;
    if (location!.nation != nation) return;
    taxProvince(location!);
  }

  /// tax province gold without checking if it has been taxed already
  void taxProvince(final Province province) {
    data.goldCarried += province.goldStored * taxRate;
    province.data.goldStored -=
        province.goldStored * (taxRate + taxGoldLeakage);
    province.data.hasBeenTaxedThisSeason = true;
  }

  void pillageProvinceGold(final Province province) {
    // sack for gold, can be in the context of capture or separate from it
    data.goldCarried += province.goldStored * sackGoldRate;
    province.data.goldStored -=
        province.goldStored * (sackGoldRate + sackGoldLeakage);
    province.data.hasBeenTaxedThisSeason = true;
  }

  Future<void> orderToProvince(final Province province) async {
    if (province == location) return;
    if (nation != game.player || game.isHeadless) {
      //AI move
      // if (!province.nation.isFriendlyTo(nation)) {
      //   nation.declareWar(province.nation);
      // }
      _processMoveOrder(province);
    } else {
      if (province.nation != nation) {
        if (province.nation.diplomaticRelationships[nation] ==
            DiplomaticStatus.peace) {
          if (!game.isHeadless) {
            final declaredWar =
                await nation.confirmWarDeclaration(province.nation);
            if (declaredWar == ConfirmAction.cancel) return;
          } else {
            nation.declareWar(province.nation);
          }
        }

        //either this nation, ally or an enemy
        if (province.nation.isFriendlyTo(nation) ||
            province.nation.isHostileTo(nation)) {
          if (province.nation.isHostileTo(nation) && province.fort != null) {
            final List<String> options = [
              S.current.attackingFortAssault,
              S.current.attackingFortBesiege,
            ];
            if (await asyncMultipleChoiceDialog(
                  getScaffoldKeyContext(),
                  S.current.attackingFortTitle,
                  S.current.attackingFortContent(province.name),
                  options,
                ) ==
                1) {
              data.siegeMode = true;
            } else {
              data.siegeMode = false;
            }
          }
        }
      }
      _processMoveOrder(province);

      game.temporaryCampaignData.selectedArmy = null;
      game.temporaryCampaignDataService.notify();
      pathSelector.showFor(1.0);
    }
  }

  void setToAssault() {
    data.siegeMode = false;
  }

  void setToSiege() {
    data.siegeMode = true;
  }

  /// clear orders and deselect armies
  Future<void> cancelOrders() async {
    clearOrders();
    await game.temporaryCampaignDataService.setState((final s) {
      s.selectedArmy = null;
      return null;
    });
  }

  /// clear destination and path to it
  void clearOrders() {
    data.progress = 0.0;
    nextProvince = null;
    destination = null;
    provincePath.clear();
  }

  void _processMoveOrder(final Province newDestination) {
    if (newDestination == location) return;

    updatePath(newDestination);
    assert(provincePath.first == location);
    assert(provincePath.last == newDestination);
    assert(provincePath.length > 1);
    final maybeNextProvince = provincePath[1];

    destination = newDestination;
    if (nextProvince != maybeNextProvince) data.progress = 0.0;
    nextProvince = maybeNextProvince;
    assert(location != maybeNextProvince);

    log(
      '$name going from ${location?.name}'
      ' to ${destination?.name} via ${nextProvince?.name}',
    );
  }

  void updatePath(final Province newDestination) {
    final effectiveLocation = location;
    if (effectiveLocation == null) throw ArgumentError.notNull('location');

    final path = game.campaign!.findPath(effectiveLocation, newDestination);
    if (path == null || path.isEmpty) throw ArgumentError.notNull('_path');

    provincePath.assignAll(<Province>[effectiveLocation] + path);
  }

  @JsonKey(ignore: true)
  @override
  List<Object?> get props => [id];

  @JsonKey(ignore: true)
  @override
  bool? get stringify => true;

  @override
  @JsonKey(ignore: true)
  // ignore: hash_and_equals, avoid_equals_and_hash_code_on_mutable_classes
  int get hashCode => super.hashCode;
}
