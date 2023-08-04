part of game;

class _CampaignNationsView extends ReactiveStatelessWidget {
  const _CampaignNationsView({
    required this.gameRef,
    final Key? key,
  }) : super(key: key);
  final TransoxianaGame gameRef;

  @override
  Widget build(final BuildContext context) {
    final runtimeData = gameRef.campaignRuntimeData;
    final nations = runtimeData.nations.values.toList();
    if (nations.isEmpty) return Container();
    return ListView.builder(
      shrinkWrap: true,
      primary: false,
      itemBuilder: (final context, final index) {
        final nation = nations[index];
        return ListTile(
          key: Key(nation.id),
          title: Text(
            '${nation.name} ${nation.getArmies().map((final e) => e.id.armyId)}',
          ),
          trailing: TextButton(
            child: const Text('diplomacy'),
            onPressed: () => showDialog(
              context: context,
              builder: (final _) => SimpleDialog(
                contentPadding: const EdgeInsets.only(bottom: 16),
                clipBehavior: Clip.hardEdge,
                children: [
                  AppBar(
                    leading: const BackButton(),
                    title: Text(nation.name),
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width,
                    child: _NationRelationsView(
                      gameRef: gameRef,
                      nation: nation,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
      itemCount: runtimeData.nations.length,
    );
  }
}

class _NationRelationsView extends ReactiveStatelessWidget {
  const _NationRelationsView({
    required this.gameRef,
    required this.nation,
    final Key? key,
  }) : super(key: key);
  final TransoxianaGame gameRef;
  final Nation nation;
  @override
  Widget build(final BuildContext context) {
    final relationsList = nation.diplomaticRelationships.entries.toList();
    final statusItems = DiplomaticStatus.values
        .map(
          (final status) => DropdownMenuItem(
            value: status,
            key: Key(status.toString()),
            child: Text('$status'),
          ),
        )
        .toList();
    return ListView.builder(
      shrinkWrap: true,
      itemBuilder: (final context, final index) {
        final nationEntry = relationsList[index];
        final otherNation = nationEntry.key;
        return ListTile(
          key: Key(otherNation.id),
          leading: Text(otherNation.name),
          trailing: DropdownButton<DiplomaticStatus>(
            items: statusItems,
            onChanged: (final newStatus) {
              if (newStatus == null) return;
              nation.diplomaticRelationships[otherNation] = newStatus;
              otherNation.diplomaticRelationships[nation] = newStatus;
            },
            value: nationEntry.value,
          ),
        );
      },
      itemCount: nation.diplomaticRelationships.length,
    );
  }
}
