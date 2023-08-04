// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes

class S {
  S();

  static S? _current;

  static S get current {
    assert(_current != null,
        'No instance of S was loaded. Try to initialize the S delegate before accessing S.current.');
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false)
        ? locale.languageCode
        : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = S();
      S._current = instance;

      return instance;
    });
  }

  static S of(BuildContext context) {
    final instance = S.maybeOf(context);
    assert(instance != null,
        'No instance of S present in the widget tree. Did you add S.delegate in localizationsDelegates?');
    return instance!;
  }

  static S? maybeOf(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  /// `Victory!`
  String get victoryDialogueTitle {
    return Intl.message(
      'Victory!',
      name: 'victoryDialogueTitle',
      desc: '',
      args: [],
    );
  }

  /// `Start the Campaign`
  String get startCampaign {
    return Intl.message(
      'Start the Campaign',
      name: 'startCampaign',
      desc: '',
      args: [],
    );
  }

  /// `Continue`
  String get continueCampaign {
    return Intl.message(
      'Continue',
      name: 'continueCampaign',
      desc: '',
      args: [],
    );
  }

  /// `Main Menu`
  String get mainMenu {
    return Intl.message(
      'Main Menu',
      name: 'mainMenu',
      desc: '',
      args: [],
    );
  }

  /// `Credits`
  String get credits {
    return Intl.message(
      'Credits',
      name: 'credits',
      desc: '',
      args: [],
    );
  }

  /// `{nation} has won the battle`
  String victoryDialogueContent(Object nation) {
    return Intl.message(
      '$nation has won the battle',
      name: 'victoryDialogueContent',
      desc: '',
      args: [nation],
    );
  }

  /// `{nation} has won the campaign`
  String campaignVictoryDialogueContent(Object nation) {
    return Intl.message(
      '$nation has won the campaign',
      name: 'campaignVictoryDialogueContent',
      desc: '',
      args: [nation],
    );
  }

  /// `Defeat!`
  String get defeatDialogueTitle {
    return Intl.message(
      'Defeat!',
      name: 'defeatDialogueTitle',
      desc: '',
      args: [],
    );
  }

  /// `Siege in {province}`
  String siegeContinueDialogueTitle(Object province) {
    return Intl.message(
      'Siege in $province',
      name: 'siegeContinueDialogueTitle',
      desc: '',
      args: [province],
    );
  }

  /// `Do you want to continue the siege?`
  String get siegeContinueDialogueContent {
    return Intl.message(
      'Do you want to continue the siege?',
      name: 'siegeContinueDialogueContent',
      desc: '',
      args: [],
    );
  }

  /// `Continue the siege`
  String get continueSiegeOption {
    return Intl.message(
      'Continue the siege',
      name: 'continueSiegeOption',
      desc: '',
      args: [],
    );
  }

  /// `Assault`
  String get assaultSiegeOption {
    return Intl.message(
      'Assault',
      name: 'assaultSiegeOption',
      desc: '',
      args: [],
    );
  }

  /// `Siege behaviour: `
  String get siegeBehaviour {
    return Intl.message(
      'Siege behaviour: ',
      name: 'siegeBehaviour',
      desc: '',
      args: [],
    );
  }

  /// `Siege`
  String get siegeBehaviourSiege {
    return Intl.message(
      'Siege',
      name: 'siegeBehaviourSiege',
      desc: '',
      args: [],
    );
  }

  /// `Confirm restart`
  String get confirmRestartDialogueTitle {
    return Intl.message(
      'Confirm restart',
      name: 'confirmRestartDialogueTitle',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to restart the game? All progress will be lost.`
  String get confirmRestartDialogueContent {
    return Intl.message(
      'Are you sure you want to restart the game? All progress will be lost.',
      name: 'confirmRestartDialogueContent',
      desc: '',
      args: [],
    );
  }

  /// `Change destination for {unit}`
  String changeDestinationDialogueTitle(Object unit) {
    return Intl.message(
      'Change destination for $unit',
      name: 'changeDestinationDialogueTitle',
      desc: '',
      args: [unit],
    );
  }

  /// `Are you sure you want to change this unit's orders?`
  String get changeDestinationDialogueContent {
    return Intl.message(
      'Are you sure you want to change this unit\'s orders?',
      name: 'changeDestinationDialogueContent',
      desc: '',
      args: [],
    );
  }

  /// `Surrender`
  String get surrender {
    return Intl.message(
      'Surrender',
      name: 'surrender',
      desc: '',
      args: [],
    );
  }

  /// `Surrender the battle to save your generals (armies will be lost).`
  String get surrenderTooltipContent {
    return Intl.message(
      'Surrender the battle to save your generals (armies will be lost).',
      name: 'surrenderTooltipContent',
      desc: '',
      args: [],
    );
  }

  /// `Confirm surrender`
  String get confirmSurrenderDialogueTitle {
    return Intl.message(
      'Confirm surrender',
      name: 'confirmSurrenderDialogueTitle',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to surrender the battle?`
  String get confirmSurrenderDialogueContent {
    return Intl.message(
      'Are you sure you want to surrender the battle?',
      name: 'confirmSurrenderDialogueContent',
      desc: '',
      args: [],
    );
  }

  /// `Confirm war declaration`
  String get confirmWarDeclarationTitle {
    return Intl.message(
      'Confirm war declaration',
      name: 'confirmWarDeclarationTitle',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to declare war on {nation}?`
  String confirmWarDeclarationContent(Object nation) {
    return Intl.message(
      'Are you sure you want to declare war on $nation?',
      name: 'confirmWarDeclarationContent',
      desc: '',
      args: [nation],
    );
  }

  /// `{nation} has just declared war on you!`
  String otherNationDeclaredWarOnYou(Object nation) {
    return Intl.message(
      '$nation has just declared war on you!',
      name: 'otherNationDeclaredWarOnYou',
      desc: '',
      args: [nation],
    );
  }

  /// `We are now at war with {nation}!`
  String youDeclareWarOnOtherNation(Object nation) {
    return Intl.message(
      'We are now at war with $nation!',
      name: 'youDeclareWarOnOtherNation',
      desc: '',
      args: [nation],
    );
  }

  /// `{nation} offers peace. Do you agree?`
  String otherNationOffersPeace(Object nation) {
    return Intl.message(
      '$nation offers peace. Do you agree?',
      name: 'otherNationOffersPeace',
      desc: '',
      args: [nation],
    );
  }

  /// `{nation} accepted your peace offer.`
  String otherNationAcceptsPeace(Object nation) {
    return Intl.message(
      '$nation accepted your peace offer.',
      name: 'otherNationAcceptsPeace',
      desc: '',
      args: [nation],
    );
  }

  /// `Event`
  String get event {
    return Intl.message(
      'Event',
      name: 'event',
      desc: '',
      args: [],
    );
  }

  /// `Spies report on a battle in {province}...`
  String aiBattleInProvince(Object province) {
    return Intl.message(
      'Spies report on a battle in $province...',
      name: 'aiBattleInProvince',
      desc: '',
      args: [province],
    );
  }

  /// `Attacking a fortified city`
  String get attackingFortTitle {
    return Intl.message(
      'Attacking a fortified city',
      name: 'attackingFortTitle',
      desc: '',
      args: [],
    );
  }

  /// `What shall the army do on arrival to {province}?`
  String attackingFortContent(Object province) {
    return Intl.message(
      'What shall the army do on arrival to $province?',
      name: 'attackingFortContent',
      desc: '',
      args: [province],
    );
  }

  /// `Besieged province captured`
  String get siegeSuccessfulTitle {
    return Intl.message(
      'Besieged province captured',
      name: 'siegeSuccessfulTitle',
      desc: '',
      args: [],
    );
  }

  /// `{nation} have taken {province} by siege as starving defenders scatter`
  String siegeSuccessfulContent(Object nation, Object province) {
    return Intl.message(
      '$nation have taken $province by siege as starving defenders scatter',
      name: 'siegeSuccessfulContent',
      desc: '',
      args: [nation, province],
    );
  }

  /// `{province} taken by {nation}`
  String provinceCaptureDialogueTitle(Object province, Object nation) {
    return Intl.message(
      '$province taken by $nation',
      name: 'provinceCaptureDialogueTitle',
      desc: '',
      args: [province, nation],
    );
  }

  /// `Choose what to do with {province}`
  String provinceCaptureDialogueContent(Object province) {
    return Intl.message(
      'Choose what to do with $province',
      name: 'provinceCaptureDialogueContent',
      desc: '',
      args: [province],
    );
  }

  /// `Sack`
  String get provinceCaptureDialogueSack {
    return Intl.message(
      'Sack',
      name: 'provinceCaptureDialogueSack',
      desc: '',
      args: [],
    );
  }

  /// `Annex`
  String get provinceCaptureDialogueAnnex {
    return Intl.message(
      'Annex',
      name: 'provinceCaptureDialogueAnnex',
      desc: '',
      args: [],
    );
  }

  /// `Assault`
  String get attackingFortAssault {
    return Intl.message(
      'Assault',
      name: 'attackingFortAssault',
      desc: '',
      args: [],
    );
  }

  /// `Besiege`
  String get attackingFortBesiege {
    return Intl.message(
      'Besiege',
      name: 'attackingFortBesiege',
      desc: '',
      args: [],
    );
  }

  /// `Restart the game`
  String get restartConfirmButton {
    return Intl.message(
      'Restart the game',
      name: 'restartConfirmButton',
      desc: '',
      args: [],
    );
  }

  /// `You are playing {nation}`
  String youArePlaying(Object nation) {
    return Intl.message(
      'You are playing $nation',
      name: 'youArePlaying',
      desc: '',
      args: [nation],
    );
  }

  /// `Saved Games`
  String get savedGames {
    return Intl.message(
      'Saved Games',
      name: 'savedGames',
      desc: '',
      args: [],
    );
  }

  /// `Units controlled`
  String get unitCountSort {
    return Intl.message(
      'Units controlled',
      name: 'unitCountSort',
      desc: '',
      args: [],
    );
  }

  /// `Population`
  String get populationSort {
    return Intl.message(
      'Population',
      name: 'populationSort',
      desc: '',
      args: [],
    );
  }

  /// `Gold controlled`
  String get goldSort {
    return Intl.message(
      'Gold controlled',
      name: 'goldSort',
      desc: '',
      args: [],
    );
  }

  /// `Loading...`
  String get loading {
    return Intl.message(
      'Loading...',
      name: 'loading',
      desc: '',
      args: [],
    );
  }

  /// `Game data retrieval error {error}`
  String gameDataError(Object error) {
    return Intl.message(
      'Game data retrieval error $error',
      name: 'gameDataError',
      desc: '',
      args: [error],
    );
  }

  /// `Army info retrieval error {error}`
  String armyDataError(Object error) {
    return Intl.message(
      'Army info retrieval error $error',
      name: 'armyDataError',
      desc: '',
      args: [error],
    );
  }

  /// `Province info retrieval error {error}`
  String provinceDataError(Object error) {
    return Intl.message(
      'Province info retrieval error $error',
      name: 'provinceDataError',
      desc: '',
      args: [error],
    );
  }

  /// `Unit info retrieval error {error}`
  String unitDataError(Object error) {
    return Intl.message(
      'Unit info retrieval error $error',
      name: 'unitDataError',
      desc: '',
      args: [error],
    );
  }

  /// `Tile info retrieval error {error}`
  String tileDataError(Object error) {
    return Intl.message(
      'Tile info retrieval error $error',
      name: 'tileDataError',
      desc: '',
      args: [error],
    );
  }

  /// `No army selected`
  String get noArmy {
    return Intl.message(
      'No army selected',
      name: 'noArmy',
      desc: '',
      args: [],
    );
  }

  /// `No province selected`
  String get noProvince {
    return Intl.message(
      'No province selected',
      name: 'noProvince',
      desc: '',
      args: [],
    );
  }

  /// `No unit selected`
  String get noUnit {
    return Intl.message(
      'No unit selected',
      name: 'noUnit',
      desc: '',
      args: [],
    );
  }

  /// `No tile selected`
  String get noTile {
    return Intl.message(
      'No tile selected',
      name: 'noTile',
      desc: '',
      args: [],
    );
  }

  /// `Province: `
  String get provinceColon {
    return Intl.message(
      'Province: ',
      name: 'provinceColon',
      desc: '',
      args: [],
    );
  }

  /// `Units: `
  String get unitsColon {
    return Intl.message(
      'Units: ',
      name: 'unitsColon',
      desc: '',
      args: [],
    );
  }

  /// `Gold carried: `
  String get goldCarriedColon {
    return Intl.message(
      'Gold carried: ',
      name: 'goldCarriedColon',
      desc: '',
      args: [],
    );
  }

  /// `Gold stored: `
  String get goldStoredColon {
    return Intl.message(
      'Gold stored: ',
      name: 'goldStoredColon',
      desc: '',
      args: [],
    );
  }

  /// `Next province: `
  String get nextProvinceColon {
    return Intl.message(
      'Next province: ',
      name: 'nextProvinceColon',
      desc: '',
      args: [],
    );
  }

  /// `Population: `
  String get populationColon {
    return Intl.message(
      'Population: ',
      name: 'populationColon',
      desc: '',
      args: [],
    );
  }

  /// `Provisions: `
  String get provisionsColon {
    return Intl.message(
      'Provisions: ',
      name: 'provisionsColon',
      desc: '',
      args: [],
    );
  }

  /// `Capacity: `
  String get capacityColon {
    return Intl.message(
      'Capacity: ',
      name: 'capacityColon',
      desc: '',
      args: [],
    );
  }

  /// `Speed: `
  String get speedColon {
    return Intl.message(
      'Speed: ',
      name: 'speedColon',
      desc: '',
      args: [],
    );
  }

  /// `Melee: `
  String get meleeColon {
    return Intl.message(
      'Melee: ',
      name: 'meleeColon',
      desc: '',
      args: [],
    );
  }

  /// `Ranged: `
  String get rangedColon {
    return Intl.message(
      'Ranged: ',
      name: 'rangedColon',
      desc: '',
      args: [],
    );
  }

  /// `Destination: `
  String get destinationColon {
    return Intl.message(
      'Destination: ',
      name: 'destinationColon',
      desc: '',
      args: [],
    );
  }

  /// `Actions:`
  String get actionsColon {
    return Intl.message(
      'Actions:',
      name: 'actionsColon',
      desc: '',
      args: [],
    );
  }

  /// `Progress: `
  String get progressColon {
    return Intl.message(
      'Progress: ',
      name: 'progressColon',
      desc: '',
      args: [],
    );
  }

  /// `Momentum: `
  String get momentumColon {
    return Intl.message(
      'Momentum: ',
      name: 'momentumColon',
      desc: '',
      args: [],
    );
  }

  /// `Tile `
  String get tileHeading {
    return Intl.message(
      'Tile ',
      name: 'tileHeading',
      desc: '',
      args: [],
    );
  }

  /// `Ground: `
  String get groundColon {
    return Intl.message(
      'Ground: ',
      name: 'groundColon',
      desc: '',
      args: [],
    );
  }

  /// `Feature: `
  String get featureColon {
    return Intl.message(
      'Feature: ',
      name: 'featureColon',
      desc: '',
      args: [],
    );
  }

  /// `Tax this Province`
  String get taxButton {
    return Intl.message(
      'Tax this Province',
      name: 'taxButton',
      desc: '',
      args: [],
    );
  }

  /// `Province has been taxed this season`
  String get alreadyTaxed {
    return Intl.message(
      'Province has been taxed this season',
      name: 'alreadyTaxed',
      desc: '',
      args: [],
    );
  }

  /// `Train a unit`
  String get trainUnit {
    return Intl.message(
      'Train a unit',
      name: 'trainUnit',
      desc: '',
      args: [],
    );
  }

  /// `No trainable units`
  String get noUnitsToTrain {
    return Intl.message(
      'No trainable units',
      name: 'noUnitsToTrain',
      desc: '',
      args: [],
    );
  }

  /// `not set`
  String get notSet {
    return Intl.message(
      'not set',
      name: 'notSet',
      desc: '',
      args: [],
    );
  }

  /// `tiles`
  String get tiles {
    return Intl.message(
      'tiles',
      name: 'tiles',
      desc: '',
      args: [],
    );
  }

  /// `Nation`
  String get nation {
    return Intl.message(
      'Nation',
      name: 'nation',
      desc: '',
      args: [],
    );
  }

  /// `Nation: `
  String get nationColon {
    return Intl.message(
      'Nation: ',
      name: 'nationColon',
      desc: '',
      args: [],
    );
  }

  /// `idle`
  String get idle {
    return Intl.message(
      'idle',
      name: 'idle',
      desc: '',
      args: [],
    );
  }

  /// `No messages in chronicle`
  String get logEmpty {
    return Intl.message(
      'No messages in chronicle',
      name: 'logEmpty',
      desc: '',
      args: [],
    );
  }

  /// `{killerNation}'s {killerUnit} killed {killedNation}'s {killedUnit} by spearing them {location}`
  String logSpearKill(Object killerNation, Object killerUnit,
      Object killedNation, Object killedUnit, Object location) {
    return Intl.message(
      '$killerNation\'s $killerUnit killed $killedNation\'s $killedUnit by spearing them $location',
      name: 'logSpearKill',
      desc: '',
      args: [killerNation, killerUnit, killedNation, killedUnit, location],
    );
  }

  /// `{killerNation}'s {killerUnit} killed {killedNation}'s {killedUnit} by shooting them {location}`
  String logRangedKill(Object killerNation, Object killerUnit,
      Object killedNation, Object killedUnit, Object location) {
    return Intl.message(
      '$killerNation\'s $killerUnit killed $killedNation\'s $killedUnit by shooting them $location',
      name: 'logRangedKill',
      desc: '',
      args: [killerNation, killerUnit, killedNation, killedUnit, location],
    );
  }

  /// `{killerNation}'s {killerUnit} killed {killedNation}'s {killedUnit} in hand-to-hand combat {location}`
  String logMeleeAttackKill(Object killerNation, Object killerUnit,
      Object killedNation, Object killedUnit, Object location) {
    return Intl.message(
      '$killerNation\'s $killerUnit killed $killedNation\'s $killedUnit in hand-to-hand combat $location',
      name: 'logMeleeAttackKill',
      desc: '',
      args: [killerNation, killerUnit, killedNation, killedUnit, location],
    );
  }

  /// `{killerNation}'s {killerUnit} was killed by {killedNation}'s {killedUnit} in hand-to-hand combat {location}`
  String logMeleeDefenceKill(Object killerNation, Object killerUnit,
      Object killedNation, Object killedUnit, Object location) {
    return Intl.message(
      '$killerNation\'s $killerUnit was killed by $killedNation\'s $killedUnit in hand-to-hand combat $location',
      name: 'logMeleeDefenceKill',
      desc: '',
      args: [killerNation, killerUnit, killedNation, killedUnit, location],
    );
  }

  /// `Winter`
  String get seasonWinter {
    return Intl.message(
      'Winter',
      name: 'seasonWinter',
      desc: '',
      args: [],
    );
  }

  /// `Spring`
  String get seasonSpring {
    return Intl.message(
      'Spring',
      name: 'seasonSpring',
      desc: '',
      args: [],
    );
  }

  /// `Summer`
  String get seasonSummer {
    return Intl.message(
      'Summer',
      name: 'seasonSummer',
      desc: '',
      args: [],
    );
  }

  /// `Autumn`
  String get seasonAutumn {
    return Intl.message(
      'Autumn',
      name: 'seasonAutumn',
      desc: '',
      args: [],
    );
  }

  /// `{season} {year}`
  String seasonYear(Object season, Object year) {
    return Intl.message(
      '$season $year',
      name: 'seasonYear',
      desc: '',
      args: [season, year],
    );
  }

  /// `Quick save`
  String get quickSave {
    return Intl.message(
      'Quick save',
      name: 'quickSave',
      desc: '',
      args: [],
    );
  }

  /// `Quick load`
  String get quickLoad {
    return Intl.message(
      'Quick load',
      name: 'quickLoad',
      desc: '',
      args: [],
    );
  }

  /// `End Turn`
  String get endTurn {
    return Intl.message(
      'End Turn',
      name: 'endTurn',
      desc: '',
      args: [],
    );
  }

  /// `It's your turn`
  String get yourTurn {
    return Intl.message(
      'It\'s your turn',
      name: 'yourTurn',
      desc: '',
      args: [],
    );
  }

  /// `Wait for your turn`
  String get waitTurn {
    return Intl.message(
      'Wait for your turn',
      name: 'waitTurn',
      desc: '',
      args: [],
    );
  }

  /// `Save game`
  String get saveGameDialogueTitle {
    return Intl.message(
      'Save game',
      name: 'saveGameDialogueTitle',
      desc: '',
      args: [],
    );
  }

  /// `Load game`
  String get loadGameDialogueTitle {
    return Intl.message(
      'Load game',
      name: 'loadGameDialogueTitle',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to overwrite your previous quick save?`
  String get saveGameDialogueContent {
    return Intl.message(
      'Are you sure you want to overwrite your previous quick save?',
      name: 'saveGameDialogueContent',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to abandon your current game?`
  String get loadGameDialogueContent {
    return Intl.message(
      'Are you sure you want to abandon your current game?',
      name: 'loadGameDialogueContent',
      desc: '',
      args: [],
    );
  }

  /// `End turn and let armies implement your orders.`
  String get endTurnCampaignTooltipContent {
    return Intl.message(
      'End turn and let armies implement your orders.',
      name: 'endTurnCampaignTooltipContent',
      desc: '',
      args: [],
    );
  }

  /// `End turn and let units implement your orders.`
  String get endTurnBattleTooltipContent {
    return Intl.message(
      'End turn and let units implement your orders.',
      name: 'endTurnBattleTooltipContent',
      desc: '',
      args: [],
    );
  }

  /// `Clear orders`
  String get clearOrders {
    return Intl.message(
      'Clear orders',
      name: 'clearOrders',
      desc: '',
      args: [],
    );
  }

  /// `Clear orders move orders`
  String get clearOrdersTooltipContent {
    return Intl.message(
      'Clear orders move orders',
      name: 'clearOrdersTooltipContent',
      desc: '',
      args: [],
    );
  }

  /// `Bombard`
  String get bombard {
    return Intl.message(
      'Bombard',
      name: 'bombard',
      desc: '',
      args: [],
    );
  }

  /// `Set stance to Bombard (stand ground + attack walls in range)`
  String get bombardTooltipContent {
    return Intl.message(
      'Set stance to Bombard (stand ground + attack walls in range)',
      name: 'bombardTooltipContent',
      desc: '',
      args: [],
    );
  }

  /// `Defend`
  String get defend {
    return Intl.message(
      'Defend',
      name: 'defend',
      desc: '',
      args: [],
    );
  }

  /// `Set stance to Defend (stand ground)`
  String get defendTooltipContent {
    return Intl.message(
      'Set stance to Defend (stand ground)',
      name: 'defendTooltipContent',
      desc: '',
      args: [],
    );
  }

  /// `Attack`
  String get attack {
    return Intl.message(
      'Attack',
      name: 'attack',
      desc: '',
      args: [],
    );
  }

  /// `Set stance to Attach (advance to engage nearby targets)`
  String get attackTooltipContent {
    return Intl.message(
      'Set stance to Attach (advance to engage nearby targets)',
      name: 'attackTooltipContent',
      desc: '',
      args: [],
    );
  }

  /// `Zoom in`
  String get zoomIn {
    return Intl.message(
      'Zoom in',
      name: 'zoomIn',
      desc: '',
      args: [],
    );
  }

  /// `Zoom in`
  String get zoomInTooltipContent {
    return Intl.message(
      'Zoom in',
      name: 'zoomInTooltipContent',
      desc: '',
      args: [],
    );
  }

  /// `Zoom out`
  String get zoomOut {
    return Intl.message(
      'Zoom out',
      name: 'zoomOut',
      desc: '',
      args: [],
    );
  }

  /// `Zoom out`
  String get zoomOutTooltipContent {
    return Intl.message(
      'Zoom out',
      name: 'zoomOutTooltipContent',
      desc: '',
      args: [],
    );
  }

  /// `Campaign menu`
  String get campaignMenu {
    return Intl.message(
      'Campaign menu',
      name: 'campaignMenu',
      desc: '',
      args: [],
    );
  }

  /// `Open campaign menu`
  String get campaignMenuTooltipContent {
    return Intl.message(
      'Open campaign menu',
      name: 'campaignMenuTooltipContent',
      desc: '',
      args: [],
    );
  }

  /// `Next army`
  String get nextArmy {
    return Intl.message(
      'Next army',
      name: 'nextArmy',
      desc: '',
      args: [],
    );
  }

  /// `Select the next army in the province`
  String get nextArmyTooltipContent {
    return Intl.message(
      'Select the next army in the province',
      name: 'nextArmyTooltipContent',
      desc: '',
      args: [],
    );
  }

  /// `Previous army`
  String get previousArmy {
    return Intl.message(
      'Previous army',
      name: 'previousArmy',
      desc: '',
      args: [],
    );
  }

  /// `Select the previous army in the province`
  String get previousArmyTooltipContent {
    return Intl.message(
      'Select the previous army in the province',
      name: 'previousArmyTooltipContent',
      desc: '',
      args: [],
    );
  }

  /// `army {active} of {total}`
  String armyCounter(Object active, Object total) {
    return Intl.message(
      'army $active of $total',
      name: 'armyCounter',
      desc: '',
      args: [active, total],
    );
  }

  /// `none`
  String get none {
    return Intl.message(
      'none',
      name: 'none',
      desc: '',
      args: [],
    );
  }

  /// `Fort integrity: `
  String get fortIntegrityColon {
    return Intl.message(
      'Fort integrity: ',
      name: 'fortIntegrityColon',
      desc: '',
      args: [],
    );
  }

  /// `Open Main Menu`
  String get mainMenuTooltipContent {
    return Intl.message(
      'Open Main Menu',
      name: 'mainMenuTooltipContent',
      desc: '',
      args: [],
    );
  }

  /// `%`
  String get percent {
    return Intl.message(
      '%',
      name: 'percent',
      desc: '',
      args: [],
    );
  }

  /// `{strength} x {reach} tiles`
  String attackValue(Object strength, Object reach) {
    return Intl.message(
      '$strength x $reach tiles',
      name: 'attackValue',
      desc: '',
      args: [strength, reach],
    );
  }

  /// `{x}:{y}`
  String tileCoordinates(Object x, Object y) {
    return Intl.message(
      '$x:$y',
      name: 'tileCoordinates',
      desc: '',
      args: [x, y],
    );
  }

  /// `{stored}/{capacity}`
  String provisionsValue(Object stored, Object capacity) {
    return Intl.message(
      '$stored/$capacity',
      name: 'provisionsValue',
      desc: '',
      args: [stored, capacity],
    );
  }

  /// `Battle of {province} {year}`
  String battleOfProvince(Object province, Object year) {
    return Intl.message(
      'Battle of $province $year',
      name: 'battleOfProvince',
      desc: '',
      args: [province, year],
    );
  }

  /// `Fortification: `
  String get fortificationColon {
    return Intl.message(
      'Fortification: ',
      name: 'fortificationColon',
      desc: '',
      args: [],
    );
  }

  /// `Fortification integrity: `
  String get fortificationIntegrityColon {
    return Intl.message(
      'Fortification integrity: ',
      name: 'fortificationIntegrityColon',
      desc: '',
      args: [],
    );
  }

  /// `Gate status: `
  String get fortificationGateStatusColon {
    return Intl.message(
      'Gate status: ',
      name: 'fortificationGateStatusColon',
      desc: '',
      args: [],
    );
  }

  /// `open`
  String get open {
    return Intl.message(
      'open',
      name: 'open',
      desc: '',
      args: [],
    );
  }

  /// `closed`
  String get closed {
    return Intl.message(
      'closed',
      name: 'closed',
      desc: '',
      args: [],
    );
  }

  /// `Open the gate`
  String get openGates {
    return Intl.message(
      'Open the gate',
      name: 'openGates',
      desc: '',
      args: [],
    );
  }

  /// `Close the gate`
  String get closeGates {
    return Intl.message(
      'Close the gate',
      name: 'closeGates',
      desc: '',
      args: [],
    );
  }

  /// `gate`
  String get gate {
    return Intl.message(
      'gate',
      name: 'gate',
      desc: '',
      args: [],
    );
  }

  /// `wall`
  String get wall {
    return Intl.message(
      'wall',
      name: 'wall',
      desc: '',
      args: [],
    );
  }

  /// `tower`
  String get tower {
    return Intl.message(
      'tower',
      name: 'tower',
      desc: '',
      args: [],
    );
  }

  /// `hill`
  String get hill {
    return Intl.message(
      'hill',
      name: 'hill',
      desc: '',
      args: [],
    );
  }

  /// `mountain`
  String get mountain {
    return Intl.message(
      'mountain',
      name: 'mountain',
      desc: '',
      args: [],
    );
  }

  /// `building`
  String get building {
    return Intl.message(
      'building',
      name: 'building',
      desc: '',
      args: [],
    );
  }

  /// `forest`
  String get forest {
    return Intl.message(
      'forest',
      name: 'forest',
      desc: '',
      args: [],
    );
  }

  /// `road`
  String get road {
    return Intl.message(
      'road',
      name: 'road',
      desc: '',
      args: [],
    );
  }

  /// `Mode: `
  String get armyModeColon {
    return Intl.message(
      'Mode: ',
      name: 'armyModeColon',
      desc: '',
      args: [],
    );
  }

  /// `Fighter`
  String get fighterMode {
    return Intl.message(
      'Fighter',
      name: 'fighterMode',
      desc: '',
      args: [],
    );
  }

  /// `Defender`
  String get defenderMode {
    return Intl.message(
      'Defender',
      name: 'defenderMode',
      desc: '',
      args: [],
    );
  }

  /// `Raider`
  String get raiderMode {
    return Intl.message(
      'Raider',
      name: 'raiderMode',
      desc: '',
      args: [],
    );
  }

  /// `Tax Collector`
  String get taxCollectorMode {
    return Intl.message(
      'Tax Collector',
      name: 'taxCollectorMode',
      desc: '',
      args: [],
    );
  }

  /// `Recruiter`
  String get recruiterMode {
    return Intl.message(
      'Recruiter',
      name: 'recruiterMode',
      desc: '',
      args: [],
    );
  }

  /// `Random`
  String get randomNation {
    return Intl.message(
      'Random',
      name: 'randomNation',
      desc: '',
      args: [],
    );
  }

  /// `At war with: `
  String get atWarWithColon {
    return Intl.message(
      'At war with: ',
      name: 'atWarWithColon',
      desc: '',
      args: [],
    );
  }

  /// `Allied with: `
  String get alliedWithColon {
    return Intl.message(
      'Allied with: ',
      name: 'alliedWithColon',
      desc: '',
      args: [],
    );
  }

  /// `At peace with: `
  String get atPeaceWithColon {
    return Intl.message(
      'At peace with: ',
      name: 'atPeaceWithColon',
      desc: '',
      args: [],
    );
  }

  /// `Set Settings:`
  String get setSettingsColon {
    return Intl.message(
      'Set Settings:',
      name: 'setSettingsColon',
      desc: '',
      args: [],
    );
  }

  /// `Custom Campaign Settings`
  String get customCampaignSettings {
    return Intl.message(
      'Custom Campaign Settings',
      name: 'customCampaignSettings',
      desc: '',
      args: [],
    );
  }

  /// `Play a Random Battle`
  String get randomBattle {
    return Intl.message(
      'Play a Random Battle',
      name: 'randomBattle',
      desc: '',
      args: [],
    );
  }

  /// `All to Attack Stance`
  String get allAttack {
    return Intl.message(
      'All to Attack Stance',
      name: 'allAttack',
      desc: '',
      args: [],
    );
  }

  /// `Set all units to Attack Stance`
  String get allAttackExplain {
    return Intl.message(
      'Set all units to Attack Stance',
      name: 'allAttackExplain',
      desc: '',
      args: [],
    );
  }

  /// `All to Defend Stance`
  String get allDefend {
    return Intl.message(
      'All to Defend Stance',
      name: 'allDefend',
      desc: '',
      args: [],
    );
  }

  /// `Set all units to Defend Stance`
  String get allDefendExplain {
    return Intl.message(
      'Set all units to Defend Stance',
      name: 'allDefendExplain',
      desc: '',
      args: [],
    );
  }

  /// `Cancel All Orders`
  String get allCancel {
    return Intl.message(
      'Cancel All Orders',
      name: 'allCancel',
      desc: '',
      args: [],
    );
  }

  /// `Cancel move orders for all units`
  String get allCancelExplain {
    return Intl.message(
      'Cancel move orders for all units',
      name: 'allCancelExplain',
      desc: '',
      args: [],
    );
  }

  /// `Open Diplomacy`
  String get showDiplomacy {
    return Intl.message(
      'Open Diplomacy',
      name: 'showDiplomacy',
      desc: '',
      args: [],
    );
  }

  /// `Open the Diplomacy Menu`
  String get showDiplomacyExplain {
    return Intl.message(
      'Open the Diplomacy Menu',
      name: 'showDiplomacyExplain',
      desc: '',
      args: [],
    );
  }

  /// `Confirm`
  String get confirm {
    return Intl.message(
      'Confirm',
      name: 'confirm',
      desc: '',
      args: [],
    );
  }

  /// `Cancel`
  String get cancel {
    return Intl.message(
      'Cancel',
      name: 'cancel',
      desc: '',
      args: [],
    );
  }

  /// `Acknowledge`
  String get ok {
    return Intl.message(
      'Acknowledge',
      name: 'ok',
      desc: '',
      args: [],
    );
  }

  /// `Back`
  String get back {
    return Intl.message(
      'Back',
      name: 'back',
      desc: '',
      args: [],
    );
  }

  /// `Next`
  String get next {
    return Intl.message(
      'Next',
      name: 'next',
      desc: '',
      args: [],
    );
  }

  /// `Help`
  String get help {
    return Intl.message(
      'Help',
      name: 'help',
      desc: '',
      args: [],
    );
  }

  /// `Close`
  String get close {
    return Intl.message(
      'Close',
      name: 'close',
      desc: '',
      args: [],
    );
  }

  /// `Don't show this again`
  String get dontShowThisAgain {
    return Intl.message(
      'Don\'t show this again',
      name: 'dontShowThisAgain',
      desc: '',
      args: [],
    );
  }

  /// `The game is paused and you can issue your orders now. Press the hourglass once you are done.`
  String get gamePaused {
    return Intl.message(
      'The game is paused and you can issue your orders now. Press the hourglass once you are done.',
      name: 'gamePaused',
      desc: '',
      args: [],
    );
  }

  /// `{nation} agreed to your peace offer.`
  String otherNationAgreedToPeace(Object nation) {
    return Intl.message(
      '$nation agreed to your peace offer.',
      name: 'otherNationAgreedToPeace',
      desc: '',
      args: [nation],
    );
  }

  /// `Peace offer sent`
  String get peaceOfferSent {
    return Intl.message(
      'Peace offer sent',
      name: 'peaceOfferSent',
      desc: '',
      args: [],
    );
  }

  /// `{nation} will respond by next season`
  String peaceOfferSentExplain(Object nation) {
    return Intl.message(
      '$nation will respond by next season',
      name: 'peaceOfferSentExplain',
      desc: '',
      args: [nation],
    );
  }

  /// `{nation} rejected your peace offer.`
  String otherNationRejectedPeace(Object nation) {
    return Intl.message(
      '$nation rejected your peace offer.',
      name: 'otherNationRejectedPeace',
      desc: '',
      args: [nation],
    );
  }

  /// `Manage armies in {province}`
  String armyManagementInProvince(Object province) {
    return Intl.message(
      'Manage armies in $province',
      name: 'armyManagementInProvince',
      desc: '',
      args: [province],
    );
  }

  /// `Drag army headers to merge armies or drag units to move them between armies. `
  String get armyManagementExplain {
    return Intl.message(
      'Drag army headers to merge armies or drag units to move them between armies. ',
      name: 'armyManagementExplain',
      desc: '',
      args: [],
    );
  }

  /// `Drop here to merge these two armies`
  String get mergeArmies {
    return Intl.message(
      'Drop here to merge these two armies',
      name: 'mergeArmies',
      desc: '',
      args: [],
    );
  }

  /// `Commander: `
  String get commanderColon {
    return Intl.message(
      'Commander: ',
      name: 'commanderColon',
      desc: '',
      args: [],
    );
  }

  /// `Morale boost: `
  String get commanderMoraleBoost {
    return Intl.message(
      'Morale boost: ',
      name: 'commanderMoraleBoost',
      desc: '',
      args: [],
    );
  }

  /// `Attrition factor: `
  String get commanderAttritionBoost {
    return Intl.message(
      'Attrition factor: ',
      name: 'commanderAttritionBoost',
      desc: '',
      args: [],
    );
  }

  /// `Melee skill: `
  String get commanderMeleeSkill {
    return Intl.message(
      'Melee skill: ',
      name: 'commanderMeleeSkill',
      desc: '',
      args: [],
    );
  }

  /// `Ranged skill: `
  String get commanderRangedSkill {
    return Intl.message(
      'Ranged skill: ',
      name: 'commanderRangedSkill',
      desc: '',
      args: [],
    );
  }

  /// `Max army size exceeded`
  String get armySizeExceeded {
    return Intl.message(
      'Max army size exceeded',
      name: 'armySizeExceeded',
      desc: '',
      args: [],
    );
  }

  /// `Armies cannot exceed {sizeLimit} fighting units.`
  String armySizeExceededExplanation(Object sizeLimit) {
    return Intl.message(
      'Armies cannot exceed $sizeLimit fighting units.',
      name: 'armySizeExceededExplanation',
      desc: '',
      args: [sizeLimit],
    );
  }

  /// `Name`
  String get name {
    return Intl.message(
      'Name',
      name: 'name',
      desc: '',
      args: [],
    );
  }

  /// `Cost in gold`
  String get cost {
    return Intl.message(
      'Cost in gold',
      name: 'cost',
      desc: '',
      args: [],
    );
  }

  /// `units`
  String get units {
    return Intl.message(
      'units',
      name: 'units',
      desc: '',
      args: [],
    );
  }

  /// `Gold available in province and local armies: `
  String get goldAvailableColon {
    return Intl.message(
      'Gold available in province and local armies: ',
      name: 'goldAvailableColon',
      desc: '',
      args: [],
    );
  }

  /// `This province has already trained a unit this season.`
  String get alreadyTrainedThisTurn {
    return Intl.message(
      'This province has already trained a unit this season.',
      name: 'alreadyTrainedThisTurn',
      desc: '',
      args: [],
    );
  }

  /// `Province needs at least {minPopNumber} in population to train a unit. `
  String notEnoughPops(Object minPopNumber) {
    return Intl.message(
      'Province needs at least $minPopNumber in population to train a unit. ',
      name: 'notEnoughPops',
      desc: '',
      args: [minPopNumber],
    );
  }

  /// `Drop a unit here to create a new army. `
  String get dropToCreateANewArmy {
    return Intl.message(
      'Drop a unit here to create a new army. ',
      name: 'dropToCreateANewArmy',
      desc: '',
      args: [],
    );
  }

  /// `Fast forward`
  String get fastForward {
    return Intl.message(
      'Fast forward',
      name: 'fastForward',
      desc: '',
      args: [],
    );
  }

  /// `Automatically skip turns to let the tactical AI handle the battle`
  String get fastForwardExplain {
    return Intl.message(
      'Automatically skip turns to let the tactical AI handle the battle',
      name: 'fastForwardExplain',
      desc: '',
      args: [],
    );
  }

  /// `Battle Sandbox`
  String get battleSandbox {
    return Intl.message(
      'Battle Sandbox',
      name: 'battleSandbox',
      desc: '',
      args: [],
    );
  }

  /// `Gameplay & Programming`
  String get gameplayAndProgramming {
    return Intl.message(
      'Gameplay & Programming',
      name: 'gameplayAndProgramming',
      desc: '',
      args: [],
    );
  }

  /// `Programming`
  String get programming {
    return Intl.message(
      'Programming',
      name: 'programming',
      desc: '',
      args: [],
    );
  }

  /// `Art`
  String get art {
    return Intl.message(
      'Art',
      name: 'art',
      desc: '',
      args: [],
    );
  }

  /// `Art Consulting`
  String get artConsulting {
    return Intl.message(
      'Art Consulting',
      name: 'artConsulting',
      desc: '',
      args: [],
    );
  }

  /// `Icons`
  String get icons {
    return Intl.message(
      'Icons',
      name: 'icons',
      desc: '',
      args: [],
    );
  }

  /// `Sound Effects`
  String get soundEffects {
    return Intl.message(
      'Sound Effects',
      name: 'soundEffects',
      desc: '',
      args: [],
    );
  }

  /// `Music`
  String get music {
    return Intl.message(
      'Music',
      name: 'music',
      desc: '',
      args: [],
    );
  }

  /// `© Palm 83 Pte Ltd {year}, All rights reserved`
  String copyright(Object year) {
    return Intl.message(
      '© Palm 83 Pte Ltd $year, All rights reserved',
      name: 'copyright',
      desc: '',
      args: [year],
    );
  }

  /// `license`
  String get license {
    return Intl.message(
      'license',
      name: 'license',
      desc: '',
      args: [],
    );
  }

  /// `Other licences`
  String get otherLicences {
    return Intl.message(
      'Other licences',
      name: 'otherLicences',
      desc: '',
      args: [],
    );
  }

  /// `Tap to view`
  String get tapToView {
    return Intl.message(
      'Tap to view',
      name: 'tapToView',
      desc: '',
      args: [],
    );
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en', countryCode: 'GB'),
      Locale.fromSubtags(languageCode: 'en'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<S> load(Locale locale) => S.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}
