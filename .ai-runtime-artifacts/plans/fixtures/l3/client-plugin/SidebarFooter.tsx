// client-plugin/SidebarFooter.tsx
export function SidebarFooter() {
  return (
    <div
      className="harness-sidebar-badge"
      style={{ display: 'flex', alignItems: 'center', gap: '8px', padding: '8px 12px', cursor: 'pointer' }}
    >
      <span style={{ width: '8px', height: '8px', borderRadius: '50%', background: '#f59e0b', display: 'inline-block' }} />
      <span style={{ fontSize: '12px', color: '#e5e5e5' }}>harness</span>
    </div>
  );
}
