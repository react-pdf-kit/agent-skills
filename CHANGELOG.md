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

(No changes yet since v1.0.0-beta.0.)

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
