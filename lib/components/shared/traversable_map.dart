import 'dart:async';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:quiver/core.dart';
import 'package:transoxiana/components/game/game.dart';
import 'package:utils/utils.dart';

/// Generic traversable map where each node on the map is of a type TMapLocation
/// which extends MapLocation. Map has to be initialized and paths precomputed
/// before they can be accessed.
///
/// Precomputing is set up to be done in isolates but this can be overridden.
///
/// Precomputing function takes callbacks that it will call right before and
/// right after the heavy computation which can be used to set loading screens

abstract class TraversableMap<TMapLocation extends MapLocation<TMapLocation>>
    with TraversableMapMixin<TMapLocation> {}

mixin TraversableMapMixin<TMapLocation extends MapLocation<TMapLocation>> {
  // static TraversableMap<T> fromJson<T extends MapLocation<T>>() =>
  //     throw UnimplementedError();
  // Map<String, dynamic> toJson() => throw UnimplementedError();

  final locations = <TMapLocation>{};
  final primitives = <PrimitiveLocation<TMapLocation>>{};
  final pathCache = PathCache<TMapLocation>();

  // TODO: add ability to have several different path structures on the same map
  // for example for different seasons or kinds of armies (fleets etc).

  /// called before anything else to populate the locations data of this class.
  void setLocations(
    final List<TMapLocation> newLocations,
  ) {
    locations.assignAll(newLocations);
    log(
      '${DateTime.now()}: <isolatePathFindingUpdate> '
      '${locations.length} nodes set',
    );
  }

  /// called on initialize to set adjacent Location data and produce
  /// primitives used for path finding
  void initializePrimitives() {
    primitives.clear();
    pathCache.clear();

    // first determine what locations are adjacent to this each location
    // and create primitives
    for (final location in locations) {
      final adjacentLocations = getAdjacentLocations(location);

      final adjacencies = adjacentLocations.map(
        (final e) => MapEntry(e, location.distanceToAdjacentLocation(e)),
      );
      location.adjacentDistances.addEntries(adjacencies);

      final currentPrimitive =
          PrimitiveLocation<TMapLocation>(location.hashCode);
      primitives.add(currentPrimitive);
      location.primitive = currentPrimitive;
    }

    // then add distances to each adjacent primitive
    for (final primitiveNode in primitives) {
      primitiveNode.adjacentPrimitiveDistances.addAll(
        locations
            .firstWhere(
              (final node) => node.hashCode == primitiveNode.richHashCode,
            )
            .adjacentDistances
            .map((final key, final value) => MapEntry(key.primitive!, value)),
      );
      // log('${primitiveNode.richHashCode} has
      // ${primitiveNode.adjacentPrimitiveDistances.length} adjacencies');
    }

    // log(
    //   '${DateTime.now()} Primitives initialized
    //   with ${primitives.length} entries',
    // );
  }

  /// called post initialization when the map has had updates that
  /// change adjacent node distances but not what node is adjacent to what
  void updateAdjacencies() {
    assert(primitives.isNotEmpty, 'primitives must not be empty');

    log('${DateTime.now()} Updating adjacency & distances');
    for (final primitive in primitives) {
      primitive.mapLocation = locations.firstWhere(
        (final location) => location.hashCode == primitive.richHashCode,
      );
    }
    for (final location in locations) {
      location.adjacentDistances.forEach((final key, value) {
        // double _oldValue = value;
        value = location.distanceToAdjacentLocation(key);
        location.adjacentDistances[key] = value;
        // if (_oldValue != value)
        //   log('Distance change from $node to $key:
        //   now $value not $_oldValue');
      });
    }
    for (final primitiveNode in primitives) {
      for (final distanceEntry
          in primitiveNode.adjacentPrimitiveDistances.entries) {
        final key = distanceEntry.key;
        final newValue = primitiveNode.mapLocation!
            .distanceToAdjacentLocation(key.mapLocation!);
        primitiveNode.adjacentPrimitiveDistances[key] = newValue;
        // assert(primitiveNode.adjacentPrimitiveDistances[key] == newValue);

        // if (_oldValue != value) {
        //   log(
        //       'Distance change from ${primitiveNode.node} to ${key.node}:
        //       now $value not $_oldValue');
        // }
      }
    }
  }

  /// Run the path updates
  Future<void> updatePaths() async {
    pathCache.clear();
    Iterable<PrimitiveLocation<TMapLocation>> updatedPrimitives;
    if (isHeadless) {
      //don't use isolates for the headless update as they are not awaited
      log('${DateTime.now()}: Sending data to Dijkstra on the main thread '
          'with ${primitives.length} entries');
      updatedPrimitives = [
        ...dijkstraUpdatePrimitive(primitives),
      ];
    } else {
      updatedPrimitives = await isolatePathFindingUpdate();
    }
    if (updatedPrimitives.first.errorTrace != null) {
      log(updatedPrimitives.first.errorTrace.toString());
    } else {
      updateLocations(updatedPrimitives);
    }
  }

  Future<Iterable<PrimitiveLocation<TMapLocation>>>
      isolatePathFindingUpdate() async => compute(
            dijkstraUpdatePrimitive,
            primitives,
          );

  Set<TMapLocation> getAdjacentLocations(final TMapLocation location) =>
      throw UnimplementedError();

  /// clear cache, update adjacencies and update paths. This is called after
  /// the very first update that used updatePaths;
  Future<void> cleanUpdate() async {
    pathCache.clear();
    initializePrimitives();
    updateAdjacencies();
    cleanPrimitives();
    await updatePaths();
  }

  /// update MapLocations from the primitive data received from Dijkstra
  void updateLocations(
    final Iterable<PrimitiveLocation<TMapLocation>> primitiveNodesWithUpdates,
  ) {
    log('Starting node update. ${primitiveNodesWithUpdates.length} updates '
        'received vs node count of ${locations.length}');

    final start = DateTime.now();

    for (final primitive in primitiveNodesWithUpdates) {
      // primitiveNodesWithUpdates.forEach((PrimitiveLocation<TMapLocation>
      //         primitive) =>
      primitive.mapLocation = locations.firstWhere(
        (final location) => location.hashCode == primitive.richHashCode,
        orElse: () => throw Exception(
          'Node with hashcode ${primitive.richHashCode} not found.',
        ),
      );
    }

    for (final primitiveNode in primitiveNodesWithUpdates) {
      // primitiveNodesWithUpdates.forEach((primitiveNode) {
      primitiveNode.mapLocation!
        ..travelCostToLocation.clear()
        ..previousStep.clear()
        ..previousStep.addAll(
          primitiveNode.previousStep.map(
            (final key, final value) => // + N
                MapEntry(key.mapLocation!, value?.mapLocation),
          ),
        )
        ..travelCostToLocation.addAll(
          primitiveNode.travelCostToPrimitive.map<TMapLocation, double>(
            // + N
            (final key, final value) => MapEntry(key.mapLocation!, value),
          ),
        );
    }

    log('Nodes updated in '
        '${DateTime.now().difference(start).inMilliseconds} milliseconds');
  }

  /// Returns the optimal path that includes the destination but not
  /// the start location
  List<TMapLocation>? findPath(
    final TMapLocation start,
    final TMapLocation destination,
  ) {
    if (start == destination) return [destination];
    final cachedPath = pathCache.load(start, destination);
    if (cachedPath != null && cachedPath.isNotEmpty) {
      // log('${start} to ${destination} returned cachedPath
      // ${cachedPath.map((e) => e).join(', ')}');
      return cachedPath;
    }
    // log(
    //     'Searching path from $start to $destination - node
    //     count: ${game.activeBattle.nodes.length}');

//  try {
    if (start.travelCostToLocation[destination] != null &&
        start.travelCostToLocation[destination]! < double.infinity) {
      var currentNode = destination;
      final reverseShortestNodePath = [currentNode];

      // log('Starting: ${start} (target - ${destination})');
      // log('${start.previousStep[currentVertex.data]}');
      int count = 0;
      //start.previousStep[currentVertex.data] != start &&
      while (start.previousStep[currentNode] != null && count < 65536) {
        count += 1; //circuit breaker
        // log('Next: ${start.previousStep[currentVertex.data]}');
        currentNode = start.previousStep[currentNode]!;
        reverseShortestNodePath.add(currentNode);
      }

//  } catch (e) {
//    log('ERROR: ${e.toString()}');
//  }

      if (reverseShortestNodePath.isNotEmpty) {
        assert(
          reverseShortestNodePath.last == start,
          'returned path does not start at the start node',
        );
        reverseShortestNodePath.removeLast();

        final shortestNodePath = reverseShortestNodePath.reversed.toList();
        // log(
        //     '${shortestNodePath.toString()} path containing
        //     ${shortestNodePath.length} nodes');

        pathCache.save(start, destination, shortestNodePath);

        // assert(shortestNodePath.first == start);
        assert(
          shortestNodePath.last == destination,
          'returned path does not end at destination',
        );

        return shortestNodePath;
      } else {
        return null;
      }
    } else {
      // log('Travel cost returned ${start.travelCostToNode[destination]}');
      return null;
    }
  }

  /// run to clear rich MapLocation references from the primitives to avoid
  /// closures in isolates
  void cleanPrimitives() {
    for (final element in primitives) {
      element.mapLocation = null;
      element.travelCostToPrimitive.clear();
      element.previousStep.clear();
    }
  }

  ///recalculates the total travel cost fora  given path without checking
  ///its optimality
  double totalPathTravelCost(final List<TMapLocation>? path) {
    if (path == null || path.isEmpty) return double.infinity;

    TMapLocation? previousLocation;
    double counter = 0.0;
//  log('Evaluating path travel cost for ${path.toString()}');
    for (final location in path) {
      if (previousLocation != null) {
        counter += previousLocation.distanceToAdjacentLocation(location);
      }
      //    log('Evaluating node ${node.toString()}');
      previousLocation = location;
    }

//  log('Cost: ${counter} units');

    return counter;
  }
}

