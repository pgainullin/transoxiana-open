import 'package:flutter/material.dart';
import 'package:transoxiana/components/campaign/province.dart';
import 'package:transoxiana/components/game/game.dart';
import 'package:transoxiana/components/shared/army.dart';
import 'package:transoxiana/generated/l10n.dart';
import 'package:transoxiana/widgets/base/army_views.dart';

import 'package:transoxiana/widgets/campaign/dismissible_menu_overlay.dart';

/// widget allowing the player to manage armies located in a given province.
/// Has to be the player's province with at least one army
class ArmyManagementOverlay extends StatelessWidget {
  const ArmyManagementOverlay({
    required this.province,
    required this.dismissCallback,
    required this.game,
    final Key? key,
  }) : super(key: key);
  final Province province;
  final VoidCallback dismissCallback;
  final TransoxianaGame game;
  @override
  Widget build(final BuildContext context) {
    final List<Army> friendlyArmies = province.armies.values
        .where((final element) => element.nation == province.game.player)
        .toList();

    assert(friendlyArmies.isNotEmpty);

    return DismissibleMenuOverlay(
      dismissCallback: dismissCallback,
      child: Column(
        children: [
          Text(
            S.of(context).armyManagementInProvince(province.name),
            style: Theme.of(context).textTheme.headline3,
          ),
          Text(
            S.of(context).armyManagementExplain,
            style: Theme.of(context).textTheme.bodyText2,
          ),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: ArmyListEdit(
                    game: game,
                    province: province,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
