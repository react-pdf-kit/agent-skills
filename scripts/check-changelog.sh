#!/usr/bin/env bash
#
# check-changelog.sh — assert that CHANGELOG.md has a section for the
# given git tag AND that section includes a "Validated against" line.
# Called by .github/workflows/release.yml on every v* tag push.
#
# Usage:
#   scripts/check-changelog.sh <git-tag>
# e.g.:
#   scripts/check-changelog.sh v1.0.0

set -euo pipefail

[[ $# -eq 1 ]] || { echo "usage: $0 <git-tag>" >&2; exit 1; }

tag="$1"
version="${tag#v}"

repo_root="$(cd "$(dirname "$0")/.." && pwd)"
changelog="$repo_root/CHANGELOG.md"

[[ -f "$changelog" ]] || { echo "check-changelog.sh: CHANGELOG.md missing" >&2; exit 2; }

# Find the section header for this version. Format: "## [<version>] - <date>".
header_line="$(grep -nE "^## \[$version\]" "$changelog" | head -n 1 | cut -d: -f1 || true)"
if [[ -z "$header_line" ]]; then
  echo "check-changelog.sh: no '## [$version]' header in CHANGELOG.md for tag $tag" >&2
  exit 3
fi

# Extract section content (from header_line to the next "## [" or EOF).
section="$(awk -v start="$header_line" 'NR>start { if (/^## \[/) exit; print }' "$changelog")"

# Must contain a "Validated against" line.
if ! grep -qE '^\*\*Validated against\*\*:' <<< "$section"; then
  echo "check-changelog.sh: CHANGELOG section for $tag is missing a '**Validated against**:' line" >&2
  exit 4
fi

# Validated-against line must not still say 'TBD'.
if grep -qE '^\*\*Validated against\*\*:.*\bTBD\b' <<< "$section"; then
  echo "check-changelog.sh: CHANGELOG section for $tag still says 'TBD' for Validated against" >&2
  exit 5
fi

# Must be non-empty beyond the header line itself.
content_lines="$(printf '%s\n' "$section" | grep -cE '^[^[:space:]]' || true)"
if (( content_lines < 2 )); then
  echo "check-changelog.sh: CHANGELOG section for $tag has no entries beyond the header" >&2
  exit 6
fi

echo "check-changelog.sh: PASS — CHANGELOG.md section for $tag is well-formed"
