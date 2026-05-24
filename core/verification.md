# Verification Gates

## 通用门禁

完成声明前必须至少说明：

- 执行过的验证命令。
- 命令是否通过。
- 未验证项和原因。
- 是否存在残留风险。

## Harness 文档验证

```bash
rg -n "T[B]D|T[O]DO|FIX[M]E|待[定]|占[位]" AGENTS.md CLAUDE.md GEMINI.md .cursor .agents cow-harness .ai-runtime-artifacts
bash -n cow-harness/scripts/install-ai-skills.sh
bash -n cow-harness/scripts/harness-init.sh
bash -n cow-harness/scripts/harness-check.sh
node -e "JSON.parse(require('fs').readFileSync('package.json','utf8')); console.log('package-json-ok')"
git status --short
```

## AI 环境验证

```bash
yarn ai:install-skills
omx doctor
```

如果这些命令涉及全局安装或本机环境修改，执行前要明确说明影响；不能执行时，至少运行静态检查并说明原因。

## 应用验证

根据改动范围选择：

```bash
yarn build
yarn build:processes
yarn build:screenUpload
yarn build:controlProcess
yarn build:all
```

如果只改 Harness 文档和规则，不要求运行应用构建。
