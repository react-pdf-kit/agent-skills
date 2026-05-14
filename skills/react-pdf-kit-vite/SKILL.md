---
name: react-pdf-kit-vite
description: Integrate @react-pdf-kit/viewer (>=1.0.0 <2.0.0) into a Vite 5 project, including the PDF.js worker import via new URL(...) and ESM-aware vite.config.ts.
metadata:
  react_pdf_kit_version: ">=1.0.0 <2.0.0"
  pdfjs_dist_version: ">=5.0.0 <6.0.0"
  frameworks: [vite, react]
  tags: [vite, pdf-viewer, esm, worker]
---

# react-pdf-kit-vite

**Use this skill when**: the developer asks to add a PDF viewer using
`@react-pdf-kit/viewer` to a **Vite-based React project**. For Next.js
use the framework-specific skills. For generic React projects without
Vite-specific worker setup, the `react-pdf-kit-setup` skill is enough.

Vite handles `pdfjs-dist@5` ESM-only out of the box. The only Vite
specifics are the worker URL and (optionally) a tweak to
`optimizeDeps` if the dev server pre-bundles `pdfjs-dist` slowly.

## Gotchas

- **Use `new URL(..., import.meta.url)` for the worker URL** — Vite
  recognizes this pattern and emits the worker file as a fingerprinted
  asset both in dev and production. Hardcoding `/pdf.worker.js`
  silently fails because Vite does not serve `node_modules/` assets at
  the root.
- **Do not put `pdfjs-dist` under `optimizeDeps.exclude`** unless you
  see real cold-start issues. Excluding it forces the browser to
  resolve all PDF.js submodule imports per request, which is slower.
- **Set worker config at app entry**, not inside the viewer
  component, so the worker is initialized exactly once and before any
  viewer mounts. Vite's HMR otherwise can re-run the configuration on
  every file change, which is harmless but noisy.
- **CSS injection**: the library's PostCSS plugin auto-injects styles
  via Vite's standard CSS pipeline. Do NOT also import a separate
  stylesheet — you'll get duplicates.

## Procedure

### 1. Install peer dependencies

```bash
pnpm add @react-pdf-kit/viewer pdfjs-dist@5.4.530
```

### 2. Configure the PDF.js worker once at entry

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
import './pdfjs-worker'
import { StrictMode } from 'react'
import { createRoot } from 'react-dom/client'
import { App } from './App'

createRoot(document.getElementById('root')!).render(
  <StrictMode><App /></StrictMode>
)
```

The `import './pdfjs-worker'` is a side-effect import; the order
matters — it must come before any `App` import that mounts the viewer.

### 3. Render the viewer

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

### 4. (Optional) `vite.config.ts` tweak for PDF.js cold-start

The default Vite config works. Only add this if dev-server cold-start
is slow because Vite's pre-bundler is choking on `pdfjs-dist`'s many
submodules:

```ts
// vite.config.ts
import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'

export default defineConfig({
  plugins: [react()],
  optimizeDeps: {
    include: ['pdfjs-dist', 'pdfjs-dist/build/pdf.worker.min.mjs'],
  },
})
```

This pre-bundles `pdfjs-dist` once at startup instead of lazily, at
the cost of a slower first dev-server boot. Most projects don't need
this.

## Verify

```bash
pnpm install
pnpm build
pnpm dev
```

Open the dev server URL. The first PDF page should render with the
default toolbar. Open DevTools Network tab — confirm
`pdf.worker.min.mjs` is fetched from a Vite-emitted, fingerprinted
asset URL (the path begins with `/assets/` and ends in `.mjs` with a
hash segment in between). Test text selection on a rendered page to
confirm the text layer mounted.

## References

- Vite worker imports: <https://vitejs.dev/guide/assets.html#new-url-url-import-meta-url>
- PDF.js worker setup: <https://github.com/mozilla/pdf.js/wiki/Setup-PDF.js-in-a-website>
- Companion skills:
  - `react-pdf-kit-setup` — generic React fundamentals.
  - `react-pdf-kit-worker-config` — for advanced worker URL
    strategies (CDN-hosted worker, locked-down CSP, etc.).
