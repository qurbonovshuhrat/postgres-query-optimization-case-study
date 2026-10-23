SELECT id, status, created_at
FROM shipments
ORDER BY created_at DESC, id DESC
OFFSET 500000 LIMIT 50;
