---
name: ship-and-slack
description: >-
  Ship chat/agent work end-to-end: remove debug instrumentation if present,
  commit, push, and post a concise update to Slack #ai-mom-baby. Use when the
  user asks to commit push slack, 发版同步, ship update, ship-and-slack, or
  /ship-and-slack.
disable-model-invocation: true
---

# Ship and Slack

Automate: **clean debug logs → commit → push → Slack `#ai-mom-baby`**.

## Guardrails

- Never update git config
- Never force-push to `main`/`master`
- Never commit secrets: `.env`, `app/env/dev.json`, API keys, tokens
- Never leave `agentDebugLog` / `AGENT_DEBUG` / `#region agent log` / `debug_agent_log.dart` in the commit
- Do not commit `.cursor/debug-*.log`

## Workflow

Copy and track:

```
Ship Progress:
- [ ] 1. Clean debug instrumentation
- [ ] 2. git status / diff / log
- [ ] 3. Stage (exclude secrets)
- [ ] 4. Commit (HEREDOC)
- [ ] 5. Push
- [ ] 6. Slack #ai-mom-baby
```

### 1) Clean debug instrumentation

Search the repo for:

- `agentDebugLog`
- `AGENT_DEBUG`
- `#region agent log`
- `debug_agent_log.dart`

If found: strip imports and calls; delete `app/lib/debug_agent_log.dart` when unused. Keep real product fixes.

### 2) Inspect git state (parallel)

```bash
git status
git diff
git diff --cached
git log -5 --oneline
```

### 3) Stage relevant files only

Exclude secrets and debug logs. Include product code, tests, fixtures, and this skill if changed.

### 4) Commit

```bash
git add <paths>
git commit -m "$(cat <<'EOF'
<concise why-focused message>

EOF
)"
git status
```

Suggested direction (adjust to diff): ship UX/agent fixes; remove debug probes.

### 5) Push

```bash
git push -u origin HEAD
```

Need network. Never `--force` on main/master.

### 6) Slack update

Channel: **`#ai-mom-baby`** / id **`C0C08H8S6CS`**

Use Slack MCP `slack_send_message`. If auth required, call `mcp_auth` for the Slack namespace.

Template:

```
*Shipped* — <one-line summary>

• What: <bullets>
• Verify: <how to check in app>
• Commit: `<sha>` — <github commit URL if remote known>
```

Keep it short. Lead with the point. Return the message permalink to the user.

## Afterward

Report: commit SHA + message, push remote/branch, Slack permalink, what was cleaned vs shipped.
