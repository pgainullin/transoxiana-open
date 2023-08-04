import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';
import 'package:transoxiana/components/campaign/campaign.dart';
import 'package:transoxiana/components/campaign/province.dart';
import 'package:transoxiana/components/game/game.dart';
import 'package:transoxiana/components/shared/army.dart';
import 'package:transoxiana/data/army_modes.dart';
import 'package:transoxiana/data/tutorial_settings/tutorial_settings.dart';
import 'package:transoxiana/generated/l10n.dart';
import 'package:transoxiana/widgets/base/callback_button.dart';
import 'package:transoxiana/widgets/base/drawer_menu.dart';
import 'package:transoxiana/widgets/base/scroll_container.dart';
import 'package:transoxiana/widgets/base/tab_panel.dart';
import 'package:transoxiana/widgets/ui_constants.dart';
// CAMPAIGN MENU WIDGET ///////////////////////////////////////////////////////

class CampaignMenu extends ReactiveStatelessWidget {
  const CampaignMenu({required this.game, final Key? key}) : super(key: key);
  final TransoxianaGame game;
  @override
  Widget build(final BuildContext context) {
    final temporaryCampaignData = game.temporaryCampaignData;

    int activeTabIndex = 0;
    bool startOpen = false;

    if (temporaryCampaignData.selectedArmy != null ||
        temporaryCampaignData.selectedProvince != null) {
      // open menu if army/province selected
      startOpen = true;
      if (temporaryCampaignData.selectedArmy != null) {
        // if army is selected, activate the army tab
        activeTabIndex = 0;
      } else {
        // if province is selected (but army is not),
        // activate the province tab
        activeTabIndex = 1;
      }
    } else {
      // close menu after clicking on empty area on the map
      startOpen = false;
    }

    final selectedArmy = temporaryCampaignData.selectedArmy;
    final selectedProvince = temporaryCampaignData.selectedProvince;

    return DrawerMenu(
      game: game,
      height: UiSizes.drawerMenuHeight,
      width: UiSizes.drawerMenuWidth,
      startOpen: startOpen,
      //deselect when the menu is closed
      closeCallback: game.campaign?.clearSelectedArmyAndProvince,
      child: TabPanel(
        icons: const [
          UiIcons.helmet,
          UiIcons.signpost,
        ],
        activeIndex: activeTabIndex,
        children: [
          ScrollContainer(
            child: selectedArmy == null
                ? ScrollContainerEmpty(S.of(context).noArmy)
                : ArmyInfo(army: temporaryCampaignData.selectedArmy!),
          ),
          ScrollContainer(
            child: selectedProvince == null
                ? ScrollContainerEmpty(S.of(context).noProvince)
                : ProvinceInfo(temporaryCampaignData.selectedProvince!),
          ),
        ],
      ),
    );
  }
}

// ARMY ///////////////////////////////////////////////////////////////////////

class ArmyInfo extends StatelessWidget {
  const ArmyInfo({
    required this.army,
    final Key? key,
  }) : super(key: key);
  final Army army;

  void taxLocation() {
    army.taxLocation();
    army.game.triggerGameDataUpdate();
  }

