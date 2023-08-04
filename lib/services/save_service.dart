import 'dart:convert';
import 'dart:developer';

import 'package:transoxiana/services/shared_preferences_keys.dart';
import 'package:transoxiana/services/shared_preferences_mixin.dart';

class SaveService with SharedPreferencesMixin {
  SaveService({required this.key});

  /// Use [key] from [SharedPreferencesKeys]

  final String key;

  Future<void> saveMap(final Map<String, dynamic> json) async {
    final str = jsonEncode(json);
    await setString(key, str);
  }

  Future<Map<String, dynamic>?> loadMap() async {
    final str = await getString(key);
    if (str.isEmpty) return null;
    try {
      return jsonDecode(str);
    } catch (e) {
      log(e.toString());
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> loadList() async {
    final str = await getString(key);
    if (str.isEmpty) return [];
    try {
      return List.castFrom<dynamic, Map<String, dynamic>>(jsonDecode(str));
    } catch (e) {
      log(e.toString());
      return [];
    }
  }
}
