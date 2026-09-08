# Plan · 09 上下文切片

```dart
class ContextSlice {
  final String promptBlock; // 含三个固定标题
  final List<ChatMessageWire> recentTurns; // ≤20
}

abstract class ContextSlicer {
  Future<ContextSlice> build({required int userId});
}

abstract class SummaryWriter {
  Future<void> writeTurnSummary({required int userId, required String assistantContent, required String rawRef});
}
```

08 的 Graph 在本功能完成后改为 messages = `[system+promptBlock, ...recent, user]`。仍 **一次** LLM。
