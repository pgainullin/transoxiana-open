import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:transoxiana/data/constants.dart';
import 'package:transoxiana/data/season.dart';

part 'game_dates.g.dart';

/// Class describing a date in the game that is fully defined by the year + season
///
/// To modify this class use [copyWith]
@immutable
@JsonSerializable()
class GameDate extends Equatable {
  const GameDate(this.year, this.season) : assert(year > 0);

  /// A [GameDate] with [defaultCampaignStartYear] and [defaultCampaignStartSeason]
  const GameDate.start()
      : year = defaultCampaignStartYear,
        season = defaultCampaignStartSeason;

  static GameDate fromJson(final Map<String, dynamic> json) =>
      _$GameDateFromJson(json);
  Map<String, dynamic> toJson() => _$GameDateToJson(this);
  GameDate copyWith({final int? year, final Season? season}) => GameDate(
        year ?? this.year,
        season ?? this.season,
      );

  final int year;
  final Season season;

  /// How many seasons have passed since a givenDate to this date
  int turnSinceDate(final GameDate? otherDate) {
    return otherDate == null
        ? 999999
        : (year - otherDate.year) * Season.values.length +
            (season.index - otherDate.season.index);
  }

  @override
  @JsonKey(ignore: true)
  List<Object?> get props => [year, season];

  @override
  @JsonKey(ignore: true)
  bool? get stringify => true;

  @override
  @JsonKey(ignore: true)
  // ignore: unnecessary_overrides, hash_and_equals
  int get hashCode => super.hashCode;
}
