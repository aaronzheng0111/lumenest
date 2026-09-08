# Tasks · 06 出网 LLM 客户端

| ID | 任务 | 依赖 | 可并行 |
|---|---|---|---|
| T06-01 | LlmClient + URL 规则单测 | 00 define | |
| T06-02 | 超时 15s（假服务器不响应） | T06-01 | 与 T06-03 并行 |
| T06-03 | 200 缺 choices 视为失败 | T06-01 | |
| T06-04 | missingKey 文案由 08 映射；本层返回 missingKey | T06-01 | |
| T06-05 | 日志脱敏测试（mock logger 不含 Bearer） | T06-01 | 并行 |

完成：全部。
