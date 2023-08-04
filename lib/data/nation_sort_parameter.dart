import 'package:transoxiana/components/shared/nation.dart';
import 'package:transoxiana/generated/l10n.dart';

/// includes a string description of a numeric value that nations can be
/// sorted by and aggregated
abstract class NationSortParameter {
  NationSortParameter(this.nation);

  late NationComparatorType type;

  final String description = '';
  final num value = 0.0;
  final Nation nation;
}

NationSortParameter comparatorFromType(
    final Nation nation, final NationComparatorType comparatorType,) {
  switch (comparatorType) {
    case NationComparatorType.unitCount:
      return UnitCountSortParameter(nation);
    case NationComparatorType.population:
      return PopulationSortParameter(nation);
    case NationComparatorType.gold:
      return GoldSortParameter(nation);
    default:
      throw Exception('Unrecognized NationComparator');
  }
}

enum NationComparatorType {
  unitCount,
  population,
  gold,
}

class UnitCountSortParameter implements NationSortParameter {
  UnitCountSortParameter(this.nation);

  @override
  final Nation nation;

  @override
  int get value => nation.unitCount;

  @override
  String get description => S.current.unitCountSort;

  @override
  NationComparatorType type = NationComparatorType.unitCount;
}

class PopulationSortParameter implements NationSortParameter {
  PopulationSortParameter(this.nation);

  @override
  final Nation nation;

  @override
  double get value => nation.getProvinces().fold(
        0.0,
        (final previousValue, final element) =>
            previousValue + element.population,
      );

  @override
  String get description => S.current.populationSort;

  @override
  NationComparatorType type = NationComparatorType.population;
}

class GoldSortParameter implements NationSortParameter {
  GoldSortParameter(this.nation);

  @override
  final Nation nation;

  @override
  double get value =>
      nation.getProvinces().fold<double>(
            0.0,
            (final previousValue, final element) =>
                previousValue + element.goldStored,
          ) +
      nation.getArmies().fold(
            0.0,
            (final previousValue, final element) =>
                previousValue + element.goldCarried,
          );

  @override
  String get description => S.current.goldSort;

  @override
  NationComparatorType type = NationComparatorType.gold;
}
