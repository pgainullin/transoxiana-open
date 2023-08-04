part of 'events.dart';

///
///
/// New types should only be added at the bottom of each enum
/// to preserve serialized events.
///
///

enum EventConditionType {
  soleSurvivor,
  captureNations,
  captureProvinces,
  killArmies,
  composedConditionAND,
  alwaysFalse,
  alwaysTrue,
  dateIsOrAfter, //unimplemented
  dateIsOrBefore, //unimplemented
  dateIs, //unimplemented
  composedConditionOR,
  campaignStart,
  battleStart,
  battleSelectPlayerUnit,
  campaignSelectPlayerArmy,
  composedConditionNOT,
}

enum EventConsequenceType {
  victory,
  defeat,
  dialogue,
  composedConsequenceOR, //player choice to be implemented
  composedConsequenceAND,
  declareWar,
  annex,
  peaceOffer,
  fortifiedBattleStarted,
  nonFortifiedBattleStarted,
  battlePlayerUnitSelected,
  campaignPlayerArmySelected,
  campaignStarted,
  handoverProvinces,
  handoverArmies,
  // tutorialBattleSelectPlayerUnit,
  // tutorialBattleIntro,
  // tutorialBattleInFortIntro,
  // tutorialCampaignSelectPlayerArmy,
  // campaignIntro,
}
//province, army, gold, provisions, diplomatic relations

enum EventTriggerType {
  startTurn,
  endTurn,
  selection,
}
