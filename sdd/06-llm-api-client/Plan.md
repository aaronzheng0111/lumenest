# Plan · 06 出网 LLM 客户端

## URL 拼接

```
base = LLM_BASE_URL.trim().replaceAll(RegExp(r'/$'), '')
if (base.endsWith('/v1')) url = '$base/chat/completions'
else url = '$base/v1/chat/completions'
```

## Dart 接口

```dart
class ChatMessageWire {
  final String role; // system | user | assistant
  final String content;
}

class LlmResult {
  final LlmStatus status; // ok | timeout | httpError | parseError | missingKey
  final String? content;
  final int? promptTokens;
  final int? completionTokens;
}

abstract class LlmClient {
  Future<LlmResult> complete({
    required List<ChatMessageWire> messages,
    required String requestId,
  });
}
```

`model` 来自 dart-define `LLM_MODEL`，默认 `gpt-4o-mini`（可被 example env 覆盖）。

## 请求示例

见 `fixtures/chat_completions_request.json`。

## 与 00 关系

不新增第二种密钥通道。
