# Resume Tailor

## Overview
A LaTeX-based resume system designed to be driven by Claude Code. The master
resume is `document.tex`; the LaTeX class is `resume.cls`. All factual content
lives in `accomplishments.md` and is linked to the resume via stable IDs. Given
a job description, Claude tailors a copy of the resume and writes a cover letter
into a self-contained directory under `tailored/`.

> **First-time setup:** see `README.md`. Replace the example content in
> `document.tex` and `accomplishments.md` with your own, then this pipeline
> works for you.

## Source of truth: `accomplishments.md`

All factual content (numbers, scope, technologies, outcomes) originates in
`accomplishments.md`. Each entry has a stable slug ID, e.g. `northwind-pipeline`.
The master resume and tailored resumes reference entries via `% id: <slug>`
LaTeX comments above each bullet.

**When editing the resume:**
- Adding a new bullet → add (or update) an entry in `accomplishments.md` first, then reference its ID in the `.tex`.
- Reading a bullet's facts → check the entry in `accomplishments.md`.
- Numbers and scope claims → must originate in `accomplishments.md`. The resume can rephrase, abbreviate, or omit, but cannot introduce new facts.
- Run `./check.sh` to verify there are no orphan IDs and that load-bearing numbers stay in sync.

**Truthfulness is non-negotiable.** Never fabricate, exaggerate, or
misrepresent experience. Only reframe and reorder existing truthful content. If
you find yourself wanting to add a fact not in `accomplishments.md`, ask the
user first and update the file. The "Wording standards" section of
`accomplishments.md` records framing rules the user has set — honor them.

## LaTeX Notes
- **Tilde/approximately:** Use `$\sim$` for the approximation symbol (e.g., `$\sim$75\%`). Do NOT use `\textasciitilde` — it renders as a raised tilde that looks broken in this document class.
- **ID comments:** every bullet, education entry, skills row, and award gets a `% id: <slug>` line directly above it. LaTeX ignores the comment; `check.sh` reads it.
- **Single page.** Keep the master and all tailored resumes to one page. Comment out lower-priority sections (e.g. Leadership) as needed.

## Job Application Pipeline

When the user provides a job description (JD), follow this pipeline.

### Step 1: Parse the JD
Extract and list:
- **Company name & role title**
- **Must-have skills** (explicitly required)
- **Nice-to-have skills** (preferred/bonus)
- **Key responsibilities** (day-to-day work)
- **Domain/industry keywords** (e.g., "fintech", "climate", "healthcare")
- **Seniority signals** (team lead? IC? architecture ownership?)

### Step 2: Map the user's experience
Read `accomplishments.md`. For each JD requirement, identify which entries map
to it (filter by tags). Flag any gaps honestly — do NOT fabricate experience.

### Step 3: Tailor the resume
Create a modified copy saved as `tailored/[company]/[YYYY-MM]/[role]/resume.tex`:
1. **Summary**: Rewrite to directly address the role. Lead with the most relevant identity.
2. **Bullet points**: Reorder bullets within each job to put the most JD-relevant ones first. **Preserve `% id:` comments** as you reorder. Swap in alternate bullets from `accomplishments.md` when they fit the JD better. Reword to echo JD language where accurate, but every fact must trace back to an `accomplishments.md` entry.
3. **Technical skills**: Reorder rows to put JD-relevant ones first. Trim or expand items within rows.
4. **Awards/Publications**: Keep, trim, or comment out depending on the role.

### Step 4: Write the cover letter
Save as `tailored/[company]/[YYYY-MM]/[role]/cover.tex` using the template below.

Structure:
1. **Opening** (2-3 sentences): Why this company/role specifically. Reference something concrete about the company.
2. **Body paragraph 1**: The most relevant experience mapped to their top requirements. Use specific numbers and outcomes.
3. **Body paragraph 2**: Secondary strengths that add unique value.
4. **Closing** (2-3 sentences): Enthusiasm + call to action.

Tone: Confident but not arrogant. Technical but readable. Show genuine interest.
(If the user has recorded voice/style preferences, follow them.)

