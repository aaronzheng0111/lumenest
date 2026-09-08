# Specify · 10 每日任务卡

**期：P2。** 源 v2 §6.1。P1 主页只显示占位（01）。

## 前端

### AC-10-F01 今日卡
- **Given** 本地日期 D、用户 stage+week 已刷新  
- **When** 打开首页  
- **Then** 「今日任务」列出当日 `task_cards` 中 `local_date=D` 的全部任务，每条含 `title` 与勾选框。无任务时文案 `今天没有安排的任务`（**替换** P1 占位句）。

### AC-10-F02 勾选
点勾选 → 状态 `DONE`，立即反映；再次点击变 `PENDING`。离线可用。

### AC-10-F03 推送（P2）
本地通知：当日 08:00（设备时区）若有 PENDING 任务，通知标题 `今日任务`，正文取第一条 title。无系统通知权限则静默，首页仍显示任务。

## 后端

### AC-10-B01 生成
App 启动或日期变更：按 `fixtures/task_templates.json` 匹配 `stage + weekValue`（`weekValue` 空则只匹配 stage=`PREP` 的模板）。写入当日卡，**幂等**：同一 user+date 不重复插入。

### AC-10-B02 不编造医学处方
模板文案禁止含剂量（fixture 评审）；生成器不得拼接药品名。

### AC-10-B03 云推送
P2 默认 **仅本地通知**。微信/厂商推送列为可选后端，若做则契约：

```
POST /internal/jobs/daily-cards  (服务端调度)
```

App 侧无此接口也可验收 AC-10-F01/F02。
