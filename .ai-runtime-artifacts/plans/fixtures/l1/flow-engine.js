const yaml = require('js-yaml');
const fs = require('fs');
const path = require('path');

const FLOW_ID_RE = /^[a-z0-9]([a-z0-9-]{0,62}[a-z0-9])?(\/[a-z0-9]([a-z0-9-]{0,62}[a-z0-9])?)*$/;

function toDirName(flowId) {
  if (!FLOW_ID_RE.test(flowId)) throw new Error(`invalid flowId: ${flowId}`);
  return flowId.replace(/\//g, '__');
}

class FlowEngine {
  constructor(yamlPath) {
    this.flow = yaml.load(fs.readFileSync(yamlPath, 'utf-8'));
    this.flows = new Map();   // key = toDirName(flowId)
    this.activeFlowId = null;  // v1.7 新增
  }

  inferTier(planFm) {
    if (planFm.tier) return planFm.tier;
    const wuCount = planFm.wus?.length || 1;
    const hasTest = (planFm.wus || []).some(w => w.test);
    if (wuCount === 1 && !hasTest) return 't0';
    return wuCount >= 2 && planFm.parallelize ? 't2' : 't1';
  }

  hasFlow(flowId) { return this.flows.has(toDirName(flowId)); }
  getFlow(flowId) { return this.flows.get(toDirName(flowId)); }
  listFlows() { return Array.from(this.flows.values()); }

  setStatus(flowId, status) {
    const flow = this.getFlow(flowId);
    if (!flow) throw new Error(`flow ${flowId} not found`);
    flow.status = status;
    flow.updatedAt = new Date().toISOString();
    return flow;
  }

  create(flowId, builtinFlowId, sessionRoot) {
    if (!FLOW_ID_RE.test(flowId)) throw new Error(`invalid flowId: must match ${FLOW_ID_RE}`);
    if (this.hasFlow(flowId)) throw new Error(`flow ${flowId} already exists`);

    const builtin = this.flow.builtin_flows.find(b => b.id === builtinFlowId);
    if (!builtin) throw new Error(`unknown builtin flow: ${builtinFlowId}`);

    const state = {
      flowId,
      status: 'active',
      builtinFlow: builtinFlowId,
      preset: 'harness-kit',
      stage: builtin.stages[0],
      gate: null,
      tier: this.inferTier({}),
      cwd: sessionRoot,
      worktree: null,
      artifacts: {},
      approvedBy: null,
      createdAt: new Date().toISOString(),
      updatedAt: new Date().toISOString(),
    };
    this.flows.set(toDirName(flowId), state);
    return state;
  }

  // v1.7 修正：若 gate 已存在且 unlocked，pass 而不重锁
  advance(flowId, toStage) {
    const state = this.getFlow(flowId);
    if (!state) throw new Error(`flow ${flowId} not found`);

    const gate = this.flow.flow.gates.find(g => g.before === toStage);
    if (!gate) {
      state.stage = toStage;
      state.gate = null;
      state.updatedAt = new Date().toISOString();
      return { ok: true, stage: toStage };
    }

    if (state.gate && state.gate.id === gate.id && state.gate.locked === false) {
      state.stage = toStage;
      state.gate = null;
      state.updatedAt = new Date().toISOString();
      return { ok: true, stage: toStage };
    }

    state.gate = { id: gate.id, locked: true, reason: 'check needed', hint: `unlock ${gate.id} before advancing to ${toStage}` };
    return { ok: false, gate: gate.id, reason: 'fixture: real check delegates to harness_advance handler', hint: state.gate.hint };
  }

  // v1.7 修正：approve 清 lock 但保留 gate 记录
  approve(flowId, kind) {
    const state = this.getFlow(flowId);
    if (!state) throw new Error(`flow ${flowId} not found`);
    state.approvedBy = 'user';
    if (state.gate) state.gate = { ...state.gate, locked: false, reason: null, hint: null };
    state.updatedAt = new Date().toISOString();
    return { ok: true, approvedBy: 'user' };
  }

  setActiveFlow(flowId) {
    if (flowId && !this.hasFlow(flowId)) throw new Error(`flow ${flowId} not found`);
    this.activeFlowId = flowId || null;
  }

  getActiveFlowId() { return this.activeFlowId; }

  save(sessionId, stateFilePath) {
    const data = {
      schemaVersion: 1,
      presetVersion: this.flow.flow.version || 1,
      sessionId,
      activeFlowId: this.activeFlowId,
      flows: Object.fromEntries(this.flows),
    };
    fs.writeFileSync(stateFilePath, JSON.stringify(data, null, 2));
  }

  load(stateFilePath, sessionId) {
    if (!fs.existsSync(stateFilePath)) return null;
    try {
      const data = JSON.parse(fs.readFileSync(stateFilePath, 'utf-8'));
      if (!data.schemaVersion) data.schemaVersion = 1;
      const currentPresetVersion = this.flow.flow.version || 1;
      if (data.presetVersion < currentPresetVersion) {
        for (const [, flow] of Object.entries(data.flows)) {
          if (!this.flow.stages.find(s => s.id === flow.stage)) flow.status = 'paused_waiting_user';
        }
      }
      for (const [key, flow] of Object.entries(data.flows)) {
        if (toDirName(flow.flowId) !== key || !FLOW_ID_RE.test(flow.flowId)) delete data.flows[key];
      }
      this.flows = new Map(Object.entries(data.flows));
      this.activeFlowId = (data.activeFlowId && this.hasFlow(data.activeFlowId)) ? data.activeFlowId : null;
      return data;
    } catch (e) {
      return null;
    }
  }
}

module.exports = { FlowEngine, toDirName, FLOW_ID_RE };
