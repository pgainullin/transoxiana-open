import 'dart:async';
import 'dart:developer';

import 'package:collection/collection.dart';
import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flame/input.dart';
import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:states_rebuilder/states_rebuilder.dart';
import 'package:tiled/tiled.dart';
import 'package:transoxiana/components/battle/heatmap_overlay.dart';
import 'package:transoxiana/components/battle/hex_tiled_component.dart';
import 'package:transoxiana/components/battle/lances.dart';
import 'package:transoxiana/components/battle/node.dart';
import 'package:transoxiana/components/battle/projectiles.dart';
import 'package:transoxiana/components/battle/unit.dart';
import 'package:transoxiana/components/campaign/campaign.dart';
import 'package:transoxiana/components/campaign/province.dart';
import 'package:transoxiana/components/game/game.dart';
import 'package:transoxiana/components/game/latest_game_loader.dart';
import 'package:transoxiana/components/game_stream/game_stream.dart';
import 'package:transoxiana/components/shared/army.dart';
import 'package:transoxiana/components/shared/components_render_priority.dart';
import 'package:transoxiana/components/shared/events/events.dart';
import 'package:transoxiana/components/shared/fortification.dart';
import 'package:transoxiana/components/shared/nation.dart';
import 'package:transoxiana/components/shared/selector.dart';
import 'package:transoxiana/components/shared/traversable_map.dart';
import 'package:transoxiana/data/campaign_data_source.dart';
import 'package:transoxiana/data/constants.dart';
import 'package:transoxiana/data/temporary_game_data.dart';
import 'package:transoxiana/generated/l10n.dart';
import 'package:transoxiana/services/ai.dart';
import 'package:transoxiana/services/battle_map_services.dart';
import 'package:transoxiana/services/save_service.dart';
import 'package:transoxiana/services/shared_preferences_keys.dart';
import 'package:transoxiana/services/tactical_ai.dart';
import 'package:transoxiana/services/tutorial/tutorial_states.dart';
import 'package:transoxiana/widgets/base/dialogues.dart';
import 'package:transoxiana/widgets/ui_constants.dart';
import 'package:utils/utils.dart';

part 'battle.g.dart';
part 'battle_in_campaign_loader.dart';
part 'battle_standalone_loader.dart';
part 'battle_standalone_loader_runner.dart';

@JsonSerializable(explicitToJson: true)
class BattleData {
  BattleData({
    required this.armies,
    required this.provinceId,
    required this.mapPath,
    final Id? id,
    final Map<String, TacticalInfoData>? tacticalInfo,
    final Set<UnitId>? units,
    final Set<String>? nations,
    this.isFirst = false,
    this.isLast = false,
  })  : id = id ?? uuid.v4(),
        tacticalInfo = tacticalInfo ?? {},
        units = units ?? {},
        nations = nations ?? {};
  static BattleData fromJson(final Map<String, dynamic> json) =>
      _$BattleDataFromJson(json);
  Map<String, dynamic> toJson() => _$BattleDataToJson(this);

  Future<Battle> toBattle({required final TransoxianaGame game}) async {
    final effectiveArmies = (await armies.convert(
      (final item) => game.campaignRuntimeData.getArmyById(item),
    ))
        .toSet();
    final effectiveNations = await nations.convert(
      (final nationId) => game.campaignRuntimeData.getNationById(nationId),
    );
    final effectiveTacticalInfo = await tacticalInfo.convertEntries(
      keyConverter: (final nationId) async =>
          game.campaignRuntimeData.getNationById(nationId),
      valueConverter: (final item) async => item.toTacticalInfo(game: game),
    );
    final effectiveUnits = await units.convert(
      (final unitId) => game.campaignRuntimeData.getUnitById(unitId: unitId),
    );

    return Battle._fromData(
      game: game,
      armies: effectiveArmies,
      province: await game.campaignRuntimeData.getProvinceById(provinceId),
      data: this,
      nations: effectiveNations,
      tacticalInfo: effectiveTacticalInfo,
      units: effectiveUnits,
    );
  }

