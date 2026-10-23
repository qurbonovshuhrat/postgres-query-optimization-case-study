# 3. Deep OFFSET pagination

**Problem.** An admin list pages through shipments with `OFFSET`. Page 10,000 means
PostgreSQL must read and throw away 500,000 rows before returning 50, even with an index.
The deeper the page, the slower it gets.

**Fix.** Keyset ("seek") pagination: remember the last row of the previous page and ask for
rows *after* it. Every page costs the same, whatever its number.
