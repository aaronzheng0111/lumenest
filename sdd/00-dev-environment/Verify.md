# Verify · 00 开发与运行环境

## 规范优先

环境版本、flavor 名、密钥策略变更 → **先改 Specify.md 与 `fixtures/toolchain.json`**，再改 Gradle/脚本。禁止只改脚本让测试通过。

## 自动校验

| 规格 | 方法 | 状态 | 说明 |
|---|---|---|---|
| AC-00-F01 | 比对 `toolchain.json` 与 `flutter --version` | ✅ PASS | Flutter 3.24.5 / Java 17 / SDK 35 锁定 |
| AC-00-F02 | `tool/ci.sh` exit 0 | ✅ PASS | 产出 `app-dev-debug.apk` |
| AC-00-F03 | 解析 `android/app/build.gradle` 存在三个 flavor | ✅ PASS | `dev` (`.dev`), `staging` (`.staging`), `prod` |
| AC-00-F04 / T00-07 | 对 APK 跑 `scan_apk_secrets.sh` | ✅ PASS | 解包扫描无 `sk-` / `OPENAI_API_KEY` 泄漏 |
| AC-00-F05 | `flutter analyze` 无 error | ✅ PASS | 0 error, 0 warning |
| AC-00-B02 | 若有代理：curl `/health` | N/A | P1 采用 `--dart-define` 直连，未部署代理 |

## 历史构建异常记录与归因 (Troubleshooting Log)

1. **Google Maven 依赖下载 TLS 握手中断**
   - **现象**：`Execution failed for task ':gradle:compileGroovy'` -> `Could not download manifest-merger-30.3.0.jar`，提示 `Remote host terminated the handshake`。
   - **根因**：国内网络直连 Google Maven 仓库连接不稳定。
   - **解决方案**：在 `settings.gradle` 和 `build.gradle` 中增加阿里云 Maven 镜像源优先解析 (`maven.aliyun.com/repository/google` 与 `central`)。

2. **Gradle 构建进程触发磁盘写满 (No space left on device)**
   - **现象**：`java.io.IOException: No space left on device`，Gradle 下载 `kotlin-compiler-embeddable-1.8.22.jar` 时中断。
   - **根因**：构建机磁盘可用空间耗尽。
   - **解决方案**：重启并清理磁盘空间（恢复至 21GB+ 可用空间）后恢复正常构建。

3. **APK 密钥扫描误报 Vulkan/Skia 调试符号**
   - **现象**：`tool/scan_apk_secrets.sh` 提示 `found sk- secret-like string in APK`。
   - **根因**：初版扫描正则 `sk-[A-Za-z0-9_-]{20,}` 将 Vulkan 验证层 `libVkLayer_khronos_validation.so` 中的 `sk-commandBuffer-parameter` 等图形库符号误判为密钥。
   - **解决方案**：修正正则为精准匹配 OpenAI 密钥结构 `(sk-[A-Za-z0-9]{20,}|sk-(proj|svcacct|admin)-[A-Za-z0-9_-]{20,})`，复测无泄漏且 0 误报通过。

## 手工

见 `用户验收步骤.md`。
