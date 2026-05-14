#!/usr/bin/env bash
#
# apply-skill-to-sample.sh — copy a skill's assets/templates into a
# sample project so contributors and CI can build the sample to verify
# the skill works end to end.
#
# Usage:
#   scripts/apply-skill-to-sample.sh <skill-name> <sample-name>
#
# Behavior:
#   - Reads skills/<skill-name>/SKILL.md (must exist) and recursively
#     copies the contents of skills/<skill-name>/assets/ into
#     samples/<sample-name>/, preserving relative paths.
#   - Records the application in samples/<sample-name>/verification/
#     applied-skills.txt (appended) so reviewers can see the order.
#   - Prints every file written.
#   - Exits non-zero if either directory is missing or no assets exist.
#
# This script intentionally does NOT install dependencies or run
# builds — that is the caller's job (CI matrix in samples.yml or the
# contributor running `pnpm install && pnpm build`).

set -euo pipefail

[[ $# -eq 2 ]] || { echo "usage: $0 <skill-name> <sample-name>" >&2; exit 1; }

skill_name="$1"
sample_name="$2"

repo_root="$(cd "$(dirname "$0")/.." && pwd)"
skill_dir="$repo_root/skills/$skill_name"
sample_dir="$repo_root/samples/$sample_name"

[[ -d "$skill_dir" ]]   || { echo "skill not found: $skill_dir" >&2; exit 2; }
[[ -d "$sample_dir" ]]  || { echo "sample not found: $sample_dir" >&2; exit 3; }
[[ -f "$skill_dir/SKILL.md" ]] || { echo "skill has no SKILL.md: $skill_dir" >&2; exit 4; }

assets_dir="$skill_dir/assets"
if [[ ! -d "$assets_dir" ]]; then
  echo "skill has no assets/ directory; nothing to apply: $skill_dir" >&2
  echo "(This is allowed for skills that are pure prose; verification"
  echo " for these skills is by reading the agent-generated code.)"
  exit 0
fi

verification_dir="$sample_dir/verification"
mkdir -p "$verification_dir"

written=()
while IFS= read -r -d '' src; do
  rel="${src#"$assets_dir/"}"
  dst="$sample_dir/$rel"
  mkdir -p "$(dirname "$dst")"
  cp "$src" "$dst"
  written+=("$rel")
done < <(find "$assets_dir" -type f -print0)

if (( ${#written[@]} == 0 )); then
  echo "no asset files found under $assets_dir; nothing applied" >&2
  exit 5
fi

# Record the application.
{
  echo "$(date -u +%Y-%m-%dT%H:%M:%SZ) applied $skill_name:"
  for f in "${written[@]}"; do echo "  $f"; done
} >> "$verification_dir/applied-skills.txt"

echo "applied $skill_name to samples/$sample_name (${#written[@]} files):"
for f in "${written[@]}"; do echo "  $f"; done
