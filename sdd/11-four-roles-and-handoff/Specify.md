# Specify · 11 四角色与同会话 Handoff

**期：P2。** 源 v2 §5.1–5.2。解锁 01 中林/苏心/阿嬷入口。

## 前端

### AC-11-F01 单聊
四入口均进入 SOLO，输入框可用。气泡显示名同 04 映射表。

### AC-11-F02 群聊入口
「对话」页按钮 `群聊会诊`。若 `group_consult_enabled=false`：点击后文案 `需要升级订阅`（12 未完成前可用 debug 开关强制 true 做本功能验收）。

### AC-11-F03 群聊气泡
每条 assistant 必须显示 `speakerRole` 对应中文名；同一用户问题下可连续出现 1–2 条助手消息（小暖→苏心），不得交错丢失 `agent_reply_ref`。

## 后端（编排）

### AC-11-B01 路由节点 ②
`RouterNode` 输入：`stage` + 用户文本。输出 `AgentRole`。P2 规则（顺序固定，命中即停）：

1. 显式 @小暖/@林医生/@苏心/@阿嬷 → 对应角色  
2. 否则 `fixtures/router_rules.json` 关键词  
3. 否则默认 `XIAONUAN`

SOLO 会话 **忽略** 路由，始终用 `conversation.role`。

### AC-11-B02 群聊 nextSpeaker（v2 状态机，每轮 **一次** 决策）

```
显式@ → 该角色
否则 风险分≥阈值 或 心理危机词 → SUXIN
否则 含图片 → LIN
否则 喂养/食物词 → AMA
否则 XIAONUAN
```

阈值 P2=`riskScore >= 7`（0–10，规则打分见 fixture）。**禁止**模型投票抢话。

### AC-11-B03 工具权限

| 角色 | 允许工具 |
|---|---|
| XIAONUAN | retrieve_kb（生活/情绪浅层）, read_context |
| LIN | retrieve_kb（医疗知识块）, read_context；**无**开药工具 |
| SUXIN | read_context, crisis_template；retrieve_kb 仅心理类 id 前缀 `kb-emotion` |
| AMA | retrieve_kb 生活, upsert_habit, toggle_task |

调用未授权工具 → 拒绝并记日志，改用该角色纯 LLM。

### AC-11-B04 共享上下文
GROUP 以同一 `conversationId` 读消息流；handoff **不**新开会话。

### AC-11-B05 LLM 次数
单次用户消息：默认 **1** 次 LLM（一个 speaker）。若规则要求「小暖后苏心」，允许 **2** 次、两次 speaker 不同；**禁止 ≥3**。
