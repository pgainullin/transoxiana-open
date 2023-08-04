import 'package:collection/collection.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:transoxiana/components/battle/battle.dart';
import 'package:transoxiana/components/battle/node.dart';
import 'package:transoxiana/components/battle/unit.dart';
import 'package:transoxiana/components/game/game.dart';
import 'package:transoxiana/components/shared/fortification.dart';
import 'package:transoxiana/components/shared/nation.dart';
import 'package:transoxiana/data/campaign_data_source.dart';
import 'package:transoxiana/data/constants.dart';
import 'package:transoxiana/services/battle_map_services.dart';

part 'tactical_ai.g.dart';

// AI that makes short-term, within real-time game decisions for each unit
class TacticalAi {
  TacticalAi(this.unit);
  final Unit unit;

  Node? pickSpearTarget() {
    if (unit.location == null) return null;

    return pickTargetNodeFromSet(targetArea(unit.location!, unit.meleeReach));
  }

  Node? pickShootingTarget() {
    if (unit.location == null) return null;

    int range = unit.shootingRange;
    if (unit.location!.fortificationSegment != null &&
        unit.location!.fortificationSegment!.life > 0.0) range += 1;

    final Set<Node> areaInRange = targetArea(unit.location!, range);

    Node? targetNode;

    if (unit.stance == Stance.bombard) {
      final Set<Node> fortifiedArea = areaInRange
          .where(
            (final node) =>
                node.fortificationSegment != null &&
                node.fortificationSegment!.life > 0.0 &&
                node != unit.location,
          )
          .toSet();

      if (fortifiedArea.isNotEmpty) {
        // select a unit that occupies a fort segment
        targetNode = pickTargetNodeFromSet(fortifiedArea);

        // if not select a fort segment
        targetNode ??= fortifiedArea.first;
      }
    }

    // normal unit targeting if no bombard target set
    return targetNode ?? pickTargetNodeFromSet(areaInRange);
  }

  Node? pickTargetNodeFromSet(final Set<Node> targetArea) {
    assert(targetArea.isNotEmpty);

    //pick a fighting target
    Node? targetNode = targetArea.firstWhereOrNull((final potentialTargetNode) {
      final Unit? enemyUnit = potentialTargetNode.unit;
      if (enemyUnit != null &&
          enemyUnit.isFighting &&
          unit.isHostileToUnit(enemyUnit)) return true;
      return false;
    });

    //if no fighting target, pick a fleeing one
    return targetNode ??=
        targetArea.firstWhereOrNull((final potentialTargetNode) {
      final Unit? enemyUnit = potentialTargetNode.unit;
      if (enemyUnit != null &&
          unit.isHostileToUnit(enemyUnit) &&
          enemyUnit.health > 0.0) return true;
      return false;
    });
  }

  void giveOrder() {
    if (unit.location == null) return;

    //TODO: add state to this instance recording how long the unit has been
    // stuck and then ordering a random deviation movement to avoid building
    // long queues of units along a path

    if (unit.stance == Stance.attack) {
      if (unit.location!.fortificationSegment != null &&
          unit.location!.fortificationSegment!.type == FortificationType.gate) {
        if (unit.game.activeBattle!.province.nation.isHostileTo(unit.nation)) {
          unit.location!.fortificationSegment!.data.open = true;
        } else {
          unit.location!.fortificationSegment!.data.open = false;
        }
      }

      final Map<Node, double> heatMap = produceHeatMap(unit);

      if (heatMap.isNotEmpty) {
        double highestScore = heatMap.entries.first.value;
        Node highScoreNode = heatMap.entries.first.key;
        heatMap.forEach((final node, final score) {
          if (score > highestScore) {
            highestScore = score;
            highScoreNode = node;
          }
        });

        final List<Node>? path = pathToNodeWithUnitAvoidance(
          unit.game.activeBattle!,
          unit.location!,
          highScoreNode,
        );
        if (path != null && path.isNotEmpty) {
          unit.data.destinationSetByAi = true;
          unit.processMoveOrder(path);
        }
      }
    }
  }

