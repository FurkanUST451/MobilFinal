import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesService {
  static const String _temaKey = 'karanlik_mod';

  Future<void> temaKaydet(bool karanlikMod) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_temaKey, karanlikMod);
  }

  Future<bool> temaGetir() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_temaKey) ?? false;
  }
}
