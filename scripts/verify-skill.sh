#!/usr/bin/env bash
#
# verify-skill.sh — agentskills.io conformance check for one skill.
#
# Usage:
#   scripts/verify-skill.sh <skill-dir>
#
# Exit codes (see specs/001-react-pdf-kit-skills/contracts/conformance-check.md):
#   0   all rules pass
#   1   internal script error
#   10  R-10  SKILL.md missing or unreadable
#   11  R-11  frontmatter block missing or malformed YAML
#   12  R-12  required frontmatter field missing or wrong type
#   13  R-13  name != directory name
#   14  R-14  version range is not valid semver range
#   15  R-15  unknown frontmatter field present
#   16  R-16  body too long (>500 lines or >30,000 chars)
#   17  R-17  referenced supporting file does not exist
#   18  R-18  references/foo.md referenced without conditional trigger
#   19  R-19  deprecated_in set but body lacks "> **Deprecated**" banner
#   20  R-20  skill missing from Skill <-> Sample mapping
#         (only enforced when SKILL_SAMPLE_MAPPING env var points to a file)
#
# Dependencies:
#   - yq (https://github.com/mikefarah/yq) for YAML parsing
#   - node + npx semver (https://www.npmjs.com/package/semver) for range validation
#   - awk, sed, wc, grep (POSIX)

set -euo pipefail

die() {
  local code="$1"
  shift
  echo "verify-skill.sh: $*" >&2
  exit "$code"
}

[[ $# -eq 1 ]] || die 1 "usage: $0 <skill-dir>"

skill_dir="${1%/}"
[[ -d "$skill_dir" ]] || die 1 "<skill-dir> does not exist: $skill_dir"

skill_name="$(basename "$skill_dir")"
skill_md="$skill_dir/SKILL.md"

# ---------- R-10 ----------
[[ -f "$skill_md" && -r "$skill_md" ]] \
  || die 10 "R-10 $skill_md missing or unreadable"

# ---------- R-11: frontmatter present and parses ----------
# Frontmatter must begin on line 1 with '---' and end with a second '---'.
if ! head -n 1 "$skill_md" | grep -qx -- '---'; then
  die 11 "R-11 $skill_md: file does not begin with '---' frontmatter delimiter"
fi

# Extract the YAML between the first two '---' lines.
yaml_block="$(awk 'NR==1 && /^---$/ {inblock=1; next} inblock && /^---$/ {exit} inblock {print}' "$skill_md")"
[[ -n "$yaml_block" ]] || die 11 "R-11 $skill_md: frontmatter block is empty"

# Find closing delimiter.
closing_line="$(awk 'NR==1 && /^---$/ {inblock=1; next} inblock && /^---$/ {print NR; exit}' "$skill_md")"
[[ -n "$closing_line" ]] || die 11 "R-11 $skill_md: frontmatter has no closing '---' delimiter"

# Validate YAML parses via yq.
if ! command -v yq >/dev/null 2>&1; then
  die 1 "yq is required (brew install yq, or apt-get install yq, or see https://github.com/mikefarah/yq)"
fi
if ! printf '%s\n' "$yaml_block" | yq -e '.' >/dev/null 2>&1; then
  die 11 "R-11 $skill_md: frontmatter YAML failed to parse"
fi

# ---------- R-12: required fields present and correct types ----------
fm() { printf '%s\n' "$yaml_block" | yq -r "$1" 2>/dev/null; }

require_string() {
  local path="$1" value
  value="$(fm "$path")"
  if [[ "$value" == "null" || -z "$value" ]]; then
    die 12 "R-12 $skill_md: frontmatter field $path is missing"
  fi
  # yq returns scalar strings raw; if it's not a string, the type check
  # against `tag` should report a non-string.
  local kind
  kind="$(printf '%s\n' "$yaml_block" | yq -e "$path | tag" 2>/dev/null || true)"
  case "$kind" in
    '!!str'|'') ;; # OK
    *) die 12 "R-12 $skill_md: frontmatter field $path is not a string (got $kind)" ;;
  esac
}