/// Wrapper for classes with [SuperMapLocation]
abstract class MapLocation<TMapLocation>
    implements SuperMapLocation<TMapLocation> {}

class SuperMapLocation<TMapLocation> {
  bool isTraversable = true;

  // static MapLocation<T> fromJson<T>() => throw UnimplementedError();
  // Map<String, dynamic> toJson() => throw UnimplementedError();

  PrimitiveLocation<TMapLocation>? primitive;

  // dynamic data;

  /// key is MapLocation destination and value is the previous step
  /// in an optimal path
  final Map<TMapLocation, TMapLocation?> previousStep = {};

  /// key is MapLocation destination and value is the travel cost to it
  /// on an optimal path
  final Map<TMapLocation, double> travelCostToLocation = {};

  /// key is an adjacent MapLocation
  final Map<TMapLocation, double> adjacentDistances = {};

  Set<TMapLocation> get adjacentLocations => adjacentDistances.keys.toSet();

  /// returns distance to otherLocation which is assumed to be adjacent to
  /// this (edge weight in graph terms)
  double distanceToAdjacentLocation(final TMapLocation otherLocation) =>
      1.0; //this will break if this is not adjacent to otherLocation

  /// returns the sum of distances between locations on an optimal path from
  /// this to destination
  double? totalTravelCost(final TMapLocation destination) =>
      travelCostToLocation[destination];

