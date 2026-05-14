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
├── CONTRIBUTING.md                 # author workflow, schema requirements, checklist
├── MAINTENANCE.md                  # release runbook, deprecation flow, security stance
├── CHANGELOG.md                    # one section per tagged release
├── LICENSE                         # MIT
├── CODEOWNERS                      # review routing
├── skills/<skill-name>/SKILL.md    # the catalog content (8 skills at v1)
├── samples/<sample>/               # runnable sample projects used to verify skills
├── scripts/verify-skill.sh         # per-skill conformance check (R-10..R-20)
├── scripts/verify-all.sh           # run verify-skill.sh across skills/
├── scripts/apply-skill-to-sample.sh # copy assets/ from a skill into a sample
├── scripts/check-changelog.sh      # release.yml gate
└── .github/workflows/              # verify.yml, samples.yml, release.yml
```

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

## Authoring a new skill

1. Read [`CONTRIBUTING.md`](./CONTRIBUTING.md) end to end.
2. Scaffold: `npx skills init react-pdf-kit-<topic>`, then move the
   resulting `SKILL.md` into `skills/react-pdf-kit-<topic>/`.
3. Fill the YAML frontmatter per the
   [`SKILL.md` schema](./CONTRIBUTING.md#skillmd-schema-summary).
4. Author the body (Lead → **Gotchas** → Procedure → Verify →
   References) following the
   [agentskills.io best practices](https://agentskills.io/skill-creation/best-practices).
5. Verify locally: `scripts/verify-skill.sh skills/react-pdf-kit-<topic>`
   then `scripts/apply-skill-to-sample.sh <skill> <sample>` then
   `pnpm install && pnpm build` in the sample.
6. Tick every applicable item on the
   [Skill Author Checklist](./CONTRIBUTING.md#skill-author-checklist)
   and open a PR.

## Constraints inherited from the React PDF Kit constitution

The library that this catalog teaches is governed by a project
constitution that lives in the React PDF Kit workspace (not in this
repo). Skills MUST NOT contradict its five principles:

1. Viewer-First Experience — never advise patterns that degrade
   reader UX (text selection, keyboard nav, a11y).
2. Integrator Respect — no globals, no peer-dep bundling, no
   bundler monkey-patching.
3. Composable & Headless-Capable — default-layout skills use the
   full provider chain; customization skills use documented hooks
   only.
4. Performance & Rendering Discipline — no instruction breaks
   virtualization or moves PDF.js off the worker.
5. Peer Dependency & Compatibility Stewardship — every skill
   declares `metadata.react_pdf_kit_version` and
   `metadata.pdfjs_dist_version` matching the sample that verified it.

The author checklist in `CONTRIBUTING.md` reproduces these as
review items.

## Compatibility

- Default `pdfjs-dist`: **v5.4.530** (ESM-only). Works on Vite,
  Turbopack, Next.js 13+/15, webpack 5.
- **Next.js 14 + webpack** has the documented
  [`pdfjs-dist@5` ESM bug](https://github.com/wojtekmaj/react-pdf/issues/1699).
  Use the [`react-pdf-kit-nextjs14-pdfjs-override`](./skills/react-pdf-kit-nextjs14-pdfjs-override/SKILL.md)
  skill to pin to v4.

## Release flow

See `MAINTENANCE.md`. Releases are tagged `vMAJOR.MINOR.PATCH`;
the `release.yml` workflow validates the CHANGELOG entry and
publishes a GitHub release.
