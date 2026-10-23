SELECT DISTINCT ON (e.shipment_id)
       e.shipment_id, e.event_type, e.location, e.happened_at
FROM tracking_events e
JOIN shipments s ON s.id = e.shipment_id
WHERE s.customer_id = 777
ORDER BY e.shipment_id, e.happened_at DESC;
