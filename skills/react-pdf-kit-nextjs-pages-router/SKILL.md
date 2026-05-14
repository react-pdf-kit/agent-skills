---
name: react-pdf-kit-nextjs-pages-router
description: Integrate @react-pdf-kit/viewer (>=1.0.0 <2.0.0) into a Next.js Pages Router project (pages/) with SSR-safe dynamic import via next/dynamic and ssr:false.
metadata:
  react_pdf_kit_version: ">=1.0.0 <2.0.0"
  pdfjs_dist_version: ">=5.0.0 <6.0.0"
  frameworks: [next.js, react]
  tags: [next.js, pages-router, pdf-viewer]
---

# react-pdf-kit-nextjs-pages-router

**Use this skill when**: the developer asks to add a PDF viewer using
`@react-pdf-kit/viewer` to a **Next.js project that uses the Pages
Router** (`pages/` directory). For App Router projects use
`react-pdf-kit-nextjs-app-router`. For Next.js 14 + webpack hitting
the `pdfjs-dist@5` ESM error, ALSO install
`react-pdf-kit-nextjs14-pdfjs-override` and apply that recipe first.

The Pages Router runs every page through SSR by default. The viewer
cannot run on the server (it touches `window` and `Worker`), so
mounting it requires `next/dynamic` with `ssr: false`.

## Gotchas

- **Always import the viewer with `next/dynamic` and `ssr: false`**.
  A direct import will crash during SSR with a `window is not
  defined` or similar reference error.
- **Worker URL must use `new URL(..., import.meta.url)`** so webpack
  emits the worker as a separate asset. Hardcoding `/pdf.worker.js`
  will silently fail (the file is not served from the public root by
  default).
- **Configure the worker inside `useEffect`**. Running it at module
  top-level executes during SSR and blows up because `import.meta.url`
  resolves to a server-side path.
- **`pdfjs-dist@5` is ESM-only**. Works on Next.js 13+ and on Next.js
  15. On Next.js 14 with webpack it fails with `TypeError:
  Object.defineProperty called on non-object`. Apply
  `react-pdf-kit-nextjs14-pdfjs-override` first in that case.
- **`_app.tsx` is the wrong place for the worker config**. `_app.tsx`
  runs on the server too. Put the config inside the viewer component's
  `useEffect`, never at module load.
- **`RPDefaultLayout` is deprecated** as of `@react-pdf-kit/viewer`
  v2.0.0. Use `RPLayout` for every new integration.

## Procedure

### 1. Install peer dependencies

```bash
pnpm add @react-pdf-kit/viewer pdfjs-dist@5.4.530
```

### 2. Create the viewer as a Client-Only component

```tsx
// components/PdfViewer.tsx
import { useEffect } from 'react'
import { GlobalWorkerOptions } from 'pdfjs-dist'
import {
  RPConfig,
  RPProvider,
  RPLayout,
  RPPages,
} from '@react-pdf-kit/viewer'

export default function PdfViewer({ src }: { src: string }) {
  useEffect(() => {
    GlobalWorkerOptions.workerSrc = new URL(
      'pdfjs-dist/build/pdf.worker.min.mjs',
      import.meta.url
    ).toString()
  }, [])

  return (
    <RPConfig>
      <RPProvider src={src}>
        <RPLayout>
          <RPPages />
        </RPLayout>
      </RPProvider>
    </RPConfig>
  )
}
```

Note the `default` export. `next/dynamic` works most ergonomically
with default exports.

### 3. Mount via `next/dynamic` with `ssr: false`

```tsx
// pages/document/[id].tsx
import dynamic from 'next/dynamic'
import { useRouter } from 'next/router'

const PdfViewer = dynamic(() => import('../../components/PdfViewer'), {
  ssr: false,
  loading: () => <div>Loading viewer...</div>,
})

export default function DocumentPage() {
  const router = useRouter()
  const id = router.query.id as string | undefined

  return (
    <main style={{ height: '100vh' }}>
      {id ? <PdfViewer src={`/api/documents/${id}.pdf`} /> : null}
    </main>
  )
}
```

The `id` guard avoids mounting the viewer with `undefined` on the
first client render (when the router hasn't hydrated yet).

### 4. Confirm the host has a definite height

`100vh` on the wrapper is the simplest pattern. The virtualizer
requires a measurable viewport.

## Verify

```bash
pnpm install
pnpm build       # must succeed under SSR + production build
pnpm dev         # visit /document/<id>
```

Open DevTools Network tab and confirm `pdf.worker.min.mjs` is fetched
from a webpack-emitted asset path, NOT from `/pdf.worker.js`. SSR
should produce HTML containing the loading state, then the viewer
mounts client-side after hydration.

## References

- `next/dynamic` API: <https://nextjs.org/docs/pages/api-reference/components/dynamic>
- PDF.js worker setup: <https://github.com/mozilla/pdf.js/wiki/Setup-PDF.js-in-a-website>
- Companion skills:
  - `react-pdf-kit-nextjs14-pdfjs-override`: apply this **first** if
    on Next.js 14 + webpack.
  - `react-pdf-kit-nextjs-app-router`: for App Router projects.
