import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';
import 'package:transoxiana/components/battle/unit.dart';
import 'package:transoxiana/components/game/game.dart';
import 'package:transoxiana/generated/l10n.dart';
import 'package:transoxiana/widgets/base/buttons.dart';
import 'package:transoxiana/widgets/ui_constants.dart';

// COMMON

/// sets the stance of the selected unit after checking that
/// it belongs to the player
void setUnitStance(final TransoxianaGame game, final Stance stance) {
  final gameData = game.temporaryCampaignDataService;
  if (gameData.state.selectedUnit!.nation == game.player) {
    gameData.setState((final currentState) {
      currentState.selectedUnit!.data.stance = stance;
      return null;
    });
  } else {
    throw Exception(
      'setUnitStance triggered for a selected unit that does not belong to the player',
    );
  }
}

// UNIT BUTTONS

class AttackButton extends ReactiveStatelessWidget {
  const AttackButton({required this.game, final Key? key}) : super(key: key);
  final TransoxianaGame game;

  @override
  Widget build(final BuildContext context) {
    final data = game.temporaryCampaignData;
    if (data.inCommand &&
        data.selectedUnit != null &&
        data.selectedUnit?.nation == game.player) {
      return RoundButton(
        icon: UiIcons.attack,
        onPressed: () => setUnitStance(game, Stance.attack),
        tooltipTitle: S.of(context).attack,
        tooltipText: S.of(context).attackTooltipContent,
        isActive: data.selectedUnit!.stance == Stance.attack,
      );
    }

    return Container();
  }
}

class DefendButton extends ReactiveStatelessWidget {
  const DefendButton({required this.game, final Key? key}) : super(key: key);
  final TransoxianaGame game;

  @override
  Widget build(final BuildContext context) {
    final data = game.temporaryCampaignData;
    if (data.inCommand &&
        data.selectedUnit != null &&
        data.selectedUnit!.nation == game.player) {
      return RoundButton(
        icon: UiIcons.defend,
        onPressed: () => setUnitStance(game, Stance.defend),
        tooltipTitle: S.of(context).defend,
        tooltipText: S.of(context).defendTooltipContent,
        isActive: data.selectedUnit!.stance == Stance.defend,
      );
    }
    return Container();
  }
}

class BombardButton extends ReactiveStatelessWidget {
  const BombardButton({required this.game, final Key? key}) : super(key: key);
  final TransoxianaGame game;

  @override
  Widget build(final BuildContext context) {
    final data = game.temporaryCampaignData;
    if (data.inCommand &&
        data.selectedUnit != null &&
        data.selectedUnit!.bombardFactor > 0.0 &&
        data.selectedUnit!.nation == game.player) {
      return RoundButton(
        icon: UiIcons.bombard,
        onPressed: () => setUnitStance(game, Stance.bombard),
        tooltipTitle: S.of(context).bombard,
        tooltipText: S.of(context).bombardTooltipContent,
        isActive: data.selectedUnit!.stance == Stance.bombard,
      );
    }
    return Container();
  }
}

class ClearOrdersButton extends ReactiveStatelessWidget {
  const ClearOrdersButton({required this.game, final Key? key})
      : super(key: key);
  final TransoxianaGame game;

  @override
  Widget build(final BuildContext context) {
    final data = game.temporaryCampaignData;
    if (data.inCommand &&
        data.selectedUnit != null &&
        data.selectedUnit!.orderedDestination != null &&
        data.selectedUnit!.nation == game.player) {
      return RoundButton(
        icon: UiIcons.cancel,
        onPressed: () {
          data.selectedUnit?.clearOrders();
          game.temporaryCampaignDataService.setState((final s) {
            s.selectedUnit = null;
            return null;
          });
        },
        tooltipTitle: S.of(context).clearOrders,
        tooltipText: S.of(context).clearOrdersTooltipContent,
      );
    }
    return Container();
  }
}

class UnitButtons extends StatelessWidget {
  const UnitButtons({
    required this.game,
    final Key? key,
  }) : super(key: key);
  final TransoxianaGame game;

