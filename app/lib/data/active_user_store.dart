import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Persists which local account is active (multi-user, no remote auth yet).
abstract interface class ActiveUserStore {
  Future<int> getActiveUserId();
  Future<void> setActiveUserId(int id);
}

final class SharedPrefsActiveUserStore implements ActiveUserStore {
  static const _key = 'activeUserId';

  int? _session;

  @override
  Future<int> getActiveUserId() async {
    if (_session != null) return _session!;
    try {
      final prefs = await SharedPreferences.getInstance();
      return _session = prefs.getInt(_key) ?? 1;
    } catch (e, st) {
      assert(() {
        debugPrint(
          'SharedPrefsActiveUserStore.getActiveUserId failed: $e\n$st',
        );
        return true;
      }());
      return 1;
    }
  }

  @override
  Future<void> setActiveUserId(int id) async {
    _session = id;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_key, id);
    } catch (e, st) {
      assert(() {
        debugPrint(
          'SharedPrefsActiveUserStore.setActiveUserId failed: $e\n$st',
        );
        return true;
      }());
    }
  }
}

final class MemoryActiveUserStore implements ActiveUserStore {
  MemoryActiveUserStore({int activeUserId = 1}) : _id = activeUserId;

  int _id;

  @override
  Future<int> getActiveUserId() async => _id;

  @override
  Future<void> setActiveUserId(int id) async {
    _id = id;
  }
}
