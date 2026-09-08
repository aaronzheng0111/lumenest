# Specify · 04 会话 UI 与消息持久化

**范围**：对话列表、气泡、本地存消息、`speakerRole`。不跑 Agent（08 接入发送按钮）。

## 前端

### AC-04-F01 列表空态
- **Given** 无 conversations 行  
- **When** 打开「对话」tab  
- **Then** 文案精确 `还没有对话`，无崩溃。

### AC-04-F02 气泡归属
- **Given** 一条 `role=user` 与一条 `role=assistant, speakerRole=XIAONUAN`  
- **When** 打开该会话  
- **Then** 用户气泡右对齐；助手气泡左对齐且显示名称 `小暖`（映射表见 Plan，禁止显示枚举原串）。

### AC-04-F03 输入框
- **Given** SOLO + XIAONUAN  
- **When** 输入 1–2000 字点发送  
- **Then** 先插入 user 消息再清空输入框；发送过程中按钮禁用，防止双击产生 2 条相同 user 消息（1 秒内）。  
- **When** 空串或仅空白  
- **Then** 不插入消息。

### AC-04-F04 超长
- **Given** 输入 2001 字  
- **When** 发送  
- **Then** 拒绝，文案 `最多 2000 字`。

### AC-04-F05 P1 其他角色会话
见 01：横幅 `该角色将在后续版本开放`；输入框 **disabled**。

## 后端（本地）

### AC-04-B01 写入
发送（尚未接 LLM 时）仍必须写入 `messages`：user 行 `role=user, speaker_role=null`。

### AC-04-B02 会话创建
首次点小暖：若无该 user+role+SOLO 会话则创建一行；再次进入 **复用同一 conversationId**（P1 每角色最多 1 个 SOLO）。

### AC-04-B03 排序
消息按 `created_at ASC, id ASC`。列表页会话按最后一条消息时间 DESC。
