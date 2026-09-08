# Specify · 13 Token 记账与预算

**期：P2。** 源 v2 §5.3。P1 字段 `messages.token_cost` 可空。

## 前端

### AC-13-F01 用户不可见明细
P2 不在聊天页展示 token 数字。仅 `我的 → 开发者信息`（dev flavor）显示当日 token 合计。

## 后端

### AC-13-B01 流水
每次成功 LLM 写 `token_ledger`：userId, scene, promptTokens, completionTokens, model, requestId, createdAt。  
scene 枚举：`DAILY_CHAT|RECORD_FEEDBACK|SYMPTOM_QA|EXAM_INTERPRET|DEEP_COUNSEL|GROUP_CONSULT`。P2 对话默认 `DAILY_CHAT`，群聊 `GROUP_CONSULT`。

### AC-13-B02 失败不计
超时/稍后再试 **不** 写成功流水（可写 `status=failed` 可选）。

### AC-13-B03 分级路由（可同迭代）
按 v2 表：日常→小模型 define `LLM_MODEL_SMALL`；群聊/心理深度→ `LLM_MODEL_LARGE`。P2 若只有一个 endpoint，两个 define 可相同，但代码分支必须存在。

### AC-13-B04 日预算告警
本地阈值：当日合计 tokens > `fixtures/budget.json` 的 `dailyTokenWarn` 时打日志 `TOKEN_BUDGET_WARN`；**不**悄改回复内容。超 `dailyTokenHard`：新请求走「稍后再试」且不调大模型。
