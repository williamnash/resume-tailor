#!/bin/bash
# Verify sync between document.tex and accomplishments.md.
# Reports:
#   1. IDs in document.tex with no matching entry in accomplishments.md (error)
#   2. IDs in accomplishments.md not used in document.tex (informational —
#      these are alternate bullets available for tailoring)
#   3. Load-bearing numbers in document.tex that don't appear in
#      accomplishments.md (only if a check-numbers.txt file is present)
#
# Usage: ./check.sh
#
# Optional: create check-numbers.txt with one load-bearing number/string per
# line (e.g. "2B+", "40\%", "\$50M"). Each is checked to ensure that if it
# appears in document.tex, the fact behind it also appears in accomplishments.md.

set -e

ROOT="$(cd "$(dirname "$0")" && pwd)"
TEX="${ROOT}/document.tex"
ACC="${ROOT}/accomplishments.md"
NUMS="${ROOT}/check-numbers.txt"

if [ ! -f "$TEX" ] || [ ! -f "$ACC" ]; then
    echo "error: document.tex or accomplishments.md not found"
    exit 1
fi

# Extract IDs from "% id: <slug>" comments in the .tex
tex_ids=$(grep -oE '% id: [a-z0-9-]+' "$TEX" | awk '{print $3}' | sort -u)

# Extract IDs from "### `<slug>`" headers in accomplishments.md
acc_ids=$(grep -oE '^### `[a-z0-9-]+`' "$ACC" | sed 's/^### `//; s/`$//' | sort -u)

status=0

# 1. IDs in tex but missing from accomplishments
echo "== orphan IDs in document.tex (no matching entry in accomplishments.md) =="
orphans=$(comm -23 <(echo "$tex_ids") <(echo "$acc_ids"))
if [ -z "$orphans" ]; then
    echo "  (none)"
else
    echo "$orphans" | sed 's/^/  /'
    status=1
fi

# 2. IDs in accomplishments.md not referenced in document.tex (informational)
echo
echo "== accomplishments entries not on master resume (informational; available for tailoring) =="
unused=$(comm -13 <(echo "$tex_ids") <(echo "$acc_ids"))
if [ -z "$unused" ]; then
    echo "  (none — every entry is on the master)"
else
    echo "$unused" | sed 's/^/  /'
fi

# 3. Optional number spot-check. Dash variants (--, –, —) normalized to "-".
if [ -f "$NUMS" ]; then
    echo
    echo "== load-bearing numbers in document.tex present in accomplishments.md? =="
    acc_normalized=$(sed -E 's/(--|–|—)/-/g' "$ACC")
    while IFS= read -r n; do
        [ -z "$n" ] && continue
        case "$n" in \#*) continue;; esac   # allow comments in check-numbers.txt
        if grep -qF "$n" "$TEX"; then
            normalized=$(echo "$n" | sed -E 's/(--|–|—)/-/g')
            if echo "$acc_normalized" | grep -qF "$normalized"; then
                echo "  ok   $n"
            else
                echo "  MISS $n  (in document.tex but not accomplishments.md)"
                status=1
            fi
        fi
    done < "$NUMS"
fi

echo
if [ "$status" -eq 0 ]; then
    echo "sync: ok"
else
    echo "sync: issues found (exit 1)"
fi
exit "$status"
