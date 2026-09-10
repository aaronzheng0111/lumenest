# Agent guidance (ai_mom_baby)

## Skill priority

1. [app/skills/ai_mom_baby-flutter/SKILL.md](app/skills/ai_mom_baby-flutter/SKILL.md) — project conventions and stack lock (highest).
2. `.agents/skills/riverpod`, `flutter-app-architecture`, `flutter-best-practices`, `effective-dart`, `testing` — stack-aligned defaults.
3. Topic skills: `.agents/skills/flutter-accessibility`, `flutter-performance`, `flutter-layout`, `flutter-concurrency` (each has a project override footnote).
4. Task-specific: `.agents/skills/code-review`, `.cursor/skills/ship-and-slack`.

## Stack

Riverpod + Dio + Drift. Keep MVVM layering; map teaching `ChangeNotifier` / `provider` examples to Riverpod.

## Do not

Do not adopt or imitate official `flutter-state-management` or `flutter-http-and-json` guidance that switches the app to `package:provider` or `package:http`. Do not replace Drift with sqflite scaffolding.
