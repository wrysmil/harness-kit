// client-plugin/BadgePopover.tsx
// 接 ctx.events 流（harness.gate.unlocked / harness.product.approved / harness.flow.started）
// C 形态：每个 turn 末尾浮小徽章，click → 跳到 settings.section / harness tab

export function BadgePopover(_props: { turnTail?: boolean }) {
  // 监听 ctx.events 实时更新
  // 渲染 activeFlowId + stage + gate 状态
  return (
    <div
      className="harness-badge-fab"
      onClick={() => {
        // 跳转到 settings.section 的 harness tab
        console.log('[harness] open panel — navigate to settings/harness');
      }}
      style={{
        position: 'fixed',
        right: '18px',
        top: '74px',
        display: 'flex',
        alignItems: 'center',
        gap: '6px',
        background: 'var(--dsh-bg, #1a1a1a)',
        border: '1px solid var(--dsh-border, #333)',
        borderRadius: '999px',
        padding: '4px 10px 4px 6px',
        fontSize: '12px',
        cursor: 'pointer',
        zIndex: 9999,
      }}
    >
      <span
        style={{
          width: '8px', height: '8px', borderRadius: '50%',
          background: '#f59e0b',
        }}
      />
      <span style={{ color: '#e5e5e5', fontWeight: 500 }}>harness</span>
      <span
        style={{
          fontSize: '10px', padding: '1px 6px', borderRadius: '999px',
          background: '#f59e0b', color: '#000', fontWeight: 600,
        }}
      >
        locked
      </span>
    </div>
  );
}
