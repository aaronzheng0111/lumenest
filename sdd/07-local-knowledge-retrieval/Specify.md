# Specify · 07 本地知识检索

**范围**：角色需要知识时的检索。P1 **假数据即可**，但接口形状必须与真向量检索兼容。  
**不做**：云端知识库 CMS。

## 前端

### AC-07-F01 来源展示
- **Given** Agent 回复使用了检索命中  
- **When** 气泡渲染  
- **Then** 底部展示 `来源：` + `title` 列表，最多 3 条；title 取自 chunk 元数据。无命中则 **不** 显示「来源」二字。

## 后端（本地检索）

### AC-07-B01 接口
```
Future<List<KnowledgeHit>> search(String query, {int k = 3})
```
每条 `KnowledgeHit`：`id, title, text, score`（0–1，假检索可用 1.0/0.5/0.2）。

### AC-07-B02 P1 假实现
语料仅来自 `fixtures/knowledge_chunks.json`。算法：对 query 分词（按空格与中文逐字 bigram 均可）与 chunk.text **子串命中计数** 排序，取 top k。无命中返回 `[]`。

### AC-07-B03 不联网
search **禁止** HTTP。

### AC-07-B04 可替换
存在 `KnowledgeRetriever` 抽象；P2 可用向量实现替换而不改 08 的调用签名。
