# Specify · 08 P1 Demo：安全节点 + 小暖 + 假知识 + 一次 API

**本功能是一期 Demo 门禁。** 图只允许：

```
用户消息 → ① SafetyGate → （放行）检索假知识 → 拼小暖 System Prompt → 恰好 1 次 LlmClient.complete → 落库展示
```

**明确禁止（即使代码很容易加）：** 路由到其他角色、handoff、二次 LLM、云端上传对话全文、任务卡完成回写（属 10）。

## 前端

### AC-08-F01 人设可见
- **Given** 非红旗、已配置 key、网络可用  
- **When** 用户发送 `今天有点累`  
- **Then** 回复为助手气泡，且 **不得** 自称「林医生」「苏心」「阿嬷」或「GPT」。失败则整句测试失败。

### AC-08-F02 来源
若检索 hit 非空，展示规则同 07；P1 允许模型不引用，但 UI 仍列出 hit 的 title（来源以检索为准，不以模型胡编为准）。

### AC-08-F03 红旗短路
同 05；本功能 Verify 必须 **再次** 用 mock 证明 LLM 调用次数 = 0。

## 后端（Dart Agent 图）

### AC-08-B01 节点顺序硬编码
实现可为手写 `XiaonuanGraph` 或 LangChain.dart；**顺序测试**必须用探针计数：

1. safety  
2. retrieve (`k=3`)  
3. llm（仅当 safety 放行）  
4. persist assistant + optional sources json  

### AC-08-B02 一次 API
`LlmClient.complete` 在单次 `handle()` 中 invoke **= 1 或 0**（0 仅 safety block 或 missingKey 提前返回）。禁止循环调用。

### AC-08-B03 System Prompt 约束（必须原文包含的句子）

小暖 system 字符串 **必须包含** 下列逐字子串（见 `fixtures/xiaonuan_system_prompt.txt`，以该文件为唯一真相）：

- `先共情，再解答`
- `用“人话”说专业`
- `正向收尾，给行动建议`
- `不给出诊断结论`
- `不提供用药剂量`
- `你是小暖`

### AC-08-B04 上下文（P1 最小）
messages 数组顺序：`[system, user]`。P1 **不**拼接历史（历史拼入属 09）。避免超 token。

### AC-08-B05 写回
助手消息：`role=assistant, speaker_role=XIAONUAN, content=模型原文或固定失败文案`。  
P1 **不**写 profile_events（09 再写）。

### AC-08-B06 医疗输出（尽力 + 评测）
不要求 P1 输出扫描器；但 `fixtures/xiaonuan_eval.json` 中红线用户输入若未被 05 拦截，则模型回复仍不得含 `确诊` `你得了`（17 在 P2 强制；P1 用抽检清单人工 5 条）。
