part of 'campaign.dart';

class Campaign extends Component
    with TraversableMapMixin<Province>
    implements Eventful, GameRef, TraversableMap<Province> {
  Campaign({
    required this.game,
    required this.temporaryDataService,
    required this.runtimeDataService,
  }) : super(
          priority: ComponentsRenderPriority.campaign.value,
        );

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    game.mapCamera
      ..setCampaignSmoothCameraSpeed()
      ..setCampaignZoomLimits();

    game.showLoadingOverlay();

    setLocations(provinces);
    await addAll(provinces);

    initializePrimitives();

    await updatePaths();
    await onMapLoaded();
    // postLoadScaling();

    await evaluateEvents();

    game.hideLoadingOverlay();
  }

  Future<void> onMapLoaded() async {
    await addAll(game.campaignRuntimeData.armies.values);
    for (final army in game.campaignRuntimeData.armies.values) {
      army.setProvincePath();
    }
  }

  final ReactiveModel<CampaignRuntimeData> runtimeDataService;
  CampaignRuntimeData get runtimeData => runtimeDataService.state;
  final ReactiveModel<TemporaryGameData> temporaryDataService;
  TemporaryGameData get temporaryData => temporaryDataService.state;
  List<Province> get provinces => runtimeData.provinces.values.toList();

  @override
  TransoxianaGame game;

  // final List<Vertex<Province>> vertices = [];
  // DirectedGraph<Province> graph;
  // final Map<String, dynamic> campaignJSON = {};
  /// Enable for advanced fog of war
  // final fogOfWarMap = FogOfWarMap();
  // TODO: move the comparison with game player to EventCondition and add a parameter to the event
  @override
  Future<void> evaluateEvents() async {
    // Evaluate events to run consequences
    final aiNations = game.campaignRuntimeData.nations.values.where(
      (final element) => element != game.player,
    );
    await EventResolver.evaluate(
      aiNations: aiNations,
      player: game.player!,
      // trigger: EventTriggerType.startTurn,
    );
  }

  @override
  Set<Province> getAdjacentLocations(final Province location) =>
      location.edges.map((final id) => runtimeData.provinces[id]!).toSet();

  @override
  void render(final Canvas canvas) {
    super.render(canvas);
    if (runtimeData.isBattleStarted &&
        runtimeData.activeBattle?.isPlayerBattle == true) return;
    // TODO(arenukvern): fix headless mode
    final backgroundImage = runtimeData.backgroundImage;
    if (backgroundImage == null) return;

    /// Will render only once at game start
    /// It can be provinces, or something that will not change
    /// at all during the whole game
    // final persistentSingleHexBuffer = <RenderCallback>[];

    /// Single province buffer will be rendered first.
    /// Contains only renderings that fit inside a single province shape
    final singleProvinceBuffer = <RenderCallback>[];

    /// Overlaying buffer will rendered second
    /// This could be weather, pointers, or something
    /// that can move - i.e. armies etc
    final overlayingBuffer = <RenderCallback>[];
    final imageRect = Rect.fromLTWH(
      0.0,
      0.0,
      game.campaignMaxWidth,
      game.campaignMaxHeight,
    );
    // c.drawImage(_image, Offset.zero, Paint());
    paintImage(
      canvas: canvas,
      rect: imageRect,
      image: backgroundImage,
    );

    /// Provinces rendering
    /// Visible provinces will be needed only for
    /// advanced fog of war
    // final Set<Province> visibleProvinces = {};
    clearAndSetVisibleNationsInProvinces();
    for (final province in provinces) {
      if (province.isNotVisibleToPlayer) continue;

      /// in case if there is no fog, then render other

      // render path selectors first so that they are
      // always under their respective armies
      // TODO(arenukvern): refactor to global component
      int newPriority = ComponentsRenderPriority.campaignArmy.value;
      for (final army in province.armiesListSortedByPosition) {
        //hack priority so armies are rendered based on their y coordinate
        // (lower armies render later)
        //Note this involves hacking priority for ALL lower
        // ComponentsRenderPriority campaign items - see constructors
        // for Weather and FogOfWar
        army.priority = newPriority;
        overlayingBuffer.add(army.pathSelector.render);
        newPriority += 1;
        if (newPriority > ComponentsRenderPriority.armyMaxLimit) {
          throw ArgumentError.value(
            'increase ComponentsRenderPriority.armyMaxLimit. '
            'Failed with priority $newPriority',
          );
        }
      }
    }

    /// ********* Buffers rendering **********

    singleProvinceBuffer.addAll(overlayingBuffer);

    renderRenderBuffer(
      buffer: singleProvinceBuffer,
      canvas: canvas,
    );
  }

  @override
  void update(final double dt) {
    super.update(dt);
    if (isHeadless) return;

    for (final army in game.campaignRuntimeData.armies.values) {
      army.update(dt);
    }
  }
}
