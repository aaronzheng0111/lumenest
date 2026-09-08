# 孕期 AI 高级助理 · 项目开发追踪清单 (Task.md)

> **版本**：v1.0 (2026-09-08)  
> **技术架构基线**：Flutter (Android 优先) + 本地持久化 (SQLite/ObjectBox) + 本地 Agent 编排 + 出网 LLM API  
> **视觉设计基线**：[`DESIGN.md`](./DESIGN.md) · Apple Liquid Glass 苹果磨砂玻璃规范 · 素材目录 `assets/`  
> **规范依据**：[`孕期AI高级助理_技术设计说明_v2.md`](./孕期AI高级助理_技术设计说明_v2.md) 及 [`sdd/`](./sdd/INDEX.md) 模块  

---

## 📊 项目总览与进度看板

```
[Phase 0: 准备与基础设施] ──────> [Phase 1: P0 单角色可运行 Demo] ──────> [Phase 2: P1 四角色会诊与记忆] ──────> [Phase 3: P2 商业化与高阶能力]
        (进度: 100%)                     (进度: 100%)                           (进度: 80%)                          (进度: 0%)
```

- **P0 紧急核心**：完成 Flutter 骨架、设计系统 Token 落地、本地存储、安全红旗拦截、小暖单角色出网对话。
- **P1 重要增强**：多角色会诊 (Handoff)、上下文记忆切片、每日任务卡片、本地知识库。
- **P2 商业扩展**：配额与订阅、Token 记账看板、隐私与合规归档。
- **P3 进阶体验**：化验单多模态识别、方言 TTS/ASR 语音陪伴。

---

## 阶段 0：设计系统与工程基础设施（Phase 0 · 准备工作）

### 0.1 视觉与素材资产准备
- [x] **TASK-001** 确立 Apple Liquid Glass 磨砂玻璃视觉语言与设计规范 ([`DESIGN.md`](./DESIGN.md))
- [x] **TASK-002** 生成 6 屏高保真磨砂玻璃参考 Mockup (`mockups/glass/`)
- [x] **TASK-003** 导出核心视觉素材包 (`assets/`):
  - [x] 品牌 Logo: `assets/brand/logo.png`
  - [x] 首页孕周卡插画: `assets/illustrations/hero-pregnancy.png`
  - [x] 聊天空态插画: `assets/illustrations/empty-chat.png`
  - [x] 四角色头像: `assets/avatars/xiaonuan.png`, `dr-lin.png`, `suxin.png`, `ama.png`

### 0.2 工程脚手架初始化
- [x] **TASK-004** [P0] 初始化 Flutter Android 项目工程骨架 (`sdd/00-dev-environment`)
  - [x] `app/` Flutter 工程 + flavors `dev`/`staging`/`prod` + `env/dev.json.example`
  - [x] 配置 `pubspec.yaml` 核心依赖（`dio`；状态管理 / 本地库留给 01–02）
  - [x] 注册 `assets/` 静态图片（symlink → 仓库根 `assets/`）
  - [x] `tool/ci.sh` + `tool/scan_apk_secrets.sh` + 根 `README.md`
- [x] **TASK-005** [P0] 落地 Liquid Glass UI Token 与基础玻璃组件
  - [x] `AppColors`、`GlassTokens`、`RadiusTokens`、`ShadowTokens`、`SpacingTokens`、`AppTheme`
  - [x] 基础组件：`GlassContainer`、`GlassAppBar`、`GlassTabBar` + `AtmosphereBackground`
  - [x] `main.dart` Token 预览页（TASK-101 替换为真实三 Tab）

---

## 阶段 1：P0 核心可用链路（MVP 单角色陪伴 Demo）
> **目标**：用户打开 App 能看到磨砂玻璃首页，能够与「小暖」进行流式对话，本地具备安全红旗拦截与持久化。

