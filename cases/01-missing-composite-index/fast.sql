SELECT id, status, destination_city, created_at
FROM shipments
WHERE customer_id = 12345 AND status = 'in_transit'
ORDER BY created_at DESC
LIMIT 20;
