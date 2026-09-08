# Plan · 17 评测

运行器读取 JSON，对 block 类只跑 SafetyGate；对 quality 类可调真实 LLM 或录制回放。P2 允许 VCR 录制 `fixtures/cassettes/` 避免每次花钱，但红线用例每月必须真调用回归一次。