  static bool nodeEngaged(final Unit unit, final Node node) {
    if (node.unit != null &&
        node.unit!.isFighting &&
        node.unit!.isHostileToUnit(unit)) {
      return true;
    } //if the node itself is occupied by the enemy, return true
    return node.adjacentNodes.firstWhereOrNull(
          (final adjacentNode) =>
              adjacentNode.unit != null &&
              adjacentNode.unit!.isFighting &&
              adjacentNode.unit!.nation != unit.nation,
        ) !=
        null;
  }

  ///return true if an enemy unit is marching on this node from any adjacent
  ///node and this node is not occupied by a friendly unit
  bool nodeUnderAttack(final Node node) {
    //TODO: remove this hack - not sure why this gets called for nodes
    // with no tileData
    if (unit.game.activeBattle!.tileData[node] == null) {
      return true;
    }

    // already occupied by the enemy
    if (node.unit != null && node.unit!.isHostileToUnit(unit)) {
      return true;
    }

    // or not occupied but targeted by an enemy unit from an adjacent node
    return (node.unit == null) &&
        node.adjacentNodes.firstWhereOrNull(
              (final adjacentNode) =>
                  adjacentNode.unit != null &&
                  adjacentNode.unit!.isHostileToUnit(unit) &&
                  adjacentNode.unit!.nextNode == node,
            ) !=
            null;
  }

  /// list of enemy units from closest to furthest away within the given
  /// set of nodes from this unit
  List<Unit> nearestEnemiesInSearchArea(final Set<Node> searchArea) {
    final List<Unit> list = unit.game.campaignRuntimeData.units.values
        .where(
          (final u) =>
              searchArea.contains(u.location) &&
              u.isHostileToUnit(unit) &&
              u.health > 0.0,
        )
        .toList()
      ..sort((final a, final b) => travelCostComparatorByUnits(unit, a, b));

    return list;
  }

  //go through the given node area and score it depending on unit stats
  static Map<Node, double> produceHeatMap(final Unit unit) =>
      unit.game.activeBattle!.tacticalInfo[unit.nation]!.combinedHeatMap(unit);
}

@JsonSerializable(explicitToJson: true)
class TacticalInfoData {
  TacticalInfoData({
    required this.battleId,
    required this.nationId,
    this.initialized = false,
  });
  static TacticalInfoData fromJson(final Map<String, dynamic> json) =>
      _$TacticalInfoDataFromJson(json);
  Map<String, dynamic> toJson() => _$TacticalInfoDataToJson(this);
  Future<TacticalInfo> toTacticalInfo({
    required final TransoxianaGame game,
  }) async {
    final effectiveBattle =
        await game.campaignRuntimeData.getBattleById(battleId: battleId);
    final effectiveNation =
        await game.campaignRuntimeData.getNationById(nationId);
    return TacticalInfo._fromData(
      battle: effectiveBattle,
      data: this,
      nation: effectiveNation,
    );
  }

  final Id battleId;
  final Id nationId;
  bool initialized;
}

//TODO: refactor by precomputing several matrices and then multiplying them
// by the unit's factor and summing for an overall heatMap
// f(distances matrix, speed) - already computed
// f(damage received matrix, strength) - to be computed for each nation
// f(melee damage inflicted, strength) - to be computed for each nation
// f(spear or ranged damage, spear or ranged strength) -can this be precomputed?
// Q: how to add path-based scoring without precomputing
// the entire resulting matrix?

/// This class contains maps / matrices of precomputed information
/// that is useful for every unit making tactical decisions
class TacticalInfo implements DataSourceRef<TacticalInfoData, TacticalInfo> {
  TacticalInfo._fromData({
    required this.battle,
    required this.nation,
    required this.data,
  });
  @override
  Future<TacticalInfoData> toData() async => TacticalInfoData(
        battleId: battle.id,
        initialized: initialized,
        nationId: nation.id,
      );
  @override
  Future<void> refillData(final TacticalInfo otherType) async {
    data = await otherType.toData();
    nation = otherType.nation;
    battle = otherType.battle;
  }

