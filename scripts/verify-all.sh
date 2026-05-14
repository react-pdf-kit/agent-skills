#!/usr/bin/env bash
#
# verify-all.sh — run verify-skill.sh against every skill under skills/
# and exit with the worst result. Also runs the find-discoverability
# probe for SC-010 when SKILLS_FIND_PROBE=1.
#
# Usage:
#   scripts/verify-all.sh
#
# Environment:
#   SKILL_SAMPLE_MAPPING   — passed through to verify-skill.sh for R-20
#   SKILLS_FIND_PROBE=1    — also run `npx skills find <name>` per skill
#                            and assert the name appears in the result.
#                            Used by CI (.github/workflows/verify.yml).

set -euo pipefail

repo_root="$(cd "$(dirname "$0")/.." && pwd)"
skills_dir="$repo_root/skills"
verify_script="$repo_root/scripts/verify-skill.sh"

[[ -d "$skills_dir" ]] || { echo "verify-all.sh: skills/ directory missing"; exit 1; }
[[ -x "$verify_script" ]] || { echo "verify-all.sh: scripts/verify-skill.sh not executable"; exit 1; }

worst=0
ok_count=0
fail_count=0

shopt -s nullglob
for skill in "$skills_dir"/*/; do
  skill="${skill%/}"
  if "$verify_script" "$skill"; then
    ok_count=$((ok_count + 1))
  else
    rc=$?
    fail_count=$((fail_count + 1))
    if (( rc > worst )); then worst=$rc; fi
  fi
done

# T046 — find-discoverability probe (SC-010). Disabled by default to keep
# local runs hermetic; CI sets SKILLS_FIND_PROBE=1.
if [[ "${SKILLS_FIND_PROBE:-0}" == "1" ]]; then
  echo "verify-all.sh: running upstream find-discoverability probe (SC-010)"
  for skill in "$skills_dir"/*/; do
    name="$(basename "${skill%/}")"
    if ! npx --yes skills find "$name" 2>/dev/null | grep -qE "(^|[[:space:]])${name}([[:space:]]|$)"; then
      echo "verify-all.sh: SC-010 FAIL — npx skills find did not surface '$name'" >&2
      fail_count=$((fail_count + 1))
      if (( 21 > worst )); then worst=21; fi
    fi
  done
fi

echo
echo "verify-all.sh: $ok_count passed, $fail_count failed"
exit "$worst"
