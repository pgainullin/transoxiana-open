import 'package:equatable/equatable.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:transoxiana/data/season.dart';
import 'package:transoxiana/data/unit_types.dart';

const double frameDuration = 1.0 / 60.0;

// CAMPAIGN MAP
///conversion of battle speed to campaign map speed
const double travelSpeedFactor = 50.0;
const int armyUnitLimit = 10;
const int defaultCampaignStartYear = 1200;
const Season defaultCampaignStartSeason = Season.summer;

// STRATEGIC AI
///how many more attackers vs defenders does there need to be
///for the AI to choose assault
const double strategicAiSiegeNumericAdvantageFactor = 1.5;

/// if AI has more units than a neighbour by this factor it will declare war
const double aiUnitAdvantageWarThreshold = 2.0;

/// if AI has fewer units than a neighbour by this factor it will sue for peace
const double aiUnitDisadvantagePeaceThreshold = 1.5;

// SCALING
const double mapImageBaseScale = 4.0;
const double inverseMapImageBaseScale = 1 / mapImageBaseScale;

/// factor scaling the unit sprites when rendered on the campaign map
const double unitSpriteCampaignScale = 0.5;

const double unitSpriteWidthOriginal = 434.0;
const double unitSpriteWidthScaled = 64.0;
const double unitSpriteHeightOriginal = 664.0;
const double unitSpriteHeightScaled = 48.0;
const double unitSpriteScaleWithDirections = 0.095;

// WALLS
enum WallsDamageLevel {
  undamaged,
  light,
  severe,
  destroyed,
}

const Map<WallsDamageLevel, String> wallsSpriteSource = {
  WallsDamageLevel.undamaged: 'walls/walls_dmg_0.png',
  WallsDamageLevel.light: 'walls/walls_dmg_1.png',
  WallsDamageLevel.severe: 'walls/walls_dmg_2.png',
  WallsDamageLevel.destroyed: 'walls/walls_dmg_3.png',
};

final Vector2 wallTileSize = Vector2(474, 411);

const double wallsMaxLife = 100.0;

/// how many times the width of the sprite will the marker center be offset
/// down from the center of the sprite
const double armyMarkerVerticalOffsetFactor = 1.0 / 4.0;

/// width of the marker divided by width of the sprite
const double armyMarkerSizeFactor = 1.0 / 1.5;

// MELEE COMBAT
// changed to 2 from 12 to accommodate the new approach to attack
// with attacks not occurring on every update
// and instead six attacks per turn
const double meleeDamageFactor = 2.1;

///what % of regular melee damage is dealt when defending against a melee strike
const double defensiveMeleeDamageFactor = 0.5;
const double spearDamageFactor = 2.3;

/// number of melee attacks in a turn, set to 6 for all units for now
const double meleeSpeed = 6.0;

/// damage reduction per flankCount
const double flankingPenalty = 0.15;

/// bonus damage factor for each node of momentum
const double chargeBonus = 0.30;

///percentage damage reduction per elevation difference
const double elevationBonus = 0.10;

/// same as elevation but acts for units on fortification vs ones outside
const double fortificationBonus = 0.75;
const double killMoraleBoost = 25.0;

// RANGED COMBAT
const double rangedDamageFactor = 16.0;

/// 0-1.0 damage reduction for moving and shooting
/// where 1.0 means full damage inflicted
const double moveAndShootPenalty = 0.75;

/// percentage of ranged damage absorbed by forest/building tiles
const double coverBonus = 0.25;

/// percentage of damage inflicted in Rain
const double rangedRainPenalty = 0.75;
const double rangedSnowPenalty = 0.65;

//TACTICAL AI
/// how many tiles away can a 100% morale unit see. More => worse perf
const int maxVision = 7;
const double friendlyOccupyingUnitPenaltyMelee = 10.0;
const double friendlyOccupyingUnitPenaltyRanged = 15.0;
const double friendlyOnPathPenalty = 1.0;
const double fortificationPreference = 47.0;
const double fortificationPreferenceCurrentNode = 55.0;

///how much of the score of a node on the path to a target node is added to
///the target node score (also weighted by number of nodes in path)
const double pathBasedNodeScoreWeight = 0.45;

