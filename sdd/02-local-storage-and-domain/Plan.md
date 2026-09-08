# Plan · 02 本地存储与领域实体

## 1. 选型

**Drift + sqlite3**。测试用 `NativeDatabase.memory()`。

## 2. 表结构（契约）

### users
| 列 | 类型 | 约束 |
|---|---|---|
| id | int | PK，P1 恒为 1 |
| nickname | text | 默认 `妈妈` |
| stage | text | PREP/PREGNANT/DELIVERY/POSTPARTUM |
| last_menstruation_date | date nullable | |
| due_date | date nullable | |
| birth_date | date nullable | |
| pregnancy_week | int nullable | 冗余，03 刷新 |
| postpartum_week | int nullable | |
| created_at / updated_at | datetime | |

### conversations
id, user_id, role (AgentRole), type (SOLO/GROUP), created_at

### messages
id, conversation_id, role (user/assistant/system), speaker_role nullable, content, image_ref nullable, token_cost nullable, agent_reply_ref nullable, created_at

### profile_events
id, user_id, week_start, week_value, week_unit, category, summary, raw_ref, risk_score nullable

### task_cards
id, user_id, local_date, stage, week_value, payload_json, status (PENDING/DONE/SKIPPED)

### subscriptions
id, user_id, plan (FREE/COMPANION/FULLCARE/ANNUAL), start_at, expire_at, daily_chat_quota, monthly_report_quota, group_consult_enabled

### schema_meta
version int

## 3. Repository 接口（供其他功能）

```dart
abstract class DatabaseProvider {
  Future<void> init();
}
```

具体 Repository 在 03/04/10/12 定义，本功能提供 Drift 生成类与 `AppDatabase`。

## 4. 枚举字符串

与 JSON fixture 完全一致：`fixtures/enums.json`。
