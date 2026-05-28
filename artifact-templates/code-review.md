---
artifact: review
route: cursor-orchestration:dispatcher-workflow -> batch-closeout
skills:
  - requesting-code-review
  - cursor-orchestration
skills_evidence:
  - adapters/cursor/.cursor/skills/requesting-code-review/SKILL.md
  - .agents/skills/cursor-orchestration/SKILL.md
source:
  - .ai-runtime-artifacts/plans/<YYYY-MM-DD>-<topic>-plan.md
  - harness-kit/docs/superpowers/specs/2026-05-28-batch-closeout-review-and-collective-test.md
created_at: <YYYY-MM-DD>
batch_id: GROUP-1
reviewer_instance: harness-reviewer
verdict: APPROVE
---

# <Topic> 集体代码审查

> **写入者：** Leader（收到 `harness-reviewer` 返回后落盘）。Reviewer 为 readonly，不 Write 本文件。

## 审查范围

- 文件列表或 `git diff <BASE>..<HEAD>` 摘要：
- BASE_SHA / HEAD_SHA：

## 对照依据

- spec：
- plan：
- done criteria 勾选：

## Findings

### Critical

- 无 |

### Important

- 无 |

### Suggestion

- 无 |

### Nit

- 无 |

## 证据

- Reviewer 已读/已跑：

## 未验证项

- 无 |

## 结论

**verdict:** APPROVE | BLOCK | SKIPPED

（若 SKIPPED：写明 `docs/superpowers/specs/2026-05-26-coder-role-design.md` § 小 WU 跳过 Reviewer 全条件 + 各 WU `skip_reviewer_eligible`）

## Next

- APPROVE → 可合并/提测；更新 execution-log
- BLOCK → 开 `review-fix` WU，修复后重跑集体测试（步骤 A）再审查
- SKIPPED → 记录跳过依据；仍须 collective-test PASS
