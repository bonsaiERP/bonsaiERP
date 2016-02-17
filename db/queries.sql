SELECT u.id, u.email, u.last_sign_in_at, o.tenant FROM common.users u
JOIN common.links l ON (u.id = l.user_id)
JOIN common.organisations o ON (o.id = l.organisation_id)
ORDER BY o.tenant;
-- Dsiconect to drop database

UPDATE pg_database SET datallowconn = 'false' WHERE datname = 'bonsai_prod';
SELECT pg_terminate_backend(pid) FROM pg_stat_activity WHERE datname = 'bonsai_prod';
DROP DATABASE bonsai_prod;
CREATE DATABASE bonsai_prod;

-- Deleted unwated migrations in the past
DELETE FROM schema_migrations WHERE version IN ('20131211134555',
'20131221130149', '20131223155017', '20131224080216',
'20131224080916', '20131224081504', '20131227025934',
'20131227032328', '20131229164735', '20140105165519');




UPDATE accounts SET extras = CONCAT(extras::text, ',"invetory"=>"',
CASE WHEN COALESCE(extras->'no_inventory', 'false') = 'false' THEN 'true'
ELSE 'false' end, '"')::hstore
WHERE type IN ('Income', 'Expense');


-- Function to cast jsonb to hstore
create or replace function simple_jsonb_to_hstore(jdata jsonb)
returns hstore language sql
as $$
    select hstore(array_agg(key), array_agg(value))
    from jsonb_each_text(jdata)
$$;

ALTER TABLE common.organisations ALTER COLUMN settings TYPE hstore USING simple_jsonb_to_hstore(settings);


update accounts set extras
