import 'dart:convert';

import 'package:flutter/services.dart';

/// One selectable LLM from [assets/fixtures/llm_models.json].
///
/// Add a new model by appending an enabled entry to that JSON (id, displayName,
/// provider, apiModelId, optional baseUrlHint, offline flag).
class LlmModelOption {
  const LlmModelOption({
    required this.id,
    required this.displayName,
    required this.provider,
    required this.apiModelId,
    required this.enabled,
    required this.offline,
    this.baseUrlHint,
  });

  factory LlmModelOption.fromJson(Map<String, dynamic> json) {
    return LlmModelOption(
      id: json['id'] as String,
      displayName: json['displayName'] as String,
      provider: json['provider'] as String? ?? '',
      apiModelId: json['apiModelId'] as String? ?? '',
      baseUrlHint: json['baseUrlHint'] as String?,
      enabled: json['enabled'] as bool? ?? true,
      offline: json['offline'] as bool? ?? false,
    );
  }

  final String id;
  final String displayName;
  final String provider;
  final String apiModelId;
  final String? baseUrlHint;
  final bool enabled;
  final bool offline;
}

class LlmModelCatalog {
  const LlmModelCatalog({
    required this.defaultModelId,
    required this.models,
  });

  final String defaultModelId;
  final List<LlmModelOption> models;

  List<LlmModelOption> get enabledModels =>
      models.where((m) => m.enabled).toList(growable: false);

  LlmModelOption? byId(String id) {
    for (final m in models) {
      if (m.id == id) return m;
    }
    return null;
  }

  LlmModelOption resolve(String? selectedId) {
    if (selectedId != null) {
      final match = byId(selectedId);
      if (match != null && match.enabled) return match;
    }
    final fallback = byId(defaultModelId);
    if (fallback != null && fallback.enabled) return fallback;
    final enabled = enabledModels;
    if (enabled.isNotEmpty) return enabled.first;
    throw StateError('llm_models.json has no enabled models');
  }
}

LlmModelCatalog parseLlmModelCatalog(String raw) {
  final map = jsonDecode(raw) as Map<String, dynamic>;
  final list = <LlmModelOption>[];
  for (final item in map['models'] as List<dynamic>? ?? const []) {
    list.add(LlmModelOption.fromJson(item as Map<String, dynamic>));
  }
  return LlmModelCatalog(
    defaultModelId: map['defaultModelId'] as String? ?? 'local-demo',
    models: list,
  );
}

Future<LlmModelCatalog> loadLlmModelCatalog({
  AssetBundle? bundle,
  String? jsonOverride,
}) async {
  final raw = jsonOverride ??
      await (bundle ?? rootBundle)
          .loadString('assets/fixtures/llm_models.json');
  return parseLlmModelCatalog(raw);
}
