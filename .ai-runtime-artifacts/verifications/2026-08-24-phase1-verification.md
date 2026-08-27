# Phase 1 验证 · L2 基石

## 验收标准（spec §8 Phase 1）

1. `harness-kit.yaml` 存在，7 stages + 4 gates + 6 builtin_flows ✅
2. `agent.cordis.yml` 存在，4 个 compose plugin ✅
3. 6 个 system prompt 文件，每个 ≥200 词，含 `.ai-runtime-artifacts/` 路径模板 ✅
4. 8 个 SKILL.md，每个 front matter 完整，含 `harness_artifact_write` 引用 ✅

## 验证结果

```
Phase 1 OK · 16 files
```

**文件清单（16 个）：**
- `plans/fixtures/harness-kit.yaml`
- `plans/fixtures/agent.cordis.yml`
- `plans/fixtures/prompts/leader.system.md` (547 词)
- `plans/fixtures/prompts/coder.system.md` (597 词)
- `plans/fixtures/prompts/reviewer.system.md` (497 词)
- `plans/fixtures/prompts/tester.system.md` (520 词)
- `plans/fixtures/prompts/security.system.md` (538 词)
- `plans/fixtures/prompts/perf.system.md` (559 词)
- `plans/fixtures/skills/harness-brief/SKILL.md`
- `plans/fixtures/skills/harness-spec/SKILL.md`
- `plans/fixtures/skills/harness-plan/SKILL.md`
- `plans/fixtures/skills/harness-dispatch/SKILL.md`
- `plans/fixtures/skills/harness-verify/SKILL.md`
- `plans/fixtures/skills/harness-review/SKILL.md`
- `plans/fixtures/skills/harness-ship/SKILL.md`
- `plans/fixtures/skills/harness-coda/SKILL.md`

## Git 提交

| WU | Commit | 内容 |
|---|---|---|
| WU-01 | `37d373d` | harness-kit.yaml + agent.cordis.yml |
| WU-02 | `5feb5ea` | 6 个 agent system prompt |
| WU-03 | `afd8726` | 8 个 SKILL.md |

## 下一步

开始 Phase 2（L1 引擎）：WU-05/06/07 并行
- Task 6: gate-enforcer 钩子（含单测）
- Task 7: 7 个 tool schema JSON
- Task 8: flow-engine 状态机 + tier 分类（含单测）
