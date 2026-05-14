# `samples/nextjs-app-router` — Next.js 15 (App Router, Turbopack) baseline

Next.js 15 App Router sample using **Turbopack** in dev and Next's
default bundler in build. Pinned to `pdfjs-dist@5.4.530`.

## Skills verified against this sample

- [`react-pdf-kit-nextjs-app-router`](../../skills/react-pdf-kit-nextjs-app-router/SKILL.md)
- [`react-pdf-kit-nextjs-pages-router`](../../skills/react-pdf-kit-nextjs-pages-router/SKILL.md) — via a `verification/pages-router/` shim, not a separate sample (per task T028).
- [`react-pdf-kit-worker-config`](../../skills/react-pdf-kit-worker-config/SKILL.md)
- [`react-pdf-kit-toolbar-customization`](../../skills/react-pdf-kit-toolbar-customization/SKILL.md)
- [`react-pdf-kit-custom-layout`](../../skills/react-pdf-kit-custom-layout/SKILL.md)

## Scaffold status

**Minimum viable** — only `package.json` and this README are committed
at v1 init. Run

```bash
pnpm create next-app@latest . -- --ts --eslint --tailwind=false --app --src-dir=false --import-alias='@/*' --turbo
```

once to hydrate the rest (`next.config.ts`, `tsconfig.json`,
`app/layout.tsx`, `app/page.tsx`). Keep the pinned dependency versions
from `package.json`. The live-verification tasks (T027, T028, T030,
T031 in `specs/001-react-pdf-kit-skills/tasks.md`) complete this
scaffold and capture baseline + post-application build transcripts.

## Pages-Router verification shim

To verify the `react-pdf-kit-nextjs-pages-router` skill without
maintaining a separate sample, the verification process ports the
agent-generated App-Router code into a `pages/_app.tsx` shim under
`verification/pages-router/`. The shim is built independently and is
not part of the default `next build`. See task T028 for the procedure.

## Pinned versions

- Next.js 15 (App Router default; Turbopack for `dev`)
- React 18
- pdfjs-dist 5.4.530
- @react-pdf-kit/viewer >=1.0.0 <2.0.0
