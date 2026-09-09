import 'dart:convert';

import 'package:flutter/services.dart';

import '../domain/agent_role.dart';

/// Scene keys for [ChatSuggestionsCatalog.suggestionsFor].
///
/// Other features can add their own keys in `chat_suggestions.json` and look
/// them up the same way (e.g. a future home teaser scene).
abstract final class ChatSuggestionScene {
  static const solo = 'solo';
  static const group = 'group';
}

/// Recommended user prompts from [assets/fixtures/chat_suggestions.json].
///
/// Edit that JSON to change chips — keyed by scene (`solo` / `group`) or by
/// [AgentRole.wireId] for role-specific lists. Lookup prefers an optional
/// role key, then the scene key, then an empty list.
class ChatSuggestionsCatalog {
  const ChatSuggestionsCatalog(this._scenes);

  final Map<String, List<String>> _scenes;

  /// Prompts for [scene], optionally overridden by [role] wire id.
  List<String> suggestionsFor(String scene, {AgentRole? role}) {
    if (role != null) {
      final byRole = _scenes[role.wireId];
      if (byRole != null && byRole.isNotEmpty) {
        return List<String>.unmodifiable(byRole);
      }
    }
    return List<String>.unmodifiable(_scenes[scene] ?? const []);
  }

  static Future<ChatSuggestionsCatalog> load({
    AssetBundle? bundle,
    String? jsonOverride,
  }) async {
    final raw = jsonOverride ??
        await (bundle ?? rootBundle)
            .loadString('assets/fixtures/chat_suggestions.json');
    return parseChatSuggestionsCatalog(raw);
  }
}

ChatSuggestionsCatalog parseChatSuggestionsCatalog(String raw) {
  final map = jsonDecode(raw) as Map<String, dynamic>;
  final scenesRaw = map['scenes'] as Map<String, dynamic>? ?? const {};
  final scenes = <String, List<String>>{};
  for (final entry in scenesRaw.entries) {
    final list = entry.value;
    if (list is! List) continue;
    scenes[entry.key] = List<String>.unmodifiable([
      for (final item in list)
        if (item is String && item.trim().isNotEmpty) item,
    ]);
  }
  return ChatSuggestionsCatalog(Map.unmodifiable(scenes));
}
