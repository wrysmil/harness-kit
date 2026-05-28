---
name: log-summarizer
description: Summarize noisy logs into actionable findings (errors, causes, next steps)
---

# Log Summarizer

## Overview

Large logs hide the signal. This skill turns raw terminal output, CI logs, or app logs into a short, accurate incident-style summary you can act on.

## When to Use

Use when you have:
- CI build/test output (GitHub Actions, Bazel, Gradle, etc.)
- Application logs (backend, frontend, mobile)
- CLI tool output (linters, compilers, infra tools)
- Any long error stream where the root failure is unclear

## Triggers

Invoke this skill when the user says things like:
- "Summarize these logs"
- "What failed and why?"
- "Find the real error in this output"
- "Extract the actionable errors"
- "Give me next steps"

## Inputs Required

Provide:
- The full log snippet (or the relevant section around the failure)
- What command/workflow produced it (if known)
- What "success" means (tests pass, build succeeds, request completes)

## Output Format

Produce exactly:

1. **Primary failure**: the single most important error (verbatim line(s) quoted)
2. **Context**: preceding warnings or secondary errors that are causally linked
3. **Likely root cause**: best hypothesis grounded in evidence from the log
4. **Next steps (ordered)**: 3-7 concrete actions to confirm/fix, including the exact commands to run when possible
5. **If blocked**: what additional log lines / environment details to request

## Constraints

- Do not invent errors or commands that are not supported by the log.
- Prefer quoting the exact lines that prove your claim.
- If multiple failures exist, pick the earliest causal failure and mark the rest as downstream noise.
