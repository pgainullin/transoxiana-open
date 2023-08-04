import 'dart:collection';

import '../../tutorial.dart';
import '../models/models.dart';

part 'tutorial_modes_map.dart';

class TutorialMode<TActionEnum> {
  final TutorialModes mode;
  final TutorialActionKeysMap<TActionEnum> keys;
  final LinkedHashSet<TutorialStep<TActionEnum>> currentSteps;
  LinkedHashSet<TutorialStep<TActionEnum>> copySteps() =>
      LinkedHashSet.from(currentSteps);
  LinkedHashSet<TutorialStep<TActionEnum>> pushSteps({
    required List<TutorialStep<TActionEnum>>? steps,
  }) {
    final newSteps = copySteps();
    if (steps != null) newSteps.addAll(steps);

    return newSteps;
  }

  LinkedHashSet<TutorialStep<TActionEnum>> unshiftSteps({
    required List<TutorialStep<TActionEnum>>? steps,
  }) {
    // ignore: prefer_collection_literals
    final newSteps = LinkedHashSet<TutorialStep<TActionEnum>>();
    if (steps != null) newSteps.addAll(steps);

    newSteps.addAll(copySteps());
    return newSteps;
  }

  TutorialMode({
    required this.mode,
    TutorialActionKeysMap<TActionEnum>? keys,
    LinkedHashSet<TutorialStep<TActionEnum>>? steps,
    // ignore: prefer_collection_literals
  })  : currentSteps = steps ?? LinkedHashSet(),
        keys = keys ?? {};

  TutorialMode pushWith({
    TutorialModes? mode,
    TutorialActionKeysMap<TActionEnum>? keys,
    List<TutorialStep<TActionEnum>>? steps,
  }) =>
      TutorialMode<TActionEnum>(
        keys: {...this.keys, ...?keys},
        mode: mode ?? this.mode,
        steps: pushSteps(steps: steps),
      );

  TutorialMode unshiftWith({
    TutorialModes? mode,
    TutorialActionKeysMap<TActionEnum>? keys,
    List<TutorialStep<TActionEnum>>? steps,
  }) =>
      TutorialMode<TActionEnum>(
        keys: {...this.keys, ...?keys},
        mode: mode ?? this.mode,
        steps: unshiftSteps(steps: steps),
      );
}
