---
name: react-pdf-kit-setup
description: Set up @react-pdf-kit/viewer in a generic React app (>=1.0.0 <2.0.0) including PDF.js worker configuration and the canonical RPConfig→RPProvider→RPTheme→RPDefaultLayout→RPPages provider chain.
metadata:
  react_pdf_kit_version: ">=1.0.0 <2.0.0"
  pdfjs_dist_version: ">=5.0.0 <6.0.0"
  frameworks: [react]
  tags: [setup, pdf-viewer, getting-started]
---

# react-pdf-kit-setup

**Use this skill when**: the developer asks to add a PDF viewer using
`@react-pdf-kit/viewer` to a React project, AND the project is *not*
specifically Next.js or Vite (use the framework-specific skills for
those — they cover bundler details this skill does not).

`@react-pdf-kit/viewer` builds on PDF.js and renders PDFs through a
nested provider chain. Treat the chain as the canonical composition
model — everything else (theming, layout, hooks) layers onto it.

## Gotchas

- **`pdfjs-dist` is a peer dependency**, not bundled. The host project
  MUST install it explicitly. Default supported version: `5.4.530`.
- **`pdfjs-dist@5` is ESM-only**. Modern bundlers handle it; legacy
  CommonJS-only environments do not. If the host is Next.js 14 with
  webpack, use `react-pdf-kit-nextjs14-pdfjs-override` instead — do
  NOT pin `pdfjs-dist@5` there.
- **The PDF.js worker MUST run in a Web Worker**, not on the main
  thread. The standard pattern below uses `new URL(...,
  import.meta.url)` so the bundler emits the worker as a separate
  asset.
- **CSS is auto-injected** by the library's PostCSS plugin; do NOT
  import a separate stylesheet unless customizing themes via
  `RPTheme`.
- **`react`, `react-dom`, and `pdfjs-dist` are peer dependencies**.
  They are NOT bundled. Do not duplicate them in your bundle.

## Procedure

### 1. Install peer dependencies

```bash
pnpm add @react-pdf-kit/viewer pdfjs-dist@5.4.530
```

(Use `npm install`, `yarn add`, or `bun add` if not on pnpm.)

### 2. Configure the PDF.js worker once at app boot

Pick the file your app boots from (e.g., `src/main.tsx`, `src/index.tsx`,
or whichever entry your bundler runs first). Add the worker URL
configuration before any viewer renders:

```tsx
// src/pdfjs-worker.ts
import { GlobalWorkerOptions } from 'pdfjs-dist'

GlobalWorkerOptions.workerSrc = new URL(
  'pdfjs-dist/build/pdf.worker.min.mjs',
  import.meta.url
).toString()
```

```tsx
// src/main.tsx
import './pdfjs-worker'   // side-effect import; must come before viewer use
import { StrictMode } from 'react'
import { createRoot } from 'react-dom/client'
import { App } from './App'

createRoot(document.getElementById('root')!).render(
  <StrictMode><App /></StrictMode>
)
```

### 3. Render the viewer with the canonical provider chain

```tsx
// src/PdfViewer.tsx
import {
  RPConfig,
  RPProvider,
  RPTheme,
  RPDefaultLayout,
  RPPages,
} from '@react-pdf-kit/viewer'

export function PdfViewer({ src }: { src: string }) {
  return (
    <RPConfig>
      <RPProvider src={src}>
        <RPTheme>
          <RPDefaultLayout>
            <RPPages />
          </RPDefaultLayout>
        </RPTheme>
      </RPProvider>
    </RPConfig>
  )
}
```

`RPTheme` is optional but harmless; include it so the viewer uses the
default light/dark theme variables.

### 4. Mount it

```tsx
// src/App.tsx
import { PdfViewer } from './PdfViewer'

export function App() {
  return (
    <main style={{ height: '100vh' }}>
      <PdfViewer src="/sample.pdf" />
    </main>
  )
}
```

The viewer requires a definite height to render correctly — give the
parent a fixed or `100vh` height so virtual scrolling has a viewport
to work against.

## Verify

```bash
pnpm install
pnpm build
pnpm dev
```

Open the dev server URL. The first PDF page should render with the
default toolbar visible. Scroll down — additional pages mount as you
scroll (virtualization at work). Selecting text should produce a real
text selection (not a canvas-only image).

## References

- Library README: <https://github.com/react-pdf-kit/viewer>
- PDF.js worker docs: <https://github.com/mozilla/pdf.js/wiki/Setup-PDF.js-in-a-website>
- Companion skills:
  - `react-pdf-kit-nextjs-app-router` — for Next.js App Router projects.
  - `react-pdf-kit-vite` — for Vite-specific worker integration.
  - `react-pdf-kit-worker-config` — for cross-bundler worker URL details.
