# ai_mom_baby

Flutter app for AI-Mom-Baby. See the repo root [README](../README.md) for setup, flavors, and dart-defines.

## LLM model picker

Chat screens load the selectable model list from `assets/fixtures/llm_models.json` (symlinked to repo `assets/`). Selection is stored in SharedPreferences (`selected_llm_model_id`) and overrides `LLM_MODEL` at runtime. The 「本地演示」 entry forces offline default replies even if a key is present.
