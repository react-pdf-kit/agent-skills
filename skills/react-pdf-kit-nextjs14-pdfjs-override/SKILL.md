---
name: react-pdf-kit-nextjs14-pdfjs-override
description: Override pdfjs-dist to v4 to work around the Next.js 14 + pdfjs-dist v5 webpack ESM interop bug (TypeError Object.defineProperty called on non-object) so @react-pdf-kit/viewer (>=1.0.0 <2.0.0) builds and runs.
metadata:
  react_pdf_kit_version: ">=1.0.0 <2.0.0"
  pdfjs_dist_version: ">=4.0.0 <5.0.0"
  frameworks: [next.js, webpack]
  tags: [next.js, pdfjs, esm, override, troubleshooting]
---

# react-pdf-kit-nextjs14-pdfjs-override

**Use this skill when**: a Next.js 14 build (or runtime) fails with

```
TypeError: Object.defineProperty called on non-object
```

(or any module-load error originating from `pdfjs-dist@5`'s ESM
import chain) AND the project uses Next.js 14 with the default
webpack bundler. Apply this skill BEFORE the framework-specific
Next.js skills.

For Next.js 13, Next.js 15, or Next.js 14 with Turbopack: this skill
is NOT needed; use `react-pdf-kit-nextjs-app-router` or
`react-pdf-kit-nextjs-pages-router` directly with `pdfjs-dist@5`.

## Why this exists

`pdfjs-dist` v5 is ESM-only. Next.js 14's webpack 5 build pipeline
has a known ESM interop bug
([wojtekmaj/react-pdf#1699](https://github.com/wojtekmaj/react-pdf/issues/1699))
that throws on the import path PDF.js takes when initializing its
worker. The bug is fixed in Next.js 15 (and avoided entirely under
Turbopack), but Next.js 14 + webpack remains broken.

The workaround is to pin `pdfjs-dist` to v4, which still ships both
ESM and CommonJS. Webpack 5 picks the CommonJS build and the import
chain succeeds. `@react-pdf-kit/viewer` declares its `pdfjs-dist`
peer range to include both v4 and v5, so the v4 pin is supported.

Keep this override in place until the project upgrades off Next.js 14.

## Gotchas

- **The override must be set in EVERY package-manager format** the
  project might use (or might be cloned with). pnpm, npm 8+, and
  yarn each read a different field. Setting only `pnpm.overrides`
  silently breaks contributors using `npm install`.
- **Re-install after editing `package.json`.** Overrides apply at
  install time, not at build time; the existing `node_modules/` will
  still have v5 until you re-install.
- **Delete `node_modules/` and the lockfile** if a previous v5
  install left behind hoisted state. Most package managers warn but
  some silently retain the old resolution.
- **The override only fixes the build error.** The viewer's runtime
  behavior is otherwise identical between `pdfjs-dist` v4 and v5 for
  React PDF Kit's purposes; no API change is required in the
  application code.
- **Document the override in the host project's README** so future
  maintainers know why `pdfjs-dist` is pinned to a major version
  behind the React PDF Kit default.

## Procedure

### 1. Confirm you're hitting the bug

Open the failing build log. If you see:

```
TypeError: Object.defineProperty called on non-object
    at <anonymous>
    at .../pdfjs-dist/build/pdf.mjs:...
```

(or a similar stack rooted in `pdfjs-dist/build/pdf.mjs`), AND the
project's `next` version starts with `14.`, AND the project does NOT
have `experimental.turbo` or `--turbo` enabled. This is the bug this
skill addresses.

### 2. Add the package-manager overrides

Edit `package.json`. Add ALL THREE of the following blocks:

```json
{
  "pnpm": {
    "overrides": {
      "pdfjs-dist": "4.10.38"
    }
  },
  "overrides": {
    "pdfjs-dist": "4.10.38"
  },
  "resolutions": {
    "pdfjs-dist": "4.10.38"
  }
}
```

Pin to a specific 4.x patch (for example, `4.10.38`), not a range.
Overrides behave most predictably with exact versions.

Also bump the `pdfjs-dist` line in `dependencies` (or
`devDependencies`) to match:

```json
{
  "dependencies": {
    "pdfjs-dist": "4.10.38"
  }
}
```

### 3. Re-install with a clean slate

```bash
rm -rf node_modules pnpm-lock.yaml package-lock.json yarn.lock
pnpm install        # or npm install / yarn install / bun install
```

Confirm `pdfjs-dist` resolves to 4.x:

```bash
pnpm why pdfjs-dist            # pnpm
npm ls pdfjs-dist              # npm
yarn why pdfjs-dist            # yarn
```

Every match should be on `4.x`. If any v5 entry remains, re-check
the override blocks for typos.

### 4. Build

```bash
pnpm build
```

The previously-failing build should now succeed. The viewer (set up
per `react-pdf-kit-nextjs-app-router` or
`react-pdf-kit-nextjs-pages-router`) renders normally at runtime.

### 5. Document the override

Add a short note to the project's README:

> ### Why `pdfjs-dist` is pinned to v4
>
> Next.js 14's webpack ESM interop has a bug
> ([wojtekmaj/react-pdf#1699](https://github.com/wojtekmaj/react-pdf/issues/1699))
> that prevents `pdfjs-dist@5` from loading. We pin `pdfjs-dist` to
> v4 via package-manager overrides until we upgrade to Next.js 15.

## Verify

```bash
pnpm build      # must exit 0
pnpm dev        # render a PDF; first page must appear
```

Pre-fix and post-fix transcripts are captured by task T033 in
`samples/nextjs-14-override/verification/`. To reproduce the bug
and double-check this skill is intact: temporarily flip the override
and the `dependencies` entry to `5.4.530`, re-install, then build.
The documented error should appear.

## References

- Upstream bug: <https://github.com/wojtekmaj/react-pdf/issues/1699>
- pnpm overrides: <https://pnpm.io/package_json#pnpmoverrides>
- npm overrides: <https://docs.npmjs.com/cli/v9/configuring-npm/package-json#overrides>
- yarn resolutions: <https://classic.yarnpkg.com/lang/en/docs/selective-version-resolutions/>
- Companion skills:
  - `react-pdf-kit-nextjs-app-router` and
    `react-pdf-kit-nextjs-pages-router`: apply either of these AFTER
    this override to set up the actual viewer.
