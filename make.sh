#!/bin/bash
# Build the master resume.
# Usage: ./make.sh
# Output: <prefix>-<YYYY-MM-DD>.pdf  (prefix defaults to "resume";
#         set RESUME_PREFIX to your name, e.g. RESUME_PREFIX=jrivera ./make.sh)
#
# Uses whichever LaTeX engine is installed: tectonic (preferred — single
# self-contained binary) or pdflatex. Run ./setup.sh if you have neither.
set -e

# Compile a .tex file in the current directory to <name>.pdf.
# Quiet on success; prints the full engine log only if compilation fails.
build_pdf() {
    local tex="$1" log
    log="$(mktemp)"
    if command -v tectonic >/dev/null 2>&1; then
        tectonic -X compile "$tex" >"$log" 2>&1 || { cat "$log"; rm -f "$log"; exit 1; }
    elif command -v pdflatex >/dev/null 2>&1; then
        pdflatex -interaction=nonstopmode "$tex" >"$log" 2>&1 || { cat "$log"; rm -f "$log"; exit 1; }
    else
        echo "error: no LaTeX engine found (looked for tectonic, pdflatex)." >&2
        echo "       Run ./setup.sh to install one." >&2
        exit 1
    fi
    rm -f "$log"
}

PREFIX="${RESUME_PREFIX:-resume}"
build_pdf document.tex
mv document.pdf "${PREFIX}-$(date +%F).pdf"
rm -f document.aux document.log document.out   # harmless if absent (tectonic keeps none)
echo "Built: ${PREFIX}-$(date +%F).pdf"
