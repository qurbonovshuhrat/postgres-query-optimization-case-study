-- Drop everything the cases create, so every case starts from the same state.
DO $$
DECLARE r record;
BEGIN
  FOR r IN SELECT indexname FROM pg_indexes WHERE schemaname='public' AND indexname LIKE 'idx\_%' LOOP
    EXECUTE format('DROP INDEX IF EXISTS %I', r.indexname);
  END LOOP;
  FOR r IN SELECT p.oid::regprocedure AS f FROM pg_proc p JOIN pg_namespace n ON n.oid=p.pronamespace
           WHERE n.nspname='public' AND p.proname LIKE 'search\_shipments%' LOOP
    EXECUTE format('DROP FUNCTION IF EXISTS %s', r.f);
  END LOOP;
END $$;
