# Verify · 06 出网 LLM 客户端

改超时、文案、URL 规则 → 先改 Specify。

用 MockWebServer：200 正常 / 500 / hang / 非法 JSON。断言无重试（请求计数=1）。
