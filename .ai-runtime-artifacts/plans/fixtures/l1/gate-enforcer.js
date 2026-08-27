// gate-enforcer — tools/pre-execute 同步门卫
// v1.7 关键修正（修后端 B6）：
//   DSH 真实 API: ctx.tools.guard((exec) => string|undefined)
//   exec.name = 工具名（不是 call.tool）
//   exec.arguments = 工具参数（不是 exec.args；dsh-tools 内部 JSON 序列化后 frozen）
//   ctx.harness 在 DSH 中不存在 → 通过闭包捕获 FlowEngine 单例
//   拒绝方式：返回 denial string → dsh-tools 自动渲染为 Error: <reason>

const FLOW_ID_RE = /^[a-z0-9]([a-z0-9-]{0,62}[a-z0-9])?(\/[a-z0-9]([a-z0-9-]{0,62}[a-z0-9])?)*$/;
const FLOW_ID_TOTAL_LEN = 64;
const BLOCK_TOOLS = new Set(['write_file', 'edit_file', 'str_replace_editor', 'harness_dispatch']);

// FlowEngine 实例（setup() 时注入的闭包变量）
let _engine = null;
function setEngine(engine) { _engine = engine; }

// 单工具内联断言
function isBlockedTool(name) {
  for (const b of BLOCK_TOOLS) { if (name.includes(b)) return true; }
  return false;
}

// 门卫函数：返回 string = denial reason，或 undefined = allow
function guard(exec) {
  const args = exec.arguments || {};
  let flowId = args.flowId;            // 1. tool 自带 flowId
  if (!flowId && _engine) flowId = _engine.activeFlowId; // 2. activeFlowId fallback
  if (!flowId || !FLOW_ID_RE.test(flowId)) return undefined; // 3. 全空放行

  if (flowId.length > FLOW_ID_TOTAL_LEN) return `flowId too long (max ${FLOW_ID_TOTAL_LEN})`;

  const dirName = flowId.replace(/\//g, '__');
  const state = _engine ? _engine.getFlow(flowId) : null;
  const gate = state?.gate;
  if (!gate || !gate.locked) return undefined;

  if (!isBlockedTool(exec.name)) return undefined;

  // 返回 string → dsh-tools 自动渲染为 Error: <reason>
  return JSON.stringify({
    ok: false,
    gate: gate.id,
    reason: gate.reason || `${gate.id} locked`,
    hint: gate.hint || `unlock ${gate.id} before calling ${exec.name}; see /harness approve ${flowId}`,
    blocked_tool: exec.name,
  });
}

function toDirName(flowId) {
  if (!FLOW_ID_RE.test(flowId)) throw new Error(`invalid flowId: ${flowId}`);
  if (flowId.length > FLOW_ID_TOTAL_LEN) throw new Error(`flowId too long: ${flowId}`);
  return flowId.replace(/\//g, '__');
}

module.exports = { guard, setEngine, toDirName, FLOW_ID_RE, FLOW_ID_TOTAL_LEN, isBlockedTool };
