# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working in
this repository.

## Project overview

This is **`@react-pdf-kit/agent-skills`**, the public catalog of agent
skills that teach AI coding agents how to integrate
[`@react-pdf-kit/viewer`](https://github.com/react-pdf-kit/viewer)
correctly. The catalog conforms to the
[agentskills.io specification](https://agentskills.io) and is installed
into consumer projects via the
[vercel-labs/skills](https://github.com/vercel-labs/skills) CLI
(`npx skills add react-pdf-kit/agent-skills#<skill-name>`).

It is a content/documentation repo, not a JavaScript application.

## Repository layout

```text
.
├── README.md                       # consumer-facing overview + worked examples
├── MAINTENANCE.md                  # release runbook, deprecation flow, security stance
├── CHANGELOG.md                    # one section per tagged release
├── LICENSE                         # MIT
├── skills/<skill-name>/SKILL.md    # the catalog content (8 skills at v1)
├── samples/<sample>/               # runnable sample projects used to verify skills
├── scripts/verify-skill.sh         # per-skill conformance check (R-10..R-20)
├── scripts/verify-all.sh           # run verify-skill.sh across skills/
├── scripts/apply-skill-to-sample.sh # copy assets/ from a skill into a sample
├── scripts/check-changelog.sh      # release.yml gate
└── .github/workflows/              # verify.yml, samples.yml, release.yml
```

External contributions are **not currently accepted**. See the
"Contributions" section in `README.md`. The author workflow below is
for maintainers.

## Common commands

```bash
# Run conformance checks against every skill (CI runs this on every PR)
scripts/verify-all.sh

# Validate one skill in isolation
scripts/verify-skill.sh skills/react-pdf-kit-setup

# Apply a skill into a sample project (used during contributor verification)
scripts/apply-skill-to-sample.sh react-pdf-kit-nextjs-app-router nextjs-app-router

# Validate the CHANGELOG section for a tag (used by release.yml)
scripts/check-changelog.sh v1.0.0
```

## Authoring a new skill (maintainers)

1. Scaffold: `npx skills init react-pdf-kit-<topic>`, then move the
   resulting `SKILL.md` into `skills/react-pdf-kit-<topic>/`.
2. Fill the required YAML frontmatter:

   ```yaml
   ---
   name: react-pdf-kit-<topic>            # MUST equal the directory name
   description: <one sentence, ≤200 chars>
   metadata:
     react_pdf_kit_version: ">=2.0.0 <3.0.0"
     pdfjs_dist_version: ">=5.0.0 <6.0.0"
     frameworks: [react]                  # optional; subset of [react, next.js, vite, webpack]
   ---
   ```

   Allow-listed fields only. `verify-skill.sh` rule R-15 fails on
   unknown keys. Optional: `metadata.tags`, `metadata.deprecated_in`,
   `metadata.internal`.

3. Author the body (≤500 lines / ~5,000 tokens) following the
   [agentskills.io best practices](https://agentskills.io/skill-creation/best-practices).
   Recommended section order: Lead paragraph → **Gotchas** →
   Procedure → Verify → References. Long reference material lives
   under `references/`, loaded conditionally ("Read X when …").
4. Add the skill to a sample project (or add a new sample), then
   verify locally:

   ```bash
   scripts/verify-skill.sh skills/react-pdf-kit-<topic>
   scripts/apply-skill-to-sample.sh react-pdf-kit-<topic> <sample-name>
   (cd samples/<sample-name> && pnpm install && pnpm build)
   ```

   All three must succeed.
5. Update `MAINTENANCE.md` §"Sample inventory" if the Skill ↔ Sample
   mapping changed. Update `README.md`'s "Skill Catalog" table with
   the new row.
6. Add a CHANGELOG entry under `## [Unreleased]` →
   `### Added` naming the new skill.

CI (`.github/workflows/verify.yml` + `samples.yml`) re-runs the
conformance script and the sample-build matrix on every PR.

## Constraints inherited from the React PDF Kit constitution

The library that this catalog teaches is governed by a project
constitution that lives in the React PDF Kit workspace (not in this
repo). Skills MUST NOT contradict its five principles:

1. Viewer-First Experience: never advise patterns that degrade
   reader UX (text selection, keyboard nav, a11y).
2. Integrator Respect: no globals, no peer-dep bundling, no
   bundler monkey-patching.
3. Composable & Headless-Capable: default-layout skills use the
   full provider chain; customization skills use documented hooks
   only.
4. Performance & Rendering Discipline: no instruction breaks
   virtualization or moves PDF.js off the worker.
5. Peer Dependency & Compatibility Stewardship: every skill
   declares `metadata.react_pdf_kit_version` and
   `metadata.pdfjs_dist_version` matching the sample that verified it.

Maintainers reviewing a new skill MUST evaluate it against each of
these five principles before merge.

## Compatibility

- `pdfjs-dist` is an **auto-installed peer dependency** (default
  **v5.4.530**, ESM-only). Consumers install only
  `@react-pdf-kit/viewer`; `pdfjs-dist` is installed separately only to
  override the version. Works on Vite, Turbopack, Next.js 15, webpack 5.
- **Next.js 14 is NOT supported by v2** (its webpack ESM interop breaks
  `pdfjs-dist@5`, the
  [documented bug](https://github.com/wojtekmaj/react-pdf/issues/1699)).
  The [`react-pdf-kit-nextjs14-pdfjs-override`](./skills/react-pdf-kit-nextjs14-pdfjs-override/SKILL.md)
  skill documents the two paths: upgrade to Next.js 15 (Turbopack), or
  stay on Next.js 14 with the legacy `@pdf-viewer/react` package.

## Release flow

See `MAINTENANCE.md`. Releases are tagged `vMAJOR.MINOR.PATCH`;
the `release.yml` workflow validates the CHANGELOG entry and
publishes a GitHub release.
