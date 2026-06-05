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

### Why two files (and what a "slug" is)

The resume is the *presentation*; `accomplishments.md` is the *facts*. Keeping
them separate means you write each fact once, and every tailored copy you ever
generate draws from that one vetted source — so a number can't drift or get
exaggerated across a dozen applications. The `% id: <slug>` comment is just a
short label (e.g. `northwind-pipeline`) that ties a resume bullet to the entry
it came from, so `check.sh` can confirm nothing on the resume is unsupported.
You rarely write these by hand — Claude wires them up for you (see Setup).

## Setup

**Prerequisite — install a LaTeX distribution** (provides `pdflatex`):
- macOS: `brew install --cask mactex-no-gui` (or the smaller BasicTeX)
- Debian/Ubuntu: `sudo apt-get install texlive-latex-base texlive-latex-extra`

This is a one-time, multi-GB install. If `./make.sh` later prints
`pdflatex: command not found`, this step is missing — the repo isn't broken. No
appetite for a local LaTeX install? You can paste `document.tex` + `resume.cls`
into [Overleaf](https://www.overleaf.com) and compile in the browser.

Confirm it works by building the example: `./make.sh` → produces
`resume-<date>.pdf` (one page).

**Then make it yours — the fast way (recommended):**

Open Claude Code in this repo and hand it your existing material:

> Here is my current resume / LinkedIn: \<paste text or attach a file\>.
> Replace the example content in `document.tex` and `accomplishments.md` with
> mine, keeping the `% id:` slugs in sync, and keep it to one page.

Claude populates both files together, matched IDs and all. Then run `./check.sh`
to confirm they're in sync.

**Or edit by hand (fallback):**
- Edit `document.tex`: your name, contact line, jobs, education, skills.
- Edit `accomplishments.md`: one entry per fact/bullet, matching the `% id:`
  slugs you use in `document.tex`.
- Replace **all** of the example content (the fictional "Jordan Rivera") so you
  never accidentally send an example resume.
- Run `./check.sh` — it flags any bullet whose ID has no entry, and (if you keep
  `check-numbers.txt`) checks that load-bearing numbers stay in sync.

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
companies you list in `tailored/companies.json`. Requires Python 3.10+ (no
third-party packages — standard library only).

```bash
python3 tailored/jobs.py            # filtered by your companies.json "filters"
python3 tailored/jobs.py --all      # every role, no filters
python3 tailored/jobs.py --new      # only roles unseen since last run
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
