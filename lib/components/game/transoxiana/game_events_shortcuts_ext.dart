part of game;

extension GameEventsShortcutsExtension on TransoxianaGame {
  Future<void> triggerVictory(final Nation winner) async {
    log('Campaign won by ${winner.name}');

    if (isHeadless) {
      await apiGetRequest(
        'report_outcome',
        Map.fromEntries([
          MapEntry(
            'outcome',
            campaignRuntimeData.nations.values
                .toList()
                .indexOf(winner)
                .toString(),
          )
        ]),
      );
      exit(campaignRuntimeData.nations.values.toList().indexOf(winner));

      // restart();
    } else {
      await asyncInfoDialog(
        getScaffoldKeyContext(),
        winner == player
            ? S.current.victoryDialogueTitle
            : S.current.defeatDialogueTitle,
        S.current.campaignVictoryDialogueContent(winner.name),
      );

      /// Preload template data
      final template = temporaryCampaignData.templateDataSource;
      if (template != null) await loadRuntimeData(dataSource: template);
      showMainMenu();
    }
  }
}
