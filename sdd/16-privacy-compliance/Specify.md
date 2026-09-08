# Specify · 16 隐私合规与数据生命周期

**P1 最小 + P2 完整。** 源 v2 §8.2–8.3。  
**P1 入口**：全部挂在 **01 `MeInfoPage`（`/me`）**，不另做独立模块首页。同意 **不依赖** 08；08 接入 LLM 时必须读同一 `privacyAccepted` flag。

## 前端

### AC-16-F01 同意（Info 页，非全屏拦截启动）
- **Given** 用户打开「我的」并点 `隐私说明`  
- **When** 展示说明  
- **Then**：
  - 页面或对话框标题精确为 `隐私说明`
  - 正文须含子串：`健康数据以设备本地为主` 与 `不上传整库`
  - 按钮至少有 `同意并继续`（可另有 `关闭`）；**不要求**「退出应用」
  - 点同意后本地 flag `privacyAccepted=true`（杀进程仍在）
- **Given** `privacyAccepted=false`  
- **When** 任何代码路径准备调用 LLM  
- **Then** **不得**发出 HTTP；用户可继续看主页 / Info 页。聊天发送时文案精确为 `请先在「我的」同意隐私说明`。

### AC-16-F02 导出
Info 页点 `导出我的数据` → 生成 JSON（字段见 Plan），拉起系统分享。P1 无库时导出 `{"user":{},"conversations":[],"messages":[],"profile_events":[],"task_cards":[]}` 仍算通过。不含 LLM API key。

### AC-16-F03 删除
Info 页点 `删除本地数据`，二次确认文案 `将删除本机档案与对话，且不可恢复`。确认后：有库则清空并重建 id=1 空用户；无库则仅把 `privacyAccepted` 置 `false` 且不 crash。P1 无云则 7 个工作日条款不适用；若已上云，删除请求状态机：`REQUESTED` 起 7 个工作日内完成。

## 后端

### AC-16-B01 分级
L3/L4 字段清单与 02 注释一致。P2：L3 字段 SQLCipher 或 Drift 加密库；密钥在 Android Keystore，**不是**硬编码。

### AC-16-B02 最小化
P1 不采集手机号、通讯录、精确 GPS。

### AC-16-B03 审计 L4
读取 `risk_score` 必须写 audit：`timestamp, reason=app_feature, featureId`。无运营后台则 operator=`local_app`。