/// ranged units' preference to avoid enemies on path
const double enemyOnPathPenaltyRanged = 15.0;

/// ranged units' preference to avoid enemies on path
const double enemyOnPathPenaltyMelee = 12.0;

/// higher = more aggressive melee fighter
const double enemyOccupiedFactorMelee = 25.0;

/// higher = more aggressive melee fighter
const double enemyOccupiedFactorRanged = -20.0;

/// higher = less damage tolerance
const double meleeVulnerabilityFactorMelee = 0.85;

/// higher = less damage tolerance
const double meleeVulnerabilityFactorRanged = 9.0;
const double rangedAggressivenessFactor = 6.0;
const double rangedVulnerabilityFactor = 1.0;

/// lower = avoid engagement more
const double spearingPreference = 0.5;

/// higher - more of a preference to stay put
const double currentLocationPreferenceMelee = 0.3;

/// higher - more of a preference to stay put
const double currentLocationPreferenceRanged = 1.0;

/// higher = stronger preference to avoid killzones
const double killzoneAvoidanceFactorRanged = 0.2;

/// higher = stronger preference to avoid killzones
const double killzoneAvoidanceFactorSpears = 0.3;

///factor which scales the penalty for distance
const double distancePenaltyFactor = 1.35;

/// penalty for each node of the path that passes outside of the visible area
const double offVisibleAreaPathPenalty = 10.0;

// Node path finding
const double stationaryBlockingUnitValue = 2.5;
const double movingBlockingUnitValue = 0.75;
const double currentPathPreferenceFactor = 1.1;

//Commander
const double commanderDeathMoraleHit = 25.0;
const double commanderMoraleBoost = 10.0;
const double commanderMoraleBoostFactorCap = 10.0;

/// how much does a commander's moraleBoostMultiple increase
/// following a successful battle
const double commanderMoraleBoostUpgradeFactor = 0.07;

///commander 1-x of morale damage compared to a regular unit
const double commanderMoraleResistanceFactor = 0.25;
const double commanderAttritionFactorFloor = 0.2;

/// how much does a commander's attritionMultiple go down for every turn
const double commanderAttritionLearningFactor = 0.01;

/// how much does a commander's melee or ranged multiple increase
/// on successful kill
const commanderCombatFactorsLearningFactor = 0.1;
const commanderCombatFactorCap = 2.0;

///
// 0.5mt per person per year consumption
// yield 0.25mt per acre worked (multiply by 0.5 for crop rotation)
// 1 worker can work max 100 acres (from 50-60 acres per household survival and
// assuming low productivity in middle ages). translates to 25mt max yield per
// worker assume LFP of 80% (everybody works) so 20mt max yield per pop
// average province has say 250,000 acres or arable land
// so output average is 250k * 0.5 * 0.25 = 31.25kmt per year
// supports a population of 62,500 people which is a decent ballpark
// storage capacity max 2 yrs of consumption
// caravans distribute excess output to neighbouring provinces
// army consumption = units x 5,000 men (10k would overwhelm too quickly) so
// 2,500mt per unit
///

// Resources
/// how many tonnes of grain can a single person produce per season
/// (= per year assuming 1 harvest)
const double maxProvisionsYieldPerPersonPerSeason = 20.0;

/// irrigation total for the year is multiplied to get the realised yield
/// at harvest to a max of 100%. Irrigation is then reset to zero
const double rainIrrigationContributionPerSeason = 0.5;
const double snowIrrigationContributionPerSeason = 0.25;
const double cloudIrrigationContributionPerSeason = 0.05;
const double sunIrrigationContributionPerSeason = -0.10;

///  0.01*smoothStep(pop) so 10k pop = 8.56/season,
///  100k pop = 1000.00/season swordsman in 3000 / x = 350...3 seasons.
const double defaultGoldYieldPerPersonPerSeason = 0.01;
const double startingGoldPerPerson = 0.05;

/// what % of province gold stored is transferred to the army by taxation
const double taxRate = 0.2;

/// what % of province gold gets destroyed by taxation
const double taxGoldLeakage = 0.05;
const double sackGoldRate = 0.5;
const double sackGoldLeakage = 0.3;

