import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Persists the selected LLM catalog id (per-app).
abstract class LlmModelSelectionStore {
  Future<String?> getSelectedId();
  Future<void> setSelectedId(String id);
}

class SharedPrefsLlmModelSelectionStore implements LlmModelSelectionStore {
  static const key = 'selected_llm_model_id';

  String? _session;

  @override
  Future<String?> getSelectedId() async {
    if (_session != null) return _session;
    try {
      final prefs = await SharedPreferences.getInstance();
      return _session = prefs.getString(key);
    } catch (e) {
      assert(() {
        debugPrint('LlmModelSelectionStore.getSelectedId failed: $e');
        return true;
      }());
      return null;
    }
  }

  @override
  Future<void> setSelectedId(String id) async {
    _session = id;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(key, id);
    } catch (e) {
      assert(() {
        debugPrint('LlmModelSelectionStore.setSelectedId failed: $e');
        return true;
      }());
    }
  }
}

class MemoryLlmModelSelectionStore implements LlmModelSelectionStore {
  MemoryLlmModelSelectionStore({String? selectedId}) : _selectedId = selectedId;

  String? _selectedId;

  @override
  Future<String?> getSelectedId() async => _selectedId;

  @override
  Future<void> setSelectedId(String id) async {
    _selectedId = id;
  }
}
