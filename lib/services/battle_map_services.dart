import 'package:collection/collection.dart';
import 'package:flame/components.dart';
import 'package:tiled/tiled.dart';
import 'package:transoxiana/components/battle/battle.dart';
import 'package:transoxiana/components/battle/node.dart';
import 'package:transoxiana/components/battle/unit.dart';
import 'package:transoxiana/components/game/game.dart';
import 'package:transoxiana/components/shared/fortification.dart';
import 'package:transoxiana/data/constants.dart';
import 'package:transoxiana/data/direction.dart';
import 'package:utils/utils.dart';

/// Node-map specific services

/// get the shortest path not blocked by a stationary friendly unit.
/// if all paths are blocked, return the shortest one
List<Node>? pathToNodeWithUnitAvoidance(
  final Battle map,
  final Node start,
  final Node destination,
) {
  final List<List<Node>> viablePaths = [];

  if (start == destination) return null;
  final List<Node>? currentPath = map.findPath(start, destination);

  if (currentPath == null || currentPath.isEmpty) {
    return null;
  } //no point searching alternatives if not path is physically possible.

  // this can be null if a unit is checking future paths
  final Unit? movingUnit = start.unit;

  // this takes care of current blockages but not expected blockages. potential solution - add predicted unit paths to a modified version of travelCost() function
  // specify level of recursion to recalculate each unit's path based on the current-best path for this unit: high recursion depths would be very intensive computationally.
  if (movingUnit != null &&
      currentPath.first.unit != null &&
      unitIsBlocking(movingUnit, currentPath.first.unit!)) {
    final Set<Node> alternativeFirstNodes =
        start.adjacentDistances.keys.toSet();

    // if (currentPath != null && currentPath.isNotEmpty)
    //   alternativeFirstNodes.remove(currentPath.first);

    assert(
      alternativeFirstNodes
          .where(
            (final alternativeNode) => !map.locations.contains(alternativeNode),
          )
          .isEmpty,
    ); //check that the alternative is in the node set
    alternativeFirstNodes
        .removeWhere((final alternativeNode) => !alternativeNode.isTraversable);
    //TODO: generalise for sea-going units
    // alternativeFirstNodes.removeWhere((Node alternativeNode) =>
    //     unitIsBlocking(movingUnit, alternativeNode.unit));
//    log('finally: ${alternativeFirstNodes.length}');

    if (alternativeFirstNodes.isNotEmpty) {
      // and there are valid alternative starting points
      for (final firstNode in alternativeFirstNodes) {
        final List<Node>? path = map.findPath(firstNode, destination);
        if (path != null) viablePaths.add([firstNode] + path);
      }
    }
  }

  // viablePaths.removeWhere((List<Node> path) =>
  //     path.contains(start)); //remove paths that return to the starting point
//  viablePaths.removeWhere((List<Node> path) => path.contains(currentPath
//      .first)); //remove paths that return to the originally-blocked node //do not remove as upon reaching the next tile unit will recalculate. consider how best to show this

  if (viablePaths.isNotEmpty) {
    // log('${viablePaths.length} alternative paths returned - sorting');
    // viablePaths.sort((List<MapLocation> a, List<MapLocation> b) =>
    //     map.totalPathTravelCost(a).compareTo(map.totalPathTravelCost(b)));
    viablePaths.sort(
      (final a, final b) => pathBlockValue(map, a, movingUnit!)
          .compareTo(pathBlockValue(map, b, movingUnit)),
    );
    // log('Sorting complete. 1st: ${pathBlockValue(map, viablePaths[0], movingUnit)}, 2nd: ${pathBlockValue(map, viablePaths[1], movingUnit)}');
    assert(viablePaths.first.first.adjacentLocations.contains(start));
    return viablePaths.first;
  } else {
    return currentPath;
  }
}

/// blocking value of nodes on a given path
double pathBlockValue(
  final Battle map,
  final List<Node> path,
  final Unit movingUnit,
) {
  return path.fold<double>(
        0.0,
        (final previousValue, final element) =>
            previousValue +
            (element.unit == null
                ? 0.0
                : blockingValue(movingUnit, element.unit!)),
      ) +
      map.totalPathTravelCost(path);
}

