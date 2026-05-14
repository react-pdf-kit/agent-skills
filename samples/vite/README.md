# `samples/vite` — Vite 5 + pdfjs-dist v5 (worker-integration-ready)

Vite-specific sample whose `vite.config.ts` is pre-arranged for the
PDF.js worker. Distinguished from `samples/generic-react/` (which is a
bundler-agnostic baseline) by being the target for skills that
explicitly teach Vite worker integration.

## Skills verified against this sample

- [`react-pdf-kit-setup`](../../skills/react-pdf-kit-setup/SKILL.md)
- [`react-pdf-kit-vite`](../../skills/react-pdf-kit-vite/SKILL.md)
- [`react-pdf-kit-worker-config`](../../skills/react-pdf-kit-worker-config/SKILL.md)

(See `MAINTENANCE.md` §Sample inventory for the authoritative mapping.)

## Scaffold status

**Minimum viable** — only `package.json` and this README are committed
at v1 init. Run

```bash
pnpm create vite@latest . -- --template react-ts
```

inside this directory once to hydrate the rest (`vite.config.ts`,
`index.html`, `src/main.tsx`, `src/App.tsx`, `tsconfig.json`). Keep the
pinned dependency versions from `package.json`. The live-verification
tasks (T026–T031 in `specs/001-react-pdf-kit-skills/tasks.md`) complete
this scaffold and capture a baseline build transcript.

## Pinned versions

- Vite 5
- React 18
- pdfjs-dist 5.4.530
- @react-pdf-kit/viewer >=1.0.0 <2.0.0

Update `package.json` in lockstep with the skills' frontmatter version
ranges when bumping.
