import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:transoxiana/components/battle/unit.dart';
import 'package:transoxiana/components/battle/unit_painters.dart';
import 'package:transoxiana/components/campaign/province.dart';
import 'package:transoxiana/components/game/game.dart';
import 'package:transoxiana/components/shared/army.dart';
import 'package:transoxiana/components/shared/commander.dart';
import 'package:transoxiana/data/army_modes.dart';
import 'package:transoxiana/data/constants.dart';
import 'package:transoxiana/data/direction.dart';
import 'package:transoxiana/generated/l10n.dart';
import 'package:transoxiana/services/painting_utils.dart';
import 'package:transoxiana/widgets/base/dialogues.dart';
import 'package:transoxiana/widgets/ui_constants.dart';

class ArmyListView extends StatelessWidget {
  const ArmyListView({
    required this.armies,
    required this.game,
    this.overrideDirection = Direction.south,
    final Key? key,
  }) : super(key: key);
  final List<Army> armies;
  final TransoxianaGame game;

  /// direction in which the unit sprites will be shown facing.
  /// defaults to Direction.south
  final Direction overrideDirection;

  @override
  Widget build(final BuildContext context) {
    return ListView.builder(
      itemCount: armies.length,
      itemBuilder: (final context, final index) => ListTile(
        title: ArmyNameWidget(armies[index]),
        subtitle: SizedBox(
          height: 80.0,
          child: ArmyUnitsRow(
            game: game,
            army: armies[index],
            overrideDirection: overrideDirection,
            addUnitCallback: null,
          ),
        ),
        trailing: Container(
          height: 32.0,
          width: 32.0,
          color: armies[index].nation.color,
        ),
      ),
    );
  }
}

///ListView showing all the units in a given army with units shown as draggables
///and the whole list as a drag target allowing player to move units
///between armies
class ArmyListEdit extends StatefulWidget {
  const ArmyListEdit({
    required this.province,
    required this.game,
    final Key? key,
  }) : super(key: key);
  final Province province;
  final TransoxianaGame game;
  @override
  _ArmyListEditState createState() => _ArmyListEditState();
}

class _ArmyListEditState extends State<ArmyListEdit> {
  // used solely to trigger rebuild when units are moved around,
  // does not contain any info.
  bool _stateToggle = false;

  /// setter adds a unit to this army
  ValueSetter<Unit> addUnitToThisArmy(final Army destinationArmy) {
    void addUnitToArmy(final Unit unit) {
      if (unit.nation != unit.game.player ||
          destinationArmy.nation != unit.game.player) return;

      if (destinationArmy.fightingUnitCount >= armyUnitLimit) return;
      if (destinationArmy == unit.army) return;

      if (mounted) {
        setState(() {
          destinationArmy.units.add(unit);
          unit.army!.units.remove(unit);
          unit.army = destinationArmy;
          _stateToggle = !_stateToggle;
        });
      }
    }

    return addUnitToArmy;
  }

  /// adds this unit to a newly-created army
  void createANewArmy(final Unit unit) {
    if (unit.nation != unit.game.player) return;
    if (mounted) {
      setState(() {
        unit.army?.location?.seedNewArmyWithAUnit(unit);
        unit.army?.data.mode = ArmyMode.fighter();
        _stateToggle = !_stateToggle;
      });
    }
  }

  /// setter merges an army with this army
  ValueSetter<Army> mergeWithThisArmy(
    final BuildContext context,
    final Army destinationArmy,
  ) {
    void mergeArmy(final Army army) {
      if (army == destinationArmy) return;

      if (army.fightingUnitCount + destinationArmy.fightingUnitCount >
          armyUnitLimit) {
        asyncInfoDialog(
          context,
          S.of(context).armySizeExceeded,
          S.of(context).armySizeExceededExplanation(armyUnitLimit.toString()),
        );
      } else {
        if (mounted) {
          setState(() {
            destinationArmy.absorbAnotherArmy(army);
            _stateToggle = !_stateToggle;
          });
        }
      }
    }

    return mergeArmy;
  }

  VoidCallback? _removeObservable;

  @override
  void initState() {
    // if the unit training screen results in one of the armies shown on this
    // screen to change it will trigger a gameData update
    //  so this widget needs to trigger a rebuild as well
    _removeObservable =
        widget.province.game.temporaryCampaignDataService.addObserver(
      listener: (final snap) {
        if (!snap.hasData || !mounted) return;
        _stateToggle = !_stateToggle;
        setState(() {});
      },
    );

    super.initState();
  }

  @override
  void dispose() {
    _removeObservable?.call();
    super.dispose();
  }

