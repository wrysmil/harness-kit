// client-plugin/ArtifactViewer.tsx
export function ArtifactViewer() {
  return (
    <div className="harness-artifact-viewer" style={{ padding: '16px' }}>
      <h3 style={{ color: '#fff', margin: '0 0 12px', fontSize: '14px' }}>📄 Harness Artifacts</h3>
      <p style={{ color: '#888', fontSize: '12px', margin: 0 }}>
        Artifact viewer 一等公民视图。（完整实现见 artifact-viewer.html fixture）
      </p>
    </div>
  );
}
