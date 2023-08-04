part of game;

class _DebugSavesList extends StatefulWidget {
  const _DebugSavesList({
    required this.game,
    final Key? key,
  }) : super(key: key);
  final TransoxianaGame game;

  @override
  State<_DebugSavesList> createState() => _DebugSavesListState();
}

class _DebugSavesListState extends State<_DebugSavesList> {
  final savesMap = <String, dynamic>{};

  @override
  Widget build(final BuildContext context) {
    final loader = CampaignLoader(game: widget.game);
    return FutureBuilder<Map<Id, dynamic>>(
      future: () async {
        final saves = await loader.getSavesMap();
        savesMap.addAll(saves);
        return savesMap;
      }(),
      builder: (final _, final snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const LinearProgressIndicator();
        }
        final savesIdsList = savesMap.keys.toList();
        return ListView.builder(
          shrinkWrap: true,
          itemBuilder: (final _, final i) {
            final saveId = savesIdsList[i];
            return ListTile(
              title: Text(saveId),
              trailing: IconButton(
                onPressed: () async {
                  await loader.removeMapIdFromStorage(
                    id: saveId,
                    map: savesMap,
                  );
                  setState(() {});
                },
                icon: const Icon(Icons.delete),
              ),
            );
          },
          itemCount: savesIdsList.length,
        );
      },
    );
  }
}
