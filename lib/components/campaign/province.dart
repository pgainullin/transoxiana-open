import 'dart:developer';
import 'dart:math' as math;
import 'dart:ui';

import 'package:collection/src/iterable_extensions.dart';
import 'package:equatable/equatable.dart';
import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flame/flame.dart';
import 'package:flutter_svg/flutter_svg.dart'; // hide Svg;
import 'package:json_annotation/json_annotation.dart';
import 'package:svg_path_parser/svg_path_parser.dart';
import 'package:transoxiana/components/battle/unit.dart';
import 'package:transoxiana/components/campaign/city_walls_indicator.dart';
import 'package:transoxiana/components/campaign/fog_of_war.dart';
import 'package:transoxiana/components/campaign/province_render_filter.dart';
import 'package:transoxiana/components/campaign/weather.dart';
import 'package:transoxiana/components/game/game.dart';
import 'package:transoxiana/components/shared/army.dart';
import 'package:transoxiana/components/shared/components_render_priority.dart';
import 'package:transoxiana/components/shared/fortification.dart';
import 'package:transoxiana/components/shared/nation.dart';
import 'package:transoxiana/components/shared/traversable_map.dart';
import 'package:transoxiana/data/army_modes.dart';
import 'package:transoxiana/data/campaign_data_source.dart';
import 'package:transoxiana/data/constants.dart';
import 'package:transoxiana/data/unit_types.dart';
import 'package:transoxiana/generated/l10n.dart';
import 'package:transoxiana/services/debug_game_service.dart';
import 'package:transoxiana/services/geometry.dart' as game_geometry;
import 'package:transoxiana/widgets/base/dialogues.dart';
import 'package:utils/utils.dart';

part 'province.g.dart';

/// Serializable/Mutable class serves to supply data,
/// !do not keep any logic here
///
/// This class should be used to keep/save/load data
///
/// [Province] can be created by [ProvinceData.toProvince]
@JsonSerializable(explicitToJson: true)
class ProvinceData with EquatableMixin {
  ProvinceData({
    required this.name,
    required this.x,
    required this.y,
    required this.width,
    required this.height,
    required this.friendlyX,
    required this.friendlyY,
    required this.enemyX,
    required this.enemyY,
    required this.nationId,
    final Id? id,
    final WeatherType? weatherType,
    final double? population,
    final double? provisionsCapacity,
    final double? provisionsStored,
    final double? goldYieldPerPop,
    final double? goldStored,
    final double? provisionsYield,
    final double? cumulativeIrrigation,
    final bool? hasBeenTaxedThisSeason,
    final bool? hasTrainedUnitsThisSeason,
    final Set<UnitTypeNames>? specialUnitsIds,
    final Set<ArmyId>? armies,
    final List<List<int>>? attackDeploymentPoints,
    final List<List<int>>? defenceDeploymentPoints,
    final List<Id>? edges,
    final Set<Id>? visibleForNations,
    final String? maskSvgPath,
    this.fort,
    this.fortPath,
    this.mapPath,
  })
      : id = id ?? uuid.v4(),
        maskSvgPath = maskSvgPath ?? '',
        population = population ?? 50000.0,
        provisionsCapacity = provisionsCapacity ?? 50000.0,
        goldYieldPerPop = goldYieldPerPop ?? defaultGoldYieldPerPersonPerSeason,
        provisionsStored = provisionsStored ?? .0,
        goldStored = goldStored ?? .0,
        provisionsYield = provisionsYield ?? 31250.0,
        cumulativeIrrigation = cumulativeIrrigation ?? .0,
        hasBeenTaxedThisSeason = hasBeenTaxedThisSeason ?? false,
        hasTrainedUnitsThisSeason = hasTrainedUnitsThisSeason ?? false,
        specialUnitsIds = specialUnitsIds ?? {},
        armies = armies ?? {},
        attackDeploymentPoints = attackDeploymentPoints ?? [],
        defenceDeploymentPoints = defenceDeploymentPoints ?? [],
        edges = edges ?? [],
        visibleForNations = visibleForNations ?? {} {
    if (provisionsStored == null || provisionsStored == .0) {
      this.provisionsStored = this.provisionsCapacity * .75;
    }
    if (goldStored == null || goldStored == .0) {
      this.goldStored = this.population * startingGoldPerPerson;
    }
    if (this.id.isEmpty) {
      this.id = uuid.v4();
    }
    this.weatherType = weatherType ?? WeatherType.sunny;
  }

  static ProvinceData fromJson(final Map<String, dynamic> json) =>
      _$ProvinceDataFromJson(json);

  Map<String, dynamic> toJson() => _$ProvinceDataToJson(this);

