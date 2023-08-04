import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:states_rebuilder/states_rebuilder.dart';
import 'package:transoxiana/components/game/game.dart';
import 'package:transoxiana/generated/l10n.dart';
import 'package:transoxiana/widgets/base/bar_container.dart';
import 'package:transoxiana/widgets/ui_constants.dart';

class BattleStatusBar extends ReactiveStatelessWidget {
  const BattleStatusBar({required this.game, final Key? key}) : super(key: key);
  final TransoxianaGame game;

  @override
  Widget build(final BuildContext context) {
    final player = game.player;
    return BarContainer(
      children: [
        if (player != null) NationTitle(player: player),
        Padding(
          padding: const EdgeInsets.only(
            left: UiSizes.paddingS,
            right: UiSizes.paddingXS,
          ),
          child: SvgPicture.asset(
            UiIcons.crossedSwords,
            color: UiColors.blackAsh,
            height: UiSizes.statusIconSize,
          ),
        ),
        // Flexible needed to prevent a weird RenderFlex overflow error
        // when locking and the unlocking screen
        Flexible(
          child: Text(
            S.of(context).battleOfProvince(
                  game.temporaryCampaignData.battleProvince?.name ?? '',
                  game.campaignRuntimeData.currentYear.toString(),
                ),
          ),
        ),
      ],
    );
  }
}
