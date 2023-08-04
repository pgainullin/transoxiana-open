part of 'tutorial_action_buttons.dart';

class TutorialOverlaySwitch extends StatelessWidget {
  const TutorialOverlaySwitch({
    required this.text,
    required this.mode,
    required this.game,
    this.padding,
    this.style,
    this.onPressed,
    final Key? key,
  }) : super(key: key);
  final TransoxianaGame game;
  final String text;
  final TutorialModes mode;
  final TextStyle? style;
  final VoidCallback? onPressed;
  final EdgeInsets? padding;
  @override
  Widget build(final BuildContext context) {
    return ListTile(
      contentPadding: padding,
      onTap: () async {
        onPressed?.call();
        TutorialState.switchMode(
          mode: mode,
          game: game,
          enableOverlay: true,
        );
      },
      title: Text(
        text,
        textAlign: TextAlign.center,
        style: style ?? Theme.of(context).textTheme.headline3,
      ),
    );
  }
}
