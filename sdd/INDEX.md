# 孕期 AI 高级助理 · 规范驱动开发（SDD）索引

> 源文档：`孕期AI高级助理_技术设计说明_v2.md`  
> 落地形态：**Android App（Flutter）内嵌 AI-Agent**；一期 Demo 本地编排 + 出网 LLM。  
> 原则：**先改规范，再改代码**。含糊描述不得进入 `Specify.md`。

## 0. 产品一句话

覆盖「备孕 → 孕期 → 生产 → 产后 12 个月」的 AI 陪伴助手。核心交付是 **4 个角色 Agent 的对话陪伴**，不是工具箱。

## 1. 技术栈（覆盖 v2 中的 Java 后端默认项）

| 层 | 本期决策 | 说明 |
|---|---|---|
| UI | Flutter（Android 先发，架构不挡 iOS） | 取代「App/小程序壳」的前端实现路径 |
| 本地存储 | SQLite 或 ObjectBox | 用户档案、孕周/阶段、习惯、任务、会话摘要 |
| Agent 编排 | Dart Agent 图（LangChain.dart 或手写路由） | 一次消息走固定节点，不把编排放在 Java 服务 |
| 知识 | 本地文档块 + 向量检索 | 一期允许假数据 / 假检索 |
| LLM | OpenAI 兼容 HTTP API | **密钥不进 APK**；经 `--dart-define` / 安全存储 / 自有代理 |
| 多模态 | 三期 | 报告图 → 视觉 API |
| 方言 | 三期 | TTS/ASR 插件；一期不做 |
| 云端 Java | **非一期阻塞项** | 订阅支付、推送、Token 看板可二期再拆服务；契约仍写在对应 Plan |

原 v2 的 Spring Cloud / MySQL / Kafka 视为 **P2+ 可选云端蓝图**，不得阻塞 Flutter Demo。

## 2. 一次消息的 Agent 图（全期目标）

```
用户说话
  → ① 安全节点（本地规则）：红旗？→ 固定就医/危机文案，停，不调 LLM
  → ② 路由：备孕/孕期/产后 + 意图 → 派给哪位角色
  → ③ 读本地上下文切片（孕周、习惯、近期摘要）拼进 prompt
  → ④ 该角色 Agent：需要知识则本地检索 → 调 LLM API → 回消息（带来源）
  → ⑤ 可选 handoff：同会话接力，共享上下文
  → ⑥ 写回本地：摘要 / 任务状态（不上传整库）
```

四角色 = 4 套 System Prompt + 不同工具权限：

| 角色 | ID | 工具侧重 |
|---|---|---|
| 小暖 | `XIAONUAN` | 陪伴、提醒；免费层默认入口 |
| 林医生 | `LIN` | 知识引用、产检/症状边界（不诊断、不处方） |
| 苏心 | `SUXIN` | 情绪边界、危机热线（L4） |
| 阿嬷 | `AMA` | 生活任务、喂养/月子（三期可方言） |

## 3. 分期（开发必须遵守，不得把三期能力塞进一期任务）

| 期 | 必须跑通 | 明确不做 |
|---|---|---|
| **P1 Demo** | ① 安全节点 + **一个角色（小暖）** + **假知识** + **一次 LLM API** + 主页/对话壳 + 本地档案最小集 | 四角色 handoff、任务卡推送、检查单视觉、方言、付费 |
| **P2** | 四角色 + handoff + 每日任务卡 + 订阅额度 + Token 流水（可先本地）+ guardrail 评测门禁 | 潮汕 TTS/ASR、完整毛利看板 |
| **P3** | 检查单多模态、周报趋势、方言、裂变、可观测看板 | — |

## 4. 开发顺序（文件夹编号 = 实施顺序）

