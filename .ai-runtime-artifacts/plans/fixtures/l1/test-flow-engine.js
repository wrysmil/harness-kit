const { FlowEngine, toDirName, FLOW_ID_RE } = require('./flow-engine');
const fs = require('fs');
const path = require('path');

let pass = 0, fail = 0;
function check(label, cond) { cond ? pass++ : fail++; console.log(`${cond?'✓':'✗'} ${label}`); }

// 1. FLOW_ID_RE 白名单
const idCases = [
  ['feat/rate-limiter', true], ['bug/login-500', true], ['hotfix/redis-down', true], ['a/b', true],
  ['../../etc/passwd', false], ['feat\\x', false], ['/abs', false], ['', false],
  ['feat//slash', false], ['feat/UPPER', false], ['feat/.dot', false], ['feat/a.b', false],
  ['_feat/x', false], ['feat/_x', false], ['feat/x_', false],
  ['feat__x/y', false],
  ['a'.repeat(65) + '/x', false],
];
for (const [id, ok] of idCases) {
  let threw = false;
  try { toDirName(id); } catch { threw = true; }
  check(`FLOW_ID_RE ${JSON.stringify(id)} → ${ok}`, threw === !ok);
}
check('toDirName 合法 → feat__rate-limiter', toDirName('feat/rate-limiter') === 'feat__rate-limiter');

// 2. tier 推断
const e = new FlowEngine(path.join('.ai-runtime-artifacts/plans/fixtures/harness-kit.yaml'));
check('infer t0', e.inferTier({ wus: [{ name: 'x' }] }) === 't0');
check('infer t1', e.inferTier({ wus: [{ name: 'x' }, { name: 'y' }] }) === 't1');
check('infer t2 (parallelize)', e.inferTier({ wus: [{ name: 'x' }, { name: 'y' }, { name: 'z' }], parallelize: true }) === 't2');
check('infer t1 if parallelize=false', e.inferTier({ wus: [{ name: 'x' }, { name: 'y' }, { name: 'z' }], parallelize: false }) === 't1');
check('explicit tier wins', e.inferTier({ tier: 't2', wus: [{ name: 'x' }] }) === 't2');

// 3. create flow（含 status 字段）
const state = e.create('feat/rate-limiter', 'feat', '/Users/x/proj');
check('create sets initial stage = clarify', state.stage === 'clarify');
check('create sets status = active', state.status === 'active');
check('create sets builtinFlow = feat', state.builtinFlow === 'feat');
check('create sets cwd = session root', state.cwd === '/Users/x/proj');
check('create sets gate = null', state.gate === null);

// 4. createFlow 重复 → 抛错
let threwDup = false;
try { e.create('feat/rate-limiter', 'feat', '/'); } catch { threwDup = true; }
check('create duplicate throws', threwDup);

// 5. createFlow flowId 非法 → 抛错
let threwInvalid = false;
try { e.create('../../etc/passwd', 'feat', '/'); } catch { threwInvalid = true; }
check('create invalid flowId throws', threwInvalid);

// 6. 多 flow 并存
const state2 = e.create('bug/login-500', 'bug', '/Users/x/proj');
check('multi-flow list count = 2', e.listFlows().length === 2);
check('multi-flow dirName key', e.hasFlow('feat/rate-limiter') && e.hasFlow('bug/login-500'));

// 7. advance 真实校验接口
const r1 = e.advance('feat/rate-limiter', 'plan');
check('advance to plan → gate check', r1.ok === false);
check('advance returns gate id', r1.gate === 'spec-approved');
check('advance returns hint', r1.hint && r1.hint.includes('spec-approved'));

// 8. approve 清 gate（v1.7：保留 gate 记录但 locked:false）
const r2 = e.approve('feat/rate-limiter', 'plan');
check('approve returns ok', r2.ok === true);
check('approve sets approvedBy', e.getFlow('feat/rate-limiter').approvedBy === 'user');
check('approve keeps gate record', e.getFlow('feat/rate-limiter').gate !== null);
check('approve unlocks gate.locked', e.getFlow('feat/rate-limiter').gate.locked === false);

// 9. setStatus
const r3 = e.setStatus('feat/rate-limiter', 'aborted');
check('setStatus aborted', r3.status === 'aborted');

// 10. save → load roundtrip
const tmp = '.ai-runtime-artifacts/plans/fixtures/l1/_tmp-state.json';
e.setStatus('feat/rate-limiter', 'active');
e.save('s-8f3a', tmp);
const e2 = new FlowEngine(path.join('.ai-runtime-artifacts/plans/fixtures/harness-kit.yaml'));
const loaded = e2.load(tmp, 's-8f3a');
check('load() returns schemaVersion=1', loaded.schemaVersion === 1);
check('load() flow count = 2', Object.keys(loaded.flows).length === 2);
check('load() flowId preserved', loaded.flows['feat__rate-limiter'].flowId === 'feat/rate-limiter');
check('load() status preserved', loaded.flows['feat__rate-limiter'].status === 'active');

// 11. load() 损坏文件 → null
fs.writeFileSync(tmp, '{ corrupted json');
const broken = e2.load(tmp, 's-8f3a');
check('load() corrupted file returns null', broken === null);

// 12. load() 不存在文件 → null
fs.unlinkSync(tmp);
const missing = e2.load(tmp, 's-8f3a');
check('load() missing file returns null', missing === null);

console.log(`\n${pass} pass · ${fail} fail`);
process.exit(fail > 0 ? 1 : 0);