  @override
  Widget build(final BuildContext context) {
    final List<Army> friendlyArmiesInProvince = army.location!.armies.values
        .where((final element) => element.nation == army.nation)
        .toList();
    final int indexOfThisArmy = friendlyArmiesInProvince.indexOf(army);

    final Widget armyName = ScrollContainerTitle(
      text: army.name,
      color: army.nation.color,
      shadows: UiSettings.textShadows,
      icon: UiIcons.laurels,
    );
    final Campaign? campaign = army.game.campaign;
    if (campaign == null) throw ArgumentError.notNull('campaign');

    final Widget armyHeader = Row(
      // mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          // flex: 1,
          child: IconButton(
            onPressed: () => campaign.selectArmy(
              friendlyArmiesInProvince[indexOfThisArmy == 0
                  ? friendlyArmiesInProvince.length - 1
                  : indexOfThisArmy - 1],
            ),
            icon: const Icon(Icons.arrow_back_ios_outlined),
            highlightColor: UiColors.brownWood
                .withOpacity(UiSettings.buttonHighlightOpacity),
            color: UiColors.blackAsh,
            splashRadius: 25,
          ),
        ),
        Flexible(
          flex: 5,
          child: Column(
            children: [
              armyName,
              Text(
                S.of(context).armyCounter(
                      indexOfThisArmy + 1,
                      friendlyArmiesInProvince.length,
                    ),
                style: Theme.of(context).textTheme.bodyText1,
              )
            ],
          ),
        ),
        Flexible(
          // flex: 1,
          child: IconButton(
            onPressed: () => campaign.selectArmy(
              friendlyArmiesInProvince[
                  indexOfThisArmy == friendlyArmiesInProvince.length - 1
                      ? 0
                      : indexOfThisArmy + 1],
            ),
            icon: const Icon(Icons.arrow_forward_ios_outlined),
            highlightColor: UiColors.brownWood
                .withOpacity(UiSettings.buttonHighlightOpacity),
            color: UiColors.blackAsh,
            splashRadius: 25,
          ),
        )
      ],
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: UiSizes.paddingS),
          child: Column(
            children: [
              if (friendlyArmiesInProvince.length > 1) armyHeader else armyName,
              if (army.nation == army.game.player)
                ManageArmyButton(
                  army: army,
                  manageCallback: () =>
                      army.game.showArmyManagement(army.location!),
                ),
            ],
          ),
        ),
        ScrollContainerText(
          S.of(context).unitsColon + army.fightingUnitCount.toString(),
        ),
        ScrollContainerText(
          S.of(context).goldCarriedColon +
              UiSettings.wholeNumberFormat.format(army.goldCarried),
        ),
        if (army.nation == army.game.player)
          ScrollContainerPairRow(
            heading: Text(
              S.of(context).armyModeColon,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            entry: ArmyModeSelector(
              key: ObjectKey(army),
              army: army,
            ),
          )
        else
          ScrollContainerText(
            S.of(context).armyModeColon + army.mode.toString(),
          ),
        if (army.location!.nation == army.game.player)
          ScrollContainerPairRow(
            flex: 3,
            heading: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                S.of(context).provinceColon + army.location!.name,
              ),
            ),
            entry: TaxProvinceButton(army: army, taxCallback: taxLocation),
          )
        else
          ScrollContainerText(
            S.of(context).provinceColon + army.location!.name,
          ),
        ScrollContainerText(
          S.of(context).destinationColon +
              (army.destination != null
                  ? army.destination!.name
                  : S.of(context).none),
          // flex: 2,
        ),
        ScrollContainerPairRow(
          key: TutorialKeys.campaignSiegeModeButtons,
          flex: 3,
          heading: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              S.of(context).siegeBehaviour,
            ),
          ),
          entry: SelectButtons(
            key: Key(army.name),
            icons: const [UiIcons.attack, UiIcons.catapult],
            disabled: army.nation != army.game.player,
            callbacks: [
              army.setToAssault,
              army.setToSiege,
            ],
            initialIndex: army.siegeMode ? 1 : 0,
            activeColor: army.nation.color,
          ),
        ),
      ],
    );
  }
}

// PROVINCE ///////////////////////////////////////////////////////////////////

class ProvinceInfo extends StatelessWidget {
  const ProvinceInfo(
    this.province, {
    final Key? key,
  }) : super(key: key);
  final Province province;

  @override
  Widget build(final BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: UiSizes.paddingS),
          child: ScrollContainerTitle(
            text: province.name,
            icon: UiIcons.compass,
            shadows: UiSettings.textShadows,
            color: province.nation.color,
          ),
        ),
        ScrollContainerRow(
          flex: 2,
          children: [
            Text(
              S.of(context).nationColon + province.nation.name,
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ],
        ),
        ScrollContainerText(
          S.of(context).populationColon +
              UiSettings.wholeNumberFormat.format(province.population),
        ),
        ScrollContainerText(
          S.of(context).provisionsColon +
              S.of(context).provisionsValue(
                    UiSettings.wholeNumberFormat
                        .format(province.provisionsStored),
                    UiSettings.wholeNumberFormat
                        .format(province.provisionsCapacity),
                  ),
        ),
        ScrollContainerText(
          S.of(context).goldStoredColon +
              UiSettings.wholeNumberFormat.format(province.goldStored),
        ),
        if (province.fortIntegrity == null)
          Container()
        else
          ScrollContainerText(
            S.of(context).fortIntegrityColon +
                province.fortIntegrity!.round().toString() +
                S.of(context).percent,
          ),
        if (province.nation != province.game.player)
          Container()
        else
          Flexible(
            child: CallbackButton(
              key: ObjectKey(province),
              callback: () => province.game.showTrainUnitOverlay(province),
              activeText: S.of(context).trainUnit,
              inactiveText: S.of(context).noUnitsToTrain,
              activeStateGetter: () => province.getAffordableUnits().isNotEmpty,
            ),
          ),
      ],
    );
  }
}

