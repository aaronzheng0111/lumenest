# Tasks · 04 会话 UI 与消息持久化

| ID | 任务 | 依赖 | 可并行 |
|---|---|---|---|
| T04-01 | ConversationRepository + 测试 getOrCreate 幂等 | 02 | |
| T04-02 | ChatPage 气泡与发送插入 | T04-01, 01 路由 | |
| T04-03 | 列表页空态与排序 | T04-01 | 与 T04-02 并行 |
| T04-04 | 防双击与 2000 字限制测试 | T04-02 | |
| T04-05 | 预留 `onUserMessageInserted` 回调给 08 | T04-02 | |

完成：T04-01…05。
