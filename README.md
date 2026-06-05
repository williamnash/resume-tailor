# Resume Tailor

A LaTeX resume system designed to be driven by [Claude Code](https://claude.com/claude-code).
You keep your facts in one place, and Claude tailors your resume and writes a
cover letter for each job description you give it — without ever inventing
facts.

## How it works

- **`accomplishments.md`** is your single source of truth. Every number, scope
  claim, and technology lives here, each under a stable slug ID.
- **`document.tex`** is your master resume. Each bullet carries a `% id: <slug>`
  comment linking it back to an entry in `accomplishments.md`.
- When you paste a job description, Claude reads `CLAUDE.md`, maps your
  experience to the role, and writes a tailored resume + cover letter into
  `tailored/<company>/<YYYY-MM>/<role>/` — reordering and rephrasing your real
  accomplishments, never fabricating new ones.
- **`check.sh`** keeps the resume and the source of truth in sync.

## Setup

1. **Install a LaTeX distribution** (provides `pdflatex`):
   - macOS: `brew install --cask mactex-no-gui` (or BasicTeX)
   - Debian/Ubuntu: `sudo apt-get install texlive-latex-base texlive-latex-extra`
2. **Make the scripts executable:** `chmod +x make.sh check.sh tailored/make.sh`
3. **Build the example** to confirm LaTeX works: `./make.sh` → produces `resume-<date>.pdf`.
4. **Replace the example content with your own:**
   - Edit `document.tex`: your name, contact line, jobs, education, skills.
   - Edit `accomplishments.md`: one entry per fact/bullet, matching the
     `% id:` slugs you use in `document.tex`.
   - Keep `% id:` comments and slug IDs consistent between the two files.
5. **Run `./check.sh`** — it flags any bullet whose ID has no entry, and (if you
   keep `check-numbers.txt`) checks that load-bearing numbers stay in sync.

Tip: set `RESUME_PREFIX` to your name so output files are nicely named when you
send them, e.g. `RESUME_PREFIX=jrivera ./make.sh` → `jrivera-2026-06-05.pdf`.

## Tailoring a resume with Claude Code

From this repo, run `claude` and paste a job description. Claude will:
1. Parse the JD into requirements and keywords.
2. Map them to your `accomplishments.md` entries and flag gaps honestly.
3. Write `tailored/<company>/<YYYY-MM>/<role>/resume.tex` + `cover.tex` + `notes.md`.
4. Build with `./tailored/make.sh <company>/<YYYY-MM>/<role>`.

The full pipeline and rules are in `CLAUDE.md`.

## Finding open roles (optional)

`tailored/jobs.py` polls Greenhouse, Lever, Ashby, and Workable job boards for
companies you list in `tailored/companies.json`.

```bash
python tailored/jobs.py            # filtered by your companies.json "filters"
python tailored/jobs.py --all      # every role, no filters
python tailored/jobs.py --new      # only roles unseen since last run
```

Edit `tailored/companies.json` to set your target companies and your
location/role keyword filters. (It ships with a few real public boards so you
can run it immediately.)

## Layout

```
document.tex          master resume (replace with yours)
accomplishments.md    single source of truth for facts
resume.cls            LaTeX class (styling)
make.sh               build the master resume
check.sh              verify resume <-> accomplishments sync
check-numbers.txt     optional load-bearing numbers for check.sh
CLAUDE.md             pipeline instructions for Claude Code
tailored/
  make.sh             build a tailored resume + cover letter
  jobs.py             poll ATS job boards
  companies.json      your target companies + filters
  <company>/<date>/<role>/   one directory per application
```

## Customizing the look

Accent color, margins, and spacing live in `resume.cls`. Change
`\definecolor{primary}` / `\definecolor{accent}` near the top to recolor headers
and links.

## Privacy

This repo is meant to hold your real career history and job applications. If you
fork it, keep your fork **private**. PDFs, LaTeX build artifacts, and the
`jobs.py` seen-cache are git-ignored by default.
