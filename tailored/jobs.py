#!/usr/bin/env python3
"""Poll ATS APIs for open roles at target companies.

Reads tailored/companies.json (registry + filters) and prints relevant open roles.

Configure your target companies and location/role filters in
tailored/companies.json. Supports Greenhouse, Lever, Ashby, and Workable boards.

Usage:
  python tailored/jobs.py                 # filtered by companies.json "filters"
  python tailored/jobs.py --all           # no filters
  python tailored/jobs.py --new           # only roles unseen since last run
  python tailored/jobs.py --company acme  # restrict to one company (substring match)
  python tailored/jobs.py --tier 1        # restrict to tier 1
  python tailored/jobs.py --json          # raw JSON output
"""

from __future__ import annotations

import argparse
import json
import re
import sys
import urllib.error
import urllib.request
from concurrent.futures import ThreadPoolExecutor, as_completed
from dataclasses import asdict, dataclass
from pathlib import Path

ROOT = Path(__file__).parent
REGISTRY = ROOT / "companies.json"
CACHE = ROOT / ".jobs_seen.json"
TIMEOUT = 10


@dataclass
class Job:
    company: str
    title: str
    location: str
    url: str
    department: str = ""
    tier: int = 0
    domain: str = ""

    @property
    def key(self) -> str:
        return f"{self.company}::{self.title}::{self.location}"


def fetch_json(url: str, post_body: dict | None = None) -> dict | list:
    headers = {"User-Agent": "jobs.py/1.0", "Accept": "application/json"}
    data = None
    if post_body is not None:
        headers["Content-Type"] = "application/json"
        data = json.dumps(post_body).encode()
    req = urllib.request.Request(url, data=data, headers=headers)
    with urllib.request.urlopen(req, timeout=TIMEOUT) as r:
        return json.loads(r.read())


def from_greenhouse(c: dict) -> list[Job]:
    url = f"https://boards-api.greenhouse.io/v1/boards/{c['slug']}/jobs"
    data = fetch_json(url)
    out = []
    for j in data.get("jobs", []):
        out.append(Job(
            company=c["name"],
            title=j["title"],
            location=j.get("location", {}).get("name", ""),
            url=j.get("absolute_url", ""),
            department=", ".join(d.get("name", "") for d in j.get("departments", [])),
            tier=c.get("tier", 0),
            domain=c.get("domain", ""),
        ))
    return out


def from_lever(c: dict) -> list[Job]:
    url = f"https://api.lever.co/v0/postings/{c['slug']}?mode=json"
    data = fetch_json(url)
    out = []
    for j in data:
        cats = j.get("categories", {}) or {}
        out.append(Job(
            company=c["name"],
            title=j.get("text", ""),
            location=cats.get("location", "") or cats.get("allLocations", [""])[0] if cats.get("allLocations") else cats.get("location", ""),
            url=j.get("hostedUrl", ""),
            department=cats.get("team", "") or cats.get("department", ""),
            tier=c.get("tier", 0),
            domain=c.get("domain", ""),
        ))
    return out


def from_ashby(c: dict) -> list[Job]:
    url = f"https://api.ashbyhq.com/posting-api/job-board/{c['slug']}"
    data = fetch_json(url)
    out = []
    for j in data.get("jobs", []):
        out.append(Job(
            company=c["name"],
            title=j.get("title", ""),
            location=j.get("location", ""),
            url=j.get("jobUrl", ""),
            department=j.get("department", "") or j.get("team", ""),
            tier=c.get("tier", 0),
            domain=c.get("domain", ""),
        ))
    return out


def from_workable(c: dict) -> list[Job]:
    url = f"https://apply.workable.com/api/v3/accounts/{c['slug']}/jobs"
    data = fetch_json(url, post_body={})
    out = []
    for j in data.get("results", []):
        loc = j.get("location", {}) or {}
        loc_str = ", ".join(filter(None, [loc.get("city", ""), loc.get("region", ""), loc.get("country", "")]))
        out.append(Job(
            company=c["name"],
            title=j.get("title", ""),
            location=loc_str,
            url=f"https://apply.workable.com/{c['slug']}/j/{j.get('shortcode', '')}/",
            department=j.get("department", "") or "",
            tier=c.get("tier", 0),
            domain=c.get("domain", ""),
        ))
    return out


ADAPTERS = {
    "greenhouse": from_greenhouse,
    "lever": from_lever,
    "ashby": from_ashby,
    "workable": from_workable,
}


def fetch_company(c: dict) -> tuple[str, list[Job], str | None]:
    try:
        adapter = ADAPTERS[c["ats"]]
        return (c["name"], adapter(c), None)
    except (urllib.error.URLError, urllib.error.HTTPError, json.JSONDecodeError, KeyError) as e:
        return (c["name"], [], f"{type(e).__name__}: {e}")


