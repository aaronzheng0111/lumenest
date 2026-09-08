# Plan · 04 会话 UI 与消息持久化

## 模块

```
ui/chat_page.dart
ui/conversation_list_page.dart
data/conversation_repository.dart
```

## 进程内 API

```dart
abstract class ConversationRepository {
  Future<int> getOrCreateSolo({required AgentRole role});
  Future<List<Message>> listMessages(int conversationId);
  Future<int> insertUserMessage({required int conversationId, required String content});
  Future<List<ConversationListItem>> listConversations();
}
```

P1 发送链路：ChatPage → insertUserMessage →（08）AgentGraph.handle。

## 显示名

| AgentRole | UI |
|---|---|
| XIAONUAN | 小暖 |
| LIN | 林医生 |
| SUXIN | 苏心 |
| AMA | 阿嬷 |

## 无 REST（P1）

v2 `POST /api/v1/conversations` 映射为本 Repository；P2 若上云，JSON 字段名保持：

```json
{
  "userId": 1,
  "role": "XIAONUAN",
  "type": "SOLO",
  "message": { "content": "...", "imageRef": null }
}
```
