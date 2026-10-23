# Results

PostgreSQL 16.15 (Ubuntu 16.15-0ubuntu0.24.04.1), 1,000,000 shipments, 4,000,000 tracking events. Median of 7 runs after one warm-up run (data in cache). Measured 2026-10-23 on x86_64 Linux.

| Case | Before | After | Faster | Buffers before → after | Same result |
|---|---:|---:|---:|---:|:---:|
| 01-missing-composite-index | 50.9 ms | 0.08 ms | 621× | 11,489 → 11 | yes |
| 02-function-on-indexed-column | 131.9 ms | 5.01 ms | 26× | 11,486 → 1,309 | yes |
| 03-deep-offset-pagination | 396.1 ms | 0.30 ms | 1,316× | 501,917 → 53 | yes |
| 04-latest-row-per-group | 350.0 ms | 0.41 ms | 860× | 35,655 → 119 | yes |