def matches(text: str, keywords: list[str]) -> bool:
    t = text.lower()
    return any(k.lower() in t for k in keywords)


def filter_jobs(jobs: list[Job], filters: dict, *, all_jobs: bool, no_role_filter: bool) -> list[Job]:
    if all_jobs:
        return jobs
    loc_kw = filters["location_keywords"]
    role_kw = filters["role_keywords"]
    excl_kw = filters["exclude_keywords"]
    out = []
    for j in jobs:
        loc_text = j.location or ""
        title_text = j.title or ""
        if loc_text and not matches(loc_text, loc_kw):
            continue
        if matches(title_text, excl_kw):
            continue
        if not no_role_filter and not matches(title_text, role_kw):
            continue
        out.append(j)
    return out


def load_cache() -> set[str]:
    if not CACHE.exists():
        return set()
    return set(json.loads(CACHE.read_text()).get("seen", []))


def save_cache(jobs: list[Job]) -> None:
    CACHE.write_text(json.dumps({"seen": sorted({j.key for j in jobs})}, indent=2))


def render_markdown(jobs: list[Job], new_keys: set[str]) -> str:
    if not jobs:
        return "_No matching roles right now._"
    by_company: dict[str, list[Job]] = {}
    for j in jobs:
        by_company.setdefault(j.company, []).append(j)
    out = []
    for company in sorted(by_company.keys(), key=lambda c: (by_company[c][0].tier, c)):
        cjobs = by_company[company]
        domain = cjobs[0].domain
        tier = cjobs[0].tier
        out.append(f"\n### {company} _(tier {tier}, {domain})_ — {len(cjobs)} role{'s' if len(cjobs) != 1 else ''}")
        for j in sorted(cjobs, key=lambda x: x.title):
            new_marker = " 🆕" if j.key in new_keys else ""
            loc = j.location or "—"
            out.append(f"- [{j.title}]({j.url}) — {loc}{new_marker}")
    return "\n".join(out)


def main() -> int:
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument("--all", action="store_true", help="No filters — show every role")
    p.add_argument("--new", action="store_true", help="Only roles new since last run")
    p.add_argument("--no-role-filter", action="store_true", help="Skip role-keyword filter, keep location filter")
    p.add_argument("--company", help="Substring-match a single company")
    p.add_argument("--tier", type=int, help="Restrict to a tier (1, 2, 3)")
    p.add_argument("--json", action="store_true", help="Output JSON instead of markdown")
    p.add_argument("--no-save", action="store_true", help="Don't update the seen-cache")
    args = p.parse_args()

    registry = json.loads(REGISTRY.read_text())
    companies = registry["companies"]
    if args.company:
        companies = [c for c in companies if args.company.lower() in c["name"].lower()]
    if args.tier is not None:
        companies = [c for c in companies if c.get("tier") == args.tier]

    if not companies:
        print("No companies match those filters.", file=sys.stderr)
        return 1

    all_jobs: list[Job] = []
    errors: list[str] = []
    with ThreadPoolExecutor(max_workers=8) as ex:
        futures = {ex.submit(fetch_company, c): c for c in companies}
        for f in as_completed(futures):
            name, jobs, err = f.result()
            if err:
                errors.append(f"{name}: {err}")
            all_jobs.extend(jobs)

    filtered = filter_jobs(all_jobs, registry["filters"], all_jobs=args.all, no_role_filter=args.no_role_filter)

    seen = load_cache()
    current_keys = {j.key for j in filtered}
    new_keys = current_keys - seen if seen else set()

    if args.new:
        filtered = [j for j in filtered if j.key in new_keys]

    if args.json:
        print(json.dumps([asdict(j) for j in filtered], indent=2))
    else:
        total_raw = len(all_jobs)
        total_filt = len(filtered)
        header = f"# Open roles ({total_filt} matching / {total_raw} total across {len(companies)} companies)"
        if new_keys and not args.new:
            header += f" — {len(new_keys & {j.key for j in filtered})} new since last run"
        print(header)
        print(render_markdown(filtered, new_keys))
        if errors:
            print("\n---\n_Errors:_")
            for e in errors:
                print(f"- {e}")
        manual = registry.get("manual_watch", [])
        if manual and not args.company and args.tier is None:
            print("\n---\n_Manual watch (no supported ATS — check by hand):_")
            for m in manual:
                note = f" — {m['note']}" if m.get("note") else ""
                print(f"- [{m['name']}]({m['url']}) _(tier {m.get('tier', '?')}, {m.get('domain', '')})_{note}")

    if not args.no_save and not args.new:
        save_cache(filtered)

    return 0


if __name__ == "__main__":
    sys.exit(main())