require_string '.name'
require_string '.description'
require_string '.metadata.react_pdf_kit_version'
require_string '.metadata.pdfjs_dist_version'

name_value="$(fm '.name')"
description_value="$(fm '.description')"
rpk_range="$(fm '.metadata.react_pdf_kit_version')"
pdfjs_range="$(fm '.metadata.pdfjs_dist_version')"

# ---------- R-13: name equals directory name ----------
[[ "$name_value" == "$skill_name" ]] \
  || die 13 "R-13 $skill_md: frontmatter name='$name_value' but directory is '$skill_name'"

# ---------- R-14: semver ranges valid ----------
validate_semver_range() {
  local label="$1" range="$2"
  if ! command -v npx >/dev/null 2>&1; then
    die 1 "npx is required for semver range validation (install Node.js 18+)"
  fi
  # The `semver` CLI exits 0 if at least one probe version satisfies
  # the range, and prints the satisfying versions. We probe a wide
  # spread of versions so any reasonable range matches at least one.
  # An invalid range syntax causes `semver` to exit non-zero on every
  # probe.
  local probes=(0.0.1 0.5.0 1.0.0 1.5.0 2.0.0 2.7.0 4.10.38 5.4.530 10.0.0 100.0.0 999.999.999)
  if ! npx --yes semver -r "$range" "${probes[@]}" >/dev/null 2>&1; then
    die 14 "R-14 $skill_md: $label is not a valid semver range: '$range'"
  fi
}
validate_semver_range "metadata.react_pdf_kit_version" "$rpk_range"
validate_semver_range "metadata.pdfjs_dist_version" "$pdfjs_range"

# ---------- R-15: no unknown frontmatter keys ----------
allowed_top='name description metadata'
allowed_meta='react_pdf_kit_version pdfjs_dist_version frameworks tags deprecated_in internal'

actual_top="$(printf '%s\n' "$yaml_block" | yq -r 'keys | .[]' 2>/dev/null || true)"
while IFS= read -r k; do
  [[ -z "$k" ]] && continue
  if ! printf '%s\n' $allowed_top | grep -qx "$k"; then
    die 15 "R-15 $skill_md: unknown top-level frontmatter key '$k'"
  fi
done <<< "$actual_top"

actual_meta="$(printf '%s\n' "$yaml_block" | yq -r '.metadata | keys | .[]' 2>/dev/null || true)"
while IFS= read -r k; do
  [[ -z "$k" || "$k" == "null" ]] && continue
  if ! printf '%s\n' $allowed_meta | grep -qx "$k"; then
    die 15 "R-15 $skill_md: unknown metadata key 'metadata.$k'"
  fi
done <<< "$actual_meta"

# ---------- R-16: body length within budget ----------
body_start=$((closing_line + 1))
body="$(sed -n "${body_start},\$p" "$skill_md")"
body_lines="$(printf '%s' "$body" | wc -l | tr -d '[:space:]')"
body_chars="$(printf '%s' "$body" | wc -c | tr -d '[:space:]')"
if (( body_lines > 500 )); then
  die 16 "R-16 $skill_md: body is $body_lines lines (limit 500)"
fi
if (( body_chars > 30000 )); then
  die 16 "R-16 $skill_md: body is $body_chars chars (limit 30000)"
fi

