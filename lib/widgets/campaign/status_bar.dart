import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:states_rebuilder/states_rebuilder.dart';
import 'package:transoxiana/components/game/game.dart';
import 'package:transoxiana/data/season.dart';
import 'package:transoxiana/generated/l10n.dart';
import 'package:transoxiana/widgets/base/bar_container.dart';
import 'package:transoxiana/widgets/ui_constants.dart';

class CampaignStatusBar extends ReactiveStatelessWidget {
  const CampaignStatusBar({
    required this.game,
    final Key? key,
  }) : super(key: key);
  final TransoxianaGame game;

  @override
  Widget build(final BuildContext context) {
    final savableData = game.campaignRuntimeData;
    String seasonString;
    String seasonIcon = UiIcons.cancel;

    switch (savableData.currentSeason) {
      case Season.winter:
        seasonString = S.of(context).seasonWinter;
        seasonIcon = UiIcons.winter;
        break;
      case Season.spring:
        seasonString = S.of(context).seasonSpring;
        seasonIcon = UiIcons.spring;
        break;
      case Season.summer:
        seasonString = S.of(context).seasonSummer;
        seasonIcon = UiIcons.summer;
        break;
      case Season.autumn:
      default:
        seasonString = S.of(context).seasonAutumn;
        seasonIcon = UiIcons.autumn;
        break;
    }
    final player = game.player;
    return BarContainer(
      key: const Key('statusBar'),
      children: [
        if (player != null) NationTitle(player: player),
        Padding(
          padding: const EdgeInsets.only(
            left: UiSizes.paddingS,
            right: UiSizes.paddingXS,
          ),
          child: SvgPicture.asset(
            seasonIcon,
            color: UiColors.blackAsh,
            height: UiSizes.statusIconSize,
          ),
        ),
        Text(
          S.of(context).seasonYear(
                seasonString,
                savableData.currentYear.toString(),
              ),
        ),
      ],
    );
  }
}
