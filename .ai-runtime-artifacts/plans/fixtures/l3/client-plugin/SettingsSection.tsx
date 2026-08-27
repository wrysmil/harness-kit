// client-plugin/SettingsSection.tsx
export function SettingsSection() {
  return (
    <div className="harness-settings" style={{ padding: '16px' }}>
      <h3 style={{ color: '#fff', margin: '0 0 12px', fontSize: '14px' }}>⚙ Harness 资产管理</h3>
      <p style={{ color: '#888', fontSize: '12px', margin: 0 }}>
        Harness flow 管理面板。（完整实现见 settings.html fixture）
      </p>
    </div>
  );
}