  @override
  Widget build(final BuildContext context) {
    final List<Army> activeArmies = widget.province.armies.values
        .where(
          (final element) =>
              element.fightingUnitCount > 0 &&
              element.defeated == false &&
              element.location != null,
        )
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          flex: 4,
          child: ListView.builder(
            itemCount: activeArmies.length,
            itemBuilder: (final context, final index) => ListTile(
              title: ArmyNameWidget(
                activeArmies[index],
                mergeCallback:
                    activeArmies[index].nation == widget.province.game.player
                        ? mergeWithThisArmy(context, activeArmies[index])
                        : null,
              ),
              subtitle: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                child: SizedBox(
                  height: 80.0,
                  child: ArmyUnitsRow(
                    game: widget.game,
                    army: activeArmies[index],
                    areUnitsDraggable: true,
                    addUnitCallback: addUnitToThisArmy(activeArmies[index]),
                  ),
                ),
              ),
            ),
          ),
        ),
        Flexible(
          // flex: 1,
          child: NewArmyWidget(createANewArmy),
        ),
      ],
    );
  }
}

class ArmyUnitsRow extends StatelessWidget {
  const ArmyUnitsRow({
    required this.army,
    required this.game,
    required this.addUnitCallback,
    this.areUnitsDraggable = false,
    this.overrideDirection = Direction.south,
    final Key? key,
  }) : super(key: key);

  final Army army;
  final bool areUnitsDraggable;
  final TransoxianaGame game;
  final ValueSetter<Unit>? addUnitCallback;

  /// direction in which the unit sprites will be shown facing.
  /// defaults to Direction.south
  final Direction overrideDirection;

  @override
  Widget build(final BuildContext context) {
    final Widget unitList = ListView.builder(
      itemCount: army.fightingUnits.length + 1,
      scrollDirection: Axis.horizontal,
      itemBuilder: (final context, final index) {
        if (index == 0) {
          return CommanderWidget(army.commander!);
        }
        final effectiveIndex = index - 1;
        if (effectiveIndex > army.fightingUnits.length - 1) {
          return const SizedBox();
        }
        final unit = army.fightingUnits.elementAt(effectiveIndex);
        return UnitSpriteWidget(
          unit,
          game: game,
          overrideDirection: overrideDirection,
          draggable: areUnitsDraggable &&
              !unit.isCommandUnit &&
              unit.nation == unit.game.player,
        );
      },
    );

    return areUnitsDraggable
        ? DragTarget<Unit>(
            builder: (
              final context,
              final accepted,
              final rejected,
            ) =>
                unitList,
            onAccept: addUnitCallback,
          )
        : unitList;
  }
}

class ArmyNameWidget extends StatelessWidget {
  const ArmyNameWidget(
    this.army, {
    this.mergeCallback,
    final Key? key,
  }) : super(key: key);
  final Army army;

  /// null for non-player armies whereby the widget will only show the name and
  /// no controls otherwise the name will be a draggable card
  /// with a trailing button leading to unit training menu
  final ValueSetter<Army>? mergeCallback;

  @override
  Widget build(final BuildContext context) {
    final Widget nameOnlyWidget = Text(
      army.name,
      style: Theme.of(context).textTheme.bodyText2!.copyWith(
            fontWeight: FontWeight.bold,
            shadows: UiSettings.textShadows,
            color: army.nation.color,
          ),
      overflow: TextOverflow.ellipsis,
      maxLines: 1,
    );

    final Widget widget = Card(
      child: ListTile(
        leading: (mergeCallback == null)
            ? Container()
            : const Icon(
                Icons.drag_indicator,
                size: 36.0,
              ),
        title: nameOnlyWidget,
        subtitle: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 48.0, maxHeight: 48.0),
          child: Text(
            '(${army.fightingUnitCount} ${S.of(context).units})',
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
        trailing: GestureDetector(
          onHorizontalDragStart: (final _) => {},
          onVerticalDragStart: (final _) => {},
          child: IconButton(
            padding: EdgeInsets.zero,
            onPressed: (mergeCallback == null ||
                    army.location!.nation != army.nation)
                ? null
                : () => army.game.showTrainUnitOverlay(army.location!, army),
            disabledColor: Colors.grey,
            color: army.nation.color,
            tooltip: S.of(context).trainUnit,
            icon: Icon(
              Icons.add,
              size: 36.0,
              semanticLabel: S.of(context).trainUnit,
            ),
          ),
        ),
      ),
    );

    return mergeCallback == null
        ? nameOnlyWidget
        : ArmyDragTarget(
            mergeCallback: mergeCallback,
            army: army,
            child: widget,
          );
  }
}

class ArmyDragTarget extends StatelessWidget {
  ArmyDragTarget({
    required this.army,
    required this.child,
    super.key,
    this.mergeCallback,
  });

  final ValueSetter<Army>? mergeCallback;
  final Army army;
  final Widget child;

  final toolTipKey = GlobalKey<TooltipState>();

  bool onHover(final Army? otherArmy) {
    if (otherArmy != null &&
        otherArmy.nation == army.nation &&
        otherArmy != army) {
      toolTipKey.currentState?.ensureTooltipVisible();
      return true;
    } else {
      toolTipKey.currentState?.deactivate();
      return false;
    }
  }

