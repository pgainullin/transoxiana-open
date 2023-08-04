// ************** RM SERVICES END **************
import 'package:shared_preferences/shared_preferences.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

class RmStore implements IPersistStore {
  late SharedPreferences _prefs;
  @override
  Future<void> delete(final String key) async => _prefs.remove(key);

  @override
  Future<void> deleteAll() async => _prefs.clear();

  @override
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  @override
  Object read(final String key) async => _prefs.get(key);

  @override
  Future<void> write<T>(final String key, final T value) async =>
      _prefs.setString(key, value.toString());
}
