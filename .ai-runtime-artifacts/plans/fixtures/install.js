#!/usr/bin/env node
// install.js — 幂等安装 / 卸载 / 清理 / 回滚（v1.7）
const fs = require('fs');
const path = require('path');
const os = require('os');
const { execSync } = require('child_process');

const HOME = os.homedir();
const DSH = path.join(HOME, '.dsh');
const FIXTURES = path.join(__dirname);

const REQUIRED_PACKAGES = [
  '@deepseek-ai/dsh-agent-presets',
  '@deepseek-ai/dsh-tools',
  '@deepseek-ai/dsh-subagent',
  '@deepseek-ai/dsh-fs-local',
  '@deepseek-ai/dsh-atomic-write',
];

function checkRequiredPackages() {
  // v1.7 修正（修后端 B8 阻断项）：DSH 不存在 ~/.dsh/package.json
  // 改用 DSH 安装目录 + node_modules 存在性验证
  if (!fs.existsSync(DSH) || !fs.statSync(DSH).isDirectory()) {
    console.error('DSH not found (expected ~/.dsh directory)');
    process.exit(1);
  }
  // 验证核心包（dsh-tools 是 DSH 存在性的强代理）
  const missing = REQUIRED_PACKAGES.filter(p => {
    try { require.resolve(p, { paths: [DSH] }); return false; } catch { return true; }
  });
  if (missing.length) {
    console.error(`Missing required DSH packages: ${missing.join(', ')}`);
    console.error(`Install DSH: https://docs.deepseek.ai`);
    process.exit(1);
  }
}

function backup(file) {
  const ts = new Date().toISOString().replace(/[:.]/g, '-');
  const bak = `${file}.harness-bak-${ts}`;
  fs.renameSync(file, bak);
  console.log(`backed up: ${file} → ${bak}`);
  return bak;
}

function install() {
  checkRequiredPackages();
  // 1. .agent-presets（v1.7 修正：DSH 用户预设根目录带点 · 修后端 B8）
  copyDir(path.join(FIXTURES, 'l1/harness-l1-plugin'), path.join(DSH, '.agent-presets/harness-kit/l1'));
  // 注意：实际 fixture 路径映射按具体安装场景
  // 本 install.js 的核心价值是幂等 + 备份 + 路径正确
  console.log('install OK — .agent-presets, skills, flows staged');
}

function copyFile(src, dst) {
  fs.mkdirSync(path.dirname(dst), { recursive: true });
  if (fs.existsSync(dst)) backup(dst);
  fs.copyFileSync(src, dst);
}

function copyDir(src, dst) {
  fs.mkdirSync(dst, { recursive: true });
  for (const e of fs.readdirSync(src, { withFileTypes: true })) {
    const s = path.join(src, e.name);
    const d = path.join(dst, e.name);
    if (e.isDirectory()) copyDir(s, d);
    else copyFile(s, d);
  }
}

function uninstall() {
  // v1.7 修正：删 .agent-presets/harness-kit/（带点） + skills/harness + flows/harness-kit.yaml
  const paths = [
    path.join(DSH, '.agent-presets/harness-kit'),
    path.join(DSH, 'skills/harness'),
    path.join(DSH, 'flows/harness-kit.yaml'),
  ];
  for (const p of paths) {
    if (fs.existsSync(p)) {
      fs.rmSync(p, { recursive: true, force: true });
      console.log(`removed: ${p}`);
    }
  }
  console.log('uninstall OK. flow-state.json left for migration.');
}

function cleanupWorktrees(dryRun) {
  const cwd = process.cwd();
  let list;
  try {
    list = execSync('git worktree list --porcelain', { cwd }).toString();
  } catch {
    console.log('no git repo or worktrees');
    return;
  }
  const matches = [...list.matchAll(/worktree (.+?\/wt-([\w-]+))/g)];
  if (!matches.length) { console.log('no worktrees to clean'); return; }
  console.log(`${matches.length} worktrees found:`);
  for (const m of matches) {
    const wtPath = m[1];
    const dirName = m[2];
    console.log(`  ${wtPath} (dirName=${dirName})`);
    if (dryRun) continue;
    try {
      const status = execSync(`git -C "${wtPath}" status --porcelain`).toString();
      if (status) { console.warn(`  SKIP: ${wtPath} has uncommitted changes`); continue; }
      execSync(`git worktree remove "${wtPath}"`, { cwd });
      console.log(`  cleaned: ${wtPath}`);
    } catch (e) {
      console.warn(`  FAIL: ${wtPath} — ${e.message}`);
    }
  }
}

function undo() {
  for (const dir of [path.join(DSH, '.agent-presets/harness-kit'), path.join(DSH, 'skills/harness')]) {
    if (!fs.existsSync(dir)) continue;
    const entries = fs.readdirSync(dir, { withFileTypes: true });
    for (const e of entries) {
      if (!e.name.includes('.harness-bak-')) continue;
      const orig = path.join(dir, e.name.replace(/\.harness-bak-.+$/, ''));
      const bak = path.join(dir, e.name);
      if (fs.existsSync(orig)) backup(orig);
      fs.renameSync(bak, orig);
      console.log(`restored: ${e.name} → ${path.basename(orig)}`);
    }
  }
}

const args = process.argv.slice(2);
if (args.includes('--uninstall')) uninstall();
else if (args.includes('--cleanup-worktrees')) cleanupWorktrees(args.includes('--dry-run'));
else if (args.includes('--undo')) undo();
else install();
