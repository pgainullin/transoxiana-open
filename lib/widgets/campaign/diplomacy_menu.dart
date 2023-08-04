import 'package:flutter/material.dart';
import 'package:transoxiana/components/game/game.dart';
import 'package:transoxiana/components/shared/events/events.dart';
import 'package:transoxiana/components/shared/nation.dart';
import 'package:transoxiana/data/nation_sort_parameter.dart';
import 'package:transoxiana/generated/l10n.dart';
import 'package:transoxiana/widgets/base/buttons.dart';
import 'package:transoxiana/widgets/base/dialogues.dart';
import 'package:transoxiana/widgets/campaign/dismissible_menu_overlay.dart';
import 'package:transoxiana/widgets/ui_constants.dart';

/// Menu showing the currently selected nation (starts =player)
/// and their diplomatic relationships
class DiplomacyMenu extends StatefulWidget {
  const DiplomacyMenu({required this.game, final Key? key}) : super(key: key);
  final TransoxianaGame game;

  @override
  _DiplomacyMenuState createState() => _DiplomacyMenuState();
}

class _DiplomacyMenuState extends State<DiplomacyMenu> {
  late Nation selectedNation;
  NationComparatorType comparatorType = NationComparatorType.unitCount;

  final List<Nation> sortedNations = [];

  @override
  void initState() {
    selectedNation = widget.game.player!;
    refreshNationsList();
    super.initState();
  }

  void refreshNationsList() {
    sortedNations
      ..clear()
      ..addAll(
        widget.game.campaignRuntimeData.nations.values
            .where((final element) => element != selectedNation),
      )
      //reverse sort by the relevant parameter
      ..sort(
        (final a, final b) => comparatorFromType(b, comparatorType)
            .value
            .compareTo(comparatorFromType(a, comparatorType).value),
      );
  }

  void changeSortType(final NationComparatorType? newType) {
    if (mounted && newType != null) {
      setState(() {
        comparatorType = newType;
        refreshNationsList();
      });
    }
  }

  NationDiplomacyWidget nationWidget(final Nation nation) {
    return NationDiplomacyWidget(
      game: widget.game,
      nation: nation,
      leadingValue: comparatorFromType(
        nation,
        comparatorType,
      ).value.toInt(),
    );
  }

  @override
  Widget build(final BuildContext context) {
    return DismissibleMenuOverlay(
      dismissCallback: widget.game.hideDiplomacyMenu,
      child: Column(
        children: [
          //select sort type
          DropdownButton<NationComparatorType>(
            value: comparatorType,
            items: NationComparatorType.values
                .map(
                  (final e) => DropdownMenuItem<NationComparatorType>(
                    value: e,
                    child:
                        Text(comparatorFromType(selectedNation, e).description),
                  ),
                )
                .toList(),
            onChanged: changeSortType,
          ),
          //selected nation
          nationWidget(selectedNation),
          const Divider(),
          //other nations
          Flexible(
            child: ListView.builder(
              itemCount: sortedNations.length,
              itemBuilder: (final context, final index) =>
                  nationWidget(sortedNations.elementAt(index)),
            ),
          ),
        ],
      ),
    );
  }
}

/// A ListTile showing a given nation's diplomatic relationships. Not reactive.
class NationDiplomacyWidget extends StatefulWidget {
  const NationDiplomacyWidget({
    required this.game,
    required this.nation,
    required this.leadingValue,
    final Key? key,
  }) : super(key: key);
  final TransoxianaGame game;
  final Nation nation;
  final int leadingValue;

  @override
  _NationDiplomacyWidgetState createState() => _NationDiplomacyWidgetState();
}

class _NationDiplomacyWidgetState extends State<NationDiplomacyWidget> {
  bool _peaceOfferSent = false;

  @override
  void initState() {
    _peaceOfferSent = widget.nation.events
        .where(
          (final element) =>
              element.consequence.type == EventConsequenceType.peaceOffer &&
              element.consequence.otherNation == widget.game.player &&
              element.triggered == false,
        )
        .isNotEmpty;
    super.initState();
  }

  @override
  Widget build(final BuildContext context) {
    return ListTile(
      leading: Text(
        UiSettings.wholeNumberFormat.format(widget.leadingValue),
        style: Theme.of(context).textTheme.headline2,
      ),
      title: Text(
        widget.nation.name,
        style: TextStyle(
          color: widget.nation.color,
          shadows: UiSettings.textShadows,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${S.of(context).atWarWithColon} ${widget.nation.diplomaticRelationships.entries.where((final element) => element.value == DiplomaticStatus.war).map((final e) => e.key.name).join(', ')}',
            textAlign: TextAlign.start,
            style: Theme.of(context).textTheme.bodyText2,
          ),
          // Text(
          //   '${S.of(context).atPeaceWithColon} ${nation.diplomaticRelationships.entries.where((element) => element.value == DiplomaticStatus.peace).map((e) => e.key.name).join(', ')}',
          // ),
          Text(
            '${S.of(context).alliedWithColon} ${widget.nation.diplomaticRelationships.entries.where((final element) => element.value == DiplomaticStatus.alliance).map((final e) => e.key.name).join(', ')}',
            textAlign: TextAlign.start,
            style: Theme.of(context).textTheme.bodyText2,
          ),
        ],
      ),
      trailing: widget.nation == widget.game.player
          ? null
          : SizedBox(
              height: 48.0,
              width: 48.0,
              child: (!widget.nation.isHostileTo(widget.game.player!))
                  ? RoundButton(
                      onPressed: confirmWarDeclaration,
                      color: Colors.red,
                      icon: UiIcons.war,
                      extraPadding: 3.0,
                      backgroundOpacity: 0.0,
                      borderWidth: 2.0,
                      // const Icon(
                      //   Icons.local_fire_department,
                      // ),
                      tooltipText: '',
                      tooltipTitle: '',
                    )
                  : RoundButton(
                      onPressed: _peaceOfferSent
                          ? null
                          : () => sendPeaceOffer(context),
                      // disabledColor: Colors.blueGrey,
                      color: _peaceOfferSent ? Colors.grey : Colors.green,
                      icon: UiIcons.peace,
                      extraPadding: 3.0,
                      backgroundOpacity: 0.0,
                      borderWidth: 2.0,
                      // const Icon(
                      //   Icons.forward_to_inbox,
                      // ),
                      tooltipText: '',
                      tooltipTitle: '',
                    ),
            ),
    );
  }

  Future<void> confirmWarDeclaration() async {
    await widget.game.player!.confirmWarDeclaration(widget.nation);
    if (mounted) {
      setState(() {
        _peaceOfferSent = false;
      });
    }
  }

  void sendPeaceOffer(final BuildContext context) {
    widget.game.player!.addPeaceOfferEvent(widget.nation);
    asyncInfoDialog(
      context,
      S.of(context).peaceOfferSent,
      S.of(context).peaceOfferSentExplain(widget.nation.name),
    );
    if (mounted) {
      setState(() {
        _peaceOfferSent = true;
      });
    }
  }
}
