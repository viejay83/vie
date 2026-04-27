# northsea-task-router

Lightweight routing skill for NorthSea AI Systems.
Use this before acting on any non-trivial task to classify it and choose the smallest sufficient capability.

Do not load this skill for tiny, obvious tasks (e.g. "what is X", "show me Y"). Use it when the task type is ambiguous or involves production systems.

---

## How to Use

1. Read the incoming task.
2. Find the matching row below.
3. Apply the routing — use the recommended agent/skill, respect risk level, run the verification step before reporting done.

---

## Routing Table

### n8n workflow — build or extend

```
task_type:          n8n_workflow_build
recommended_agent:  n8n-workflow-engineer
recommended_skill:  —
risk_level:         medium
allowed_actions:    read workflow JSON, edit nodes, create new workflow, test via webhook
forbidden_actions:  restart n8n/Docker without rollback plan, read .env, delete workflows
verification_step:  trigger test webhook and confirm expected output
```

---

### n8n workflow — debug / broken

```
task_type:          n8n_workflow_debug
recommended_agent:  systematic-debugger → n8n-workflow-engineer
recommended_skill:  —
risk_level:         medium
allowed_actions:    read logs (docker logs), inspect node output, targeted file read
forbidden_actions:  restart n8n without rollback, broad log scans, read credentials
verification_step:  reproduce error → apply fix → confirm resolved in execution log
```

---

### Telegram callback bug

```
task_type:          telegram_callback_bug
recommended_agent:  systematic-debugger
recommended_skill:  —
risk_level:         medium
allowed_actions:    inspect workflow, check Answer Callback Query node position, read Telegram logs
forbidden_actions:  restart bot/n8n without rollback, hardcode tokens
verification_step:  click inline button → confirm callback acknowledged within 2s, no "query too old" error
```

---

### Google Sheets update issue

```
task_type:          sheets_update_issue
recommended_agent:  systematic-debugger → n8n-workflow-engineer
recommended_skill:  —
risk_level:         low
allowed_actions:    inspect Sheets node config, check value_input_option, verify match key
forbidden_actions:  write formulas or leading = unless explicitly requested, use company name as match key
verification_step:  run node in test mode → confirm row updated by stable ID, value is RAW
```

---

### Monetization / outreach / sales strategy

```
task_type:          monetization_strategy
recommended_agent:  northsea-monetization-architect
recommended_skill:  —
risk_level:         low
allowed_actions:    read context files, draft offers, write outreach copy, plan funnels
forbidden_actions:  make external API calls, send real messages, commit sales copy as config
verification_step:  review output with Vie before acting on any outreach
```

---

### Code review

```
task_type:          code_review
recommended_agent:  code-reviewer (spawn if available)
recommended_skill:  —
risk_level:         low
allowed_actions:    read source files, diff, report issues
forbidden_actions:  edit files during review pass, run tests that modify state
verification_step:  confirm review covers logic, security, n8n rules, and NorthSea coding standards
```

---

### Docker / VPS issue

```
task_type:          docker_vps_issue
recommended_agent:  systematic-debugger
recommended_skill:  —
risk_level:         high
allowed_actions:    docker ps, docker logs (targeted), inspect compose file
forbidden_actions:  docker compose down, docker volume rm, docker system prune, restart without rollback plan
verification_step:  confirm service status with docker ps → check logs → report before any restart
```

---

### Claude Code config issue

```
task_type:          claude_code_config
recommended_agent:  —
recommended_skill:  northsea-task-router (this skill)
risk_level:         low
allowed_actions:    read CLAUDE.md, settings.json, agents/, hooks/, skills/
forbidden_actions:  delete existing config, overwrite without backup, push without review
verification_step:  bash -n hook; validate settings.json; confirm file exists after change
```

---

### OpenClaw / Friday runtime issue

```
task_type:          openclaw_friday_runtime
recommended_agent:  systematic-debugger
recommended_skill:  —
risk_level:         high
allowed_actions:    read runtime logs, inspect agent config, targeted file inspection
forbidden_actions:  restart OpenClaw/Friday without explicit approval, read .env or tokens
verification_step:  reproduce issue in logs → identify root cause → propose fix → wait for approval before applying
```

---

### External API integration

```
task_type:          external_api_integration
recommended_agent:  n8n-workflow-engineer (if n8n) or systematic-debugger (if broken)
recommended_skill:  —
risk_level:         medium
allowed_actions:    read API docs (fetch only when needed), inspect existing HTTP nodes, test with safe payload
forbidden_actions:  hardcode API keys, commit tokens, run live API calls against production without confirmation
verification_step:  confirm request/response shape matches expected schema in test mode
```

---

### Documentation-only task

```
task_type:          documentation
recommended_agent:  —
recommended_skill:  —
risk_level:         low
allowed_actions:    read files, write markdown, update CLAUDE.md or agent docs
forbidden_actions:  modify runtime config or app logic while doing docs
verification_step:  confirm file saved and content is accurate — no functional side effects
```

---

## Risk Level Guide

| Level | Meaning | Default action |
|-------|---------|----------------|
| low | No production impact, fully reversible | Proceed |
| medium | May affect workflow behavior or data | Confirm test step before finishing |
| high | Can break running services or lose data | Stop and explain before acting — get approval |

---

## Routing Fallback

If no row matches:
1. Default to `systematic-debugger` for any error/broken state.
2. Default to `northsea-monetization-architect` for any revenue/sales question.
3. Default to `n8n-workflow-engineer` for any automation build question.
4. If still unclear: report task_type as `unknown`, list options, and ask Vie before acting.
