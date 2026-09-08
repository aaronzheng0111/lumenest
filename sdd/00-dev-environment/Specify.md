# Specify · 00 开发与运行环境

**范围**：可克隆即可在本机编译出 Android Debug APK；密钥永不打进包。  
**不做**：生产签名上架、K8s、Java 微服务集群。

## 前端（Flutter / Android）

### AC-00-F01 工具链版本锁定
- **Given** 仓库根目录存在版本锁文件  
- **When** 开发者按文档安装 SDK  
- **Then** 必须同时满足：
  - Flutter SDK 版本与 `sdd/00-dev-environment/fixtures/toolchain.json` 中 `flutter` 字段 **逐位一致**（不允许「3.x 即可」）
  - Dart SDK 落在该 Flutter 捆绑范围内
  - Android `compileSdk` / `minSdk` / `targetSdk` 与同一 JSON 的 `android` 字段一致  
- **Fail**：文档只写「最新 Flutter」而无锁定文件。

### AC-00-F02 一键本地构建
- **Given** 已安装锁定版本工具链、已配置 Android SDK  
- **When** 执行仓库文档中的 **唯一** 构建命令（不得有未文档化的前置手工步骤）  
- **Then** 10 分钟内产出 `debug` APK，exit code = 0。

### AC-00-F03 构建变体
- **Given** 工程已初始化  
- **When** 分别构建 `dev` / `staging` / `prod` flavor（若 P1 仅 `dev`，则 `staging`/`prod` 可空实现但 flavor 名必须存在）  
- **Then** 每个 flavor 的 `applicationId` 后缀不同（`dev` 为 `.dev`），避免覆盖安装生产包。

### AC-00-F04 密钥不进包
- **Given** 任意 flavor 的 APK  
- **When** 解包并扫描字符串/资源  
- **Then**：
  - 不出现 `sk-` 开头、长度 ≥ 20 的 OpenAI 类密钥
  - 不出现明文 `OPENAI_API_KEY=`
  - LLM base URL 与 key 仅允许来自：运行时 `--dart-define`、系统环境、或用户本机安全存储（见 06）
- **Fail**：`lib/` 或 `assets/` 内硬编码 key。

### AC-00-F05 静态检查门
- **Given** CI 或本地 pre-push  
- **When** 运行 `flutter analyze`  
- **Then** 0 error；warning 策略写在 Plan，P1 允许 warning 但必须有清单，不得静默忽略 analyzer。

## 后端（本机代理 / 可选）

P1 **允许没有独立后端**。若采用「本机或内网 LLM 代理以免 key 进包」，下列条款生效；若完全 `--dart-define` 仅用于开发机，则 AC-00-B02 标记 N/A 并在 Verify 记录。

### AC-00-B01 代理不进 APK
- **Given** 选择了 HTTP 代理保存供应商 key  
- **When** App 发 LLM 请求  
- **Then** App 只持有 **短期会话令牌或空**，供应商 key 仅存在于代理进程环境变量，不在 Flutter 资源中。

### AC-00-B02 代理健康检查
- **Given** 代理已启动  
- **When** `GET /health`  
- **Then** 200 且 JSON 含 `"status":"ok"`，响应时间 P95 < 200ms（本机）。

### AC-00-B03 无后端时的明确契约
- **Given** P1 选择直连兼容 API  
- **When** 阅读 Plan  
- **Then** Plan 必须写明：生产环境 **禁止** 把供应商 key 打进 prod APK 的迁移路径（至少一种：用户粘贴到系统密钥库 / 自有代理）。

## 非功能

### AC-00-N01 可重复
同一 commit，两台 Mac（darwin）按文档操作，构建结果差异仅限签名时间戳，不得因「某同学本机改过 gradle」而失败。