bool unitIsBlocking(final Unit movingUnit, final Unit blockingUnit) {
  if (blockingUnit.nation == movingUnit.nation && //of the same player
          blockingUnit.health > 0.0 && //that has positive health
          blockingUnit.nextNode == null //that is not moving away}
      ) return true;
  return false;
}

double blockingValue(final Unit movingUnit, final Unit blockingUnit) {
  if (blockingUnit.nation == movingUnit.nation && //of the same player
          blockingUnit.health > 0.0 //that has positive health
      ) {
    if (blockingUnit.nextNode == null) {
      //that is not moving away}
      return stationaryBlockingUnitValue;
    } else {
      return movingBlockingUnitValue;
    }
  } else {
    return 0.0;
  }
}

/// travel cost between two adjacent tile nodes expressed in road-road multiples
double nodeTravelCost(final Node start, final Node finish) {
  if ((start.terrain == TerrainType.water ||
          finish.terrain == TerrainType.water) &&
      (start.superStructure != SuperStructureType.road ||
          finish.superStructure != SuperStructureType.road)) {
    return double.infinity;
    // log(finish);
  }

  if (finish.fortificationSegment != null &&
      finish.fortificationSegment!.life > 0.0) {
    //finishing in a fortification

    if (start.fortificationSegment != null &&
        start.fortificationSegment!.life > 0.0) {
      //already on the walls

      if (start.fortificationSegment!.firstConnectedNode == finish ||
          start.fortificationSegment!.secondConnectedNode == finish) {
        return 2.0; //walk on the walls as on regular terrain
      } else {
        return 50.0; // jumping between walls is really slow
      }
    } else {
      if (finish.fortificationSegment!.entrance == start) {
        return 1.0; //always quick to get up the walls from the designated entrance
      } else {
        if (finish.fortificationSegment!.type == FortificationType.gate &&
            finish.fortificationSegment!.open == true) {
          return 1.0; //easy to get through the open gates
        } else {
          return 40.0; // very hard otherwise
        }
      }
    }
  }

  if (start.superStructure == SuperStructureType.road &&
      finish.superStructure == SuperStructureType.road) {
    return 1.0;
  } else if (finish.superStructure == SuperStructureType.hill) {
    return 3.0;
  } else if (finish.superStructure == SuperStructureType.mountain) {
    return 15.0;
  } else if (finish.superStructure == SuperStructureType.forest) {
    return 2.5;
  } else {
    return 2.0;
  }
}

Node? closestEmptyNode(final Node node, final TransoxianaGame game) {
  Node currentNode = node;
  final Set<Node> explorationSpace = {};
  explorationSpace.addAll(
    game.activeBattle!.nodes.where((final element) => element.isTraversable),
  );

  while (explorationSpace.isNotEmpty) {
    // int lastTileIndex = explorationSpace.indexOf(tile);
    final Node lastNode = currentNode;

    if (currentNode.unit == null && currentNode.isTraversable) {
      return currentNode;
    } else {
      explorationSpace.remove(currentNode);
      if (explorationSpace.isEmpty) {
        return null;
      } else {
        final Set<Node> intersection =
            explorationSpace.intersection(adjacentNodes(lastNode, game));

        currentNode = intersection.isNotEmpty
            ? intersection.randomElement()!
            : explorationSpace.randomElement()!;
        // explorationSpace[min(explorationSpace.length - 1, lastTileIndex)];
      }
    }
  }
  return null;
}

