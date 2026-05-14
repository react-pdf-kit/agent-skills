// Baseline App component — intentionally has NO PDF integration.
// Skill verification works by applying a skill via
// `scripts/apply-skill-to-sample.sh` and then asserting the build is
// still green AND the PDF viewer renders. The before/after delta is
// observable from this baseline.

export function App() {
  return (
    <main style={{ fontFamily: 'system-ui', padding: 24 }}>
      <h1>Generic React baseline</h1>
      <p>
        This sample verifies the <code>react-pdf-kit-setup</code>,{' '}
        <code>react-pdf-kit-toolbar-customization</code>, and{' '}
        <code>react-pdf-kit-custom-layout</code> skills. Apply a skill via
        <code> scripts/apply-skill-to-sample.sh </code> and the PDF
        viewer will appear here after rebuild.
      </p>
    </main>
  )
}
