-- Deterministic test data: 50k customers, 1M shipments, ~4M tracking events.
SELECT setseed(0.42) \gset

INSERT INTO customers (name, country, created_at)
SELECT 'Customer ' || g,
       (ARRAY['US','DE','GB','TR','UZ','KZ','PL','FR'])[1 + (g % 8)],
       timestamptz '2022-01-01' + (random() * interval '1000 days')
FROM generate_series(1, 50000) g;

INSERT INTO shipments (customer_id, status, origin_city, destination_city, weight_kg, price, created_at)
SELECT 1 + floor(random() * 50000)::bigint,
       CASE WHEN r < 0.70 THEN 'delivered' WHEN r < 0.90 THEN 'in_transit'
            WHEN r < 0.96 THEN 'created'   WHEN r < 0.99 THEN 'returned' ELSE 'lost' END,
       (ARRAY['Berlin','London','Istanbul','Tashkent','Almaty','Warsaw','Paris','Chicago'])[1 + floor(random()*8)::int],
       (ARRAY['Berlin','London','Istanbul','Tashkent','Almaty','Warsaw','Paris','Chicago'])[1 + floor(random()*8)::int],
       round((0.1 + random() * 30)::numeric, 2),
       round((5 + random() * 200)::numeric, 2),
       timestamptz '2024-01-01' + (random() * interval '730 days')
FROM (SELECT random() AS r FROM generate_series(1, 1000000)) s;

INSERT INTO tracking_events (shipment_id, event_type, location, happened_at)
SELECT s.id,
       (ARRAY['picked_up','sorted','departed','arrived','out_for_delivery','delivered'])[e],
       s.origin_city,
       s.created_at + (e * interval '9 hours') + (random() * interval '3 hours')
FROM shipments s
CROSS JOIN LATERAL generate_series(1, 2 + (s.id % 5)::int) e;

ANALYZE;