  @override
  TacticalInfoData data;
  Battle battle;
  Nation nation;

  /// scores based on where own and allied troops are located or
  /// are moving towards
  final Map<Node, int> friendlyPositions = {};

  /// scores based on where neutral troops are located or are moving towards
  final Map<Node, int> neutralPositions = {};

  /// scores based on where neutral troops are located or are moving towards
  final Map<Node, int> enemyPositions = {};

  /// scores based on melee damage received in each node
  final Map<Node, double> meleeVulnerableZones = {};

  /// penalties from being flanked
  final Map<Node, int> flankingPenalties = {};

  /// bonuses from flanking
  final Map<Node, int> flankingBonuses = {};

  /// scores based on melee damage received in each node
  final Map<Node, double> rangedVulnerableZones = {};

  /// scores based on damage that can be inflicted in this node. this should be
  /// evaluated by taking account of the melee/spear/shooting range of a
  /// specific unit
  final Map<Node, double> attackValues = {};

  bool get initialized => data.initialized;

  /// updates all the precomputed maps with values based on the current
  /// state of the Battle
  void computeMaps() {
    // log('Updating tactical information for $nation');

    clearAllMaps();

    final List<Unit> allUnits = battle.armies
        .expand<Unit>(
          (final army) => army.units.where(
            (final unit) => unit.isFighting && unit.location != null,
          ),
        )
        .toList();

    for (final Unit unit in allUnits) {
      if (unit.location == null) continue;

      if (unit.nation.isFriendlyTo(nation)) {
        //allied
        friendlyPositions[unit.location!] =
            friendlyPositions[unit.location!]! + 1;
        for (final Node adjacentNode in unit.location!.adjacentNodes) {
          flankingBonuses[adjacentNode] = flankingBonuses[adjacentNode]! + 1;
        }
      } else if (unit.nation.isHostileTo(nation)) {
        //enemy
        enemyPositions[unit.location!] = enemyPositions[unit.location!]! + 1;
        attackValues[unit.location!] =
            attackValues[unit.location!]! + unit.meleeDps();
        if (unit.meleeReach < 2) {
          //regular melee
          for (final Node adjacentNode in unit.location!.adjacentNodes) {
            meleeVulnerableZones[adjacentNode] =
                meleeVulnerableZones[adjacentNode]! - unit.meleeDps();
            flankingPenalties[adjacentNode] =
                flankingPenalties[adjacentNode]! + 1;
          }
        } else {
          //spearing unit
          final Set<Node> spearingArea =
              targetArea(unit.location!, unit.meleeReach);
          for (final Node targetedNode in spearingArea) {
            meleeVulnerableZones[targetedNode] =
                meleeVulnerableZones[targetedNode]! - unit.meleeDps();
            if (targetedNode.isAdjacent(unit.location!)) {
              flankingPenalties[targetedNode] =
                  flankingPenalties[targetedNode]! + 1;
            }
          }
        }

        if (unit.shootingRange > 1 && unit.rangedDps() > 0.0) {
          //ranged unit
          final Set<Node> shootingArea =
              targetAreaWithFortExtension(unit.location!, unit.shootingRange);
          for (final Node targetedNode
              in shootingArea.difference(unit.location!.adjacentLocations)) {
            rangedVulnerableZones[targetedNode] =
                rangedVulnerableZones[targetedNode]! - unit.rangedDps();
          }
        }
      } else {
        //neutral
        neutralPositions[unit.location!] =
            neutralPositions[unit.location!]! + 1;
      }
    }

    data.initialized = true;
  }

