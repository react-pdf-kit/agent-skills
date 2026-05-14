# `samples/nextjs-14-override` — Next.js 14 + pdfjs-dist v4 (post-fix baseline)

Next.js 14 + webpack sample whose baseline is the **post-fix state** —
`pdfjs-dist` pinned to v4 via every package-manager override format
(`pnpm.overrides`, `overrides`, `resolutions`). This is the state a
project ends up in *after* applying the override skill.

## Skill verified against this sample

- [`react-pdf-kit-nextjs14-pdfjs-override`](../../skills/react-pdf-kit-nextjs14-pdfjs-override/SKILL.md)

## Why this exists

Next.js 14's webpack ESM interop has a known bug
([wojtekmaj/react-pdf#1699](https://github.com/wojtekmaj/react-pdf/issues/1699))
that causes `pdfjs-dist@5` (ESM-only) to fail at module load with:

```
TypeError: Object.defineProperty called on non-object
```

The override skill teaches AI agents to pin `pdfjs-dist` to v4 (which
ships both ESM and CommonJS) via package-manager overrides. This
sample is the post-fix state used to verify the skill produces a
working build.

## Verification flow (task T033)

1. **Capture failure transcript**: Temporarily bump `pdfjs-dist` (and
   all override entries) to `5.4.530`. Run `pnpm install && pnpm
   build` and capture the failure with the documented error string.
   Save to `verification/before-fix.txt`.
2. **Apply the skill**: Run
   `../../scripts/apply-skill-to-sample.sh react-pdf-kit-nextjs14-pdfjs-override nextjs-14-override`.
3. **Capture success transcript**: Re-run `pnpm install && pnpm build`.
   Save to `verification/after-fix.txt`.
4. **Revert**: `git restore package.json` to return to the baseline
   committed v4 state.

## Scaffold status

**Minimum viable** — only `package.json` and this README are committed
at v1 init. Run

```bash
pnpm create next-app@latest . -- --ts --eslint --tailwind=false --app --src-dir=false --import-alias='@/*' --no-turbo
```

once to hydrate the rest. Keep the pinned versions from
`package.json`. Make sure the generated `next.config.js` does NOT
enable Turbopack — this sample exists specifically to exercise the
webpack path.

## Pinned versions

- Next.js 14 (webpack mode)
- React 18
- pdfjs-dist 4.10.38 (post-fix; via package-manager overrides)
- @react-pdf-kit/viewer >=1.0.0 <2.0.0
