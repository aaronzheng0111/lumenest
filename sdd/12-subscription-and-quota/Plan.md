# Plan · 12 订阅与额度

额度计数键：`yyyy-MM-dd` + userId 存 Drift `quota_usage` 或 Redis 预留。P2 只用 Drift。

```dart
class Entitlement {
  final Plan plan;
  final int dailyChatQuota;
  final int remainingToday;
  final bool groupConsultEnabled;
}
```
