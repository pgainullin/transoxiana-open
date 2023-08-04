import 'dart:math';

import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';
import 'package:transoxiana/components/battle/battle.dart';
import 'package:transoxiana/components/game/game.dart';
import 'package:transoxiana/components/shared/army.dart';
import 'package:transoxiana/data/direction.dart';
import 'package:transoxiana/generated/l10n.dart';
import 'package:transoxiana/widgets/base/army_views.dart';
import 'package:transoxiana/widgets/base/rounded_border_container.dart';

class AiBattleOverlay extends StatelessWidget {
  const AiBattleOverlay({
    required this.battle,
    required this.game,
    final Key? key,
  }) : super(key: key);
  final Battle battle;
  final TransoxianaGame game;

  @override
  Widget build(final BuildContext context) {
    // TODO: design

    final List<Army> friendlyArmies = battle.armies
        .where(
          (final element) =>
              element.nation.isFriendlyTo(battle.province.nation),
        )
        .toList();
    if (friendlyArmies.isEmpty) {
      friendlyArmies.addAll(
        battle.armies.where(
          (final element) =>
              element.nation.isFriendlyTo(battle.armies.first.nation),
        ),
      );
    }

    assert(friendlyArmies.isNotEmpty);
    final List<Army> enemyArmies = battle.armies
        .where(
          (final element) =>
              element.nation.isHostileTo(friendlyArmies.first.nation),
        )
        .toList();

    final Size screenSize = MediaQuery.of(context).size;
    final double width = max(screenSize.width * 0.65, 400.0);
    final double height = max(screenSize.height * 0.75, 250.0);

    return Stack(
      children: [
        Container(),
        Positioned(
          left: 0.5 * (screenSize.width - width),
          top: 0.5 * (screenSize.height - height),
          child: Card(
            // color: Theme.of(context).primaryColor.withAlpha(125),
            child: MenuBox(
              width: width,
              height: height,
              child: Column(
                children: [
                  Text(
                    S.of(context).aiBattleInProvince(battle.province.name),
                    style: Theme.of(context).textTheme.headline3,
                  ),
                  OnReactive(() {
                    if (battle.game.temporaryCampaignDataService.state
                            .winningNation !=
                        null) {
                      return Text(
                        S.of(context).victoryDialogueContent(
                              battle.game.temporaryCampaignDataService.state
                                  .winningNation!.name,
                            ),
                        style: Theme.of(context).textTheme.headline2,
                        textAlign: TextAlign.center,
                      );
                    } else {
                      return Container();
                    }
                  }),
                  Expanded(
                    child: Row(
                      children: [
                        Expanded(
                          child: ArmyListView(
                            game: game,
                            armies: friendlyArmies,
                            overrideDirection: Direction.southEast,
                          ),
                        ),
                        Expanded(
                          child: ArmyListView(
                            game: game,
                            armies: enemyArmies,
                            overrideDirection: Direction.southWest,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