  Future<Province> toProvince({
    required final TransoxianaGame game,
  }) async {
    final effectiveArmies = await armies.convert(
          (final armyId) => game.campaignRuntimeData.getArmyById(armyId),
    );
    final effectiveVisibleForNations = await visibleForNations.convert(
          (final nationId) => game.campaignRuntimeData.getNationById(nationId),
    );
    final effectiveNation =
    await game.campaignRuntimeData.getNationById(nationId);
    final maskSvgStr = await _loadImageMaskStr();
    final maskSvg = await _loadImageMask(maskSvgStr);
    final image = await _loadImage(maskSvg: maskSvg);
    return Province._fromData(
      data: this,
      game: game,
      fort: await _loadFort(game: game),
      visibleForNations: Map.fromEntries(
        effectiveVisibleForNations.map((final e) => MapEntry(e.id, e)),
      ),
      armies: Map.fromEntries(
        effectiveArmies.map((final e) => MapEntry(e.id, e)),
      ),
      nation: effectiveNation,
      specialUnitsTypes: await _loadSpecialUnits(game: game),
      image: image,
      maskSvg: maskSvg,
      weather: await _loadWeather(weatherType),
    );
  }

  String name;
  double x;
  double y;
  double width;
  double height;
  double friendlyX;
  double friendlyY;
  double enemyX;
  double enemyY;
  @JsonKey(name: 'mask')
  String maskSvgPath;

  /// nation index in a list of nations
  String nationId;
  Id id;

  /// path to the tiled file containing the battle map for this province - if null, battles play out in a random map
  @JsonKey(name: 'map')
  final String? mapPath;
  final String? fortPath; //path to the JSON file

  /// destructible fortifications of this province if it has them, or null
  FortificationData? fort;

  /// This set purpose is to keep all nations, who sees
  /// this province through the fog of war
  Set<Id> visibleForNations;

  final List<List<int>> attackDeploymentPoints;
  final List<List<int>> defenceDeploymentPoints;

  //Resources
  double population; // number of inhabitants

  double provisionsCapacity; // storage capacity in metric tonnes
  double provisionsStored;
  double provisionsYield; //production per year in metric tonnes
  double cumulativeIrrigation; //1.0+ means full harvest

  double goldStored;
  double goldYieldPerPop;
  bool hasBeenTaxedThisSeason; //can only tax once per season
  bool hasTrainedUnitsThisSeason; //can only train once per season

  /// UnitTypes that this nation can build in addition to basic units
  /// and Nation specialUnits
  @JsonKey(name: 'specialUnits')
  final Set<UnitTypeNames> specialUnitsIds;

  /// other provinces this province is connected to - used to build a graph
  final List<Id> edges;
  final Set<ArmyId> armies;

  /// current weather in this province
  late WeatherType weatherType;

  Future<Fortification?> _loadFort({
    required final TransoxianaGame game,
  }) async {
    FortificationData? fortData = fort;
    if (fortData == null) {
      if (fortPath != null && fortPath!.isNotEmpty) {
        fortData = await FortificationData.fromJsonPath(fortPath!);
      }
    }
    return fortData?.toFortification(game: game);
  }

  Future<List<UnitType>> _loadSpecialUnits({
    required final TransoxianaGame game,
  }) async {
    final units = await specialUnitsIds.convert(
          (final unitTypeId) async =>
          game.campaignRuntimeData.getUnitTypeById(unitTypeId),
    );
    return units.toList();
  }

  /// cached content of mask image
  String _maskSvgStr = '';

  Future<String> _loadImageMaskStr() async {
    if (_maskSvgStr.isNotEmpty == true) return _maskSvgStr;
    assert(maskSvgPath
        .split('.')
        .last
        .toLowerCase() == 'svg');
    final String assetFileString =
    await Flame.assets.readFile('images/$maskSvgPath');
    _maskSvgStr = assetFileString;
    return assetFileString;
  }

  Future<Weather> _loadWeather(final WeatherType type) async =>
      getWeatherByType(type);

  Future<DrawableRoot> _loadImageMask(final String assetFileString) async =>
      svg.fromSvgString(assetFileString, assetFileString);

  Future<Image> _loadImage({required final DrawableRoot maskSvg}) async {
    // this.svgPath = parseSvgPath(xmlFirstSvgPath.allMatches(assetFileString).first.group(1), failSilently: true);
    // svg.('images/' + this.maskImage);

    // if (this.svgPath != null) {
    final Picture picture = maskSvg.toPicture(
      size: touchRect.size,
      // colorFilter: filter,
      // clipToViewBox: true,
    );
    return await picture.toImage(
      touchRect.width.toInt(),
      touchRect.height.toInt(),
    );
    // log('$maskImage loaded');
  }

  // TODO(arenukvern): add memoize
  Vector2 get enemyVector2 =>
      Vector2(
        enemyX * inverseMapImageBaseScale,
        enemyY * inverseMapImageBaseScale,
      );

  // TODO(arenukvern): add memoize
  Vector2 get friendlyVector2 =>
      Vector2(
        friendlyX * inverseMapImageBaseScale,
        friendlyY * inverseMapImageBaseScale,
      );

