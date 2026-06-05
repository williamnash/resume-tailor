#!/bin/bash
# Build a tailored resume and cover letter.
# Usage: ./tailored/make.sh company/date/role
# Example: ./tailored/make.sh acme/2026-06/backend-eng
#
# Outputs <prefix>-resume.pdf and (if cover.tex exists) <prefix>-cover.pdf
# in the application directory. Prefix defaults to "resume"; override with
# RESUME_PREFIX (e.g. RESUME_PREFIX=jrivera ./tailored/make.sh ...).

set -e

if [ -z "$1" ]; then
    echo "Usage: ./tailored/make.sh company/date/role"
    echo "Example: ./tailored/make.sh acme/2026-06/backend-eng"
    exit 1
fi

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

# Copy resume.cls into the application directory so pdflatex can find it.
# Trap cleanup so the .cls is removed even if pdflatex fails.
cp "${TAILORED_DIR}/../resume.cls" "${APP_DIR}/resume.cls"
trap 'rm -f "${APP_DIR}/resume.cls" "${APP_DIR}"/*.aux "${APP_DIR}"/*.log "${APP_DIR}"/*.out' EXIT

cd "$APP_DIR"

# Build resume
pdflatex -interaction=nonstopmode resume.tex >/dev/null
mv resume.pdf "${PREFIX}.pdf"
echo "Built: tailored/${1}/${PREFIX}.pdf"

# Build cover letter if it exists
if [ -f "cover.tex" ]; then
    pdflatex -interaction=nonstopmode cover.tex >/dev/null
    mv cover.pdf "${PREFIX}-cover.pdf"
    echo "Built: tailored/${1}/${PREFIX}-cover.pdf"
fi