  void onEndHover() {
    toolTipKey.currentState?.deactivate();
  }

  @override
  Widget build(final BuildContext context) {
    return Tooltip(
      key: toolTipKey,
      message: S.of(context).mergeArmies,
      triggerMode: TooltipTriggerMode.manual,
      // to avoid the tooltip being triggered on hover on Desktop
      // ref https://github.com/flutter/flutter/issues/113310
      waitDuration: const Duration(minutes: 60),
      child: DragTarget<Army>(
        builder: (
          final context,
          final accepted,
          final rejected,
        ) =>
            Draggable<Army>(
          feedback: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 512.0, maxHeight: 80.0),
            child: child,
          ),
          data: army,
          child: child,
        ),
        onAccept: mergeCallback,
        onWillAccept: onHover,
        onLeave: (final _) => onEndHover(),
      ),
    );
  }
}

class CommanderWidget extends StatelessWidget {
  const CommanderWidget(
    this.commander, {
    final Key? key,
  }) : super(key: key);
  final Commander commander;

  @override
  Widget build(final BuildContext context) {
    return SizedBox(
      width: 198.0,
      height: 64.0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${S.of(context).commanderColon}${commander.name}',
            style: Theme.of(context).textTheme.bodyText1!.copyWith(
                  decoration: TextDecoration.underline,
                ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            textAlign: TextAlign.left,
          ),
          Text(
            '${S.of(context).commanderMoraleBoost}'
            '${UiSettings.decimalNumberFormat.format(commander.moraleBoostMultiple)}',
            style: Theme.of(context).textTheme.bodyText1,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            textAlign: TextAlign.left,
          ),
          Text(
            '${S.of(context).commanderAttritionBoost}'
            '${UiSettings.decimalNumberFormat.format(commander.attritionMultiple)}',
            style: Theme.of(context).textTheme.bodyText1,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            textAlign: TextAlign.left,
          ),
          Text(
            '${S.of(context).commanderMeleeSkill}'
            '${UiSettings.decimalNumberFormat.format(commander.unitMeleeBonus)}',
            style: Theme.of(context).textTheme.bodyText1,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            textAlign: TextAlign.left,
          ),
          Text(
            '${S.of(context).commanderRangedSkill}'
            '${UiSettings.decimalNumberFormat.format(commander.unitRangedBonus)}',
            style: Theme.of(context).textTheme.bodyText1,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            textAlign: TextAlign.left,
          ),
        ],
      ),
    );
  }
}

class UnitSpriteWidget extends StatelessWidget {
  const UnitSpriteWidget(
    this.unit, {
    required this.game,
    this.draggable = false,
    this.overrideDirection = Direction.south,
    final Key? key,
  }) : super(key: key);
  final TransoxianaGame game;
  final Unit unit;
  final bool draggable;

  /// direction in which the unit sprites will be shown facing.
  /// defaults to Direction.south
  final Direction overrideDirection;

  @override
  Widget build(final BuildContext context) {
    const double scale = 1.2;

    final box = SizedBox(
      width: unit.type.spriteSizeForHUD(scale).x,
      height: unit.type.spriteSizeForHUD(scale).y +
          unit.nation.painter.strokeWidth * 2.0 +
          paints.healthBarPaint.strokeWidth,
      child: Container(
        color: Colors.black.withOpacity(0.3),
      ),
    );

    final Widget widget = CustomPaint(
      painter: UnitPainter(
        game: game,
        unit: unit,
        center: unit.type.spriteSizeForHUD(scale) * 0.5,
        diameter: 32.0,
        scale: unit.type.spriteScaleForHUD(scale),
        spriteSize: unit.type.spriteSizeForHUD(scale),
        marker: markerType.hud,
        overrideDirection: overrideDirection,
      ),
      child: SizedBox(
        width: unit.type.spriteSizeForHUD(scale).x,
        height: unit.type.spriteSizeForHUD(scale).y +
            unit.nation.painter.strokeWidth * 2.0 +
            paints.healthBarPaint.strokeWidth,
      ),
    );

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 12.0),
      child: draggable
          ? Draggable<Unit>(
              feedback: widget,
              data: unit,
              childWhenDragging: box,
              child: widget,
            )
          : widget,
    );
  }
}

class NewArmyWidget extends StatelessWidget {
  const NewArmyWidget(this.createCallback, {final Key? key}) : super(key: key);
  final ValueSetter<Unit> createCallback;

  @override
  Widget build(final BuildContext context) {
    return DragTarget<Unit>(
      builder: (
        final context,
        final accepted,
        final rejected,
      ) =>
          Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 24.0,
          vertical: 16.0,
        ),
        child: DottedBorder(
          radius: const Radius.circular(16.0),
          strokeWidth: 3.0,
          child: Container(
            height: 80.0,
            color: Colors.black.withOpacity(0.25),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.add,
                ),
                Text(
                  S.of(context).dropToCreateANewArmy,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
      onAccept: createCallback,
    );
  }
}
