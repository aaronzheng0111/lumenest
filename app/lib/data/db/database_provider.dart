import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';

import '../../app_copy.dart';
import 'app_database.dart';
import 'connection.dart';

/// Facade for other features (03/04/10/12). UI never touches Drift types.
abstract class DatabaseProvider {
  Future<void> init();

  /// Exposed only to data-layer repositories — not UI.
  AppDatabase get db;
}

/// Thrown when schema migration cannot complete (AC-02-B04).
class LocalDataUpgradeRequiredException implements Exception {
  @override
  String toString() => AppCopy.localDataNeedsUpgrade;
}

class DriftDatabaseProvider implements DatabaseProvider {
  DriftDatabaseProvider({QueryExecutor? executor}) : _executor = executor;

  final QueryExecutor? _executor;
  AppDatabase? _db;
  bool _ready = false;

  @override
  AppDatabase get db {
    final instance = _db;
    if (instance == null) {
      throw StateError('DatabaseProvider.init() has not completed');
    }
    return instance;
  }

  @override
  Future<void> init() async {
    if (_ready) return;
    try {
      _db = AppDatabase(_executor ?? openConnection());
      // Touch the database so migrations run before seed.
      await _db!.customSelect('SELECT 1').get();
      await _db!.ensureSeedRows();
      _ready = true;
    } catch (e, st) {
      debugPrint('DatabaseProvider.init failed: $e\n$st');
      await _db?.close();
      _db = null;
      throw LocalDataUpgradeRequiredException();
    }
  }

  Future<void> close() async {
    await _db?.close();
    _db = null;
    _ready = false;
  }
}