### Step 5: Review
Present to the user:
- Summary of what was changed and why (cite the `accomplishments.md` IDs swapped in/out)
- Any gaps between JD requirements and the user's experience (with suggestions for how to address them in interviews)
- The tailored resume and cover letter for review

## File Structure
- `accomplishments.md` — single source of truth for facts; entries identified by stable slug IDs
- `document.tex` — master resume; do not modify during tailoring
- `resume.cls` — LaTeX class file
- `make.sh` — build script for the master resume
- `check.sh` — verifies sync between `document.tex` and `accomplishments.md`
- `check-numbers.txt` — optional list of load-bearing numbers for `check.sh`
- `tailored/make.sh` — build script for tailored resumes
- `tailored/jobs.py` — polls ATS job boards listed in `tailored/companies.json`
- `tailored/companies.json` — your target companies + location/role filters
- `tailored/` — job-specific application directories

## Tailored Output Convention

Each job application is a self-contained directory under `tailored/`:

```
tailored/
  make.sh
  [company]/
    [YYYY-MM]/
      [role]/
        resume.tex        # tailored resume (standalone copy of document.tex)
        cover.tex         # cover letter (LaTeX)
        notes.md          # gap analysis + interview prep
```

Naming: lowercase, hyphen-separated. The date is when the application was prepared.
Example: `tailored/acme/2026-06/backend-eng/resume.tex`

### Rules for tailored files
1. **Copy, don't import.** Each `.tex` is a full standalone copy of `document.tex`, so edits to one never affect another or the master.
2. **Never modify `document.tex` or `accomplishments.md`** during the tailoring pipeline. Those change only when the user explicitly asks for base-resume changes.
3. **Preserve `% id:` comments** when reordering or swapping bullets.
4. **Allowed:** rewrite the summary, reorder bullets, reword bullets (truthfully, traceable to an entry), swap in alternate bullets, comment sections in/out, reorder skills.
5. **Forbidden:** fabricating experience, inflating numbers, adding skills the user doesn't have, introducing facts not in `accomplishments.md`.
6. **Single page.**

### Cover letter format
LaTeX `article` class with a header matching the resume. ~300 words. The build
script (`tailored/make.sh`) compiles both the resume and cover letter PDFs.

Template structure:
```latex
\documentclass[10pt]{article}
\usepackage[top=0.4in, bottom=0.4in, left=0.7in, right=0.7in]{geometry}
\usepackage{hyperref}
\usepackage[parfill]{parskip}
\pagestyle{empty}

\begin{document}

% Header matching resume style
\begingroup
\hfil{\MakeUppercase{\huge\bfseries Your Name}}\hfil
\smallskip\break
\endgroup
\begingroup
\parfillskip=0pt plus 1fil
\noindent\makebox[\textwidth]{(555) 123-4567 $\diamond$ you@example.com $\diamond$ \href{https://example.com}{example.com}}
\par
\endgroup

\vspace{1em}
\hrule
\vspace{1.5em}

Dear [Hiring Team],

[Opening paragraph]

[Body paragraph 1]

[Body paragraph 2]

[Closing paragraph]

\vspace{1em}
Sincerely,\\
Your Name

\end{document}
```

### Notes file
The `notes.md` in each application directory captures:
- What was changed and why (cite the `accomplishments.md` IDs swapped in/out)
- Gaps between JD and the user's experience
- Suggested talking points for interviews
- Company-specific research (mission, recent news, team info)

## Build

**Master resume:** `./make.sh` — compiles `document.tex`, outputs `resume-YYYY-MM-DD.pdf` (set `RESUME_PREFIX` to change the filename prefix).

**Tailored resume:** `./tailored/make.sh [company]/[date]/[role]` — compiles `resume.tex` and `cover.tex` (if present), outputting `resume.pdf` and `resume-cover.pdf` alongside the source (or `<prefix>.pdf` / `<prefix>-cover.pdf` if `RESUME_PREFIX` is set).

**Sync check:** `./check.sh` — verifies every `% id:` in `document.tex` matches an entry in `accomplishments.md` and that load-bearing numbers (from `check-numbers.txt`) appear in both. Run before committing.

**Find open roles:** `python tailored/jobs.py` — polls the ATS boards listed in `tailored/companies.json`.
