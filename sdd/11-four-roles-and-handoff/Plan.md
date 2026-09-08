# Plan · 11 四角色 Handoff

四份 prompt 文件：`fixtures/prompts/{xiaonuan,lin,suxin,ama}_system_prompt.txt`。  
小暖文件与 08 **同源**（复制或共享 assets，禁止两份漂移：测试比对 hash）。

```dart
AgentRole nextSpeaker({
  required ConversationType type,
  required AgentRole soloRole,
  required String userText,
  required bool hasImage,
  required int? riskScore,
});
```

群聊 REST 预留（云端可选）：

```
POST /api/v1/conversations/group
```

响应形状对齐 v2 §7.2。
