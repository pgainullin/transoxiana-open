part of game;

class _CampaignUnitTypes extends ReactiveStatelessWidget {
  const _CampaignUnitTypes({required this.gameRef, final Key? key})
      : super(key: key);
  final TransoxianaGame gameRef;

  @override
  Widget build(final BuildContext context) {
    final runtimeData = gameRef.campaignRuntimeData;
    final unitTypes = runtimeData.unitTypes.values.toList();
    if (unitTypes.isEmpty) return Container();
    return ListView.builder(
      primary: false,
      shrinkWrap: true,
      itemBuilder: (final context, final index) => ListTile(
        title: Text('${unitTypes[index].toJson()}'),
      ),
      itemCount: runtimeData.unitTypes.length,
    );
  }
}
