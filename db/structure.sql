--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

--
-- Name: bonsai; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA bonsai;


--
-- Name: common; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA common;


--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


SET search_path = common, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: queue_classic_jobs; Type: TABLE; Schema: common; Owner: -; Tablespace: 
--

CREATE TABLE queue_classic_jobs (
    id integer NOT NULL,
    q_name character varying(255),
    method character varying(255),
    args text,
    locked_at timestamp with time zone
);


--
-- Name: lock_head(character varying); Type: FUNCTION; Schema: common; Owner: -
--

CREATE FUNCTION lock_head(tname character varying) RETURNS SETOF queue_classic_jobs
    LANGUAGE plpgsql
    AS $_$
BEGIN
  RETURN QUERY EXECUTE 'SELECT * FROM lock_head($1,10)' USING tname;
END;
$_$;


--
-- Name: lock_head(character varying, integer); Type: FUNCTION; Schema: common; Owner: -
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


SET search_path = bonsai, pg_catalog;

--
-- Name: account_balances; Type: TABLE; Schema: bonsai; Owner: -; Tablespace: 
--

CREATE TABLE account_balances (
    id integer NOT NULL,
    user_id integer,
    contact_id integer,
    account_id integer,
    currency_id integer,
    amount numeric(14,4),
    old_amount numeric(14,2),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: account_balances_id_seq; Type: SEQUENCE; Schema: bonsai; Owner: -
--

CREATE SEQUENCE account_balances_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: account_balances_id_seq; Type: SEQUENCE OWNED BY; Schema: bonsai; Owner: -
--

ALTER SEQUENCE account_balances_id_seq OWNED BY account_balances.id;


--
-- Name: account_ledger_details; Type: TABLE; Schema: bonsai; Owner: -; Tablespace: 
--

CREATE TABLE account_ledger_details (
    id integer NOT NULL,
    account_id integer,
    account_ledger_id integer,
    currency_id integer,
    related_id integer,
    amount numeric(14,2),
    exchange_rate numeric(14,4),
    description character varying(255),
    active boolean DEFAULT true,
    state character varying(20),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: account_ledger_details_id_seq; Type: SEQUENCE; Schema: bonsai; Owner: -
--

CREATE SEQUENCE account_ledger_details_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: account_ledger_details_id_seq; Type: SEQUENCE OWNED BY; Schema: bonsai; Owner: -
--

ALTER SEQUENCE account_ledger_details_id_seq OWNED BY account_ledger_details.id;


--
-- Name: account_ledgers; Type: TABLE; Schema: bonsai; Owner: -; Tablespace: 
--

CREATE TABLE account_ledgers (
    id integer NOT NULL,
    reference character varying(255),
    currency_id integer,
    account_id integer,
    to_id integer,
    date date,
    operation character varying(20),
    conciliation boolean DEFAULT true,
    amount numeric(14,2),
    exchange_rate numeric(14,4),
    interests_penalties numeric(14,2) DEFAULT 0,
    description character varying(255),
    transaction_id integer,
    creator_id integer,
    approver_id integer,
    approver_datetime timestamp without time zone,
    nuller_id integer,
    nuller_datetime timestamp without time zone,
    active boolean DEFAULT true,
    has_error boolean DEFAULT false,
    error_messages character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    account_balance numeric(14,2),
    to_balance numeric(14,2),
    contact_id integer,
    staff_id integer,
    due_date date,
    inverse boolean DEFAULT false,
    project_id integer,
    transaction_type character varying(30),
    status character varying(255) DEFAULT 'none'::character varying
);


--
-- Name: account_ledgers_id_seq; Type: SEQUENCE; Schema: bonsai; Owner: -
--

CREATE SEQUENCE account_ledgers_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: account_ledgers_id_seq; Type: SEQUENCE OWNED BY; Schema: bonsai; Owner: -
--

ALTER SEQUENCE account_ledgers_id_seq OWNED BY account_ledgers.id;


--
-- Name: account_types; Type: TABLE; Schema: bonsai; Owner: -; Tablespace: 
--

CREATE TABLE account_types (
    id integer NOT NULL,
    name character varying(255),
    number character varying(255),
    account_number character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: account_types_id_seq; Type: SEQUENCE; Schema: bonsai; Owner: -
--

CREATE SEQUENCE account_types_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: account_types_id_seq; Type: SEQUENCE OWNED BY; Schema: bonsai; Owner: -
--

ALTER SEQUENCE account_types_id_seq OWNED BY account_types.id;


--
-- Name: accounts; Type: TABLE; Schema: bonsai; Owner: -; Tablespace: 
--

CREATE TABLE accounts (
    id integer NOT NULL,
    currency_id integer,
    account_type_id integer,
    accountable_id integer,
    accountable_type character varying(255),
    original_type character varying(20),
    name character varying(255),
    type character varying(20),
    amount numeric(14,2),
    initial_amount numeric(14,2),
    number character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: accounts_id_seq; Type: SEQUENCE; Schema: bonsai; Owner: -
--

CREATE SEQUENCE accounts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: accounts_id_seq; Type: SEQUENCE OWNED BY; Schema: bonsai; Owner: -
--

ALTER SEQUENCE accounts_id_seq OWNED BY accounts.id;


--
-- Name: contacts; Type: TABLE; Schema: bonsai; Owner: -; Tablespace: 
--

CREATE TABLE contacts (
    id integer NOT NULL,
    matchcode character varying(255),
    first_name character varying(100),
    organisation_name character varying(100),
    address character varying(250),
    address_alt character varying(250),
    phone character varying(20),
    mobile character varying(20),
    email character varying(200),
    tax_number character varying(30),
    aditional_info character varying(250),
    code character varying(255),
    type character varying(255),
    last_name character varying(100),
    "position" character varying(255),
    active boolean DEFAULT true,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: contacts_id_seq; Type: SEQUENCE; Schema: bonsai; Owner: -
--

CREATE SEQUENCE contacts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: contacts_id_seq; Type: SEQUENCE OWNED BY; Schema: bonsai; Owner: -
--

ALTER SEQUENCE contacts_id_seq OWNED BY contacts.id;


--
-- Name: inventory_operation_details; Type: TABLE; Schema: bonsai; Owner: -; Tablespace: 
--

CREATE TABLE inventory_operation_details (
    id integer NOT NULL,
    inventory_operation_id integer,
    item_id integer,
    quantity numeric(14,2),
    unitary_cost numeric(14,2),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    store_id integer,
    contact_id integer,
    transaction_id integer,
    operation character varying(10)
);


--
-- Name: inventory_operation_details_id_seq; Type: SEQUENCE; Schema: bonsai; Owner: -
--

CREATE SEQUENCE inventory_operation_details_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: inventory_operation_details_id_seq; Type: SEQUENCE OWNED BY; Schema: bonsai; Owner: -
--

ALTER SEQUENCE inventory_operation_details_id_seq OWNED BY inventory_operation_details.id;


--
-- Name: inventory_operations; Type: TABLE; Schema: bonsai; Owner: -; Tablespace: 
--

CREATE TABLE inventory_operations (
    id integer NOT NULL,
    store_id integer,
    transaction_id integer,
    date date,
    ref_number character varying(255),
    operation character varying(10),
    state character varying(255),
    description character varying(255),
    total numeric(14,2),
    has_error boolean DEFAULT false,
    error_messages character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    contact_id integer,
    creator_id integer,
    transference_id integer,
    store_to_id integer,
    project_id integer
);


--
-- Name: inventory_operations_id_seq; Type: SEQUENCE; Schema: bonsai; Owner: -
--

CREATE SEQUENCE inventory_operations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: inventory_operations_id_seq; Type: SEQUENCE OWNED BY; Schema: bonsai; Owner: -
--

ALTER SEQUENCE inventory_operations_id_seq OWNED BY inventory_operations.id;


--
-- Name: items; Type: TABLE; Schema: bonsai; Owner: -; Tablespace: 
--

CREATE TABLE items (
    id integer NOT NULL,
    unit_id integer,
    unitary_cost numeric(14,2),
    price numeric(14,2) DEFAULT 0,
    name character varying(255),
    description character varying(255),
    code character varying(100),
    "integer" boolean DEFAULT false,
    stockable boolean DEFAULT false,
    active boolean DEFAULT true,
    discount character varying(255),
    ctype character varying(20),
    type character varying(255),
    un_name character varying(255),
    un_symbol character varying(10),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    for_sale boolean DEFAULT true
);


--
-- Name: items_id_seq; Type: SEQUENCE; Schema: bonsai; Owner: -
--

CREATE SEQUENCE items_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: items_id_seq; Type: SEQUENCE OWNED BY; Schema: bonsai; Owner: -
--

ALTER SEQUENCE items_id_seq OWNED BY items.id;


--
-- Name: money_stores; Type: TABLE; Schema: bonsai; Owner: -; Tablespace: 
--

CREATE TABLE money_stores (
    id integer NOT NULL,
    currency_id integer,
    type character varying(30),
    name character varying(100),
    number character varying(30),
    address character varying(255),
    website character varying(255),
    phone character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: money_stores_id_seq; Type: SEQUENCE; Schema: bonsai; Owner: -
--

CREATE SEQUENCE money_stores_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: money_stores_id_seq; Type: SEQUENCE OWNED BY; Schema: bonsai; Owner: -
--

ALTER SEQUENCE money_stores_id_seq OWNED BY money_stores.id;


--
-- Name: pay_plans; Type: TABLE; Schema: bonsai; Owner: -; Tablespace: 
--

CREATE TABLE pay_plans (
    id integer NOT NULL,
    transaction_id integer,
    currency_id integer,
    cur character varying(255),
    amount numeric(14,2),
    interests_penalties numeric(14,2),
    due_date date,
    alert_date date,
    email boolean DEFAULT true,
    ctype character varying(20),
    description character varying(255),
    paid boolean DEFAULT false,
    operation character varying(20),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    project_id integer
);


--
-- Name: pay_plans_id_seq; Type: SEQUENCE; Schema: bonsai; Owner: -
--

CREATE SEQUENCE pay_plans_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: pay_plans_id_seq; Type: SEQUENCE OWNED BY; Schema: bonsai; Owner: -
--

ALTER SEQUENCE pay_plans_id_seq OWNED BY pay_plans.id;


--
-- Name: payments; Type: TABLE; Schema: bonsai; Owner: -; Tablespace: 
--

CREATE TABLE payments (
    id integer NOT NULL,
    transaction_id integer,
    ctype character varying(255),
    date date,
    amount numeric(14,2),
    interests_penalties numeric(14,2),
    description character varying(255),
    account_id integer,
    account_ledger_id integer,
    contact_id integer,
    active boolean DEFAULT true,
    state character varying(20),
    exchange_rate numeric(14,4),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: payments_id_seq; Type: SEQUENCE; Schema: bonsai; Owner: -
--

CREATE SEQUENCE payments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: payments_id_seq; Type: SEQUENCE OWNED BY; Schema: bonsai; Owner: -
--

ALTER SEQUENCE payments_id_seq OWNED BY payments.id;


--
-- Name: prices; Type: TABLE; Schema: bonsai; Owner: -; Tablespace: 
--

CREATE TABLE prices (
    id integer NOT NULL,
    item_id integer,
    unitary_cost numeric(14,2),
    price numeric(14,2),
    discount character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: prices_id_seq; Type: SEQUENCE; Schema: bonsai; Owner: -
--

CREATE SEQUENCE prices_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: prices_id_seq; Type: SEQUENCE OWNED BY; Schema: bonsai; Owner: -
--

ALTER SEQUENCE prices_id_seq OWNED BY prices.id;


--
-- Name: projects; Type: TABLE; Schema: bonsai; Owner: -; Tablespace: 
--

CREATE TABLE projects (
    id integer NOT NULL,
    name character varying(255),
    active boolean DEFAULT true,
    date_start date,
    date_end date,
    description text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: projects_id_seq; Type: SEQUENCE; Schema: bonsai; Owner: -
--

CREATE SEQUENCE projects_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: projects_id_seq; Type: SEQUENCE OWNED BY; Schema: bonsai; Owner: -
--

ALTER SEQUENCE projects_id_seq OWNED BY projects.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: bonsai; Owner: -; Tablespace: 
--

CREATE TABLE schema_migrations (
    version character varying(255) NOT NULL
);


--
-- Name: stocks; Type: TABLE; Schema: bonsai; Owner: -; Tablespace: 
--

CREATE TABLE stocks (
    id integer NOT NULL,
    store_id integer,
    item_id integer,
    state character varying(20),
    unitary_cost numeric(14,2),
    quantity numeric(14,2),
    minimum numeric(14,2),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    user_id integer
);


--
-- Name: stocks_id_seq; Type: SEQUENCE; Schema: bonsai; Owner: -
--

CREATE SEQUENCE stocks_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: stocks_id_seq; Type: SEQUENCE OWNED BY; Schema: bonsai; Owner: -
--

ALTER SEQUENCE stocks_id_seq OWNED BY stocks.id;


--
-- Name: stores; Type: TABLE; Schema: bonsai; Owner: -; Tablespace: 
--

CREATE TABLE stores (
    id integer NOT NULL,
    name character varying(255),
    address character varying(255),
    phone character varying(255),
    active boolean DEFAULT true,
    description character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: stores_id_seq; Type: SEQUENCE; Schema: bonsai; Owner: -
--

CREATE SEQUENCE stores_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: stores_id_seq; Type: SEQUENCE OWNED BY; Schema: bonsai; Owner: -
--

ALTER SEQUENCE stores_id_seq OWNED BY stores.id;


--
-- Name: taxes; Type: TABLE; Schema: bonsai; Owner: -; Tablespace: 
--

CREATE TABLE taxes (
    id integer NOT NULL,
    name character varying(255),
    abbreviation character varying(10),
    rate numeric(5,2),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: taxes_id_seq; Type: SEQUENCE; Schema: bonsai; Owner: -
--

CREATE SEQUENCE taxes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: taxes_id_seq; Type: SEQUENCE OWNED BY; Schema: bonsai; Owner: -
--

ALTER SEQUENCE taxes_id_seq OWNED BY taxes.id;


--
-- Name: taxes_transactions; Type: TABLE; Schema: bonsai; Owner: -; Tablespace: 
--

CREATE TABLE taxes_transactions (
    tax_id integer,
    transaction_id integer
);


--
-- Name: transaction_details; Type: TABLE; Schema: bonsai; Owner: -; Tablespace: 
--

CREATE TABLE transaction_details (
    id integer NOT NULL,
    transaction_id integer,
    item_id integer,
    currency_id integer,
    quantity numeric(14,2),
    price numeric(14,2),
    description character varying(255),
    ctype character varying(30),
    discount numeric(14,2),
    balance numeric(14,2),
    original_price numeric(14,2),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    delivered numeric(14,2) DEFAULT 0
);


--
-- Name: transaction_details_id_seq; Type: SEQUENCE; Schema: bonsai; Owner: -
--

CREATE SEQUENCE transaction_details_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: transaction_details_id_seq; Type: SEQUENCE OWNED BY; Schema: bonsai; Owner: -
--

ALTER SEQUENCE transaction_details_id_seq OWNED BY transaction_details.id;


--
-- Name: transaction_histories; Type: TABLE; Schema: bonsai; Owner: -; Tablespace: 
--

CREATE TABLE transaction_histories (
    id integer NOT NULL,
    transaction_id integer,
    user_id integer,
    data text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: transaction_histories_id_seq; Type: SEQUENCE; Schema: bonsai; Owner: -
--

CREATE SEQUENCE transaction_histories_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: transaction_histories_id_seq; Type: SEQUENCE OWNED BY; Schema: bonsai; Owner: -
--

ALTER SEQUENCE transaction_histories_id_seq OWNED BY transaction_histories.id;


--
-- Name: transactions; Type: TABLE; Schema: bonsai; Owner: -; Tablespace: 
--

CREATE TABLE transactions (
    id integer NOT NULL,
    account_id integer,
    type character varying(20),
    total numeric(14,2),
    balance numeric(14,2),
    tax_percent numeric(5,2),
    active boolean DEFAULT true,
    description character varying(255),
    state character varying(20),
    date date,
    ref_number character varying(255),
    bill_number character varying(255),
    currency_id integer,
    exchange_rate numeric(14,4),
    project_id integer,
    discount numeric(5,2),
    gross_total numeric(14,2),
    cash boolean DEFAULT true,
    due_date date,
    balance_inventory numeric(14,2),
    creator_id integer,
    approver_id integer,
    approver_datetime timestamp without time zone,
    approver_reason character varying(255),
    creditor_id integer,
    credit_reference character varying(255),
    credit_datetime timestamp without time zone,
    credit_description character varying(500),
    has_error boolean DEFAULT false,
    error_messages character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    deliver boolean DEFAULT false,
    deliver_datetime timestamp without time zone,
    deliver_approver_id integer,
    deliver_reason character varying(255),
    nuller_id integer,
    nuller_datetime timestamp without time zone,
    contact_id integer,
    delivered boolean DEFAULT false,
    original_total numeric(14,2),
    discounted boolean DEFAULT false,
    modified_by integer,
    fact boolean DEFAULT true,
    devolution boolean DEFAULT false
);


--
-- Name: transactions_id_seq; Type: SEQUENCE; Schema: bonsai; Owner: -
--

CREATE SEQUENCE transactions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: transactions_id_seq; Type: SEQUENCE OWNED BY; Schema: bonsai; Owner: -
--

ALTER SEQUENCE transactions_id_seq OWNED BY transactions.id;


--
-- Name: units; Type: TABLE; Schema: bonsai; Owner: -; Tablespace: 
--

CREATE TABLE units (
    id integer NOT NULL,
    name character varying(100),
    symbol character varying(20),
    "integer" boolean DEFAULT false,
    visible boolean DEFAULT true,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: units_id_seq; Type: SEQUENCE; Schema: bonsai; Owner: -
--

CREATE SEQUENCE units_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: units_id_seq; Type: SEQUENCE OWNED BY; Schema: bonsai; Owner: -
--

ALTER SEQUENCE units_id_seq OWNED BY units.id;


SET search_path = common, pg_catalog;

--
-- Name: countries; Type: TABLE; Schema: common; Owner: -; Tablespace: 
--

CREATE TABLE countries (
    id integer NOT NULL,
    name character varying(50),
    code character varying(5),
    abbreviation character varying(10),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: countries_id_seq; Type: SEQUENCE; Schema: common; Owner: -
--

CREATE SEQUENCE countries_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: countries_id_seq; Type: SEQUENCE OWNED BY; Schema: common; Owner: -
--

ALTER SEQUENCE countries_id_seq OWNED BY countries.id;


--
-- Name: currencies; Type: TABLE; Schema: common; Owner: -; Tablespace: 
--

CREATE TABLE currencies (
    id integer NOT NULL,
    name character varying(100),
    symbol character varying(20),
    code character varying(5),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: currencies_id_seq; Type: SEQUENCE; Schema: common; Owner: -
--

CREATE SEQUENCE currencies_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: currencies_id_seq; Type: SEQUENCE OWNED BY; Schema: common; Owner: -
--

ALTER SEQUENCE currencies_id_seq OWNED BY currencies.id;


--
-- Name: links; Type: TABLE; Schema: common; Owner: -; Tablespace: 
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


--
-- Name: links_id_seq; Type: SEQUENCE; Schema: common; Owner: -
--

CREATE SEQUENCE links_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: links_id_seq; Type: SEQUENCE OWNED BY; Schema: common; Owner: -
--

ALTER SEQUENCE links_id_seq OWNED BY links.id;


--
-- Name: organisations; Type: TABLE; Schema: common; Owner: -; Tablespace: 
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


--
-- Name: organisations_id_seq; Type: SEQUENCE; Schema: common; Owner: -
--

CREATE SEQUENCE organisations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: organisations_id_seq; Type: SEQUENCE OWNED BY; Schema: common; Owner: -
--

ALTER SEQUENCE organisations_id_seq OWNED BY organisations.id;


--
-- Name: queue_classic_jobs_id_seq; Type: SEQUENCE; Schema: common; Owner: -
--

CREATE SEQUENCE queue_classic_jobs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: queue_classic_jobs_id_seq; Type: SEQUENCE OWNED BY; Schema: common; Owner: -
--

ALTER SEQUENCE queue_classic_jobs_id_seq OWNED BY queue_classic_jobs.id;


--
-- Name: users; Type: TABLE; Schema: common; Owner: -; Tablespace: 
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


--
-- Name: users_id_seq; Type: SEQUENCE; Schema: common; Owner: -
--

CREATE SEQUENCE users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: common; Owner: -
--

ALTER SEQUENCE users_id_seq OWNED BY users.id;


SET search_path = public, pg_catalog;

--
-- Name: account_balances; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE account_balances (
    id integer NOT NULL,
    user_id integer,
    contact_id integer,
    account_id integer,
    currency_id integer,
    amount numeric(14,4),
    old_amount numeric(14,2),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: account_balances_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE account_balances_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: account_balances_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE account_balances_id_seq OWNED BY account_balances.id;


--
-- Name: account_ledger_details; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE account_ledger_details (
    id integer NOT NULL,
    account_id integer,
    account_ledger_id integer,
    currency_id integer,
    related_id integer,
    amount numeric(14,2),
    exchange_rate numeric(14,4),
    description character varying(255),
    active boolean DEFAULT true,
    state character varying(20),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: account_ledger_details_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE account_ledger_details_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: account_ledger_details_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE account_ledger_details_id_seq OWNED BY account_ledger_details.id;


--
-- Name: account_ledgers; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE account_ledgers (
    id integer NOT NULL,
    reference character varying(255),
    currency_id integer,
    account_id integer,
    to_id integer,
    date date,
    operation character varying(20),
    conciliation boolean DEFAULT true,
    amount numeric(14,2),
    exchange_rate numeric(14,4),
    interests_penalties numeric(14,2) DEFAULT 0,
    description character varying(255),
    transaction_id integer,
    creator_id integer,
    approver_id integer,
    approver_datetime timestamp without time zone,
    nuller_id integer,
    nuller_datetime timestamp without time zone,
    active boolean DEFAULT true,
    has_error boolean DEFAULT false,
    error_messages character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    account_balance numeric(14,2),
    to_balance numeric(14,2),
    contact_id integer,
    staff_id integer,
    due_date date,
    inverse boolean DEFAULT false,
    project_id integer,
    transaction_type character varying(30),
    status character varying(255) DEFAULT 'none'::character varying
);


--
-- Name: account_ledgers_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE account_ledgers_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: account_ledgers_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE account_ledgers_id_seq OWNED BY account_ledgers.id;


--
-- Name: account_types; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE account_types (
    id integer NOT NULL,
    name character varying(255),
    number character varying(255),
    account_number character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: account_types_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE account_types_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: account_types_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE account_types_id_seq OWNED BY account_types.id;


--
-- Name: accounts; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE accounts (
    id integer NOT NULL,
    currency_id integer,
    account_type_id integer,
    accountable_id integer,
    accountable_type character varying(255),
    original_type character varying(20),
    name character varying(255),
    type character varying(20),
    amount numeric(14,2),
    initial_amount numeric(14,2),
    number character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: accounts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE accounts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: accounts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE accounts_id_seq OWNED BY accounts.id;


--
-- Name: contacts; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE contacts (
    id integer NOT NULL,
    matchcode character varying(255),
    first_name character varying(100),
    organisation_name character varying(100),
    address character varying(250),
    address_alt character varying(250),
    phone character varying(20),
    mobile character varying(20),
    email character varying(200),
    tax_number character varying(30),
    aditional_info character varying(250),
    code character varying(255),
    type character varying(255),
    last_name character varying(100),
    "position" character varying(255),
    active boolean DEFAULT true,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: contacts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE contacts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: contacts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE contacts_id_seq OWNED BY contacts.id;


--
-- Name: inventory_operation_details; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE inventory_operation_details (
    id integer NOT NULL,
    inventory_operation_id integer,
    item_id integer,
    quantity numeric(14,2),
    unitary_cost numeric(14,2),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    store_id integer,
    contact_id integer,
    transaction_id integer,
    operation character varying(10)
);


--
-- Name: inventory_operation_details_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE inventory_operation_details_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: inventory_operation_details_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE inventory_operation_details_id_seq OWNED BY inventory_operation_details.id;


--
-- Name: inventory_operations; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE inventory_operations (
    id integer NOT NULL,
    store_id integer,
    transaction_id integer,
    date date,
    ref_number character varying(255),
    operation character varying(10),
    state character varying(255),
    description character varying(255),
    total numeric(14,2),
    has_error boolean DEFAULT false,
    error_messages character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    contact_id integer,
    creator_id integer,
    transference_id integer,
    store_to_id integer,
    project_id integer
);


--
-- Name: inventory_operations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE inventory_operations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: inventory_operations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE inventory_operations_id_seq OWNED BY inventory_operations.id;


--
-- Name: items; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE items (
    id integer NOT NULL,
    unit_id integer,
    unitary_cost numeric(14,2),
    price numeric(14,2) DEFAULT 0,
    name character varying(255),
    description character varying(255),
    code character varying(100),
    "integer" boolean DEFAULT false,
    stockable boolean DEFAULT false,
    active boolean DEFAULT true,
    discount character varying(255),
    ctype character varying(20),
    type character varying(255),
    un_name character varying(255),
    un_symbol character varying(10),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    for_sale boolean DEFAULT true
);


--
-- Name: items_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE items_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: items_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE items_id_seq OWNED BY items.id;


--
-- Name: money_stores; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE money_stores (
    id integer NOT NULL,
    currency_id integer,
    type character varying(30),
    name character varying(100),
    number character varying(30),
    address character varying(255),
    website character varying(255),
    phone character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: money_stores_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE money_stores_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: money_stores_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE money_stores_id_seq OWNED BY money_stores.id;


--
-- Name: pay_plans; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE pay_plans (
    id integer NOT NULL,
    transaction_id integer,
    currency_id integer,
    cur character varying(255),
    amount numeric(14,2),
    interests_penalties numeric(14,2),
    due_date date,
    alert_date date,
    email boolean DEFAULT true,
    ctype character varying(20),
    description character varying(255),
    paid boolean DEFAULT false,
    operation character varying(20),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    project_id integer
);


--
-- Name: pay_plans_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE pay_plans_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: pay_plans_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE pay_plans_id_seq OWNED BY pay_plans.id;


--
-- Name: payments; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE payments (
    id integer NOT NULL,
    transaction_id integer,
    ctype character varying(255),
    date date,
    amount numeric(14,2),
    interests_penalties numeric(14,2),
    description character varying(255),
    account_id integer,
    account_ledger_id integer,
    contact_id integer,
    active boolean DEFAULT true,
    state character varying(20),
    exchange_rate numeric(14,4),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: payments_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE payments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: payments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE payments_id_seq OWNED BY payments.id;


--
-- Name: prices; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE prices (
    id integer NOT NULL,
    item_id integer,
    unitary_cost numeric(14,2),
    price numeric(14,2),
    discount character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: prices_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE prices_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: prices_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE prices_id_seq OWNED BY prices.id;


--
-- Name: projects; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE projects (
    id integer NOT NULL,
    name character varying(255),
    active boolean DEFAULT true,
    date_start date,
    date_end date,
    description text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: projects_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE projects_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: projects_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE projects_id_seq OWNED BY projects.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE schema_migrations (
    version character varying(255) NOT NULL
);


--
-- Name: stocks; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE stocks (
    id integer NOT NULL,
    store_id integer,
    item_id integer,
    state character varying(20),
    unitary_cost numeric(14,2),
    quantity numeric(14,2),
    minimum numeric(14,2),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    user_id integer
);


--
-- Name: stocks_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE stocks_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: stocks_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE stocks_id_seq OWNED BY stocks.id;


--
-- Name: stores; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE stores (
    id integer NOT NULL,
    name character varying(255),
    address character varying(255),
    phone character varying(255),
    active boolean DEFAULT true,
    description character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: stores_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE stores_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: stores_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE stores_id_seq OWNED BY stores.id;


--
-- Name: taxes; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE taxes (
    id integer NOT NULL,
    name character varying(255),
    abbreviation character varying(10),
    rate numeric(5,2),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: taxes_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE taxes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: taxes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE taxes_id_seq OWNED BY taxes.id;


--
-- Name: taxes_transactions; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE taxes_transactions (
    tax_id integer,
    transaction_id integer
);


--
-- Name: transaction_details; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE transaction_details (
    id integer NOT NULL,
    transaction_id integer,
    item_id integer,
    currency_id integer,
    quantity numeric(14,2),
    price numeric(14,2),
    description character varying(255),
    ctype character varying(30),
    discount numeric(14,2),
    balance numeric(14,2),
    original_price numeric(14,2),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    delivered numeric(14,2) DEFAULT 0
);


--
-- Name: transaction_details_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE transaction_details_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: transaction_details_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE transaction_details_id_seq OWNED BY transaction_details.id;


--
-- Name: transaction_histories; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE transaction_histories (
    id integer NOT NULL,
    transaction_id integer,
    user_id integer,
    data text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: transaction_histories_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE transaction_histories_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: transaction_histories_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE transaction_histories_id_seq OWNED BY transaction_histories.id;


--
-- Name: transactions; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE transactions (
    id integer NOT NULL,
    account_id integer,
    type character varying(20),
    total numeric(14,2),
    balance numeric(14,2),
    tax_percent numeric(5,2),
    active boolean DEFAULT true,
    description character varying(255),
    state character varying(20),
    date date,
    ref_number character varying(255),
    bill_number character varying(255),
    currency_id integer,
    exchange_rate numeric(14,4),
    project_id integer,
    discount numeric(5,2),
    gross_total numeric(14,2),
    cash boolean DEFAULT true,
    due_date date,
    balance_inventory numeric(14,2),
    creator_id integer,
    approver_id integer,
    approver_datetime timestamp without time zone,
    approver_reason character varying(255),
    creditor_id integer,
    credit_reference character varying(255),
    credit_datetime timestamp without time zone,
    credit_description character varying(500),
    has_error boolean DEFAULT false,
    error_messages character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    deliver boolean DEFAULT false,
    deliver_datetime timestamp without time zone,
    deliver_approver_id integer,
    deliver_reason character varying(255),
    nuller_id integer,
    nuller_datetime timestamp without time zone,
    contact_id integer,
    delivered boolean DEFAULT false,
    original_total numeric(14,2),
    discounted boolean DEFAULT false,
    modified_by integer,
    fact boolean DEFAULT true,
    devolution boolean DEFAULT false
);


--
-- Name: transactions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE transactions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: transactions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE transactions_id_seq OWNED BY transactions.id;


--
-- Name: units; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE units (
    id integer NOT NULL,
    name character varying(100),
    symbol character varying(20),
    "integer" boolean DEFAULT false,
    visible boolean DEFAULT true,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: units_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE units_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: units_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE units_id_seq OWNED BY units.id;


SET search_path = bonsai, pg_catalog;

--
-- Name: id; Type: DEFAULT; Schema: bonsai; Owner: -
--

ALTER TABLE ONLY account_balances ALTER COLUMN id SET DEFAULT nextval('account_balances_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: bonsai; Owner: -
--

ALTER TABLE ONLY account_ledger_details ALTER COLUMN id SET DEFAULT nextval('account_ledger_details_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: bonsai; Owner: -
--

ALTER TABLE ONLY account_ledgers ALTER COLUMN id SET DEFAULT nextval('account_ledgers_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: bonsai; Owner: -
--

ALTER TABLE ONLY account_types ALTER COLUMN id SET DEFAULT nextval('account_types_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: bonsai; Owner: -
--

ALTER TABLE ONLY accounts ALTER COLUMN id SET DEFAULT nextval('accounts_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: bonsai; Owner: -
--

ALTER TABLE ONLY contacts ALTER COLUMN id SET DEFAULT nextval('contacts_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: bonsai; Owner: -
--

ALTER TABLE ONLY inventory_operation_details ALTER COLUMN id SET DEFAULT nextval('inventory_operation_details_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: bonsai; Owner: -
--

ALTER TABLE ONLY inventory_operations ALTER COLUMN id SET DEFAULT nextval('inventory_operations_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: bonsai; Owner: -
--

ALTER TABLE ONLY items ALTER COLUMN id SET DEFAULT nextval('items_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: bonsai; Owner: -
--

ALTER TABLE ONLY money_stores ALTER COLUMN id SET DEFAULT nextval('money_stores_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: bonsai; Owner: -
--

ALTER TABLE ONLY pay_plans ALTER COLUMN id SET DEFAULT nextval('pay_plans_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: bonsai; Owner: -
--

ALTER TABLE ONLY payments ALTER COLUMN id SET DEFAULT nextval('payments_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: bonsai; Owner: -
--

ALTER TABLE ONLY prices ALTER COLUMN id SET DEFAULT nextval('prices_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: bonsai; Owner: -
--

ALTER TABLE ONLY projects ALTER COLUMN id SET DEFAULT nextval('projects_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: bonsai; Owner: -
--

ALTER TABLE ONLY stocks ALTER COLUMN id SET DEFAULT nextval('stocks_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: bonsai; Owner: -
--

ALTER TABLE ONLY stores ALTER COLUMN id SET DEFAULT nextval('stores_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: bonsai; Owner: -
--

ALTER TABLE ONLY taxes ALTER COLUMN id SET DEFAULT nextval('taxes_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: bonsai; Owner: -
--

ALTER TABLE ONLY transaction_details ALTER COLUMN id SET DEFAULT nextval('transaction_details_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: bonsai; Owner: -
--

ALTER TABLE ONLY transaction_histories ALTER COLUMN id SET DEFAULT nextval('transaction_histories_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: bonsai; Owner: -
--

ALTER TABLE ONLY transactions ALTER COLUMN id SET DEFAULT nextval('transactions_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: bonsai; Owner: -
--

ALTER TABLE ONLY units ALTER COLUMN id SET DEFAULT nextval('units_id_seq'::regclass);


SET search_path = common, pg_catalog;

--
-- Name: id; Type: DEFAULT; Schema: common; Owner: -
--

ALTER TABLE ONLY countries ALTER COLUMN id SET DEFAULT nextval('countries_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: common; Owner: -
--

ALTER TABLE ONLY currencies ALTER COLUMN id SET DEFAULT nextval('currencies_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: common; Owner: -
--

ALTER TABLE ONLY links ALTER COLUMN id SET DEFAULT nextval('links_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: common; Owner: -
--

ALTER TABLE ONLY organisations ALTER COLUMN id SET DEFAULT nextval('organisations_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: common; Owner: -
--

ALTER TABLE ONLY queue_classic_jobs ALTER COLUMN id SET DEFAULT nextval('queue_classic_jobs_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: common; Owner: -
--

ALTER TABLE ONLY users ALTER COLUMN id SET DEFAULT nextval('users_id_seq'::regclass);


SET search_path = public, pg_catalog;

--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY account_balances ALTER COLUMN id SET DEFAULT nextval('account_balances_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY account_ledger_details ALTER COLUMN id SET DEFAULT nextval('account_ledger_details_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY account_ledgers ALTER COLUMN id SET DEFAULT nextval('account_ledgers_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY account_types ALTER COLUMN id SET DEFAULT nextval('account_types_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY accounts ALTER COLUMN id SET DEFAULT nextval('accounts_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY contacts ALTER COLUMN id SET DEFAULT nextval('contacts_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY inventory_operation_details ALTER COLUMN id SET DEFAULT nextval('inventory_operation_details_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY inventory_operations ALTER COLUMN id SET DEFAULT nextval('inventory_operations_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY items ALTER COLUMN id SET DEFAULT nextval('items_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY money_stores ALTER COLUMN id SET DEFAULT nextval('money_stores_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY pay_plans ALTER COLUMN id SET DEFAULT nextval('pay_plans_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY payments ALTER COLUMN id SET DEFAULT nextval('payments_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY prices ALTER COLUMN id SET DEFAULT nextval('prices_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY projects ALTER COLUMN id SET DEFAULT nextval('projects_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY stocks ALTER COLUMN id SET DEFAULT nextval('stocks_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY stores ALTER COLUMN id SET DEFAULT nextval('stores_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY taxes ALTER COLUMN id SET DEFAULT nextval('taxes_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY transaction_details ALTER COLUMN id SET DEFAULT nextval('transaction_details_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY transaction_histories ALTER COLUMN id SET DEFAULT nextval('transaction_histories_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY transactions ALTER COLUMN id SET DEFAULT nextval('transactions_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY units ALTER COLUMN id SET DEFAULT nextval('units_id_seq'::regclass);


SET search_path = bonsai, pg_catalog;

--
-- Name: account_balances_pkey; Type: CONSTRAINT; Schema: bonsai; Owner: -; Tablespace: 
--

ALTER TABLE ONLY account_balances
    ADD CONSTRAINT account_balances_pkey PRIMARY KEY (id);


--
-- Name: account_ledger_details_pkey; Type: CONSTRAINT; Schema: bonsai; Owner: -; Tablespace: 
--

ALTER TABLE ONLY account_ledger_details
    ADD CONSTRAINT account_ledger_details_pkey PRIMARY KEY (id);


--
-- Name: account_ledgers_pkey; Type: CONSTRAINT; Schema: bonsai; Owner: -; Tablespace: 
--

ALTER TABLE ONLY account_ledgers
    ADD CONSTRAINT account_ledgers_pkey PRIMARY KEY (id);


--
-- Name: account_types_pkey; Type: CONSTRAINT; Schema: bonsai; Owner: -; Tablespace: 
--

ALTER TABLE ONLY account_types
    ADD CONSTRAINT account_types_pkey PRIMARY KEY (id);


--
-- Name: accounts_pkey; Type: CONSTRAINT; Schema: bonsai; Owner: -; Tablespace: 
--

ALTER TABLE ONLY accounts
    ADD CONSTRAINT accounts_pkey PRIMARY KEY (id);


--
-- Name: contacts_pkey; Type: CONSTRAINT; Schema: bonsai; Owner: -; Tablespace: 
--

ALTER TABLE ONLY contacts
    ADD CONSTRAINT contacts_pkey PRIMARY KEY (id);


--
-- Name: inventory_operation_details_pkey; Type: CONSTRAINT; Schema: bonsai; Owner: -; Tablespace: 
--

ALTER TABLE ONLY inventory_operation_details
    ADD CONSTRAINT inventory_operation_details_pkey PRIMARY KEY (id);


--
-- Name: inventory_operations_pkey; Type: CONSTRAINT; Schema: bonsai; Owner: -; Tablespace: 
--

ALTER TABLE ONLY inventory_operations
    ADD CONSTRAINT inventory_operations_pkey PRIMARY KEY (id);


--
-- Name: items_pkey; Type: CONSTRAINT; Schema: bonsai; Owner: -; Tablespace: 
--

ALTER TABLE ONLY items
    ADD CONSTRAINT items_pkey PRIMARY KEY (id);


--
-- Name: money_stores_pkey; Type: CONSTRAINT; Schema: bonsai; Owner: -; Tablespace: 
--

ALTER TABLE ONLY money_stores
    ADD CONSTRAINT money_stores_pkey PRIMARY KEY (id);


--
-- Name: pay_plans_pkey; Type: CONSTRAINT; Schema: bonsai; Owner: -; Tablespace: 
--

ALTER TABLE ONLY pay_plans
    ADD CONSTRAINT pay_plans_pkey PRIMARY KEY (id);


--
-- Name: payments_pkey; Type: CONSTRAINT; Schema: bonsai; Owner: -; Tablespace: 
--

ALTER TABLE ONLY payments
    ADD CONSTRAINT payments_pkey PRIMARY KEY (id);


--
-- Name: prices_pkey; Type: CONSTRAINT; Schema: bonsai; Owner: -; Tablespace: 
--

ALTER TABLE ONLY prices
    ADD CONSTRAINT prices_pkey PRIMARY KEY (id);


--
-- Name: projects_pkey; Type: CONSTRAINT; Schema: bonsai; Owner: -; Tablespace: 
--

ALTER TABLE ONLY projects
    ADD CONSTRAINT projects_pkey PRIMARY KEY (id);


--
-- Name: stocks_pkey; Type: CONSTRAINT; Schema: bonsai; Owner: -; Tablespace: 
--

ALTER TABLE ONLY stocks
    ADD CONSTRAINT stocks_pkey PRIMARY KEY (id);


--
-- Name: stores_pkey; Type: CONSTRAINT; Schema: bonsai; Owner: -; Tablespace: 
--

ALTER TABLE ONLY stores
    ADD CONSTRAINT stores_pkey PRIMARY KEY (id);


--
-- Name: taxes_pkey; Type: CONSTRAINT; Schema: bonsai; Owner: -; Tablespace: 
--

ALTER TABLE ONLY taxes
    ADD CONSTRAINT taxes_pkey PRIMARY KEY (id);


--
-- Name: transaction_details_pkey; Type: CONSTRAINT; Schema: bonsai; Owner: -; Tablespace: 
--

ALTER TABLE ONLY transaction_details
    ADD CONSTRAINT transaction_details_pkey PRIMARY KEY (id);


--
-- Name: transaction_histories_pkey; Type: CONSTRAINT; Schema: bonsai; Owner: -; Tablespace: 
--

ALTER TABLE ONLY transaction_histories
    ADD CONSTRAINT transaction_histories_pkey PRIMARY KEY (id);


--
-- Name: transactions_pkey; Type: CONSTRAINT; Schema: bonsai; Owner: -; Tablespace: 
--

ALTER TABLE ONLY transactions
    ADD CONSTRAINT transactions_pkey PRIMARY KEY (id);


--
-- Name: units_pkey; Type: CONSTRAINT; Schema: bonsai; Owner: -; Tablespace: 
--

ALTER TABLE ONLY units
    ADD CONSTRAINT units_pkey PRIMARY KEY (id);


SET search_path = common, pg_catalog;

--
-- Name: countries_pkey; Type: CONSTRAINT; Schema: common; Owner: -; Tablespace: 
--

ALTER TABLE ONLY countries
    ADD CONSTRAINT countries_pkey PRIMARY KEY (id);


--
-- Name: currencies_pkey; Type: CONSTRAINT; Schema: common; Owner: -; Tablespace: 
--

ALTER TABLE ONLY currencies
    ADD CONSTRAINT currencies_pkey PRIMARY KEY (id);


--
-- Name: links_pkey; Type: CONSTRAINT; Schema: common; Owner: -; Tablespace: 
--

ALTER TABLE ONLY links
    ADD CONSTRAINT links_pkey PRIMARY KEY (id);


--
-- Name: organisations_pkey; Type: CONSTRAINT; Schema: common; Owner: -; Tablespace: 
--

ALTER TABLE ONLY organisations
    ADD CONSTRAINT organisations_pkey PRIMARY KEY (id);


--
-- Name: queue_classic_jobs_pkey; Type: CONSTRAINT; Schema: common; Owner: -; Tablespace: 
--

ALTER TABLE ONLY queue_classic_jobs
    ADD CONSTRAINT queue_classic_jobs_pkey PRIMARY KEY (id);


--
-- Name: users_pkey; Type: CONSTRAINT; Schema: common; Owner: -; Tablespace: 
--

ALTER TABLE ONLY users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


SET search_path = public, pg_catalog;

--
-- Name: account_balances_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY account_balances
    ADD CONSTRAINT account_balances_pkey PRIMARY KEY (id);


--
-- Name: account_ledger_details_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY account_ledger_details
    ADD CONSTRAINT account_ledger_details_pkey PRIMARY KEY (id);


--
-- Name: account_ledgers_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY account_ledgers
    ADD CONSTRAINT account_ledgers_pkey PRIMARY KEY (id);


--
-- Name: account_types_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY account_types
    ADD CONSTRAINT account_types_pkey PRIMARY KEY (id);


--
-- Name: accounts_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY accounts
    ADD CONSTRAINT accounts_pkey PRIMARY KEY (id);


--
-- Name: contacts_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY contacts
    ADD CONSTRAINT contacts_pkey PRIMARY KEY (id);


--
-- Name: inventory_operation_details_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY inventory_operation_details
    ADD CONSTRAINT inventory_operation_details_pkey PRIMARY KEY (id);


--
-- Name: inventory_operations_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY inventory_operations
    ADD CONSTRAINT inventory_operations_pkey PRIMARY KEY (id);


--
-- Name: items_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY items
    ADD CONSTRAINT items_pkey PRIMARY KEY (id);


--
-- Name: money_stores_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY money_stores
    ADD CONSTRAINT money_stores_pkey PRIMARY KEY (id);


--
-- Name: pay_plans_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY pay_plans
    ADD CONSTRAINT pay_plans_pkey PRIMARY KEY (id);


--
-- Name: payments_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY payments
    ADD CONSTRAINT payments_pkey PRIMARY KEY (id);


--
-- Name: prices_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY prices
    ADD CONSTRAINT prices_pkey PRIMARY KEY (id);


--
-- Name: projects_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY projects
    ADD CONSTRAINT projects_pkey PRIMARY KEY (id);


--
-- Name: stocks_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY stocks
    ADD CONSTRAINT stocks_pkey PRIMARY KEY (id);


--
-- Name: stores_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY stores
    ADD CONSTRAINT stores_pkey PRIMARY KEY (id);


--
-- Name: taxes_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY taxes
    ADD CONSTRAINT taxes_pkey PRIMARY KEY (id);


--
-- Name: transaction_details_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY transaction_details
    ADD CONSTRAINT transaction_details_pkey PRIMARY KEY (id);


--
-- Name: transaction_histories_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY transaction_histories
    ADD CONSTRAINT transaction_histories_pkey PRIMARY KEY (id);


--
-- Name: transactions_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY transactions
    ADD CONSTRAINT transactions_pkey PRIMARY KEY (id);


--
-- Name: units_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY units
    ADD CONSTRAINT units_pkey PRIMARY KEY (id);


SET search_path = bonsai, pg_catalog;

--
-- Name: index_account_balances_on_account_id; Type: INDEX; Schema: bonsai; Owner: -; Tablespace: 
--

CREATE INDEX index_account_balances_on_account_id ON account_balances USING btree (account_id);


--
-- Name: index_account_balances_on_contact_id; Type: INDEX; Schema: bonsai; Owner: -; Tablespace: 
--

CREATE INDEX index_account_balances_on_contact_id ON account_balances USING btree (contact_id);


--
-- Name: index_account_balances_on_currency_id; Type: INDEX; Schema: bonsai; Owner: -; Tablespace: 
--

CREATE INDEX index_account_balances_on_currency_id ON account_balances USING btree (currency_id);


--
-- Name: index_account_balances_on_user_id; Type: INDEX; Schema: bonsai; Owner: -; Tablespace: 
--

CREATE INDEX index_account_balances_on_user_id ON account_balances USING btree (user_id);


--
-- Name: index_account_ledger_details_on_account_id; Type: INDEX; Schema: bonsai; Owner: -; Tablespace: 
--

CREATE INDEX index_account_ledger_details_on_account_id ON account_ledger_details USING btree (account_id);


--
-- Name: index_account_ledger_details_on_account_ledger_id; Type: INDEX; Schema: bonsai; Owner: -; Tablespace: 
--

CREATE INDEX index_account_ledger_details_on_account_ledger_id ON account_ledger_details USING btree (account_ledger_id);


--
-- Name: index_account_ledger_details_on_active; Type: INDEX; Schema: bonsai; Owner: -; Tablespace: 
--

CREATE INDEX index_account_ledger_details_on_active ON account_ledger_details USING btree (active);


--
-- Name: index_account_ledger_details_on_currency_id; Type: INDEX; Schema: bonsai; Owner: -; Tablespace: 
--

CREATE INDEX index_account_ledger_details_on_currency_id ON account_ledger_details USING btree (currency_id);


--
-- Name: index_account_ledger_details_on_related_id; Type: INDEX; Schema: bonsai; Owner: -; Tablespace: 
--

CREATE INDEX index_account_ledger_details_on_related_id ON account_ledger_details USING btree (related_id);


--
-- Name: index_account_ledger_details_on_state; Type: INDEX; Schema: bonsai; Owner: -; Tablespace: 
--

CREATE INDEX index_account_ledger_details_on_state ON account_ledger_details USING btree (state);


--
-- Name: index_account_ledgers_on_account_id; Type: INDEX; Schema: bonsai; Owner: -; Tablespace: 
--

CREATE INDEX index_account_ledgers_on_account_id ON account_ledgers USING btree (account_id);


--
-- Name: index_account_ledgers_on_active; Type: INDEX; Schema: bonsai; Owner: -; Tablespace: 
--

CREATE INDEX index_account_ledgers_on_active ON account_ledgers USING btree (active);


--
-- Name: index_account_ledgers_on_approver_id; Type: INDEX; Schema: bonsai; Owner: -; Tablespace: 
--

CREATE INDEX index_account_ledgers_on_approver_id ON account_ledgers USING btree (approver_id);


--
-- Name: index_account_ledgers_on_conciliation; Type: INDEX; Schema: bonsai; Owner: -; Tablespace: 
--

CREATE INDEX index_account_ledgers_on_conciliation ON account_ledgers USING btree (conciliation);


--
-- Name: index_account_ledgers_on_contact_id; Type: INDEX; Schema: bonsai; Owner: -; Tablespace: 
--

CREATE INDEX index_account_ledgers_on_contact_id ON account_ledgers USING btree (contact_id);


--
-- Name: index_account_ledgers_on_created_at; Type: INDEX; Schema: bonsai; Owner: -; Tablespace: 
--

CREATE INDEX index_account_ledgers_on_created_at ON account_ledgers USING btree (created_at);


--
-- Name: index_account_ledgers_on_creator_id; Type: INDEX; Schema: bonsai; Owner: -; Tablespace: 
--

CREATE INDEX index_account_ledgers_on_creator_id ON account_ledgers USING btree (creator_id);


--
-- Name: index_account_ledgers_on_currency_id; Type: INDEX; Schema: bonsai; Owner: -; Tablespace: 
--

CREATE INDEX index_account_ledgers_on_currency_id ON account_ledgers USING btree (currency_id);


--
-- Name: index_account_ledgers_on_date; Type: INDEX; Schema: bonsai; Owner: -; Tablespace: 
--

CREATE INDEX index_account_ledgers_on_date ON account_ledgers USING btree (date);


--
-- Name: index_account_ledgers_on_has_error; Type: INDEX; Schema: bonsai; Owner: -; Tablespace: 
--

CREATE INDEX index_account_ledgers_on_has_error ON account_ledgers USING btree (has_error);


--
-- Name: index_account_ledgers_on_inverse; Type: INDEX; Schema: bonsai; Owner: -; Tablespace: 
--

CREATE INDEX index_account_ledgers_on_inverse ON account_ledgers USING btree (inverse);


--
-- Name: index_account_ledgers_on_nuller_id; Type: INDEX; Schema: bonsai; Owner: -; Tablespace: 
--

CREATE INDEX index_account_ledgers_on_nuller_id ON account_ledgers USING btree (nuller_id);


--
-- Name: index_account_ledgers_on_operation; Type: INDEX; Schema: bonsai; Owner: -; Tablespace: 
--

CREATE INDEX index_account_ledgers_on_operation ON account_ledgers USING btree (operation);


--
-- Name: index_account_ledgers_on_project_id; Type: INDEX; Schema: bonsai; Owner: -; Tablespace: 
--

CREATE INDEX index_account_ledgers_on_project_id ON account_ledgers USING btree (project_id);


--
-- Name: index_account_ledgers_on_reference; Type: INDEX; Schema: bonsai; Owner: -; Tablespace: 
--

CREATE INDEX index_account_ledgers_on_reference ON account_ledgers USING btree (reference);


--
-- Name: index_account_ledgers_on_staff_id; Type: INDEX; Schema: bonsai; Owner: -; Tablespace: 
--

CREATE INDEX index_account_ledgers_on_staff_id ON account_ledgers USING btree (staff_id);


--
-- Name: index_account_ledgers_on_status; Type: INDEX; Schema: bonsai; Owner: -; Tablespace: 
--

CREATE INDEX index_account_ledgers_on_status ON account_ledgers USING btree (status);


--
-- Name: index_account_ledgers_on_to_id; Type: INDEX; Schema: bonsai; Owner: -; Tablespace: 
--

CREATE INDEX index_account_ledgers_on_to_id ON account_ledgers USING btree (to_id);


--
-- Name: index_account_ledgers_on_transaction_id; Type: INDEX; Schema: bonsai; Owner: -; Tablespace: 
--

CREATE INDEX index_account_ledgers_on_transaction_id ON account_ledgers USING btree (transaction_id);


--
-- Name: index_account_ledgers_on_transaction_type; Type: INDEX; Schema: bonsai; Owner: -; Tablespace: 
--

CREATE INDEX index_account_ledgers_on_transaction_type ON account_ledgers USING btree (transaction_type);


--
-- Name: index_account_types_on_account_number; Type: INDEX; Schema: bonsai; Owner: -; Tablespace: 
--

CREATE INDEX index_account_types_on_account_number ON account_types USING btree (account_number);


--
-- Name: index_accounts_on_account_type_id; Type: INDEX; Schema: bonsai; Owner: -; Tablespace: 
--

CREATE INDEX index_accounts_on_account_type_id ON accounts USING btree (account_type_id);


--
-- Name: index_accounts_on_accountable_id; Type: INDEX; Schema: bonsai; Owner: -; Tablespace: 
--

CREATE INDEX index_accounts_on_accountable_id ON accounts USING btree (accountable_id);


--
-- Name: index_accounts_on_accountable_type; Type: INDEX; Schema: bonsai; Owner: -; Tablespace: 
--

CREATE INDEX index_accounts_on_accountable_type ON accounts USING btree (accountable_type);


--
-- Name: index_accounts_on_amount; Type: INDEX; Schema: bonsai; Owner: -; Tablespace: 
--

CREATE INDEX index_accounts_on_amount ON accounts USING btree (amount);


--
-- Name: index_accounts_on_currency_id; Type: INDEX; Schema: bonsai; Owner: -; Tablespace: 
--

CREATE INDEX index_accounts_on_currency_id ON accounts USING btree (currency_id);


--
-- Name: index_accounts_on_original_type; Type: INDEX; Schema: bonsai; Owner: -; Tablespace: 
--

CREATE INDEX index_accounts_on_original_type ON accounts USING btree (original_type);


--
-- Name: index_accounts_on_type; Type: INDEX; Schema: bonsai; Owner: -; Tablespace: 
--

CREATE INDEX index_accounts_on_type ON accounts USING btree (type);


--
-- Name: index_contacts_on_first_name; Type: INDEX; Schema: bonsai; Owner: -; Tablespace: 
--

CREATE INDEX index_contacts_on_first_name ON contacts USING btree (first_name);


--
-- Name: index_contacts_on_last_name; Type: INDEX; Schema: bonsai; Owner: -; Tablespace: 
--

CREATE INDEX index_contacts_on_last_name ON contacts USING btree (last_name);


--
-- Name: index_contacts_on_matchcode; Type: INDEX; Schema: bonsai; Owner: -; Tablespace: 
--

CREATE INDEX index_contacts_on_matchcode ON contacts USING btree (matchcode);


--
-- Name: index_contacts_on_type; Type: INDEX; Schema: bonsai; Owner: -; Tablespace: 
--

CREATE INDEX index_contacts_on_type ON contacts USING btree (type);


--
-- Name: index_inventory_operation_details_on_contact_id; Type: INDEX; Schema: bonsai; Owner: -; Tablespace: 
--

CREATE INDEX index_inventory_operation_details_on_contact_id ON inventory_operation_details USING btree (contact_id);


--
-- Name: index_inventory_operation_details_on_inventory_operation_id; Type: INDEX; Schema: bonsai; Owner: -; Tablespace: 
--

CREATE INDEX index_inventory_operation_details_on_inventory_operation_id ON inventory_operation_details USING btree (inventory_operation_id);


--
-- Name: index_inventory_operation_details_on_item_id; Type: INDEX; Schema: bonsai; Owner: -; Tablespace: 
--

CREATE INDEX index_inventory_operation_details_on_item_id ON inventory_operation_details USING btree (item_id);


--
-- Name: index_inventory_operation_details_on_operation; Type: INDEX; Schema: bonsai; Owner: -; Tablespace: 
--

CREATE INDEX index_inventory_operation_details_on_operation ON inventory_operation_details USING btree (operation);


--
-- Name: index_inventory_operation_details_on_store_id; Type: INDEX; Schema: bonsai; Owner: -; Tablespace: 
--

CREATE INDEX index_inventory_operation_details_on_store_id ON inventory_operation_details USING btree (store_id);


--
-- Name: index_inventory_operation_details_on_transaction_id; Type: INDEX; Schema: bonsai; Owner: -; Tablespace: 
--

CREATE INDEX index_inventory_operation_details_on_transaction_id ON inventory_operation_details USING btree (transaction_id);


--
-- Name: index_inventory_operations_on_contact_id; Type: INDEX; Schema: bonsai; Owner: -; Tablespace: 
--

CREATE INDEX index_inventory_operations_on_contact_id ON inventory_operations USING btree (contact_id);


--
-- Name: index_inventory_operations_on_creator_id; Type: INDEX; Schema: bonsai; Owner: -; Tablespace: 
--

CREATE INDEX index_inventory_operations_on_creator_id ON inventory_operations USING btree (creator_id);


--
-- Name: index_inventory_operations_on_date; Type: INDEX; Schema: bonsai; Owner: -; Tablespace: 
--

CREATE INDEX index_inventory_operations_on_date ON inventory_operations USING btree (date);


--
-- Name: index_inventory_operations_on_has_error; Type: INDEX; Schema: bonsai; Owner: -; Tablespace: 
--

CREATE INDEX index_inventory_operations_on_has_error ON inventory_operations USING btree (has_error);


--
-- Name: index_inventory_operations_on_operation; Type: INDEX; Schema: bonsai; Owner: -; Tablespace: 
--

CREATE INDEX index_inventory_operations_on_operation ON inventory_operations USING btree (operation);


--
-- Name: index_inventory_operations_on_project_id; Type: INDEX; Schema: bonsai; Owner: -; Tablespace: 
--

CREATE INDEX index_inventory_operations_on_project_id ON inventory_operations USING btree (project_id);


--
-- Name: index_inventory_operations_on_ref_number; Type: INDEX; Schema: bonsai; Owner: -; Tablespace: 
--

CREATE INDEX index_inventory_operations_on_ref_number ON inventory_operations USING btree (ref_number);


--
-- Name: index_inventory_operations_on_state; Type: INDEX; Schema: bonsai; Owner: -; Tablespace: 
--

CREATE INDEX index_inventory_operations_on_state ON inventory_operations USING btree (state);


--
-- Name: index_inventory_operations_on_store_id; Type: INDEX; Schema: bonsai; Owner: -; Tablespace: 
--

CREATE INDEX index_inventory_operations_on_store_id ON inventory_operations USING btree (store_id);


--
-- Name: index_inventory_operations_on_transaction_id; Type: INDEX; Schema: bonsai; Owner: -; Tablespace: 
--

CREATE INDEX index_inventory_operations_on_transaction_id ON inventory_operations USING btree (transaction_id);


--
-- Name: index_inventory_operations_on_transference_id; Type: INDEX; Schema: bonsai; Owner: -; Tablespace: 
--

CREATE INDEX index_inventory_operations_on_transference_id ON inventory_operations USING btree (transference_id);


--
-- Name: index_items_on_code; Type: INDEX; Schema: bonsai; Owner: -; Tablespace: 
--

CREATE INDEX index_items_on_code ON items USING btree (code);


--
-- Name: index_items_on_ctype; Type: INDEX; Schema: bonsai; Owner: -; Tablespace: 
--

CREATE INDEX index_items_on_ctype ON items USING btree (ctype);


--
-- Name: index_items_on_for_sale; Type: INDEX; Schema: bonsai; Owner: -; Tablespace: 
--

CREATE INDEX index_items_on_for_sale ON items USING btree (for_sale);


--
-- Name: index_items_on_stockable; Type: INDEX; Schema: bonsai; Owner: -; Tablespace: 
--

CREATE INDEX index_items_on_stockable ON items USING btree (stockable);


--
-- Name: index_items_on_type; Type: INDEX; Schema: bonsai; Owner: -; Tablespace: 
--

CREATE INDEX index_items_on_type ON items USING btree (type);


--
-- Name: index_items_on_unit_id; Type: INDEX; Schema: bonsai; Owner: -; Tablespace: 
--

CREATE INDEX index_items_on_unit_id ON items USING btree (unit_id);


--
-- Name: index_money_stores_on_currency_id; Type: INDEX; Schema: bonsai; Owner: -; Tablespace: 
--

CREATE INDEX index_money_stores_on_currency_id ON money_stores USING btree (currency_id);


--
-- Name: index_money_stores_on_name; Type: INDEX; Schema: bonsai; Owner: -; Tablespace: 
--

CREATE INDEX index_money_stores_on_name ON money_stores USING btree (name);


--
-- Name: index_money_stores_on_type; Type: INDEX; Schema: bonsai; Owner: -; Tablespace: 
--

CREATE INDEX index_money_stores_on_type ON money_stores USING btree (type);


--
-- Name: index_pay_plans_on_ctype; Type: INDEX; Schema: bonsai; Owner: -; Tablespace: 
--

CREATE INDEX index_pay_plans_on_ctype ON pay_plans USING btree (ctype);


--
-- Name: index_pay_plans_on_operation; Type: INDEX; Schema: bonsai; Owner: -; Tablespace: 
--

CREATE INDEX index_pay_plans_on_operation ON pay_plans USING btree (operation);


--
-- Name: index_pay_plans_on_paid; Type: INDEX; Schema: bonsai; Owner: -; Tablespace: 
--

CREATE INDEX index_pay_plans_on_paid ON pay_plans USING btree (paid);


--
-- Name: index_pay_plans_on_due_date; Type: INDEX; Schema: bonsai; Owner: -; Tablespace: 
--

CREATE INDEX index_pay_plans_on_due_date ON pay_plans USING btree (due_date);


--
-- Name: index_pay_plans_on_project_id; Type: INDEX; Schema: bonsai; Owner: -; Tablespace: 
--

CREATE INDEX index_pay_plans_on_project_id ON pay_plans USING btree (project_id);


--
-- Name: index_pay_plans_on_transaction_id; Type: INDEX; Schema: bonsai; Owner: -; Tablespace: 
--

CREATE INDEX index_pay_plans_on_transaction_id ON pay_plans USING btree (transaction_id);


--
-- Name: index_payments_on_account_id; Type: INDEX; Schema: bonsai; Owner: -; Tablespace: 
--

CREATE INDEX index_payments_on_account_id ON payments USING btree (account_id);


--
-- Name: index_payments_on_account_ledger_id; Type: INDEX; Schema: bonsai; Owner: -; Tablespace: 
--

CREATE INDEX index_payments_on_account_ledger_id ON payments USING btree (account_ledger_id);


--
-- Name: index_payments_on_contact_id; Type: INDEX; Schema: bonsai; Owner: -; Tablespace: 
--

CREATE INDEX index_payments_on_contact_id ON payments USING btree (contact_id);


--
-- Name: index_payments_on_ctype; Type: INDEX; Schema: bonsai; Owner: -; Tablespace: 
--

CREATE INDEX index_payments_on_ctype ON payments USING btree (ctype);


--
-- Name: index_payments_on_date; Type: INDEX; Schema: bonsai; Owner: -; Tablespace: 
--

CREATE INDEX index_payments_on_date ON payments USING btree (date);


--
-- Name: index_payments_on_transaction_id; Type: INDEX; Schema: bonsai; Owner: -; Tablespace: 
--

CREATE INDEX index_payments_on_transaction_id ON payments USING btree (transaction_id);


--
-- Name: index_prices_on_item_id; Type: INDEX; Schema: bonsai; Owner: -; Tablespace: 
--

CREATE INDEX index_prices_on_item_id ON prices USING btree (item_id);


--
-- Name: index_projects_on_active; Type: INDEX; Schema: bonsai; Owner: -; Tablespace: 
--

CREATE INDEX index_projects_on_active ON projects USING btree (active);


--
-- Name: index_stocks_on_item_id; Type: INDEX; Schema: bonsai; Owner: -; Tablespace: 
--

CREATE INDEX index_stocks_on_item_id ON stocks USING btree (item_id);


--
-- Name: index_stocks_on_minimum; Type: INDEX; Schema: bonsai; Owner: -; Tablespace: 
--

CREATE INDEX index_stocks_on_minimum ON stocks USING btree (minimum);


--
-- Name: index_stocks_on_quantity; Type: INDEX; Schema: bonsai; Owner: -; Tablespace: 
--

CREATE INDEX index_stocks_on_quantity ON stocks USING btree (quantity);


--
-- Name: index_stocks_on_state; Type: INDEX; Schema: bonsai; Owner: -; Tablespace: 
--

CREATE INDEX index_stocks_on_state ON stocks USING btree (state);


--
-- Name: index_stocks_on_store_id; Type: INDEX; Schema: bonsai; Owner: -; Tablespace: 
--

CREATE INDEX index_stocks_on_store_id ON stocks USING btree (store_id);


--
-- Name: index_stocks_on_updated_at; Type: INDEX; Schema: bonsai; Owner: -; Tablespace: 
--

CREATE INDEX index_stocks_on_updated_at ON stocks USING btree (updated_at);


--
-- Name: index_stocks_on_user_id; Type: INDEX; Schema: bonsai; Owner: -; Tablespace: 
--

CREATE INDEX index_stocks_on_user_id ON stocks USING btree (user_id);


--
-- Name: index_taxes_transactions_on_tax_id; Type: INDEX; Schema: bonsai; Owner: -; Tablespace: 
--

CREATE INDEX index_taxes_transactions_on_tax_id ON taxes_transactions USING btree (tax_id);


--
-- Name: index_taxes_transactions_on_tax_id_and_transaction_id; Type: INDEX; Schema: bonsai; Owner: -; Tablespace: 
--

CREATE INDEX index_taxes_transactions_on_tax_id_and_transaction_id ON taxes_transactions USING btree (tax_id, transaction_id);


--
-- Name: index_taxes_transactions_on_transaction_id; Type: INDEX; Schema: bonsai; Owner: -; Tablespace: 
--

CREATE INDEX index_taxes_transactions_on_transaction_id ON taxes_transactions USING btree (transaction_id);


--
-- Name: index_transaction_details_on_ctype; Type: INDEX; Schema: bonsai; Owner: -; Tablespace: 
--

CREATE INDEX index_transaction_details_on_ctype ON transaction_details USING btree (ctype);


--
-- Name: index_transaction_details_on_item_id; Type: INDEX; Schema: bonsai; Owner: -; Tablespace: 
--

CREATE INDEX index_transaction_details_on_item_id ON transaction_details USING btree (item_id);


--
-- Name: index_transaction_details_on_transaction_id; Type: INDEX; Schema: bonsai; Owner: -; Tablespace: 
--

CREATE INDEX index_transaction_details_on_transaction_id ON transaction_details USING btree (transaction_id);


--
-- Name: index_transaction_histories_on_transaction_id; Type: INDEX; Schema: bonsai; Owner: -; Tablespace: 
--

CREATE INDEX index_transaction_histories_on_transaction_id ON transaction_histories USING btree (transaction_id);


--
-- Name: index_transaction_histories_on_user_id; Type: INDEX; Schema: bonsai; Owner: -; Tablespace: 
--

CREATE INDEX index_transaction_histories_on_user_id ON transaction_histories USING btree (user_id);


--
-- Name: index_transactions_on_account_id; Type: INDEX; Schema: bonsai; Owner: -; Tablespace: 
--

CREATE INDEX index_transactions_on_account_id ON transactions USING btree (account_id);


--
-- Name: index_transactions_on_active; Type: INDEX; Schema: bonsai; Owner: -; Tablespace: 
--

CREATE INDEX index_transactions_on_active ON transactions USING btree (active);


--
-- Name: index_transactions_on_balance_inventory; Type: INDEX; Schema: bonsai; Owner: -; Tablespace: 
--

CREATE INDEX index_transactions_on_balance_inventory ON transactions USING btree (balance_inventory);


--
-- Name: index_transactions_on_cash; Type: INDEX; Schema: bonsai; Owner: -; Tablespace: 
--

CREATE INDEX index_transactions_on_cash ON transactions USING btree (cash);


--
-- Name: index_transactions_on_contact_id; Type: INDEX; Schema: bonsai; Owner: -; Tablespace: 
--

CREATE INDEX index_transactions_on_contact_id ON transactions USING btree (contact_id);


--
-- Name: index_transactions_on_created_at; Type: INDEX; Schema: bonsai; Owner: -; Tablespace: 
--

CREATE INDEX index_transactions_on_created_at ON transactions USING btree (created_at);


--
-- Name: index_transactions_on_creditor_id; Type: INDEX; Schema: bonsai; Owner: -; Tablespace: 
--

CREATE INDEX index_transactions_on_creditor_id ON transactions USING btree (creditor_id);


--
-- Name: index_transactions_on_currency_id; Type: INDEX; Schema: bonsai; Owner: -; Tablespace: 
--

CREATE INDEX index_transactions_on_currency_id ON transactions USING btree (currency_id);


--
-- Name: index_transactions_on_date; Type: INDEX; Schema: bonsai; Owner: -; Tablespace: 
--

CREATE INDEX index_transactions_on_date ON transactions USING btree (date);


--
-- Name: index_transactions_on_deliver; Type: INDEX; Schema: bonsai; Owner: -; Tablespace: 
--

CREATE INDEX index_transactions_on_deliver ON transactions USING btree (deliver);


--
-- Name: index_transactions_on_deliver_approver_id; Type: INDEX; Schema: bonsai; Owner: -; Tablespace: 
--

CREATE INDEX index_transactions_on_deliver_approver_id ON transactions USING btree (deliver_approver_id);


--
-- Name: index_transactions_on_delivered; Type: INDEX; Schema: bonsai; Owner: -; Tablespace: 
--

CREATE INDEX index_transactions_on_delivered ON transactions USING btree (delivered);


--
-- Name: index_transactions_on_devolution; Type: INDEX; Schema: bonsai; Owner: -; Tablespace: 
--

CREATE INDEX index_transactions_on_devolution ON transactions USING btree (devolution);


--
-- Name: index_transactions_on_discounted; Type: INDEX; Schema: bonsai; Owner: -; Tablespace: 
--

CREATE INDEX index_transactions_on_discounted ON transactions USING btree (discounted);


--
-- Name: index_transactions_on_fact; Type: INDEX; Schema: bonsai; Owner: -; Tablespace: 
--

CREATE INDEX index_transactions_on_fact ON transactions USING btree (fact);


--
-- Name: index_transactions_on_has_error; Type: INDEX; Schema: bonsai; Owner: -; Tablespace: 
--

CREATE INDEX index_transactions_on_has_error ON transactions USING btree (has_error);


--
-- Name: index_transactions_on_modified_by; Type: INDEX; Schema: bonsai; Owner: -; Tablespace: 
--

CREATE INDEX index_transactions_on_modified_by ON transactions USING btree (modified_by);


--
-- Name: index_transactions_on_nuller_id; Type: INDEX; Schema: bonsai; Owner: -; Tablespace: 
--

CREATE INDEX index_transactions_on_nuller_id ON transactions USING btree (nuller_id);


--
-- Name: index_transactions_on_due_date; Type: INDEX; Schema: bonsai; Owner: -; Tablespace: 
--

CREATE INDEX index_transactions_on_due_date ON transactions USING btree (due_date);


--
-- Name: index_transactions_on_project_id; Type: INDEX; Schema: bonsai; Owner: -; Tablespace: 
--

CREATE INDEX index_transactions_on_project_id ON transactions USING btree (project_id);


--
-- Name: index_transactions_on_ref_number; Type: INDEX; Schema: bonsai; Owner: -; Tablespace: 
--

CREATE INDEX index_transactions_on_ref_number ON transactions USING btree (ref_number);


--
-- Name: index_transactions_on_state; Type: INDEX; Schema: bonsai; Owner: -; Tablespace: 
--

CREATE INDEX index_transactions_on_state ON transactions USING btree (state);


--
-- Name: unique_schema_migrations; Type: INDEX; Schema: bonsai; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX unique_schema_migrations ON schema_migrations USING btree (version);


SET search_path = common, pg_catalog;

--
-- Name: idx_qc_on_name_only_unlocked; Type: INDEX; Schema: common; Owner: -; Tablespace: 
--

CREATE INDEX idx_qc_on_name_only_unlocked ON queue_classic_jobs USING btree (q_name, id) WHERE (locked_at IS NULL);


--
-- Name: index_common.links_on_organisation_id; Type: INDEX; Schema: common; Owner: -; Tablespace: 
--

CREATE INDEX "index_common.links_on_organisation_id" ON links USING btree (organisation_id);


--
-- Name: index_common.links_on_user_id; Type: INDEX; Schema: common; Owner: -; Tablespace: 
--

CREATE INDEX "index_common.links_on_user_id" ON links USING btree (user_id);


--
-- Name: index_common.organisations_on_client_account_id; Type: INDEX; Schema: common; Owner: -; Tablespace: 
--

CREATE INDEX "index_common.organisations_on_client_account_id" ON organisations USING btree (client_account_id);


--
-- Name: index_common.organisations_on_country_id; Type: INDEX; Schema: common; Owner: -; Tablespace: 
--

CREATE INDEX "index_common.organisations_on_country_id" ON organisations USING btree (country_id);


--
-- Name: index_common.organisations_on_currency_id; Type: INDEX; Schema: common; Owner: -; Tablespace: 
--

CREATE INDEX "index_common.organisations_on_currency_id" ON organisations USING btree (currency_id);


--
-- Name: index_common.organisations_on_due_date; Type: INDEX; Schema: common; Owner: -; Tablespace: 
--

CREATE INDEX "index_common.organisations_on_due_date" ON organisations USING btree (due_date);


--
-- Name: index_common.organisations_on_tenant; Type: INDEX; Schema: common; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX "index_common.organisations_on_tenant" ON organisations USING btree (tenant);


--
-- Name: index_common.users_on_auth_token; Type: INDEX; Schema: common; Owner: -; Tablespace: 
--

CREATE INDEX "index_common.users_on_auth_token" ON users USING btree (auth_token);


--
-- Name: index_common.users_on_confirmation_token; Type: INDEX; Schema: common; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX "index_common.users_on_confirmation_token" ON users USING btree (confirmation_token);


--
-- Name: index_common.users_on_email; Type: INDEX; Schema: common; Owner: -; Tablespace: 
--

CREATE INDEX "index_common.users_on_email" ON users USING btree (email);


--
-- Name: index_common.users_on_first_name; Type: INDEX; Schema: common; Owner: -; Tablespace: 
--

CREATE INDEX "index_common.users_on_first_name" ON users USING btree (first_name);


--
-- Name: index_common.users_on_last_name; Type: INDEX; Schema: common; Owner: -; Tablespace: 
--

CREATE INDEX "index_common.users_on_last_name" ON users USING btree (last_name);


SET search_path = public, pg_catalog;

--
-- Name: index_account_balances_on_account_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_account_balances_on_account_id ON account_balances USING btree (account_id);


--
-- Name: index_account_balances_on_contact_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_account_balances_on_contact_id ON account_balances USING btree (contact_id);


--
-- Name: index_account_balances_on_currency_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_account_balances_on_currency_id ON account_balances USING btree (currency_id);


--
-- Name: index_account_balances_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_account_balances_on_user_id ON account_balances USING btree (user_id);


--
-- Name: index_account_ledger_details_on_account_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_account_ledger_details_on_account_id ON account_ledger_details USING btree (account_id);


--
-- Name: index_account_ledger_details_on_account_ledger_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_account_ledger_details_on_account_ledger_id ON account_ledger_details USING btree (account_ledger_id);


--
-- Name: index_account_ledger_details_on_active; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_account_ledger_details_on_active ON account_ledger_details USING btree (active);


--
-- Name: index_account_ledger_details_on_currency_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_account_ledger_details_on_currency_id ON account_ledger_details USING btree (currency_id);


--
-- Name: index_account_ledger_details_on_related_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_account_ledger_details_on_related_id ON account_ledger_details USING btree (related_id);


--
-- Name: index_account_ledger_details_on_state; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_account_ledger_details_on_state ON account_ledger_details USING btree (state);


--
-- Name: index_account_ledgers_on_account_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_account_ledgers_on_account_id ON account_ledgers USING btree (account_id);


--
-- Name: index_account_ledgers_on_active; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_account_ledgers_on_active ON account_ledgers USING btree (active);


--
-- Name: index_account_ledgers_on_approver_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_account_ledgers_on_approver_id ON account_ledgers USING btree (approver_id);


--
-- Name: index_account_ledgers_on_conciliation; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_account_ledgers_on_conciliation ON account_ledgers USING btree (conciliation);


--
-- Name: index_account_ledgers_on_contact_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_account_ledgers_on_contact_id ON account_ledgers USING btree (contact_id);


--
-- Name: index_account_ledgers_on_created_at; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_account_ledgers_on_created_at ON account_ledgers USING btree (created_at);


--
-- Name: index_account_ledgers_on_creator_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_account_ledgers_on_creator_id ON account_ledgers USING btree (creator_id);


--
-- Name: index_account_ledgers_on_currency_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_account_ledgers_on_currency_id ON account_ledgers USING btree (currency_id);


--
-- Name: index_account_ledgers_on_date; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_account_ledgers_on_date ON account_ledgers USING btree (date);


--
-- Name: index_account_ledgers_on_has_error; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_account_ledgers_on_has_error ON account_ledgers USING btree (has_error);


--
-- Name: index_account_ledgers_on_inverse; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_account_ledgers_on_inverse ON account_ledgers USING btree (inverse);


--
-- Name: index_account_ledgers_on_nuller_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_account_ledgers_on_nuller_id ON account_ledgers USING btree (nuller_id);


--
-- Name: index_account_ledgers_on_operation; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_account_ledgers_on_operation ON account_ledgers USING btree (operation);


--
-- Name: index_account_ledgers_on_project_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_account_ledgers_on_project_id ON account_ledgers USING btree (project_id);


--
-- Name: index_account_ledgers_on_reference; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_account_ledgers_on_reference ON account_ledgers USING btree (reference);


--
-- Name: index_account_ledgers_on_staff_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_account_ledgers_on_staff_id ON account_ledgers USING btree (staff_id);


--
-- Name: index_account_ledgers_on_status; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_account_ledgers_on_status ON account_ledgers USING btree (status);


--
-- Name: index_account_ledgers_on_to_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_account_ledgers_on_to_id ON account_ledgers USING btree (to_id);


--
-- Name: index_account_ledgers_on_transaction_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_account_ledgers_on_transaction_id ON account_ledgers USING btree (transaction_id);


--
-- Name: index_account_ledgers_on_transaction_type; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_account_ledgers_on_transaction_type ON account_ledgers USING btree (transaction_type);


--
-- Name: index_account_types_on_account_number; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_account_types_on_account_number ON account_types USING btree (account_number);


--
-- Name: index_accounts_on_account_type_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_accounts_on_account_type_id ON accounts USING btree (account_type_id);


--
-- Name: index_accounts_on_accountable_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_accounts_on_accountable_id ON accounts USING btree (accountable_id);


--
-- Name: index_accounts_on_accountable_type; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_accounts_on_accountable_type ON accounts USING btree (accountable_type);


--
-- Name: index_accounts_on_amount; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_accounts_on_amount ON accounts USING btree (amount);


--
-- Name: index_accounts_on_currency_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_accounts_on_currency_id ON accounts USING btree (currency_id);


--
-- Name: index_accounts_on_original_type; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_accounts_on_original_type ON accounts USING btree (original_type);


--
-- Name: index_accounts_on_type; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_accounts_on_type ON accounts USING btree (type);


--
-- Name: index_contacts_on_first_name; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_contacts_on_first_name ON contacts USING btree (first_name);


--
-- Name: index_contacts_on_last_name; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_contacts_on_last_name ON contacts USING btree (last_name);


--
-- Name: index_contacts_on_matchcode; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_contacts_on_matchcode ON contacts USING btree (matchcode);


--
-- Name: index_contacts_on_type; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_contacts_on_type ON contacts USING btree (type);


--
-- Name: index_inventory_operation_details_on_contact_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_inventory_operation_details_on_contact_id ON inventory_operation_details USING btree (contact_id);


--
-- Name: index_inventory_operation_details_on_inventory_operation_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_inventory_operation_details_on_inventory_operation_id ON inventory_operation_details USING btree (inventory_operation_id);


--
-- Name: index_inventory_operation_details_on_item_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_inventory_operation_details_on_item_id ON inventory_operation_details USING btree (item_id);


--
-- Name: index_inventory_operation_details_on_operation; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_inventory_operation_details_on_operation ON inventory_operation_details USING btree (operation);


--
-- Name: index_inventory_operation_details_on_store_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_inventory_operation_details_on_store_id ON inventory_operation_details USING btree (store_id);


--
-- Name: index_inventory_operation_details_on_transaction_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_inventory_operation_details_on_transaction_id ON inventory_operation_details USING btree (transaction_id);


--
-- Name: index_inventory_operations_on_contact_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_inventory_operations_on_contact_id ON inventory_operations USING btree (contact_id);


--
-- Name: index_inventory_operations_on_creator_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_inventory_operations_on_creator_id ON inventory_operations USING btree (creator_id);


--
-- Name: index_inventory_operations_on_date; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_inventory_operations_on_date ON inventory_operations USING btree (date);


--
-- Name: index_inventory_operations_on_has_error; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_inventory_operations_on_has_error ON inventory_operations USING btree (has_error);


--
-- Name: index_inventory_operations_on_operation; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_inventory_operations_on_operation ON inventory_operations USING btree (operation);


--
-- Name: index_inventory_operations_on_project_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_inventory_operations_on_project_id ON inventory_operations USING btree (project_id);


--
-- Name: index_inventory_operations_on_ref_number; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_inventory_operations_on_ref_number ON inventory_operations USING btree (ref_number);


--
-- Name: index_inventory_operations_on_state; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_inventory_operations_on_state ON inventory_operations USING btree (state);


--
-- Name: index_inventory_operations_on_store_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_inventory_operations_on_store_id ON inventory_operations USING btree (store_id);


--
-- Name: index_inventory_operations_on_transaction_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_inventory_operations_on_transaction_id ON inventory_operations USING btree (transaction_id);


--
-- Name: index_inventory_operations_on_transference_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_inventory_operations_on_transference_id ON inventory_operations USING btree (transference_id);


--
-- Name: index_items_on_code; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_items_on_code ON items USING btree (code);


--
-- Name: index_items_on_ctype; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_items_on_ctype ON items USING btree (ctype);


--
-- Name: index_items_on_for_sale; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_items_on_for_sale ON items USING btree (for_sale);


--
-- Name: index_items_on_stockable; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_items_on_stockable ON items USING btree (stockable);


--
-- Name: index_items_on_type; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_items_on_type ON items USING btree (type);


--
-- Name: index_items_on_unit_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_items_on_unit_id ON items USING btree (unit_id);


--
-- Name: index_money_stores_on_currency_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_money_stores_on_currency_id ON money_stores USING btree (currency_id);


--
-- Name: index_money_stores_on_name; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_money_stores_on_name ON money_stores USING btree (name);


--
-- Name: index_money_stores_on_type; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_money_stores_on_type ON money_stores USING btree (type);


--
-- Name: index_pay_plans_on_ctype; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_pay_plans_on_ctype ON pay_plans USING btree (ctype);


--
-- Name: index_pay_plans_on_operation; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_pay_plans_on_operation ON pay_plans USING btree (operation);


--
-- Name: index_pay_plans_on_paid; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_pay_plans_on_paid ON pay_plans USING btree (paid);


--
-- Name: index_pay_plans_on_due_date; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_pay_plans_on_due_date ON pay_plans USING btree (due_date);


--
-- Name: index_pay_plans_on_project_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_pay_plans_on_project_id ON pay_plans USING btree (project_id);


--
-- Name: index_pay_plans_on_transaction_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_pay_plans_on_transaction_id ON pay_plans USING btree (transaction_id);


--
-- Name: index_payments_on_account_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_payments_on_account_id ON payments USING btree (account_id);


--
-- Name: index_payments_on_account_ledger_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_payments_on_account_ledger_id ON payments USING btree (account_ledger_id);


--
-- Name: index_payments_on_contact_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_payments_on_contact_id ON payments USING btree (contact_id);


--
-- Name: index_payments_on_ctype; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_payments_on_ctype ON payments USING btree (ctype);


--
-- Name: index_payments_on_date; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_payments_on_date ON payments USING btree (date);


--
-- Name: index_payments_on_transaction_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_payments_on_transaction_id ON payments USING btree (transaction_id);


--
-- Name: index_prices_on_item_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_prices_on_item_id ON prices USING btree (item_id);


--
-- Name: index_projects_on_active; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_projects_on_active ON projects USING btree (active);


--
-- Name: index_stocks_on_item_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_stocks_on_item_id ON stocks USING btree (item_id);


--
-- Name: index_stocks_on_minimum; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_stocks_on_minimum ON stocks USING btree (minimum);


--
-- Name: index_stocks_on_quantity; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_stocks_on_quantity ON stocks USING btree (quantity);


--
-- Name: index_stocks_on_state; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_stocks_on_state ON stocks USING btree (state);


--
-- Name: index_stocks_on_store_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_stocks_on_store_id ON stocks USING btree (store_id);


--
-- Name: index_stocks_on_updated_at; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_stocks_on_updated_at ON stocks USING btree (updated_at);


--
-- Name: index_stocks_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_stocks_on_user_id ON stocks USING btree (user_id);


--
-- Name: index_taxes_transactions_on_tax_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_taxes_transactions_on_tax_id ON taxes_transactions USING btree (tax_id);


--
-- Name: index_taxes_transactions_on_tax_id_and_transaction_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_taxes_transactions_on_tax_id_and_transaction_id ON taxes_transactions USING btree (tax_id, transaction_id);


--
-- Name: index_taxes_transactions_on_transaction_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_taxes_transactions_on_transaction_id ON taxes_transactions USING btree (transaction_id);


--
-- Name: index_transaction_details_on_ctype; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_transaction_details_on_ctype ON transaction_details USING btree (ctype);


--
-- Name: index_transaction_details_on_item_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_transaction_details_on_item_id ON transaction_details USING btree (item_id);


--
-- Name: index_transaction_details_on_transaction_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_transaction_details_on_transaction_id ON transaction_details USING btree (transaction_id);


--
-- Name: index_transaction_histories_on_transaction_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_transaction_histories_on_transaction_id ON transaction_histories USING btree (transaction_id);


--
-- Name: index_transaction_histories_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_transaction_histories_on_user_id ON transaction_histories USING btree (user_id);


--
-- Name: index_transactions_on_account_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_transactions_on_account_id ON transactions USING btree (account_id);


--
-- Name: index_transactions_on_active; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_transactions_on_active ON transactions USING btree (active);


--
-- Name: index_transactions_on_balance_inventory; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_transactions_on_balance_inventory ON transactions USING btree (balance_inventory);


--
-- Name: index_transactions_on_cash; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_transactions_on_cash ON transactions USING btree (cash);


--
-- Name: index_transactions_on_contact_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_transactions_on_contact_id ON transactions USING btree (contact_id);


--
-- Name: index_transactions_on_created_at; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_transactions_on_created_at ON transactions USING btree (created_at);


--
-- Name: index_transactions_on_creditor_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_transactions_on_creditor_id ON transactions USING btree (creditor_id);


--
-- Name: index_transactions_on_currency_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_transactions_on_currency_id ON transactions USING btree (currency_id);


--
-- Name: index_transactions_on_date; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_transactions_on_date ON transactions USING btree (date);


--
-- Name: index_transactions_on_deliver; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_transactions_on_deliver ON transactions USING btree (deliver);


--
-- Name: index_transactions_on_deliver_approver_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_transactions_on_deliver_approver_id ON transactions USING btree (deliver_approver_id);


--
-- Name: index_transactions_on_delivered; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_transactions_on_delivered ON transactions USING btree (delivered);


--
-- Name: index_transactions_on_devolution; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_transactions_on_devolution ON transactions USING btree (devolution);


--
-- Name: index_transactions_on_discounted; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_transactions_on_discounted ON transactions USING btree (discounted);


--
-- Name: index_transactions_on_fact; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_transactions_on_fact ON transactions USING btree (fact);


--
-- Name: index_transactions_on_has_error; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_transactions_on_has_error ON transactions USING btree (has_error);


--
-- Name: index_transactions_on_modified_by; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_transactions_on_modified_by ON transactions USING btree (modified_by);


--
-- Name: index_transactions_on_nuller_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_transactions_on_nuller_id ON transactions USING btree (nuller_id);


--
-- Name: index_transactions_on_due_date; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_transactions_on_due_date ON transactions USING btree (due_date);


--
-- Name: index_transactions_on_project_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_transactions_on_project_id ON transactions USING btree (project_id);


--
-- Name: index_transactions_on_ref_number; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_transactions_on_ref_number ON transactions USING btree (ref_number);


--
-- Name: index_transactions_on_state; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_transactions_on_state ON transactions USING btree (state);


--
-- Name: unique_schema_migrations; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX unique_schema_migrations ON schema_migrations USING btree (version);


--
-- PostgreSQL database dump complete
--

INSERT INTO schema_migrations (version) VALUES ('20100101101010');

INSERT INTO schema_migrations (version) VALUES ('20100324202441');

INSERT INTO schema_migrations (version) VALUES ('20100325212939');

INSERT INTO schema_migrations (version) VALUES ('20100325221629');

INSERT INTO schema_migrations (version) VALUES ('20100330214802');

INSERT INTO schema_migrations (version) VALUES ('20100401192000');

INSERT INTO schema_migrations (version) VALUES ('20100414180825');

INSERT INTO schema_migrations (version) VALUES ('20100416193705');

INSERT INTO schema_migrations (version) VALUES ('20100421174307');

INSERT INTO schema_migrations (version) VALUES ('20100427190727');

INSERT INTO schema_migrations (version) VALUES ('20100531141109');

INSERT INTO schema_migrations (version) VALUES ('20101006212223');

INSERT INTO schema_migrations (version) VALUES ('20101007032653');

INSERT INTO schema_migrations (version) VALUES ('20101026230758');

INSERT INTO schema_migrations (version) VALUES ('20110119140408');

INSERT INTO schema_migrations (version) VALUES ('20110119160057');

INSERT INTO schema_migrations (version) VALUES ('20110127181906');

INSERT INTO schema_migrations (version) VALUES ('20110201144429');

INSERT INTO schema_migrations (version) VALUES ('20110201153434');

INSERT INTO schema_migrations (version) VALUES ('20110201161907');

INSERT INTO schema_migrations (version) VALUES ('20110411174426');

INSERT INTO schema_migrations (version) VALUES ('20110411182005');

INSERT INTO schema_migrations (version) VALUES ('20110411182905');

INSERT INTO schema_migrations (version) VALUES ('20110601192036');

INSERT INTO schema_migrations (version) VALUES ('20110601200753');

INSERT INTO schema_migrations (version) VALUES ('20110608151314');

INSERT INTO schema_migrations (version) VALUES ('20110711205129');

INSERT INTO schema_migrations (version) VALUES ('20110817190851');

INSERT INTO schema_migrations (version) VALUES ('20110822184842');

INSERT INTO schema_migrations (version) VALUES ('20110823182653');

INSERT INTO schema_migrations (version) VALUES ('20110824124311');

INSERT INTO schema_migrations (version) VALUES ('20110831184724');

INSERT INTO schema_migrations (version) VALUES ('20110901210941');

INSERT INTO schema_migrations (version) VALUES ('20110907155314');

INSERT INTO schema_migrations (version) VALUES ('20110908160542');

INSERT INTO schema_migrations (version) VALUES ('20110910194717');

INSERT INTO schema_migrations (version) VALUES ('20110911162450');

INSERT INTO schema_migrations (version) VALUES ('20110916175327');

INSERT INTO schema_migrations (version) VALUES ('20110919150401');

INSERT INTO schema_migrations (version) VALUES ('20110929210133');

INSERT INTO schema_migrations (version) VALUES ('20111004214811');

INSERT INTO schema_migrations (version) VALUES ('20111012142328');

INSERT INTO schema_migrations (version) VALUES ('20111020162732');

INSERT INTO schema_migrations (version) VALUES ('20111103143524');

INSERT INTO schema_migrations (version) VALUES ('20111103164257');

INSERT INTO schema_migrations (version) VALUES ('20111114185926');

INSERT INTO schema_migrations (version) VALUES ('20111117201201');

INSERT INTO schema_migrations (version) VALUES ('20111121204629');

INSERT INTO schema_migrations (version) VALUES ('20111123171035');

INSERT INTO schema_migrations (version) VALUES ('20111128194315');

INSERT INTO schema_migrations (version) VALUES ('20111129155318');

INSERT INTO schema_migrations (version) VALUES ('20120109190911');

INSERT INTO schema_migrations (version) VALUES ('20120123221029');

INSERT INTO schema_migrations (version) VALUES ('20120125210732');

INSERT INTO schema_migrations (version) VALUES ('20120127123204');

INSERT INTO schema_migrations (version) VALUES ('20120308030345');

INSERT INTO schema_migrations (version) VALUES ('20120517130511');

INSERT INTO schema_migrations (version) VALUES ('20121011155712');

INSERT INTO schema_migrations (version) VALUES ('20121017094703');