// deprecated
Set<Tile> adjacentTiles(final Tile tile, final TransoxianaGame game) {
  final terrainTiles = game.activeBattle!.terrainTiles;
  assert(
    terrainTiles.expand((final element) => element).contains(tile),
  );

  final List<Tile> collector = [];
  if (tile.x.isOdd) {
    if (tile.x - 1 >= 0) {
      collector.add(terrainTiles[tile.y][tile.x - 1]);
    }
    if (tile.y + 1 < terrainTiles.length && tile.x - 1 >= 0) {
      collector.add(terrainTiles[tile.y + 1][tile.x - 1]);
    }

    if (tile.y - 1 >= 0) {
      collector.add(terrainTiles[tile.y - 1][tile.x]);
    }
    if (tile.y + 1 < terrainTiles.length) {
      collector.add(terrainTiles[tile.y + 1][tile.x]);
    }

    if (tile.x + 1 < terrainTiles[tile.y].length) {
      collector.add(terrainTiles[tile.y][tile.x + 1]);
    }
    if (tile.y + 1 < terrainTiles.length &&
        tile.x + 1 < terrainTiles[tile.y + 1].length) {
      collector.add(terrainTiles[tile.y + 1][tile.x + 1]);
    }
  } else {
    if (tile.y - 1 >= 0 && tile.x - 1 >= 0) {
      collector.add(terrainTiles[tile.y - 1][tile.x - 1]);
    }
    if (tile.x - 1 >= 0) {
      collector.add(terrainTiles[tile.y][tile.x - 1]);
    }

    if (tile.y - 1 >= 0) {
      collector.add(terrainTiles[tile.y - 1][tile.x]);
    }
    if (tile.y + 1 < terrainTiles.length) {
      collector.add(terrainTiles[tile.y + 1][tile.x]);
    }

    if (tile.y - 1 >= 0 && tile.x + 1 < terrainTiles[tile.y - 1].length) {
      collector.add(terrainTiles[tile.y - 1][tile.x + 1]);
    }
    if (tile.x + 1 < terrainTiles[tile.y].length) {
      collector.add(terrainTiles[tile.y][tile.x + 1]);
    }
  }

  return collector.toSet();
}

Set<Node> adjacentNodes(final Node node, final TransoxianaGame game) {
  assert(game.activeBattle!.nodes.contains(node));
  final terrainTiles = game.activeBattle!.terrainTiles;

  final List<Node> collector = [];

  if (node.x.isOdd) {
    if (node.x - 1 >= 0) {
      collector.add(optimisedNodeByCoordinates(game, node.x - 1, node.y));
    }
    if (node.y + 1 < terrainTiles.length && node.x - 1 >= 0) {
      collector.add(optimisedNodeByCoordinates(game, node.x - 1, node.y + 1));
    }

    if (node.y - 1 >= 0) {
      collector.add(optimisedNodeByCoordinates(game, node.x, node.y - 1));
    }
    if (node.y + 1 < terrainTiles.length) {
      collector.add(optimisedNodeByCoordinates(game, node.x, node.y + 1));
    }

    if (node.x + 1 < terrainTiles[node.y].length) {
      collector.add(optimisedNodeByCoordinates(game, node.x + 1, node.y));
    }
    if (node.y + 1 < terrainTiles.length &&
        node.x + 1 < terrainTiles[node.y + 1].length) {
      collector.add(optimisedNodeByCoordinates(game, node.x + 1, node.y + 1));
    }
  } else {
    if (node.y - 1 >= 0 && node.x - 1 >= 0) {
      collector.add(optimisedNodeByCoordinates(game, node.x - 1, node.y - 1));
    }
    if (node.x - 1 >= 0) {
      collector.add(optimisedNodeByCoordinates(game, node.x - 1, node.y));
    }

    if (node.y - 1 >= 0) {
      collector.add(optimisedNodeByCoordinates(game, node.x, node.y - 1));
    }
    if (node.y + 1 < terrainTiles.length) {
      collector.add(optimisedNodeByCoordinates(game, node.x, node.y + 1));
    }

    if (node.y - 1 >= 0 && node.x + 1 < terrainTiles[node.y - 1].length) {
      collector.add(optimisedNodeByCoordinates(game, node.x + 1, node.y - 1));
    }
    if (node.x + 1 < terrainTiles[node.y].length) {
      collector.add(optimisedNodeByCoordinates(game, node.x + 1, node.y));
    }
  }

  assert(
    collector
        .where((final element) => !game.activeBattle!.nodes.contains(element))
        .isEmpty,
  );

  collector.removeWhere((final element) => element.x < 0 || element.y < 0);
  return collector.toSet();
}

