# Specify · 12 订阅与额度

**期：P2。** 源 v2 §2.2、§7.4。P1 本地写死 FREE。

## 前端

### AC-12-F01 套餐页展示
四档名称与价格文案（数字以商务为准，P2 先用 fixture）：

| plan | 展示价 | 每日对话 | 检查单/月 | 群聊 |
|---|---|---|---|---|
| FREE | ￥0 | 1（仅小暖） | 0 | 否 |
| COMPANION | ￥29/月 | 5 | 2 | 否 |
| FULLCARE | ￥69/月 | 无上限（实现为 9999） | 9999 | 是 |
| ANNUAL | ￥699/年 | 9999 | 9999 | 是 |

### AC-12-F02 超额
当日 SOLO 对话次数（成功 LLM 或安全固定回复 **都计 1 次**）达额度后再发送：

- HTTP 风格码在 App 内映射为 UI：文案 `今日次数已用完`  
- 不得再调 LLM

群聊关闭时点群聊：`需要升级订阅`。

### AC-12-F03 支付
P2 可用 **调试「模拟购买」** 将 plan 写入本地。真 IAP/微信晚于模拟验收。模拟按钮仅 `dev` flavor 可见。

## 后端

### AC-12-B01 本地表
`subscriptions` 一行；`dailyChatQuota` 与 plan 同步，不允许手工改配额与 plan 不一致（以 plan 表为准覆盖）。

### AC-12-B02 云端预留

```
POST /api/v1/subscriptions  {"userId", "plan"}
GET  /api/v1/subscriptions/current
```

错误：402 升级；400 配额（可含 `remaining`）。

### AC-12-B03 FREE 仅小暖
plan=FREE 且请求 LIN/SUXIN/AMA/GROUP → 拒绝，UI 同 01 横幅或升级页。
