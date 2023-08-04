import 'dart:math';

import 'package:json_annotation/json_annotation.dart';
import 'package:transoxiana/components/battle/unit.dart';
import 'package:transoxiana/components/game/game.dart';
import 'package:transoxiana/data/campaign_data_source.dart';
import 'package:transoxiana/data/constants.dart';

part 'commander.g.dart';

/// This class purpose is to keep all data for [Commander]
///
/// To create [Commander] use [CommanderData.toCommander]
@JsonSerializable(explicitToJson: true)
class CommanderData {
  CommanderData({
    this.name = 'Unknown Commander',
    this.birthYear = 1195,
    this.moraleBoostMultiple = 1.0,
    this.moraleRange = 3,
    this.attritionMultiple = 1.0,
    this.unitMeleeBonus = 1.0,
    this.unitRangedBonus = 1.0,
    this.unit,
  })  : assert(attritionMultiple != 0.0),
        assert(moraleBoostMultiple != 0.0),
        assert(moraleRange != 0),
        assert(unitMeleeBonus != 0.0),
        assert(unitRangedBonus != 0.0);
  static CommanderData fromJson(final Map<String, dynamic> json) =>
      _$CommanderDataFromJson(json);
  Map<String, dynamic> toJson() => _$CommanderDataToJson(this);
  Future<Commander> toCommander({
    required final TransoxianaGame game,
  }) async {
    final effectiveUnit = await unit?.toUnit(game: game);
    return Commander._fromData(data: this, game: game, unit: effectiveUnit);
  }

  String name;
  int birthYear;
  UnitData? unit;

  /// higher -> larger effect on nearby troops
  double moraleBoostMultiple;

  /// node distance of morale effects
  int moraleRange;

  /// lower -> lower attrition
  double attritionMultiple;

  /// how much stronger the commander unit is in melee than an equivalent regular unit
  double unitMeleeBonus;

  /// how much stronger the commander unit is in ranged combat than an equivalent regular unit
  double unitRangedBonus;
}

/// Use [CommanderData.toCommander] to create/load instance
///
/// Keep all logic in this class
class Commander implements GameRef, DataSourceRef<CommanderData, Commander> {
  Commander._fromData({
    required this.data,
    required this.game,
    required this.unit,
  });
  @override
  Future<CommanderData> toData() async => CommanderData(
        attritionMultiple: attritionMultiple,
        birthYear: birthYear,
        moraleBoostMultiple: moraleBoostMultiple,
        moraleRange: moraleRange,
        name: name,
        unit: await unit?.toData(),
        unitMeleeBonus: unitMeleeBonus,
        unitRangedBonus: unitRangedBonus,
      );

  @override
  Future<void> refillData(final Commander otherType) async {
    data = await otherType.toData();
    unit = otherType.unit;
  }

  @override
  TransoxianaGame game;
  @override
  CommanderData data;

  String get name => data.name;
  int get birthYear => data.birthYear;

  // higher -> larger effect on nearby troops
  double get moraleBoostMultiple => data.moraleBoostMultiple;

  /// node distance of morale effects
  int get moraleRange => data.moraleRange;

  /// lower -> lower attrition
  double get attritionMultiple => data.attritionMultiple;

  /// how much stronger the commander unit is in melee than an equivalent regular unit
  double get unitMeleeBonus => data.unitMeleeBonus;

  /// how much stronger the commander unit is in ranged combat than an equivalent regular unit
  double get unitRangedBonus => data.unitRangedBonus;

  Unit? unit;

  ///commander won a battle and gets a skill boost
  void promotePostBattle() {
    data.moraleBoostMultiple = min(
      commanderMoraleBoostFactorCap,
      moraleBoostMultiple * (1 + commanderMoraleBoostUpgradeFactor),
    );
    // log('$name morale skill is now $moraleBoostMultiple');
  }

  ///survived a season and gets a skill boost
  void learnAtSeasonEnd() {
    data.attritionMultiple = max(
      commanderAttritionFactorFloor,
      attritionMultiple * (1 - commanderAttritionLearningFactor),
    );
  }

  /// commander made a melee kill and improves the relevant skill
  void improveMeleeSkill() {
    data.unitMeleeBonus = min(
      commanderCombatFactorCap,
      unitMeleeBonus * (1 + commanderCombatFactorsLearningFactor),
    );
    // log('$name melee skill is now $unitMeleeBonus');
  }

  /// commander made a ranged kill and improves the relevant skill
  void improveRangedSkill() {
    data.unitRangedBonus = min(
      commanderCombatFactorCap,
      unitRangedBonus * (1 + commanderCombatFactorsLearningFactor),
    );
    // log('$name ranged skill is now $unitRangedBonus');
  }

  @override
  String toString() {
    return '<Commander>: $name';
  }
}
