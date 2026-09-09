---
name: ai_mom_baby-flutter
description: >-
  Project-local notes for ai_mom_baby. Prefer official skills from
  evanca/flutter-ai-rules (flutter-best-practices, riverpod, effective-dart)
  under .agents/skills/. Use this only for app-specific conventions.
---

# ai_mom_baby project notes

Install / refresh official Flutter skills:

```bash
npx skills add evanca/flutter-ai-rules --skill flutter-best-practices --skill riverpod --skill effective-dart --skill testing --yes
```

## App-specific rules

* LLM: `LlmConfig` + `assets/fixtures/llm_models.json`; never commit secrets.
* Agent tools go through `ToolAcl` in the graph; offline uses `OfflineDefaultReply`.
* Chat drafts: `ChatDraftStore` shared by solo and group sessions.
* Flavors: always `--flavor dev` (or staging/prod) for run/build.
