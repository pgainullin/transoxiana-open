import 'package:collection/collection.dart';
import 'package:flame/components.dart';
import 'package:tiled/tiled.dart';
import 'package:transoxiana/components/battle/unit.dart';
import 'package:transoxiana/components/shared/fortification.dart';
import 'package:transoxiana/components/shared/traversable_map.dart';
import 'package:transoxiana/services/battle_map_services.dart';

///
///
/// Node is the basic data unit for the BattleMap. Isolates use PrimitiveNode
/// which Node's basic bitch cousin which only has path finding info and
/// no closures (achieved by setting the .node to null before sending it into
/// an isolate
///
///

enum TerrainType {
  grass,
  dirt,
  water,
  snow, //unimplemented
  sand, //unimplemented
}

enum SuperStructureType {
  hill,
  mountain,
  forest,
  road,
  building,
  empty,
}

//int idCounter = 0;
class Node extends SuperMapLocation<Node> implements MapLocation<Node> {
  Node(this.x, this.y, this.terrainTile, this.superStructureTile) : super() {
    terrain = TerrainType.values.firstWhere(
      (final element) =>
          element.name ==
          terrainTile.properties['terrainType'].toString().trim(),
      orElse: () => throw Exception(
          "No terrainType found for '${terrainTile.properties['terrainType']}'"),
    ); // ?? tileData[terrainTile]['terrainType'];
    // if (superStructureTile.properties.isNotEmpty) {
    // print('');
    // }
    superStructure = SuperStructureType.values.firstWhereOrNull(
          (final element) =>
              element.name ==
              superStructureTile.properties['terrainType'].toString().trim(),
        ) ??
        SuperStructureType.empty;

    if (terrain == TerrainType.grass) momentumFactor = 1;
    switch (superStructure) {
      case SuperStructureType.hill:
        {
          elevation = 1;
          momentumFactor = -1;
        }
        break;
      case SuperStructureType.mountain:
        {
          elevation = 2;
          momentumFactor = -3;
        }
        break;
      case SuperStructureType.building:
        {
          momentumFactor -= 1;
        }
        break;
      case SuperStructureType.forest:
        {
          momentumFactor = 0;
        }
        break;
      case SuperStructureType.road:
        {
          momentumFactor += 1;
        }
        break;
      default:
        {
          elevation = 0;
        }
    }

    //    id = idCounter;
    //    idCounter += 1;
  }

  factory Node.from(final Node otherNode, {final bool clearFort = false}) {
    final copyNode = Node(
      otherNode.x,
      otherNode.y,
      otherNode.terrainTile,
      otherNode.superStructureTile,
    )
      ..adjacentDistances.addAll(otherNode.adjacentDistances)
      ..previousStep.addAll(otherNode.previousStep)
      ..travelCostToLocation.addAll(otherNode.travelCostToLocation);

    if (clearFort == false) {
      copyNode.fortificationSegment = otherNode.fortificationSegment;
    }

    return copyNode;
  }

  /// game width coordinate that does not reflect positioning on screen
  final int x;

  /// game height coordinate that does not reflect positioning on screen
  final int y;
  Vector2 get position => Vector2(x.toDouble(), y.toDouble());
  late TerrainType terrain;
  late SuperStructureType superStructure;

  Segment? fortificationSegment;

  /// +1 = hills
  int elevation = 0;

  /// 1 = grass, -1 = mud (dirt+rain), up hills, fortifications, +2 = down hills, 0 = forest, dirt. hills to be handled separately via elevation though
  int momentumFactor = 0;

  final Tile terrainTile;
  final Tile superStructureTile;

  Unit? unit;
//  int id;

  //for AI training API
  Map<String, dynamic> toJson() {
    return Map<String, dynamic>.fromEntries([
      MapEntry('x', x),
      MapEntry('y', y),
      MapEntry('fortSegment', fortificationSegment),
      MapEntry('terrainType', terrain.index),
      MapEntry('superStructure', superStructure.index),
    ]);
  }

  @override
  bool get isTraversable {
    if (terrain == TerrainType.water &&
        superStructure != SuperStructureType.road) return false;
    return true;
  }

  double coverFactor() {
    if (superStructure == SuperStructureType.forest) return 1.0;
    if (superStructure == SuperStructureType.building) return 0.85;

    return 0.0;
  }

  List<Node> get adjacentNodes =>
      adjacentLocations.map((final e) => e).toList();

  // @override
  // bool operator ==(Object other) =>
  //     other is Node && other.x == x && other.y == y;
  //
  // @override
  // int get hashCode => hash2(x.hashCode, y.hashCode);

  @override
  double distanceToAdjacentLocation(final Node otherNode) =>
      nodeTravelCost(this, otherNode);

  @override
  String toString() => '<$hashCode> ($x:$y) ($terrain, $superStructure)';
}

/// comparator sorting Units by distance to a given myUnit
int travelCostComparatorByUnits(
  final Unit myUnit,
  final Unit a,
  final Unit b,
) =>
    travelCostComparatorByNodes(myUnit.location!, a.location!, b.location!);

/// comparator sorting Units by distance to a given myUnit
int travelCostComparatorByNodes(
  final Node startingNode,
  final Node a,
  final Node b,
) {
  final travelCostA = startingNode.totalTravelCost(a);
  final travelCostB = startingNode.totalTravelCost(b);
  if (travelCostB == null) return travelCostA?.toInt() ?? 0;
  if (travelCostA == null) return -1;
  return travelCostA.compareTo(travelCostB);
}
