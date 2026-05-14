# Maintenance & Release Runbook

This document is the source of truth for maintainers cutting releases,
deprecating skills, and tracking the skills.sh registry submission.

## Versioning policy

We use [Semantic Versioning](https://semver.org) on git tags
(`vMAJOR.MINOR.PATCH`).

- **MAJOR**: A skill `name` was removed or renamed, OR any skill's
  `metadata.react_pdf_kit_version` no longer overlaps the previous
  release's range. Renames are equivalent to remove + add from the
  CLI's perspective and break consumer pins.
- **MINOR**: A new skill or new sample is added, or any skill's
  version range is widened.
- **PATCH**: Content corrections, doc fixes, range narrowing within an
  already-supported window, schema-conformance fixes.

Every release records, in `CHANGELOG.md`, the **validated React PDF Kit
version range** the skills were exercised against.

## Release runbook

1. **Decide the version bump.** Inspect every PR merged since the last
   tag against the rules above. When in doubt, treat it as the higher
   bump.
2. **Update CHANGELOG.md.** Move the `## [Unreleased]` header content
   into a new `## [<X.Y.Z>] - <YYYY-MM-DD>` section. Add a
   "Validated against `@react-pdf-kit/viewer` `<range>`" line. List
   skills added / changed / deprecated since previous release, by
   name. List sample-project additions / changes by name.
3. **Run the full suite locally.**

   ```bash
   scripts/verify-all.sh
   for sample in samples/*/; do
     (cd "$sample" && pnpm install && pnpm build) || exit 1
   done
   ```

   Both must exit 0. CI also runs these on the release branch but a
   local run catches issues before the tag.
4. **Tag and push.**

   ```bash
   git tag -a v<X.Y.Z> -m "v<X.Y.Z>: <one-line summary>"
   git push origin v<X.Y.Z>
   ```

   The `.github/workflows/release.yml` workflow validates the
   `CHANGELOG.md` entry for the pushed tag exists, then creates a
   GitHub release with the CHANGELOG section as the body.
5. **Announcement checklist.**
   - [ ] Update the README's "Latest validated against" line (if used).
   - [ ] Post to the React PDF Kit org's discussions / Discord / Slack
     channel (whichever applies).
   - [ ] If a new skill was added, file a discoverability re-index
     request with the skills.sh registry (see §skills.sh tracker).

## Deprecation flow

To deprecate a skill **without** removing it (preferred, since it
gives consumers time to migrate):

1. Add `metadata.deprecated_in: <next-release-version>` to the skill's
   frontmatter.
2. Prepend a `> **Deprecated** in repository release <X.Y.Z>. Use
   `<replacement-skill>` instead. …` blockquote as the first non-blank
   line of the body.
3. Add a row to `CHANGELOG.md` under the next release's
   "Deprecations" subsection naming the deprecated skill and its
   replacement.
4. Run `scripts/verify-skill.sh skills/<deprecated-skill>` and confirm
   it still exits 0 (rule R-19 enforces the banner presence).

To **remove** a deprecated skill:

1. Wait at least one MAJOR release after deprecation.
2. Delete the skill's directory.
3. Add a "Removed" line in CHANGELOG; bump MAJOR.
4. If consumers commonly install this skill, leave a tombstone entry in
   the README catalog noting the removal release and the canonical
   replacement.

## skills.sh registry tracker

[skills.sh](https://skills.sh) is the community registry of agent
skills. The vercel-labs/skills CLI works without it (GitHub shorthand
is enough), but submitting our catalog improves discoverability for
agents that browse the registry.

**Submission status**: `Not submitted yet.` Planned for the first
release after v1.0.0.

**Submission steps** (when ready):

1. Confirm the repo's `README.md` clearly states the catalog's purpose
   and the supported library version range.
2. Confirm every skill in `skills/` has a valid `description` because
   skills.sh indexes by description.
3. Visit <https://skills.sh/submit> (or the current submission flow
   linked from the homepage) and submit `react-pdf-kit/agent-skills`
   as the GitHub source.
4. Record the submission date and listing URL in this file under
   "Submission history" below.

**Submission history**:

| Date | Action | Notes |
|------|--------|-------|
|      |        | First entry will be added on submission. |

## Sample inventory

| Sample | Framework | pdfjs-dist | Used by |
|--------|-----------|------------|---------|
| `samples/generic-react/` | Vite + React 18 | v5 | `react-pdf-kit-setup`, `react-pdf-kit-toolbar-customization`, `react-pdf-kit-custom-layout` |
| `samples/vite/` | Vite 5 | v5 | `react-pdf-kit-setup`, `react-pdf-kit-vite`, `react-pdf-kit-worker-config` |
| `samples/nextjs-app-router/` | Next.js 15 + Turbopack | v5 | `react-pdf-kit-nextjs-app-router`, `react-pdf-kit-nextjs-pages-router` (via `verification/pages-router/` shim), `react-pdf-kit-worker-config`, `react-pdf-kit-toolbar-customization`, `react-pdf-kit-custom-layout` |
| `samples/nextjs-14-override/` | Next.js 14 + webpack | v4 (post-fix) | `react-pdf-kit-nextjs14-pdfjs-override` |

If a skill needs verification against a framework / version combination
not listed above, add a new sample in the same PR as the skill and
extend this table.

## Verified flows

Maintainers periodically walk the deprecation and release flows
end-to-end to ensure the runbook stays accurate. Record each walk here.

| Date | Flow | Outcome |
|------|------|---------|
|      | Deprecation drill (per tasks T038) | TBD |
|      | First release (v1.0.0, per tasks T045) | TBD |

## Security review

`MAINTENANCE.md` is also the home for security-posture notes (per spec
FR-010 + tasks T043).

**Security posture (last reviewed: TBD)**:

- LICENSE: MIT, present, scope-correct.
- Sample projects: no embedded secrets, no `.env` files committed.
- Third-party code: only sample-project scaffolds pulled from upstream
  framework installers. No copied code from third-party repos.
- `pnpm audit` / `npm audit` posture for each sample: TBD on first
  review.

Re-run on every release and update the "last reviewed" date.

## Document ownership

This file is maintained by the React PDF Kit catalog maintainers.
Major changes (versioning policy revision, new release artifact,
registry choice) require a PR that updates this file and any
user-facing references in `README.md`.
