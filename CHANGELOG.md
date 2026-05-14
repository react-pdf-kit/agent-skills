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

**Validated against**: `@react-pdf-kit/viewer` *TBD on first release.*

### Added

- Initial scaffolding: LICENSE (MIT), README, CONTRIBUTING,
  MAINTENANCE, CODEOWNERS, .gitignore.
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

- (none yet)

### Deprecated

- (none yet)

### Removed

- (none yet)

### Fixed

- (none yet)

### Security

- (none yet)
