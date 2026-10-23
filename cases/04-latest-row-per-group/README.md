# 4. Latest row per group (last tracking event)

**Problem.** For a customer's shipments we need each shipment's latest tracking event.
`tracking_events` has ~4M rows and no index on `shipment_id`, so the join reads all of it
and sorts the result to pick the last event.

**Fix.** An index on `(shipment_id, happened_at DESC)` plus a `LATERAL ... LIMIT 1` subquery:
for each shipment PostgreSQL reads exactly one index entry.
