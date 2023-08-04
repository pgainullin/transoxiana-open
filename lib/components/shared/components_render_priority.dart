enum ComponentsRenderPriority {
  campaignBackground(1),
  campaign(2),
  campaignProvince(3),
  campaignProvinceColor(4),
  campaignWalls(5),

  /// assuming that we will have 20000 limit for armies
  ///
  /// because every army will have priority +1
  campaignArmy(6),
  campaignFogOfWar(7, minLimit: armyMaxLimit),
  campaignWeather(8, minLimit: armyMaxLimit),
  battleBackground(9, minLimit: armyMaxLimit),
  battleShadowBackground(10, minLimit: armyMaxLimit),
  battle(11, minLimit: armyMaxLimit),
  battleHexMap(12, minLimit: armyMaxLimit),
  battleWalls(13, minLimit: armyMaxLimit),
  battleUnit(14, minLimit: armyMaxLimit),
  battleLancesAndShoots(15, minLimit: armyMaxLimit),
  battleNodeSelector(16, minLimit: armyMaxLimit);

  const ComponentsRenderPriority(final int value, {final int minLimit = 0})
      : value = minLimit + value;
  final int value;
  static const int armyMaxLimit = 20000;
}
