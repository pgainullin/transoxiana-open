import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:equatable/equatable.dart';
import 'package:flame/components.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:transoxiana/components/battle/hex_tiled_component.dart';
import 'package:transoxiana/components/battle/lances.dart';
import 'package:transoxiana/components/battle/node.dart';
import 'package:transoxiana/components/battle/projectiles.dart';
import 'package:transoxiana/components/battle/unit_painters.dart';
import 'package:transoxiana/components/campaign/weather.dart';
import 'package:transoxiana/components/game/game.dart';
import 'package:transoxiana/components/shared/army.dart';
import 'package:transoxiana/components/shared/components_render_priority.dart';
import 'package:transoxiana/components/shared/nation.dart';
import 'package:transoxiana/data/campaign_data_source.dart';
import 'package:transoxiana/data/constants.dart';
import 'package:transoxiana/data/direction.dart';
import 'package:transoxiana/data/unit_types.dart';
import 'package:transoxiana/generated/l10n.dart';
import 'package:transoxiana/services/audio/sfx.dart';
import 'package:transoxiana/services/battle_map_services.dart';
import 'package:transoxiana/services/tactical_ai.dart';

part 'unit.g.dart';

enum Stance {
  attack,
  defend,
  bombard,
}

@JsonSerializable()
class UnitId with EquatableMixin {
  UnitId({
    required final Id? unitId,
    required this.typeId,
    required this.nationId,
  }) : unitId = unitId ?? uuid.v4();

  Map<String, dynamic> toJson() => _$UnitIdToJson(this);

  static UnitId fromJson(final Map<String, dynamic> json) =>
      _$UnitIdFromJson(json);
  final Id unitId;
  final UnitTypeNames typeId;

  /// as [nationId] is dynamic we cannot rely on it as id
  /// so this param used mostly for unit restoration only
  Id nationId;

  @override
  @JsonKey(ignore: true)
  List<Object?> get props => [unitId, typeId];

  @override
  @JsonKey(ignore: true)
  // ignore: hash_and_equals
  int get hashCode => super.hashCode;

  @override
  @JsonKey(ignore: true)
  bool? get stringify => true;
}

/// Unit state without any logic
/// to simplify save/load, serialization processes etc.
///
/// Keeps only serializable data without any references
/// The data can be mutable
///
/// To create [Unit] use [UnitData.toUnit]
@JsonSerializable(explicitToJson: true)
// ignore: must_be_immutable
class UnitData extends Equatable {
  UnitData({
    required this.id,
    this.visionProvinceRange = 1,
    this.health = 100.0,
    this.morale = 100.0,
    this.progress = 0.0,
    this.shotProgress = 0.0,
    this.meleeProgress = 0.0,
    this.flankCount = 0,
    this.direction = Direction.south,
    this.stance = Stance.attack,
    this.destinationSetByAi = false,
    this.engaged = false,
    this.armyId,
  });

  static UnitData fromJson(final Map<String, dynamic> json) =>
      _$UnitDataFromJson(json);

  Map<String, dynamic> toJson() => _$UnitDataToJson(this);

  Future<Unit> toUnit({
    required final TransoxianaGame game,
    final Node? nextNode,
    final Node? location,
    final Node? orderedDestination,
  }) async {
    final effectiveArmyId = armyId;
    final effectiveArmy = effectiveArmyId == null
        ? null
        : await game.campaignRuntimeData.getArmyById(effectiveArmyId);
    final effectiveNation =
    await game.campaignRuntimeData.getNationById(id.nationId);
    final effectiveUnitType =
    await game.campaignRuntimeData.getUnitTypeById(id.typeId);
    return Unit._fromData(
      data: this,
      game: game,
      nation: effectiveNation,
      army: effectiveArmy,
      location: location,
      nextNode: nextNode,
      orderedDestination: orderedDestination,
      type: effectiveUnitType,
    );
  }

  ArmyId? armyId;
  final UnitId id;

  /// 0-100.0
  double health;

  /// 0-100.0
  double morale;

  /// 0.0-1.0, progress to nextTile where 1.0 is completion of the move
  double progress;

