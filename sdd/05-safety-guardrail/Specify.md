# Specify · 05 本地安全节点（Guardrail）

**范围**：Agent 图第 ① 步。红旗 **只许本地规则**，命中则 **禁止调用 LLM**，返回固定文案。  
**源**：v2 §8.1、§11.1。

## 前端

### AC-05-F01 展示
- **Given** 安全节点拦截  
- **When** 助手回复上屏  
- **Then**：
  - `speakerRole` 仍为当前会话角色（P1=小暖），但气泡左上角徽章文案 `安全提示`（固定）
  - 用户可继续输入下一句

### AC-05-F02 无「思考中」超时
从点发送到固定文案上屏 **≤ 300ms**（本机，不含动画），因无网络。

## 后端（本地规则引擎）

### AC-05-B01 先于一切模型
`SafetyGate.inspect(text)` 在路由、检索、LLM **之前**。命中 `block=true` 则图终止。

### AC-05-B02 红旗类别与动作

| category | 动作 | LLM |
|---|---|---|
| `MEDICAL_EMERGENCY` | 返回 `fixtures/safety_replies.json` 中该 key 的 `reply` 全文，不得改字 | 否 |
| `PSYCH_CRISIS` | 同上；P1 仍由本节点处理，不转苏心 | 否 |
| `PROMPT_INJECTION` | 同上 | 否 |
| `MEDICATION_DOSE` | 同上（用药剂量套话） | 否 |
| `none` | 放行 | 后续节点决定 |

匹配：对用户原文做 Unicode NFC 后大小写折叠；命中 `fixtures/safety_patterns.json` 任一 `patterns[]` 子串或正则（字段 `type`: `contains` | `regexp`）。

### AC-05-B03 评测集红线
`fixtures/safety_eval.json` 中 `"mustBlock": true` 的用例 **拦截率 100%**。  
`"mustBlock": false` 的用例 **不得** 拦截（防止「孕期腹痛」过度拦截日常「有点腰酸」——以 fixture 为准）。

### AC-05-B04 审计
每次拦截写本地日志表或文件一行：`timestamp, category, patternId, conversationId`；**不**把完整危机原文同步云端（P1 无云）。
