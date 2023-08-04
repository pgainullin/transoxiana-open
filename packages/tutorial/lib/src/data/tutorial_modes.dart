/// As this class is completely stringified
/// there group modes as you need to
enum TutorialModes {
  campaignIntro,
  campaignButtonsIntro,
  battleIntro,
  mainMenu,

  /// [TutorialModes.independent] is a mode, that
  /// usually used when [TutorialStep().selfRemoveAfterClose] == true
  campaignIndependent,
  battleIndependent,

  /// system value
  fromString
}

extension TutorialModesExt on TutorialModes {
  TutorialModes operator [](String key) => (name) {
        final resolvedEnum = TutorialModes.values.firstWhere(
          (val) => val.toString() == name,
          orElse: () => throw RangeError(
            "enum TutorialModes contains no value '$name'",
          ),
        );
        return resolvedEnum;
      }(key);
}