  @override
  Widget build(final BuildContext context) {
    return Positioned(
      bottom: UiSizes.paddingM,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          ClearOrdersButton(game: game),
          Column(
            children: [
              BombardButton(game: game),
              Row(
                children: [DefendButton(game: game), AttackButton(game: game)],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ALL UNIT BUTTONS AND TURN BUTTONS

class BattleTurnWidget extends StatelessWidget {
  const BattleTurnWidget({
    required this.game,
    final Key? key,
  }) : super(key: key);
  final TransoxianaGame game;

  void setAllToAttack() {
    game.activeBattle!.setAllPlayerUnitsToAttack();
    game.temporaryCampaignDataService.notify();
  }

  void setAllToDefend() {
    game.activeBattle!.setAllPlayerUnitsToDefend();
    game.temporaryCampaignDataService.notify();
  }

  void cancelAllOrders() {
    game.activeBattle!.cancelAllPlayerUnitOrders();
    game.temporaryCampaignDataService.notify();
  }

  @override
  Widget build(final BuildContext context) {
    return Positioned(
      bottom: UiSizes.paddingM,
      right: UiSizes.paddingM,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        // mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          RoundButton(
            onPressed: setAllToAttack,
            tooltipTitle: S.of(context).allAttack,
            tooltipText: S.of(context).allAttackExplain,
            icon: UiIcons.allAttack,
            extraPadding: 4.0,
            // child: const Icon(Icons.campaign),
          ),
          RoundButton(
            onPressed: setAllToDefend,
            tooltipTitle: S.of(context).allDefend,
            tooltipText: S.of(context).allDefendExplain,
            icon: UiIcons.allDefend,
            extraPadding: 4.0,
            // child: const Icon(Icons.add_location_alt),
          ),
          RoundButton(
            onPressed: cancelAllOrders,
            tooltipTitle: S.of(context).allCancel,
            tooltipText: S.of(context).allCancelExplain,
            icon: UiIcons.allCancel,
            extraPadding: 4.0,
          ),
          Padding(
            padding: EdgeInsets.only(
              right: UiSizes.paddingL,
              top: UiSizes.paddingL +
                  (MediaQuery.of(context).size.height > 500
                      ? UiSizes.buttonSize
                      : 0),
            ),
            child: Row(
              children: [
                FastForwardButton(
                  game: game,
                  key: ObjectKey(game.activeBattle),
                ),
                EndTurnButton(
                  game,
                  onPressed: () => game.activeBattle!.endTurn(),
                  tooltipText: S.of(context).endTurnBattleTooltipContent,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// SURRENDER

class SurrenderButton extends StatelessWidget {
  const SurrenderButton({required this.game, final Key? key}) : super(key: key);
  final TransoxianaGame game;

  @override
  Widget build(final BuildContext context) {
    return CornerButton(
      icon: UiIcons.flag,
      tooltipTitle: S.of(context).surrender,
      tooltipText: S.of(context).surrenderTooltipContent,
      onPressed: () => game.activeBattle?.confirmSurrender(),
      corner: Corner.topRight,
      color: Colors.white,
      iconSize: 40,
      extraIconOffset: 5,
    );
  }
}

// FAST-FORWARD

class FastForwardButton extends StatefulWidget {
  const FastForwardButton({required this.game, final Key? key})
      : super(key: key);
  final TransoxianaGame game;

  @override
  _FastForwardButtonState createState() => _FastForwardButtonState();
}

class _FastForwardButtonState extends State<FastForwardButton> {
  bool _fastForwardActive = false;

  @override
  void initState() {
    _fastForwardActive = widget.game.activeBattle?.fastForwardEnabled ?? false;
    super.initState();
  }

  void toggle() {
    widget.game.activeBattle?.toggleFastForward();
    if (mounted) {
      setState(() {
        _fastForwardActive = !_fastForwardActive;
      });
    }
  }

  @override
  Widget build(final BuildContext context) {
    return RoundButton(
      onPressed: toggle,
      tooltipTitle: S.of(context).fastForward,
      tooltipText: S.of(context).fastForwardExplain,
      isActive: _fastForwardActive,
      icon: UiIcons.fastForward,
    );
  }
}
