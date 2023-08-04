part of game;

class _BattleDebugView extends StatelessWidget {
  const _BattleDebugView({
    required this.game,
    final Key? key,
  }) : super(key: key);
  final TransoxianaGame game;
  @override
  Widget build(final BuildContext context) {
    return DefaultTabController(
      length: 1,
      child: NestedScrollView(
        headerSliverBuilder: (final context, final innerBoxIsScrolled) {
          return const [
            SliverToBoxAdapter(
              child: TabBar(
                tabs: [
                  Tab(child: Text('Units')),
                ],
              ),
            )
          ];
        },
        body: TabBarView(
          children: [
            _BattleUnitsDebugView(gameRef: game),
          ],
        ),
      ),
    );
  }
}
