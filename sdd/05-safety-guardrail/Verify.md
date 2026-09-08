# Verify · 05 本地安全节点

改红旗词 → 先改 `safety_patterns.json` 与 `safety_eval.json`，跑测试，再发版。Prompt 变更 **不能** 绕过本节点。

| 规格 | 校验 |
|---|---|
| AC-05-B03 | `safety_eval.json` 100% |
| AC-05-B01 | 单元测试 mock LLM，block 时 verify never called |
| AC-05-F02 | widget 计时或黄金路径无 `HttpClient` |
