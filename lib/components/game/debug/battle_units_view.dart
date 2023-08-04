part of game;

class _BattleUnitsDebugView extends ReactiveStatelessWidget {
  const _BattleUnitsDebugView({
    required this.gameRef,
    final Key? key,
  }) : super(key: key);
  final TransoxianaGame gameRef;

  @override
  Widget build(final BuildContext context) {
    final battle = gameRef.activeBattle;

    if (battle == null) return const SizedBox();
    final units = battle.units.toList();
    if (units.isEmpty) return Container();

    return ListView.builder(
      shrinkWrap: true,
      primary: false,
      itemBuilder: (final context, final index) {
        final unit = units[index];
        return ListTile(
          key: ValueKey(unit.id),
          title: Text(
            '${unit.name} '
            'Nation: ${unit.nation.name} '
            '${unit.locationInfo?.dstRect}',
          ),
          trailing: IconButton(
            onPressed: () {
              gameRef.mapCamera.toUnit(unit);
            },
            icon: const Icon(
              Icons.location_on_sharp,
              color: Colors.white,
            ),
          ),
        );
      },
      itemCount: units.length,
    );
  }
}
