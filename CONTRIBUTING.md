# Contributing to @react-pdf-kit/agent-skills

Thank you for proposing a skill or correction. This repository's audience
is AI coding agents, and we hold contributions to a higher
specification-conformance bar than typical docs — both for cross-agent
compatibility (the [agentskills.io](https://agentskills.io) standard)
and for correctness against the React PDF Kit library itself.

## TL;DR

1. **Fork** this repo and clone your fork.
2. **Scaffold** a new skill: `npx skills init react-pdf-kit-<my-topic>`,
   then move the generated `SKILL.md` into
   `skills/react-pdf-kit-<my-topic>/`.
3. **Fill** the frontmatter and body per the
   [SKILL.md schema](#skill-md-schema-summary) below.
4. **Verify** locally: `scripts/verify-skill.sh
   skills/react-pdf-kit-<my-topic>` must exit 0.
5. **Apply** the skill to a sample project: `scripts/apply-skill-to-sample.sh
   react-pdf-kit-<my-topic> <sample-name>`, then `pnpm install && pnpm
   build` in the sample. Both must succeed.
6. **Tick** every applicable box on the
   [Skill Author Checklist](#skill-author-checklist) and open a PR.
7. CI runs `scripts/verify-all.sh` plus the sample-build matrix; a code
   owner reviews body accuracy. Merge requires both passing.

## Prerequisites

- A GitHub account.
- Node.js 20 LTS or later. The CLI works under any environment that
  ships `npx` (npm 5.2+), `pnpm dlx`, `yarn dlx`, or `bunx`.
- `yq` (for YAML parsing in `verify-skill.sh`). Install via `brew install
  yq` on macOS or your platform's package manager.
- React PDF Kit installed locally in a scratch project, so you can
  exercise the library against your skill while authoring.

## SKILL.md schema summary

Every skill is a directory under `skills/` containing a `SKILL.md`. The
file MUST begin with a YAML frontmatter block:

```yaml
---
name: react-pdf-kit-<my-topic>
description: <one sentence, ≤200 chars, mentions react-pdf-kit and the framework>
metadata:
  react_pdf_kit_version: ">=1.0.0 <2.0.0"
  pdfjs_dist_version: ">=5.0.0 <6.0.0"
  frameworks: [next.js]   # or [vite], [react], etc.
---
```

Required fields: `name`, `description`, `metadata.react_pdf_kit_version`,
`metadata.pdfjs_dist_version`. Optional: `metadata.frameworks`,
`metadata.tags`, `metadata.deprecated_in`, `metadata.internal`.

The body MUST stay ≤ 500 lines and ~5,000 tokens (~30,000 characters).
Longer reference material moves under `references/`, `assets/`, or
`scripts/` subdirectories and MUST be loaded with conditional triggers
("Read `references/foo.md` when X").

Full schema, including forbidden fields and verification rules, lives in
[`specs/001-react-pdf-kit-skills/contracts/skill-md-schema.md`](../specs/001-react-pdf-kit-skills/contracts/skill-md-schema.md).

## Body conventions

Skills inherit the [agentskills.io best
practices](https://agentskills.io/skill-creation/best-practices). The
recommended section order:

1. **Lead paragraph** (≤ 4 sentences): what this skill teaches and the
   trigger ("Use this skill when…").
2. **Gotchas** — bullet list of non-obvious environment-specific facts
   (required if at least one applies, which is almost always for
   React PDF Kit skills given the peer-dep landscape).
3. **Procedure** — numbered steps or a short recipe.
4. **Code / config templates** — inline if short, referenced from
   `assets/` if long.
5. **Verify** — exact commands the agent or developer runs to confirm
   success.
6. **References** — links to upstream docs and `references/` files with
   conditional load triggers.

## Sample projects

Skills must be verified against at least one sample project under
`samples/`. The Skill ↔ Sample mapping is tracked in
[`specs/001-react-pdf-kit-skills/data-model.md`](../specs/001-react-pdf-kit-skills/data-model.md);
update it in the same PR if your skill needs a new sample or remaps an
existing one.

Available samples at v1:

- `samples/generic-react/` — Vite 5 + React 18 + pdfjs-dist v5.
- `samples/vite/` — Vite 5 + pdfjs-dist v5.
- `samples/nextjs-app-router/` — Next.js 15 + Turbopack + pdfjs-dist v5.
- `samples/nextjs-14-override/` — Next.js 14 + webpack + pdfjs-dist v4
  (used to validate the override skill).

If you add a new sample, scaffold it minimally (no demo content beyond a
baseline page), pin every framework/peer-dep version explicitly in
`package.json`, and document which skills target it in the sample's
`README.md`.

## Skill Author Checklist

Tick each applicable box before requesting review. The full checklist
with rationale and constitution references lives at
[`specs/001-react-pdf-kit-skills/contracts/skill-author-checklist.md`](../specs/001-react-pdf-kit-skills/contracts/skill-author-checklist.md).
Reviewers also use it.

### Format & conformance

- [ ] `scripts/verify-skill.sh <skill-dir>` exits 0 locally.
- [ ] `name` frontmatter equals the directory name; both are kebab-case
  and globally unique under `skills/`.
- [ ] `description` is one sentence, ≤ 200 chars, contains a
  high-signal keyword (`react-pdf-kit`, framework name, etc.).
- [ ] `metadata.react_pdf_kit_version` and
  `metadata.pdfjs_dist_version` are valid semver ranges and match the
  sample project that verified the skill.
- [ ] `metadata.frameworks` lists every framework the skill applies to.

### Real expertise

- [ ] Every exported symbol, prop, hook, or CSS class the skill
  mentions exists in the canonical React PDF Kit library at the
  declared version range. (Verified by running the sample build.)
- [ ] No filler advice ("handle errors appropriately"). Every
  instruction tells the agent something specific it would otherwise
  get wrong.

### Progressive disclosure

- [ ] SKILL.md body is ≤ 500 lines / ≤ 30,000 chars.
- [ ] Long reference material lives under `references/`, loaded
  conditionally.
- [ ] Long code templates live under `assets/`.

### Gotchas

- [ ] A "Gotchas" section is present near the top of the body if any
  non-obvious environment-specific behavior applies (worker URL,
  bundler ESM handling, CSS injection, peer-dep pinning).

### Default + escape hatch

- [ ] The skill picks one default approach and mentions alternatives
  briefly. No menus of equally weighted options.

### Verification

- [ ] The skill appears in the Skill ↔ Sample mapping in
  `data-model.md`.
- [ ] `scripts/apply-skill-to-sample.sh <skill> <sample>` succeeds
  locally.
- [ ] `pnpm install && pnpm build` in the sample succeeds after
  application.
- [ ] The "Verify" section of the body matches what the sample build
  exercises.

### Constitution alignment

The project constitution lives at
[`.specify/memory/constitution.md`](../.specify/memory/constitution.md).
Five principles apply to every skill:

- [ ] I. Viewer-First Experience — skill does not advise patterns that
  degrade reader UX (text selection, keyboard nav, a11y).
- [ ] II. Integrator Respect — skill does not advise mutating globals,
  polluting `window`, bundling peer deps, or monkey-patching the
  bundler.
- [ ] III. Composable & Headless-Capable — default-layout skills use
  the full provider chain; customization skills use documented hooks
  only.
- [ ] IV. Performance & Rendering Discipline — no instruction breaks
  virtualization or moves PDF.js off the worker.
- [ ] V. Peer Dependency & Compatibility Stewardship —
  `metadata.*_version` ranges match the verified sample; peer-dep
  pins are justified and linked to upstream evidence.

### Repository hygiene

- [ ] `CHANGELOG.md` updated under `## [Unreleased]` with a line
  describing your change.
- [ ] If adding a new skill: the catalog table in `README.md` has a
  new row.
- [ ] If adding a new sample: `MAINTENANCE.md` §Sample inventory is
  updated.
- [ ] `CODEOWNERS` reflects new file paths if applicable.

## Review & merge

CI runs:

- `.github/workflows/verify.yml` — `scripts/verify-all.sh` on every
  PR.
- `.github/workflows/samples.yml` — matrix-build of every
  `samples/*` directory.

Both must be green. At least one code owner of the touched skill
directory reviews the body for accuracy. Merges happen via
"Squash and merge"; the commit message should follow Conventional
Commits.

## Reporting bugs and suggesting changes

For issues with the *content* of a skill (incorrect code, missing
gotchas, stale version range), open an issue rather than a PR — we will
help you scope the fix. For larger changes (new sample project, new
framework support, schema additions), open an issue first to align on
scope.

## License

By contributing, you agree your contribution is licensed under the
[MIT License](./LICENSE).