### 1.1 页面骨架与导航 (P0)
- [x] **TASK-101** [P0] 实现悬浮式磨砂底栏与三 Tab 页面骨架 (`sdd/01-app-home-and-navigation`)
  - [x] 首页 (Home)、对话 (Chat)、我的 (Me) · Riverpod · `GlassTabBar`
  - [x] 首页英雄卡（阶段 Chip + 周次 + 插画）、四角色 2×2（小暖可进会话，其余锁定横幅）
  - [x] 「我的」三项入口 + 隐私 Sheet / 空 JSON 导出 / 删除确认（16 P1 挂载）
- [x] **TASK-102** [P0] 实现「我的」与隐私设置弹窗 (`sdd/16-privacy-compliance`)
  - [x] 设置列表项（隐私说明、数据导出、删除数据；编辑档案留给 TASK-104）
  - [x] 磨砂玻璃 Sheet 弹窗交互与用户授权状态持久化（T16-01…03 P1）

### 1.2 本地数据层与领域模型 (P0)
- [x] **TASK-103** [P0] 本地数据库初始化与表结构设计 (`sdd/02-local-storage-and-domain`)
  - [x] Drift `AppDatabase`：users / conversations / messages / profile_events / task_cards / subscriptions + schema_meta
  - [x] 启动 ensure 单行 user id=1 与 FREE 订阅；v1→v2 空迁移骨架；L3/L4 字段标记
  - [x] AgentRole 等枚举 wire 值与 `assets/fixtures/enums.json` 对齐
- [x] **TASK-104** [P0] 孕周与阶段推导服务 (`sdd/03-user-profile-and-stage`)
  - [x] `resolveStage` / week 计算器与 `stage_cases.json` 对齐；Drift 档案读写
  - [x] 「编辑档案」表单 + 分娩日期校验；AppLifecycle 触发 refresh

### 1.3 安全拦截与模型网关 (P0)
- [x] **TASK-105** [P0] 本地安全防御前置节点 (Guardrail) (`sdd/05-safety-guardrail`)
  - [x] `LocalSafetyGate` + patterns/replies/eval fixtures；拦截审计日志（不含原文）
  - [x] Chat 接入与「安全提示」徽章留给 TASK-107/108
- [x] **TASK-106** [P0] 出网 LLM API Client 实现 (`sdd/06-llm-api-client`)
  - [x] OpenAI 兼容 `chat/completions`（P1 非流式）；15s 超时且禁止重试
  - [x] `--dart-define` 密钥；缺 key / 失败固定文案；日志脱敏

### 1.4 聊天界面与小暖对话闭环 (P0)
- [x] **TASK-107** [P0] 对话界面实现 (`sdd/04-chat-ui-and-session`)
  - [x] 磨砂气泡左右对齐 + speaker 显示名；胶囊输入；草稿 SharedPreferences
  - [x] ConversationRepository（getOrCreateSolo 幂等、2000 字限制、防双击）
- [x] **TASK-108** [P0] 小暖 Agent 对话全链路连通 (`sdd/08-p1-agent-xiaonuan-demo`)
  - [x] `XiaonuanGraph`：Safety → 假知识检索 → 恰好 0/1 次 LLM → 落库
  - [x] System prompt 子串门禁；红旗短路 llm.calls==0；来源 Chip

---

## 阶段 2：P1 核心价值深化（四角色会诊与记忆切片）
> **目标**：解锁其余三位专家角色，支持多角色接力会诊（Handoff），引入本地知识检索与动态记忆。

### 2.1 本地知识库与记忆切片 (P1)
- [x] **TASK-201** [P1] 本地知识检索与 RAG 插件 (`sdd/07-local-knowledge-retrieval`)
  - [x] 内置孕期常见食物红黑榜、孕检时间表文档
  - [x] 本地关键词 / 向量检索节点，回答时附带「来源: 权威指南」标牌
- [x] **TASK-202** [P1] 上下文记忆切片服务 (`sdd/09-context-slice-memory`)
  - [x] 维护用户近 7 天情绪、孕周、睡眠与身体习惯摘要
  - [x] 动态拼接至 Prompt 上下文，避免超长 Token 浪费，保证陪伴连续性

