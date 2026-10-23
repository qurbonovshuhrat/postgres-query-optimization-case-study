-- :last_ts / :last_id = created_at and id of the last row on the previous page
SELECT id, status, created_at
FROM shipments
WHERE (created_at, id) < (:'last_ts'::timestamptz, :last_id)
ORDER BY created_at DESC, id DESC
LIMIT 50;
