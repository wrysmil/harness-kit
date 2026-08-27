// 单测用 mock exec 对象（dsh-tools 真实传入的 exec 结构）
const { guard, setEngine, toDirName, FLOW_ID_RE, isBlockedTool } = require('./gate-enforcer');

// mock FlowEngine：提供 activeFlowId + getFlow()
class MockEngine {
  constructor() { this._flows = new Map(); this.activeFlowId = null; }
  getFlow(flowId) { return this._flows.get(toDirName(flowId)) || null; }
  addFlow(flowId, gate) { this._flows.set(toDirName(flowId), { gate }); }
}

let pass = 0, fail = 0;
function check(label, cond) { cond ? pass++ : fail++; console.log(`${cond?'✓':'✗'} ${label}`); }

const engine = new MockEngine();
setEngine(engine);

// === FLOW_ID_RE 自校验（v1.7 统一版：禁段内 __ / 不以 _/- 开头 / 总长 ≤64）===
const idCases = [
  ['feat/rate-limiter', true], ['bug/login-500', true], ['hotfix/redis-down', true],
  ['../../etc/passwd', false], ['feat\\x', false], ['/abs', false], ['', false],
  ['feat//slash', false], ['feat/UPPER', false],
  ['_feat/x', false], ['feat/_x', false], ['feat/x_', false],
  ['feat__x/y', false],
  ['a'.repeat(65) + '/x', false],
];
for (const [id, ok] of idCases) {
  check(`FLOW_ID_RE ${JSON.stringify(id).slice(0,35)} → ${ok}`, FLOW_ID_RE.test(id) === ok);
}

// === 场景矩阵 4×3×4 = 48 case ===
const gates = [
  { id: 'spec-approved',  locked: true,  reason: 'spec missing',  hint: 'create specs/*.md' },
  { id: 'plan-approved',  locked: true,  reason: 'plan missing',  hint: 'create plans/*.md' },
  { id: 'verify-passed',  locked: true,  reason: 'verify failed', hint: 're-run tests' },
  { id: 'refs-checked',   locked: true,  reason: 'refs failed',  hint: 'run /harness check' },
];
const states = [true, false, undefined];
const tools = ['read_file', 'write_file', 'edit_file', 'harness_dispatch'];
const expectedBlock = { read_file: false, write_file: true, edit_file: true, harness_dispatch: true };

for (const gate of gates) {
  for (const locked of states) {
    for (const tool of tools) {
      engine._flows.clear();
      engine.activeFlowId = null;
      const g = locked === undefined ? null : { ...gate, locked };
      if (g) engine.addFlow('feat/x', g);
      const result = guard({ name: tool, arguments: { flowId: 'feat/x' } });
      const expectDeny = locked === true && expectedBlock[tool];
      const ok = expectDeny
        ? (typeof result === 'string' && JSON.parse(result).ok === false)
        : result === undefined;
      check(`[${gate.id}] locked=${locked} ${tool} → ${expectDeny?'deny':'allow'}`, ok);
    }
  }
}

// === 原生工具 activeFlowId fallback 4 case（修后端 P2 · v1.7）===
engine._flows.clear();
engine.addFlow('feat/x', { id: 'plan-approved', locked: true, reason: 'plan missing' });
engine.activeFlowId = 'feat/x';
check('A: native write_file + activeFlowId locked → deny', typeof guard({ name: 'write_file', arguments: {} }) === 'string');

engine._flows.clear();
engine.addFlow('feat/x', { id: 'plan-approved', locked: false });
engine.activeFlowId = 'feat/x';
check('B: native write_file + activeFlowId unlocked → allow', guard({ name: 'write_file', arguments: {} }) === undefined);

engine._flows.clear();
engine.activeFlowId = null;
check('C: native write_file + no flowId → allow (fallback)', guard({ name: 'write_file', arguments: {} }) === undefined);

engine._flows.clear();
engine.addFlow('feat/x', { id: 'plan-approved', locked: true, reason: 'plan missing' });
engine.addFlow('bug/y', { id: null, locked: false });
engine.activeFlowId = 'bug/y';
check('D: tool flowId wins over activeFlowId', typeof guard({ name: 'write_file', arguments: { flowId: 'feat/x' } }) === 'string');

console.log(`\n${pass} pass · ${fail} fail`);
process.exit(fail > 0 ? 1 : 0);