  void clearAllMaps() {
    flankingBonuses.clear();
    flankingPenalties.clear();
    neutralPositions.clear();
    enemyPositions.clear();
    friendlyPositions.clear();
    attackValues.clear();
    meleeVulnerableZones.clear();
    rangedVulnerableZones.clear();

    flankingBonuses.addEntries(battle.nodes.map((final e) => MapEntry(e, 0)));
    flankingPenalties.addEntries(battle.nodes.map((final e) => MapEntry(e, 0)));
    neutralPositions.addEntries(battle.nodes.map((final e) => MapEntry(e, 0)));
    enemyPositions.addEntries(battle.nodes.map((final e) => MapEntry(e, 0)));
    friendlyPositions.addEntries(battle.nodes.map((final e) => MapEntry(e, 0)));
    attackValues.addEntries(battle.nodes.map((final e) => MapEntry(e, 0.0)));
    meleeVulnerableZones
        .addEntries(battle.nodes.map((final e) => MapEntry(e, 0.0)));
    rangedVulnerableZones
        .addEntries(battle.nodes.map((final e) => MapEntry(e, 0.0)));
  }

  /// called by units to come up with new orders within the real time phase so
  /// should be optimised
  Map<Node, double> combinedHeatMap(final Unit unit) {
    assert(unit.nation == nation);
    assert(unit.location != null);
    assert(unit.isFighting);

    final Map<Node, double> visibleArea = Map.fromEntries(
      targetArea(unit.location!, unit.visionRange)
          .map<MapEntry<Node, double>>((final node) => MapEntry(node, 0.0)),
    );

    visibleArea[unit.location!] = unit.isMelee
        ? currentLocationPreferenceMelee
        : currentLocationPreferenceRanged;

    final Map<Node, Node> nodesWithShootingTargets = {};
    final Map<Node, Node> nodesWithMeleeTargets = {};

    visibleArea.forEach((final key, final value) {
      if (!key.isTraversable) {
        visibleArea[key] = double.negativeInfinity;
      } else {
        //positions
        if (key != unit.location) {
          visibleArea[key] = visibleArea[key]! -
              (friendlyPositions[key] ?? 0) *
                  (unit.isMelee
                      ? friendlyOccupyingUnitPenaltyMelee
                      : friendlyOccupyingUnitPenaltyRanged);
          visibleArea[key] = visibleArea[key]! -
              (enemyPositions[key] ?? 0) *
                  (unit.isMelee
                      ? enemyOnPathPenaltyMelee
                      : enemyOnPathPenaltyRanged);
          visibleArea[key] = visibleArea[key]! -
              (neutralPositions[key] ?? 0) *
                  (unit.isMelee
                      ? friendlyOccupyingUnitPenaltyMelee
                      : friendlyOccupyingUnitPenaltyRanged);
        }

        //fortifications
        if (key.fortificationSegment != null &&
            key.fortificationSegment!.life > 0.0) {
          visibleArea[key] = visibleArea[key]! +
              (key == unit.location
                  ? fortificationPreferenceCurrentNode
                  : fortificationPreference);
        }

        //melee vulnerable zones
        if (meleeVulnerableZones[key] != 0.0) {
          visibleArea[key] = visibleArea[key]! +
              nodeMeleeDefenseValue(
                key,
                unit.meleeDps(),
                unit.isMelee
                    ? meleeVulnerabilityFactorMelee
                    : meleeVulnerabilityFactorRanged,
              );
        }

        //ranged vulnerable zones
        if (rangedVulnerableZones[key] != 0.0) {
          visibleArea[key] = visibleArea[key]! + nodeRangedDefenseValue(key);
        }

        //attacks
        if (attackValues[key]! > 0.0) {
          //melee attacks
          if (unit.meleeReach < 2) {
            nodesWithMeleeTargets.addEntries(
              key.adjacentNodes
                  .where((final element) => visibleArea[element] != null)
                  .map((final e) => MapEntry(e, key)),
            );
          } else {
            //spearing unit
            nodesWithMeleeTargets.addEntries(
              targetArea(key, unit.meleeReach)
                  .where((final element) => visibleArea[element] != null)
                  .map((final e) => MapEntry(e, key)),
            );
          }

          // ranged attacks on fortifications
          if (key.fortificationSegment != null &&
              key.fortificationSegment!.life > 0.0 &&
              unit.shootingRange > 1 &&
              unit.rangedStrength > 0.0 &&
              unit.bombardFactor > 0.0) {
            final Set<Node> targetArea =
                targetAreaWithFortExtension(key, unit.shootingRange);
            nodesWithShootingTargets.addEntries(
              targetArea
                  .where((final element) => visibleArea[element] != null)
                  .map((final e) => MapEntry(e, key)),
            );
          }

          //ranged attacks on units
          if (unit.shootingRange > 1 && unit.rangedStrength > 0.0) {
            final Set<Node> targetArea =
                targetAreaWithFortExtension(key, unit.shootingRange);
            nodesWithShootingTargets.addEntries(
              targetArea
                  .where((final element) => visibleArea[element] != null)
                  .map((final e) => MapEntry(e, key)),
            );
          }
        }
      }
    });

    // run through the nodes with targets
    nodesWithMeleeTargets.forEach((final element, final target) {
      visibleArea[element] = visibleArea[element]! +
          nodeMeleeAttackValue(
            target,
            unit.meleeDps(),
            unit.isMelee ? enemyOccupiedFactorMelee : enemyOccupiedFactorRanged,
            spear: !target.isAdjacent(element),
          );
    });

    nodesWithShootingTargets.forEach((final element, final target) {
      visibleArea[element] =
          visibleArea[element]! + nodeRangedAttackValue(element, unit);
    });

    // possible optimisation: consider doing this only for the best
    // scoring nodes?
    visibleArea
      ..forEach((final key, final value) {
        if (unit.location!.totalTravelCost(key) != double.infinity) {
          final List<Node>? path = battle.findPath(unit.location!, key);
          assert(
            path != null,
            'path is null from ${unit.location} to $key',
          );
          for (final Node pathNode in path!) {
            if (pathNode != key && pathNode != unit.location) {
              visibleArea[key] = visibleArea[key]! +
                  (visibleArea[pathNode] ?? -offVisibleAreaPathPenalty) *
                      pathBasedNodeScoreWeight /
                      path.length;
            }
          }
        }
      })
      ..forEach(
        (final key, final value) => visibleArea[key] = visibleArea[key]! -
            unit.location!.totalTravelCost(key)! * distancePenaltyFactor,
      );

    return visibleArea;
  }

