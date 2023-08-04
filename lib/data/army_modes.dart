import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

// /// finite state machine governing the Army's behaviour. Fighters will go after enemy provinces, recruiters try to grow armies and taxCollectors get gold. Raiders try to sack/tax enemy provinces and avoid battle
enum ArmyModeEnum {
  fighter,
  recruiter,
  taxCollector,
  raider,
  defender,
}

@immutable
class ArmyMode extends Equatable {
  /// !Never use default constructor directly
  /// use factory functions like [ArmyMode.fighter]
  const ArmyMode({
    required this.value,
    required this.stringRepresentation,
    required this.enumValue,
  });
  factory ArmyMode.fighter() => const ArmyMode(
        value: 0,
        // TODO(arenukvern): figure out how to access S.current in isolate
        stringRepresentation: 'Fighter', // S.current.fighterMode,
        enumValue: ArmyModeEnum.fighter,
      );

  factory ArmyMode.recruiter() => const ArmyMode(
        value: 1,
        // TODO(arenukvern): figure out how to access S.current in isolate
        stringRepresentation: 'Recruiter', // S.current.recrurecruiterMode,
        enumValue: ArmyModeEnum.recruiter,
      );
  factory ArmyMode.taxCollector() => const ArmyMode(
        value: 2,
        // TODO(arenukvern): figure out how to access S.current in isolate
        stringRepresentation: 'Tax Collector', // S.current.taxCollectorMode,
        enumValue: ArmyModeEnum.taxCollector,
      );
  factory ArmyMode.raider() => const ArmyMode(
        value: 3,
        // TODO(arenukvern): figure out how to access S.current in isolate
        stringRepresentation: 'Raider', // S.current.raiderMode,
        enumValue: ArmyModeEnum.raider,
      );
  factory ArmyMode.defender() => const ArmyMode(
        value: 4,
        // TODO(arenukvern): figure out how to access S.current in isolate
        stringRepresentation: 'Defender', // S.current.defenderMode,
        enumValue: ArmyModeEnum.defender,
      );

  static ArmyMode fromJson(final int? modeIndex) =>
      modeIndex == null ? ArmyMode.fighter() : ArmyMode.values[modeIndex];
  int toJson() => value;
  static int modeToJson(final ArmyMode mode) => mode.value;

  final String stringRepresentation;
  final int value;
  final ArmyModeEnum enumValue;

  @override
  String toString() => stringRepresentation;

  static List<ArmyMode> get values => [
        ArmyMode.fighter(),
        ArmyMode.recruiter(),
        ArmyMode.taxCollector(),
        ArmyMode.raider(),
        ArmyMode.defender(),
      ];
  @JsonKey(ignore: true)
  int get index => value;

  @override
  @JsonKey(ignore: true)
  bool? get stringify => true;

  @override
  @JsonKey(ignore: true)
  List<Object?> get props => [value];

  @override
  @JsonKey(ignore: true)
  // ignore: hash_and_equals
  int get hashCode => super.hashCode;
}
