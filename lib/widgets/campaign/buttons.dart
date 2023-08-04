import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:transoxiana/components/campaign/campaign.dart';
import 'package:transoxiana/components/game/game.dart';
import 'package:transoxiana/data/campaign_data_source.dart';
import 'package:transoxiana/generated/l10n.dart';
import 'package:transoxiana/widgets/base/buttons.dart';
import 'package:transoxiana/widgets/tutorial/tutorial.dart';
import 'package:transoxiana/widgets/ui_constants.dart';

// class ZoomButtons extends StatelessWidget {
//   const ZoomButtons({
//     required this.game,
//     final Key? key,
//   }) : super(key: key);
//   final TransoxianaGame game;
//
//   @override
//   Widget build(final BuildContext context) {
//     return Positioned(
//       bottom: UiSizes.paddingM,
//       child: Row(
//         children: [
//           // ZOOM OUT
//           RoundButton(
//             icon: UiIcons.zoomOut,
//             onPressed: () => game.mapCamera.zoomOut(),
//             // onPressed: () => game.scaleCampaign(1 / 1.25),
//             tooltipTitle: S.of(context).zoomOut,
//             tooltipText: S.of(context).zoomOutTooltipContent,
//           ),
//           // ZOOM IN
//           RoundButton(
//             icon: UiIcons.zoomIn,
//             onPressed: () => game.mapCamera.zoomIn(),
//             // onPressed: () => game.scaleCampaign(1.25),
//             tooltipTitle: S.of(context).zoomIn,
//             tooltipText: S.of(context).zoomInTooltipContent,
//           ),
//         ],
//       ),
//     );
//   }
// }

class CampaignHelpButton extends StatelessWidget {
  const CampaignHelpButton({
    required this.game,
    final Key? key,
  }) : super(key: key);
  final TransoxianaGame game;

  @override
  Widget build(final BuildContext context) {
    return
        // Positioned(
        // bottom: UiSizes.buttonSize + UiSizes.paddingL,
        // right: UiSizes.paddingM,
        // child:
        TutorialHelpButton(
      key: const Key('campaignHelpButton'),
      game: game,
      activateTutorialCallback: game.campaign!.resetArmySelectionEvents,
      // ),
    );
  }
}

class CampaignTurnWidget extends StatelessWidget {
  const CampaignTurnWidget({
    required this.game,
    final Key? key,
  }) : super(key: key);
  final TransoxianaGame game;

  @override
  Widget build(final BuildContext context) {
    return Positioned(
      right: UiSizes.paddingM,
      bottom: UiSizes.paddingM,
      child: EndTurnButton(
        game,
        key: const Key('endCampaignTurnButton'),
        onPressed: () => game.campaign!.endTurn(),
        tooltipText: S.of(context).endTurnCampaignTooltipContent,
      ),
    );
  }
}

class MainMenuButton extends StatelessWidget {
  const MainMenuButton({
    required this.game,
    final Key? key,
  }) : super(key: key);
  final TransoxianaGame game;

  @override
  Widget build(final BuildContext context) {
    return CornerButton(
      icon: UiIcons.cogwheel,
      tooltipTitle: S.of(context).mainMenu,
      tooltipText: S.of(context).mainMenuTooltipContent,
      onPressed: () async {
        await CampaignLoader(game: game)
            .saveRuntime(reservedId: SaveReservedIds.autosave);
        game.showMainMenu();
      },
      corner: Corner.topRight,
    );
  }
}

typedef UseTutorialStepStateWrapper = Widget Function({required Widget child});

/// Set of menus in the top left corner that cover
/// campaign-wide concepts like diplomacy and statistics
class GameMenuButtons extends StatelessWidget {
  const GameMenuButtons({
    required this.game,
    required this.useTutorialStateWrapper,
    final Key? key,
  }) : super(key: key);
  final TransoxianaGame game;

  final UseTutorialStepStateWrapper useTutorialStateWrapper;
  void toggleDiplomacyMenu() {
    if (game.temporaryCampaignData.diplomacyMenuOpen) {
      game.hideDiplomacyMenu();
    } else {
      game.showDiplomacyMenu();
    }
  }

  @override
  Widget build(final BuildContext context) {
    return Positioned(
      top: -UiSizes.paddingL * 2.0,
      left: UiSizes.paddingL + UiSizes.buttonSize,
      child: Row(
        children: [
          //diplomacy
          RoundButton(
            onPressed: toggleDiplomacyMenu,
            tooltipTitle: S.of(context).showDiplomacy,
            tooltipText: S.of(context).showDiplomacyExplain,
            // isActive: !_diplomacyMenuOpen, //doesn't work if closed outside this widget - needs to be reactive or send a callback
            icon: UiIcons.diplomacy,
            extraPadding: 8.0,
            // child: const Icon(Icons.book_outlined),
          ),
          //help
          useTutorialStateWrapper(
            child: CampaignHelpButton(game: game),
          )

          // Placeholder
          // RoundButton(
          //   icon: UiIcons.zoomIn,
          //   onPressed: () => game.scaleCampaign(1.25),
          //   tooltipTitle: S.of(context).zoomIn,
          //   tooltipText: S.of(context).zoomInTooltipContent,
          // ),
        ],
      ),
    );
  }
}
