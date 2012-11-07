
--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

--
-- Name: common; Type: SCHEMA; Schema: -; Owner: demo
--

CREATE SCHEMA common;


ALTER SCHEMA common OWNER TO demo;

SET search_path = common, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: queue_classic_jobs; Type: TABLE; Schema: common; Owner: demo; Tablespace: 
--

CREATE TABLE queue_classic_jobs (
    id integer NOT NULL,
    q_name character varying(255),
    method character varying(255),
    args text,
    locked_at timestamp with time zone
);


ALTER TABLE common.queue_classic_jobs OWNER TO demo;

--
-- Name: lock_head(character varying); Type: FUNCTION; Schema: common; Owner: demo
--

CREATE FUNCTION lock_head(tname character varying) RETURNS SETOF queue_classic_jobs
    LANGUAGE plpgsql
    AS $_$
BEGIN
  RETURN QUERY EXECUTE 'SELECT * FROM lock_head($1,10)' USING tname;
END;
$_$;


ALTER FUNCTION common.lock_head(tname character varying) OWNER TO demo;

--
-- Name: lock_head(character varying, integer); Type: FUNCTION; Schema: common; Owner: demo
--

CREATE FUNCTION lock_head(q_name character varying, top_boundary integer) RETURNS SETOF queue_classic_jobs
    LANGUAGE plpgsql
    AS $_$
DECLARE
  unlocked integer;
  relative_top integer;
  job_count integer;
BEGIN
  -- The purpose is to release contention for the first spot in the table.
  -- The select count(*) is going to slow down dequeue performance but allow
  -- for more workers. Would love to see some optimization here...

  EXECUTE 'SELECT count(*) FROM '
    || '(SELECT * FROM queue_classic_jobs WHERE q_name = '
    || quote_literal(q_name)
    || ' LIMIT '
    || quote_literal(top_boundary)
    || ') limited'
  INTO job_count;

  SELECT TRUNC(random() * (top_boundary - 1))
  INTO relative_top;

  IF job_count < top_boundary THEN
    relative_top = 0;
  END IF;

  LOOP
    BEGIN
      EXECUTE 'SELECT id FROM queue_classic_jobs '
        || ' WHERE locked_at IS NULL'
        || ' AND q_name = '
        || quote_literal(q_name)
        || ' ORDER BY id ASC'
        || ' LIMIT 1'
        || ' OFFSET ' || quote_literal(relative_top)
        || ' FOR UPDATE NOWAIT'
      INTO unlocked;
      EXIT;
    EXCEPTION
      WHEN lock_not_available THEN
        -- do nothing. loop again and hope we get a lock
    END;
  END LOOP;

  RETURN QUERY EXECUTE 'UPDATE queue_classic_jobs '
    || ' SET locked_at = (CURRENT_TIMESTAMP)'
    || ' WHERE id = $1'
    || ' AND locked_at is NULL'
    || ' RETURNING *'
  USING unlocked;

  RETURN;
END;
$_$;


ALTER FUNCTION common.lock_head(q_name character varying, top_boundary integer) OWNER TO demo;

--
-- Name: countries; Type: TABLE; Schema: common; Owner: demo; Tablespace: 
--

