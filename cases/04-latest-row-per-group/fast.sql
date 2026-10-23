SELECT s.id AS shipment_id, last.event_type, last.location, last.happened_at
FROM shipments s
CROSS JOIN LATERAL (
    SELECT e.event_type, e.location, e.happened_at
    FROM tracking_events e
    WHERE e.shipment_id = s.id
    ORDER BY e.happened_at DESC
    LIMIT 1
) last
WHERE s.customer_id = 777
ORDER BY s.id;
