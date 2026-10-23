CREATE INDEX idx_shipments_customer_status_created
    ON shipments (customer_id, status, created_at DESC);
