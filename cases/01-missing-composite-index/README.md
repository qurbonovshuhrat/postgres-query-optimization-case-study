# 1. Missing composite index

**Problem.** The customer dashboard shows a customer's latest in-transit shipments.
Only the primary key exists, so PostgreSQL reads the whole `shipments` table and sorts it.

**Fix.** One composite index that matches the filter *and* the sort order:
`(customer_id, status, created_at DESC)`. PostgreSQL jumps straight to the right rows,
already in the right order, and stops after 20.
