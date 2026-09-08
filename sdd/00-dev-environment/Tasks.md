# Tasks · 00 开发与运行环境

并行组 A（无依赖）：T00-01, T00-02  
然后 B：T00-03, T00-04  
然后 C：T00-05

| ID | 任务 | 依赖 | 产出 | 建议执行方 |
|---|---|---|---|---|
| T00-01 | 锁定 `fixtures/toolchain.json` 并写 `README` 安装步骤（仅本功能相关） | — | JSON + 安装段落 | 任一人 |
| T00-02 | `flutter create` 工程到约定目录，提交 `.gitignore`（含 `env/*.json` 除 example） | — | Flutter 工程骨架 | 任一人 |
| T00-03 | 配置 flavors：`dev`/`staging`/`prod` 与 applicationId 后缀 | T00-02 | Android flavor | Android |
| T00-04 | 增加 `env/dev.json.example` 与 `--dart-define-from-file` 构建说明 | T00-02 | example + 文档 | 任一人 |
| T00-05 | `tool/ci.sh`：analyze + test + 构建 debug apk（可跳过无设备安装） | T00-03, T00-04 | 脚本 | 任一人 |
| T00-06 | （可选）最小 LLM 代理 + `/health` | T00-04 | `tool/llm_proxy/` | 后端 |
| T00-07 | APK 字符串扫描脚本：禁止 `sk-` 长密钥 | T00-05 | `tool/scan_apk_secrets.sh` | 任一人 |

完成定义：T00-01…05 与 T00-07 全绿；T00-06 若未做，Verify 中 AC-00-B02 = N/A。
