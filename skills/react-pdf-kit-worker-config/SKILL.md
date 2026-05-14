---
name: react-pdf-kit-worker-config
description: Configure the PDF.js worker URL across supported bundlers (Vite, Turbopack, Next.js webpack, plain webpack 5) for @react-pdf-kit/viewer (>=1.0.0 <2.0.0), with CDN-hosted and self-hosted recipes.
metadata:
  react_pdf_kit_version: ">=1.0.0 <2.0.0"
  pdfjs_dist_version: ">=5.0.0 <6.0.0"
  frameworks: [vite, next.js, webpack, react]
  tags: [pdf-viewer, pdfjs-worker, configuration]
---

# react-pdf-kit-worker-config

**Use this skill when**: the developer asks how to configure the
PDF.js worker URL — for example, behind a strict CSP that blocks
inline blob workers, hosting the worker on a CDN, working around an
asset-pipeline rewrite, or debugging a 404 on `pdf.worker.min.mjs`.

For first-time setup the framework-specific skills already include
the canonical worker config; this skill is the deeper dive.

## Gotchas

- **The worker MUST run in a Web Worker, not the main thread.** PDF.js
  has a fallback that runs everything on the main thread; do NOT
  enable it. The fallback freezes the UI on multi-page documents.
- **`new URL('pdfjs-dist/build/pdf.worker.min.mjs', import.meta.url)`
  is the default for every modern bundler.** Vite, Turbopack, and
  webpack 5 all recognize this pattern and emit the worker as a
  separate fingerprinted asset. Hardcoded paths usually fail.
- **CSP `worker-src` matters.** If you serve the app behind a CSP
  that restricts `worker-src`, you must include the origin from which
  the worker file is served. Inline `blob:` workers also require
  `worker-src 'self' blob:`.
- **CDN hosting trades local-bundling simplicity for a network round
  trip.** Pinning the CDN URL to a specific `pdfjs-dist` version is
  mandatory; serving "latest" breaks the moment PDF.js ships a
  breaking change.
- **The worker URL configuration must run BEFORE any viewer mounts.**
  Race-conditioning it (configuring it inside a `useEffect` after the
  viewer renders) results in the first render using a default that
  may not work.

## Procedure

### Default: bundler-emitted worker (recommended)

Works on Vite, Turbopack, Next.js with webpack 5, and standalone
webpack 5. This is the pattern the framework-specific skills install:

```ts
import { GlobalWorkerOptions } from 'pdfjs-dist'

GlobalWorkerOptions.workerSrc = new URL(
  'pdfjs-dist/build/pdf.worker.min.mjs',
  import.meta.url
).toString()
```

Run this at app entry (or, on Next.js, inside a `useEffect` of a
Client Component — see `react-pdf-kit-nextjs-app-router`).

### Alternative A: CDN-hosted worker

Use this when the host environment forbids serving worker files from
the app's origin (rare), or when you want to deduplicate the worker
across many independently-built apps.

```ts
import { GlobalWorkerOptions, version as pdfjsVersion } from 'pdfjs-dist'

GlobalWorkerOptions.workerSrc =
  `https://cdn.jsdelivr.net/npm/pdfjs-dist@${pdfjsVersion}/build/pdf.worker.min.mjs`
```

`pdfjsVersion` is the version installed in the host project, so the
URL stays in sync with the API the viewer is using. Pin a major in
your `package.json` so this version doesn't drift unexpectedly.

CSP requirement: include `worker-src https://cdn.jsdelivr.net;` (or
your CDN's origin).

### Alternative B: Self-host the worker file at a known path

Use this when bundling the worker is undesirable (e.g., a static-host
deployment that doesn't run a build step):

1. Copy `node_modules/pdfjs-dist/build/pdf.worker.min.mjs` into the
   public directory at deploy time:

   ```bash
   cp node_modules/pdfjs-dist/build/pdf.worker.min.mjs public/pdf.worker.min.mjs
   ```

2. Configure the URL:

   ```ts
   import { GlobalWorkerOptions } from 'pdfjs-dist'

   GlobalWorkerOptions.workerSrc = '/pdf.worker.min.mjs'
   ```

3. CSP requirement: `worker-src 'self';` is enough.

This option exists for deployments that cannot use bundler-emitted
worker URLs. Prefer the default whenever bundling is available.

## Verify

After applying any of the three options:

```bash
pnpm install
pnpm build
pnpm dev   # or your equivalent serve step
```

In the browser DevTools Network tab, filter for `pdf.worker`. You
should see exactly **one** request, status 200, with a content-type
of `application/javascript` (or `text/javascript`). Then open a PDF
in the viewer and observe text selection works on a rendered page —
this confirms the worker is responding to PDF.js's text-extraction
calls.

## References

- PDF.js worker docs: <https://github.com/mozilla/pdf.js/wiki/Setup-PDF.js-in-a-website>
- Vite worker imports: <https://vitejs.dev/guide/assets.html#new-url-url-import-meta-url>
- MDN `worker-src`: <https://developer.mozilla.org/docs/Web/HTTP/Headers/Content-Security-Policy/worker-src>
- Companion skills:
  - `react-pdf-kit-setup` — first-time setup.
  - `react-pdf-kit-vite` / `react-pdf-kit-nextjs-app-router` /
    `react-pdf-kit-nextjs-pages-router` — framework-specific worker
    setup.
