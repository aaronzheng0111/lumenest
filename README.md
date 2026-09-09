# 孕期 AI 高级助理（AI-Mom-Baby）

Flutter（Android 优先）本地 Agent + 出网 LLM。规范在 `sdd/`，工程在 `app/`。

工具链版本锁：[`sdd/00-dev-environment/fixtures/toolchain.json`](sdd/00-dev-environment/fixtures/toolchain.json)（当前 Flutter **3.24.5**）。

## 本机安装（macOS）

1. **Flutter 3.24.5**（须与锁文件逐位一致）

```bash
git clone --depth 1 --branch 3.24.5 https://github.com/flutter/flutter.git ~/development/flutter
export PATH="$HOME/development/flutter/bin:$PATH"
flutter precache --android
```

2. **Android SDK**（Android Studio）+ `ANDROID_HOME`，并接受 licenses：

```bash
export ANDROID_HOME="$HOME/Library/Android/sdk"
export ANDROID_SDK_ROOT="$ANDROID_HOME"
flutter doctor --android-licenses
```

3. **JDK 17**（推荐 Android Studio 自带 JBR）：

```bash
export JAVA_HOME="/Applications/Android Studio.app/Contents/jbr/Contents/Home"
```

4. **本地密钥文件**（不入库）

```bash
cd app
cp env/dev.json.example env/dev.json
# 编辑 env/dev.json，填入 LLM_BASE_URL / LLM_API_KEY
```

## 在 Android Studio 里点运行

Flutter 工程在 **`app/`**，不在仓库根目录。若打开的是 `AI-Mom-Baby`（能看到 `sdd/`、`Task.md`），绿色 Run 会是灰的，顶部会显示 **Add Configuration...**。

1. **File → Open…**，选 `~/Desktop/AI-Mom-Baby/app`（里面有 `pubspec.yaml`、`lib/`）。
2. 等右下角 Flutter / Gradle 同步结束。
3. 顶部设备选 **Pixel 4 API 34**。
4. Run 配置选 **dev**（已带 `--flavor dev`）。没有的话：Run → Edit Configurations → Flutter → Additional run args 填：

```
--flavor dev --dart-define-from-file=env/dev.json
```

不指定 flavor 会编不过（工程有 `dev` / `staging` / `prod` 三个变体）。

## 唯一推荐构建命令（dev debug APK）

```bash
cd app
flutter pub get
flutter build apk --flavor dev --debug --dart-define-from-file=env/dev.json
```

产物：`app/build/app/outputs/flutter-apk/app-dev-debug.apk`

或一键：

```bash
./tool/ci.sh
```

## Flavors

| Flavor | applicationId | 说明 |
|--------|---------------|------|
| `dev` | `com.aimombaby.ai_mom_baby.dev` | 日常开发 |
| `staging` | `com.aimombaby.ai_mom_baby.staging` | 预发 |
| `prod` | `com.aimombaby.ai_mom_baby` | 正式（P1 可空实现） |

## 密钥约定

- 禁止在 `lib/` / `assets/` 硬编码供应商 key。
- 开发机用 `--dart-define-from-file=env/dev.json`；生产须迁到系统密钥库或自有代理（见 `sdd/00-dev-environment` / `06-llm-api-client`）。

## 模拟用户与启动隐私文案

测试夹具：[`assets/fixtures/模拟用户与隐私文案.md`](assets/fixtures/模拟用户与隐私文案.md)

- `mock-user.json`：冷启动首页用的模拟档案（当前孕 16 周）
- `privacy-notice.json`：**每次启动**弹出的隐私状况页（改 JSON 即可改文案）
- `llm_models.json`：聊天页模型下拉目录（DeepSeek / GLM / OpenAI 兼容 / 本地演示）。新增模型：追加一条 `enabled: true` 的条目（`id`、`displayName`、`provider`、`apiModelId`、可选 `baseUrlHint`、`offline`）

## 文档入口

- 产品与分期：[`sdd/INDEX.md`](sdd/INDEX.md)
- 任务清单：[`Task.md`](Task.md)
- 视觉：[`DESIGN.md`](DESIGN.md)
