# Accomplishments

**This is your single source of truth for facts.** Every number, scope claim,
and technology on your resume originates here. The master resume
(`document.tex`) and every tailored resume link their bullets back to entries
in this file via `% id: <slug>` LaTeX comments.

Replace the example entries below with your own. Keep the structure: a level-3
heading with a backtick-wrapped slug ID, a **Tags** line, a **Facts** list, and
a **Resume phrasing** line (the exact text that goes on the resume).

## How to use this file

- **Adding a new bullet:** add an entry here first, then reference its ID in `document.tex`.
- **Editing a bullet:** update the resume phrasing here when you change it in `document.tex`.
- **Tailoring a resume:** pick relevant IDs by tag, copy bullets into the application's `resume.tex`, and preserve the `% id:` comments. Reword for the job's vocabulary if needed, but never introduce a fact that isn't in this file.
- **Numbers and scope claims:** must originate here. A resume can rephrase, abbreviate, or omit, but cannot invent.
- **Verify sync:** run `./check.sh` to flag orphan IDs.

## Wording standards (your truthfulness guardrails)

Use this section to record framing rules that must never be violated when
tailoring — phrasings that would cross from "true" into "misleading." Examples
of the *kind* of rule to add (replace with your own):

- *Ownership:* if you contributed a component to a team effort, do not write "led" or "owned" the whole project. Reserve strong ownership verbs for work you actually drove.
- *Titles:* do not inflate a title or imply "first/founding" status that isn't accurate.
- *LaTeX tilde:* use `$\sim$` (not `\textasciitilde`) for the "approximately" symbol.

---

# Awards & Credentials

### `award-hackathon`
**Tags:** award
**Year:** 2022
**Facts:**
- Won 1st place in a company-wide hackathon (out of ~30 teams).
- Built a real-time fraud-detection prototype over a weekend.
**Resume phrasing:** `Company-wide Hackathon, 1st place (real-time fraud-detection prototype)`

---

# Northwind Data — Jan 2021 to Present

**Title progression:** Software Engineer (Jan 2021 – Jun 2023) → Senior Software Engineer (Jun 2023 – Present).

### `northwind-pipeline`
**Tags:** distributed, streaming, data, performance
**Facts:**
- Designed and own a streaming ingestion pipeline on Kafka + Flink.
- Processes 2B+ events/day.
- Sub-second p99 end-to-end latency.
**Resume phrasing:** `Designed and own a streaming ingestion pipeline processing 2B+ events/day with sub-second p99 latency on Kafka and Flink.`

### `northwind-cost`
**Tags:** data, performance, cost
**Facts:**
- Cut data-warehouse compute spend 40% (measured over a quarter, Snowflake credits).
- Repartitioned hot tables; rewrote nightly aggregation jobs.
**Resume phrasing:** `Cut data-warehouse compute spend 40\% by repartitioning hot tables and rewriting the nightly aggregation jobs.`

### `northwind-oncall`
**Tags:** infra, observability, leadership
**Facts:**
- Led migration of 12 services to a unified observability stack (Prometheus + Grafana + structured logs).
- Reduced mean time to resolution from hours to minutes.
**Resume phrasing:** `Led migration of 12 services to a unified observability stack, reducing mean time to resolution from hours to minutes.`

---

# Acme Software — Jun 2017 to Dec 2020

### `acme-api`
**Tags:** api, backend, platform
**Facts:**
- Built a public REST and GraphQL API.
- Used by 300+ partner integrations.
- Versioning and backward-compatibility guarantees.
**Resume phrasing:** `Built a public REST/GraphQL API used by 300+ partner integrations, with versioning and backward-compatibility guarantees.`

### `acme-payments`
**Tags:** backend, payments, reliability
**Facts:**
- Implemented idempotent payment-reconciliation jobs.
- Handled $50M/month in transaction volume.
- Zero double-charges in production.
**Resume phrasing:** `Implemented idempotent payment-reconciliation jobs handling \$50M/month with zero double-charges in production.`

---

# Education

### `edu-state`
**Tags:** education
**Resume phrasing:** `BS in Computer Science, State University (May 2017)`

---

# Skills (rows on the resume Technical Skills table)

### `skills-languages`
**Resume phrasing:** `Go, Python, TypeScript, SQL`

### `skills-data`
**Resume phrasing:** `Kafka, Flink, Postgres, Snowflake, dbt, Airflow`

### `skills-infra`
**Resume phrasing:** `AWS, Kubernetes, Terraform, Docker, Prometheus, Grafana`
