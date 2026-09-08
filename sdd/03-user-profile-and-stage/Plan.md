# Plan · 03 用户档案与阶段状态机

## 1. 模块

```
domain/stage_resolver.dart   // 纯函数，无 Flutter
domain/week_calculator.dart
data/user_profile_repository.dart
ui/me_profile_form.dart
```

## 2. API 契约（进程内）

```dart
abstract class UserProfileRepository {
  Future<UserProfileSnapshot> getSnapshot({required DateTime today});
  Future<void> saveEdits(ProfileEdits edits);
}

class ProfileEdits {
  final String? nickname;
  final DateTime? lastMenstruationDate;
  final DateTime? dueDate;
  final DateTime? birthDate;
}
```

无 HTTP。

## 3. 测试数据

所有边界日用例在 `fixtures/stage_cases.json`。新增规则必须先加 case。