  final String mapPath;
  // whether the battle is the FIRST in the current season
  bool isFirst;
  // whether the battle is the LAST in the current season
  bool isLast;
  final Set<ArmyId> armies;
  final Id provinceId;
  final Set<NationId> nations;
  final Map<NationId, TacticalInfoData> tacticalInfo;
  final Set<UnitId> units;
  final Id id;
}

class Battle extends Component
    with TraversableMapMixin<Node>
    implements
        Eventful,
        GameRef,
        DataSourceRef<BattleData, Battle>,
        TraversableMap<Node> {
  Battle._fromData({
    required this.game,
    required this.armies,
    required this.province,
    required this.data,
    required this.nations,
    required this.tacticalInfo,
    required this.units,
  }) : super(priority: ComponentsRenderPriority.battle.value) {
    nodeSelector = NodeSelector(game);
    pathSelector = PathSelector(game);
    heatmapOverlay = HeatmapOverlay(game);
    battleOutcomeCompleter = Completer<Nation>();
    hexTiledComponent = HexTiledComponent(
      filename: mapPath,
      renderEnabled: true,
      destTileHeight: UiSizes.tileSize,
      gameSize: game.camera.gameSize,
    );
    _initDataSync();
    hexTiledComponent.renderEnabled = isPlayerBattle;
  }
  @override
  Future<BattleData> toData() async => BattleData(
        armies: await armies.convert((final item) async => item.id),
        mapPath: mapPath,
        provinceId: province.id,
        isFirst: isFirst,
        isLast: isLast,
        nations: await nations.convert((final item) async => item.id),
        tacticalInfo: await tacticalInfo.convertEntries(
          keyConverter: (final nation) async => nation.id,
          valueConverter: (final info) async => info.toData(),
        ),
        units: await units.convert((final item) async => item.id),
      );

  static String getRandomMap() => tacticalMapsPaths.randomElement()!;

  void _initDataSync() {
    if (nations.isEmpty) {
      assert(
        armies.isNotEmpty,
        'If nations is empty, armies should not be empty',
      );
      nations.addAll(armies.map((final e) => e.nation).toSet());
    }

    isAiBattle = armies
        .where(
          (final element) => !element.defeated && element.nation == game.player,
        )
        .isEmpty;

    // ignore: avoid_log
    log('Initialized battle with ${armies.length} armies belonging to ${nations.length} nations');

    // add(hud);
  }

  /// Should be used only within [onLoad] or [refillData]
  Future<void> _initDataComponents() async {
    final newUnits = <Unit>{};
    final Set<Army> emptyArmies = {};
    for (final army in armies) {
      if (army.units.isEmpty) {
        // assert(
        //   army.units.isNotEmpty,
        //   'if units are empty, its army should be killed',
        // );
        army.kill();
        emptyArmies.add(army);
      } else {
        newUnits.addAll(army.units);
      }
    }
    armies.removeAll(emptyArmies);

    await removeComponentUnits();
    units.assignAll(newUnits);
    if (isPlayerBattle) await addComponentUnits();
  }

  @override
  Future<void> onLoad() async {
    if (isPlayerBattle) game.showLoadingOverlay();
    if (tacticalInfo.isEmpty) {
      final infos = await nations.convert(
        (final e) async => MapEntry(
          e,
          await TacticalInfoData(battleId: id, nationId: e.id)
              .toTacticalInfo(game: game),
        ),
      );
      tacticalInfo.addEntries(infos);
    }
    await addAll([hexTiledComponent, pathSelector, nodeSelector]);
    await super.onLoad();
    await _initDataComponents();

    // ignore: avoid_log
    log('${DateTime.now()}: loadBattle() called');
    await initializeTileData();

    if (isPlayerBattle) await game.pause();

    await updatePaths();
    finishMapPathUpdate();

    final fort = province.fort;

    final isFortified = fort != null;

    if (isFortified) {
      assert(
        fort.segments.isNotEmpty,
        'fort is not null but fort.segments are empty',
      );
      // log(this.province.fort.segments.first.node);
      await add(fort);
    }

    if (isPlayerBattle) {
      final eventData = EventData.fromConditionAndConsequenceTypes(
        condition: EventConditionType.battleStart,
        consequence: isFortified
            ? EventConsequenceType.fortifiedBattleStarted
            : EventConsequenceType.nonFortifiedBattleStarted,
        nationId: player!.id,
      );

      Event event = await eventData.toEvent(game: game);
      if (isFortified) {
        event = _battleFortIntroEvent ??= event;
      } else {
        event = _battleIntroEvent ??= event;
      }

      player?.battleEvents.add(event);
      await evaluateEvents();
      initCamera();
      game.hideLoadingOverlay();
    } else {
      endTurn();
    }
  }

  static Event? _battleIntroEvent;
  static Event? _battleFortIntroEvent;

  @override
  Future<void> refillData(final Battle otherType) async {
    assert(otherType == this, 'You trying to update different battle.');
    final newData = await otherType.toData();
    data = newData;
    armies.assignAll(otherType.armies);
    province = otherType.province;
    nations.assignAll(otherType.nations);
    tacticalInfo.assignAll(otherType.tacticalInfo);
    units.assignAll(otherType.units);
    _initDataSync();
    await _initDataComponents();
  }

  Rect get mapBounds => hexTiledComponent.mapBounds;

  @override
  TransoxianaGame game;
  @override
  BattleData data;
  Nation? get player => game.player;
  Id get id => data.id;
  late NodeSelector nodeSelector;
  late PathSelector pathSelector;

  /// debug overlay showing tactical AI node values
  late HeatmapOverlay heatmapOverlay;

  bool isPathFindingUpdateQueued = false;

  // whether the battle is the FIRST in the current season
  bool get isFirst => data.isFirst;
  // whether the battle is the LAST in the current season
  bool get isLast => data.isLast;

  final List<List<Tile>> terrainTiles = [];
  final List<List<Tile>> superstructureTiles = [];
  late List<Node> nodes;
  late HexTiledComponent hexTiledComponent;
  Map<Tile, TileInfo> get tileData => hexTiledComponent.tileData;

  String get mapPath => data.mapPath;
  Province province;

  /// armies participating in this encounter
  final Set<Army> armies;
  final Set<Unit> units;
  Future<void> addComponentUnits() async => addAll(units);
  Future<void> removeComponentUnits() async => removeAll(units);

  /// nations participating in this encounter
  final Set<Nation> nations;
  final Map<Nation, TacticalInfo> tacticalInfo;

  /// time in seconds between each call to update tactical information used
  /// by all tactical AIs
  static const double timeBetweenTacticalUpdates = 0.5;
  double timeSinceTacticalUpdate = 0.0;

  /// returns true if no player armies are involved in the battle
  late bool isAiBattle;
  bool get isPlayerBattle => !isAiBattle;

  final Set<Lance> lances = {};
  final Set<Projectile> shots = {};
  late Completer<Nation?> battleOutcomeCompleter;

  ///
  /// LOADING SEQUENCE:
  ///
  /// Constructor -> update() -> initializeTileData() -> getNodes() ->
  /// loadFortifications() -> updateAdjacentNodes() -> deployArmiesToTiles()
  /// -> updatePathFinding() -> updateNodes().
  ///

  void finishMapPathUpdate() {
    for (final element in tacticalInfo.values) {
      element.computeMaps();
    }
  }

  Future<void> initializeTileData() async {
    // if (game.isHeadless || isAiBattle) component.populateHeadlessTileData();

    terrainTiles.assignAll(hexTiledComponent.map.layers[2].tiles);
    superstructureTiles.assignAll(hexTiledComponent.map.layers[3].tiles);
    loadLocations();
    // log('Nodes generated: ${nodes.length}, ${nodes[1]}');

    if (province.fort != null) await province.fort?.onLoad();

    /// needs access to fortifications so they have to be updated first
    initializePrimitives();

    deployArmiesToTiles();
  }

  /// run only once to initialize nodes
  void loadLocations() {
    nodes = terrainTiles.expand((final element) => element).map((final tile) {
      return Node(
        tile.x,
        tile.y,
        tile,
        superstructureTiles[tile.y][tile.x],
      );
    }).toList();
    setLocations(nodes);
  }

  @override
  Set<Node> getAdjacentLocations(final Node location) =>
      adjacentNodes(location, game);

  /// called by the timer just before the player's turn starts to enable
  /// path finding updates based on what happened in the real time section
  Future<void> turnStartCallback() async {
    log('startAiDriven.turnStartCallback inner start ${DateTime.now()}');
    if (isPathFindingUpdateQueued == true) {
      // ignore: avoid_log
      log('${DateTime.now()} Restarting pathfinding');
      await cleanUpdate();
      isPathFindingUpdateQueued = false;
    }
    //each army's commander rallies their troops
    for (final army in armies) {
      final armyCommander = army.commander;
      if (army.defeated == false &&
          armyCommander != null &&
          armyCommander.unit != null &&
          armyCommander.unit!.isFighting &&
          armyCommander.unit!.location != null) {
        final nodes = targetArea(
          armyCommander.unit!.location!,
          armyCommander.moraleRange,
        );
        // targetArea(army.commander.unit!.location!,
        // army.commander.moraleRange)
        for (final node in nodes) {
          final Unit? unit = node.unit;
          if (unit != null && unit.nation == army.nation) {
            unit.receiveMoraleBoost(
              commanderMoraleBoost * armyCommander.moraleBoostMultiple,
            );
          }
        }
      }
    }
    log('startAiDriven.turnStartCallback inner end ${DateTime.now()}');
  }

  /// ************************************
  ///
  /// RENDERING, UPDATE & INPUT PROCESSING
  ///
  /// ************************************

  @override
  void onGameResize(final Vector2 gameSize) {
    super.onGameResize(gameSize);
    if (!isLoaded || isAiBattle) return;
    hexTiledComponent.verifyWorldBounds(
      gameSize: gameSize,
      onWorldBoundsChange: (final mapBounds) {
        game.camera.worldBounds = mapBounds;
      },
    );
    setInitialCameraPosition();
  }

  /// how much game time passes between updates in a headless / AI battle mode
  static const aiBattleUpdateTime = Duration(seconds: 60);
  static const updateTime = Duration(seconds: 1);
  @override
  void update(final double dt) {
    super.update(dt);
    if (dt == 0.0) {
      log('!Warning - dt $dt');
    }
    if (gameIsUpdating || battleOutcomeCompleter.isCompleted) return;
    // if (isPlayerBattle) gameUpdate(dt);
    gameUpdate(dt == 0.0 ? 1 / 60 : dt);
  }

  bool gameIsUpdating = false;
  void gameUpdate(final double dt) {
    if (battleOutcomeCompleter.isCompleted) return;
    gameIsUpdating = true;

    if (!game.temporaryCampaignData.isPaused) {
      checkDefeatConditions();
      if (!battleOutcomeCompleter.isCompleted) {
        isAiBattle ? loopedEntityUpdates() : updateBattleEntities(dt);
      }
    }
    gameIsUpdating = false;
  }

  /// cycle several battle entity updates within a single game update
  /// call to speed up battle processing
  void loopedEntityUpdates() {
    int leftTimeToUpdateInSeconds = aiBattleUpdateTime.inSeconds;
    log('loopedEntityUpdates - start ${DateTime.now()}');
    final approxUpdateTime = updateTime.inSeconds.toDouble();
    while (leftTimeToUpdateInSeconds > 0) {
      updateBattleEntities(approxUpdateTime);
      leftTimeToUpdateInSeconds -= updateTime.inSeconds;
    }
    log('loopedEntityUpdates - end ${DateTime.now()}');
  }

  /// update all the elements that depend on time elapsed which
  /// can be real time delta or some multiple of it in AI battles
  void updateBattleEntities(final double dt) {
    // for (final army in armies) {
    if (isAiBattle) {
      for (final unit in [...units]) {
        unit.update(dt);
      }
      for (final projectile in [...shots]) {
        projectile.update(dt);
      }
      for (final lance in [...lances]) {
        lance.update(dt);
      }
    }
    // }
    // nodeSelector.update(dt);
    // pathSelector.update(dt);
    heatmapOverlay.update(dt);

    if (!game.temporaryCampaignData.isPaused) {
      timeSinceTacticalUpdate += dt;
      if (timeSinceTacticalUpdate >= timeBetweenTacticalUpdates) {
        tacticalInfo.forEach((final key, final value) => value.computeMaps());
        timeSinceTacticalUpdate = 0.0;
      }
    }
  }

  /// Runs when component has been rendered, loading screen removed
  /// and player is about to get control. Moves the camera to player units
  ///
  /// Sets camera params accordingly to battle needs.
  void initCamera() {
    game.camera.worldBounds = mapBounds;
    game.mapCamera
      ..setBattleZoomLimits()
      ..setMaxZoom();
  }

  bool isInitialCameraPositionSet = false;
  void setInitialCameraPosition() {
    if (isInitialCameraPositionSet) return;
    game.mapCamera.toPlayerUnits();
    isInitialCameraPositionSet = true;
  }

  void onTap(final TapDownInfo info) {
    if (game.activeBattle == null) {
      removeFromParent();
      return;
    }
    final gamePointerPosition = info.eventPosition.game;
    if (game.isHeadless || isAiBattle) return;

    bool isHandled = false;
    final ReactiveModel<TemporaryGameData> gameData =
        game.temporaryCampaignDataService;

    //TILES
    if (isHandled == false && gameData.state.inCommand == true) {
      //ONLY ALLOW UNIT SELECTION IF IN COMMAND
      for (final node in nodes) {
        // The old code
        // final Offset _centerPoint = tileData[node.terrainTile]!.center;
        // final double _distance =
        //     (_centerPoint - details.globalPosition - game.camera.)
        //         .distance;
        // if (_distance <= tile.collisionDiameter / 2.0) {
        final tileInfo = tileData[node.terrainTile];
        if (tileInfo == null) continue;
        final isClickInsideTile =
            tileInfo.dstRect?.contains(gamePointerPosition.toOffset());
        if (isClickInsideTile != true) continue;

        selectNode(node);

        //UNITS
        if (node.unit != null &&
            (gameData.state.selectedUnit == null ||
                gameData.state.selectedUnit!.nation != game.player) &&
//                  s.tileUnitData[tile] != s.selectedUnit &&
//                     this.tileData[tile].unit.nation == this.game.player &&
            node.unit!.health > 0.0) {
          // SELECT ANY UNIT, WHEN NO UNIT SELECTED - SELECT
          selectUnit(node.unit);
        } else if (node.unit != null && node.unit == gameData.state.selectedUnit
            //&& this.tileData[tile].unit.nation == this.game.player
            ) {
          // SELECT UNIT ALREADY SELECTED - DESELECT

          selectUnit(null);
          selectNode(null);
        } else if (gameData.state.selectedUnit != null &&
            gameData.state.selectedUnit!.nation == game.player &&
            gameData.state.selectedUnit!.isFighting &&
            node != gameData.state.selectedUnit!.location &&
            node.isTraversable) {
          // SELECT A VALID DIFFERENT TILE WHILE A PLAYER UNIT
          // IS SELECTED -> ORDER
          orderMove(node);
        }

        isHandled = true;
      }
    }
  }

  ///
  ///
  /// ORDERS
  ///
  ///

  /// orders currently selected unit to move to a given node.
  /// Assumes the game is not headless
  Future<void> orderMove(final Node node) async {
    final ReactiveModel<TemporaryGameData> gameData =
        game.temporaryCampaignDataService;
    final Unit selectedUnit = gameData.state.selectedUnit!;
    assert(
      selectedUnit.nation == game.player,
      'Do not use orderMove for non-player units',
    );
    if (selectedUnit.location == null) return;

    // default value which will be overridden by the dialogue
    // if current orders present
    ConfirmAction confirmation = ConfirmAction.accept;

    if (selectedUnit.orderedDestination != null) {
      confirmation = await asyncConfirmDialog(
            getScaffoldKeyContext(),
            S.current.changeDestinationDialogueTitle(selectedUnit.name),
            S.current.changeDestinationDialogueContent,
          ) ??
          ConfirmAction.accept;
    }

    if (confirmation == ConfirmAction.accept) {
      if (pathToNodeWithUnitAvoidance(this, selectedUnit.location!, node) ==
          null) return;

      selectedUnit.orderToNode(node);
      // if (!this.game.isHeadless)
      pathSelector.showPath(
        ([selectedUnit.location!] +
                pathToNodeWithUnitAvoidance(
                  this,
                  selectedUnit.location!,
                  node,
                )!)
            .toSet(),
        color: selectedUnit.nation.color,
      );
    }
    await gameData.setState((final s) {
      s.selectedUnit = null;
      return null;
    });
  }

  /// Select a tile/node
  void selectNode(final Node? node) {
    final ReactiveModel<TemporaryGameData> gameData =
        game.temporaryCampaignDataService;

    if (node != null) {
      //debug
      // showTilePath(optimisedTargetArea(game, node, 3).
      // map((e) => e.terrainTile).toSet(), game);

      // this.tileData[node.terrainTile].selected = true;
      gameData.setState((final s) {
        s.selectedNode = node;
        if (s.selectedUnit != null && s.selectedUnit!.nation != game.player) {
          s.selectedUnit = null;
        }
        return null;
      });

      nodeSelector.selectNode(node);
    } else {
      gameData.setState((final s) {
        s.selectedNode = null;
        return null;
      });
      nodeSelector.deselect();
    }
  }

  /// Select a unit
  Future<void> selectUnit(final Unit? selectedUnit) async {
    //note that unit can be null in a deselect scenario
    game.temporaryCampaignData.selectedUnit = selectedUnit;
    game.temporaryCampaignDataService.notify();

    await processUnitSelectionEvents(selectedUnit);

    //and highlights its ordered path
    if (selectedUnit != null &&
        selectedUnit.orderedDestination != null &&
        selectedUnit.nation == game.player) {
      if (selectedUnit.location == null) return;
      final List<Node>? path = pathToNodeWithUnitAvoidance(
        game.activeBattle!,
        selectedUnit.location!,
        selectedUnit.orderedDestination!,
      );
      if (path != null) {
        pathSelector.showPath(
          ([selectedUnit.location!] + path).toSet(),
          color: selectedUnit.nation.color,
        );
      }
    }

    // heatmapOverlay.showUnitHeatmap(unit);
  }

  /// currently creates a new event triggered on selection of the player's unit.
  /// This is used in tutorial
  // TODO: generalise to just check any events that require a unit
  // selection parameter and move the event creation to the battle
  // initialization sequence
  bool unitEventCreated = false;
  Future<void> processUnitSelectionEvents(final Unit? unit) async {
    if (!unitEventCreated && unit != null && unit.nation == player) {
      final eventData = EventData.fromConditionAndConsequenceTypes(
        condition: EventConditionType.battleSelectPlayerUnit,
        consequence: EventConsequenceType.battlePlayerUnitSelected,
        nationId: player!.id,
        trigger: EventTriggerType.selection,
      );
      final event = await eventData.toEvent(game: game);

      /// add event for history
      await EventResolver.evaluateEvent(
        event: event,
        events: player!.battleEvents,
        trigger: EventTriggerType.selection,
      );
      unitEventCreated = true;
    }
  }

  /// end player turn
  void endTurn() {
    if (battleOutcomeCompleter.isCompleted) return;
    game.streamRunner.addEvent(BattleEndTurn());
  }

  Future<void> prepareToEndTurn() async {
    final gameData = game.temporaryCampaignDataService;

    selectNode(null);

    // ignore: avoid_log
    log(
      'Ending battle turn at ${game.campaignRuntimeData.gameTime} in '
      '${gameData.state.battleProvince?.name}',
    );

    //process AI ordering sequences
    game.campaignRuntimeData.ais.values
        .where((final e) => nations.contains(e.nation))
        .forEach((final ai) => ai.giveBattleOrders(this));

    await evaluateEvents();
  }

  @override
  Future<void> evaluateEvents() async => EventResolver.evaluate(
        aiNations: nations,
        player: player!,
        useBattleEvents: true,
      );

  /// confirm action and then restart the game generating new units and nations
  Future<void> confirmSurrender() async {
    final ConfirmAction confirmAction = await asyncConfirmDialog(
          getScaffoldKeyContext(),
          S.current.confirmSurrenderDialogueTitle,
          S.current.confirmSurrenderDialogueContent,
        ) ??
        ConfirmAction.cancel;
    if (confirmAction == ConfirmAction.accept) await surrender();
  }

  bool fastForwardEnabled = false;

  /// make the battle end turns automatically to proceed in quasi-real time
  /// with the tactical ai making the decisions
  Future<void> toggleFastForward() async {
    fastForwardEnabled = !fastForwardEnabled;
    if (fastForwardEnabled && game.temporaryCampaignData.isPaused) {
      endTurn();
    }
  }

  void setStanceForAllPlayerUnits(final Stance stance) {
    for (final unit
        in units.where((final element) => element.nation == player)) {
      unit.data.stance = stance;
    }
  }

  void setAllPlayerUnitsToDefend() {
    setStanceForAllPlayerUnits(Stance.defend);
  }

  void setAllPlayerUnitsToAttack() {
    setStanceForAllPlayerUnits(Stance.attack);
  }

  void cancelAllPlayerUnitOrders() {
    for (final unit
        in units.where((final element) => element.nation == player)) {
      unit.clearOrders();
    }
  }

  /// an army's commander unit is killed in battle triggering morale
  /// effects around it
  void commanderKill(final Unit commanderUnit) {
    assert(
      commanderUnit.location != null,
      'commander already removed on call to commanderKill',
    );

    final Army army = armies
        .firstWhere((final element) => element.units.contains(commanderUnit));
    targetArea(commanderUnit.location!, army.commander!.moraleRange)
        .forEach((final node) {
      final Unit? unit = node.unit;
      if (unit != null && unit.nation == army.nation) {
        unit.receiveMoraleDamage(
          commanderDeathMoraleHit * army.commander!.moraleBoostMultiple,
        );
      }
    });

    army.appointNewCommander();
  }

  ///
  ///
  /// RESOLVING THE BATTLE: check victory conditions, surrender etc
  ///
  ///

  /// returns the winning nation upon completion of the future.
  Future<Nation?> battleOutcome() {
    battleOutcomeCompleter.future.whenComplete(() {
      singleTrackSfxController.forceStopAll();
      clearProgress();
      clearBattleEvents();
    });

    return battleOutcomeCompleter.future;
  }

  /// clear unit melee and shot progress states at the end of the battle
  /// reset unit Stance
  /// close fort gates
  void clearProgress() {
    for (final Army element in armies) {
      for (final Unit unit in element.units) {
        // unit.isCommandUnit = false;
        unit.data
          ..progress = 0.0
          ..shotProgress = 0.0
          ..stance = Stance.attack;
        unit
          ..location = null
          ..orderedDestination = null
          ..nextNode = null;
      }

      if (element.fightingUnits.isEmpty) continue;
      element.commander?.unit = element.fightingUnits.first;
    }

    if (province.fort != null && province.fort!.segments.isNotEmpty) {
      for (final element in province.fort!.segments) {
        element.data.open = false;
      }
    }
  }

  /// Kill all the player's armies in this battle but save the commanders
  Future<void> surrender() async {
    for (final army
        in armies.where((final element) => element.nation == game.player)) {
      final commander = army.commander;
      if (commander != null) {
        game.player!.unemployedCommanders.add(commander);
      }
      army.kill();
    }

    battleOutcomeCompleter.complete();
  }

  /// check if no fighting hostile armies remain at which point
  /// the battle should end
  void checkDefeatConditions() {
    //add all nations in the battle first
    final losers = <Nation>{}..addAll(nations);

    //then remove ones that have fighting armies
    for (final army in armies) {
      if (!army.defeated && army.isFighting) {
        losers.remove(army.nation);
      }
      //meanwhile kill off armies that have no fighting units
      if (!army.isFighting) {
        army.kill();
      }
    }

    final Set<Nation> nonLosers = nations.difference(losers);

    // how many nations have not been defeated in this battle
    // yet have other hostile nations in it
    int hostileRelationsCount = 0;

    for (final a in nonLosers) {
      for (final b in nonLosers) {
        if (a.isHostileTo(b)) hostileRelationsCount += 1;
      }
    }

    if (hostileRelationsCount == 0) {
      //no two hostile nations remain undefeated - end of battle
      final winner = nations.firstWhereOrNull(
        (final nation) => !losers.contains(nation),
      );

      // if (!battleOutcomeCompleter.isCompleted)
      battleOutcomeCompleter.complete(winner);
    }
  }

  ///
  ///
  /// DEPLOYMENT HELPERS
  ///
  ///

  void deployArmiesToTiles() {
    final int totalNodeCount = nodes.length;
    final int unitTileCount =
        totalNodeCount ~/ 3; // this will be off (+) by the number of nations

    final List<Segment> freeSegments = [];
    if (province.fort != null && province.fort!.segments.isNotEmpty) {
      freeSegments.addAll(List.from(province.fort!.segments));
    }

    for (final army in armies) {
      final Set<Unit> liveUnits =
          army.units.where((final element) => element.isFighting).toSet();

      if (army.nation == province.nation &&
          army.siegeMode == true &&
          province.fort != null &&
          province.fort!.segments.isNotEmpty) {
        //Deploy the fort defender to the fort first
        List<Unit> sortedUnitList = liveUnits.toList()
          ..sort((final a, final b) => a.speed.compareTo(b.speed));
        sortedUnitList = sortedUnitList.reversed.toList();

        int deployedUnitCount = 0;

        for (int i = deployedUnitCount;
            i <= unitTileCount ~/ armies.length;
            i++) {
          if (i < sortedUnitList.length) {
            final Unit unit = sortedUnitList[i];
            Segment randomSegment;
            if (freeSegments.isNotEmpty) {
              //deploy to the walls while free segments are available
              randomSegment =
                  freeSegments[game.rand.nextInt(freeSegments.length)];
              final Node location = randomSegment.node;
              deployUnit(unit, location);
              deployedUnitCount += 1;
              freeSegments.remove(randomSegment);
            } else {
              //otherwise deploy to closest free tile to the last segment
              final Node? location = closestEmptyNode(
                province.fort!.segments
                    .toList()[game.rand.nextInt(province.fort!.segments.length)]
                    .node,
                game,
              );

              if (location != null && liveUnits.length > i) {
                deployUnit(sortedUnitList[i - deployedUnitCount], location);
              }
            }
          }
        }
      } else {
        List<Node> deploymentNodes = List.from(nodes);
        if (army.nation == province.nation ||
            army.nation.diplomaticRelationships[province.nation] !=
                DiplomaticStatus.war) {
          if (province.defenceDeploymentPoints.isNotEmpty) {
            deploymentNodes = deploymentNodes
                .where(
                  (final node) =>
                      province.defenceDeploymentPoints.firstWhereOrNull(
                        (final deploymentPoint) =>
                            node.x == deploymentPoint[0] &&
                            node.y == deploymentPoint[1],
                      ) !=
                      null,
                )
                .toList();
          }
        } else {
          if (province.attackDeploymentPoints.isNotEmpty) {
            deploymentNodes = deploymentNodes
                .where(
                  (final node) =>
                      province.attackDeploymentPoints.firstWhereOrNull(
                        (final deploymentPoint) =>
                            node.x == deploymentPoint[0] &&
                            node.y == deploymentPoint[1],
                      ) !=
                      null,
                )
                .toList();
          }
        }

        final Node startNode =
            deploymentNodes[game.rand.nextInt(deploymentNodes.length)];
        final liveUnitsList = liveUnits.toList();
        for (int i = 0; i <= unitTileCount ~/ armies.length; i++) {
          final Node? location = closestEmptyNode(startNode, game);
          // log('${_location.x}:${_location.y} is empty for unit no. $i');

          if (location != null && liveUnits.length > i) {
            // log('unit no. $i placed to ${tileToNode(game, _location)}');

            deployUnit(liveUnitsList[i], location);
            // liveUnits.elementAt(i).location = tileToNode(game, _location);
            // this.tileData[_location].unit = liveUnits.elementAt(i);

            // log('This unit location set to
            // ${army.units.elementAt(i).location}');
          } //else map is full

        }
      }
    }
  }

  /// deploy given unit to given node
  void deployUnit(final Unit unit, final Node node) {
    unit.location = node;
    node.unit = unit;
  }

  void clearBattleEvents() {
    nations.map((final e) => e.battleEvents.clear());
    player!.battleEvents.clear();
  }
}