/// generating 0.01 gold allows a pop to buy 0.1 of provisions
/// while they need 0.125 per season
const double provisionsPrice = 0.1;
//TODO: dynamic pricing

/// unit types that are available in any province
const List<UnitTypeNames> defaultUnitTypeIndices = [
  UnitTypeNames.archers,
  UnitTypeNames.swordsmen,
  UnitTypeNames.lightCavalry,
  UnitTypeNames.catapult,
];
const double popsPerUnit = 5000.0;

/// when a unit dies from attrition, half the pops used to create it are
/// added to the pops of the local province
const double popsRecoveredInUnitAttrition = 0.5;

/// 3.0 means 1/3 of the pops are draftable meaning
/// you need 3.0 x popsPerUnit in population to train a unit
const double inverseDraftablePopsProportion = 3.0;

const double populationProvisionsConsumptionPerSeason = 0.5 / 4;
const double unitProvisionsConsumptionPerSeason =
    popsPerUnit * populationProvisionsConsumptionPerSeason;

/// to make sieges more viable, give besiegers a minimum of provisions even if
/// the province has none (expressed as proportion of demand)
const double besiegingArmyProvisionsBonus = 0.25;

///health hit if not supplied at all in a season
const double unitHealthAttritionFactor = 25.0;

///morale hit if not supplied at all in a season
const double unitMoraleAttritionFactor = 35.0;

/// heal this much per season if supplied
const double unitHealingPerSeason = 40.0;

/// restore this much per season if supplied and healed
const double unitMoraleRestorePerSeason = 65.0;

/// what % of pop will die in a famine in a season assuming zero supply
const double populationAttritionRate = 0.25;

///before starvation and war losses
const double populationGrowthPerSeason = 0.08 / 4.0;

///how much of a fort segment's life can be repaired in a season.
const double fortRepairFactor = 20.0;

///how much max fort life can be repaired by 1 pop
const double maxFortRepairPerPerson = 5.0 / 1000.0;

///what proportion of the population gets killed/captured
///when a province is sacked
const double sackPopulationShare = 0.5;

///what proportion of sack casualties are captured
const double captivePopulationShare = 0.5;

/// how many captives per unit
const double populationPerCaptiveUnit = 10000.0;

// Siege
///how much damage do bombards do to walls
///(sum of all bombard damage divided by number of segments in the fort)
const double seasonSiegeBombardDamageFactor = 28.0;

///how much damage do the ranged units within the fort do to the attackers
const double seasonSiegeRangedDamageFactor = 1.0;

///percentage of bombard damage coming through in Rain
const double rainBombardPenalty = 0.8;

///percentage of bombard damage coming through in Snow
const double snowBombardPenalty = 0.5;

//MAP ASSETS

final Iterable<String> tacticalMapsPaths =
    tacticalMaps.map((final map) => map.path);

const List<BattleMap> tacticalMaps = [
  BattleMap(
    path: 'river.tmx',
    title: 'River',
  ),
  BattleMap(
    path: 'hexi.tmx',
    title: 'Hexi',
  ),
  BattleMap(
    path: 'city.tmx',
    title: 'City',
  ),
  BattleMap(
    path: 'road.tmx',
    title: 'Road',
  ),
  BattleMap(
    path: 'forest.tmx',
    title: 'Forest',
  ),
  BattleMap(
    path: 'desert.tmx',
    title: 'Desert',
  ),
  BattleMap(
    path: 'lush.tmx',
    title: 'Lush',
  ),
];

@immutable
class BattleMap extends Equatable {
  const BattleMap({
    required this.title,
    required this.path,
  });
  String get id => path;
  final String title;
  final String path;

  bool containsValue(final TextEditingValue textEditingValue) =>
      '$title$path'.toLowerCase().contains(textEditingValue.text);

  @override
  List<Object?> get props => [id];
}

/// *******************************
///            MUSIC
/// *******************************
/// milliseconds
const musicDelayDurationForBattleWon = 5000;

/// milliseconds
const musicDelayDurationForBattleLost = 3000;

/// milliseconds
const musicThemeFadeDuration = 2000;

const bgmVolume = 0.06;