  double nodeMeleeAttackValue(
    final Node target,
    final double attackerDps,
    final double factor, {
    final bool spear = false,
  }) {
    if (attackValues[target] == 0.0 || attackValues[target] == null) return 0.0;

    double attackingStrength = attackerDps;
    if (flankingBonuses[target] != null && flankingBonuses[target] != 0.0) {
      attackingStrength = attackingStrength *
          (1 +
              flankingPenalty * flankingBonuses[target]! * (spear ? 0.0 : 1.0));
    }
    //this is not how the unit.dart resolves flanking but if much faster
    // in terms of perf

    return attackingStrength * factor -
        defensiveMeleeDamageFactor *
            attackValues[target]! *
            (spear ? 0.0 : 1.0);
  }

  double nodeMeleeDefenseValue(
    final Node node,
    final double defenderDps,
    final double factor,
  ) {
    if (meleeVulnerableZones[node] == 0.0 ||
        meleeVulnerableZones[node] == null) {
      return 0.0;
    }

    double defendingStrength = defenderDps;
    if (flankingPenalties[node] != null && flankingPenalties[node] != 0.0) {
      defendingStrength = defendingStrength / flankingPenalties[node]!;
    }
    //this is not how the unit.dart resolves flanking but is much faster
    // in terms of perf

    return meleeVulnerableZones[node]! * factor +
        defensiveMeleeDamageFactor * defendingStrength;
  }

  double nodeRangedDefenseValue(final Node node) {
    if (rangedVulnerableZones[node] == 0.0 ||
        rangedVulnerableZones[node] == null) return 0.0;

    return rangedVulnerableZones[node]! * rangedVulnerabilityFactor;
  }

  double nodeRangedAttackValue(final Node shootingNode, final Unit attacker) {
    if (TacticalAi.nodeEngaged(attacker, shootingNode)) return 0.0;
    return (attacker.rangedDps()) * rangedAggressivenessFactor;
  }
}
