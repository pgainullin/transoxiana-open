part of all_utils;

class EnumHelper {
  static T? findFromString<T>({
    required List<T> list,
    required String? key,
  }) {
    for (final item in list) {
      if (item.toString() == key) return item;
    }
    return null;
  }
}
