-- Schema for a parcel delivery service: customers, shipments, tracking events.
DROP TABLE IF EXISTS tracking_events, shipments, customers CASCADE;

CREATE TABLE customers (
    id          bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name        text        NOT NULL,
    country     char(2)     NOT NULL,
    created_at  timestamptz NOT NULL
);

CREATE TABLE shipments (
    id              bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    customer_id     bigint      NOT NULL REFERENCES customers(id),
    status          text        NOT NULL,      -- created / in_transit / delivered / returned / lost
    origin_city     text        NOT NULL,
    destination_city text       NOT NULL,
    weight_kg       numeric(8,2) NOT NULL,
    price           numeric(10,2) NOT NULL,
    created_at      timestamptz NOT NULL
);

CREATE TABLE tracking_events (
    id           bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    shipment_id  bigint      NOT NULL REFERENCES shipments(id),
    event_type   text        NOT NULL,
    location     text        NOT NULL,
    happened_at  timestamptz NOT NULL
);
-- Deliberately only primary keys at the start: the cases add the indexes they need.
