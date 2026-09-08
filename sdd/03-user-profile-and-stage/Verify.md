# Verify · 03 用户档案与阶段状态机

改状态机 → 先改 `stage_cases.json` 与 Specify，再改 Dart。禁止先改代码让个别测试过。

| 规格 | 校验 |
|---|---|
| AC-03-B01 | `stage_cases.json` 100% 通过 |
| AC-03-B02 | 模拟日期 +1 天，week 变化断言 |
| AC-03-F03 | widget 测试保存被拒、DB 不变 |
