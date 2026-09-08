# Specify · 06 出网 LLM 客户端

**范围**：OpenAI 兼容 `chat/completions`；超时、失败文案、密钥注入。P1 **只允许一次成功路径上的 1 次 HTTP 调用**（由 08 保证）。  
**不做**：分级路由多模型（P2/13）、流式 UI（可选，P1 不要求 stream）。

## 前端

### AC-06-F01 错误文案
- **Given** LLM 失败（超时/5xx/无网）  
- **When** 用户已发送非红旗消息  
- **Then** 助手气泡文案 **精确** 为 `稍后再试`（四字），不得出现供应商名称、堆栈、HTTP 码、`OpenAI`、`api key`。

### AC-06-F02 加载
从发送到收到成功回复或失败文案期间，显示 `正在回复`（固定），成功后消失。

## 后端（App 内 HTTP 客户端 = 本功能的「后端适配层」）

### AC-06-B01 协议
- Method `POST`
- Path：`{LLM_BASE_URL}/chat/completions`（若 BASE_URL 已含 `/v1` 则不再重复拼接，见 Plan 规则）
- Header：`Authorization: Bearer <key>` **或** 仅打到代理（无 Bearer 供应商 key）
- Header：`x-request-id`：每请求 UUID v4
- Body JSON keys：`model`, `messages`, `temperature`；P1 `temperature=0.7` 写死

### AC-06-B02 超时
连接+首包+整体：合计 **15s** 超时。超时视为失败 → 前端 `稍后再试`。P1 **禁止重试**（避免双计费）；429 同样不重试，仅失败文案。

### AC-06-B03 解析
成功 200：取 `choices[0].message.content` 为 string；缺字段视为失败。

### AC-06-B04 密钥
从 `--dart-define` 或安全存储读取；**源码与 assets 无 key**。key 为空时：不发请求，助手文案精确 `未配置模型服务`。

### AC-06-B05 日志
可记 status code 与 latency；**禁止**记 prompt 全文与 key。
