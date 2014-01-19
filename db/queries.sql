SELECT u.id, u.email, u.last_sign_in_at, o.tenant FROM common.users u
JOIN common.links l ON (u.id = l.user_id)
JOIN common.organisations o ON (o.id = l.organisation_id)
ORDER BY o.tenant;
-- Dsiconect to drop database

UPDATE pg_database SET datallowconn = 'false' WHERE datname = 'bonsai_prod';
SELECT pg_terminate_backend(pid) FROM pg_stat_activity WHERE datname = 'bonsai_prod';
DROP DATABASE bonsai_prod;
