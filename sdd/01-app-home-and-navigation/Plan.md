# Plan · 01 主页与导航

## 1. Flutter 信息架构

```
MaterialApp
  └── Shell (IndexedStack)
        ├── HomePage          // 本功能
        ├── ConversationList  // 04 实现，本功能只放路由占位
        └── MeInfoPage        // 本功能：简单 Info 列表；16 P1 挂三项；03 后补「编辑档案」
```

路由名锁定：

| name | 页 |
|---|---|
| `/` | Shell 默认首页 |
| `/chat` | 单聊（query: `role`） |
| `/me` | 我的 Info 页 |

## 2. 读取模型（前端 DTO，由 03 提供）

```dart
class UserProfileSnapshot {
  final Stage stage; // PREP, PREGNANT, DELIVERY, POSTPARTUM
  final int? weekValue;
  final String? weekUnit; // PREGNANCY_WEEK | POSTPARTUM_WEEK | null
}
```

主页 **不得** 自己用日期算孕周。

## 3. Widget 蓝图

- `HomeStageHeader`：阶段 + 周次
- `RoleEntryGrid`：2×2，顺序固定 小暖、林医生、苏心、阿嬷
- `TodayTaskTeaser`：P1 静态文案
- `AppBottomNav`：3 tab
- `MeInfoPage`：`ListTile` 三项（隐私说明 / 导出我的数据 / 删除本地数据）；不在本页做加密或评测

## 4. 状态管理

P1 使用 `ChangeNotifier` 或 `Riverpod` **二选一，在本 Plan 冻结**：默认 **Riverpod**。后续功能不得再引入第二套全局方案。

## 5. 后端

无 REST。Repository 接口属于 03，本功能只依赖接口，03 未完成时用 `FakeUserProfileRepository` 返回 PREP。
