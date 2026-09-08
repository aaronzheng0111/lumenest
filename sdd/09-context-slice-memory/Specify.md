# Specify · 09 上下文切片与摘要写回

**范围**：Agent 图 ③ 读切片、⑥ 写摘要。P1 可在 08 之后立刻做最小版；完整 20 轮 + 周摘要为默认方案（v2 开放问题 3）。

## 前端

### AC-09-F01 用户无感知开关
无单独「记忆管理」复杂 UI。P1 仅在「我的」提供 `清除对话摘要` 按钮，确认文案 `将删除本地摘要，对话气泡仍保留`。

## 后端

### AC-09-B01 切片内容
拼进 prompt 的 context 块必须按固定标题顺序：

```
【档案】阶段={stage} 周次={weekValue}{weekUnit}
【习惯】{habits or "无"}
【近期摘要】{summaries, newest last, max 5}
```

习惯 P1：`profile_events` 中 `category=HABIT` 最多 10 条 summary 拼接，总长 ≤ 500 字。

### AC-09-B02 历史原文
P2：最近 **20** 条消息原文（user+assistant）接在 system+context 之后。P1：可 0 条（08 行为）；本功能完成后改为最多 20。

### AC-09-B03 写回
每轮 LLM **成功** 后异步生成摘要：允许 **规则截断** 前 80 字作为 P1 摘要（不强制再调 LLM）。写入 `profile_events`：`category=SUMMARY`。失败的 LLM 回合不写摘要。

### AC-09-B04 不上传整库
摘要仅本地；无 HTTP 上传 events。
