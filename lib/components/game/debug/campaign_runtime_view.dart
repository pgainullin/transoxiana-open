part of game;

class _CampaignDebugRuntimeDataView extends StatelessWidget {
  const _CampaignDebugRuntimeDataView({required this.game, final Key? key})
      : super(key: key);
  final TransoxianaGame game;
  @override
  Widget build(final BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: NestedScrollView(
        headerSliverBuilder: (final context, final innerBoxIsScrolled) {
          return const [
            SliverToBoxAdapter(
              child: TabBar(
                tabs: [
                  Tab(child: Text('Parameters')),
                  Tab(child: Text('Unit Types')),
                  Tab(child: Text('Nations')),
                  Tab(child: Text('Provinces')),
                ],
              ),
            )
          ];
        },
        body: TabBarView(
          children: [
            _CampaignParameters(gameRef: game),
            _CampaignUnitTypes(gameRef: game),
            _CampaignNationsView(gameRef: game),
            _CampaignProvincesView(gameRef: game),
          ],
        ),
      ),
    );
  }
}

class _CampaignParameters extends ReactiveStatelessWidget {
  const _CampaignParameters({required this.gameRef, final Key? key})
      : super(key: key);
  final TransoxianaGame gameRef;

  @override
  Widget build(final BuildContext context) {
    final runtimeData = gameRef.campaignRuntimeData;
    final text = '''
      name: ${runtimeData.campaignName} \n
      narrative objectives: ${runtimeData.narrative?.objectives} \n
      currentDate: ${runtimeData.currentDate} \n
      startDate: ${runtimeData.startDate} \n
      gameTime: ${runtimeData.gameTime} \n
      backgroundImagePath: ${runtimeData.backgroundImagePath} \n
      player: ${runtimeData.player?.data.toJson()} \n
      player using ai: ${runtimeData.player?.ai != null}
      ais count: ${runtimeData.ais.length} \n
    ''';
    return SingleChildScrollView(
      primary: false,
      child: Text(text),
    );
  }
}
