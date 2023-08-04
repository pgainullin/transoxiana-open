// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a en_GB locale. All the
// messages from the main program should be duplicated here with the same
// function name.

// Ignore issues from commonly used lints in this file.
// ignore_for_file:unnecessary_brace_in_string_interps, unnecessary_new
// ignore_for_file:prefer_single_quotes,comment_references, directives_ordering
// ignore_for_file:annotate_overrides,prefer_generic_function_type_aliases
// ignore_for_file:unused_import, file_names, avoid_escaping_inner_quotes
// ignore_for_file:unnecessary_string_interpolations, unnecessary_string_escapes

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = new MessageLookup();

typedef String MessageIfAbsent(String messageStr, List<dynamic> args);

class MessageLookup extends MessageLookupByLibrary {
  String get localeName => 'en_GB';

  static String m0(province) => "Spies report on a battle in ${province}...";

  static String m1(active, total) => "army ${active} of ${total}";

  static String m2(error) => "Army info retrieval error ${error}";

  static String m3(province) => "Manage armies in ${province}";

  static String m4(sizeLimit) =>
      "Armies cannot exceed ${sizeLimit} fighting units.";

  static String m5(strength, reach) => "${strength} x ${reach} tiles";

  static String m6(province) =>
      "What shall the army do on arrival to ${province}?";

  static String m7(province, year) => "Battle of ${province} ${year}";

  static String m8(nation) => "${nation} has won the campaign";

  static String m9(unit) => "Change destination for ${unit}";

  static String m10(nation) =>
      "Are you sure you want to declare war on ${nation}?";

  static String m11(year) => "© Palm 83 Pte Ltd ${year}, All rights reserved";

  static String m12(error) => "Game data retrieval error ${error}";

  static String m13(
          killerNation, killerUnit, killedNation, killedUnit, location) =>
      "${killerNation}\'s ${killerUnit} killed ${killedNation}\'s ${killedUnit} in hand-to-hand combat ${location}";

  static String m14(
          killerNation, killerUnit, killedNation, killedUnit, location) =>
      "${killerNation}\'s ${killerUnit} was killed by ${killedNation}\'s ${killedUnit} in hand-to-hand combat ${location}";

  static String m15(
          killerNation, killerUnit, killedNation, killedUnit, location) =>
      "${killerNation}\'s ${killerUnit} killed ${killedNation}\'s ${killedUnit} by shooting them ${location}";

  static String m16(
          killerNation, killerUnit, killedNation, killedUnit, location) =>
      "${killerNation}\'s ${killerUnit} killed ${killedNation}\'s ${killedUnit} by spearing them ${location}";

  static String m17(minPopNumber) =>
      "Province needs at least ${minPopNumber} in population to train a unit. ";

  static String m18(nation) => "${nation} accepted your peace offer.";

  static String m19(nation) => "${nation} agreed to your peace offer.";

  static String m20(nation) => "${nation} has just declared war on you!";

  static String m21(nation) => "${nation} offers peace. Do you agree?";

  static String m22(nation) => "${nation} rejected your peace offer.";

  static String m23(nation) => "${nation} will respond by next season";

  static String m24(province) => "Choose what to do with ${province}";

  static String m25(province, nation) => "${province} taken by ${nation}";

  static String m26(error) => "Province info retrieval error ${error}";

  static String m27(stored, capacity) => "${stored}/${capacity}";

  static String m28(season, year) => "${season} ${year}";

  static String m29(province) => "Siege in ${province}";

  static String m30(nation, province) =>
      "${nation} have taken ${province} by siege as starving defenders scatter";

  static String m31(x, y) => "${x}:${y}";

  static String m32(error) => "Tile info retrieval error ${error}";

  static String m33(error) => "Unit info retrieval error ${error}";

  static String m34(nation) => "${nation} has won the battle";

  static String m35(nation) => "You are playing ${nation}";

