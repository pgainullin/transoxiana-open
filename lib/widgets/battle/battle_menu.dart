import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';
import 'package:transoxiana/components/battle/node.dart';
import 'package:transoxiana/components/battle/unit.dart';
import 'package:transoxiana/components/game/game.dart';
import 'package:transoxiana/components/shared/fortification.dart';
import 'package:transoxiana/data/temporary_game_data.dart';
import 'package:transoxiana/generated/l10n.dart';
import 'package:transoxiana/widgets/base/drawer_menu.dart';
import 'package:transoxiana/widgets/base/scroll_container.dart';
import 'package:transoxiana/widgets/base/tab_panel.dart';
import 'package:transoxiana/widgets/ui_constants.dart';

class BattleMenu extends StatelessWidget {
  const BattleMenu({required this.game, final Key? key, this.keepOpen = false})
      : super(key: key);

  final bool keepOpen;

  final TransoxianaGame game;

  @override
  Widget build(final BuildContext context) {
    bool shouldBeOpen = false;
    int activeTabIndex = 0;

    return StateBuilder<TemporaryGameData>(
      observe: () => game.temporaryCampaignDataService,
      shouldRebuild: (final rm) => true,
      builder: (final context, final data) {
        final effectiveData = data;
        if (effectiveData == null) return const CircularProgressIndicator();

        return effectiveData.onAll(
          onIdle: () => const CircularProgressIndicator(),
          onWaiting: () => const CircularProgressIndicator(),
          onError: (final error, final _) => ErrorWidget(error as Object),
          onData: (final data) {
            final isRealTimePhase = !data.inCommand;

            if (data.selectedUnit != null && !isRealTimePhase) {
              // open menu
              shouldBeOpen = true;
              // if unit is selected, activate the unit tab
              activeTabIndex = 0;
            } else if (data.selectedNode != null && !isRealTimePhase) {
              // open menu
              shouldBeOpen = true;
              // if tile is selected (but unit is not),
              // activate the tile tab
              activeTabIndex = 1;
            } else if (keepOpen) {
              // keep open if it's intentional and switch to Chronicle page
              activeTabIndex = 2;
              shouldBeOpen = true;
            } else {
              // close menu after deselecting unit
              shouldBeOpen = false;
            }

            return DrawerMenu(
              game: game,
              height: 270,
              width: 335,
              startOpen: shouldBeOpen,
              child: TabPanel(
                tabWidth: 75,
                icons: const [
                  UiIcons.helmet,
                  UiIcons.signpost,
                  UiIcons.crossedSwords
                ],
                activeIndex: activeTabIndex,
                children: [
                  ScrollContainer(
                    child: data.selectedUnit == null
                        ? ScrollContainerEmpty(S.of(context).noUnit)
                        : UnitInfo(unit: effectiveData.state.selectedUnit!),
                  ),
                  ScrollContainer(
                    child: data.selectedNode == null
                        ? ScrollContainerEmpty(S.of(context).noTile)
                        : TileInfo(
                            node: effectiveData.state.selectedNode!,
                            game: game,
                          ),
                  ),
                  ScrollContainer(
                    child: ChronicleInfo(game: game),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

// LOG ///////////////////////////////////////////////////////////////////

class ChronicleInfo extends ReactiveStatelessWidget {
  const ChronicleInfo({required this.game, final Key? key}) : super(key: key);
  final TransoxianaGame game;

  @override
  Widget build(final BuildContext context) {
    final temporaryCampaignData = game.temporaryCampaignData;
    final List<Widget> infoItems = [
      Column(
        children: [
          ScrollContainerTitle(
            text: game.player?.name ?? '',
            icon: UiIcons.flag,
            color: game.player?.color ?? UiColors.blackAsh,
            shadows: UiSettings.textShadows,
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: UiSizes.paddingXS),
            child: temporaryCampaignData.inCommand
                ? Text(S.of(context).yourTurn)
                : Text(S.of(context).waitTurn),
          ),
        ],
      ),
    ];

    final List<String> logItems = game.logs.reversed.toList();

    if (logItems.isEmpty) {
      return Column(
        children: infoItems +
            [
              // Flexible to prevent overflow issues
              // when animating menu open/close
              Flexible(
                child: SizedBox(
                  height: 100,
                  child: Align(
                    // alignment: Alignment.center,
                    child: Text(S.of(context).logEmpty),
                  ),
                ),
              )
            ],
      );
    } else {
      infoItems.addAll(
        logItems.map((final item) {
          return Container(
            margin: const EdgeInsets.only(
              right: UiSizes.paddingL,
              left: UiSizes.paddingL,
              bottom: UiSizes.paddingXS,
            ),
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(
                  // width: 1.0,
                  color: UiColors.blackAsh,
                ),
              ),
            ),
            child: Text(item),
          );
        }),
      );

      return ClipRRect(
        borderRadius:
            const BorderRadius.all(Radius.circular(UiSizes.borderRadius)),
        child: GlowingOverscrollIndicator(
          axisDirection: AxisDirection.down,
          color: UiColors.brownWood,
          child: ListView(
            children: infoItems,
          ),
        ),
      );
    }
  }
}

// UNIT ///////////////////////////////////////////////////////////////////

class UnitInfo extends StatelessWidget {
  const UnitInfo({
    required this.unit,
    final Key? key,
  }) : super(key: key);
  final Unit unit;

  @override
  Widget build(final BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: UiSizes.paddingXS),
          // padding: const EdgeInsets.all(8.0),
          child: ScrollContainerTitle(
            text: unit.name,
            color: unit.nation.color,
            shadows: UiSettings.textShadows,
            icon: UiIcons.attack,
          ),
        ),
        ScrollContainerText(S.of(context).speedColon + unit.speed.toString()),
        ScrollContainerText(
          S.of(context).meleeColon +
              S.of(context).attackValue(
                    unit.meleeStrength.toString(),
                    unit.meleeReach.toString(),
                  ),
        ),
        ScrollContainerText(
          S.of(context).rangedColon +
              S.of(context).attackValue(
                    unit.rangedStrength.toString(),
                    unit.shootingRange.toString(),
                  ),
        ),
        ScrollContainerText(
          S.of(context).destinationColon +
              (unit.orderedDestination != null
                  ? S.of(context).tileCoordinates(
                        unit.orderedDestination?.x.toString() ?? '',
                        unit.orderedDestination?.y.toString() ?? '',
                      )
                  : S.of(context).notSet),
        ),
        ScrollContainerText(
          S.of(context).progressColon + unit.progress.toStringAsFixed(2),
        ),
        // ScrollContainerText(
        //   'Distance: ${unit.location?.
        //   adjacentDistances[unit.nextNode]?.toString() ?? 'NaN'}',
        // ),
        // ScrollContainerText(
        //   S.of(context).progressColon +
        //   unit.meleeProgress.toStringAsFixed(2),),
        ScrollContainerText(
          S.of(context).momentumColon + unit.momentum.toString(),
        )
      ],
    );
  }
}

// TILE ///////////////////////////////////////////////////////////////////

class TileInfo extends StatelessWidget {
  const TileInfo({
    required this.node,
    required this.game,
    final Key? key,
  }) : super(key: key);
  final Node node;
  final TransoxianaGame game;

  @override
  Widget build(final BuildContext context) {
    final Segment? segment = node.fortificationSegment;
    String fortificationString;
    String superStructureString;
    final Unit? occupyingUnit = node.unit;

    switch (segment?.type) {
      case FortificationType.wall:
        fortificationString = S.of(context).wall;
        break;
      case FortificationType.tower:
        fortificationString = S.of(context).tower;
        break;
      case FortificationType.gate:
        fortificationString = S.of(context).gate;
        break;
      default:
        fortificationString = S.of(context).none;
    }

    switch (node.superStructure) {
      case SuperStructureType.hill:
        superStructureString = S.of(context).hill;
        break;
      case SuperStructureType.mountain:
        superStructureString = S.of(context).mountain;
        break;
      case SuperStructureType.building:
        superStructureString = S.of(context).building;
        break;
      case SuperStructureType.forest:
        superStructureString = S.of(context).forest;
        break;
      case SuperStructureType.road:
        superStructureString = S.of(context).road;
        break;
      default:
        superStructureString = S.of(context).none;
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: UiSizes.paddingXS),
          child: ScrollContainerTitle(
            text: S.of(context).tileHeading +
                S
                    .of(context)
                    .tileCoordinates(node.x.toString(), node.y.toString()),
            icon: UiIcons.compass,
          ),
        ),
        ScrollContainerText(
          S.of(context).groundColon + node.terrain.toString().split('.').last,
        ),
        ScrollContainerText(S.of(context).featureColon + superStructureString),
        ScrollContainerText(
          S.of(context).fortificationColon + fortificationString,
        ),
        if (segment == null)
          Container()
        else
          ScrollContainerText(
            S.of(context).fortificationIntegrityColon +
                segment.life.round().toString() +
                S.of(context).percent,
          ),
        // segment == null || segment.type != fortificationType.gate
        //     ? Container()
        //     : ScrollContainerText(
        //         S.of(context).fortificationGateStatusColon +
        //             (segment.open ? S.of(context).open :
        //             S.of(context).closed),
        //       ),
        if (segment == null ||
            segment.type != FortificationType.gate ||
            occupyingUnit == null ||
            occupyingUnit.nation != game.player)
          Container()
        else
          ToggleGatesButton(
            key: ObjectKey(segment),
            startingStateOpen: segment.open,
            callback: segment.toggleOpenStatus,
          )
      ],
    );
  }
}

// GATES BUTTON ///////////////////////////////////////////////////////////////

class ToggleGatesButton extends StatefulWidget {
  const ToggleGatesButton({
    required this.startingStateOpen,
    required this.callback,
    final Key? key,
  }) : super(key: key);
  final bool startingStateOpen;
  final VoidCallback callback;

  @override
  _ToggleGatesButtonState createState() => _ToggleGatesButtonState();
}

class _ToggleGatesButtonState extends State<ToggleGatesButton> {
  bool _gateOpen = false;

  @override
  void initState() {
    _gateOpen = widget.startingStateOpen;
    super.initState();
  }

  void toggle() {
    if (mounted) {
      setState(() {
        widget.callback.call();
        _gateOpen = !_gateOpen;
      });
    }
  }

  @override
  Widget build(final BuildContext context) {
    return TextButton(
      onPressed: toggle,
      child:
          Text(_gateOpen ? S.of(context).closeGates : S.of(context).openGates),
    );
  }
}
