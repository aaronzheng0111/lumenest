# Specify · 15 潮汕方言 TTS/ASR

**期：P3。** 默认先文案模板，TTS 后置（v2 开放问题 4）。

## 前端

### AC-15-F01 开关
「我的」项 `潮汕话助手` 默认关。打开后：阿嬷回复优先用 `fixtures/dialect_templates.json` 的键匹配；无匹配则普通话 + 句末固定 `（阿嬷普通话版）`。

### AC-15-F02 ASR
P3 后置：若未集成插件，语音按钮隐藏。集成后：识别失败文案 `没听清，请再说一次或打字`。

### AC-15-F03 TTS
未集成则无播放键。集成后播放阿嬷气泡；停止按钮可中断。

## 后端

### AC-15-B01 不错义
`dialect_eval.json` 中每条：模板输出必须等于 `expect` 字段（逐字）。

### AC-15-B02 不进 P1
代码可存在但 flavor 或 remote flag 默认 false；P1 构建不得依赖 TTS 原生 so 缺失而编译失败（插件 optional）。
