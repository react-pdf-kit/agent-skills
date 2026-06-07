# Changelog

All notable changes to this catalog are documented here. The format
follows [Keep a Changelog](https://keepachangelog.com/) loosely, and
each release records the validated `@react-pdf-kit/viewer` version
range under a **Validated against** line.

## Conventions

- One section per release, header format `## [<X.Y.Z>] - <YYYY-MM-DD>`.
- Each release section MUST contain a `**Validated against**:
  @react-pdf-kit/viewer <semver-range>` line; the CI release workflow
  (`.github/workflows/release.yml`) checks for it via
  `scripts/check-changelog.sh`.
- Group entries under: **Added**, **Changed**, **Deprecated**,
  **Removed**, **Fixed**, **Security**. Omit empty groups.
- Reference skills by their kebab-case `name`, not their display
  description.

## [Unreleased]

Retarget the entire catalog at the `@react-pdf-kit/viewer` v2.x.x
release line, align every skill with the official v2 docs, and
centralize all worker / `pdfjs-dist` configuration in
`react-pdf-kit-worker-config`.

**Validated against**: `@react-pdf-kit/viewer` `>=2.0.0 <3.0.0`

### Changed

- Every skill's `metadata.react_pdf_kit_version` moved from
  `>=1.0.0 <2.0.0` to `>=2.0.0 <3.0.0`. Descriptions updated to match.
- Install instructions across all skills now install **only**
  `@react-pdf-kit/viewer`. Per the v2 docs, `pdfjs-dist` is an
  auto-installed peer dependency (default `5.4.530`); it is installed
  explicitly only when overriding the version.
- Default examples use `<RPLayout toolbar>` and drop the manual
  `RPTheme` (`RPConfig` wraps theming and worker setup internally). The
  optional `RPConfig` `licenseKey` prop is documented.
- `react-pdf-kit-nextjs-app-router` and
  `react-pdf-kit-nextjs-pages-router` restructured around the
  documented client-only pattern (`'use client'` + `next/dynamic`
  `ssr: false`), targeting Next.js 15 + Turbopack, and now reference
  the `Promise.withResolve is not a function` server-render error.
- `react-pdf-kit-worker-config` rewritten around v2: the worker is
  auto-configured (zero setup by default); the skill now owns the
  `pdfjs-dist` version-override flow (install + package-manager
  override) and the per-bundler `RPConfig` `workerUrl` recipes (Vite
  `?url`, Next.js 15 Turbopack `import.meta.url`, webpack
  `copy-webpack-plugin`).
- `react-pdf-kit-nextjs14-pdfjs-override` rewritten as a compatibility
  note: **v2 does not support Next.js 14**. It now documents the two
  supported paths (upgrade to Next.js 15 + Turbopack, or stay on
  Next.js 14 with the legacy `@pdf-viewer/react` package) instead of
  the obsolete "pin `pdfjs-dist` to v4" recipe.

### Removed

- All manual PDF.js worker-configuration guidance (the
  `pdfjs-worker.ts` side-effect module, `GlobalWorkerOptions.workerSrc`
  assignment, and the Next.js `useEffect` worker wiring) removed from
  the general skills `react-pdf-kit-setup`, `react-pdf-kit-vite`,
  `react-pdf-kit-nextjs-app-router`, and
  `react-pdf-kit-nextjs-pages-router`. These skills now focus solely on
  React PDF Kit usage and defer all worker / `pdfjs-dist` configuration
  to `react-pdf-kit-worker-config`.

## [1.0.0-beta.2] - 2026-05-15

README polish on top of `v1.0.0-beta.1`.

**Validated against**: `@react-pdf-kit/viewer` `>=1.0.0 <2.0.0`

### Changed

- `README.md` Skill Catalog table no longer carries the
  `React PDF Kit` and `pdfjs-dist` version-range columns. Seven of
  the eight catalog rows showed identical ranges, so the columns
  were noise. The override skill's distinct `pdfjs-dist` v4
  dependency is still surfaced through its own description in the
  table and through the dedicated Troubleshooting section. Per-skill
  compatibility ranges remain machine-readable in each skill's YAML
  frontmatter (`metadata.react_pdf_kit_version` and
  `metadata.pdfjs_dist_version`), which is the canonical source of
  truth.

### Catalog content

(No skill content changes since `v1.0.0-beta.1`. All eight skills,
sample scaffolds, scripts, and CI workflows ship unchanged.)

## [1.0.0-beta.1] - 2026-05-14

Patch on top of `v1.0.0-beta.0` to fix the release workflow.

**Validated against**: `@react-pdf-kit/viewer` `>=1.0.0 <2.0.0`

### Fixed

- `.github/workflows/release.yml`: the "Confirm samples workflow
  green for this commit" step incorrectly assumed `samples.yml` had
  run against the tag commit on `main`, but `samples.yml` only
  triggers on `pull_request` and `push to main`, never on tag
  pushes. The query also hard-coded `--branch=main` even when the
  tag was on `develop`, so it returned `'unknown'` and failed the
  release on `v1.0.0-beta.0`. The step is now informational only:
  it reports the samples run conclusion as a notice/warning and no
  longer fails the release. The maintainer cutting the tag remains
  responsible for ensuring the green PR for the tagged commit
  exists.

### Catalog content

(No skill or content changes since `v1.0.0-beta.0`. All eight
skills, README, MAINTENANCE, CLAUDE.md, conformance scripts, and
the rest of the CI surface ship unchanged.)

## [1.0.0-beta.0] - 2026-05-14

First public pre-release for testing. The catalog and verification
scripts are feature-complete for v1, but the live build-verification
trials documented in the spec (T026 through T031, T033, T041) have
not yet been executed end to end against real `pnpm create next-app`
and `pnpm create vite` projects. Feedback wanted on skill accuracy,
agent activation behavior, and the install workflow before promoting
to v1.0.0.

**Validated against**: `@react-pdf-kit/viewer` `>=1.0.0 <2.0.0`

### Added

- Initial scaffolding: LICENSE (MIT), README, MAINTENANCE,
  .gitignore. (CONTRIBUTING and CODEOWNERS were authored and then
  removed before first release. See Removed below.)
- Conformance scripts: `scripts/verify-skill.sh`,
  `scripts/verify-all.sh`, `scripts/apply-skill-to-sample.sh`,
  `scripts/check-changelog.sh`.
- Sample-project scaffolds: `samples/generic-react/`, `samples/vite/`,
  `samples/nextjs-app-router/`, `samples/nextjs-14-override/`.
- CI workflows: `.github/workflows/verify.yml`,
  `.github/workflows/samples.yml`, `.github/workflows/release.yml`.
- Skills (v1 catalog):
  - `react-pdf-kit-setup`
  - `react-pdf-kit-nextjs-app-router`
  - `react-pdf-kit-nextjs-pages-router`
  - `react-pdf-kit-vite`
  - `react-pdf-kit-worker-config`
  - `react-pdf-kit-toolbar-customization`
  - `react-pdf-kit-custom-layout`
  - `react-pdf-kit-nextjs14-pdfjs-override`

### Changed

- All skills and the README now teach `RPLayout` as the canonical
  layout component. `RPDefaultLayout` is deprecated in
  `@react-pdf-kit/viewer` v2.0.0 and will be removed in a future
  release. Each affected skill (setup, vite, nextjs-app-router,
  nextjs-pages-router, toolbar-customization, custom-layout) ships
  an explicit Gotcha entry calling out the deprecation, and the
  toolbar-customization skill is rewritten to teach
  `RPLayout`'s `toolbar` prop with `RPHorizontalBar` /
  `RPVerticalBar` slot customization. The "fully custom bar"
  fallback (composing individual `*Tool` exports) is preserved as
  step 4 of that skill.
- Catalog prose (SKILL.md bodies, README, CLAUDE.md, MAINTENANCE.md)
  no longer uses the em dash character. Voice tightened across all
  authored content.

### Deprecated

- (none yet)

### Removed

- `CONTRIBUTING.md` and `CODEOWNERS`. The catalog is not currently
  accepting external contributions, and the placeholder CODEOWNERS
  teams (`@react-pdf-kit/maintainers`, `@react-pdf-kit/samples-owners`,
  `@react-pdf-kit/infra-owners`) do not yet exist on GitHub. README's
  "Contributions" section now directs would-be contributors to open
  an issue. Both files will be reintroduced when external
  contributions open up.

### Fixed

- (none yet)

### Security

- (none yet)
