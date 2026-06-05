#!/bin/bash
# Build a tailored resume and cover letter.
# Usage: ./tailored/make.sh company/date/role
# Example: ./tailored/make.sh acme/2026-06/backend-eng
#
# Outputs <prefix>.pdf and (if cover.tex exists) <prefix>-cover.pdf in the
# application directory. Prefix defaults to "resume"; override with
# RESUME_PREFIX (e.g. RESUME_PREFIX=jrivera ./tailored/make.sh ...).
#
# Uses tectonic (preferred) or pdflatex, whichever is installed.

set -e

if [ -z "$1" ]; then
    echo "Usage: ./tailored/make.sh company/date/role"
    echo "Example: ./tailored/make.sh acme/2026-06/backend-eng"
    exit 1
fi

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
TAILORED_DIR="$(cd "$(dirname "$0")" && pwd)"
APP_DIR="${TAILORED_DIR}/${1}"
RESUME_TEX="${APP_DIR}/resume.tex"

if [ ! -d "$APP_DIR" ]; then
    echo "Error: directory ${APP_DIR} not found"
    exit 1
fi

if [ ! -f "$RESUME_TEX" ]; then
    echo "Error: ${RESUME_TEX} not found"
    exit 1
fi

# Copy resume.cls into the application directory so the engine can find it.
# Trap cleanup so the .cls (and any aux files) are removed even on failure.
cp "${TAILORED_DIR}/../resume.cls" "${APP_DIR}/resume.cls"
trap 'rm -f "${APP_DIR}/resume.cls" "${APP_DIR}"/*.aux "${APP_DIR}"/*.log "${APP_DIR}"/*.out' EXIT

cd "$APP_DIR"

# Build resume (engine produces resume.pdf; rename only if the target differs)
build_pdf resume.tex
[ "${PREFIX}.pdf" = "resume.pdf" ] || mv resume.pdf "${PREFIX}.pdf"
echo "Built: tailored/${1}/${PREFIX}.pdf"

# Build cover letter if it exists
if [ -f "cover.tex" ]; then
    build_pdf cover.tex
    mv cover.pdf "${PREFIX}-cover.pdf"
    echo "Built: tailored/${1}/${PREFIX}-cover.pdf"
fi
