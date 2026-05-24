---
generated_at: 2026-05-14
generator: harness-init
---

# Project Verification — lightapp-meeting-summary

## 可用验证手段

| 验证类型 | 命令 | 状态 |
|----------|------|------|
| TypeScript 类型检查 | `tsc` | ✅ 可用 |
| ESLint | `yarn eslint` | ✅ 可用 |
| Stylelint | `yarn stylelint` | ✅ 可用 |
| Vite 构建 | `yarn build` | ✅ 可用 |
| 主进程构建 | `yarn build:processes` | ✅ 可用 |
| 子项目构建 | `yarn build:subprojects` | ✅ 可用 |
| 单元测试 | — | ❌ 未配置 |
| E2E 测试 | — | ❌ 未配置 |

## 验证策略

### 代码变更最小验证

```bash
tsc && yarn eslint src/
```

### 完整构建验证

```bash
yarn build:all
```

### 变更前检查 (pre-commit)

```bash
yarn pre-check   # tsc + lint-staged
```

## 推断项

- 【推断】项目无测试框架，验证依赖 tsc + lint + build
- 【推断】husky pre-commit hook 执行 lint-staged

## 待确认项

- 【待确认】是否有计划引入测试框架
- 【待确认】CI 流水线中是否有额外验证步骤
