part of extensions;

extension MapExt<TKey, TValue> on Map<TKey, TValue> {
  Future<Map<TNewKey, TValue>> convertKeys<TNewKey>(
    IterableConverter<TKey, TNewKey> keyConverter,
  ) async {
    final map = <TNewKey, TValue>{};

    for (final entry in entries) {
      final key = await keyConverter(entry.key);
      map[key] = entry.value;
    }
    return map;
  }

  Future<Map<TKey, TNewValue>> convertValues<TNewValue>(
    IterableConverter<TValue, TNewValue> valueConverter,
  ) async {
    final map = <TKey, TNewValue>{};

    for (final entry in entries) {
      final value = await valueConverter(entry.value);
      map[entry.key] = value;
    }
    return map;
  }

  Future<void> addAllNew<TNewValue>(Map<TKey, TValue> map) async {
    for (final entry in map.entries) {
      final exists = containsKey(entry.key);
      if (exists) continue;
      this[entry.key] = entry.value;
    }
  }

  Future<Map<TNewKey, TNewValue>> convertEntries<TNewKey, TNewValue>({
    required IterableConverter<TKey, TNewKey> keyConverter,
    required IterableConverter<TValue, TNewValue> valueConverter,
  }) async {
    final map = <TNewKey, TNewValue>{};

    for (final entry in entries) {
      final key = await keyConverter(entry.key);
      final value = await valueConverter(entry.value);
      map[key] = value;
    }
    return map;
  }

  void assignAll(Map<TKey, TValue> other) {
    clear();
    addAll(other);
  }

  void assignEntries(Iterable<MapEntry<TKey, TValue>> other) {
    clear();
    addEntries(other);
  }
}
