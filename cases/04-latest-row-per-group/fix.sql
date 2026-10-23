CREATE INDEX idx_events_shipment_happened
    ON tracking_events (shipment_id, happened_at DESC);
