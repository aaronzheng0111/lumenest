# Plan · 10 每日任务卡

模板 JSON：`id, stage, weekMin, weekMax, title, body`。  
week 匹配：`weekMin <= weekValue <= weekMax`；PREP 的 weekMin=weekMax=null。

```dart
abstract class TaskCardService {
  Future<void> ensureTodayCards(DateTime today);
  Future<List<TaskCard>> listToday(DateTime today);
  Future<void> toggle(int id);
}
```

Agent 图 ⑥ 可在 11 将「阿嬷」工具设为 `toggleTask`，P2 未接工具前只允许 UI 勾选。
