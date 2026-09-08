# Plan · 08 P1 Demo 小暖图

## 编排（推荐手写，少依赖）

```dart
class XiaonuanGraph {
  XiaonuanGraph(this.safety, this.retriever, this.llm, this.messages);
  Future<GraphTurnResult> handle({
    required int conversationId,
    required String userText,
  });
}
```

LangChain.dart 仅当不改变 Specify 的节点顺序与一次 API 约束时允许。

## Prompt 装配

```
system = file xiaonuan_system_prompt.txt
       + optional "\n【本地资料】\n" + hits
user = userText
```

## 失败映射

| LlmStatus | 落库 content |
|---|---|
| ok | model content |
| missingKey | `未配置模型服务` |
| 其他 | `稍后再试` |

## 模块边界

- 不 import 11 的 Handoff
- 不 import 10 的 TaskService
