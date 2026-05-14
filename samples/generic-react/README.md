# `samples/generic-react` — Vite + React 18 baseline

A minimal Vite + React 18 project pinned to **`pdfjs-dist@5.4.530`**.
Used as the bundler-agnostic baseline for skills that aren't Next.js
or Vite specific.

## Skills verified against this sample

- [`react-pdf-kit-setup`](../../skills/react-pdf-kit-setup/SKILL.md)
- [`react-pdf-kit-toolbar-customization`](../../skills/react-pdf-kit-toolbar-customization/SKILL.md)
- [`react-pdf-kit-custom-layout`](../../skills/react-pdf-kit-custom-layout/SKILL.md)

(See `MAINTENANCE.md` §Sample inventory for the authoritative mapping.)

## Local verification

```bash
cd samples/generic-react
pnpm install
pnpm build
# Apply a skill and re-run:
../../scripts/apply-skill-to-sample.sh react-pdf-kit-setup generic-react
pnpm build
```

The baseline `src/App.tsx` deliberately renders no PDF — applying a
skill is what mounts the viewer. CI's `samples.yml` builds the
baseline AND the post-application state for each skill targeting this
sample.

## Pinned versions

- Vite 5
- React 18
- pdfjs-dist 5.4.530
- @react-pdf-kit/viewer >=1.0.0 <2.0.0

Update `package.json` in lockstep with the skills' frontmatter
`metadata.react_pdf_kit_version` / `metadata.pdfjs_dist_version`
ranges when bumping. Never silently widen.
