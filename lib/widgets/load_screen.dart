import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';
import 'package:transoxiana/components/campaign/campaign.dart';
import 'package:transoxiana/components/game/game.dart';
import 'package:transoxiana/data/campaign_data_source.dart';

Future<void> showSavesLoadDialog({
  required final BuildContext context,
  required final TransoxianaGame game,
}) async {
  return showDialog(
    context: context,
    builder: (final _) {
      final theme = Theme.of(context);
      return SimpleDialog(
        backgroundColor: theme.cardColor,
        contentPadding: const EdgeInsets.only(bottom: 16),
        clipBehavior: Clip.hardEdge,
        children: [
          AppBar(
            backgroundColor: theme.cardColor,
            titleTextStyle: theme.textTheme.bodyText2,
            leading: BackButton(
              color: theme.textTheme.bodyText2?.color,
            ),
            title: const Text('Auto Saves'),
          ),
          SizedBox(
            height: 500,
            width: 500,
            child: LoadScreen(
              game: game,
            ),
          ),
        ],
      );
    },
  );
}

class LoadScreen extends ReactiveStatelessWidget {
  const LoadScreen({
    required this.game,
    final Key? key,
  }) : super(key: key);
  final TransoxianaGame game;
  @override
  Widget build(final BuildContext context) {
    final campaignSaves = game.campaignSortedSavesBuffer.all;
    // TODO(arenukvern): enable when will be needed
    //  final battleSaves = game.battleSavesFromNewToLast;

    Widget getSavesList(final List<CampaignSaveData> saves) {
      final noSaves = saves.isEmpty;
      if (noSaves) {
        return const Padding(
          padding: EdgeInsets.all(16.0),
          child: Center(
            // TODO(arenukvern): replace with S.current
            child: Text('No saves'),
          ),
        );
      }
      return ListView.builder(
        shrinkWrap: true,
        itemBuilder: (final _, final i) {
          final saveData = saves[i];
          final campaignLoader = CampaignLoader(game: game);
          return ListTile(
            title: Text('${saveData.player?.name} ${saveData.currentDate}'),
            subtitle: Text(saveData.gameSaveDate.toIso8601String()),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextButton(
                  // TODO(arenukvern): add translation
                  child: const Text('Load'),
                  onPressed: () async {
                    final navigator = Navigator.of(context);
                    if (saveData.id == game.campaignRuntimeData.id) {
                      game.hideMainMenu();
                    } else {
                      await campaignLoader.continueFrom(
                        source: saveData,
                        context: context,
                      );
                    }
                    navigator.pop();
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => campaignLoader.remove(source: saveData),
                ),
              ],
            ),
          );
        },
        itemCount: saves.length,
      );
    }

    return Theme(
      data: Theme.of(context).copyWith(
        tabBarTheme: TabBarTheme.of(context)
            .copyWith(labelColor: Theme.of(context).textTheme.bodyText2?.color),
      ),
      child: DefaultTabController(
        length: 1,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const TabBar(
              tabs: [
                // TODO(arenukvern): replace with S.current
                Tab(text: 'Campaign'),
                // TODO(arenukvern): enable when will be needed
                // Tab(text: 'Battle'),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  getSavesList(campaignSaves),
                  // TODO(arenukvern): enable when will be needed
                  // getSavesList(battleSaves),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
