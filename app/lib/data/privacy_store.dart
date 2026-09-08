import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class PrivacyStore {
  Future<bool> isAccepted();
  Future<void> setAccepted(bool value);
}

class SharedPrefsPrivacyStore implements PrivacyStore {
  static const _key = 'privacyAccepted';

  /// Session cache so agree/delete is readable before prefs I/O finishes.
  bool? _session;

  @override
  Future<bool> isAccepted() async {
    if (_session != null) return _session!;
    try {
      final prefs = await SharedPreferences.getInstance();
      return _session = prefs.getBool(_key) ?? false;
    } catch (e) {
      assert(() {
        debugPrint('SharedPrefsPrivacyStore.isAccepted failed: $e');
        return true;
      }());
      return false;
    }
  }

  @override
  Future<void> setAccepted(bool value) async {
    _session = value;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_key, value);
    } catch (e) {
      // Missing plugin / storage errors must not block leaving the launch page.
      assert(() {
        debugPrint('SharedPrefsPrivacyStore.setAccepted failed: $e');
        return true;
      }());
    }
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
