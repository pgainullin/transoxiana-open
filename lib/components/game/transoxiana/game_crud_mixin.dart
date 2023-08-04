part of game;

mixin _GameCrudMixin on _TransoxianaGameLateState {
  @Deprecated('use CampaignLoader.save')
  Future<void> saveGame() async {
    final ConfirmAction confirm = await asyncConfirmDialog(
          getScaffoldKeyContext(),
          S.current.saveGameDialogueTitle,
          S.current.saveGameDialogueContent,
        ) ??
        ConfirmAction.cancel;
    if (confirm == ConfirmAction.accept) {
      // TODO(arenukvern): fixme
      // await savableCampaignData.saveToFile();
    }
  }

  @Deprecated('use CampaignLoader.load')
  Future<void> loadGame() async {
    final ConfirmAction confirm = await asyncConfirmDialog(
          getScaffoldKeyContext(),
          S.current.loadGameDialogueTitle,
          S.current.loadGameDialogueContent,
        ) ??
        ConfirmAction
            .cancel; //if initialized need confirmation to reset current game, otherwise no game started
    if (confirm == ConfirmAction.accept) {
      // TODO(arenukvern): fixme
      // await savableCampaignData.loadFromFile();
    }
  }
}