CREATE TABLE countries (
    id integer NOT NULL,
    name character varying(50),
    code character varying(5),
    abbreviation character varying(10),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


ALTER TABLE common.countries OWNER TO demo;

--
-- Name: countries_id_seq; Type: SEQUENCE; Schema: common; Owner: demo
--

CREATE SEQUENCE countries_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE common.countries_id_seq OWNER TO demo;

--
-- Name: countries_id_seq; Type: SEQUENCE OWNED BY; Schema: common; Owner: demo
--

ALTER SEQUENCE countries_id_seq OWNED BY countries.id;


--
-- Name: currencies; Type: TABLE; Schema: common; Owner: demo; Tablespace: 
--

CREATE TABLE currencies (
    id integer NOT NULL,
    name character varying(100),
    symbol character varying(20),
    code character varying(5),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


ALTER TABLE common.currencies OWNER TO demo;

--
-- Name: currencies_id_seq; Type: SEQUENCE; Schema: common; Owner: demo
--

CREATE SEQUENCE currencies_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE common.currencies_id_seq OWNER TO demo;

--
-- Name: currencies_id_seq; Type: SEQUENCE OWNED BY; Schema: common; Owner: demo
--

ALTER SEQUENCE currencies_id_seq OWNED BY currencies.id;


--
-- Name: links; Type: TABLE; Schema: common; Owner: demo; Tablespace: 
--

CREATE TABLE links (
    id integer NOT NULL,
    organisation_id integer,
    user_id integer,
    settings character varying(255),
    creator boolean DEFAULT false,
    master_account boolean DEFAULT false,
    rol character varying(50),
    active boolean DEFAULT true,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


ALTER TABLE common.links OWNER TO demo;

--
-- Name: links_id_seq; Type: SEQUENCE; Schema: common; Owner: demo
--

CREATE SEQUENCE links_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE common.links_id_seq OWNER TO demo;

--
-- Name: links_id_seq; Type: SEQUENCE OWNED BY; Schema: common; Owner: demo
--

ALTER SEQUENCE links_id_seq OWNED BY links.id;


--
-- Name: organisations; Type: TABLE; Schema: common; Owner: demo; Tablespace: 
--

CREATE TABLE organisations (
    id integer NOT NULL,
    country_id integer,
    currency_id integer,
    name character varying(100),
    address character varying(255),
    address_alt character varying(255),
    phone character varying(20),
    phone_alt character varying(20),
    mobile character varying(20),
    email character varying(255),
    website character varying(255),
    user_id integer,
    due_date date,
    preferences text,
    base_accounts boolean DEFAULT false,
    time_zone character varying(100),
    tenant character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    client_account_id integer DEFAULT 1
);


ALTER TABLE common.organisations OWNER TO demo;

--
-- Name: organisations_id_seq; Type: SEQUENCE; Schema: common; Owner: demo
--

CREATE SEQUENCE organisations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE common.organisations_id_seq OWNER TO demo;

--
-- Name: organisations_id_seq; Type: SEQUENCE OWNED BY; Schema: common; Owner: demo
--

ALTER SEQUENCE organisations_id_seq OWNED BY organisations.id;


--
-- Name: queue_classic_jobs_id_seq; Type: SEQUENCE; Schema: common; Owner: demo
--

CREATE SEQUENCE queue_classic_jobs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE common.queue_classic_jobs_id_seq OWNER TO demo;

--
-- Name: queue_classic_jobs_id_seq; Type: SEQUENCE OWNED BY; Schema: common; Owner: demo
--

ALTER SEQUENCE queue_classic_jobs_id_seq OWNED BY queue_classic_jobs.id;


--
-- Name: users; Type: TABLE; Schema: common; Owner: demo; Tablespace: 
--

CREATE TABLE users (
    id integer NOT NULL,
    email character varying(255),
    first_name character varying(80),
    last_name character varying(80),
    phone character varying(20),
    mobile character varying(20),
    website character varying(200),
    account_type character varying(15),
    description character varying(255),
    encrypted_password character varying(255),
    password_salt character varying(255),
    confirmation_token character varying(60),
    confirmation_sent_at timestamp without time zone,
    confirmed_at timestamp without time zone,
    reset_password_token character varying(255),
    reset_password_sent_at timestamp without time zone,
    reseted_password_at timestamp without time zone,
    sign_in_count integer DEFAULT 0,
    last_sign_in_at timestamp without time zone,
    abbreviation character varying(10),
    change_default_password boolean DEFAULT false,
    address character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    active boolean DEFAULT true,
    auth_token character varying(255)
);


ALTER TABLE common.users OWNER TO demo;

--
-- Name: users_id_seq; Type: SEQUENCE; Schema: common; Owner: demo
--

CREATE SEQUENCE users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE common.users_id_seq OWNER TO demo;

--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: common; Owner: demo
--

ALTER SEQUENCE users_id_seq OWNED BY users.id;


--
-- Name: id; Type: DEFAULT; Schema: common; Owner: demo
--

ALTER TABLE ONLY countries ALTER COLUMN id SET DEFAULT nextval('countries_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: common; Owner: demo
--

ALTER TABLE ONLY currencies ALTER COLUMN id SET DEFAULT nextval('currencies_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: common; Owner: demo
--

ALTER TABLE ONLY links ALTER COLUMN id SET DEFAULT nextval('links_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: common; Owner: demo
--

ALTER TABLE ONLY organisations ALTER COLUMN id SET DEFAULT nextval('organisations_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: common; Owner: demo
--

ALTER TABLE ONLY queue_classic_jobs ALTER COLUMN id SET DEFAULT nextval('queue_classic_jobs_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: common; Owner: demo
--

ALTER TABLE ONLY users ALTER COLUMN id SET DEFAULT nextval('users_id_seq'::regclass);


--
-- Name: countries_pkey; Type: CONSTRAINT; Schema: common; Owner: demo; Tablespace: 
--

ALTER TABLE ONLY countries
    ADD CONSTRAINT countries_pkey PRIMARY KEY (id);


--
-- Name: currencies_pkey; Type: CONSTRAINT; Schema: common; Owner: demo; Tablespace: 
--

ALTER TABLE ONLY currencies
    ADD CONSTRAINT currencies_pkey PRIMARY KEY (id);


--
-- Name: links_pkey; Type: CONSTRAINT; Schema: common; Owner: demo; Tablespace: 
--

ALTER TABLE ONLY links
    ADD CONSTRAINT links_pkey PRIMARY KEY (id);


--
-- Name: organisations_pkey; Type: CONSTRAINT; Schema: common; Owner: demo; Tablespace: 
--

ALTER TABLE ONLY organisations
    ADD CONSTRAINT organisations_pkey PRIMARY KEY (id);


--
-- Name: queue_classic_jobs_pkey; Type: CONSTRAINT; Schema: common; Owner: demo; Tablespace: 
--

ALTER TABLE ONLY queue_classic_jobs
    ADD CONSTRAINT queue_classic_jobs_pkey PRIMARY KEY (id);


--
-- Name: users_pkey; Type: CONSTRAINT; Schema: common; Owner: demo; Tablespace: 
--

ALTER TABLE ONLY users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: idx_qc_on_name_only_unlocked; Type: INDEX; Schema: common; Owner: demo; Tablespace: 
--

CREATE INDEX idx_qc_on_name_only_unlocked ON queue_classic_jobs USING btree (q_name, id) WHERE (locked_at IS NULL);


--
-- Name: index_common.links_on_organisation_id; Type: INDEX; Schema: common; Owner: demo; Tablespace: 
--

CREATE INDEX "index_common.links_on_organisation_id" ON links USING btree (organisation_id);


--
-- Name: index_common.links_on_user_id; Type: INDEX; Schema: common; Owner: demo; Tablespace: 
--

CREATE INDEX "index_common.links_on_user_id" ON links USING btree (user_id);


--
-- Name: index_common.organisations_on_client_account_id; Type: INDEX; Schema: common; Owner: demo; Tablespace: 
--

CREATE INDEX "index_common.organisations_on_client_account_id" ON organisations USING btree (client_account_id);


--
-- Name: index_common.organisations_on_country_id; Type: INDEX; Schema: common; Owner: demo; Tablespace: 
--

CREATE INDEX "index_common.organisations_on_country_id" ON organisations USING btree (country_id);


--
-- Name: index_common.organisations_on_currency_id; Type: INDEX; Schema: common; Owner: demo; Tablespace: 
--

CREATE INDEX "index_common.organisations_on_currency_id" ON organisations USING btree (currency_id);


--
-- Name: index_common.organisations_on_due_date; Type: INDEX; Schema: common; Owner: demo; Tablespace: 
--

CREATE INDEX "index_common.organisations_on_due_date" ON organisations USING btree (due_date);


--
-- Name: index_common.organisations_on_tenant; Type: INDEX; Schema: common; Owner: demo; Tablespace: 
--

CREATE UNIQUE INDEX "index_common.organisations_on_tenant" ON organisations USING btree (tenant);


--
-- Name: index_common.users_on_auth_token; Type: INDEX; Schema: common; Owner: demo; Tablespace: 
--

CREATE INDEX "index_common.users_on_auth_token" ON users USING btree (auth_token);


--
-- Name: index_common.users_on_confirmation_token; Type: INDEX; Schema: common; Owner: demo; Tablespace: 
--

CREATE UNIQUE INDEX "index_common.users_on_confirmation_token" ON users USING btree (confirmation_token);


--
-- Name: index_common.users_on_email; Type: INDEX; Schema: common; Owner: demo; Tablespace: 
--

CREATE INDEX "index_common.users_on_email" ON users USING btree (email);


--
-- Name: index_common.users_on_first_name; Type: INDEX; Schema: common; Owner: demo; Tablespace: 
--

CREATE INDEX "index_common.users_on_first_name" ON users USING btree (first_name);


--
-- Name: index_common.users_on_last_name; Type: INDEX; Schema: common; Owner: demo; Tablespace: 
--

CREATE INDEX "index_common.users_on_last_name" ON users USING btree (last_name);


--
-- PostgreSQL database dump complete
--
