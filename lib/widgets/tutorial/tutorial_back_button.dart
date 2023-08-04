part of 'tutorial_action_buttons.dart';

class TutorialBackButton extends StatelessWidget {
  const TutorialBackButton({required this.game, final Key? key})
      : super(key: key);
  final TransoxianaGame game;
  @override
  Widget build(final BuildContext context) {
    return TextButton(
      onPressed: () {
        game.tutorialStateService.setState(
          (final s) {
            s.back();
            return null;
          },
        );
      },
      child: Text(
        S.of(context).back,
        style: Theme.of(context).textTheme.headline4,
      ),
    );
  }
}
