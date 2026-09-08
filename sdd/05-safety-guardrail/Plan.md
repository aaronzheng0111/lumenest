# Plan · 05 本地安全节点

## 1. 在图中的位置

```
ChatPage.send
  → SafetyGate.inspect
       → blocked: persist assistant message (fixed reply), return
       → pass: next node (P1: XiaonuanAgent)
```

## 2. 接口

```dart
class SafetyDecision {
  final bool block;
  final String? category; // MEDICAL_EMERGENCY | PSYCH_CRISIS | PROMPT_INJECTION | MEDICATION_DOSE
  final String? patternId;
  final String? reply;
}

abstract class SafetyGate {
  SafetyDecision inspect(String userText);
}
```

**同步纯函数**，无 IO（审计异步 fire-and-forget）。

## 3. 文案与热线

回复全文只来自 JSON。热线占位见 `fixtures/crisis_hotlines.json`，嵌入 PSYCH_CRISIS 模板的 `{hotline}` `{hotline_name}`。

## 4. 输出侧（P2 完整）

P1 **不做** LLM 输出后再扫描；08 的 LLM 回复在 P2 由 17 评测 + 可选 OutputGuard。Specify 此处不要求输出扫描。
