part of game;

class _DebugControlsView extends ReactiveStatelessWidget {
  const _DebugControlsView({
    required this.game,
    final Key? key,
  }) : super(key: key);
  final TransoxianaGame game;
  @override
  Widget build(final BuildContext context) {
    return ListView(
      shrinkWrap: true,
      primary: false,
      children: [
        const Text('Music'),
        Row(
          children: [
            TextButton(
              onPressed: game.music.bgm?.stop,
              child: const Text('Stop'),
            ),
            TextButton(
              onPressed: game.music.playMainTheme,
              child: const Text('Main Theme'),
            ),
            TextButton(
              onPressed: game.music.playBattleTheme,
              child: const Text('Battle Theme'),
            ),
          ],
        ),
        const Text('Battle'),
        TextButton(
          onPressed: () {
            game.mapCamera.toPlayerUnits();
          },
          child: const Text('To player units'),
        ),
        const Text('Campaign'),
        TextButton(
          onPressed: () {
            game.mapCamera.toPlayerProvinces();
          },
          child: const Text('To player provinces'),
        ),
        SwitchListTile(
          value: game.soundsEnabled,
          onChanged: (final enabled) {
            game.soundsEnabled = enabled;
            game.debugService.notify();
          },
          title: const Text('Global sounds'),
        ),
        SwitchListTile(
          value: game.debugService.state.fogOfWarVisibility ==
              VisibilityState.whatPlayerSee,
          onChanged: (final visible) {
            game.debugService.state.fogOfWarVisibility = visible
                ? VisibilityState.whatPlayerSee
                : VisibilityState.hidden;
            game.debugService.notify();
          },
          title: const Text('Fog of war'),
        ),
      ],
    );
  }
}
