#!/bin/bash
# Build the master resume.
# Usage: ./make.sh
# Output: <prefix>-<YYYY-MM-DD>.pdf  (prefix defaults to "resume";
#         set RESUME_PREFIX to your name, e.g. RESUME_PREFIX=jrivera ./make.sh)
set -e
PREFIX="${RESUME_PREFIX:-resume}"
pdflatex -interaction=nonstopmode document.tex
mv document.pdf "${PREFIX}-$(date +%F).pdf"
echo "Built: ${PREFIX}-$(date +%F).pdf"
