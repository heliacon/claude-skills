#!/bin/bash
# Release gate for the plugin. Exits non-zero on any failure.
#   1. Private-reference scan (block list in scripts/blocklist.txt, kept out of the published tree).
#   2. Skill frontmatter: name = folder, only name/description/license, description under 400 chars, no < or >.
#   3. Size: every SKILL.md under 500 lines.
#   4. Agents: name + description present, every `craft:<skill>` they name exists.
#   5. Voice: no em or en dashes.
#   --calibrate: plants one defect of each kind in a copy and requires every check to fail.
set -u
ROOT="${1:-$(cd "$(dirname "$0")/.." && pwd)}"
[ "${1:-}" = "--calibrate" ] && ROOT="$(cd "$(dirname "$0")/.." && pwd)"
BLOCK="${BLOCKLIST:-$(dirname "$0")/blocklist.txt}"
fails=0
fail() { echo "  FAIL $*"; fails=$((fails+1)); }

check() {
  local R="$1"; fails=0
  local files; files=$(find "$R/skills" "$R/agents" -type f 2>/dev/null)
  # The README and manifests name the publisher on purpose; everything else in the block list still applies.
  local pub; pub=$(find "$R/README.md" "$R/ACKNOWLEDGEMENTS.md" "$R/.claude-plugin" -type f 2>/dev/null)

  # 1. private references
  if [ -f "$BLOCK" ]; then
    hits=$(echo "$files" | xargs grep -niE -f "$BLOCK" 2>/dev/null)
    [ -n "$hits" ] && { fail "private references:"; echo "$hits" | head -20 | sed 's/^/         /'; }
    if [ -n "$pub" ]; then
      hits=$(echo "$pub" | xargs grep -niE -f <(grep -viE '^heliacon$' "$BLOCK") 2>/dev/null)
      [ -n "$hits" ] && { fail "private references in published front matter:"; echo "$hits" | head -10 | sed 's/^/         /'; }
    fi
  else echo "  skip private-reference scan: no block list at $BLOCK (maintainers keep it outside the repo)"; fi

  # 2 + 3. skills
  n=0
  for d in "$R"/skills/*/; do
    n=$((n+1)); s="${d%/}"; name=$(basename "$s"); f="$s/SKILL.md"
    [ -f "$f" ] || { fail "$name: no SKILL.md"; continue; }
    fm=$(awk 'NR==1&&$0=="---"{on=1;next} on&&$0=="---"{exit} on' "$f")
    [ "$(head -1 "$f")" = "---" ] || fail "$name: no frontmatter"
    got=$(echo "$fm" | sed -n 's/^name: *//p')
    [ "$got" = "$name" ] || fail "$name: frontmatter name is '$got'"
    keys=$(echo "$fm" | grep -oE '^[a-zA-Z_-]+:' | tr -d ':' | sort | tr '\n' ' ')
    [ "$keys" = "description license name " ] || fail "$name: frontmatter keys are '$keys'"
    desc=$(python3 -c "import sys,yaml; print(yaml.safe_load(sys.argv[1])['description'])" "$fm" 2>/dev/null) \
      || { fail "$name: frontmatter is not valid YAML"; continue; }
    [ ${#desc} -lt 400 ] || fail "$name: description is ${#desc} chars"
    echo "$desc" | grep -q '[<>]' && fail "$name: description has < or >"
    echo "$desc" | grep -q '^Use when' || fail "$name: description does not start 'Use when'"
    lines=$(wc -l < "$f"); [ "$lines" -lt 500 ] || fail "$name: SKILL.md is $lines lines"
  done
  [ "$n" -gt 0 ] || fail "no skills found"

  # 4. agents
  for f in "$R"/agents/*.md; do
    a=$(basename "$f" .md)
    fm=$(awk 'NR==1&&$0=="---"{on=1;next} on&&$0=="---"{exit} on' "$f")
    echo "$fm" | grep -q '^name: ' || fail "agent $a: no name"
    echo "$fm" | grep -q '^description: ' || fail "agent $a: no description"
    python3 -c "import sys,yaml; yaml.safe_load(sys.argv[1])" "$fm" 2>/dev/null || fail "agent $a: frontmatter is not valid YAML"
    for s in $(grep -oE 'craft:[a-z0-9-]+' "$f" | sort -u | cut -d: -f2); do
      [ -f "$R/skills/$s/SKILL.md" ] || [ -f "$R/agents/$s.md" ] || fail "agent $a names craft:$s, which does not exist"
    done
  done

  # 5. voice
  dashes=$(echo "$files" | xargs grep -n "[—–]" 2>/dev/null)
  [ -n "$dashes" ] && { fail "em or en dashes:"; echo "$dashes" | head -5 | sed 's/^/         /'; }
  return $fails
}

if [ "${1:-}" = "--calibrate" ]; then
  missed=0
  plant() {   # label, shell edit run inside the copy
    tmp=$(mktemp -d); cp -R "$ROOT/skills" "$ROOT/agents" "$tmp/"
    (cd "$tmp" && eval "$2")
    if check "$tmp" >/dev/null; then echo "  MISS $1"; missed=$((missed+1)); else echo "  ok   $1 caught"; fi
    rm -rf "$tmp"
  }
  first=$(ls "$ROOT/skills" | head -1); agent=$(ls "$ROOT/agents" | head -1)
  word=$(grep -vE '[\\^$|()?*+]' "$BLOCK" | head -1)   # a plain word from the private list
  plant "private name"      "echo 'Ask $word first.' >> skills/$first/SKILL.md"
  plant "home path"         "echo 'See /Users/someone/x' >> skills/$first/SKILL.md"
  plant "name mismatch"     "sed -i '' 's/^name: $first\$/name: wrong/' skills/$first/SKILL.md"
  plant "extra key"         "sed -i '' '2a\\
model: opus
' skills/$first/SKILL.md"
  plant "missing skill"     "echo 'skills: [craft:no-such-skill]' >> agents/$agent"
  plant "em dash"           "echo 'a — b' >> skills/$first/SKILL.md"
  plant "bad yaml"          "sed -i '' 's/^description: .*/description: Use when x: y/' skills/$first/SKILL.md"
  plant "too long"          "for i in \$(seq 500); do echo x >> skills/$first/SKILL.md; done"
  [ "$missed" -eq 0 ] && echo "--- calibration PASS ---" || echo "--- calibration FAIL ($missed missed) ---"
  exit "$missed"
fi

check "$ROOT"; r=$?
[ "$r" -eq 0 ] && echo "--- release gate PASS ($(ls -d "$ROOT"/skills/*/ | wc -l | tr -d ' ') skills, $(ls "$ROOT"/agents/*.md | wc -l | tr -d ' ') agents) ---" \
  || echo "--- release gate FAIL ($r) ---"
exit "$r"
