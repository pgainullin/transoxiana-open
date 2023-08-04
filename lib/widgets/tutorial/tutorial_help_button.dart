import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';
import 'package:transoxiana/components/game/game.dart';
import 'package:transoxiana/generated/l10n.dart';
import 'package:transoxiana/services/tutorial/tutorial_states.dart';
import 'package:transoxiana/widgets/base/buttons.dart';
import 'package:transoxiana/widgets/ui_constants.dart';
import 'package:tutorial/tutorial.dart';

class TutorialHelpButton extends StatelessWidget {
  const TutorialHelpButton({
    required this.activateTutorialCallback,
    required this.game,
    final Key? key,
  }) : super(key: key);

  /// callback used to reset event-based tutorials
  final VoidCallback activateTutorialCallback;

  final TransoxianaGame game;
  @override
  Widget build(final BuildContext context) {
    return RoundButton(
      icon: UiIcons.help,
      onPressed: () async {
        game.tutorialHistory.statePointers[TutorialModes.campaignButtonsIntro] =
            0;

        TutorialState.switchMode(
          mode: TutorialModes.campaignButtonsIntro,
          game: game,
          enableOverlay: true,
        );
        activateTutorialCallback.call();
      },
      tooltipText: '',
      tooltipTitle: S.of(context).help,
    );
  }
}
