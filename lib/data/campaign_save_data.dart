part of 'campaign_data_source.dart';

enum SaveReservedIds {
  quickSave,
  autosave,
}

final saveReservedIds = {
  SaveReservedIds.quickSave.toString(): SaveReservedIds.quickSave,
  SaveReservedIds.autosave.toString(): SaveReservedIds.autosave,
};

/// Primitive class that holds serializable data only
///
/// !This class should not have any logic!
///
/// How and why?
///
/// As this class represent simple data structure
/// it is simple to create it from anywhere and then supply to campaign
/// as settings/params.
///
/// In this case we can make configurable campaign, configurable battle
/// that will create this data first, and then just run it through
/// [Campaign.startNew] or [Campaign.continueFrom]
///
/// For instances creation use immutable, game independable
/// [TemplateData] class
@JsonSerializable(explicitToJson: true)
class CampaignSaveData extends CampaignDataSource with EquatableMixin {
  CampaignSaveData({
    required final GameDate currentDate,
    required final GameDate startDate,
    final String campaignName = '',
    final Map<Id, ProvinceData>? provinces,
    final Map<Id, AiData>? ais,
    final Map<Id, ArmyData>? armies,
    final Map<Id, NationData>? nations,
    final Map<Id, UnitData>? units,
    final Map<Id, BattleData>? battles,
    final Map<Id, ArmyTemplateData>? armyTemplates,
    final Map<UnitTypeNames, UnitTypeData>? unitTypes,
    final Map<Id, FortificationData>? forts,
    final NationData? player,
    final BattleData? activeBattle,
    final String? backgroundImagePath,
    final CampaignNarrativeData? narrative,
    final Id? id,
    final DiplomaticRelationships? diplomaticRelationships,
    final Set<EventData>? events,
    final DateTime? gameSaveDate,
    final CampaignDataSourceType? sourceType,
  })  : rand = Random(),
        super(
          sourceType: sourceType,
          battles: battles,
          events: events,
          activeBattle: activeBattle,
          ais: ais,
          armies: armies,
          armyTemplates: armyTemplates,
          backgroundImagePath: backgroundImagePath,
          campaignName: campaignName,
          currentDate: currentDate,
          id: id ?? uuid.v4(),
          narrative: narrative,
          forts: forts,
          nations: nations,
          player: player,
          provinces: provinces,
          startDate: startDate,
          unitTypes: unitTypes,
          units: units,
          diplomaticRelationships: diplomaticRelationships,
          gameSaveDate: gameSaveDate,
        );

  @override
  Future<Map<String, dynamic>> toJson() async =>
      compute(_$CampaignSaveDataToJson, this);
  static Future<CampaignSaveData> fromJson(
          final Map<String, dynamic> json,) async =>
      compute(_$CampaignSaveDataFromJson, json);

  @override
  Future<CampaignRuntimeData> toRuntime({
    required final TransoxianaGame game,
    final Campaign? campaign,
  }) async {
    final effectiveNations =
        await nations.convertValues((final item) => item.toNation(game: game));
    final effectiveAis =
        await ais.convertValues((final item) => item.toAi(game: game));
    final effectiveProvinces = await provinces
        .convertValues((final item) => item.toProvince(game: game));
    final effectiveArmies =
        await armies.convertValues((final item) => item.toArmy(game: game));
    final effectiveUnits =
        await units.convertValues((final item) => item.toUnit(game: game));
    final effectiveArmyTemplates = await armyTemplates.convertValues(
      (final item) async => item.toTemplate(game: game),
    );
    final effectiveUnitTypes = await unitTypes.convertValues(
      (final item) async => item.toType(),
    );
    final effectiveFortifications = await forts.convertValues(
      (final item) async => item.toFortification(game: game),
    );

    /// As all battles appears only during the turn, it should be not possible
    /// to save game with battles.

    // final effectiveActiveBattle = activeBattle;
    // final resolvedActiveBattle = effectiveActiveBattle == null
    //     ? null
    //     : {
    //         effectiveActiveBattle.id:
    //             await effectiveActiveBattle.toBattle(game: game)
    //       };
    return CampaignRuntimeData._fromData(
      player: await player?.toNation(game: game),
      armyTemplates: effectiveArmyTemplates,
      campaignName: campaignName,
      currentDate: currentDate,
      forts: effectiveFortifications,
      id: id,
      startDate: startDate,
      unitTypes: effectiveUnitTypes,
      provinces: effectiveProvinces,
      data: this,
      ais: effectiveAis,
      armies: effectiveArmies,
      nations: effectiveNations,
      units: effectiveUnits,
      backgroundImagePath: backgroundImagePath,
      battles: {},
      game: game,
      narrative: narrative?.toNarrative(game: game),
      backgroundImage: await _loadBackgroundImage(backgroundImagePath),
    );
  }

  @override
  @JsonKey(ignore: true)
  // ignore: overridden_fields
  Random rand;

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

Future<Image?> _loadBackgroundImage(final String? backgroundImagePath) async {
  final path = backgroundImagePath ?? '';
  if (path.isEmpty) return null;
  return Flame.images.load(path);
}
