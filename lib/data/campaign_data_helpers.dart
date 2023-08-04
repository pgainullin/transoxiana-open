part of 'campaign_data_source.dart';

// ************************************
//       Nation helpers
// ************************************
/// convert a 2-dimensional array or int DiplomaticStatus values to properties of each Nation in a given set
Future<void> connectDiplomaticRelationships({
  required final Map<Id, Nation> nations,
  required final DiplomaticRelationships matrix,
  required final TransoxianaGame game,
}) async {
  assert(nations.length == matrix.length);
  for (final nationIdsEntry in matrix.entries) {
    for (final diplomaticRelationship in nationIdsEntry.value.entries) {
      final nation = await game.campaignRuntimeData
          .getNationById(diplomaticRelationship.key);
      final otherNation = nations[nationIdsEntry.key]!;
      final status = diplomaticRelationship.value;
      otherNation.diplomaticRelationships[nation] = status;
      nation.diplomaticRelationships[otherNation] = status;
    }
  }

  //check internal consistency
  for (final nation in nations.values) {
    nation.diplomaticRelationships.forEach((final otherNation, final status) {
      assert(otherNation.diplomaticRelationships[nation] == status);
    });
  }
}

/// convert a 2-dimensional array or int DiplomaticStatus values to properties of each Nation in a given set
Future<DiplomaticRelationships> getDiplomaticRelationships({
  required final Map<Id, Nation> nations,
}) async {
  return nations.convertValues(
    (final nation) async => (await nation.toData()).diplomaticRelationships,
  );
}

// ************************************
//       Events helpers
// ************************************
// // load events
// if (jsonCache['events'] != null &&
//     (jsonCache['events'] as List<dynamic>).isNotEmpty) {
//   for (final element in jsonCache['events'] as List<dynamic>) {
//     final Nation _eventNation = game.savableCampaignData.nations
//         .toList()
//         .elementAt((element as Map<String, dynamic>)['nation'] as int);
//     _eventNation.events.add(Event.fromJson(
//         game, _eventNation, element as Map<String, dynamic>));
//   }
// }
Future<void> connectNationsEvents({
  required final Map<Id, Nation> nations,
  required final Iterable<Event> events,
}) async {
  for (final event in events) {
    event.nation.events.add(event);
    nations[event.nation.id]!.events.add(event);
  }
}

Future<Set<EventData>> getNationsEvents({
  required final Map<Id, Nation> nations,
}) async {
  final events = <EventData>{};
  for (final nation in nations.values) {
    final nationEvents = await nation.events.convert((final e) => e.toData());
    events.addAll(nationEvents);
  }
  return events;
}

Future<void> connectNationsAis({
  required final Map<Id, Nation> nations,
  required final Map<Id, Ai> ais,
}) async {
  for (final ai in ais.values) {
    ai.nation.ai = ai;
    assert(nations[ai.nation.id]?.ai == ai);
  }
}

// ************************************
//       Army helpers
// ************************************

Future<void> connectArmyToProvinces({
  required final Map<Id, Army> armies,
  required final Map<Id, Province> provinces,
}) async {
  for (final army in armies.values) {
    final location = army.location;
    if (location == null) continue;
    location.armies[army.id] = army;
    assert(provinces[location.id]?.armies.containsKey(army.id) == true);
  }
}

Future<void> connectArmyToUnits({
  required final Map<Id, Army> armies,
  required final Map<Id, Unit> units,
}) async {
  for (final unit in units.values) {
    final army = unit.army;
    if (army != null) {
      final units = armies[army.id.armyId]?.units ?? {};
      units.add(unit);
    }
  }
  for (final army in armies.values) {
    for (final unit in army.units) {
      unit.army ??= army;
    }
    await units.addAllNew(
      Map.fromEntries(
        army.units.map(
          (final e) => MapEntry(e.id.unitId, e),
        ),
      ),
    );
  }
}

Future<void> connectProvincesFortifications({
  required final Map<Id, Province> provinces,
}) async {
  for (final province in provinces.values) {
    if (province.fort != null) {
      province.fort!.province = province;
    }
  }
}
