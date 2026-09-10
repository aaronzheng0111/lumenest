---
name: ai_mom_baby-flutter
description: >-
  Project-local conventions for ai_mom_baby. Read first when changing Flutter
  features, architecture, state, networking, local DB, performance, or
  accessibility. Prefer stack-aligned skills under .agents/skills/ (riverpod,
  flutter-app-architecture, flutter-best-practices, effective-dart, testing,
  plus flutter-accessibility / performance / layout / concurrency). Use this
  skill for app-specific rules and the stack lock below.
---

# ai_mom_baby project notes

Install / refresh upstream Flutter skills (evanca; do not overwrite local topic skills):

```bash
npx skills add evanca/flutter-ai-rules --skill flutter-best-practices --skill riverpod --skill effective-dart --skill testing --skill flutter-app-architecture --skill code-review --yes
```

## Stack lock

These are the source of truth for this repo. Do not introduce a second stack to match generic Flutter docs or official agent-plugin examples.

* **State / DI:** `flutter_riverpod`. Do not add `package:provider` or use `ChangeNotifier` as the default ViewModel pattern for new code.
* **HTTP:** `dio` (including `app/lib/llm/dio_llm_client.dart`). Do not use `package:http` for new features.
* **Local DB:** `drift` (`app/lib/data/db/app_database.dart`). Do not scaffold with `sqflite`.
* **Architecture:** Keep MVVM layering (`View → ViewModel/equivalent → Repository → Service`). When `flutter-app-architecture` or `flutter-best-practices` show `ChangeNotifier` examples, implement with Riverpod (`Notifier` / `AsyncNotifier` or existing project patterns) per the `riverpod` skill.
* **Theme:** Reuse tokens under `app/lib/theme/`. Do not run a wholesale Material 3 seed-color migration from a generic theming skill.

## App-specific rules

* LLM: `LlmConfig` + `assets/fixtures/llm_models.json`; never commit secrets.
* Agent tools go through `ToolAcl` in the graph; offline uses `OfflineDefaultReply`.
* Chat drafts: `ChatDraftStore` shared by solo and group sessions.
* Flavors: always `--flavor dev` (or staging/prod) for run/build.