  bool isAdjacent(final TMapLocation otherLocation) =>
      adjacentLocations.contains(otherLocation);
}

class PrimitiveLocation<TMapLocation> {
  PrimitiveLocation(
    this.richHashCode, {
    this.mapLocation,
    final Map<PrimitiveLocation<TMapLocation>, double>?
        adjacentPrimitiveDistances,
    final Map<PrimitiveLocation<TMapLocation>,
            PrimitiveLocation<TMapLocation>?>?
        previousStep,
    final Map<PrimitiveLocation<TMapLocation>, double>? travelCostToPrimitive,
  })  : adjacentPrimitiveDistances = adjacentPrimitiveDistances ?? {},
        previousStep = previousStep ?? {},
        travelCostToPrimitive = travelCostToPrimitive ?? {};

  // static PrimitiveLocation<T> fromJson<T>() => throw UnimplementedError();
  // Map<String, dynamic> toJson() => throw UnimplementedError();

  /// rich MapLocation instance that is represented by this primitive.
  /// NB! This has to be null when passing to an isolate
  TMapLocation? mapLocation;

  /// hashcode of the MapLocation associated with this PrimitiveLocation
  final int richHashCode;

  /// key is PrimitiveLocation destination and
  /// value is the previous step in an optimal path
  final Map<PrimitiveLocation<TMapLocation>, PrimitiveLocation<TMapLocation>?>
      previousStep;

  /// key is PrimitiveLocation destination and
  /// value is the travel cost to it on an optimal path
  final Map<PrimitiveLocation<TMapLocation>, double> travelCostToPrimitive;

  /// key is an adjacent Primitive
  final Map<PrimitiveLocation<TMapLocation>, double> adjacentPrimitiveDistances;

  /// hacky way to get StackTrace of an error from the isolate by
  /// assigning it to the first primitive.
  StackTrace? errorTrace;
}

