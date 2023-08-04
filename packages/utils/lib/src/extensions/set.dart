part of extensions;

extension SetExt<TValue> on Set<TValue> {
  void assignAll(Iterable<TValue> other) {
    clear();
    addAll(other);
  }

  Future<Set<TNew>> convert<TNew>(
    IterableConverter<TValue, TNew> converter,
  ) async {
    final list = <TNew>{};
    for (final item in this) {
      list.add(await converter(item));
    }
    return list;
  }
}
