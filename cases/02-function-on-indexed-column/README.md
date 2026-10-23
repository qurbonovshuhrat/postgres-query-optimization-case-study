# 2. Function on an indexed column

**Problem.** There *is* an index on `created_at`, but the report wraps the column in
`date_trunc('day', ...)`. PostgreSQL can't use a plain index on an expression it has to
compute for every row, so it scans the whole table.

**Fix.** Rewrite the condition as a half-open range on the raw column.
Same result, and the existing index is used. No new index needed.