### 2.2 四角色解锁与接力会诊 (P1)
- [x] **TASK-203** [P1] 激活林医生、苏心、阿嬷三位专家 Agent (`sdd/11-four-roles-and-handoff`)
  - [x] 林医生（医学产检、症状分析、工具调用）
  - [x] 苏心（产前焦虑、产后情绪、身心放松引导）
  - [x] 阿嬷（生活偏方纠偏、坐月子饮食、习俗关怀）
- [x] **TASK-204** [P1] 多角色群聊会诊机制 (Handoff) (`sdd/11-four-roles-and-handoff`)
  - [x] 主持人路由机制：小暖判断专业问题自动 @林医生 或 @苏心
  - [x] 消息列表支持多角色归属展示（带对应角色头像与专属气泡标识）

### 2.3 孕期每日任务体系 (P1)
- [ ] **TASK-205** [P1] 首页每日任务卡片体系 (`sdd/10-daily-task-cards`)
  - [ ] 动态任务生成（数胎动、喝水记录、孕期补钙、散步打卡）
  - [ ] 任务状态持久化与打卡轻动效

---

## 阶段 3：P2 商业化飞轮与质量保障
> **目标**：建立商业转化与 Token 计量，保障数据隐私与离线体验。

### 3.1 商业化与配额管理 (P2)
- [ ] **TASK-301** [P2] Token 消耗账本与会话计费 (`sdd/13-token-ledger`)
  - [ ] 每次对话实时记录 Prompt Tokens 与 Completion Tokens
  - [ ] 本地生成用户专属的 Token 消耗看板
- [ ] **TASK-302** [P2] 订阅体系与角色权益配额 (`sdd/12-subscription-and-quota`)
  - [ ] 免费体验包（小暖每日限额）与专业会诊包（四角色无限畅聊）
  - [ ] 会员权益墙与升级提示

### 3.2 隐私合规与数据安全 (P2)
- [ ] **TASK-303** [P2] 隐私合规体系 (`sdd/16-privacy-compliance`)
  - [ ] 敏感医疗信息脱敏
  - [ ] 一键导出完整健康数据包 (JSON/CSV) 与本地数据彻底粉碎清空

### 3.3 质量评估与稳定性 (P2)
- [ ] **TASK-304** [P2] AI 回复回归评测集 (`sdd/17-ai-eval-regression`)
  - [ ] 预设 50+ 孕期标准问答评测样本，验证角色不越界、红旗 100% 拦截
- [ ] **TASK-305** [P2] 异常监控与 SLO 埋点 (`sdd/18-observability-slo`)
  - [ ] 统计 API 延迟、流式首字耗时 (TTFT)、报错率与断网降级

---

## 阶段 4：P3 进阶体验与多模态 (未来规划)
- [ ] **TASK-401** [P3] 化验单 / B超图多模态视觉解析 (`sdd/14-exam-report-multimodal`)
- [ ] **TASK-402** [P3] 拟人化方言语音陪伴 (TTS / ASR) (`sdd/15-dialect-tts-asr`)
- [ ] **TASK-403** [P3] 伴侣端数据同步与双人协同陪伴

---

## 📋 快速任务执行排期建议 (Sprint 排期)

| 周期 | 核心交付物 | 对应任务 | 交付标志 |
|---|---|---|---|
| **Sprint 1 (当前)** | 磨砂玻璃视觉框架 + Flutter 骨架 + 本地数据表 | TASK-004 ~ 005, TASK-101 ~ 104 | 手机端可安装，三 Tab 可切换，UI 符合 DESIGN.md |
| **Sprint 2** | 安全红旗拦截 + 小暖单角色对话流式跑通 | TASK-105 ~ 108 | 小暖能正常流式聊天，触发危急词立即拦截 |
| **Sprint 3** | 四角色会诊 (Handoff) + 记忆切片 + 知识检索 | TASK-201 ~ 205 | 四角色均可对话，支持小暖转接林医生 |
| **Sprint 4** | 订阅配额 + 隐私合规 + 自动化评测与发布 | TASK-301 ~ 305 | 商业飞轮闭环，满足上架合规要求 |
