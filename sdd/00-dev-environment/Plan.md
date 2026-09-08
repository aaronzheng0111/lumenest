# Plan · 00 开发与运行环境

## 1. 蓝图

```
开发者机器
  ├── Flutter SDK (版本锁)
  ├── Android SDK + emulator 或真机
  ├── 本仓库 (Flutter 工程根，本任务创建)
  └── [可选] llm-proxy/  (仅环境变量持有 API key)
```

P1 仓库形态：`app/` Flutter 工程 + `sdd/` 规范。不建 Spring 多模块。

## 2. 数据模型

本功能无业务表。仅配置：

| 键 | 存储位置 | 进包？ |
|---|---|---|
| `LLM_BASE_URL` | dart-define / 代理 | URL 可进 dev；prod 用可配置 |
| `LLM_API_KEY` | 环境 / 代理 / 系统密钥库 | **否** |

## 3. 接口契约

### 3.1 构建（前端）

```
flutter pub get
flutter analyze
flutter test
flutter build apk --flavor dev --debug --dart-define-from-file=env/dev.json
```

`env/dev.json` **必须 gitignore**；仓库提供 `env/dev.json.example`（无真实 key）。

`env/dev.json.example` 形状：

```json
{
  "LLM_BASE_URL": "https://api.openai.com/v1",
  "LLM_API_KEY": "REPLACE_ME"
}
```

### 3.2 可选代理（后端）

```
GET  /health          → 200 {"status":"ok"}
POST /v1/chat/completions
  Header: 无供应商 key；或 X-App-Token（P2）
  Body: OpenAI Chat Completions 兼容 JSON
```

代理把 `Authorization: Bearer $LLM_API_KEY` 补上后转发。P1 可用 50 行 Dart/Node 脚本，不强制 Java。

## 4. 技术选型

| 项 | 选择 | 理由 |
|---|---|---|
| 状态管理 | 本任务不定 | 01 再定 |
| CI | GitHub Actions 或本机脚本 `tool/ci.sh` | P1 至少本机脚本 |
| minSdk | 见 `fixtures/toolchain.json` | 锁定 |

## 5. 与后续功能的接口

- 06-llm-api-client 只读 `LLM_BASE_URL` / `LLM_API_KEY` 注入点，不自己发明第二种密钥通道。
- 16-privacy 不在本任务实现加密，但本任务必须保证密钥通道可被 16 替换为系统密钥库。
