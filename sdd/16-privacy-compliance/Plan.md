# Plan · 16 隐私合规

## P1 挂载

只往 01 的 `MeInfoPage` 三个 `ListTile.onTap` 填实现，不新增底栏 tab。

```
MeInfoPage
  ├── 隐私说明     → PrivacyCopy + 同意（SharedPreferences / 等价）
  ├── 导出我的数据 → 分享 JSON
  └── 删除本地数据 → 确认对话框 + wipe
```

`LlmClient.complete` / XiaonuanGraph 在 06/08 落地时检查 `privacyAccepted`；**本任务不实现 Agent 图**。

导出 JSON：

```json
{
  "user": {},
  "conversations": [],
  "messages": [],
  "profile_events": [],
  "task_cards": []
}
```

不含 LLM API key。
