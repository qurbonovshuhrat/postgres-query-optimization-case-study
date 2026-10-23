SELECT count(*), sum(price)
FROM shipments
WHERE date_trunc('day', created_at) = timestamptz '2025-03-15';
