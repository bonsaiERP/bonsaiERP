DROP FUNCTION IF EXISTS common.lock_head(tname character varying);
DROP FUNCTION IF EXISTS common.lock_head(q_name character varying, top_boundary integer);
DROP TABLE IF EXISTS common.queue_classic_jobs;