  static String m36(nation) => "We are now at war with ${nation}!";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
        "actionsColon": MessageLookupByLibrary.simpleMessage("Actions:"),
        "aiBattleInProvince": m0,
        "allAttack":
            MessageLookupByLibrary.simpleMessage("All to Attack Stance"),
        "allAttackExplain": MessageLookupByLibrary.simpleMessage(
            "Set all units to Attack Stance"),
        "allCancel": MessageLookupByLibrary.simpleMessage("Cancel All Orders"),
        "allCancelExplain": MessageLookupByLibrary.simpleMessage(
            "Cancel move orders for all units"),
        "allDefend":
            MessageLookupByLibrary.simpleMessage("All to Defend Stance"),
        "allDefendExplain": MessageLookupByLibrary.simpleMessage(
            "Set all units to Defend Stance"),
        "alliedWithColon":
            MessageLookupByLibrary.simpleMessage("Allied with: "),
        "alreadyTaxed": MessageLookupByLibrary.simpleMessage(
            "Province has been taxed this season"),
        "alreadyTrainedThisTurn": MessageLookupByLibrary.simpleMessage(
            "This province has already trained a unit this season."),
        "armyCounter": m1,
        "armyDataError": m2,
        "armyManagementExplain": MessageLookupByLibrary.simpleMessage(
            "Drag army headers to merge armies or drag units to move them between armies. "),
        "armyManagementInProvince": m3,
        "armyModeColon": MessageLookupByLibrary.simpleMessage("Mode: "),
        "armySizeExceeded":
            MessageLookupByLibrary.simpleMessage("Max army size exceeded"),
        "armySizeExceededExplanation": m4,
        "art": MessageLookupByLibrary.simpleMessage("Art"),
        "artConsulting": MessageLookupByLibrary.simpleMessage("Art Consulting"),
        "assaultSiegeOption": MessageLookupByLibrary.simpleMessage("Assault"),
        "atPeaceWithColon":
            MessageLookupByLibrary.simpleMessage("At peace with: "),
        "atWarWithColon": MessageLookupByLibrary.simpleMessage("At war with: "),
        "attack": MessageLookupByLibrary.simpleMessage("Attack"),
        "attackTooltipContent": MessageLookupByLibrary.simpleMessage(
            "Set stance to Attach (advance to engage nearby targets)"),
        "attackValue": m5,
        "attackingFortAssault": MessageLookupByLibrary.simpleMessage("Assault"),
        "attackingFortBesiege": MessageLookupByLibrary.simpleMessage("Besiege"),
        "attackingFortContent": m6,
        "attackingFortTitle":
            MessageLookupByLibrary.simpleMessage("Attacking a fortified city"),
        "back": MessageLookupByLibrary.simpleMessage("Back"),
        "battleOfProvince": m7,
        "battleSandbox": MessageLookupByLibrary.simpleMessage("Battle Sandbox"),
        "bombard": MessageLookupByLibrary.simpleMessage("Bombard"),
        "bombardTooltipContent": MessageLookupByLibrary.simpleMessage(
            "Set stance to Bombard (stand ground + attack walls in range)"),
        "building": MessageLookupByLibrary.simpleMessage("building"),
        "campaignMenu": MessageLookupByLibrary.simpleMessage("Campaign menu"),
        "campaignMenuTooltipContent":
            MessageLookupByLibrary.simpleMessage("Open campaign menu"),
        "campaignVictoryDialogueContent": m8,
        "cancel": MessageLookupByLibrary.simpleMessage("Cancel"),
        "capacityColon": MessageLookupByLibrary.simpleMessage("Capacity: "),
        "changeDestinationDialogueContent":
            MessageLookupByLibrary.simpleMessage(
                "Are you sure you want to change this unit\'s orders?"),
        "changeDestinationDialogueTitle": m9,
        "clearOrders": MessageLookupByLibrary.simpleMessage("Clear orders"),
        "clearOrdersTooltipContent":
            MessageLookupByLibrary.simpleMessage("Clear orders move orders"),
        "close": MessageLookupByLibrary.simpleMessage("Close"),
        "closeGates": MessageLookupByLibrary.simpleMessage("Close the gate"),
        "closed": MessageLookupByLibrary.simpleMessage("closed"),
        "commanderAttritionBoost":
            MessageLookupByLibrary.simpleMessage("Attrition factor: "),
        "commanderColon": MessageLookupByLibrary.simpleMessage("Commander: "),
        "commanderMeleeSkill":
            MessageLookupByLibrary.simpleMessage("Melee skill: "),
        "commanderMoraleBoost":
            MessageLookupByLibrary.simpleMessage("Morale boost: "),
        "commanderRangedSkill":
            MessageLookupByLibrary.simpleMessage("Ranged skill: "),
        "confirm": MessageLookupByLibrary.simpleMessage("Confirm"),
        "confirmRestartDialogueContent": MessageLookupByLibrary.simpleMessage(
            "Are you sure you want to restart the game? All progress will be lost."),
        "confirmRestartDialogueTitle":
            MessageLookupByLibrary.simpleMessage("Confirm restart"),
        "confirmSurrenderDialogueContent": MessageLookupByLibrary.simpleMessage(
            "Are you sure you want to surrender the battle?"),
        "confirmSurrenderDialogueTitle":
            MessageLookupByLibrary.simpleMessage("Confirm surrender"),
        "confirmWarDeclarationContent": m10,
        "confirmWarDeclarationTitle":
            MessageLookupByLibrary.simpleMessage("Confirm war declaration"),
        "continueCampaign": MessageLookupByLibrary.simpleMessage("Continue"),
        "continueSiegeOption":
            MessageLookupByLibrary.simpleMessage("Continue the siege"),
        "copyright": m11,
        "cost": MessageLookupByLibrary.simpleMessage("Cost in gold"),
        "credits": MessageLookupByLibrary.simpleMessage("Credits"),
        "customCampaignSettings":
            MessageLookupByLibrary.simpleMessage("Custom Campaign Settings"),
        "defeatDialogueTitle": MessageLookupByLibrary.simpleMessage("Defeat!"),
        "defend": MessageLookupByLibrary.simpleMessage("Defend"),
        "defendTooltipContent": MessageLookupByLibrary.simpleMessage(
            "Set stance to Defend (stand ground)"),
        "defenderMode": MessageLookupByLibrary.simpleMessage("Defender"),
        "destinationColon":
            MessageLookupByLibrary.simpleMessage("Destination: "),
        "dontShowThisAgain":
            MessageLookupByLibrary.simpleMessage("Don\'t show this again"),
        "dropToCreateANewArmy": MessageLookupByLibrary.simpleMessage(
            "Drop a unit here to create a new army. "),
        "endTurn": MessageLookupByLibrary.simpleMessage("End Turn"),
        "endTurnBattleTooltipContent": MessageLookupByLibrary.simpleMessage(
            "End turn and let units implement your orders."),
        "endTurnCampaignTooltipContent": MessageLookupByLibrary.simpleMessage(
            "End turn and let armies implement your orders."),
        "event": MessageLookupByLibrary.simpleMessage("Event"),
        "fastForward": MessageLookupByLibrary.simpleMessage("Fast forward"),
        "fastForwardExplain": MessageLookupByLibrary.simpleMessage(
            "Automatically skip turns to let the tactical AI handle the battle"),
        "featureColon": MessageLookupByLibrary.simpleMessage("Feature: "),
        "fighterMode": MessageLookupByLibrary.simpleMessage("Fighter"),
        "forest": MessageLookupByLibrary.simpleMessage("forest"),
        "fortIntegrityColon":
            MessageLookupByLibrary.simpleMessage("Fort integrity: "),
        "fortificationColon":
            MessageLookupByLibrary.simpleMessage("Fortification: "),
        "fortificationGateStatusColon":
            MessageLookupByLibrary.simpleMessage("Gate status: "),
        "fortificationIntegrityColon":
            MessageLookupByLibrary.simpleMessage("Fortification integrity: "),
        "gameDataError": m12,
        "gamePaused": MessageLookupByLibrary.simpleMessage(
            "The game is paused and you can issue your orders now. Press the hourglass once you are done."),
        "gameplayAndProgramming":
            MessageLookupByLibrary.simpleMessage("Gameplay & Programming"),
        "gate": MessageLookupByLibrary.simpleMessage("gate"),
        "goldAvailableColon": MessageLookupByLibrary.simpleMessage(
            "Gold available in province and local armies: "),
        "goldCarriedColon":
            MessageLookupByLibrary.simpleMessage("Gold carried: "),
        "goldSort": MessageLookupByLibrary.simpleMessage("Gold controlled"),
        "goldStoredColon":
            MessageLookupByLibrary.simpleMessage("Gold stored: "),
        "groundColon": MessageLookupByLibrary.simpleMessage("Ground: "),
        "help": MessageLookupByLibrary.simpleMessage("Help"),
        "hill": MessageLookupByLibrary.simpleMessage("hill"),
        "icons": MessageLookupByLibrary.simpleMessage("Icons"),
        "idle": MessageLookupByLibrary.simpleMessage("idle"),
        "license": MessageLookupByLibrary.simpleMessage("license"),
        "loadGameDialogueContent": MessageLookupByLibrary.simpleMessage(
            "Are you sure you want to abandon your current game?"),
        "loadGameDialogueTitle":
            MessageLookupByLibrary.simpleMessage("Load game"),
        "loading": MessageLookupByLibrary.simpleMessage("Loading..."),
        "logEmpty":
            MessageLookupByLibrary.simpleMessage("No messages in chronicle"),
        "logMeleeAttackKill": m13,
        "logMeleeDefenceKill": m14,
        "logRangedKill": m15,
        "logSpearKill": m16,
        "mainMenu": MessageLookupByLibrary.simpleMessage("Main Menu"),
        "mainMenuTooltipContent":
            MessageLookupByLibrary.simpleMessage("Open Main Menu"),
        "meleeColon": MessageLookupByLibrary.simpleMessage("Melee: "),
        "mergeArmies": MessageLookupByLibrary.simpleMessage(
            "Drop here to merge these two armies"),
        "momentumColon": MessageLookupByLibrary.simpleMessage("Momentum: "),
        "mountain": MessageLookupByLibrary.simpleMessage("mountain"),
        "music": MessageLookupByLibrary.simpleMessage("Music"),
        "name": MessageLookupByLibrary.simpleMessage("Name"),
        "nation": MessageLookupByLibrary.simpleMessage("Nation"),
        "nationColon": MessageLookupByLibrary.simpleMessage("Nation: "),
        "next": MessageLookupByLibrary.simpleMessage("Next"),
        "nextArmy": MessageLookupByLibrary.simpleMessage("Next army"),
        "nextArmyTooltipContent": MessageLookupByLibrary.simpleMessage(
            "Select the next army in the province"),
        "nextProvinceColon":
            MessageLookupByLibrary.simpleMessage("Next province: "),
        "noArmy": MessageLookupByLibrary.simpleMessage("No army selected"),
        "noProvince":
            MessageLookupByLibrary.simpleMessage("No province selected"),
        "noTile": MessageLookupByLibrary.simpleMessage("No tile selected"),
        "noUnit": MessageLookupByLibrary.simpleMessage("No unit selected"),
        "noUnitsToTrain":
            MessageLookupByLibrary.simpleMessage("No trainable units"),
        "none": MessageLookupByLibrary.simpleMessage("none"),
        "notEnoughPops": m17,
        "notSet": MessageLookupByLibrary.simpleMessage("not set"),
        "ok": MessageLookupByLibrary.simpleMessage("Acknowledge"),
        "open": MessageLookupByLibrary.simpleMessage("open"),
        "openGates": MessageLookupByLibrary.simpleMessage("Open the gate"),
        "otherLicences": MessageLookupByLibrary.simpleMessage("Other licences"),
        "otherNationAcceptsPeace": m18,
        "otherNationAgreedToPeace": m19,
        "otherNationDeclaredWarOnYou": m20,
        "otherNationOffersPeace": m21,
        "otherNationRejectedPeace": m22,
        "peaceOfferSent":
            MessageLookupByLibrary.simpleMessage("Peace offer sent"),
        "peaceOfferSentExplain": m23,
        "percent": MessageLookupByLibrary.simpleMessage("%"),
        "populationColon": MessageLookupByLibrary.simpleMessage("Population: "),
        "populationSort": MessageLookupByLibrary.simpleMessage("Population"),
        "previousArmy": MessageLookupByLibrary.simpleMessage("Previous army"),
        "previousArmyTooltipContent": MessageLookupByLibrary.simpleMessage(
            "Select the previous army in the province"),
        "programming": MessageLookupByLibrary.simpleMessage("Programming"),
        "progressColon": MessageLookupByLibrary.simpleMessage("Progress: "),
        "provinceCaptureDialogueAnnex":
            MessageLookupByLibrary.simpleMessage("Annex"),
        "provinceCaptureDialogueContent": m24,
        "provinceCaptureDialogueSack":
            MessageLookupByLibrary.simpleMessage("Sack"),
        "provinceCaptureDialogueTitle": m25,
        "provinceColon": MessageLookupByLibrary.simpleMessage("Province: "),
        "provinceDataError": m26,
        "provisionsColon": MessageLookupByLibrary.simpleMessage("Provisions: "),
        "provisionsValue": m27,
        "quickLoad": MessageLookupByLibrary.simpleMessage("Quick load"),
        "quickSave": MessageLookupByLibrary.simpleMessage("Quick save"),
        "raiderMode": MessageLookupByLibrary.simpleMessage("Raider"),
        "randomBattle":
            MessageLookupByLibrary.simpleMessage("Play a Random Battle"),
        "randomNation": MessageLookupByLibrary.simpleMessage("Random"),
        "rangedColon": MessageLookupByLibrary.simpleMessage("Ranged: "),
        "recruiterMode": MessageLookupByLibrary.simpleMessage("Recruiter"),
        "restartConfirmButton":
            MessageLookupByLibrary.simpleMessage("Restart the game"),
        "road": MessageLookupByLibrary.simpleMessage("road"),
        "saveGameDialogueContent": MessageLookupByLibrary.simpleMessage(
            "Are you sure you want to overwrite your previous quick save?"),
        "saveGameDialogueTitle":
            MessageLookupByLibrary.simpleMessage("Save game"),
        "savedGames": MessageLookupByLibrary.simpleMessage("Saved Games"),
        "seasonAutumn": MessageLookupByLibrary.simpleMessage("Autumn"),
        "seasonSpring": MessageLookupByLibrary.simpleMessage("Spring"),
        "seasonSummer": MessageLookupByLibrary.simpleMessage("Summer"),
        "seasonWinter": MessageLookupByLibrary.simpleMessage("Winter"),
        "seasonYear": m28,
        "setSettingsColon":
            MessageLookupByLibrary.simpleMessage("Set Settings:"),
        "showDiplomacy": MessageLookupByLibrary.simpleMessage("Open Diplomacy"),
        "showDiplomacyExplain":
            MessageLookupByLibrary.simpleMessage("Open the Diplomacy Menu"),
        "siegeBehaviour":
            MessageLookupByLibrary.simpleMessage("Siege behaviour: "),
        "siegeBehaviourSiege": MessageLookupByLibrary.simpleMessage("Siege"),
        "siegeContinueDialogueContent": MessageLookupByLibrary.simpleMessage(
            "Do you want to continue the siege?"),
        "siegeContinueDialogueTitle": m29,
        "siegeSuccessfulContent": m30,
        "siegeSuccessfulTitle":
            MessageLookupByLibrary.simpleMessage("Besieged province captured"),
        "soundEffects": MessageLookupByLibrary.simpleMessage("Sound Effects"),
        "speedColon": MessageLookupByLibrary.simpleMessage("Speed: "),
        "startCampaign":
            MessageLookupByLibrary.simpleMessage("Start the Campaign"),
        "surrender": MessageLookupByLibrary.simpleMessage("Surrender"),
        "surrenderTooltipContent": MessageLookupByLibrary.simpleMessage(
            "Surrender the battle to save your generals (armies will be lost)."),
        "tapToView": MessageLookupByLibrary.simpleMessage("Tap to view"),
        "taxButton": MessageLookupByLibrary.simpleMessage("Tax this Province"),
        "taxCollectorMode":
            MessageLookupByLibrary.simpleMessage("Tax Collector"),
        "tileCoordinates": m31,
        "tileDataError": m32,
        "tileHeading": MessageLookupByLibrary.simpleMessage("Tile "),
        "tiles": MessageLookupByLibrary.simpleMessage("tiles"),
        "tower": MessageLookupByLibrary.simpleMessage("tower"),
        "trainUnit": MessageLookupByLibrary.simpleMessage("Train a unit"),
        "unitCountSort":
            MessageLookupByLibrary.simpleMessage("Units controlled"),
        "unitDataError": m33,
        "units": MessageLookupByLibrary.simpleMessage("units"),
        "unitsColon": MessageLookupByLibrary.simpleMessage("Units: "),
        "victoryDialogueContent": m34,
        "victoryDialogueTitle":
            MessageLookupByLibrary.simpleMessage("Victory!"),
        "waitTurn": MessageLookupByLibrary.simpleMessage("Wait for your turn"),
        "wall": MessageLookupByLibrary.simpleMessage("wall"),
        "youArePlaying": m35,
        "youDeclareWarOnOtherNation": m36,
        "yourTurn": MessageLookupByLibrary.simpleMessage("It\'s your turn"),
        "zoomIn": MessageLookupByLibrary.simpleMessage("Zoom in"),
        "zoomInTooltipContent": MessageLookupByLibrary.simpleMessage("Zoom in"),
        "zoomOut": MessageLookupByLibrary.simpleMessage("Zoom out"),
        "zoomOutTooltipContent":
            MessageLookupByLibrary.simpleMessage("Zoom out")
      };
}
