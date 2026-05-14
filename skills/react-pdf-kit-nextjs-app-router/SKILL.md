---
name: react-pdf-kit-nextjs-app-router
description: Integrate @react-pdf-kit/viewer (>=1.0.0 <2.0.0) into a Next.js 13+ App Router project, including the 'use client' boundary, dynamic import, and PDF.js worker URL via new URL(...) for both Turbopack and webpack.
metadata:
  react_pdf_kit_version: ">=1.0.0 <2.0.0"
  pdfjs_dist_version: ">=5.0.0 <6.0.0"
  frameworks: [next.js, react]
  tags: [next.js, app-router, pdf-viewer, turbopack]
---

# react-pdf-kit-nextjs-app-router

**Use this skill when**: the developer asks to add a PDF viewer using
`@react-pdf-kit/viewer` to a **Next.js project that uses the App
Router** (`app/` directory). For Pages Router projects use
`react-pdf-kit-nextjs-pages-router`. For Next.js 14 + webpack hitting
the `pdfjs-dist@5` ESM error, ALSO install
`react-pdf-kit-nextjs14-pdfjs-override` and apply that recipe first.

The viewer touches the `window` and `Worker` globals — it cannot run
on the server. The skill structures the integration around that
constraint.

## Gotchas

- **Server Components cannot import the viewer**. The viewer mounts
  PDF.js, which is browser-only. Always render the viewer from a
  Client Component (`'use client'`) AND import it dynamically with
  `next/dynamic` and `ssr: false` from a Server Component if you want
  to keep the route a Server Component overall.
- **Worker URL must use `new URL(..., import.meta.url)`**. Both
  Turbopack and webpack 5 emit the worker as a separate asset when
  given that pattern. Do NOT hardcode `/pdf.worker.js` — Next will
  not place the file there, and the viewer will silently render
  blank.
- **`pdfjs-dist@5` is ESM-only**. This works on Next.js 13+ with
  Turbopack out of the box, and on Next.js 15 with webpack. On
  Next.js 14 with webpack it fails with `TypeError:
  Object.defineProperty called on non-object` — use
  `react-pdf-kit-nextjs14-pdfjs-override` to downgrade `pdfjs-dist` to
  v4.
- **Hydration**: render the viewer inside a fixed-height container so
  layout doesn't shift on hydration. Without a definite height, the
  virtualizer can mount with 0 rows and never recover.
- **Fonts**: PDF.js fetches its `cmaps/` and `standard_fonts/` from
  the worker. With Turbopack/webpack defaults this works; if you
  customize asset routing, also serve `node_modules/pdfjs-dist/cmaps/`
  and `node_modules/pdfjs-dist/standard_fonts/` from a stable public
  path or expect missing-glyph rendering for non-Latin PDFs.

## Procedure

### 1. Install peer dependencies

```bash
pnpm add @react-pdf-kit/viewer pdfjs-dist@5.4.530
```

### 2. Create the viewer as a Client Component

```tsx
// app/_components/PdfViewer.tsx
'use client'

import { useEffect } from 'react'
import { GlobalWorkerOptions } from 'pdfjs-dist'
import {
  RPConfig,
  RPProvider,
  RPTheme,
  RPDefaultLayout,
  RPPages,
} from '@react-pdf-kit/viewer'

export function PdfViewer({ src }: { src: string }) {
  useEffect(() => {
    GlobalWorkerOptions.workerSrc = new URL(
      'pdfjs-dist/build/pdf.worker.min.mjs',
      import.meta.url
    ).toString()
  }, [])

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

The worker URL configuration runs once in `useEffect` so it executes
client-side only. Configuring it at module top-level also works under
Turbopack but throws under webpack SSR — `useEffect` is the safe
default.

### 3. Mount via dynamic import from a Server Component (if applicable)

If the page hosting the viewer is a Server Component (the default in
the App Router), wrap the import:

```tsx
// app/document/[id]/page.tsx
import dynamic from 'next/dynamic'

const PdfViewer = dynamic(
  () => import('../../_components/PdfViewer').then(m => m.PdfViewer),
  { ssr: false, loading: () => <div>Loading viewer…</div> }
)

export default function DocumentPage({ params }: { params: { id: string } }) {
  return (
    <main style={{ height: '100vh' }}>
      <PdfViewer src={`/api/documents/${params.id}.pdf`} />
    </main>
  )
}
```

If the page is already a Client Component (`'use client'` at the top),
import `PdfViewer` directly without `dynamic` — the lazy/SSR-disable
dance is unnecessary.

### 4. Confirm the host has a definite height

The viewer's virtualizer requires a measurable viewport. Wrap it in a
`height: 100vh` (or fixed-height) container, OR put it in a flex/grid
ancestor with `min-height` set.

## Verify

```bash
pnpm install
pnpm build         # must succeed under both turbopack-dev and the next build (webpack/webpack-like) path
pnpm dev           # then visit /document/<id>
```

Open the page. The first PDF page should render with the default
toolbar. Open DevTools Network tab — confirm `pdf.worker.min.mjs` is
fetched from a `_next/static/...` path (Turbopack) or a chunked asset
URL (webpack), NOT from a 404'd `/pdf.worker.js`.

## References

- Next.js dynamic import: <https://nextjs.org/docs/app/api-reference/functions/dynamic>
- PDF.js worker setup: <https://github.com/mozilla/pdf.js/wiki/Setup-PDF.js-in-a-website>
- Companion skills:
  - `react-pdf-kit-nextjs14-pdfjs-override` — apply this **first** if
    on Next.js 14 + webpack.
  - `react-pdf-kit-worker-config` — for advanced worker URL strategies
    (CDN-hosted worker, locked-down CSP, etc.).