/// taking a directed graph consisting of PrimitiveLocation where weights are
/// given by a function of two adjacent PrimitiveLocations,
/// update PrimitiveLocation previousStep and travelCostToPrimitive data
Iterable<PrimitiveLocation<TMapLocation>> dijkstraUpdatePrimitive<TMapLocation>(
  final Iterable<PrimitiveLocation<TMapLocation>> primitives,
) {
  try {
    for (final sourceNode in primitives) {
      final queue = <PrimitiveLocation<TMapLocation>>{};

      // initialise the queue with infinite distance AND clear the
      // previousStep value
      // TBD: can this be skipped for a partial update
      for (final targetNode in primitives) {
        sourceNode.travelCostToPrimitive[targetNode] = double.infinity;
        sourceNode.previousStep[targetNode] = null;
        queue.add(targetNode);
      }
      sourceNode.travelCostToPrimitive[sourceNode] = 0.0;

      assert(
        queue.contains(sourceNode),
        'queue does not contain $sourceNode',
      );

      //process queue
      while (queue.isNotEmpty) {
        //  + log(N) x (
        final nextNode = shortestDistancePrimitive(
          sourceNode,
          queue,
        ); //TODO: consider implementing priority queue
        // log('Dijkstra queue item ${nextNode.richHashCode}');
        queue.remove(nextNode);

        nextNode.adjacentPrimitiveDistances
            .forEach((final neighbour, final distance) {
          if (queue.contains(neighbour)) {
            final travelCost =
                sourceNode.travelCostToPrimitive[nextNode]! + distance;
            if (travelCost < sourceNode.travelCostToPrimitive[neighbour]!) {
              // if (sourceNode.previousStep[neighbour] == null) counter += 1;
              sourceNode.travelCostToPrimitive[neighbour] = travelCost;
              sourceNode.previousStep[neighbour] = nextNode;
              // log('${sourceVertex.data} to ${neighbour.data}, previousStep
              // is ${nextVertex.data}');
            }
          }
        });
      }
    }
  } catch (e) {
    primitives.first.errorTrace = StackTrace.current;
  }

  // log('Completed Dijkstra update in
  // ${DateTime.now().difference(start).inMilliseconds} milliseconds
  // ($counter path steps recorded)');
  return primitives;
}

PrimitiveLocation<TMapLocation> shortestDistancePrimitive<TMapLocation>(
  final PrimitiveLocation<TMapLocation> sourceNode,
  final Set<PrimitiveLocation<TMapLocation>> queue,
) {
  var shortestEdge = queue.first;
  var shortestDistance = sourceNode.travelCostToPrimitive[shortestEdge];
  for (final otherNode in queue) {
    final travelCost = sourceNode.travelCostToPrimitive[otherNode];
    if (shortestDistance == null) {
      shortestEdge = otherNode;
      shortestDistance = travelCost;
    } else if (travelCost != null && travelCost < shortestDistance) {
      shortestEdge = otherNode;
      shortestDistance = travelCost;
    }
  }

  return shortestEdge;
}

/// class storing cached node paths to prevent searching the graph repeatedly
class PathCache<TMapLocation extends MapLocation<TMapLocation>> {
  PathCache({
    final Map<MapLocationPair<TMapLocation>, List<TMapLocation>>? paths,
  }) : paths = paths ?? {};
  final Map<MapLocationPair<TMapLocation>, List<TMapLocation>> paths;

  void clear() {
    paths.clear();
  }

  int length() {
    return paths.length;
  }

  List<TMapLocation>? load(
    final TMapLocation start,
    final TMapLocation finish,
  ) {
    assert(
      start != finish,
      'requested path finishes at the start',
    );
    return paths[MapLocationPair<TMapLocation>(start, finish)];
  }

  void save(
    final TMapLocation start,
    final TMapLocation finish,
    final List<TMapLocation> path,
  ) {
    final pair = MapLocationPair(start, finish);
    assert(
      paths[pair] == null,
      'no path for $pair',
    );

    final tempPath = path.copy();

    paths[pair] = path.copy();

    if (tempPath.isNotEmpty) {
      assert(
        tempPath.last == finish,
        'retrieved path does not end at the finish',
      );

      TMapLocation newStart;
      //also cache every subpath
      while (tempPath.length > 1) {
        newStart = tempPath.removeAt(0);

        // log('Caching subpath from ${newStart} to ${path.last}
        // with ${path.length.toString()} steps');
        paths[MapLocationPair(newStart, finish)] = tempPath.copy();
      }
    }
  }
}

@immutable
class MapLocationPair<TMapLocation extends MapLocation<TMapLocation>> {
  const MapLocationPair(this.start, this.finish);

  //NOT symmetric!
  final TMapLocation start;
  final TMapLocation finish;

  @override
  bool operator ==(final Object other) {
    return other is MapLocationPair &&
        start == other.start &&
        finish == other.finish;
  }

  @override
  int get hashCode => hash2(start, finish);
}
