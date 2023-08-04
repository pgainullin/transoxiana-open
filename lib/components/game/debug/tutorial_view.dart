part of game;

class _TutorialDebugView extends ReactiveStatelessWidget {
  const _TutorialDebugView({
    required this.game,
    final Key? key,
  }) : super(key: key);
  final TransoxianaGame game;
  @override
  Widget build(final BuildContext context) {
    return ListView(
      children: [
        ListTile(
          title: const Text('Is overlay visible'),
          trailing: Switch(
            value: game.tutorialOverlayStateService.state.isAllVisible,
            onChanged: (final isAllVisible) {
              game.tutorialOverlayStateService
                ..state.isAllVisible = isAllVisible
                ..notify();
            },
          ),
        ),
        TextButton(
          onPressed: () async {
            if (game.campaign == null) return;
            game.tutorialHistory.statePointers[TutorialModes.campaignIntro] = 0;

            TutorialState.switchMode(
              mode: TutorialModes.campaignIntro,
              game: game,
              enableOverlay: true,
            );
          },
          child: const Text(
            'Turn on Campaign intro tutorial',
          ),
        ),
        TextButton(
          onPressed: () async {
            if (game.activeBattle == null) return;
            game.tutorialHistory.statePointers[TutorialModes.battleIntro] = 0;

            TutorialState.switchMode(
              mode: TutorialModes.battleIntro,
              game: game,
              enableOverlay: true,
            );
          },
          child: const Text(
            'Turn on Battle intro tutorial',
          ),
        ),
      ],
    );
  }
}