  // TODO(arenukvern): add memoize
  /// world top left position
  ///
  Vector2 get position => Vector2(x, y) * inverseMapImageBaseScale;

  // TODO(arenukvern): add memoize
  Vector2 get size => Vector2(width, height) * inverseMapImageBaseScale;

  // TODO(arenukvern): add memoize
  /// world bottom left position
  Vector2 get bottomRightPosition => position + size;

  // TODO(arenukvern): add memoize
  Rect get touchRect => position.toPositionedRect(size);

  // (this.svgPath != null ? this.fallbackWidth : this.image.width) *
  // (this.svgPath != null ? this.fallbackHeight : this.image.height) *

  @override
  @JsonKey(ignore: true)
  List<Object?> get props => [id];

  @override
  @JsonKey(ignore: true)
  // ignore: hash_and_equals
  int get hashCode => super.hashCode;

  @override
  @JsonKey(ignore: true)
  bool? get stringify => true;
}

/// Not serializable runtime only type
/// !Place logic here
/// If you need to add new data - use [ProvinceData] class
///
/// Should be created only by [ProvinceData.toProvince]
class Province extends Component
    with EquatableMixin, SuperMapLocation<Province>
    implements
        GameRef,
        DataSourceRef<ProvinceData, Province>,
        MapLocation<Province> {
  Province._fromData({
    required this.data,
    required this.game,
    required this.specialUnitsTypes,
    required this.nation,
    required this.visibleForNations,
    required this.armies,
    required this.image,
    required this.maskSvg,
    required this.weather,
    required this.fort,
  }) : super(priority: ComponentsRenderPriority.campaignProvince.value) {
    weather.province = this;
  }

  @override
  Future<void> refillData(final Province otherType) async {
    assert(otherType == this, 'You trying to update different province.');
    final newData = await otherType.toData();
    data = newData;
    specialUnitsTypes = otherType.specialUnitsTypes;
    nation = otherType.nation;
    visibleForNations.assignAll(otherType.visibleForNations);
    armies.assignAll(otherType.armies);
    image = otherType.image;
    maskSvg = otherType.maskSvg;
    await updateWeather(); //add savedWeather: otherType.weather.type when json updated
    final otherFort = otherType.fort;
    if (otherFort != null) {
      if (fort == null) {
        await setFort(otherFort);
      } else {
        await fort?.refillData(otherFort);
      }
    }
  }

  @override
  Future<void>? onLoad() async {
    await super.onLoad();
    renderFilter.updateFilters();

    // if(weather.isMounted) game.remove(weather);
    // weather.removeFromParent();
    // await add(weather);
    await updateWeather(savedWeather: weather.type);
    await add(fogOfWar);
    await add(renderFilter);
    await setFort(fort);
  }

  @override
  Future<ProvinceData> toData() async =>
      ProvinceData(
        id: id,
        enemyX: enemyX,
        enemyY: enemyY,
        friendlyX: friendlyX,
        friendlyY: friendlyY,
        height: height,
        name: name,
        nationId: nation.id,
        width: width,
        x: x,
        y: y,
        armies: armies.keys.toSet(),
        attackDeploymentPoints: attackDeploymentPoints,
        cumulativeIrrigation: cumulativeIrrigation,
        defenceDeploymentPoints: defenceDeploymentPoints,
        edges: edges,
        fort: fort?.data,
        fortPath: fortPath,
        goldStored: goldStored,
        goldYieldPerPop: goldYieldPerPop,
        hasBeenTaxedThisSeason: hasBeenTaxedThisSeason,
        hasTrainedUnitsThisSeason: hasTrainedUnitsThisSeason,
        mapPath: data.mapPath,
        maskSvgPath: data.maskSvgPath,
        population: population,
        provisionsCapacity: provisionsCapacity,
        provisionsStored: provisionsStored,
        provisionsYield: provisionsYield,
        specialUnitsIds: specialUnitsTypes.map((final e) => e.id).toSet(),
        visibleForNations: visibleForNations.keys.toSet(),
        weatherType: weather.type,
      );
  @override
  TransoxianaGame game;
  @override
  ProvinceData data;

  Id get id => data.id;

  String get name => data.name;

  /// world x position
  double get x => data.x;

  /// world y position
  double get y => data.y;

  /// world position (top left)
  Vector2 get position => data.position;

  /// world width
  double get width => data.width;

  /// world height
  double get height => data.height;

  Rect get touchRect => data.touchRect;

  /// world center
  Vector2 get center => data.touchRect.center.toVector2();

  Vector2 get friendlyVector2 => data.friendlyVector2;

  Vector2 get enemyVector2 => data.enemyVector2;

  double get friendlyX => data.friendlyX;

  double get friendlyY => data.friendlyY;

  double get enemyX => data.enemyX;

  double get enemyY => data.enemyY;
  Nation nation;

  /// path to the tiled file containing the battle map for this province - if null, battles play out in a random map
  String? get mapPath => data.mapPath;

  String? get fortPath => data.fortPath; //path to the JSON file

  /// destructible fortifications of this province if it has them, or null
  /// To destroy or set new always use [setFort] or [destroyFort]
  Fortification? fort;

  Future<void> setFort(final Fortification? newFort) async {
    destroyFort();
    if (newFort == null) return;

    fort = newFort;
  }

  void destroyFort() {
    if (fort == null) return;
    fort = null;
  }

  CityWallsIndicator? get wallsIndicator => fort?.cityWallsIndicator;

  /// This set purpose is to keep all nations, who sees
  /// this province through the fog of war
  final Map<Id, Nation> visibleForNations;

  late final fogOfWar = FogOfWar(province: this);
  late final renderFilter = ProvinceRenderFilter(province: this);

  List<List<int>> get attackDeploymentPoints => data.attackDeploymentPoints;

  List<List<int>> get defenceDeploymentPoints => data.defenceDeploymentPoints;

  //Resources
  double get population => data.population; // number of inhabitants

  double get provisionsCapacity =>
      data.provisionsCapacity; // storage capacity in metric tonnes
  double get provisionsStored => data.provisionsStored;

  double get provisionsYield =>
      data.provisionsYield; //production per year in metric tonnes
  double get cumulativeIrrigation =>
      data.cumulativeIrrigation; //1.0+ means full harvest

  double get goldStored => data.goldStored;

  double get goldYieldPerPop => data.goldYieldPerPop;

  bool get hasBeenTaxedThisSeason =>
      data.hasBeenTaxedThisSeason; //can only tax once per season
  bool get hasTrainedUnitsThisSeason =>
      data.hasTrainedUnitsThisSeason; //can only train once per season
  List<UnitType> specialUnitsTypes;

  /// other provinces this province is connected to - used to build a graph
  List<Id> get edges => data.edges;

  /// Do not add directly army to [armies].
  /// Always use [setArmy], [removeArmy], [getArmy]
  ///
  /// Exception [onLoad] [refill] and those methods that
  /// should run before rendering
  final Map<ArmyId, Army> armies;

  Army? getArmy(final ArmyId armyId) => armies[armyId];

  void setArmy(final Army army) {
    armies[army.id] = army;
    army.location = this;
  }

  void removeArmy(final Army army) {
    armies.remove(army.id);
  }

  /// current weather in this province
  Weather weather;

  Image image;
  DrawableRoot maskSvg;

  String? get maskSvgStr => data.maskSvgPath;
  Path? _maskPath;

  Path get maskPath {
    final path = maskSvgStr;
    if (path == null) return Path();
    return _maskPath ??= parseSvgPath(path);
  }

  // Path svgPath;

  bool isProvinceVisibleForNation({required final Nation specificNation}) =>
      visibleForNations.containsKey(specificNation.id);

  bool isProvinceNotVisibleForNation({required final Nation specificNation}) =>
      !isProvinceVisibleForNation(specificNation: specificNation);

  bool get isSelected =>
      game.temporaryCampaignDataService.state.selectedProvince == this;

  /// Returns true if this province is covered by fog of war for the game.player nation.
  bool get isNotVisibleToPlayer => !isVisibleToPlayer;

  bool get isVisibleToPlayer {
    switch (game.debugService.state.fogOfWarVisibility) {
      case VisibilityState.whatEnemiesSee:
        throw UnimplementedError();
      case VisibilityState.hidden:
        return true;
      case VisibilityState.whatPlayerSee:
        if (game.player == null) return false;
        return isProvinceVisibleForNation(specificNation: game.player!);
    }
  }

  /// getter returning true if this province has a fort with at least one live segment
  bool get isFortified =>
      fort != null &&
          fort!
              .segments
              .where((final element) => element.life > 0.0)
              .isNotEmpty;

  double get goldAvailable =>
      goldStored +
          armies.values
              .where((final element) => element.nation == nation)
              .fold<double>(
            0.0,
                (final previousValue, final army) =>
            previousValue + army.goldCarried,
          );

  int getArmyMaxVisibilityRange({required final Nation armyNation}) {
    if (armies.isEmpty) return 0;
    final nationArmies =
    armies.values.where((final element) => element.nation == armyNation);
    if (nationArmies.isEmpty) return 0;
    final Army maybeArmy = armies.values.reduce((final value, final element) {
      if (value.visibleProvincesRange < element.visibleProvincesRange) {
        return element;
      }
      return value;
    });
    return maybeArmy.visibleProvincesRange;
  }

  /// Null safe armies sorted in position order
  /// and ready for render
  List<Army> get armiesListSortedByPosition {
    final nullSafeArmies = armies.values
        .where((final element) => element.topLeft != null)
        .toList();
    nullSafeArmies
        .sort((final a, final b) => a.topLeft!.y.compareTo(b.topLeft!.y));
    return nullSafeArmies;
  }

  Set<Nation> get armiesNations =>
      armies.values.map((final e) => e.nation).toSet();

  /// Sets nations in nearest provinces
  /// to make provinces visible for this nation
  void setVisibleProvinces() {
    /// always visible for owner nation
    visibleForNations[nation.id] = nation;
    if (edges.isEmpty || armies.isEmpty) return;

    /// Discovered level is a counter how edges may be discovered
    void setNationToProvinces({
      required final List<Id> provinceEdges,
      required final int discoveredLevel,
      required final Nation armyNation,
    }) {
      for (final provinceId in provinceEdges) {
        final Province? maybeProvince =
        game.campaignRuntimeData.provinces[provinceId];
        if (maybeProvince == null) continue;
        maybeProvince.visibleForNations[armyNation.id] = armyNation;
        if (discoveredLevel <= 0) continue;
        setNationToProvinces(
          discoveredLevel: discoveredLevel - 1,
          provinceEdges: maybeProvince.edges,
          armyNation: armyNation,
        );
      }
    }

    for (final armyNation in armiesNations) {
      final armyVisibility = getArmyMaxVisibilityRange(armyNation: armyNation);
      if (armyVisibility <= 0) continue;
      setNationToProvinces(
        discoveredLevel: armyVisibility,
        provinceEdges: edges,
        armyNation: armyNation,
      );
    }
  }

  // static RegExp xmlFirstSvgPath = new RegExp('\<path d="(.*)"/>', multiLine: true, caseSensitive: false, dotAll: true);

  Map<String, dynamic> toAiJson() {
    return Map<String, dynamic>.fromEntries([
      MapEntry('name', name),
      MapEntry('x', x),
      MapEntry('y', y),
      MapEntry('height', height),
      MapEntry('width', width),
      MapEntry('mask', data.maskSvgPath),
      MapEntry('map', mapPath),
      MapEntry('fortification', fortPath),
      MapEntry('attackDeploymentPoints', attackDeploymentPoints),
      MapEntry('defenceDeploymentPoints', defenceDeploymentPoints),
      MapEntry(
        'nation',
        game.campaignRuntimeData.nations.values.toList().indexOf(nation),
      ),
      MapEntry('friendlyX', friendlyX),
      MapEntry('friendlyY', friendlyY),
      MapEntry('enemyX', enemyX),
      MapEntry('enemyY', enemyY),
      MapEntry('population', population),
      MapEntry('provisionsCapacity', provisionsCapacity),
      MapEntry('provisionsStored', provisionsStored),
      MapEntry('provisionsYield', provisionsYield),
      MapEntry('cumulativeIrrigation', cumulativeIrrigation),
      MapEntry('goldStored', goldStored),
      MapEntry('goldYieldPerPop', goldYieldPerPop),
      MapEntry('weather', weather.type),
      MapEntry(
        'specialUnits',
        specialUnitsTypes.map((final e) => e.id).toList(),
      ),
      MapEntry('hasTrainedUnitsThisSeason', hasTrainedUnitsThisSeason),
      MapEntry('hasBeenTaxedThisSeason', hasBeenTaxedThisSeason),
      MapEntry('edges', edges),
    ]);
  }

  @override
  String toString() {
    return '<Province>: $name';
  }

  Offset get unscaledCentre => data.touchRect.center;

  @override
  double distanceToAdjacentLocation(final Province otherProvince) {
    return (unscaledCentre - otherProvince.unscaledCentre).distance;
  }

  /// 0.0-100.0 indicator of fort average life
  double? get fortIntegrity {
    if (fort == null || fort!.segments.isEmpty) return null;
    return fort?.integrity;
  }

  @override
  void render(final Canvas canvas) {
    super.render(canvas);
    if (wallsIndicator != null) {
      canvas
        ..save()
        ..translate(friendlyVector2.x, friendlyVector2.y);
      wallsIndicator?.render(canvas);
      canvas.restore();
    }
  }

  /// whether a given Army is blocked from leaving this Province by enemy armies
  bool isEngagingToArmy(final Army army) {
    if (fort != null && fortIntegrity! > 0.0) {
      if (nation.isHostileTo(army.nation)) {
        // the given army is a besieger which can walk away as long as all the defenders are in siege mode
        return armies.values
            .where(
              (final otherArmy) =>
          (otherArmy.siegeMode == false) &&
              otherArmy.nation.isHostileTo(army.nation),
        )
            .isNotEmpty;
      } else if (nation.isFriendlyTo(army.nation)) {
        // the given army is a defender and can only leave
        // if there are no enemies
        return armies.values
            .where(
              (final otherArmy) => otherArmy.nation.isHostileTo(army.nation),
        )
            .isNotEmpty;
      } else {
        // the given army is neutral and can leave if there are no enemies
        return armies.values
            .where(
              (final otherArmy) => otherArmy.nation.isHostileTo(army.nation),
        )
            .isNotEmpty;
      }
    } else {
      // non-fort situations - can only leave if no enemies
      return armies.values
          .where((final otherArmy) => otherArmy.nation.isHostileTo(army.nation))
          .isNotEmpty;
    }
  }

  Future<void> capture(final Nation newNation, {
    final bool autoAnnex = false,
  }) async {
    final Nation oldNation = nation;

    nation = newNation;
    // renderFilter.updateFilters();

    if (game.player == newNation) {
      //player decides post province capture

      if (game.isHeadless == false) {
        final List<String> options = [
          S.current.provinceCaptureDialogueAnnex,
          S.current.provinceCaptureDialogueSack,
        ];
        if (!autoAnnex &&
            await asyncMultipleChoiceDialog(
              getScaffoldKeyContext(),
              S.current.provinceCaptureDialogueTitle(name, newNation.name),
              S.current.provinceCaptureDialogueContent(name),
              options,
            ) ==
                1) {
          await sack();
          armies.values
              .firstWhere((final element) => element.nation == newNation)
              .pillageProvinceGold(this);
        }
      }
    } else {
      //AI decides what to do
      // TODO: add AI decision
    }

    renderFilter.updateFilters();

    oldNation.checkIfDefeated();
  }

  /// add the province to the given nation without the possibility to
  /// sack or any dialogues - used in diplomatic actions / events
  void annex(final Nation newNation) {
    final Nation oldNation = nation;
    nation = newNation;
    renderFilter.updateFilters();

    oldNation.checkIfDefeated();
  }

  /// sack a province after capturing it reducing its population and
  /// generating captives and todo: other resources
  Future<void> sack() async {
    /// diminish population
    final double sackCasualties = population * sackPopulationShare;

    data.population -= sackCasualties;

    //take captives if the nation has the ability
    if (nation.takeCaptives == true) {
      final int newUnits =
      (captivePopulationShare * sackCasualties / populationPerCaptiveUnit)
          .round();

      if (newUnits > 0) {
        for (int i = 0; i <= newUnits; i += 1) {
          final unitData = UnitData(
            id: UnitId(
              unitId: null,
              // TODO(arenukvern): fix type
              typeId: UnitTypeNames.captives,
              // game.campaignRuntimeData.unitTypes.values.first.id,
              nationId: nation.id,
            ),
          );
          final unit = await unitData.toUnit(game: game);

          final army = armies.values
              .firstWhereOrNull((final element) => element.nation == nation);
          army?.units.add(unit);
          unit.army = army;
        }
      }
    }

    //destroy fortifications
    if (fort != null) {
      for (final Segment element in fort!.segments) {
        element.receiveDamage(100.0);
      }
    }
  }

  Future<void> seasonStartActions() async {
    growPopulation();
    produceGold();
    data
      ..hasBeenTaxedThisSeason = false
      ..hasTrainedUnitsThisSeason = false;
    repairFort();
    await updateWeather();
  }

  Future<void> updateWeather({final WeatherType? savedWeather}) async {
    Weather? newWeather;
    if (savedWeather != null) {
      newWeather = await getWeatherByType(savedWeather);
    } else {
      newWeather =
      await generateWeather(game.campaignRuntimeData.currentSeason);
      switch (weather.type) {
        case WeatherType.rain:
          data.cumulativeIrrigation += rainIrrigationContributionPerSeason;
          break;
        case WeatherType.snow:
          data.cumulativeIrrigation += snowIrrigationContributionPerSeason;
          break;
        case WeatherType.cloudy:
          data.cumulativeIrrigation += cloudIrrigationContributionPerSeason;
          break;
        case WeatherType.sunny:
          data.cumulativeIrrigation += sunIrrigationContributionPerSeason;
          break;
      }
    }

    newWeather.province = this;

    if (weather.parent != null) remove(weather);
    await add(newWeather);
    weather = newWeather;
  }

  /// produce provisions - this is run every season.Spring
  void harvest() {
    final double realisedYield = math.min(
      1.0,
      math.max(0.0, cumulativeIrrigation),
    ) *
        math.min(
          provisionsYield,
          maxProvisionsYieldPerPersonPerSeason * population,
        );
    data.cumulativeIrrigation = 0.0;

    final double excessProduction =
    math.max(0, provisionsStored + realisedYield - provisionsCapacity);

    data.provisionsStored =
        math.min(provisionsCapacity, provisionsStored + realisedYield);

    if (excessProduction > 0) {
      trade(excessProduction);
    }
  }

  /// distribute a given quantity of provisions between neighbours
  //TODO: add longer-range trade
  void trade(final double provisionsQuantity) {
    double tradableQuantity = provisionsQuantity;
    final campaign = game.campaign;
    if (campaign == null) throw ArgumentError.notNull('camapign');
    for (final edge in edges) {
      if (provisionsCapacity > 0.0) {
        final neighbour = game.campaignRuntimeData.provinces[edge]!;
        if (nation.diplomaticRelationships[neighbour.nation] !=
            DiplomaticStatus.war &&
            neighbour.provisionsStored < neighbour.provisionsCapacity) {
          double quantityTraded = math.min(
            tradableQuantity,
            neighbour.provisionsCapacity - neighbour.provisionsStored,
          );

          // adjust quantity traded to quantity affordable
          quantityTraded = math.min(
            quantityTraded,
            neighbour.goldStored / provisionsPrice,
          );

          neighbour.data.provisionsStored += quantityTraded;
          neighbour.data.goldStored -= quantityTraded * provisionsPrice;
          tradableQuantity -= quantityTraded;
          data.goldStored += quantityTraded * provisionsPrice;
        }
      }
    }
  }

  void produceGold() {
    //every season every province produces gold scaled by its population
    data.goldStored +=
        goldYieldPerPop * game_geometry.smoothStep(0.0, 100000.0, population);
  }

  /// have population and armies consume provisions - this is run evey season
  /// and before harvest to ensure available production doesn't get traded away
  Future<void> consume() async {
    final double armyDemand = armies.values.fold(
      0.0,
          (previousValue, final army) => previousValue += army.provisionsDemand,
    );
    // log('Armies in ${this.name} demand $armyDemand');

    if (provisionsStored >= armyDemand) {
      armies.values.forEach(healArmy);
      data.provisionsStored -= armyDemand;
    } else {
      if (fort != null) {
        //in a siege besiegers are assumed to consume first before the defenders
        // get anything as they are able to intercept shipments
        final Set<Army> besiegingArmies = armies.values
            .where((final army) => !army.nation.isFriendlyTo(nation))
            .toSet();
        final Set<Army> friendlyArmies =
        armies.values.toSet().difference(besiegingArmies);

        final double besiegerDemand = besiegingArmies.fold(
          0.0,
              (previousValue, final army) =>
          previousValue += army.provisionsDemand,
        );

        final double friendlyDemand = friendlyArmies.fold(
          0.0,
              (previousValue, final army) =>
          previousValue += army.provisionsDemand,
        );

        if (provisionsStored * (1 + besiegingArmyProvisionsBonus) >=
            besiegerDemand) {
          //besiegers fed fully
          besiegingArmies.forEach(healArmy);
          data.provisionsStored -= math.min(besiegerDemand, provisionsStored);
        } else {
          final double supplyPercentage = provisionsStored *
              (1 + besiegingArmyProvisionsBonus) /
              besiegerDemand;
          for (final Army army in besiegingArmies) {
            await army.underSuppliedAttrition(supplyPercentage);
          }

          data.provisionsStored = 0.0;
        }

        if (provisionsStored >= friendlyDemand) {
          // friendlies fed fully
          friendlyArmies.forEach(healArmy);
          data.provisionsStored -= friendlyDemand;
        } else {
          final double supplyPercentage = provisionsStored / friendlyDemand;
          for (final Army army in friendlyArmies) {
            await army.underSuppliedAttrition(supplyPercentage);
          }
          data.provisionsStored = 0.0;
        }
      } else {
        final double supplyPercentage = provisionsStored / armyDemand;
        final provinceArmies = [...armies.values];
        for (final Army army in provinceArmies) {
          await army.underSuppliedAttrition(supplyPercentage);
        }
      }
      data.provisionsStored = 0.0;
    }

    final double populationDemand =
        population * populationProvisionsConsumptionPerSeason;
    if (provisionsStored >= populationDemand) {
      data.provisionsStored -= populationDemand;
    } else {
      //starvation
      data
        ..population -= population *
          populationAttritionRate *
          (1 - provisionsStored / populationDemand)
            ..provisionsStored = 0.0;
    }

    // log('Population in ${this.name} demand $populationDemand. Resulting stored $provisionsStored');
  }

  void healArmy(final Army army) => army.heal();

  void growPopulation() {
    data.population *= 1 + populationGrowthPerSeason;
  }

  void repairFort() {
    if (fort != null) {
      double repairBudget = math.min(
        fortRepairFactor * fort!.segments.length,
        maxFortRepairPerPerson * population,
      );
      // log('Repair budget of $repairBudget spent on ${this.fort.segments.length} segments');

      for (final Segment segment in fort!.segments) {
        if (repairBudget > 0.0) {
          final double thisRepair = math.min(
            100.0 - segment.life,
            repairBudget,
          );
          segment.repair(thisRepair);
          repairBudget -= thisRepair;
        }
      }
    }
  }

  /// return list of UnitTypes that can be produced in this Province while it is owned by the current owner
  List<UnitType> getAvailableUnits() {
    return specialUnitsTypes +
        nation.specialUnitsTypes +
        game.campaignRuntimeData.defaultUnitTypes
            .whereType<UnitType>()
            .toList();
  }

  /// returns list of UnitTypes that can be trained in this Province given the gold available
  List<UnitType> getAffordableUnits() {
    if (hasTrainedUnitsThisSeason == true) return <UnitType>[];

    if (population > popsPerUnit * inverseDraftablePopsProportion) {
      final availableUnits = getAvailableUnits();
      final affordableUnits = availableUnits
          .where((final element) => element.cost <= goldAvailable)
          .toList();
      return affordableUnits;
    } else {
      return <UnitType>[];
    }
  }

  /// Pick a random affordable unit type and train a unit of that type.
  Future<Unit?> trainRandomUnit([final Army? preferredArmyToAllocateTo]) async {
    final List<UnitType> affordableUnits = getAffordableUnits();
    if (affordableUnits.isNotEmpty) {
      return trainUnit(
        affordableUnits.randomElement()!,
        preferredArmyToAllocateTo,
      );
    } else {
      return null;
      // log('No affordable units');
    }
  }

  /// Pick the most expensive affordable unit type and train a unit of that type
  Future<Unit?> trainMostExpensiveUnit([
    final Army? preferredArmyToAllocateTo,
  ]) async {
    final List<UnitType> affordableUnits = getAffordableUnits();
    if (affordableUnits.isNotEmpty) {
      affordableUnits.sort((final a, final b) => a.cost.compareTo(b.cost));
      return trainUnit(affordableUnits.last, preferredArmyToAllocateTo);
    } else {
      return null;
      // log('No affordable units');
    }
  }

  /// train a unit of a given type, place it in an army and call for payment
  /// of its cost.
  /// Note this does not check affordability and will trip up if
  /// there is not enough gold.
  Future<Unit> trainUnit(final UnitType type,
      final Army? preferredArmyToAllocateTo,) async {
    final unitData = UnitData(
      id: UnitId(
        unitId: null,
        typeId: type.id,
        nationId: nation.id,
      ),
      armyId: preferredArmyToAllocateTo?.id,
    );
    final newUnit = await unitData.toUnit(game: game);
    if (armies.values
        .where(
          (final element) =>
      element.nation == nation &&
          element.fightingUnitCount < armyUnitLimit,
    )
        .isEmpty) {
      // no suitable armies in the province so create a new one
      await seedNewArmyWithAUnit(newUnit);
    } else {
      Army armyToAllocateTo;

      if (preferredArmyToAllocateTo != null &&
          preferredArmyToAllocateTo.fightingUnitCount < armyUnitLimit) {
        armyToAllocateTo = preferredArmyToAllocateTo;
      } else {
        final List<Army> sortedArmies = armies.values
            .where((final element) => element.nation == nation)
            .toList()
          ..sort(
                (final a, final b) =>
                a.units
                    .where((final element) => element.isFighting)
                    .length
                    .compareTo(
                  b.units
                      .where((final element) => element.isFighting)
                      .length,
                ),
          );
        armyToAllocateTo = sortedArmies.first;
      }

      armyToAllocateTo.units.add(newUnit);
      newUnit.army = armyToAllocateTo;
    }
    log('${nation.toString()} built ${newUnit.name} in $this');
    pay(type.cost);
    data
      ..population -= popsPerUnit
      ..hasTrainedUnitsThisSeason = true;

    return newUnit;
  }

  /// create a new army in this province and place the given unit into it,
  /// removing this unit from its previous army. assumes the unit already
  /// exists and is in this province.
  Future<void> seedNewArmyWithAUnit(final Unit unit) async {
    final newArmyData = ArmyData(
      name: '${unit.name} of $name',
      unitIds: {unit.id},
      id: ArmyId(armyId: null, nationId: nation.id),
    );
    final newArmy = await newArmyData.toArmy(game: game);
    unit.army?.units.remove(unit);
    unit.army = newArmy;
    newArmy.location = this;
    armies[newArmy.id] = newArmy;
    game.campaignRuntimeData.armies[newArmy.id.armyId] = newArmy;

    /// should be global position to avoid color overlapping
    await game.add(newArmy);

    newArmy.data.mode = (armies.isEmpty && isFortified)
        ? ArmyMode.defender()
        : ArmyMode.fighter();
  }

  void pay(final double goldAmount) {
    assert(goldAmount <= goldAvailable);
    if (goldStored > goldAmount) {
      data.goldStored -= goldAmount;
    } else {
      double shortfall = goldAmount - goldStored;
      data.goldStored = 0.0;
      final List<Army> payingArmies = armies.values
          .where((final element) => element.nation == nation)
          .toList();
      while (shortfall > 0.0) {
        if (payingArmies.first.goldCarried >= shortfall) {
          payingArmies.first.data.goldCarried -= shortfall;
          shortfall = 0.0;
        } else {
          shortfall -= payingArmies.first.goldCarried;
          payingArmies.first.data.goldCarried = 0.0;
          payingArmies.removeAt(0);
        }
      }
    }
  }

  @override
  List<Object?> get props => [id];
}