| 目录 | 功能 | 对应源文档 | 期 |
|---|---|---|---|
| [00-dev-environment](00-dev-environment/) | Flutter/Android 工程、密钥与 CI | §4 部署、§8 密钥 | P1 |
| [01-app-home-and-navigation](01-app-home-and-navigation/) | 主页与信息架构；「我的」Info 页挂载 16 P1 | §0 产品、§9 P1 壳、§8 最小隐私 | P1 |
| [02-local-storage-and-domain](02-local-storage-and-domain/) | 本地库与领域实体 | §2 | P1 |
| [03-user-profile-and-stage](03-user-profile-and-stage/) | 用户档案与阶段状态机 | §2.1 | P1 |
| [04-chat-ui-and-session](04-chat-ui-and-session/) | 会话 UI 与消息持久化 | §2.3、§7.1 | P1 |
| [05-safety-guardrail](05-safety-guardrail/) | 本地安全节点 | §8、§11 红线 | P1 |
| [06-llm-api-client](06-llm-api-client/) | 出网 LLM 客户端 | §5.4 | P1 |
| [07-local-knowledge-retrieval](07-local-knowledge-retrieval/) | 本地知识/假检索 | §5.1 知识 | P1 |
| [08-p1-agent-xiaonuan-demo](08-p1-agent-xiaonuan-demo/) | 一期垂直切片（图 ①+④ 单角色） | §5、用户给定编排 | P1 **Demo 门禁** |
| [09-context-slice-memory](09-context-slice-memory/) | 上下文切片与摘要写回 | §2.4、开放问题 3 | P1 可简化 / P2 完整 |
| [10-daily-task-cards](10-daily-task-cards/) | 每日任务卡 | §6.1、§7.3 | P2 |
| [11-four-roles-and-handoff](11-four-roles-and-handoff/) | 四角色 + 群聊接力 | §5.1–5.2、§7.2 | P2 |
| [12-subscription-and-quota](12-subscription-and-quota/) | 订阅与额度 | §2.2、§7.4 | P2 |
| [13-token-ledger](13-token-ledger/) | Token 记账与预算 | §5.3 | P2 |
| [14-exam-report-multimodal](14-exam-report-multimodal/) | 检查单解读 | §6.2 | P3 |
| [15-dialect-tts-asr](15-dialect-tts-asr/) | 潮汕方言 | §1、开放问题 4 | P3 |
| [16-privacy-compliance](16-privacy-compliance/) | 分级、加密、导出删除 | §8.2–8.3 | P1 挂 01 Info 页 / P2 完整 |
| [17-ai-eval-regression](17-ai-eval-regression/) | 评测集与发布门禁 | §11 | P2 起强制 |
| [18-observability-slo](18-observability-slo/) | SLO 与看板 | §10 | P2/P3 |

## 5. 每个功能文件夹约定

| 文件 | 职责 |
|---|---|
| `Specify.md` | 可测试验收标准；**前端 / 后端（含本地服务层）分写** |
| `Plan.md` | 数据模型、API/接口契约、模块蓝图 |
| `Tasks.md` | 可并行的原子任务（含依赖） |
| `Verify.md` | 如何用规范做自动/手工校验；变更必须先改 Specify |
| `用户验收步骤.md` | 非开发人员可执行的步骤 |
| `fixtures/*.json` | 仅当该功能需要固定输入/输出做测试时提供 |

## 6. 规范驱动开发循环（全仓库强制）

1. **Specify**：写 Given/When/Then，拒绝「尽量」「适当」「友好一点」。
2. **Plan**：规格 → 表结构 / Dart 接口 / HTTP 契约。
3. **Tasks**：一切代码工作必须挂任务 ID。
4. **Implement**：只实现 Tasks 中已列出的项。
5. **Verify**：对照 Specify；失败则改规范或改实现，**禁止只改测试来迁就错误产品行为**。

## 7. 原 v2 开放问题的默认决策（未确认前按此实现）

1. 多模态：P3；自持 OCR + 聚合 VLM；图片 L3；7 天清理。
2. Handoff：先规则引擎（§5.2 状态机），不上模型抢话。
3. 记忆：最近 20 轮原文 + 周摘要；摘要进 prompt。
4. 方言：P3；先文案模板，TTS 后置。
5. 敏感数据：检查单与情绪摘要端侧主存；云端只存加密摘要（若上云）。
6. 模型映射：轻问答小模型、深度大模型；P1 可固定一个兼容端点。
7. 危机热线：法务/医疗顾问首版；未提供前使用 `fixtures/crisis_hotlines.json` 占位并在 UI 标明「待官方复核」。
