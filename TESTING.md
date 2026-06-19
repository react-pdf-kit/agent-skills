# Internal Testing Guide: `@react-pdf-kit/agent-skills`

The catalog lives at <https://github.com/react-pdf-kit/agent-skills> (private). Until it goes public, install skills from a local checkout instead of the GitHub shorthand.

## Prerequisites

- Node.js 20+
- Read access to `react-pdf-kit/agent-skills`
- Clone the catalog locally:
  ```bash
  cd YOUR_PATH
  git clone git@github.com:react-pdf-kit/agent-skills.git
  ```

## 1. Pick a target project

Use one of:

- A fresh `pnpm create next-app@latest` (App Router, TypeScript)
- The workspace's existing `starter-rp-next-ts/`
- Any internal project that needs a PDF viewer
- A throwaway dir (`mkdir /tmp/skills-test && cd /tmp/skills-test && npm init -y`) if you only want to test the CLI mechanics

## 2. Install the matching skill from the local checkout

From the target project root:

```bash
npx skills add ~/YOUR_PATH/agent-skills/skills/react-pdf-kit-nextjs-app-router
```

Pick the skill that matches your stack:

| Stack                     | Skill                                                                           |
| ------------------------- | ------------------------------------------------------------------------------- |
| Next.js 15 App Router     | `react-pdf-kit-nextjs-app-router`                                               |
| Next.js 15 Pages Router   | `react-pdf-kit-nextjs-pages-router`                                             |
| Next.js 14 (any)          | `react-pdf-kit-nextjs-app-router` **+** `react-pdf-kit-nextjs14-pdfjs-override` |
| Vite + React              | `react-pdf-kit-vite`                                                            |
| Plain CRA / generic React | `react-pdf-kit-setup`                                                           |
| Customizing the toolbar   | add `react-pdf-kit-toolbar-customization`                                       |
| Headless / custom layout  | add `react-pdf-kit-custom-layout`                                               |

Confirm the skill landed:

```bash
ls .claude/skills/        # Claude Code
# or
ls .agents/skills/        # Cursor / OpenCode / Codex
npx skills list
```

Each `add` should exit 0 and the skill directory should contain `SKILL.md` plus any referenced assets.

## 3. Open the project in your agent and prompt it

Put any small PDF at `public/sample.pdf` first.

**Claude Code:**

```bash
cd <project>
claude
```

**Cursor / OpenCode / Codex:** open the project, ensure the agent has skill support enabled.

Then ask, verbatim:

> Add a PDF viewer page that loads `/sample.pdf`. Use the React PDF Kit skill that's installed in this project.

## Reporting bugs

File issues with:

- Skill name(s) tested
- Agent (Claude Code / Cursor / OpenCode / Codex) and version
- What you prompted
- What went wrong (CLI error, wrong code generated, build failure, runtime failure)
- The generated file(s) if applicable