/// returns Direction between two *adjacent* nodes
/// without referring to their actual screen positioning
Direction directionBetweenAdjacentNodes(final Node from, final Node to) {
  assert(to != from);

  if (from.x == to.x) {
    if (from.y > to.y) return Direction.north;
    return Direction.south;
  } else {
    if (from.x.isEven) {
      if (from.x < to.x) {
        if (from.y == to.y) {
          return Direction.southEast;
        } else {
          return Direction.northEast;
        }
      } else {
        if (from.y == to.y) {
          return Direction.southWest;
        } else {
          return Direction.northWest;
        }
      }
    } else {
      if (from.x < to.x) {
        if (from.y < to.y) {
          return Direction.southEast;
        } else {
          return Direction.northEast;
        }
      } else {
        if (from.y < to.y) {
          return Direction.southWest;
        } else {
          return Direction.northWest;
        }
      }
    }
  }
  // game, tile.x + 1, tile.x.isEven ? tile.y - 1 : tile.y);
}

/// direction between any two nodes on the same battle map as determined by
/// their on-screen positioning
Direction directionBetweenAnyNodes(
    final Battle battle, final Node from, final Node to,) {
  final Vector2? fromTileOffset = battle.tileData[from.terrainTile]?.center;
  final Vector2? toTileOffset = battle.tileData[to.terrainTile]?.center;
  if (fromTileOffset == null || toTileOffset == null) {
    throw ArgumentError.notNull(
      'fromTileOffset: $fromTileOffset '
      'toTileOffset: $toTileOffset',
    );
  }
  return offsetToDirection(fromTileOffset - toTileOffset);
}

/// returns all nodes within range of a given node - used for shooting / spearing distant enemies
/// assumes the shooter is at the center of the area
Set<Node> targetArea(final Node node, final int range) {
  //TODO: add elevation and cover factors

  final Set<Node> testedNodes = {node};
  final Set<Node> targetArea = {};

  //directly adjacent tiles are always within range
  targetArea.addAll(
    node.adjacentDistances.keys,
  );

  //recursively add all adjacent tiles within the given range
  for (int i = 1; i < range; i++) {
    final Set<Node> collector = {};
    for (final Node testNode in targetArea.difference(testedNodes)) {
      // targetArea.difference(testedNodes).forEach((
      //   MapLocation<Node> testNode,
      // ) {
      collector.addAll(testNode.adjacentDistances.keys);

      testedNodes.add(testNode);
    }
    targetArea.addAll(collector);
  }

  // log('$node $range target area has ${targetArea.length} nodes');
  return targetArea;
}

/// returns all nodes within range of a given node - used for shooting /
/// spearing distant enemies. Extends the range by the nodes at the outer edge
/// that have fortifications.
/// assumes the shooter is at the edges and is targeting the centre of the area
Set<Node> targetAreaWithFortExtension(final Node node, final int range) {
  //TODO: add elevation and cover factors

  final Set<Node> testedNodes = {node};
  final Set<Node> targetArea = {}

    //directly adjacent tiles are always within range
    ..addAll(node.adjacentDistances.keys);

  final Set<Node> outerRing = {};

  //recursively add all adjacent tiles within the given range
  for (int i = 1; i <= range; i++) {
    final Set<Node> collector = {};
    if (i == range) {
      for (final Node testNode in targetArea.difference(testedNodes)) {
        // targetArea.difference(testedNodes).forEach((Node testNode) {
        outerRing.addAll(testNode.adjacentDistances.keys);
      }
    } else if (i < range) {
      for (final Node testNode in targetArea.difference(testedNodes)) {
        // targetArea.difference(testedNodes).forEach((Node testNode) {
        collector.addAll(testNode.adjacentDistances.keys);
        testedNodes.add(testNode);
      }
      targetArea.addAll(collector);
    }
  }

  // only fortified nodes that give +1 range are left in the outer ring of the target area
  targetArea.addAll(
    outerRing.where(
      (final element) =>
          element.fortificationSegment != null &&
          element.fortificationSegment!.life > 0.0,
    ),
  );

  // log('$node $range target area has ${targetArea.length} nodes');
  return targetArea;
}

