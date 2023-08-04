import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:transoxiana/components/battle/unit_painters.dart';
import 'package:transoxiana/components/campaign/province.dart';
import 'package:transoxiana/components/shared/army.dart';
import 'package:transoxiana/data/constants.dart';
import 'package:transoxiana/data/unit_types.dart';
import 'package:transoxiana/generated/l10n.dart';
import 'package:transoxiana/widgets/campaign/dismissible_menu_overlay.dart';
import 'package:transoxiana/widgets/ui_constants.dart';

class UnitTrainingView extends StatefulWidget {
  const UnitTrainingView({
    required this.province,
    required this.dismissCallback,
    this.preferredArmy,
    final Key? key,
  }) : super(key: key);
  final Province province;
  final Army? preferredArmy;
  final VoidCallback dismissCallback;

  @override
  _UnitTrainingViewState createState() => _UnitTrainingViewState();
}

class _UnitTrainingViewState extends State<UnitTrainingView> {
  // used solely to trigger rebuild when units are moved around, does not contain any info.
  bool _stateToggle = false;

  Future<void> trainUnit(final UnitType type) async {
    if (mounted) {
      await widget.province.trainUnit(type, widget.preferredArmy);
      _stateToggle = !_stateToggle;
      setState(() {});
    }
  }

  @override
  Widget build(final BuildContext context) {
    return DismissibleMenuOverlay(
      dismissCallback: widget.dismissCallback,
      widthFactor: 0.4,
      heightFactor: 0.6,
      child: Column(
        children: [
          Text(
            '${S.of(context).goldAvailableColon}${UiSettings.wholeNumberFormat.format(widget.province.goldAvailable)}',
          ),
          if (widget.province.hasTrainedUnitsThisSeason)
            Text(
              S.of(context).alreadyTrainedThisTurn,
              style: Theme.of(context).textTheme.bodyText2!.copyWith(
                    color: Theme.of(context).colorScheme.secondary,
                  ),
            )
          else
            Container(),
          if (widget.province.population <
              popsPerUnit * inverseDraftablePopsProportion)
            Text(
              S.of(context).notEnoughPops(
                    (popsPerUnit * inverseDraftablePopsProportion).toString(),
                  ),
              style: Theme.of(context).textTheme.bodyText2!.copyWith(
                    color: Theme.of(context).colorScheme.secondary,
                  ),
            )
          else
            Container(),
          Expanded(
            child: AvailableUnitListView(widget.province, trainUnit),
          ),
        ],
      ),
    );
  }
}

class AvailableUnitListView extends StatelessWidget {
  const AvailableUnitListView(this.province, this.trainCallback,
      {final Key? key,})
      : super(key: key);

  final Province province;
  final ValueSetter<UnitType> trainCallback;

  @override
  Widget build(final BuildContext context) {
    final List<UnitType> types = province.getAvailableUnits();

    return ListView.builder(
      itemCount: types.length + 1,
      itemBuilder: (final context, final index) => index == 0
          ? const UnitParametersRow()
          : UnitTrainWidget(
              types[index - 1],
              province,
              () => trainCallback(types[index - 1]),
            ),
    );
  }
}

class UnitParametersRow extends StatelessWidget {
  const UnitParametersRow({final Key? key}) : super(key: key);

  @override
  Widget build(final BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(UiSizes.paddingL * 2.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Expanded(
            child: Text(' '),
          ),
          Expanded(
            child: Text(S.of(context).name),
          ),
          Expanded(
            child: Text(S.of(context).meleeColon),
          ),
          Expanded(
            child: Text(S.of(context).rangedColon),
          ),
          Expanded(
            child: Text(S.of(context).cost),
          ),
        ],
      ),
    );
  }
}

class UnitTrainWidget extends StatelessWidget {
  const UnitTrainWidget(
    this.type,
    this.province,
    this.trainCallback, {
    final Key? key,
  }) : super(key: key);

  final UnitType type;
  final Province province;
  final VoidCallback trainCallback;

  @override
  Widget build(final BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(UiSizes.paddingL * 2.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Align(
              // alignment: Alignment.center,
              child: UnitTypeSpriteWidget(type: type),
            ),
          ),
          Expanded(
            child: Text(
              type.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: Text(
              '${UiSettings.wholeNumberFormat.format(type.meleeStrength)} x ${UiSettings.wholeNumberFormat.format(type.meleeReach)}',
              maxLines: 1,
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: Text(
              '${UiSettings.wholeNumberFormat.format(type.rangedStrength)} x ${UiSettings.wholeNumberFormat.format(type.shootingRange)}',
              maxLines: 1,
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: Column(
              children: [
                Text(
                  UiSettings.wholeNumberFormat.format(type.cost),
                  maxLines: 1,
                  textAlign: TextAlign.center,
                ),
                IconButton(
                  icon: const Icon(Icons.add_shopping_cart),
                  onPressed: province.getAffordableUnits().contains(type)
                      ? trainCallback
                      : null,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

//TODO: merge with UnitSpriteWidget after streamlining the painter classes
/// creates a widget that paints the unit type sprite in a box on the canvas
class UnitTypeSpriteWidget extends StatelessWidget {
  const UnitTypeSpriteWidget({
    required this.type,
    final Key? key,
  }) : super(key: key);
  final UnitType type;

  @override
  Widget build(final BuildContext context) {
    final srcSize = type.sprite.srcSize;
    final Widget widget = CustomPaint(
      painter: UnitTypePainter(
        type: type,
        center: Vector2.zero(),
        spriteSize: Vector2(0, 10),
      ),
      child: SizedBox(
        width: srcSize.x,
        height: srcSize.y,
      ),
    );

    return widget;
  }
}
