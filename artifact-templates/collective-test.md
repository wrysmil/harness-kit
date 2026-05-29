---
artifact: verification
route: cursor-orchestration:dispatcher-workflow -> batch-closeout
skills:
  - verification-before-completion
skills_evidence:
  - adapters/cursor/.cursor/skills/verification-before-completion/SKILL.md
source:
  - harness-kit/project.verification.md
  - harness-kit/docs/superpowers/specs/2026-05-28-batch-closeout-review-and-collective-test.md
created_at: <YYYY-MM-DD>
batch_id: GROUP-1
worktree_id: 
worktree_path: 
verdict: PASS
---

# <Topic> 集体测试

> **纪律：** 先 Load **verification-before-completion**；**先跑命令、再给结论**（禁止「应该通过」）。  
> **写入者：** Leader。WU 内 Coder 单测摘要可引用，**不能替代**本表命令的本机重跑。

## 变更范围

- 本批次触及模块/目录：

## WU 已覆盖项（引用，非替代）

| WU | 命令/结论摘要 |
| --- | --- |
| WU-01 | |

## 命令表

| 命令 | cwd | exit | 关键输出摘要 |
| --- | --- | --- | --- |
| | | 0 | |

## 集成 / E2E

- 无 | Test Engineer WU-id + 摘要：

## 未验证项

- 无 |

## 残留风险

- 无 |

## 结论

**verdict:** PASS | FAIL

## Next

- PASS → 进入集体代码审查（`artifact-templates/code-review.md`）
- FAIL → 开 bugfix WU；不得进入审查或声称批次完成
