part of extensions;

typedef FutureBoolCallback = Future<bool> Function();
typedef FutureVoidCallback = Future<void> Function();
typedef FutureValueChanged<T> = Future<void> Function(T);
