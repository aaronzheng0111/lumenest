# Specify · 03 用户档案与阶段状态机

**范围**：末次月经、预产期、分娩日、阶段 `resolveStage`、冗余孕周/产后周。  
**源**：v2 §2.1。日期以设备本地时区 `Asia/Shanghai` 为展示与计算日历日（P1 写死，不做时区设置项）。

## 前端

### AC-03-F01 档案表单字段
- **Given** 「我的」页  
- **When** 编辑档案  
- **Then** 可见字段仅：`昵称`（1–20 字）、`末次月经`、`预产期`、`分娩日期`（均可空）。无手机号登录（P1）。

### AC-03-F02 保存反馈
- **Given** 合法日期  
- **When** 点保存  
- **Then** 200ms 内 Toast/SnackBar 文案精确为 `已保存`；主页周次在返回后刷新。

### AC-03-F03 非法组合
- **Given** `分娩日期` 早于 `预产期` 超过 42 天或晚于今天  
- **When** 保存  
- **Then** 拒绝写入，文案 `请检查分娩日期`；库中旧值不变。

## 后端（本地领域服务）

纯函数 `resolveStage` 必须与 `fixtures/stage_cases.json` **逐条一致**。

### AC-03-B01 规则（禁止改口述，以 fixture 为准）
实现须等价于：

```
if dueDate == null → PREP
else if today < dueDate → PREGNANT
else if birthDate == null → DELIVERY
else if daysSinceBirth <= 42 → DELIVERY
else → POSTPARTUM
```

`pregnancyWeek`：PREGNANT 时 `floor((today - lastMenstruationDate).days / 7) + 1`；若无 LMP 则用 `dueDate - 280 days` 为 LMP 代理。  
范围夹紧到 1–42；超出仍存储夹紧值并记日志。

`postpartumWeek`：POSTPARTUM 或 DELIVERY 且已有 birthDate：`floor(daysSinceBirth / 7) + 1`。

### AC-03-B02 每日刷新
- **Given** App 从后台回到前台或本地日期变化  
- **When** `StageService.refresh(today)`  
- **Then** 更新 `users.stage/pregnancy_week/postpartum_week`；不发网络。

### AC-03-B03 Snapshot
`getSnapshot()` 字段与 01 Plan DTO 一致；weekUnit：PREGNANT→PREGNANCY_WEEK；产后相关→POSTPARTUM_WEEK；PREP→null。
