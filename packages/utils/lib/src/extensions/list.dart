part of extensions;

extension ListCopy<TValue> on List<TValue> {
  List<TValue> copy() => [...this];
  void assignAll(Iterable<TValue> other) {
    clear();
    addAll(other);
  }
}