//TODO: fix
// use coordinate bounds to go collect nodes within a certain range of a given node without passing the same node twice
Set<Node> optimisedTargetArea(
    final TransoxianaGame game, final Node node, final int range,) {
  // int currentX = node.x;
  // int currentY = node.y;

  final Set<Node> collector = {};

  for (int currentX = node.x - range;
      currentX <= node.x + range;
      currentX += 1) {
    for (int currentY = node.y - range + (currentX - node.x).abs();
        currentY <= node.y + range - (currentX - node.x).abs();
        currentY += 1) {
      //this is wrong
      if (currentX >= 0 &&
          currentY >= 0 &&
          currentX < game.activeBattle!.hexTiledComponent.map.width &&
          currentY < game.activeBattle!.hexTiledComponent.map.height) {
        collector.add(optimisedNodeByCoordinates(game, currentX, currentY));
      }
    }
  }

  return collector;
  // }
}

///use what we know about the Tiled map coordinates system + Node set structure
/// to quickly return the right node: tiles are loaded in rows so nodes
/// get generated in a typewriter sequence from x = 0 to x = map width in tiles
Node optimisedNodeByCoordinates(
    final TransoxianaGame game, final int x, final int y,) {
  assert(game.activeBattle != null);
  final Node candidate = game.activeBattle!.nodes
      .elementAt(y * game.activeBattle!.hexTiledComponent.map.width + x);
  // log('${y * game.activeBattle.map.tileWidth + x}th node is $candidate ($x,$y) - tileWidth is ${game.activeBattle.map.width}');
  assert(candidate.x == x);
  assert(candidate.y == y);

  return candidate;
}

Node nodeByCoordinates(final TransoxianaGame game, final int x, final int y) {
//  log('Retrieving from ${map.nodes.first}');
  final Node? node = game.activeBattle!.nodes
      .firstWhereOrNull((final node) => node.x == x && node.y == y);

  if (node == null) {
    throw Exception('Null node retrieved for $x:$y');
  }

  return node;
}

//SINGLE-TILE MOVEMENTS (excl pure y axis)

Tile? topRightTile(final TransoxianaGame game, final Tile tile) {
  return tileByCoordinates(
    game,
    tile.x + 1,
    tile.x.isEven ? tile.y - 1 : tile.y,
  );
}

Tile? topLeftTile(final TransoxianaGame game, final Tile tile) {
  return tileByCoordinates(
    game,
    tile.x - 1,
    tile.x.isEven ? tile.y - 1 : tile.y,
  );
}

Tile? bottomRightTile(final TransoxianaGame game, final Tile tile) {
  return tileByCoordinates(
    game,
    tile.x + 1,
    tile.x.isEven ? tile.y : tile.y + 1,
  );
}

Tile? bottomLeftTile(final TransoxianaGame game, final Tile tile) {
  return tileByCoordinates(
    game,
    tile.x - 1,
    tile.x.isEven ? tile.y : tile.y + 1,
  );
}

// returns the terrain tile form given coordinates or null for overflows beyond the map
Tile? tileByCoordinates(final TransoxianaGame game, final int x, final int y) {
  if (x < 0 || y < 0) return null;

  if (y > game.activeBattle!.terrainTiles.length ||
      x > game.activeBattle!.terrainTiles[y].length) return null;

  return game.activeBattle!.terrainTiles[y][x];
}

// NODE-TILE IO
List<Tile>? nodePathToTilePath(final List<Node>? nodePath) {
  if (nodePath == null) return null;

  final List<Tile> collector = [];

  for (final node in nodePath) {
    if (node.x >= 0 && node.y >= 0) collector.add(node.terrainTile);
  }

  return collector;
}

Node? tileToNode(final TransoxianaGame game, final Tile tile) {
  return game.activeBattle!.nodes.firstWhereOrNull(
    (final element) => element.x == tile.x && element.y == tile.y,
  );
}
