import 'package:flutter/foundation.dart';
import 'package:universal_io/io.dart';

class AudioAvailabilityChecker {
  static bool isImplemented() {
    if (kIsWeb) return true;

    if (Platform.isWindows) return false;

    return true;
  }

  static bool get isNotImplemented => !isImplemented();
}
