import 'package:shared_preferences/shared_preferences.dart';

class CounterService {
  final SharedPreferences sharedPreferences;
  final String key;

  CounterService(this.key, this.sharedPreferences);

  Future<bool> save(int value) async {
    try {
      await sharedPreferences.setInt(key, value);
    } catch (e) {
      return false;
    }
    return true;
  }

  int get() {
    return sharedPreferences.getInt(key) ?? 0;
  }
}