// Army Mode DropdownButton ////

class ArmyModeSelector extends StatefulWidget {
  const ArmyModeSelector({
    required this.army,
    final Key? key,
  }) : super(key: key);

  final Army army;

  @override
  _ArmyModeSelectorState createState() => _ArmyModeSelectorState();
}

class _ArmyModeSelectorState extends State<ArmyModeSelector> {
  late ArmyMode _selectedMode;

  @override
  void initState() {
    _selectedMode = widget.army.mode;
    super.initState();
  }

  void updateMode(final ArmyMode newMode) {
    if (mounted) {
      setState(() {
        widget.army.data.mode = newMode;
        _selectedMode = newMode;
      });
    }
  }

  @override
  Widget build(final BuildContext context) {
    return DropdownButton<ArmyMode>(
      key: TutorialKeys.campaignArmyModeDropDown,
      style: Theme.of(context).textTheme.bodyText2,
      dropdownColor: UiColors.yellowPapyrus,
      isDense: true,
      items: ArmyMode.values.map((final value) {
        return DropdownMenuItem<ArmyMode>(
          value: value,
          child: Align(
            alignment: Alignment.topLeft,
            child: Text(
              value.toString(),
              overflow: TextOverflow.ellipsis,
              softWrap: true,
            ),
          ),
        );
      }).toList(),
      value: _selectedMode,
      underline: Container(),
      // selectedItemBuilder: (BuildContext context) =>
      // [Text(army.mode.toString().split('.').last)],
      onChanged: (final newMode) => updateMode(newMode!),
    );
  }
}

// Province Action Buttons ////

/// tile showing the name of the province this army is located in
/// and context buttons to tax and manage armies
class ProvinceButtons extends StatelessWidget {
  const ProvinceButtons({
    required this.army,
    required this.taxCallback,
    required this.recruitCallback,
    required this.manageCallback,
    final Key? key,
  }) : super(key: key);

  final Army army;
  final VoidCallback taxCallback;
  final VoidCallback recruitCallback;
  final VoidCallback manageCallback;

  @override
  Widget build(final BuildContext context) {
    if (army.location == null) return Container();

    final List<Widget> widgets = [];

    if (army.nation == army.game.player) {
      widgets.add(ManageArmyButton(army: army, manageCallback: manageCallback));

      if (army.location!.nation == army.game.player) {
        widgets.add(TaxProvinceButton(army: army, taxCallback: taxCallback));
      }
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: widgets.map((final btn) => Expanded(child: btn)).toList(),
      // crossAxisAlignment: CrossAxisAlignment.start,
      // mainAxisSize: MainAxisSize.max,
    );
  }
}

class ManageArmyButton extends StatelessWidget {
  const ManageArmyButton({
    required this.army,
    required this.manageCallback,
    final Key? key,
  }) : super(key: key);

  final Army army;
  final VoidCallback manageCallback;

  @override
  Widget build(final BuildContext context) {
    return Container(
      key: TutorialKeys.campaignManageArmyButton,
      child: RoundBorderButton(
        key: ObjectKey(army.location),
        callback: manageCallback,
        selectedIcon: Icon(
          Icons.multiple_stop,
          color: army.nation.color,
        ),
        activeColor: army.nation.color,
        notSelectedIcon: const Icon(
          Icons.multiple_stop,
          color: Colors.grey,
        ),
        activeStateGetter: () => true,
      ),
    );
  }
}

class TaxProvinceButton extends StatelessWidget {
  const TaxProvinceButton({
    required this.army,
    required this.taxCallback,
    final Key? key,
  }) : super(key: key);

  final Army army;
  final VoidCallback taxCallback;

  @override
  Widget build(final BuildContext context) {
    return Container(
      key: TutorialKeys.campaignTaxProvinceButton,
      child: RoundBorderButton(
        key: ObjectKey(army),
        callback: taxCallback,
        selectedIcon: Icon(
          Icons.attach_money,
          color: army.location!.nation.color,
        ),
        activeColor: army.location!.nation.color,
        notSelectedIcon: const Icon(
          Icons.attach_money,
          color: Colors.grey,
        ),
        activeStateGetter: () =>
            !army.location!.hasBeenTaxedThisSeason &&
            army.location!.nation == army.nation,
      ),
    );
  }
}
