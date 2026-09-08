import 'package:shared_preferences/shared_preferences.dart';

abstract class PrivacyStore {
  Future<bool> isAccepted();
  Future<void> setAccepted(bool value);
}

class SharedPrefsPrivacyStore implements PrivacyStore {
  static const _key = 'privacyAccepted';

  @override
  Future<bool> isAccepted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_key) ?? false;
  }

  @override
  Future<void> setAccepted(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, value);
  }
}

class MemoryPrivacyStore implements PrivacyStore {
  MemoryPrivacyStore({bool accepted = false}) : _accepted = accepted;

  bool _accepted;

  @override
  Future<bool> isAccepted() async => _accepted;

  @override
  Future<void> setAccepted(bool value) async {
    _accepted = value;
  }
}
