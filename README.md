# @react-pdf-kit/agent-skills

> Agent skills for [@react-pdf-kit/viewer](https://github.com/react-pdf-kit/viewer).
> Install with `npx skills add react-pdf-kit/agent-skills` and let your
> AI coding agent integrate the React PDF Kit library correctly on the
> first attempt.

This repository is a curated catalog of [agent skills](https://agentskills.io)
that teach AI coding agents (Claude Code, Cursor, OpenCode, Codex, and
anything else that follows the same convention) how to set up,
customize, and troubleshoot the React PDF Kit viewer across the React,
Next.js, and Vite ecosystems. Skills are installed via the open-source
[vercel-labs/skills](https://github.com/vercel-labs/skills) CLI.

## Who is this for?

- **Developers using AI coding agents** to build with React PDF Kit, who
  want first-attempt-correct integration code without spending time
  debugging peer-dependency and bundler interop issues.
- **AI coding agents themselves**: every skill here is authored to the
  [agentskills.io specification](https://agentskills.io) and is
  retrievable by both `npx skills find` and direct GitHub shorthand.

## Quickstart

### 1. Discover

```bash
npx skills find "react pdf kit"
```

You'll get a ranked list of skills with each skill's `name`,
`description`, and supported version range.

### 2. Install

Install one skill (recommended):

```bash
npx skills add react-pdf-kit/agent-skills#react-pdf-kit-nextjs-app-router
```

Install the whole catalog:

```bash
npx skills add react-pdf-kit/agent-skills
```

By default skills are installed into your project's agent-specific
directory (e.g., `.claude/skills/` for Claude Code, `.agents/skills/` for
Cursor / OpenCode / Codex). Add `-g` for global installation.

### 3. Ask your agent

With the skill installed, your agent activates it automatically when you
ask about React PDF Kit. Example prompt: *"Add a PDF viewer for
`report.pdf` to my Next.js project."*

### Other package managers

| Tool | Invocation |
|------|------------|
| npm | `npx skills add …` |
| pnpm | `pnpm dlx skills add …` |
| yarn (1.x) | `yarn dlx skills add …` |
| bun | `bunx skills add …` |

## Skill Catalog

The catalog is populated as skills are merged. Each row links to the
skill's `SKILL.md`. Per-skill compatibility (React PDF Kit and
`pdfjs-dist` version ranges) lives in each skill's YAML frontmatter
under `metadata.react_pdf_kit_version` and
`metadata.pdfjs_dist_version`.

| Skill | Description |
|-------|-------------|
| [`react-pdf-kit-setup`](./skills/react-pdf-kit-setup/SKILL.md) | Set up `@react-pdf-kit/viewer` in a generic React app, including PDF.js worker setup and the canonical provider chain. |
| [`react-pdf-kit-nextjs-app-router`](./skills/react-pdf-kit-nextjs-app-router/SKILL.md) | Integrate `@react-pdf-kit/viewer` into a Next.js App Router project, including PDF.js worker configuration. |
| [`react-pdf-kit-nextjs-pages-router`](./skills/react-pdf-kit-nextjs-pages-router/SKILL.md) | Integrate `@react-pdf-kit/viewer` into a Next.js Pages Router project with SSR-safe dynamic import. |
| [`react-pdf-kit-vite`](./skills/react-pdf-kit-vite/SKILL.md) | Integrate `@react-pdf-kit/viewer` into a Vite project, including the PDF.js worker import. |
| [`react-pdf-kit-worker-config`](./skills/react-pdf-kit-worker-config/SKILL.md) | Configure the PDF.js worker URL across supported bundlers (Vite, Turbopack, webpack, Next.js App Router). |
| [`react-pdf-kit-toolbar-customization`](./skills/react-pdf-kit-toolbar-customization/SKILL.md) | Add, remove, or replace individual toolbar tools while preserving Radix-based accessibility. |
| [`react-pdf-kit-custom-layout`](./skills/react-pdf-kit-custom-layout/SKILL.md) | Build a headless / custom layout for the viewer using only the documented hooks. |
| [`react-pdf-kit-nextjs14-pdfjs-override`](./skills/react-pdf-kit-nextjs14-pdfjs-override/SKILL.md) | Override `pdfjs-dist` to v4 to work around the Next.js 14 webpack ESM interop bug. |

## Troubleshooting

### Next.js 14 build fails with `TypeError: Object.defineProperty called on non-object`

This is the documented Next.js 14 + `pdfjs-dist@5` webpack ESM interop
bug ([wojtekmaj/react-pdf#1699](https://github.com/wojtekmaj/react-pdf/issues/1699)).
Install the override skill:

```bash
npx skills add react-pdf-kit/agent-skills#react-pdf-kit-nextjs14-pdfjs-override
```

Ask your agent to apply it; the agent will downgrade `pdfjs-dist` to v4
via a package-manager override and the build will succeed.

## When things go wrong

These behaviors are governed by the upstream
[vercel-labs/skills](https://github.com/vercel-labs/skills) CLI; reading them here helps you interpret errors quickly.

- **`no matching skill` after `npx skills add <name>`**: the name is
  wrong or the skill has been renamed. Symptom: CLI exits non-zero with
  a "no matching skill" line. Response: run `npx skills find <keyword>`
  and pick the exact `name` from the result list.
- **Network failure during `add`**: the CLI fails fast with the
  underlying transport error and does **not** leave a partial install.
  Response: retry once the network is restored. There is no recovery
  step needed.
- **Re-install of an already-installed skill**: the CLI prompts before
  overwriting (or refuses if `--yes` is not set). Response: either
  confirm overwrite (you lose local edits to the installed copy) or
  decline and uninstall the existing copy first with
  `npx skills remove <name>`.

For issues with the *content* of a skill (incorrect code, missing
gotchas, stale version range), open an issue in this repository.

## How an AI agent discovers and uses this repo

The transcript below is a representative session showing the
discover, install, ask flow. It is the same flow the spec's SC-001
trial protocol exercises (see
`specs/001-react-pdf-kit-skills/tasks.md` T041). Replace this example
with an anonymized real session captured during T041 once that runs.

```text
$ pnpm create next-app@latest my-pdf-app -- --ts --eslint --app --no-tailwind --no-src-dir --turbo
... (Next.js scaffold completes)

$ cd my-pdf-app

$ npx skills find "react pdf kit next.js"
react-pdf-kit-nextjs-app-router          Integrate @react-pdf-kit/viewer (>=1.0.0 <2.0.0) into a Next.js...
react-pdf-kit-nextjs14-pdfjs-override    Override pdfjs-dist to v4 to work around the Next.js 14 + pdfjs-dist v5...
react-pdf-kit-nextjs-pages-router        Integrate @react-pdf-kit/viewer (>=1.0.0 <2.0.0) into a Next.js Pages...
react-pdf-kit-worker-config              Configure the PDF.js worker URL across supported bundlers...

$ npx skills add react-pdf-kit/agent-skills#react-pdf-kit-nextjs-app-router
Installed react-pdf-kit-nextjs-app-router into .claude/skills/

$ # Open Claude Code (or your agent of choice) and ask:
> Add a PDF viewer to /document/[id] that loads /api/documents/[id].pdf.

# Agent activates the skill, installs @react-pdf-kit/viewer + pdfjs-dist,
# generates app/_components/PdfViewer.tsx with the canonical provider
# chain and worker config, generates app/document/[id]/page.tsx with
# the dynamic-import + ssr:false pattern, and runs `pnpm install` then
# `pnpm build`. Build is green; navigating to /document/test renders
# the first PDF page.
```

The same shape works under Cursor, OpenCode, and Codex. The CLI
routes the install into the right per-agent directory automatically.

## Contributions

This catalog is **not currently accepting external contributions**.
The maintainers are still validating the v1 catalog end to end and
the contribution workflow has not been opened up yet.

If you'd like to **request a new skill**, **report an incorrect
recipe**, or **flag a stale version range**, please
[open an issue](https://github.com/react-pdf-kit/agent-skills/issues).
We'll triage it and either author the skill in-house or revisit the
contribution surface once the v1 verification protocol is settled.

## Maintenance & releases

See [MAINTENANCE.md](./MAINTENANCE.md) for the release runbook,
versioning policy, deprecation flow, and skills.sh submission tracker.

## Related projects

- [react-pdf-kit/viewer](https://github.com/react-pdf-kit/viewer): the
  React PDF Kit library this catalog teaches.
- [agentskills.io](https://agentskills.io): the agent-skills standard.
- [vercel-labs/skills](https://github.com/vercel-labs/skills): the
  open-source `npx skills` CLI implementing the standard.

## License

[MIT](./LICENSE)
