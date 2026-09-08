# Verify · 02 本地存储与领域实体

改列名/枚举 → 先改 Specify + `fixtures/enums.json`。

| 规格 | 校验 |
|---|---|
| AC-02-B01 | `pubspec.yaml` 无 objectbox **且** 有 drift（或反过来若变更了 Plan） |
| AC-02-B02 | 测试列出 table 名集合相等 |
| AC-02-B03 | 两次 init 后 `select users` count=1, id=1 |
| AC-02-B04 | 迁移测试 |
| AC-02-F01 | `lib/ui` 禁止 import `*.g.dart` 的 lint |
| AC-02-B06 | grep 无 upload db 路径 |
