part of 'tutorial_states.dart';

@JsonSerializable(explicitToJson: true)
class TutorialHistory {
  TutorialHistory({
    final Map<TutorialModes, TutorialMode<dynamic>>? modesMap,
    final Map<TutorialModes, int>? statePointers,
    final Set<TutorialModes>? playedTutorialModes,
  })  : modesMap = modesMap ?? {},
        statePointers = statePointers ?? {},
        playedTutorialModes = playedTutorialModes ?? {};
  factory TutorialHistory.empty() => TutorialHistory();
  TutorialStatePointersMap statePointers;
  @JsonKey(ignore: true)
  TutorialModesMap modesMap;

  /// This stack keeps tutorials which needs to be runned only once
  final Set<TutorialModes> playedTutorialModes;
  bool getIsTutorialModePlayed(final TutorialModes mode) =>
      playedTutorialModes.contains(mode);
  void setTutorialModePlayed(final TutorialModes mode) =>
      playedTutorialModes.add(mode);

  Map<String, dynamic> toJson() => _$TutorialHistoryToJson(this);
  String toRawJson() => jsonEncode(toJson());
  static TutorialHistory fromJson(final Map<String, dynamic> json) =>
      _$TutorialHistoryFromJson(json);
  static TutorialHistory fromRawJson(final String json) => fromJson(
        jsonDecode(json) as Map<String, dynamic>? ?? {},
      );
}
