# Verify · 01 主页与导航

改文案、tab 数量、P1 角色锁定 → 先改 Specify。

| 规格 | 校验 |
|---|---|
| AC-01-F01 | golden 或 `find.text`：四角色名；阶段四枚举映射表单测 |
| AC-01-F02 | 点击小暖 `expect` 路由 `/chat?role=XIAONUAN`；点击林医生 expect 横幅文案 |
| AC-01-F03 | 恰好 3 个 BottomNavigationBarItem |
| AC-01-F04 | 测试绑定拦截 HTTP，pump 主页无 exception |
| AC-01-B01 | mock repository 调用次数 = 1 |
| AC-01-B02 | 拦截器记录 0 次出站请求 |
| AC-01-F05 | `find.text('隐私说明')` 等三项；点击不抛异常 |
