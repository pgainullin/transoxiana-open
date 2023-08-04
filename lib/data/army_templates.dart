import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:transoxiana/components/game/game.dart';
import 'package:transoxiana/data/campaign_data_source.dart';
import 'package:transoxiana/data/unit_types.dart';
import 'package:utils/utils.dart';

part 'army_templates.g.dart';

/// Template describing what units go together in an army type
///
/// Always use to create [ArmyTemplateData.toTemplate]
class ArmyTemplate extends ArmyTemplateData
    implements DataSourceRef<ArmyTemplateData, ArmyTemplate> {
  ArmyTemplate._fromData({
    required this.data,
    required this.types,
  }) : super(
          name: data.name,
          unitsTypesIds: data.unitsTypesIds,
          id: data.id,
        );
  @override
  Future<void> refillData(final ArmyTemplate otherType) async {
    assert(
      otherType == this,
      'You trying to update different ArmyTemplate.',
    );
    final newData = await otherType.toData();
    data = newData;
    types.assignAll(otherType.types);
    unitsTypesIds.assignAll(data.unitsTypesIds);
  }

  @override
  Future<ArmyTemplateData> toData() async => ArmyTemplateData(
        name: name,
        unitsTypesIds:
            types.map((final e) => e.map((final e) => e.id).toList()).toList(),
        id: id,
      );

  /// Rolling list of lists of UnitTypes which in a random army
  /// gets drawn sequentially to build an army that resembles
  /// this template with earlier units being higher priority
  final List<List<UnitType>> types;

  /// for AI training API convert this into its index in the list of templates
  Map<String, dynamic> toAiJson(final CampaignRuntimeData runtimeData) {
    return Map<String, dynamic>.fromEntries([
      MapEntry(
        'armyTemplate',
        runtimeData.armyTemplates.values.toList().indexOf(this),
      ),
    ]);
  }

  @override
  ArmyTemplateData data;
}

/// Template describing what units go together in an army type
///
/// ! do not place any logic in this class
///
/// To create [ArmyTemplate] use [ArmyTemplateData.toTemplate]
@JsonSerializable(explicitToJson: true)
class ArmyTemplateData with EquatableMixin {
  ArmyTemplateData({
    required this.name,
    required this.unitsTypesIds,
    required final Id? id,
  })  : id = id ?? uuid.v4(),
        assert(unitsTypesIds.isNotEmpty),
        assert(unitsTypesIds.first.isNotEmpty);

  static ArmyTemplateData fromJson(final Map<String, dynamic> json) =>
      _$ArmyTemplateDataFromJson(json);

  Map<String, dynamic> toJson() => _$ArmyTemplateDataToJson(this);

  Future<ArmyTemplate> toTemplate({
    required final TransoxianaGame game,
  }) async {
    final types = await _loadTypes(runtimeData: game.campaignRuntimeData);
    return ArmyTemplate._fromData(
      data: this,
      types: types,
    );
  }

  Future<List<List<UnitType>>> _loadTypes({
    required final CampaignRuntimeData runtimeData,
  }) async {
    final newTypes = <List<UnitType>>[];
    // TODO(arenukvern): replace to Future.forEach
    for (final ids in unitsTypesIds) {
      final units = <UnitType>[];
      for (final unitId in ids) {
        final type = await runtimeData.getUnitTypeById(unitId);
        units.add(type);
      }
      newTypes.add(units);
    }
    return newTypes;
  }

  final Id id;

  /// Rolling list of lists of UnitTypes which in a random army
  /// gets drawn sequentially to build an army that resembles
  /// this template with earlier units being higher priority
  @JsonKey(name: 'units')
  final List<List<UnitTypeNames>> unitsTypesIds;
  final String name;
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