  /// 0..1.0 where at 1.0 a shot occurs
  double shotProgress;

  /// melee attack occurs at 1.0
  double meleeProgress;
  int flankCount;
  Direction direction;
  Stance stance;

  /// determines that the destination was set by tactical AI and resets
  bool destinationSetByAi;
  bool engaged;
  int momentum = 0; // number of nodes of uninterrupted charge accumulated

  /// Determines how many provinces could be without
  /// a fog of war around unit army.
  ///
  /// Please note the value is zero counted!
  final int visionProvinceRange;

  @override
  @JsonKey(ignore: true)
  List<Object?> get props => [id];

  @override
  @JsonKey(ignore: true)
  // ignore: hash_and_equals
  int get hashCode => super.hashCode;

  @override
  @JsonKey(ignore: true)
  bool? get stringify => true;
}

/// Mutable runtime unit with state containing its position, actions, AI etc
///
/// [Unit] should be always created from [UnitData.toUnit] method
class Unit extends Component
    with EquatableMixin
    implements GameRef, DataSourceRef<UnitData, Unit> {
  Unit._fromData({
    required this.game,
    required this.data,
    required this.army,
    required this.location,
    required this.nextNode,
    required this.orderedDestination,
    required this.nation,
    required this.type,
  }) : super(priority: ComponentsRenderPriority.battleUnit.value) {
    //TODO: post deployment set directions of each army to
    // face the enemy deployment point
    if (location != null) {
      if (nextNode != null) {
        setDirectionAdjacent(nextNode!);
      }
    }
  }

  @override
  Future<void> refillData(final Unit unit) async {
    assert(unit == this, 'You trying to update different unit.');
    final newData = await unit.toData();
    data = newData;
    army = unit.army;
    location = unit.location;
    nextNode = unit.nextNode;
    orderedDestination = unit.orderedDestination;
    nation = unit.nation;
  }

  @override
  Future<UnitData> toData() async =>
      UnitData(
        armyId: army?.id,
        destinationSetByAi: destinationSetByAi,
        direction: direction,
        engaged: engaged,
        flankCount: flankCount,
        health: health,
        meleeProgress: meleeProgress,
        morale: morale,
        progress: progress,
        shotProgress: shotProgress,
        stance: stance,
        visionProvinceRange: visionProvinceRange,
        id: id..nationId = nation.id,
      );

  @override
  TransoxianaGame game;
  Army? army;

  Nation nation;

  @override
  UnitData data;
  final UnitType type;

  /// cache
  TacticalAi? _tacticalAi;

  TacticalAi get tacticalAi => _tacticalAi ??= TacticalAi(this);

  Node? location;
  Node? orderedDestination;
  Node? nextNode;

  int get visionProvinceRange => data.visionProvinceRange;

  Stance get stance => data.stance;

  Direction get direction => data.direction;

  /// determines that the destination was set by tactical AI and resets
  bool get destinationSetByAi => data.destinationSetByAi;

  //0.0-1.0, progress to nextTile where 1.0 is completion of the move
  double get progress => data.progress;

  ///0..1.0 where at 1.0 a shot occurs
  double get shotProgress => data.shotProgress;

  /// melee attack occurs at 1.0
  double get meleeProgress => data.meleeProgress;

  /// number of nodes of uninterrupted charge accumulated
  int get momentum => data.momentum;

  bool get engaged => data.engaged;

  final Set<Unit> engagedUnits = {};
  final Set<Unit> fleeingAdjacentEnemies = {};

  int get flankCount => data.flankCount;

  double get health => data.health; //0-100.0
  double get morale => data.morale; //0-100.0

  int get visionRange => max(1, maxVision * morale / 100.0).round();

  String get name => type.name;

  int get speed => type.speed;

  int get rangedSpeed => type.rangedSpeed;

  int get rangedStrength => type.rangedStrength;

  int get shootingRange => type.shootingRange;

  double get bombardFactor => type.bombardFactor;

  int get meleeReach => type.meleeReach;

  int get meleeStrength => type.meleeStrength;

  int get maxMomentum => type.maxMomentum;

  int get momentumBreak => type.momentumBreak;

  Sprite get sprite => type.sprite;

  bool get isCommandUnit =>
      army?.commander != null && army?.commander?.unit == this;

  UnitId get id => data.id;

  // for AI training API
  Map<String, dynamic> toAiJson() {
    return Map<String, dynamic>.fromEntries([
      MapEntry('location', location),
      MapEntry('health', health),
      MapEntry('morale', morale),
      MapEntry('type', type),
    ]);
  }

  @override
  void update(final double dt) {
    super.update(dt);
    if (location == null ||
        health <= 0.0 ||
        game.temporaryCampaignData.isPaused ||
        dt <= 0.0) return;

    if (morale > 0.0) {
      data
        ..shotProgress += rangedSpeed * (dt / GameConsts.secondsToCommand)
        ..meleeProgress += meleeSpeed * (dt / GameConsts.secondsToCommand);

      updateEngagementStatus();

      if (engaged == true) {
        //close quarters melee fighting
        data.flankCount = max(0, engagedUnits.length - 1);

        if (meleeProgress >= 1.0) {
          if (engagedUnits.first.location == null) return;
          attack(engagedUnits.first.location!);
          data.meleeProgress = 0.0;
        }
      } else {
        bool isOccupied = false;

        if (orderedDestination != null) {
          //if not engaged and have a target - attempt to move
          move(dt);
          isOccupied = true;
        }

        if (meleeReach > 1 && meleeProgress >= 1.0) {
          //check if you can spear someone
          final Node? targetNode = tacticalAi.pickSpearTarget();
          if (targetNode != null) {
            spear(targetNode);
            data.meleeProgress = 0.0;
            isOccupied = true;
          }
        } else if (shootingRange > 1 && shotProgress >= 1.0) {
          //check if you can shoot at someone
          final Node? targetNode = tacticalAi.pickShootingTarget();

          if (targetNode != null) {
            shoot(targetNode);
            data.shotProgress = 0.0;
            isOccupied = true;
          }
        } else if (meleeProgress >= 1.0 && fleeingAdjacentEnemies.isNotEmpty) {
          attack(fleeingAdjacentEnemies.first.location!);
          isOccupied = true;
          data.meleeProgress = 0.0;
        }

        if (isOccupied == false ||
            (orderedDestination != null &&
                destinationSetByAi == true &&
                meleeProgress >= 1.0)) {
          // idle unit - let tactical AI direct
          // also if current orders given by tactical AI so behaviour adapts
          // meleeProgress check is a hack to reduce the number of calls
          // to tacticalAi

          if (game.reactiveTimer.state.remainder(1) < frameDuration &&
              meleeProgress > progress) {
            tacticalAi.giveOrder();
          }
        }
      }
    } else {
      flee(dt);
    }
  }

  /// check if this unit is currently engaged, save that info in unit's state
  /// and save the units it's engaged with
  void updateEngagementStatus() {
    if (location == null) return;

    //engagement check
    data.engaged = false; //in case moved to a new cell with no adjacent units
    engagedUnits.clear();
    fleeingAdjacentEnemies.clear();

    for (final Node adjacentNode in location!.adjacentNodes) {
      final Unit? adjacentUnit = adjacentNode.unit;
      if (adjacentUnit != null &&
          isHostileToUnit(adjacentUnit) &&
          adjacentUnit.health > 0.0) {
        if (adjacentUnit.isFighting) {
          data.engaged = true;
          engagedUnits.add(adjacentUnit);
        } else {
          fleeingAdjacentEnemies.add(adjacentUnit);
        }
      }
    }
  }

  void flee(final double dt) {
    if (location == null) return;

    final List<Node> fleeToNodes = adjacentNodes(location!, game)
        .where((final node) => node.unit == null && node.isTraversable)
        .toList();
    //potential issue with nodes that are traversable but
    //not accessible from location such as bridges connected to a different node

    final Node? fleeToNode = fleeToNodes.isNotEmpty
        ? fleeToNodes[game.rand.nextInt(fleeToNodes.length)]
        : null;

    if (fleeToNode != null) {
      if (orderedDestination == null) processMoveOrder([fleeToNode]);
      move(dt);
    }
  }

  bool get isRenderAllowed => !isRenderNotAllowed;

  bool get isRenderNotAllowed =>
      game.isHeadless ||
          (game.campaignRuntimeData.isBattleStarted &&
              game.activeBattle!.isAiBattle);

  Future<void> playMoveSound() async {
    if (isRenderNotAllowed) return;

    if (speed >= 4) {
      await MultiTrackSfx.horses.startPlayer(volume: 0.6);
    } else {
      await MultiTrackSfx.marching.startPlayer(volume: 0.4);
    }
  }

  /// manually order the unit to go to a given node.
  /// Does not ask for any confirmations
  void orderToNode(final Node node) {
    if (location == null) return;

    // log('AI order to $node');
    final List<Node>? path =
    pathToNodeWithUnitAvoidance(game.activeBattle!, location!, node);
//                log(path.length.toString());
    if (path != null) {
      data.destinationSetByAi = false;
      processMoveOrder(path);
    }
  }

  void setDirectionAdjacent(final Node adjacentTargetNode) {
    if (location == null) return;
    assert(
    location!.isAdjacent(adjacentTargetNode),
    '$adjacentTargetNode is not adjacent to $location '
        'in setDirectionAdjacent',
    );

    // start animation for turning here
    data.direction =
        directionBetweenAdjacentNodes(location!, adjacentTargetNode);
    // log('$this direction.dart from $location to $adjacentTargetNode
    // is now $direction.dart');
  }

  /// more expensive than the adjacent one as it involves vector
  /// angle calculations
  void setDirectionToAnyNode(final Node targetNode) {
    if (location == null) return;

    data.direction =
        directionBetweenAnyNodes(game.activeBattle!, location!, targetNode);
    // log('$location to $targetNode is $direction');
  }

  /// execute a move order along a given path
  void processMoveOrder(final List<Node> path) {
    if (nextNode != path.first) {
      data.progress = 0.0;
      setDirectionAdjacent(path.first);
    }
    nextNode = path.first;
    orderedDestination = path.last;
    if (isRenderAllowed) {
      singleTrackSfxController.play(
        speed > 4
            ? singleTrackLoopingSfxType.cavalryMove
            : singleTrackLoopingSfxType.infantryMove,
      );
    }
  }

  void clearOrders() {
    if ((nextNode != null || orderedDestination != null) && isRenderAllowed) {
      singleTrackSfxController.stop(
        speed > 4
            ? singleTrackLoopingSfxType.cavalryMove
            : singleTrackLoopingSfxType.infantryMove,
      );
    }
    orderedDestination = null;
    nextNode = null;
    data.progress = 0.0;
  }

  void move(final double dt) {
    if (location == null) return;
    assert(
    nextNode != null,
    'nextNode is null in move',
    );
    assert(
    orderedDestination != null,
    'orderedDestination is null in move',
    );

    if (nextNode! != orderedDestination!) {
      if (pathToNodeWithUnitAvoidance(
        game.activeBattle!,
        nextNode!,
        orderedDestination!,
      ) ==
          null) {
        clearOrders();
        return;
      }

      //runs this only if timer which is 0.0...6.0 is closer to a full second
      //than one frame to avoid fidgeting behaviour
      if (game.reactiveTimer.state.remainder(1) < frameDuration) {
        considerAlternativePaths();
      }
    }

    assert(
    adjacentNodes(location!, game).contains(nextNode),
    'recalculated $nextNode is not adjacent to $location',
    );
    assert(
    location!.adjacentDistances.containsKey(nextNode),
    'no distance saved for $nextNode from $location',
    );
    assert(
    location!.adjacentDistances[nextNode]! > 0.0,
    'distance to $nextNode must be positive',
    );

    // travelCost(location, nextNode);
    data.progress = min(
      1.0,
      progress +
          speed *
              (dt / GameConsts.secondsToCommand) /
              location!.adjacentDistances[nextNode]!,
    );

    if (progress >= 1.0 &&
        (nextNode!.unit == null || nextNode!.unit!.health <= 0.0)) {
      //Reached next node
      location!.unit = null;
      nextNode!.unit = this;

      arrive(nextNode!);
    } else if (progress >= 1.0 &&
        nextNode!.unit != null &&
        !nextNode!.unit!.nation.isHostileTo(nation) &&
        nextNode!.unit!.nextNode == location &&
        nextNode!.unit!.progress >= 1.0) {
      //swapping two friendly units between tiles

      nextNode!.unit!.arrive(location!);

      // //Move the other unit to this node
      location!.unit = nextNode!.unit;
      nextNode!.unit = this;

      //Move this unit to the other node
      arrive(nextNode!);
    }
  }

  void arrive(final Node node,) {
    // node.unit = this;
    // playMoveSound();

    data
      ..momentum += node.momentumFactor - (node.elevation - location!.elevation)
      ..momentum = min(max(momentum, 0), maxMomentum);

    location = node;
    if (location != orderedDestination) {
      nextNode =
          game.activeBattle!.findPath(location!, orderedDestination!)!.first;
      setDirectionAdjacent(nextNode!);
      data.progress = 0.0;
    } else {
      clearOrders();
      return;
    }
  }

  /// calculate the current path cost and consider if a better
  /// path is now available
  void considerAlternativePaths() {
    if (nextNode == null) return;

    final double currentPathCost = game.activeBattle!.totalPathTravelCost(
      pathToNodeWithUnitAvoidance(
        game.activeBattle!,
        nextNode!,
        orderedDestination!,
      ),
    ) +
        (1 - progress) * location!.distanceToAdjacentLocation(nextNode!);
    final List<Node>? alternativePath = pathToNodeWithUnitAvoidance(
      game.activeBattle!,
      location!,
      orderedDestination!,
    );

    if (alternativePath != null) {
      if (currentPathCost >
          currentPathPreferenceFactor *
              game.activeBattle!.totalPathTravelCost(alternativePath) ||
          (nextNode!.unit != null &&
              nextNode!.unit!.nation == nation &&
              nextNode!.unit!.nextNode == null)) {
        //reset the path if costs less than current path or if blocked
        processMoveOrder(alternativePath);
      }
    }
  }

  bool get isMelee => meleeDps() > rangedDps();

  bool get isRanged => meleeDps() <= rangedDps();

  bool get isBombard => bombardFactor > 0.0;

  //benchmark damage per second vs a strength 5 unit
  double meleeDps([final int enemyStrength = 5]) =>
      (meleeStrength / enemyStrength) *
          meleeDamageFactor *
          meleeSpeed *
          1.0 /
          GameConsts.secondsToCommand;

  /// start a melee attack targeting an adjacent enemyUnit
  void attack(final Node targetNode) {
    if (location == null) return;

    //TODO(pgainullin): investigate why this is called instead of
    // spear() sometimes
    setDirectionToAnyNode(targetNode);

    addLance(targetNode);
  }

  /// start a melee attack targeting an non-adjacent enemyUnit
  void spear(final Node targetNode) {
    if (location == null) return;

    setDirectionToAnyNode(targetNode);

    addLance(targetNode);
  }

  double elevationDamageFactor(final Unit attacker, final Unit victim) {
    if (attacker.location == null) return 0.0;
    if (victim.location == null) return 0.0;

    return 1 +
        (attacker.location!.elevation - victim.location!.elevation) *
            elevationBonus;
  }

  double fortificationDamageFactor(final Unit attacker, final Unit victim) {
    if (attacker.location == null) return 0.0;
    if (victim.location == null) return 0.0;

    return 1 +
        ((attacker.location!.fortificationSegment == null
            ? 0
            : location!.fortificationSegment!.life / 100) -
            (victim.location!.fortificationSegment == null
                ? 0
                : victim.location!.fortificationSegment!.life / 100)) *
            fortificationBonus;
  }

  /// calculate melee attacking damage versus a given unit
  double attackingMeleeDamage(final Unit targetUnit, {
    final bool isSpearing = false,
  }) {
    if (isSpearing == false) {
      return (meleeStrength / targetUnit.meleeStrength) *
          (isCommandUnit ? army!.commander!.unitMeleeBonus : 1.0) *
          pow(1 + chargeBonus, max(momentum - targetUnit.momentumBreak, 0)) *
          pow(1 - flankingPenalty, flankCount) *
          elevationDamageFactor(this, targetUnit) *
          fortificationDamageFactor(this, targetUnit) *
          meleeDamageFactor;
    } else {
      return (meleeStrength / targetUnit.meleeStrength) *
          (isCommandUnit ? army!.commander!.unitMeleeBonus : 1.0) *
          elevationDamageFactor(this, targetUnit) *
          fortificationDamageFactor(this, targetUnit) *
          spearDamageFactor;
    }
  }

  /// calculate the damage received by this unit when it is hitting a given
  /// defendingUnit in melee
  double defensiveMeleeDamage(final Unit defendingUnit) {
    return defendingUnit.isFighting
        ? defensiveMeleeDamageFactor *
        (defendingUnit.meleeStrength / meleeStrength) *
        (isCommandUnit ? 1 / army!.commander!.unitMeleeBonus : 1.0) *
        pow(1 - flankingPenalty, defendingUnit.flankCount) *
        elevationDamageFactor(this, defendingUnit) *
        fortificationDamageFactor(this, defendingUnit) *
        meleeDamageFactor
        : 0.0;
  }

  /// called when this unit's attack lands on another node where it hits
  /// the unit on there or misses if the unit managed to move out
  void attackResult(final Node targetNode) {
    if (location == null) return;

    if (targetNode.unit != null) {
      final Unit hitUnit = targetNode.unit!;

      final bool isSpearing = !targetNode.isAdjacent(location!);

      // higher than in the meleeDps to account for the expected
      // number of flanking units
      final double damageToThem =
      attackingMeleeDamage(hitUnit, isSpearing: isSpearing);

      final double damageToUs =
      isSpearing ? 0.0 : defensiveMeleeDamage(hitUnit);

      receiveDamage(damageToUs);
      hitUnit.receiveDamage(damageToThem);

      if (hitUnit.health <= 0.0) {
        receiveMoraleBoost(killMoraleBoost);
        if (isCommandUnit) {
          army!.commander!.improveMeleeSkill();
        }
        game.logs.add(
          isSpearing
              ? S.current.logSpearKill(
            nation.name,
            name,
            hitUnit.nation.name,
            hitUnit.name,
            '(${location!.x}:${location!.y})',
          )
              : S.current.logMeleeAttackKill(
            nation.name,
            name,
            hitUnit.nation.name,
            hitUnit.name,
            '(${location!.x}:${location!.y})',
          ),
        );
        if (hitUnit.isCommandUnit) {
          game.activeBattle!.commanderKill(hitUnit);
        }
      }

      if (health <= 0.0) {
        game.logs.add(
          S.current.logMeleeDefenceKill(
            nation.name,
            name,
            hitUnit.nation.name,
            hitUnit.name,
            '(${hitUnit.location?.x}:${hitUnit.location?.y})',
          ),
        );
        game.setTemporaryData((final s) => null);
        if (isCommandUnit) game.activeBattle!.commanderKill(this);
      }
    }

    if (isRenderAllowed) {
      singleTrackSfxController.stop(singleTrackLoopingSfxType.melee);
    }

    if (!engaged && nextNode != null) setDirectionAdjacent(nextNode!);
  }

  //benchmark ranged damage per second vs a strength 5 unit
  double rangedDps([final int enemyStrength = 5]) =>
      (rangedStrength / enemyStrength) *
          rangedDamageFactor *
          rangedSpeed /
          GameConsts.secondsToCommand;

  void shoot(final Node targetNode) {
    if (location == null) return;

    setDirectionToAnyNode(targetNode);

    addShot(targetNode);
  }

  /// process the results of this unit shooting the targetNode.
  /// Since the original target may have moved the shot may miss or
  /// hit a different target
  void shotResult(final Node targetNode) {
    if (targetNode.unit != null) {
      //hit a unit
      final Unit hitUnit = targetNode.unit!;
      if (hitUnit.location == null) return;

      double damageToThem = (rangedStrength / hitUnit.meleeStrength) *
          (isCommandUnit ? army!.commander!.unitRangedBonus : 1.0) *
          (1 - (hitUnit.location!.coverFactor() * coverBonus)) *
          fortificationDamageFactor(this, hitUnit) *
          ((game.activeBattle!.province.weather is Rain)
              ? rangedRainPenalty
              : 1.0) *
          ((game.activeBattle!.province.weather is Snow)
              ? rangedSnowPenalty
              : 1.0) *
          rangedDamageFactor;

      if (progress != 0.0) {
        // shoot and move penalty
        damageToThem *= moveAndShootPenalty;
      }

      if (bombardFactor > 0.0 &&
          hitUnit.location!.fortificationSegment != null) {
        hitUnit.location!.fortificationSegment!
            .receiveDamage(bombardFactor * rangedStrength * rangedDamageFactor);
      }

      hitUnit.receiveDamage(damageToThem);
      if (hitUnit.health <= 0.0) {
        receiveMoraleBoost(killMoraleBoost);
        if (isCommandUnit) {
          army!.commander!.improveRangedSkill();
        }
        game.logs.add(
          S.current.logRangedKill(
            nation.name,
            name,
            hitUnit.nation.name,
            hitUnit.name,
            '(${hitUnit.location?.x}:${hitUnit.location?.y})',
          ),
        );
        game.setTemporaryData((final s) => null);
        if (hitUnit.isCommandUnit) {
          game.activeBattle!.commanderKill(hitUnit);
        }
      }
    } else if (bombardFactor > 0.0 && targetNode.fortificationSegment != null) {
      //bombard hit walls

      targetNode.fortificationSegment!
          .receiveDamage(bombardFactor * rangedStrength * rangedDamageFactor);
    }

    if (!engaged && nextNode != null) setDirectionAdjacent(nextNode!);
  }

  void receiveDamage(final double damage) {
    assert(
    damage >= 0.0,
    'receiveDamage called with negative damage ($damage)',
    );

    data.health = max(0.0, health - damage);

    if (flankCount > 0) {
      //damage morale proportional to health damage and flank count
      receiveMoraleDamage(
        1.0 * damage * flankCount,
      );
    }

    if (health <= 0) {
      clearOrders();
    }
  }

  void healDamage(final double healthBoost) {
    assert(
    healthBoost >= 0.0,
    'healDamage called with negative healthBoost ($healthBoost)',
    );

    data.health = min(100.0, health + healthBoost);
  }

  void receiveMoraleDamage(final double moraleDamage) {
    double finalMoraleHit = moraleDamage;
    assert(
    finalMoraleHit >= 0.0,
    'receiveMoraleDamage called with negative morale hit ($moraleDamage)',
    );

    if (isCommandUnit) {
      finalMoraleHit *= 1 - commanderMoraleResistanceFactor;
    }
    data.morale = max(0.0, morale - finalMoraleHit);

    if (morale <= 0.0) {
      clearOrders();
    }
  }

  void receiveMoraleBoost(final double moraleBoost) {
    data.morale = min(100.0, morale + moraleBoost);
  }

  /// check that the unit is still in the game
  bool get isFighting {
    if (health > 0 && morale > 0) return true;
    return false;
  }

  /// return true if this is a unit of this nation OR allied
  bool isFriendlyToUnit(final Unit otherUnit) {
    if (nation.isFriendlyTo(otherUnit.nation)) return true;
    return false;
  }

  /// return true if this is a unit of a hostile nation
  bool isHostileToUnit(final Unit otherUnit) {
    if (nation.isHostileTo(otherUnit.nation)) return true;
    return false;
  }

  Vector2 get spriteSize => unscaledSpriteSize * spriteScale;

  Vector2 get unscaledSpriteSize {
    final resolvedImage = type.sprites[direction]?.image;
    return (resolvedImage != null)
        ? Vector2(
      resolvedImage.width.toDouble(),
      resolvedImage.height.toDouble(),
      // Transoxiana.tileSize / 1.3,
      // Transoxiana.tileSize / 0.65,
    )
        : Vector2(
      unitSpriteWidthScaled,
      unitSpriteHeightScaled,
      // Transoxiana.tileSize,
      // Transoxiana.tileSize *
      //     unitSpriteHeightScaled /
      //     unitSpriteWidthScaled
    );
  }

  double get spriteScale =>
      (health > 0.0 ? liveSpriteScale : deadSpriteScale) *
          (game.activeBattle?.hexTiledComponent.tileScale ?? 1) /
          1.2;

  double get liveSpriteScale {
    return (type.sprites[direction] != null
        ? unitSpriteScaleWithDirections
        : 1.0) *
        0.5;
  }

  double get deadSpriteScale {
    return (type.sprites[direction] != null
        ? unitSpriteScaleWithDirections
        : 1.0) /
        3.0;
  }

  TileInfo? get locationInfo =>
      game.activeBattle?.tileData[location?.terrainTile];

  bool get renderAllowed => !game.isHeadless && !game.activeBattle!.isAiBattle;

  @override
  void render(final Canvas canvas) {
    if (!renderAllowed) return;
    final tileInfo = locationInfo;
    if (tileInfo == null) return;

    // log('Rendering unit ${this.name} at ${this.location}');
    final tileCenter = tileInfo.center;
    final tileCollisionDiameter = tileInfo.collisionDiameter;
    if (tileCenter == null || tileCollisionDiameter == null) {
      throw ArgumentError.notNull(
        'tileCenter: $tileCenter '
            'tileCollisionDiameter: $tileCollisionDiameter',
      );
    }
    UnitPainter(
      game: game,
      center: tileCenter,
      diameter: tileCollisionDiameter,
      // scale: spriteScale,
      unit: this,
      // spriteSize: const Offset(
      //   UiSizes.tileSize,
      //   UiSizes.tileSize,
      // ),
      // marker: markerType.unit,
    ).paint(canvas, Size.zero);
    super.render(canvas);
  }

  /// adds the relevant melee attack and triggers a callback
  /// to process the results of a hit
  void addLance(final Node enemyLocation) {
    final Lance newLance = Lance(
      game,
      location!,
      enemyLocation,
      hitCallback: () => attackResult(enemyLocation),
      onRemoveCallback: _removeLance,
    );

    if (isRenderAllowed) {
      singleTrackSfxController.play(singleTrackLoopingSfxType.melee);
    }

    _addLance(newLance);
  }

  void _addLance(final Lance lance) {
    final battle = game.activeBattle;
    if (battle == null) return;
    battle.lances.add(lance);
    if (battle.isPlayerBattle) {
      battle.add(lance);
    }
  }

  void _removeLance(final Lance lance) {
    final battle = game.activeBattle;
    if (battle == null) return;
    battle.lances.remove(lance);
    if (battle.isPlayerBattle) {
      // battle.remove(lance);
      lance.removeFromParent();
    }
  }

  /// adds the relevant projectiles for the shot that then trigger a callback
  /// when they hit
  void addShot(final Node targetNode) {
    final Projectile newShot = bombardFactor > 0.0
        ? Cannonball(
      game,
      location!,
      targetNode,
      hitCallback: () => shotResult(targetNode),
      onRemoveCallback: _removeShot,
    )
        : Arrows(
      game,
      location!,
      targetNode,
      hitCallback: () => shotResult(targetNode),
      onRemoveCallback: _removeShot,
    );

    _addShot(newShot);
  }

  void _addShot(final Projectile shot) {
    final battle = game.activeBattle;
    if (battle == null) return;
    battle.shots.add(shot);
    if (battle.isPlayerBattle) {
      unawaited(battle.add(shot));
    }
  }

  void _removeShot(final Projectile shot) {
    final battle = game.activeBattle;
    if (battle == null) return;
    battle.shots.remove(shot);
    if (battle.isPlayerBattle) {
      shot.removeFromParent();
    }
  }

  @override
  List<Object?> get props => [id];

  @override
  bool? get stringify => true;
}
