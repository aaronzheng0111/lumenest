# Verify · 08 P1 Demo

**门禁：** 本目录 Verify 全绿才能宣称「一期 Demo 完成」。

| 规格 | 校验 |
|---|---|
| AC-08-B01/B02 | mock：block 时 llm.calls==0；pass 时 llm.calls==1 |
| AC-08-B03 | prompt 文件包含指定子串 |
| AC-08-B04 | complete 传入 messages.length==2 |
| AC-08-F03 | 集成：红旗无 HTTP |

变更人设：先改 `xiaonuan_system_prompt.txt` 与 Specify 子串列表。