# ---------- R-17 & R-18: referenced files exist + conditional triggers ----------
# Extract every token of the form references/<file>, assets/<file>, scripts/<file>.
# Use a portable while-read loop instead of mapfile (mapfile requires bash 4+;
# macOS ships bash 3.2).
# Match references/assets/scripts paths that look like real files —
# require a final ".<extension>" so prose URLs containing the literal
# strings "assets/" don't false-positive (e.g., the Vite asset URL
# example "/assets/pdf.worker.min-<hash>.mjs" must NOT be treated as
# a sibling reference). The path must also start at a token boundary, so a
# package path such as "@react-pdf-kit/viewer/dist/assets/pdf.worker.min.mjs"
# is not mistaken for this skill's own "assets/" folder.
refs_text="$(printf '%s\n' "$body" | grep -oE '(^|[^A-Za-z0-9._/-])(references|assets|scripts)/[A-Za-z0-9._/-]+\.[A-Za-z0-9]+' | sed -E 's#^[^rsa]##' | sort -u || true)"
while IFS= read -r ref; do
  [[ -z "$ref" ]] && continue
  ref_path="$skill_dir/$ref"
  if [[ ! -e "$ref_path" ]]; then
    die 17 "R-17 $skill_md: references nonexistent file '$ref'"
  fi
done <<< "$refs_text"

# R-18: every references/<file> mention must have a conditional trigger
# within 200 characters before or after.
while IFS= read -r ref; do
  [[ -z "$ref" ]] && continue
  case "$ref" in
    references/*)
      # Build a regex-safe pattern.
      esc="$(printf '%s' "$ref" | sed 's|/|\\/|g; s|\.|\\.|g')"
      # Slurp body as a single line for awk; check the 200 chars around
      # each mention contain a trigger phrase ("when", "if", "Read", "after").
      hit="$(awk -v RS= -v pat="$esc" '
        {
          for (i = 1; i <= length($0); ) {
            m = match(substr($0, i), pat)
            if (m == 0) break
            start = i + m - 1
            from = (start - 200 > 1 ? start - 200 : 1)
            to   = start + length(pat) + 200
            window = substr($0, from, to - from + 1)
            if (match(window, /(Read|read|When|when|If|if|After|after|Use|use this|see this).*'"$esc"'|'"$esc"'.*(when|if|after)/)) {
              print "OK"; exit
            }
            i = start + length(pat)
          }
        }' <<< "$body")"
      if [[ "$hit" != "OK" ]]; then
        die 18 "R-18 $skill_md: '$ref' mentioned without conditional trigger ('Read X when ...', 'if X fails see ...', etc.)"
      fi
      ;;
  esac
done <<< "$refs_text"

# ---------- R-19: deprecation banner ----------
deprecated_in="$(fm '.metadata.deprecated_in')"
if [[ "$deprecated_in" != "null" && -n "$deprecated_in" ]]; then
  first_nonblank="$(printf '%s' "$body" | awk '/^[^[:space:]]/ {print; exit}')"
  case "$first_nonblank" in
    '> **Deprecated**'*) ;;
    *)
      die 19 "R-19 $skill_md: metadata.deprecated_in set ('$deprecated_in') but body does not start with '> **Deprecated**' banner"
      ;;
  esac
fi

# ---------- R-20: Skill <-> Sample mapping (opt-in via env var) ----------
if [[ -n "${SKILL_SAMPLE_MAPPING:-}" ]]; then
  if [[ ! -f "$SKILL_SAMPLE_MAPPING" ]]; then
    die 1 "SKILL_SAMPLE_MAPPING points to a file that does not exist: $SKILL_SAMPLE_MAPPING"
  fi
  if ! grep -qE "\`$skill_name\`" "$SKILL_SAMPLE_MAPPING"; then
    die 20 "R-20 $skill_md: skill '$skill_name' is not listed in Skill <-> Sample mapping at $SKILL_SAMPLE_MAPPING"
  fi
else
  # R-20 is enforced in CI by setting SKILL_SAMPLE_MAPPING; locally it's
  # a soft-skip with a one-line notice so authors are aware.
  echo "verify-skill.sh: note: R-20 (Skill <-> Sample mapping) not enforced; set SKILL_SAMPLE_MAPPING=path/to/data-model.md to enable" >&2
fi

echo "verify-skill.sh: PASS $skill_dir"
exit 0
