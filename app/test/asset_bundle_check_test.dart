import 'package:flutter_test/flutter_test.dart';

import 'package:ai_mom_baby/agent/role_prompts.dart';
import 'package:ai_mom_baby/chat/chat_suggestions_catalog.dart';
import 'package:ai_mom_baby/domain/agent_role.dart';
import 'package:ai_mom_baby/knowledge/knowledge_retriever.dart';
import 'package:ai_mom_baby/llm/llm_model_catalog.dart';
import 'package:ai_mom_baby/safety/safety_gate.dart';

/// Guards against pubspec omitting fixture subdirectories (Flutter does not
/// recurse into `assets/fixtures/` automatically). Missing prompts made group
/// chat throw on send while solo chat silently fell back.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('bundled RolePrompts assets load for every role', () async {
    for (final role in AgentRole.values) {
      final text = await RolePrompts.load(role);
      expect(text.trim(), isNotEmpty, reason: role.wireId);
    }
  });

  test('bundled safety patterns asset loads', () async {
    final gate = await LocalSafetyGate.load();
    expect(gate, isA<LocalSafetyGate>());
  });

  test('bundled knowledge chunks asset loads', () async {
    final r = await FakeSubstringRetriever.load();
    expect(r, isA<FakeSubstringRetriever>());
  });

  test('bundled llm_models.json loads', () async {
    final catalog = await loadLlmModelCatalog();
    expect(catalog.enabledModels, isNotEmpty);
  });

  test('bundled chat_suggestions.json loads', () async {
    final catalog = await ChatSuggestionsCatalog.load();
    expect(
      catalog.suggestionsFor(ChatSuggestionScene.solo),
      isNotEmpty,
    );
    expect(
      catalog.suggestionsFor(ChatSuggestionScene.group),
      isNotEmpty,
    );
  });
}
