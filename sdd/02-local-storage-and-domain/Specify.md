# Specify · 02 本地存储与领域实体

**范围**：端侧库、表/盒、迁移、实体字段与 v2 §2 对齐（Dart 而非 JPA）。  
**不做**：业务计算（放 03）、消息 UI（04）。

## 前端

### AC-02-F01 存储对 UI 不可见
- **Given** Widget  
- **When** 读写档案  
- **Then** Widget **不得** import SQLite/ObjectBox 生成代码；只依赖 Repository 接口。

## 后端（本地数据层，跑在 App 进程）

### AC-02-B01 引擎二选一并冻结
- **Given** Plan 已选 SQLite（Drift）或 ObjectBox  
- **When** 代码合并  
- **Then** 全仓库仅此一种；禁止双写。默认：**Drift (SQLite)**（可测试 SQL、易备份）。

### AC-02-B02 最小表集（P1 必须存在）

必须有且字段不得缺（类型见 Plan）：

| 存储 | 对应 v2 |
|---|---|
| `users` | t_user |
| `conversations` | t_conversation |
| `messages` | t_message |
| `profile_events` | t_profile_event |
| `task_cards` | 任务卡（P1 可空表） |
| `subscriptions` | t_subscription（P1 一行本地 FREE） |

### AC-02-B03 单用户 MVP
- **Given** P1  
- **When** 查询 users  
- **Then** 最多 1 行；`id` 稳定（安装后不变）。卸载后数据丢失可接受（未做云备份）。

### AC-02-B04 迁移
- **Given** schema 版本 N  
- **When** 升级到 N+1  
- **Then** 旧库不丢 `users` 行；迁移失败则拒绝启动并提示 `本地数据需要升级，请更新应用`（固定文案）。

### AC-02-B05 敏感字段标记
- **Given** 实体定义  
- **When** 代码审查  
- **Then** `lastMenstruationDate` `dueDate` `birthDate` `profile_events.summary` `messages.content` 在代码注释或注解中标为 L3；`riskScore` 标 L4。加密实现属 16，本任务只标记。

### AC-02-B06 不上传整库
- **Given** 任何网络层  
- **When** P1  
- **Then** 不存在把整个 SQLite 文件或全表 dump 上传的 API。
