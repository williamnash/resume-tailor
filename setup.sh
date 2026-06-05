#!/usr/bin/env bash
# One-command setup for Resume Tailor.
# Installs a LaTeX engine (tectonic — a single self-contained binary) if you
# don't already have one, checks Python, and builds the example to confirm it
# all works.
#
# Usage: ./setup.sh
set -euo pipefail

have() { command -v "$1" >/dev/null 2>&1; }

echo "== Resume Tailor setup =="

# 1. LaTeX engine ----------------------------------------------------------
if have tectonic; then
    echo "[ok] tectonic found: $(tectonic --version 2>/dev/null | head -1)"
elif have pdflatex; then
    echo "[ok] pdflatex found — builds will use it (tectonic is recommended but optional)."
else
    echo "[..] No LaTeX engine found. Installing tectonic (small, self-contained)…"
    if [ "$(uname -s)" = "Darwin" ] && have brew; then
        brew install tectonic
    else
        # Official installer drops a 'tectonic' binary into the current dir.
        mkdir -p "$HOME/.local/bin"
        ( cd "$HOME/.local/bin" && curl --proto '=https' --tlsv1.2 -fsSL https://drop-sh.fullyjustified.net | sh )
        echo "[ok] Installed tectonic to ~/.local/bin"
        case ":$PATH:" in
            *":$HOME/.local/bin:"*) ;;
            *) echo "    NOTE: add ~/.local/bin to your PATH:"
               echo "          export PATH=\"\$HOME/.local/bin:\$PATH\"" ;;
        esac
        export PATH="$HOME/.local/bin:$PATH"
    fi
fi

# 2. Python (only needed for tailored/jobs.py) -----------------------------
if have python3; then
    py="$(python3 -c 'import sys; print("%d.%d" % sys.version_info[:2])')"
    echo "[ok] python3 $py present (tailored/jobs.py needs 3.10+)"
else
    echo "[--] python3 not found — only needed for tailored/jobs.py (job-board search)."
fi

# 3. Build the example to confirm everything works -------------------------
echo "[..] Building the example resume…"
if ./make.sh; then
    echo
    echo "== Setup complete. =="
    echo "Next: replace the example content in document.tex + accomplishments.md"
    echo "with your own — or open Claude Code and ask it to populate them from"
    echo "your existing resume (see README)."
else
    echo "Build failed — see the log above." >&2
    exit 1
fi
