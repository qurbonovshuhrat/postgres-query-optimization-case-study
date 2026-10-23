#!/usr/bin/env python3
"""Benchmark every case: slow query vs fixed query, median of N runs.

Uses the `psql` client. Connection comes from the usual PG* environment variables
(PGHOST, PGPORT, PGUSER, PGPASSWORD, PGDATABASE). With the bundled docker-compose:
    PGHOST=localhost PGPORT=5433 PGUSER=bench PGPASSWORD=bench PGDATABASE=shipping python bench/run.py
"""
import hashlib, json, os, statistics, subprocess, sys, pathlib, platform, datetime

ROOT = pathlib.Path(__file__).resolve().parent.parent
RUNS = int(os.environ.get("RUNS", "7"))
PSQL = os.environ.get("PSQL", "psql")


def psql(sql, vars=None, fmt_args=()):
    cmd = [PSQL, "-X", "-q", "-A", "-t", "-v", "ON_ERROR_STOP=1", *fmt_args]
    for k, v in (vars or {}).items():
        cmd += ["-v", f"{k}={v}"]
    out = subprocess.run(cmd, input="SET TIME ZONE 'UTC';\n" + sql, capture_output=True, text=True)
    if out.returncode:
        sys.exit(out.stderr)
    return out.stdout.strip()


def exec_ms(query, vars):
    plan = json.loads(psql(f"EXPLAIN (ANALYZE, BUFFERS, FORMAT JSON) {query}", vars))
    p = plan[0]
    buf = p["Plan"].get("Shared Hit Blocks", 0) + p["Plan"].get("Shared Read Blocks", 0)
    return p["Execution Time"], buf


def measure(query, vars):
    exec_ms(query, vars)  # warm-up (cache)
    runs = [exec_ms(query, vars) for _ in range(RUNS)]
    return statistics.median(r[0] for r in runs), runs[-1][1]


def result_hash(query, vars):
    return hashlib.md5(psql(query, vars).encode()).hexdigest()


def text_plan(query, vars):
    return psql(f"EXPLAIN (ANALYZE, BUFFERS, COSTS OFF, TIMING OFF) {query}", vars)


def main():
    results = []
    for case in sorted((ROOT / "cases").iterdir()):
        if not case.is_dir():
            continue
        psql((ROOT / "bench/reset.sql").read_text())
        if (case / "setup.sql").exists():
            psql((case / "setup.sql").read_text())
        psql("ANALYZE;")
        vars = {}
        if case.name.startswith("03"):
            ts, i = psql("SELECT created_at, id FROM shipments ORDER BY created_at DESC, id DESC OFFSET 499999 LIMIT 1").split("|")
            vars = {"last_ts": ts, "last_id": i}
        slow_q = (case / "slow.sql").read_text().strip().rstrip(";")
        fast_q = "\n".join(l for l in (case / "fast.sql").read_text().splitlines() if not l.startswith("--")).strip().rstrip(";")

        slow_ms, slow_buf = measure(slow_q, vars)
        slow_hash = result_hash(slow_q, vars)
        (ROOT / "results" / f"{case.name}-slow-plan.txt").write_text(text_plan(slow_q, vars) + "\n")

        psql((case / "fix.sql").read_text())
        psql("ANALYZE;")
        fast_ms, fast_buf = measure(fast_q, vars)
        fast_hash = result_hash(fast_q, vars)
        (ROOT / "results" / f"{case.name}-fast-plan.txt").write_text(text_plan(fast_q, vars) + "\n")

        same = "yes" if slow_hash == fast_hash else "NO"
        results.append((case.name, slow_ms, fast_ms, slow_buf, fast_buf, same))
        print(f"{case.name}: {slow_ms:.1f} ms -> {fast_ms:.2f} ms  (same result: {same})")

    version = psql("SHOW server_version;")
    rows = psql("SELECT (SELECT count(*) FROM shipments) || '|' || (SELECT count(*) FROM tracking_events)").split("|")
    lines = [
        "# Results", "",
        f"PostgreSQL {version}, {int(rows[0]):,} shipments, {int(rows[1]):,} tracking events. "
        f"Median of {RUNS} runs after one warm-up run (data in cache). "
        f"Measured {datetime.date.today().isoformat()} on {platform.machine()} {platform.system()}.", "",
        "| Case | Before | After | Faster | Buffers before → after | Same result |",
        "|---|---:|---:|---:|---:|:---:|",
    ]
    for name, s, f, sb, fb, same in results:
        lines.append(f"| {name} | {s:,.1f} ms | {f:,.2f} ms | {s/f:,.0f}× | {sb:,} → {fb:,} | {same} |")
    (ROOT / "results" / "results.md").write_text("\n".join(lines) + "\n")
    print("\nWritten results/results.md")


if __name__ == "__main__":
    main()
