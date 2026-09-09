import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:ai_mom_baby/llm/dio_llm_client.dart';
import 'package:ai_mom_baby/llm/llm_model_catalog.dart';
import 'package:ai_mom_baby/llm/llm_model_selection_store.dart';

void main() {
  const fixture = '''
{
  "defaultModelId": "local-demo",
  "models": [
    {
      "id": "local-demo",
      "displayName": "本地演示",
      "provider": "offline",
      "apiModelId": "",
      "baseUrlHint": null,
      "enabled": true,
      "offline": true
    },
    {
      "id": "deepseek-chat",
      "displayName": "DeepSeek",
      "provider": "deepseek",
      "apiModelId": "deepseek-chat",
      "baseUrlHint": "https://api.deepseek.com",
      "enabled": true,
      "offline": false
    },
    {
      "id": "disabled-one",
      "displayName": "Off",
      "provider": "x",
      "apiModelId": "x",
      "enabled": false,
      "offline": false
    }
  ]
}
''';

  test('parseLlmModelCatalog loads enabled models and default', () {
    final catalog = parseLlmModelCatalog(fixture);
    expect(catalog.defaultModelId, 'local-demo');
    expect(catalog.enabledModels.map((m) => m.id), ['local-demo', 'deepseek-chat']);
    expect(catalog.resolve(null).id, 'local-demo');
    expect(catalog.resolve('deepseek-chat').displayName, 'DeepSeek');
    expect(catalog.resolve('missing').id, 'local-demo');
    expect(catalog.resolve('disabled-one').id, 'local-demo');
  });

  test('withModelOption overrides model and forceOffline', () {
    const env = LlmConfig(
      baseUrl: 'https://proxy.example/v1',
      apiKey: 'secret',
      model: 'gpt-4o-mini',
    );
    final catalog = parseLlmModelCatalog(fixture);
    final offline = env.withModelOption(catalog.resolve('local-demo'));
    expect(offline.forceOffline, isTrue);
    expect(offline.model, 'gpt-4o-mini');
    expect(offline.baseUrl, 'https://proxy.example/v1');

    final deepseek = env.withModelOption(catalog.resolve('deepseek-chat'));
    expect(deepseek.forceOffline, isFalse);
    expect(deepseek.model, 'deepseek-chat');
    expect(deepseek.baseUrl, 'https://proxy.example/v1');
  });

  test('withModelOption uses baseUrlHint when env baseUrl empty', () {
    const env = LlmConfig(baseUrl: '', apiKey: 'k', model: 'gpt-4o-mini');
    final catalog = parseLlmModelCatalog(fixture);
    final deepseek = env.withModelOption(catalog.resolve('deepseek-chat'));
    expect(deepseek.baseUrl, 'https://api.deepseek.com');
    expect(deepseek.model, 'deepseek-chat');
  });

  test('DioLlmClient respects forceOffline even with key', () {
    final client = DioLlmClient(
      config: const LlmConfig(
        baseUrl: 'https://example.com/v1',
        apiKey: 'present',
        model: 'x',
        forceOffline: true,
      ),
    );
    expect(client.canCallRemote, isFalse);
  });

  test('SharedPrefs selection store persists id', () async {
    SharedPreferences.setMockInitialValues({});
    final store = SharedPrefsLlmModelSelectionStore();
    expect(await store.getSelectedId(), isNull);
    await store.setSelectedId('deepseek-chat');
    expect(await store.getSelectedId(), 'deepseek-chat');

    final again = SharedPrefsLlmModelSelectionStore();
    expect(await again.getSelectedId(), 'deepseek-chat');
  });
}
