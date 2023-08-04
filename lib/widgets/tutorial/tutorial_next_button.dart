part of 'tutorial_action_buttons.dart';

class TutorialNextButton extends StatelessWidget {
  const TutorialNextButton({
    required this.game,
    required this.step,
    final Key? key,
  }) : super(key: key);
  final TutorialStep step;

  final TransoxianaGame game;
  @override
  Widget build(final BuildContext context) {
    return TextButton(
      onPressed: () async {
        final nextAllowed = await step.onVerifyNext?.call();
        if (nextAllowed == false) return;
        await game.tutorialStateService.setState((final s) {
          s.next();
          return null;
        });
      },
      child: Text(
        S.of(context).next,
        style: Theme.of(context).textTheme.headline4,
      ),
    );
  }
}
