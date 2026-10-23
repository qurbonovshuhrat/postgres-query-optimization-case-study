SELECT count(*), sum(price)
FROM shipments
WHERE created_at >= timestamptz '2025-03-15'
  AND created_at <  timestamptz '2025-03-16';
