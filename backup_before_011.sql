--
-- PostgreSQL database dump
--

\restrict RoghM5lRQwEp6tBS79a7qvFKzcS0zRMetaGzZPfTYRB0mqHg86b0tucKFwVhQc4

-- Dumped from database version 14.20 (Debian 14.20-1.pgdg13+1)
-- Dumped by pg_dump version 14.20 (Debian 14.20-1.pgdg13+1)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: pb3gir75kkooyea; Type: SCHEMA; Schema: -; Owner: admin
--

CREATE SCHEMA pb3gir75kkooyea;


ALTER SCHEMA pb3gir75kkooyea OWNER TO admin;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: account_opening_request; Type: TABLE; Schema: pb3gir75kkooyea; Owner: admin
--

CREATE TABLE pb3gir75kkooyea.account_opening_request (
    id text NOT NULL,
    runtime_id text NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    version bigint NOT NULL,
    request_no text NOT NULL,
    user_id text NOT NULL,
    application_id text NOT NULL,
    reason text NOT NULL,
    contact text DEFAULT ''::text NOT NULL,
    remark text DEFAULT ''::text NOT NULL,
    status text NOT NULL,
    submitted_at timestamp with time zone NOT NULL,
    handled_by text,
    handled_at timestamp with time zone,
    handle_note text,
    CONSTRAINT account_opening_request_status_check CHECK ((status = ANY (ARRAY['PENDING'::text, 'PROCESSING'::text, 'COMPLETED'::text, 'REJECTED'::text, 'CANCELLED'::text]))),
    CONSTRAINT account_opening_request_version_check CHECK ((version >= 1))
);


ALTER TABLE pb3gir75kkooyea.account_opening_request OWNER TO admin;

--
-- Name: announcement; Type: TABLE; Schema: pb3gir75kkooyea; Owner: admin
--

CREATE TABLE pb3gir75kkooyea.announcement (
    nc_id integer NOT NULL,
    created_at1 timestamp without time zone,
    updated_at1 timestamp without time zone,
    created_by character varying,
    updated_by character varying,
    nc_order numeric,
    id text NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    version bigint DEFAULT 1 NOT NULL,
    title text NOT NULL,
    announcement_type text NOT NULL,
    content text NOT NULL,
    scope text DEFAULT 'ALL'::text NOT NULL,
    status text DEFAULT 'DRAFT'::text NOT NULL,
    effective_start timestamp with time zone,
    effective_end timestamp with time zone,
    publisher_id text,
    published_at timestamp with time zone,
    runtime_id text,
    publish_mode text,
    scheduled_publish_at timestamp with time zone,
    submitted_at timestamp with time zone,
    submitted_by text,
    withdrawn_at timestamp with time zone,
    withdrawn_by text,
    withdrawn_reason text,
    last_edited_at timestamp with time zone,
    last_edited_by text,
    deleted_at timestamp with time zone,
    deleted_by text,
    delete_reason text,
    CONSTRAINT announcement_publish_mode_check CHECK (((publish_mode IS NULL) OR (publish_mode = ANY (ARRAY['IMMEDIATE'::text, 'SCHEDULED'::text])))),
    CONSTRAINT p3_announcement_033c1c2718d0 CHECK (((effective_end IS NULL) OR (effective_start IS NULL) OR (effective_end > effective_start))),
    CONSTRAINT p3_announcement_6d735cfb827e CHECK (((status <> 'PUBLISHED'::text) OR ((publisher_id IS NOT NULL) AND (published_at IS NOT NULL)))),
    CONSTRAINT p3_announcement_96d5cd6fd37a CHECK ((version >= 1)),
    CONSTRAINT p3_announcement_c017f9d8f3ae CHECK ((scope = ANY (ARRAY['ALL'::text, 'CITIZEN'::text, 'GOV'::text, 'ORG'::text]))),
    CONSTRAINT p3_announcement_db123e2570fc CHECK ((status = ANY (ARRAY['DRAFT'::text, 'PUBLISHED'::text, 'WITHDRAWN'::text, 'EXPIRED'::text])))
);


ALTER TABLE pb3gir75kkooyea.announcement OWNER TO admin;

--
-- Name: COLUMN announcement.runtime_id; Type: COMMENT; Schema: pb3gir75kkooyea; Owner: admin
--

COMMENT ON COLUMN pb3gir75kkooyea.announcement.runtime_id IS 'Stable portal DTO id; physical ids may retain the P4FIX prefix.';


--
-- Name: COLUMN announcement.deleted_at; Type: COMMENT; Schema: pb3gir75kkooyea; Owner: admin
--

COMMENT ON COLUMN pb3gir75kkooyea.announcement.deleted_at IS 'Soft-delete/archive timestamp; archived announcements are excluded from normal reads.';


--
-- Name: CONSTRAINT p3_announcement_033c1c2718d0 ON announcement; Type: COMMENT; Schema: pb3gir75kkooyea; Owner: admin
--

COMMENT ON CONSTRAINT p3_announcement_033c1c2718d0 ON pb3gir75kkooyea.announcement IS 'P3|033c1c2718d0ac2b209af698ea6140b3bb9b468dbaaf67b02e92da2891dfbc7a|CHECK (((effective_end IS NULL) OR (effective_start IS NULL) OR (effective_end > effective_start)))';


--
-- Name: CONSTRAINT p3_announcement_6d735cfb827e ON announcement; Type: COMMENT; Schema: pb3gir75kkooyea; Owner: admin
--

COMMENT ON CONSTRAINT p3_announcement_6d735cfb827e ON pb3gir75kkooyea.announcement IS 'P3|6d735cfb827ea37d90edb130aa8dcb57d010f2848fc74f5a124d6bd7aabb189d|CHECK (((status <> ''PUBLISHED''::text) OR ((publisher_id IS NOT NULL) AND (published_at IS NOT NULL))))';


--
-- Name: CONSTRAINT p3_announcement_96d5cd6fd37a ON announcement; Type: COMMENT; Schema: pb3gir75kkooyea; Owner: admin
--

COMMENT ON CONSTRAINT p3_announcement_96d5cd6fd37a ON pb3gir75kkooyea.announcement IS 'P3|96d5cd6fd37a65123060b0f30cbfda68046602a4e4960b638d65f1cd8c083024|CHECK ((version >= 1))';


--
-- Name: CONSTRAINT p3_announcement_c017f9d8f3ae ON announcement; Type: COMMENT; Schema: pb3gir75kkooyea; Owner: admin
--

COMMENT ON CONSTRAINT p3_announcement_c017f9d8f3ae ON pb3gir75kkooyea.announcement IS 'P3|c017f9d8f3ae94fef9f665f5a1ab06e42396458f0e4b76c933db8a09f19aa966|CHECK ((scope = ANY (ARRAY[''ALL''::text, ''CITIZEN''::text, ''GOV''::text, ''ORG''::text])))';


--
-- Name: CONSTRAINT p3_announcement_db123e2570fc ON announcement; Type: COMMENT; Schema: pb3gir75kkooyea; Owner: admin
--

COMMENT ON CONSTRAINT p3_announcement_db123e2570fc ON pb3gir75kkooyea.announcement IS 'P3|db123e2570fc49006f5144f2ec798f3c7d087c5c41354d618ab6ba9f4278ea14|CHECK ((status = ANY (ARRAY[''DRAFT''::text, ''PUBLISHED''::text, ''WITHDRAWN''::text, ''EXPIRED''::text])))';


--
-- Name: announcement_attachment; Type: TABLE; Schema: pb3gir75kkooyea; Owner: admin
--

CREATE TABLE pb3gir75kkooyea.announcement_attachment (
    nc_id integer NOT NULL,
    created_at1 timestamp without time zone,
    updated_at1 timestamp without time zone,
    created_by character varying,
    updated_by character varying,
    nc_order numeric,
    id text NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    version bigint DEFAULT 1 NOT NULL,
    announcement_id text NOT NULL,
    file_name text NOT NULL,
    size_bytes bigint NOT NULL,
    mime_type text NOT NULL,
    attachment text NOT NULL,
    uploaded_by text,
    sort_order bigint DEFAULT 0 NOT NULL,
    runtime_id text,
    CONSTRAINT p3_announcement_attachment_7dac1f299fa6 CHECK ((size_bytes >= 0)),
    CONSTRAINT p3_announcement_attachment_8d1434e8dc58 CHECK (((attachment IS NULL) OR (jsonb_typeof((attachment)::jsonb) IS NOT NULL))),
    CONSTRAINT p3_announcement_attachment_b6332a8e883b CHECK ((version >= 1))
);


ALTER TABLE pb3gir75kkooyea.announcement_attachment OWNER TO admin;

--
-- Name: CONSTRAINT p3_announcement_attachment_7dac1f299fa6 ON announcement_attachment; Type: COMMENT; Schema: pb3gir75kkooyea; Owner: admin
--

COMMENT ON CONSTRAINT p3_announcement_attachment_7dac1f299fa6 ON pb3gir75kkooyea.announcement_attachment IS 'P3|7dac1f299fa60821170ec6287423cda49d3402cab74fb778738c65eddca6203f|CHECK ((size_bytes >= 0))';


--
-- Name: CONSTRAINT p3_announcement_attachment_8d1434e8dc58 ON announcement_attachment; Type: COMMENT; Schema: pb3gir75kkooyea; Owner: admin
--

COMMENT ON CONSTRAINT p3_announcement_attachment_8d1434e8dc58 ON pb3gir75kkooyea.announcement_attachment IS 'P3|8d1434e8dc5807acc4cb9537f14b695d18dca74274f026d873a2c4798d2fe18e|CHECK (((attachment IS NULL) OR (jsonb_typeof((attachment)::jsonb) IS NOT NULL)))';


--
-- Name: CONSTRAINT p3_announcement_attachment_b6332a8e883b ON announcement_attachment; Type: COMMENT; Schema: pb3gir75kkooyea; Owner: admin
--

COMMENT ON CONSTRAINT p3_announcement_attachment_b6332a8e883b ON pb3gir75kkooyea.announcement_attachment IS 'P3|b6332a8e883ba45176c7efcfeee6428beafa829e9f657ca7ca9e5b784c2f96ef|CHECK ((version >= 1))';


--
-- Name: announcement_attachment_nc_id_seq; Type: SEQUENCE; Schema: pb3gir75kkooyea; Owner: admin
--

CREATE SEQUENCE pb3gir75kkooyea.announcement_attachment_nc_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE pb3gir75kkooyea.announcement_attachment_nc_id_seq OWNER TO admin;

--
-- Name: announcement_attachment_nc_id_seq; Type: SEQUENCE OWNED BY; Schema: pb3gir75kkooyea; Owner: admin
--

ALTER SEQUENCE pb3gir75kkooyea.announcement_attachment_nc_id_seq OWNED BY pb3gir75kkooyea.announcement_attachment.nc_id;


--
-- Name: announcement_nc_id_seq; Type: SEQUENCE; Schema: pb3gir75kkooyea; Owner: admin
--

CREATE SEQUENCE pb3gir75kkooyea.announcement_nc_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE pb3gir75kkooyea.announcement_nc_id_seq OWNER TO admin;

--
-- Name: announcement_nc_id_seq; Type: SEQUENCE OWNED BY; Schema: pb3gir75kkooyea; Owner: admin
--

ALTER SEQUENCE pb3gir75kkooyea.announcement_nc_id_seq OWNED BY pb3gir75kkooyea.announcement.nc_id;


--
-- Name: announcement_org_scope; Type: TABLE; Schema: pb3gir75kkooyea; Owner: admin
--

CREATE TABLE pb3gir75kkooyea.announcement_org_scope (
    nc_id integer NOT NULL,
    created_at1 timestamp without time zone,
    updated_at1 timestamp without time zone,
    created_by character varying,
    updated_by character varying,
    nc_order numeric,
    id text NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    version bigint DEFAULT 1 NOT NULL,
    announcement_id text NOT NULL,
    identity_source_code text NOT NULL,
    org_key text NOT NULL,
    CONSTRAINT p3_announcement_org_scope_f6873d76e7b8 CHECK ((version >= 1))
);


ALTER TABLE pb3gir75kkooyea.announcement_org_scope OWNER TO admin;

--
-- Name: CONSTRAINT p3_announcement_org_scope_f6873d76e7b8 ON announcement_org_scope; Type: COMMENT; Schema: pb3gir75kkooyea; Owner: admin
--

COMMENT ON CONSTRAINT p3_announcement_org_scope_f6873d76e7b8 ON pb3gir75kkooyea.announcement_org_scope IS 'P3|f6873d76e7b82991183f6cec9177f3f0663a0e9e733dbf4103d388fed6552fa4|CHECK ((version >= 1))';


--
-- Name: announcement_org_scope_nc_id_seq; Type: SEQUENCE; Schema: pb3gir75kkooyea; Owner: admin
--

CREATE SEQUENCE pb3gir75kkooyea.announcement_org_scope_nc_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE pb3gir75kkooyea.announcement_org_scope_nc_id_seq OWNER TO admin;

--
-- Name: announcement_org_scope_nc_id_seq; Type: SEQUENCE OWNED BY; Schema: pb3gir75kkooyea; Owner: admin
--

ALTER SEQUENCE pb3gir75kkooyea.announcement_org_scope_nc_id_seq OWNED BY pb3gir75kkooyea.announcement_org_scope.nc_id;


--
-- Name: announcement_read_receipt; Type: TABLE; Schema: pb3gir75kkooyea; Owner: admin
--

CREATE TABLE pb3gir75kkooyea.announcement_read_receipt (
    id text NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    version bigint DEFAULT 1 NOT NULL,
    announcement_id text NOT NULL,
    user_id text NOT NULL,
    read_at timestamp with time zone NOT NULL,
    CONSTRAINT announcement_read_receipt_version_check CHECK ((version >= 1))
);


ALTER TABLE pb3gir75kkooyea.announcement_read_receipt OWNER TO admin;

--
-- Name: TABLE announcement_read_receipt; Type: COMMENT; Schema: pb3gir75kkooyea; Owner: admin
--

COMMENT ON TABLE pb3gir75kkooyea.announcement_read_receipt IS 'Per-user idempotent announcement read receipt.';


--
-- Name: application; Type: TABLE; Schema: pb3gir75kkooyea; Owner: admin
--

CREATE TABLE pb3gir75kkooyea.application (
    nc_id integer NOT NULL,
    created_at1 timestamp without time zone,
    updated_at1 timestamp without time zone,
    created_by character varying,
    updated_by character varying,
    nc_order numeric,
    id text NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    version bigint DEFAULT 1 NOT NULL,
    code text NOT NULL,
    name text NOT NULL,
    category_id text,
    network_zone text,
    user_type text NOT NULL,
    application_url text NOT NULL,
    logo_url text,
    description text,
    contact_name text,
    technical_contact text,
    sort_order bigint DEFAULT 0 NOT NULL,
    status text DEFAULT 'DISABLED'::text NOT NULL,
    runtime_status text DEFAULT 'UNCONFIGURED'::text NOT NULL,
    allowed_origins text DEFAULT '[]'::text NOT NULL,
    binding_methods text DEFAULT '[]'::text NOT NULL,
    runtime_id text,
    runtime_payload jsonb,
    deleted_at timestamp with time zone,
    CONSTRAINT p3_application_02964c7c74be CHECK (((binding_methods IS NULL) OR (jsonb_typeof((binding_methods)::jsonb) IS NOT NULL))),
    CONSTRAINT p3_application_48a78c19e880 CHECK ((user_type = ANY (ARRAY['CITIZEN'::text, 'GOV'::text, 'BOTH'::text]))),
    CONSTRAINT p3_application_784d16254804 CHECK (((allowed_origins IS NULL) OR (jsonb_typeof((allowed_origins)::jsonb) IS NOT NULL))),
    CONSTRAINT p3_application_b448172ab694 CHECK ((status = ANY (ARRAY['ENABLED'::text, 'DISABLED'::text]))),
    CONSTRAINT p3_application_bc9eb911168e CHECK ((version >= 1)),
    CONSTRAINT p3_application_e3b618e81a7c CHECK ((runtime_status = ANY (ARRAY['NORMAL'::text, 'ABNORMAL'::text, 'UNCONFIGURED'::text, 'DISABLED'::text])))
);


ALTER TABLE pb3gir75kkooyea.application OWNER TO admin;

--
-- Name: COLUMN application.runtime_payload; Type: COMMENT; Schema: pb3gir75kkooyea; Owner: admin
--

COMMENT ON COLUMN pb3gir75kkooyea.application.runtime_payload IS 'Portal catalog display and local demonstration fields; normalized columns remain authoritative.';


--
-- Name: COLUMN application.deleted_at; Type: COMMENT; Schema: pb3gir75kkooyea; Owner: admin
--

COMMENT ON COLUMN pb3gir75kkooyea.application.deleted_at IS 'Logical deletion retains application foreign-key history.';


--
-- Name: CONSTRAINT p3_application_02964c7c74be ON application; Type: COMMENT; Schema: pb3gir75kkooyea; Owner: admin
--

COMMENT ON CONSTRAINT p3_application_02964c7c74be ON pb3gir75kkooyea.application IS 'P3|02964c7c74be55ed39412dd35df15cf412f1c3f824427370028817634cb23b82|CHECK (((binding_methods IS NULL) OR (jsonb_typeof((binding_methods)::jsonb) IS NOT NULL)))';


--
-- Name: CONSTRAINT p3_application_48a78c19e880 ON application; Type: COMMENT; Schema: pb3gir75kkooyea; Owner: admin
--

COMMENT ON CONSTRAINT p3_application_48a78c19e880 ON pb3gir75kkooyea.application IS 'P3|48a78c19e880fc8de0ebb94a1514d39380f766e6e12b78da2139b59576e1a949|CHECK ((user_type = ANY (ARRAY[''CITIZEN''::text, ''GOV''::text, ''BOTH''::text])))';


--
-- Name: CONSTRAINT p3_application_784d16254804 ON application; Type: COMMENT; Schema: pb3gir75kkooyea; Owner: admin
--

COMMENT ON CONSTRAINT p3_application_784d16254804 ON pb3gir75kkooyea.application IS 'P3|784d162548049c231cf491f0c50e8199bf5100a41bdf64dd60537a31dadf7ab0|CHECK (((allowed_origins IS NULL) OR (jsonb_typeof((allowed_origins)::jsonb) IS NOT NULL)))';


--
-- Name: CONSTRAINT p3_application_b448172ab694 ON application; Type: COMMENT; Schema: pb3gir75kkooyea; Owner: admin
--

COMMENT ON CONSTRAINT p3_application_b448172ab694 ON pb3gir75kkooyea.application IS 'P3|b448172ab694bfa8a8d9568c79fa83abe0dff679425ca468092044e281945784|CHECK ((status = ANY (ARRAY[''ENABLED''::text, ''DISABLED''::text])))';


--
-- Name: CONSTRAINT p3_application_bc9eb911168e ON application; Type: COMMENT; Schema: pb3gir75kkooyea; Owner: admin
--

COMMENT ON CONSTRAINT p3_application_bc9eb911168e ON pb3gir75kkooyea.application IS 'P3|bc9eb911168e3ec888a53c167285b479254e49c49a231e84f0e0802b47061e5a|CHECK ((version >= 1))';


--
-- Name: CONSTRAINT p3_application_e3b618e81a7c ON application; Type: COMMENT; Schema: pb3gir75kkooyea; Owner: admin
--

COMMENT ON CONSTRAINT p3_application_e3b618e81a7c ON pb3gir75kkooyea.application IS 'P3|e3b618e81a7c5991b94a372c774fde1e1ba6b02a5aac2a36e4c8109835d3c814|CHECK ((runtime_status = ANY (ARRAY[''NORMAL''::text, ''ABNORMAL''::text, ''UNCONFIGURED''::text, ''DISABLED''::text])))';


--
-- Name: application_access_grant; Type: TABLE; Schema: pb3gir75kkooyea; Owner: admin
--

CREATE TABLE pb3gir75kkooyea.application_access_grant (
    id text NOT NULL,
    runtime_id text NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    version bigint NOT NULL,
    user_id text NOT NULL,
    application_id text NOT NULL,
    status text NOT NULL,
    granted_by text,
    granted_at timestamp with time zone,
    expires_at timestamp with time zone,
    CONSTRAINT application_access_grant_status_check CHECK ((status = ANY (ARRAY['ACTIVE'::text, 'REVOKED'::text, 'EXPIRED'::text]))),
    CONSTRAINT application_access_grant_version_check CHECK ((version >= 1))
);


ALTER TABLE pb3gir75kkooyea.application_access_grant OWNER TO admin;

--
-- Name: application_access_request; Type: TABLE; Schema: pb3gir75kkooyea; Owner: admin
--

CREATE TABLE pb3gir75kkooyea.application_access_request (
    id text NOT NULL,
    runtime_id text NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    version bigint NOT NULL,
    request_no text NOT NULL,
    user_id text NOT NULL,
    application_id text NOT NULL,
    reason text NOT NULL,
    contact text DEFAULT ''::text NOT NULL,
    remark text DEFAULT ''::text NOT NULL,
    status text NOT NULL,
    submitted_at timestamp with time zone NOT NULL,
    reviewed_by text,
    reviewed_at timestamp with time zone,
    review_note text,
    withdrawn_at timestamp with time zone,
    expired_at timestamp with time zone,
    CONSTRAINT application_access_request_status_check CHECK ((status = ANY (ARRAY['PENDING'::text, 'APPROVED'::text, 'REJECTED'::text, 'WITHDRAWN'::text, 'EXPIRED'::text]))),
    CONSTRAINT application_access_request_version_check CHECK ((version >= 1))
);


ALTER TABLE pb3gir75kkooyea.application_access_request OWNER TO admin;

--
-- Name: application_category; Type: TABLE; Schema: pb3gir75kkooyea; Owner: admin
--

CREATE TABLE pb3gir75kkooyea.application_category (
    nc_id integer NOT NULL,
    created_at1 timestamp without time zone,
    updated_at1 timestamp without time zone,
    created_by character varying,
    updated_by character varying,
    nc_order numeric,
    id text NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    version bigint DEFAULT 1 NOT NULL,
    code text NOT NULL,
    name text NOT NULL,
    icon text,
    sort_order bigint DEFAULT 0 NOT NULL,
    status text DEFAULT 'ENABLED'::text NOT NULL,
    remark text,
    runtime_id text,
    runtime_payload jsonb,
    deleted_at timestamp with time zone,
    CONSTRAINT p3_application_category_37ee9d58131b CHECK ((version >= 1)),
    CONSTRAINT p3_application_category_bbf6c38cdc58 CHECK ((status = ANY (ARRAY['ENABLED'::text, 'DISABLED'::text])))
);


ALTER TABLE pb3gir75kkooyea.application_category OWNER TO admin;

--
-- Name: CONSTRAINT p3_application_category_37ee9d58131b ON application_category; Type: COMMENT; Schema: pb3gir75kkooyea; Owner: admin
--

COMMENT ON CONSTRAINT p3_application_category_37ee9d58131b ON pb3gir75kkooyea.application_category IS 'P3|37ee9d58131b32980288488d2cc3b9adb8d29ad8f52adcdcdea7f8e721c7db62|CHECK ((version >= 1))';


--
-- Name: CONSTRAINT p3_application_category_bbf6c38cdc58 ON application_category; Type: COMMENT; Schema: pb3gir75kkooyea; Owner: admin
--

COMMENT ON CONSTRAINT p3_application_category_bbf6c38cdc58 ON pb3gir75kkooyea.application_category IS 'P3|bbf6c38cdc5864b310fbe40be6701633edef2be86ca37124526e09d14a283370|CHECK ((status = ANY (ARRAY[''ENABLED''::text, ''DISABLED''::text])))';


--
-- Name: application_category_nc_id_seq; Type: SEQUENCE; Schema: pb3gir75kkooyea; Owner: admin
--

CREATE SEQUENCE pb3gir75kkooyea.application_category_nc_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE pb3gir75kkooyea.application_category_nc_id_seq OWNER TO admin;

--
-- Name: application_category_nc_id_seq; Type: SEQUENCE OWNED BY; Schema: pb3gir75kkooyea; Owner: admin
--

ALTER SEQUENCE pb3gir75kkooyea.application_category_nc_id_seq OWNED BY pb3gir75kkooyea.application_category.nc_id;


--
-- Name: application_nc_id_seq; Type: SEQUENCE; Schema: pb3gir75kkooyea; Owner: admin
--

CREATE SEQUENCE pb3gir75kkooyea.application_nc_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE pb3gir75kkooyea.application_nc_id_seq OWNER TO admin;

--
-- Name: application_nc_id_seq; Type: SEQUENCE OWNED BY; Schema: pb3gir75kkooyea; Owner: admin
--

ALTER SEQUENCE pb3gir75kkooyea.application_nc_id_seq OWNED BY pb3gir75kkooyea.application.nc_id;


--
-- Name: application_user_mapping; Type: TABLE; Schema: pb3gir75kkooyea; Owner: admin
--

CREATE TABLE pb3gir75kkooyea.application_user_mapping (
    nc_id integer NOT NULL,
    created_at1 timestamp without time zone,
    updated_at1 timestamp without time zone,
    created_by character varying,
    updated_by character varying,
    nc_order numeric,
    id text NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    version bigint DEFAULT 1 NOT NULL,
    user_id text NOT NULL,
    application_id text NOT NULL,
    external_user_id text,
    external_account text,
    binding_method text,
    status text DEFAULT 'UNBOUND'::text NOT NULL,
    active_account_key text,
    verified_method text,
    verified_at timestamp with time zone,
    bound_at timestamp with time zone,
    unbound_at timestamp with time zone,
    conflict_reason text,
    CONSTRAINT p3_application_user_mapping_0f52ff390c6c CHECK ((((status = 'BOUND'::text) AND (external_user_id IS NOT NULL) AND (active_account_key IS NOT NULL)) OR ((status <> 'BOUND'::text) AND (active_account_key IS NULL)))),
    CONSTRAINT p3_application_user_mapping_4301624b1176 CHECK (((active_account_key IS NULL) OR ((active_account_key)::jsonb = jsonb_build_array(application_id, external_user_id)))),
    CONSTRAINT p3_application_user_mapping_54bd74ca0798 CHECK ((version >= 1)),
    CONSTRAINT p3_application_user_mapping_5648aeaafcaa CHECK ((binding_method = ANY (ARRAY['AUTO'::text, 'SELF'::text, 'ADMIN'::text]))),
    CONSTRAINT p3_application_user_mapping_d93a1bc6dd1d CHECK ((status = ANY (ARRAY['UNBOUND'::text, 'VERIFYING'::text, 'BOUND'::text, 'FAILED'::text, 'CONFLICT'::text])))
);


ALTER TABLE pb3gir75kkooyea.application_user_mapping OWNER TO admin;

--
-- Name: CONSTRAINT p3_application_user_mapping_0f52ff390c6c ON application_user_mapping; Type: COMMENT; Schema: pb3gir75kkooyea; Owner: admin
--

COMMENT ON CONSTRAINT p3_application_user_mapping_0f52ff390c6c ON pb3gir75kkooyea.application_user_mapping IS 'P3|0f52ff390c6c0a843cd8b4649b783e700d4c73a3f47f805e4b7045f35bf174a2|CHECK ((((status = ''BOUND''::text) AND (external_user_id IS NOT NULL) AND (active_account_key IS NOT NULL)) OR ((status <> ''BOUND''::text) AND (active_account_key IS NULL))))';


--
-- Name: CONSTRAINT p3_application_user_mapping_4301624b1176 ON application_user_mapping; Type: COMMENT; Schema: pb3gir75kkooyea; Owner: admin
--

COMMENT ON CONSTRAINT p3_application_user_mapping_4301624b1176 ON pb3gir75kkooyea.application_user_mapping IS 'P3|4301624b1176d494f009a018043b12b191e89cee91b85a915e939aca829feffa|CHECK (((active_account_key IS NULL) OR ((active_account_key)::jsonb = jsonb_build_array(application_id, external_user_id))))';


--
-- Name: CONSTRAINT p3_application_user_mapping_54bd74ca0798 ON application_user_mapping; Type: COMMENT; Schema: pb3gir75kkooyea; Owner: admin
--

COMMENT ON CONSTRAINT p3_application_user_mapping_54bd74ca0798 ON pb3gir75kkooyea.application_user_mapping IS 'P3|54bd74ca0798a435ece1d5eb4b6985c98042502ce3fd5c70fd52d789e401f20a|CHECK ((version >= 1))';


--
-- Name: CONSTRAINT p3_application_user_mapping_5648aeaafcaa ON application_user_mapping; Type: COMMENT; Schema: pb3gir75kkooyea; Owner: admin
--

COMMENT ON CONSTRAINT p3_application_user_mapping_5648aeaafcaa ON pb3gir75kkooyea.application_user_mapping IS 'P3|5648aeaafcaa3fc16840a70bfad8c731408b6cad0a390d57803a0c02b52869fe|CHECK ((binding_method = ANY (ARRAY[''AUTO''::text, ''SELF''::text, ''ADMIN''::text])))';


--
-- Name: CONSTRAINT p3_application_user_mapping_d93a1bc6dd1d ON application_user_mapping; Type: COMMENT; Schema: pb3gir75kkooyea; Owner: admin
--

COMMENT ON CONSTRAINT p3_application_user_mapping_d93a1bc6dd1d ON pb3gir75kkooyea.application_user_mapping IS 'P3|d93a1bc6dd1d15abe1c5c26fa82b22d234f23d6362efe2347264ec12428709e8|CHECK ((status = ANY (ARRAY[''UNBOUND''::text, ''VERIFYING''::text, ''BOUND''::text, ''FAILED''::text, ''CONFLICT''::text])))';


--
-- Name: application_user_mapping_nc_id_seq; Type: SEQUENCE; Schema: pb3gir75kkooyea; Owner: admin
--

CREATE SEQUENCE pb3gir75kkooyea.application_user_mapping_nc_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE pb3gir75kkooyea.application_user_mapping_nc_id_seq OWNER TO admin;

--
-- Name: application_user_mapping_nc_id_seq; Type: SEQUENCE OWNED BY; Schema: pb3gir75kkooyea; Owner: admin
--

ALTER SEQUENCE pb3gir75kkooyea.application_user_mapping_nc_id_seq OWNED BY pb3gir75kkooyea.application_user_mapping.nc_id;


--
-- Name: audit_event; Type: TABLE; Schema: pb3gir75kkooyea; Owner: admin
--

CREATE TABLE pb3gir75kkooyea.audit_event (
    nc_id integer NOT NULL,
    created_at1 timestamp without time zone,
    updated_at1 timestamp without time zone,
    created_by character varying,
    updated_by character varying,
    nc_order numeric,
    id text NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    version bigint DEFAULT 1 NOT NULL,
    kind text NOT NULL,
    event_code text NOT NULL,
    request_id text NOT NULL,
    actor_user_id text,
    actor_kind text NOT NULL,
    application_id text,
    object_type text,
    object_id text,
    result text NOT NULL,
    summary text NOT NULL,
    details text DEFAULT '{}'::text NOT NULL,
    resolution_status text,
    CONSTRAINT p3_audit_event_0b58d4fbed1c CHECK ((actor_kind = ANY (ARRAY['USER'::text, 'APPLICATION'::text, 'SYSTEM'::text, 'ANONYMOUS'::text]))),
    CONSTRAINT p3_audit_event_179d1ceba52f CHECK ((version >= 1)),
    CONSTRAINT p3_audit_event_24a22e04a028 CHECK ((result = ANY (ARRAY['SUCCESS'::text, 'FAILURE'::text, 'DENIED'::text]))),
    CONSTRAINT p3_audit_event_5a421ad7ab7b CHECK ((kind = ANY (ARRAY['LOGIN'::text, 'AUTH'::text, 'ACCESS'::text, 'OPERATION'::text, 'API'::text, 'ERROR'::text]))),
    CONSTRAINT p3_audit_event_c922244128c0 CHECK ((resolution_status = ANY (ARRAY['OPEN'::text, 'RESOLVED'::text]))),
    CONSTRAINT p3_audit_event_ed3f3b85e73e CHECK (((details IS NULL) OR (jsonb_typeof((details)::jsonb) IS NOT NULL)))
);


ALTER TABLE pb3gir75kkooyea.audit_event OWNER TO admin;

--
-- Name: CONSTRAINT p3_audit_event_0b58d4fbed1c ON audit_event; Type: COMMENT; Schema: pb3gir75kkooyea; Owner: admin
--

COMMENT ON CONSTRAINT p3_audit_event_0b58d4fbed1c ON pb3gir75kkooyea.audit_event IS 'P3|0b58d4fbed1c2f2d76bfd000ae4bada0adfe2832bf0739ad55f20551d11de612|CHECK ((actor_kind = ANY (ARRAY[''USER''::text, ''APPLICATION''::text, ''SYSTEM''::text, ''ANONYMOUS''::text])))';


--
-- Name: CONSTRAINT p3_audit_event_179d1ceba52f ON audit_event; Type: COMMENT; Schema: pb3gir75kkooyea; Owner: admin
--

COMMENT ON CONSTRAINT p3_audit_event_179d1ceba52f ON pb3gir75kkooyea.audit_event IS 'P3|179d1ceba52ffdc74c419719993b34a216287a1876d189917d2b7c1df68e917e|CHECK ((version >= 1))';


--
-- Name: CONSTRAINT p3_audit_event_24a22e04a028 ON audit_event; Type: COMMENT; Schema: pb3gir75kkooyea; Owner: admin
--

COMMENT ON CONSTRAINT p3_audit_event_24a22e04a028 ON pb3gir75kkooyea.audit_event IS 'P3|24a22e04a028bbc79d6feac18eb9961ced38078fa7898594fd2bdaa1cead303c|CHECK ((result = ANY (ARRAY[''SUCCESS''::text, ''FAILURE''::text, ''DENIED''::text])))';


--
-- Name: CONSTRAINT p3_audit_event_5a421ad7ab7b ON audit_event; Type: COMMENT; Schema: pb3gir75kkooyea; Owner: admin
--

COMMENT ON CONSTRAINT p3_audit_event_5a421ad7ab7b ON pb3gir75kkooyea.audit_event IS 'P3|5a421ad7ab7bb5678590b946992e617fe0f82d0148bcac0b95b3efe0f69730d6|CHECK ((kind = ANY (ARRAY[''LOGIN''::text, ''AUTH''::text, ''ACCESS''::text, ''OPERATION''::text, ''API''::text, ''ERROR''::text])))';


--
-- Name: CONSTRAINT p3_audit_event_c922244128c0 ON audit_event; Type: COMMENT; Schema: pb3gir75kkooyea; Owner: admin
--

COMMENT ON CONSTRAINT p3_audit_event_c922244128c0 ON pb3gir75kkooyea.audit_event IS 'P3|c922244128c04fc8472e75927a0ba896da53aeeb61d55aa55814c4f7177b5a9b|CHECK ((resolution_status = ANY (ARRAY[''OPEN''::text, ''RESOLVED''::text])))';


--
-- Name: CONSTRAINT p3_audit_event_ed3f3b85e73e ON audit_event; Type: COMMENT; Schema: pb3gir75kkooyea; Owner: admin
--

COMMENT ON CONSTRAINT p3_audit_event_ed3f3b85e73e ON pb3gir75kkooyea.audit_event IS 'P3|ed3f3b85e73ebb9e96f8dbaabc4e431ca66a3f92358b5de5c27405873f29a416|CHECK (((details IS NULL) OR (jsonb_typeof((details)::jsonb) IS NOT NULL)))';


--
-- Name: audit_event_nc_id_seq; Type: SEQUENCE; Schema: pb3gir75kkooyea; Owner: admin
--

CREATE SEQUENCE pb3gir75kkooyea.audit_event_nc_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE pb3gir75kkooyea.audit_event_nc_id_seq OWNER TO admin;

--
-- Name: audit_event_nc_id_seq; Type: SEQUENCE OWNED BY; Schema: pb3gir75kkooyea; Owner: admin
--

ALTER SEQUENCE pb3gir75kkooyea.audit_event_nc_id_seq OWNED BY pb3gir75kkooyea.audit_event.nc_id;


--
-- Name: identity_mapping; Type: TABLE; Schema: pb3gir75kkooyea; Owner: admin
--

CREATE TABLE pb3gir75kkooyea.identity_mapping (
    nc_id integer NOT NULL,
    created_at1 timestamp without time zone,
    updated_at1 timestamp without time zone,
    created_by character varying,
    updated_by character varying,
    nc_order numeric,
    id text NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    version bigint DEFAULT 1 NOT NULL,
    user_id text NOT NULL,
    source_id text NOT NULL,
    external_subject_id text NOT NULL,
    external_account text,
    status text DEFAULT 'PENDING'::text NOT NULL,
    verified_at timestamp with time zone,
    CONSTRAINT p3_identity_mapping_37d207dea3f8 CHECK ((status = ANY (ARRAY['PENDING'::text, 'BOUND'::text, 'CONFLICT'::text, 'UNBOUND'::text]))),
    CONSTRAINT p3_identity_mapping_e2bf3479a23a CHECK ((version >= 1))
);


ALTER TABLE pb3gir75kkooyea.identity_mapping OWNER TO admin;

--
-- Name: CONSTRAINT p3_identity_mapping_37d207dea3f8 ON identity_mapping; Type: COMMENT; Schema: pb3gir75kkooyea; Owner: admin
--

COMMENT ON CONSTRAINT p3_identity_mapping_37d207dea3f8 ON pb3gir75kkooyea.identity_mapping IS 'P3|37d207dea3f89f44a8cfcaefcfe4d07e83341dce6cae41f47cabe2d00e089fb9|CHECK ((status = ANY (ARRAY[''PENDING''::text, ''BOUND''::text, ''CONFLICT''::text, ''UNBOUND''::text])))';


--
-- Name: CONSTRAINT p3_identity_mapping_e2bf3479a23a ON identity_mapping; Type: COMMENT; Schema: pb3gir75kkooyea; Owner: admin
--

COMMENT ON CONSTRAINT p3_identity_mapping_e2bf3479a23a ON pb3gir75kkooyea.identity_mapping IS 'P3|e2bf3479a23a0d677195dab79be88c0fca32410a308af7bec07178e4807d4d68|CHECK ((version >= 1))';


--
-- Name: identity_mapping_nc_id_seq; Type: SEQUENCE; Schema: pb3gir75kkooyea; Owner: admin
--

CREATE SEQUENCE pb3gir75kkooyea.identity_mapping_nc_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE pb3gir75kkooyea.identity_mapping_nc_id_seq OWNER TO admin;

--
-- Name: identity_mapping_nc_id_seq; Type: SEQUENCE OWNED BY; Schema: pb3gir75kkooyea; Owner: admin
--

ALTER SEQUENCE pb3gir75kkooyea.identity_mapping_nc_id_seq OWNED BY pb3gir75kkooyea.identity_mapping.nc_id;


--
-- Name: identity_source; Type: TABLE; Schema: pb3gir75kkooyea; Owner: admin
--

CREATE TABLE pb3gir75kkooyea.identity_source (
    nc_id integer NOT NULL,
    created_at1 timestamp without time zone,
    updated_at1 timestamp without time zone,
    created_by character varying,
    updated_by character varying,
    nc_order numeric,
    id text NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    version bigint DEFAULT 1 NOT NULL,
    code text NOT NULL,
    name text NOT NULL,
    kind text NOT NULL,
    protocol text,
    config_secret_ref text,
    register_url text,
    status text DEFAULT 'DISABLED'::text NOT NULL,
    CONSTRAINT p3_identity_source_4e364815e78d CHECK ((kind = ANY (ARRAY['CITIZEN'::text, 'GOV'::text]))),
    CONSTRAINT p3_identity_source_722fe076aec2 CHECK ((version >= 1)),
    CONSTRAINT p3_identity_source_df153a1313b8 CHECK ((status = ANY (ARRAY['ENABLED'::text, 'DISABLED'::text])))
);


ALTER TABLE pb3gir75kkooyea.identity_source OWNER TO admin;

--
-- Name: CONSTRAINT p3_identity_source_4e364815e78d ON identity_source; Type: COMMENT; Schema: pb3gir75kkooyea; Owner: admin
--

COMMENT ON CONSTRAINT p3_identity_source_4e364815e78d ON pb3gir75kkooyea.identity_source IS 'P3|4e364815e78d3e592d9f7faff3c8bc136b51fb20388d56b2a0d47e5824e3bc6f|CHECK ((kind = ANY (ARRAY[''CITIZEN''::text, ''GOV''::text])))';


--
-- Name: CONSTRAINT p3_identity_source_722fe076aec2 ON identity_source; Type: COMMENT; Schema: pb3gir75kkooyea; Owner: admin
--

COMMENT ON CONSTRAINT p3_identity_source_722fe076aec2 ON pb3gir75kkooyea.identity_source IS 'P3|722fe076aec2effea8a00402d7a856c333512ccee5496e3d45c9eb52b867d2cc|CHECK ((version >= 1))';


--
-- Name: CONSTRAINT p3_identity_source_df153a1313b8 ON identity_source; Type: COMMENT; Schema: pb3gir75kkooyea; Owner: admin
--

COMMENT ON CONSTRAINT p3_identity_source_df153a1313b8 ON pb3gir75kkooyea.identity_source IS 'P3|df153a1313b802860599e16d5331416623e48178b1de2ea8d223f2b0484f5617|CHECK ((status = ANY (ARRAY[''ENABLED''::text, ''DISABLED''::text])))';


--
-- Name: identity_source_nc_id_seq; Type: SEQUENCE; Schema: pb3gir75kkooyea; Owner: admin
--

CREATE SEQUENCE pb3gir75kkooyea.identity_source_nc_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE pb3gir75kkooyea.identity_source_nc_id_seq OWNER TO admin;

--
-- Name: identity_source_nc_id_seq; Type: SEQUENCE OWNED BY; Schema: pb3gir75kkooyea; Owner: admin
--

ALTER SEQUENCE pb3gir75kkooyea.identity_source_nc_id_seq OWNED BY pb3gir75kkooyea.identity_source.nc_id;


--
-- Name: ingest_receipt; Type: TABLE; Schema: pb3gir75kkooyea; Owner: admin
--

CREATE TABLE pb3gir75kkooyea.ingest_receipt (
    nc_id integer NOT NULL,
    created_at1 timestamp without time zone,
    updated_at1 timestamp without time zone,
    created_by character varying,
    updated_by character varying,
    nc_order numeric,
    id text NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    version bigint DEFAULT 1 NOT NULL,
    application_id text NOT NULL,
    kind text NOT NULL,
    event_id text NOT NULL,
    payload_hash text NOT NULL,
    status text DEFAULT 'RECEIVED'::text NOT NULL,
    result text,
    applied_at timestamp with time zone,
    CONSTRAINT p3_ingest_receipt_3b16904262fc CHECK ((kind = ANY (ARRAY['TODO'::text, 'MESSAGE'::text, 'SMS'::text]))),
    CONSTRAINT p3_ingest_receipt_73955776ef8a CHECK ((status = ANY (ARRAY['RECEIVED'::text, 'APPLIED'::text, 'REJECTED'::text]))),
    CONSTRAINT p3_ingest_receipt_cb17784af306 CHECK (((result IS NULL) OR (jsonb_typeof((result)::jsonb) IS NOT NULL))),
    CONSTRAINT p3_ingest_receipt_f0f958e6a879 CHECK ((version >= 1))
);


ALTER TABLE pb3gir75kkooyea.ingest_receipt OWNER TO admin;

--
-- Name: CONSTRAINT p3_ingest_receipt_3b16904262fc ON ingest_receipt; Type: COMMENT; Schema: pb3gir75kkooyea; Owner: admin
--

COMMENT ON CONSTRAINT p3_ingest_receipt_3b16904262fc ON pb3gir75kkooyea.ingest_receipt IS 'P3|3b16904262fcba4c8ef9af8e4e378e7eb4751935cbb11ef0641cd536d8a5b49b|CHECK ((kind = ANY (ARRAY[''TODO''::text, ''MESSAGE''::text, ''SMS''::text])))';


--
-- Name: CONSTRAINT p3_ingest_receipt_73955776ef8a ON ingest_receipt; Type: COMMENT; Schema: pb3gir75kkooyea; Owner: admin
--

COMMENT ON CONSTRAINT p3_ingest_receipt_73955776ef8a ON pb3gir75kkooyea.ingest_receipt IS 'P3|73955776ef8ab1b9efc56e15d4923c709dac6b3226115335c6462ba7daaf62a2|CHECK ((status = ANY (ARRAY[''RECEIVED''::text, ''APPLIED''::text, ''REJECTED''::text])))';


--
-- Name: CONSTRAINT p3_ingest_receipt_cb17784af306 ON ingest_receipt; Type: COMMENT; Schema: pb3gir75kkooyea; Owner: admin
--

COMMENT ON CONSTRAINT p3_ingest_receipt_cb17784af306 ON pb3gir75kkooyea.ingest_receipt IS 'P3|cb17784af3069f76585dee8c3ff1b04a7a61f1ca20a99af0e1262e2e6a3fb9a6|CHECK (((result IS NULL) OR (jsonb_typeof((result)::jsonb) IS NOT NULL)))';


--
-- Name: CONSTRAINT p3_ingest_receipt_f0f958e6a879 ON ingest_receipt; Type: COMMENT; Schema: pb3gir75kkooyea; Owner: admin
--

COMMENT ON CONSTRAINT p3_ingest_receipt_f0f958e6a879 ON pb3gir75kkooyea.ingest_receipt IS 'P3|f0f958e6a8791542a63ea644d2d3ec767d3e0072da52d2466f3a2a462d7d24b1|CHECK ((version >= 1))';


--
-- Name: ingest_receipt_nc_id_seq; Type: SEQUENCE; Schema: pb3gir75kkooyea; Owner: admin
--

CREATE SEQUENCE pb3gir75kkooyea.ingest_receipt_nc_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE pb3gir75kkooyea.ingest_receipt_nc_id_seq OWNER TO admin;

--
-- Name: ingest_receipt_nc_id_seq; Type: SEQUENCE OWNED BY; Schema: pb3gir75kkooyea; Owner: admin
--

ALTER SEQUENCE pb3gir75kkooyea.ingest_receipt_nc_id_seq OWNED BY pb3gir75kkooyea.ingest_receipt.nc_id;


--
-- Name: login_request; Type: TABLE; Schema: pb3gir75kkooyea; Owner: admin
--

CREATE TABLE pb3gir75kkooyea.login_request (
    nc_id integer NOT NULL,
    created_at1 timestamp without time zone,
    updated_at1 timestamp without time zone,
    created_by character varying,
    updated_by character varying,
    nc_order numeric,
    id text NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    version bigint DEFAULT 1 NOT NULL,
    source_id text NOT NULL,
    state_hash text NOT NULL,
    method text NOT NULL,
    status text DEFAULT 'WAITING'::text NOT NULL,
    expires_at timestamp with time zone NOT NULL,
    consumed_at timestamp with time zone,
    failure_code text,
    CONSTRAINT p3_login_request_63ae1bd58c34 CHECK ((status = ANY (ARRAY['WAITING'::text, 'SCANNED'::text, 'AUTHENTICATING'::text, 'SUCCESS'::text, 'FAILED'::text, 'EXPIRED'::text, 'CANCELLED'::text]))),
    CONSTRAINT p3_login_request_d0785f9a6986 CHECK ((version >= 1))
);


ALTER TABLE pb3gir75kkooyea.login_request OWNER TO admin;

--
-- Name: CONSTRAINT p3_login_request_63ae1bd58c34 ON login_request; Type: COMMENT; Schema: pb3gir75kkooyea; Owner: admin
--

COMMENT ON CONSTRAINT p3_login_request_63ae1bd58c34 ON pb3gir75kkooyea.login_request IS 'P3|63ae1bd58c342c588daeb81db637603b30285623c67e6740ffafae7966fa8582|CHECK ((status = ANY (ARRAY[''WAITING''::text, ''SCANNED''::text, ''AUTHENTICATING''::text, ''SUCCESS''::text, ''FAILED''::text, ''EXPIRED''::text, ''CANCELLED''::text])))';


--
-- Name: CONSTRAINT p3_login_request_d0785f9a6986 ON login_request; Type: COMMENT; Schema: pb3gir75kkooyea; Owner: admin
--

COMMENT ON CONSTRAINT p3_login_request_d0785f9a6986 ON pb3gir75kkooyea.login_request IS 'P3|d0785f9a6986a94693134fa56311aad98472231d96ea6d64fe03f6ff0295a714|CHECK ((version >= 1))';


--
-- Name: login_request_nc_id_seq; Type: SEQUENCE; Schema: pb3gir75kkooyea; Owner: admin
--

CREATE SEQUENCE pb3gir75kkooyea.login_request_nc_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE pb3gir75kkooyea.login_request_nc_id_seq OWNER TO admin;

--
-- Name: login_request_nc_id_seq; Type: SEQUENCE OWNED BY; Schema: pb3gir75kkooyea; Owner: admin
--

ALTER SEQUENCE pb3gir75kkooyea.login_request_nc_id_seq OWNED BY pb3gir75kkooyea.login_request.nc_id;


--
-- Name: mapping_exception; Type: TABLE; Schema: pb3gir75kkooyea; Owner: admin
--

CREATE TABLE pb3gir75kkooyea.mapping_exception (
    nc_id integer NOT NULL,
    created_at1 timestamp without time zone,
    updated_at1 timestamp without time zone,
    created_by character varying,
    updated_by character varying,
    nc_order numeric,
    id text NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    version bigint DEFAULT 1 NOT NULL,
    mapping_id text,
    identity_mapping_id text,
    exception_type text NOT NULL,
    summary text NOT NULL,
    resolution_status text DEFAULT 'OPEN'::text NOT NULL,
    resolved_by text,
    resolved_at timestamp with time zone,
    resolution_note text,
    CONSTRAINT p3_mapping_exception_8a626dcbe6e8 CHECK (((mapping_id IS NOT NULL) OR (identity_mapping_id IS NOT NULL))),
    CONSTRAINT p3_mapping_exception_b976b27a5623 CHECK ((resolution_status = ANY (ARRAY['OPEN'::text, 'RESOLVED'::text]))),
    CONSTRAINT p3_mapping_exception_bc50abcb628d CHECK ((version >= 1))
);


ALTER TABLE pb3gir75kkooyea.mapping_exception OWNER TO admin;

--
-- Name: CONSTRAINT p3_mapping_exception_8a626dcbe6e8 ON mapping_exception; Type: COMMENT; Schema: pb3gir75kkooyea; Owner: admin
--

COMMENT ON CONSTRAINT p3_mapping_exception_8a626dcbe6e8 ON pb3gir75kkooyea.mapping_exception IS 'P3|8a626dcbe6e81ccc054379121748f20e4d68320081602b27eb40be3157619627|CHECK (((mapping_id IS NOT NULL) OR (identity_mapping_id IS NOT NULL)))';


--
-- Name: CONSTRAINT p3_mapping_exception_b976b27a5623 ON mapping_exception; Type: COMMENT; Schema: pb3gir75kkooyea; Owner: admin
--

COMMENT ON CONSTRAINT p3_mapping_exception_b976b27a5623 ON pb3gir75kkooyea.mapping_exception IS 'P3|b976b27a56236a134b350425465689440e1c9f9c029a119d490fc14c77ee4bea|CHECK ((resolution_status = ANY (ARRAY[''OPEN''::text, ''RESOLVED''::text])))';


--
-- Name: CONSTRAINT p3_mapping_exception_bc50abcb628d ON mapping_exception; Type: COMMENT; Schema: pb3gir75kkooyea; Owner: admin
--

COMMENT ON CONSTRAINT p3_mapping_exception_bc50abcb628d ON pb3gir75kkooyea.mapping_exception IS 'P3|bc50abcb628d2c16feb017b1ce0379f409d2462de728601d72b4eee5f3e0ca27|CHECK ((version >= 1))';


--
-- Name: mapping_exception_nc_id_seq; Type: SEQUENCE; Schema: pb3gir75kkooyea; Owner: admin
--

CREATE SEQUENCE pb3gir75kkooyea.mapping_exception_nc_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE pb3gir75kkooyea.mapping_exception_nc_id_seq OWNER TO admin;

--
-- Name: mapping_exception_nc_id_seq; Type: SEQUENCE OWNED BY; Schema: pb3gir75kkooyea; Owner: admin
--

ALTER SEQUENCE pb3gir75kkooyea.mapping_exception_nc_id_seq OWNED BY pb3gir75kkooyea.mapping_exception.nc_id;


--
-- Name: message; Type: TABLE; Schema: pb3gir75kkooyea; Owner: admin
--

CREATE TABLE pb3gir75kkooyea.message (
    nc_id integer NOT NULL,
    created_at1 timestamp without time zone,
    updated_at1 timestamp without time zone,
    created_by character varying,
    updated_by character varying,
    nc_order numeric,
    id text NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    version bigint DEFAULT 1 NOT NULL,
    application_id text,
    source_kind text NOT NULL,
    source_key text NOT NULL,
    source_message_id text NOT NULL,
    message_type text NOT NULL,
    title text NOT NULL,
    content text NOT NULL,
    business_url text,
    source_created_at timestamp with time zone NOT NULL,
    runtime_id text,
    received_at timestamp with time zone,
    CONSTRAINT p3_message_04377c1af0cb CHECK ((source_kind = ANY (ARRAY['PORTAL'::text, 'APPLICATION'::text]))),
    CONSTRAINT p3_message_11f2cd81e668 CHECK ((message_type = ANY (ARRAY['BUSINESS'::text, 'SYSTEM'::text, 'ACCOUNT'::text, 'SECURITY'::text, 'TODO_REMINDER'::text, 'OTHER'::text]))),
    CONSTRAINT p3_message_3b635aad4e93 CHECK ((((source_kind = 'PORTAL'::text) AND (application_id IS NULL) AND (source_key = 'PORTAL'::text)) OR ((source_kind = 'APPLICATION'::text) AND (application_id IS NOT NULL) AND (source_key = application_id)))),
    CONSTRAINT p3_message_881bb19a57d9 CHECK ((version >= 1))
);


ALTER TABLE pb3gir75kkooyea.message OWNER TO admin;

--
-- Name: CONSTRAINT p3_message_04377c1af0cb ON message; Type: COMMENT; Schema: pb3gir75kkooyea; Owner: admin
--

COMMENT ON CONSTRAINT p3_message_04377c1af0cb ON pb3gir75kkooyea.message IS 'P3|04377c1af0cb724b29511497a144fc7fb90519ba06672f4319ed53d0a2ef414a|CHECK ((source_kind = ANY (ARRAY[''PORTAL''::text, ''APPLICATION''::text])))';


--
-- Name: CONSTRAINT p3_message_11f2cd81e668 ON message; Type: COMMENT; Schema: pb3gir75kkooyea; Owner: admin
--

COMMENT ON CONSTRAINT p3_message_11f2cd81e668 ON pb3gir75kkooyea.message IS 'P3|11f2cd81e6685a9ac3e89906b57eedba5062f7dccc1097c0b4aef8eb007e6658|CHECK ((message_type = ANY (ARRAY[''BUSINESS''::text, ''SYSTEM''::text, ''ACCOUNT''::text, ''SECURITY''::text, ''TODO_REMINDER''::text, ''OTHER''::text])))';


--
-- Name: CONSTRAINT p3_message_3b635aad4e93 ON message; Type: COMMENT; Schema: pb3gir75kkooyea; Owner: admin
--

COMMENT ON CONSTRAINT p3_message_3b635aad4e93 ON pb3gir75kkooyea.message IS 'P3|3b635aad4e932da97d397a9bd93670370228d547fdfe35cf5258ec7c2991c3a8|CHECK ((((source_kind = ''PORTAL''::text) AND (application_id IS NULL) AND (source_key = ''PORTAL''::text)) OR ((source_kind = ''APPLICATION''::text) AND (application_id IS NOT NULL) AND (source_key = application_id))))';


--
-- Name: CONSTRAINT p3_message_881bb19a57d9 ON message; Type: COMMENT; Schema: pb3gir75kkooyea; Owner: admin
--

COMMENT ON CONSTRAINT p3_message_881bb19a57d9 ON pb3gir75kkooyea.message IS 'P3|881bb19a57d97d31e6332c14c4e8183efa2d488f9cc43e067949bd9f03f81996|CHECK ((version >= 1))';


--
-- Name: message_nc_id_seq; Type: SEQUENCE; Schema: pb3gir75kkooyea; Owner: admin
--

CREATE SEQUENCE pb3gir75kkooyea.message_nc_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE pb3gir75kkooyea.message_nc_id_seq OWNER TO admin;

--
-- Name: message_nc_id_seq; Type: SEQUENCE OWNED BY; Schema: pb3gir75kkooyea; Owner: admin
--

ALTER SEQUENCE pb3gir75kkooyea.message_nc_id_seq OWNED BY pb3gir75kkooyea.message.nc_id;


--
-- Name: message_recipient; Type: TABLE; Schema: pb3gir75kkooyea; Owner: admin
--

CREATE TABLE pb3gir75kkooyea.message_recipient (
    nc_id integer NOT NULL,
    created_at1 timestamp without time zone,
    updated_at1 timestamp without time zone,
    created_by character varying,
    updated_by character varying,
    nc_order numeric,
    id text NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    version bigint DEFAULT 1 NOT NULL,
    message_id text NOT NULL,
    user_id text NOT NULL,
    read_status text DEFAULT 'UNREAD'::text NOT NULL,
    read_at timestamp with time zone,
    received_at timestamp with time zone,
    deleted_at timestamp with time zone,
    CONSTRAINT p3_message_recipient_0824eec79d95 CHECK ((version >= 1)),
    CONSTRAINT p3_message_recipient_ecdd56777ebe CHECK ((((read_status = 'UNREAD'::text) AND (read_at IS NULL)) OR ((read_status = 'READ'::text) AND (read_at IS NOT NULL)))),
    CONSTRAINT p3_message_recipient_f36610ccd560 CHECK ((read_status = ANY (ARRAY['UNREAD'::text, 'READ'::text])))
);


ALTER TABLE pb3gir75kkooyea.message_recipient OWNER TO admin;

--
-- Name: CONSTRAINT p3_message_recipient_0824eec79d95 ON message_recipient; Type: COMMENT; Schema: pb3gir75kkooyea; Owner: admin
--

COMMENT ON CONSTRAINT p3_message_recipient_0824eec79d95 ON pb3gir75kkooyea.message_recipient IS 'P3|0824eec79d95c2da63589f99874d8204e870f6fd61261631b59e031573a6a511|CHECK ((version >= 1))';


--
-- Name: CONSTRAINT p3_message_recipient_ecdd56777ebe ON message_recipient; Type: COMMENT; Schema: pb3gir75kkooyea; Owner: admin
--

COMMENT ON CONSTRAINT p3_message_recipient_ecdd56777ebe ON pb3gir75kkooyea.message_recipient IS 'P3|ecdd56777ebe739026157d463fc7da91474929eed54b7a94e55954fd13322778|CHECK ((((read_status = ''UNREAD''::text) AND (read_at IS NULL)) OR ((read_status = ''READ''::text) AND (read_at IS NOT NULL))))';


--
-- Name: CONSTRAINT p3_message_recipient_f36610ccd560 ON message_recipient; Type: COMMENT; Schema: pb3gir75kkooyea; Owner: admin
--

COMMENT ON CONSTRAINT p3_message_recipient_f36610ccd560 ON pb3gir75kkooyea.message_recipient IS 'P3|f36610ccd560dddfbb2ca38133c480a23a21873b0de4451bfedea93ee7f36bba|CHECK ((read_status = ANY (ARRAY[''UNREAD''::text, ''READ''::text])))';


--
-- Name: message_recipient_nc_id_seq; Type: SEQUENCE; Schema: pb3gir75kkooyea; Owner: admin
--

CREATE SEQUENCE pb3gir75kkooyea.message_recipient_nc_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE pb3gir75kkooyea.message_recipient_nc_id_seq OWNER TO admin;

--
-- Name: message_recipient_nc_id_seq; Type: SEQUENCE OWNED BY; Schema: pb3gir75kkooyea; Owner: admin
--

ALTER SEQUENCE pb3gir75kkooyea.message_recipient_nc_id_seq OWNED BY pb3gir75kkooyea.message_recipient.nc_id;


--
-- Name: monitor_status; Type: TABLE; Schema: pb3gir75kkooyea; Owner: admin
--

CREATE TABLE pb3gir75kkooyea.monitor_status (
    nc_id integer NOT NULL,
    created_at1 timestamp without time zone,
    updated_at1 timestamp without time zone,
    created_by character varying,
    updated_by character varying,
    nc_order numeric,
    id text NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    version bigint DEFAULT 1 NOT NULL,
    target_key text NOT NULL,
    service_type text NOT NULL,
    status text DEFAULT 'UNCONFIGURED'::text NOT NULL,
    last_success_at timestamp with time zone,
    last_failure_at timestamp with time zone,
    failure_count bigint DEFAULT 0 NOT NULL,
    response_time_ms bigint,
    last_error text,
    CONSTRAINT p3_monitor_status_3b4e2d6e9015 CHECK ((status = ANY (ARRAY['NORMAL'::text, 'ABNORMAL'::text, 'UNCONFIGURED'::text, 'DISABLED'::text]))),
    CONSTRAINT p3_monitor_status_4212c36d929b CHECK ((failure_count >= 0)),
    CONSTRAINT p3_monitor_status_6d099d57f99c CHECK ((service_type = ANY (ARRAY['IDENTITY'::text, 'SSO'::text, 'TODO'::text, 'MESSAGE'::text, 'SMS'::text]))),
    CONSTRAINT p3_monitor_status_91dbd6b139ca CHECK ((version >= 1))
);


ALTER TABLE pb3gir75kkooyea.monitor_status OWNER TO admin;

--
-- Name: CONSTRAINT p3_monitor_status_3b4e2d6e9015 ON monitor_status; Type: COMMENT; Schema: pb3gir75kkooyea; Owner: admin
--

COMMENT ON CONSTRAINT p3_monitor_status_3b4e2d6e9015 ON pb3gir75kkooyea.monitor_status IS 'P3|3b4e2d6e901586b2671ac491b1b17fb19170649a28b3494ea43f6128f5bbd133|CHECK ((status = ANY (ARRAY[''NORMAL''::text, ''ABNORMAL''::text, ''UNCONFIGURED''::text, ''DISABLED''::text])))';


--
-- Name: CONSTRAINT p3_monitor_status_4212c36d929b ON monitor_status; Type: COMMENT; Schema: pb3gir75kkooyea; Owner: admin
--

COMMENT ON CONSTRAINT p3_monitor_status_4212c36d929b ON pb3gir75kkooyea.monitor_status IS 'P3|4212c36d929b5369b187e74e6c74a538876af8761a4e4a3d2a89bd037b40e519|CHECK ((failure_count >= 0))';


--
-- Name: CONSTRAINT p3_monitor_status_6d099d57f99c ON monitor_status; Type: COMMENT; Schema: pb3gir75kkooyea; Owner: admin
--

COMMENT ON CONSTRAINT p3_monitor_status_6d099d57f99c ON pb3gir75kkooyea.monitor_status IS 'P3|6d099d57f99cb26ca28c2fc4ed5ef3e27ce0af3b4606bea8830bb0061bbd90b1|CHECK ((service_type = ANY (ARRAY[''IDENTITY''::text, ''SSO''::text, ''TODO''::text, ''MESSAGE''::text, ''SMS''::text])))';


--
-- Name: CONSTRAINT p3_monitor_status_91dbd6b139ca ON monitor_status; Type: COMMENT; Schema: pb3gir75kkooyea; Owner: admin
--

COMMENT ON CONSTRAINT p3_monitor_status_91dbd6b139ca ON pb3gir75kkooyea.monitor_status IS 'P3|91dbd6b139cab9fd90c274f8dce51922d7394a81f23a7ffa9416038f80711a32|CHECK ((version >= 1))';


--
-- Name: monitor_status_nc_id_seq; Type: SEQUENCE; Schema: pb3gir75kkooyea; Owner: admin
--

CREATE SEQUENCE pb3gir75kkooyea.monitor_status_nc_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE pb3gir75kkooyea.monitor_status_nc_id_seq OWNER TO admin;

--
-- Name: monitor_status_nc_id_seq; Type: SEQUENCE OWNED BY; Schema: pb3gir75kkooyea; Owner: admin
--

ALTER SEQUENCE pb3gir75kkooyea.monitor_status_nc_id_seq OWNED BY pb3gir75kkooyea.monitor_status.nc_id;


--
-- Name: portal_demo_restore_archive; Type: TABLE; Schema: pb3gir75kkooyea; Owner: admin
--

CREATE TABLE pb3gir75kkooyea.portal_demo_restore_archive (
    archive_key text NOT NULL,
    resource text NOT NULL,
    runtime_id text NOT NULL,
    original_payload jsonb NOT NULL,
    archived_at timestamp with time zone DEFAULT now() NOT NULL,
    reason text NOT NULL,
    CONSTRAINT portal_demo_restore_archive_original_payload_check CHECK ((jsonb_typeof(original_payload) = 'object'::text))
);


ALTER TABLE pb3gir75kkooyea.portal_demo_restore_archive OWNER TO admin;

--
-- Name: portal_permission; Type: TABLE; Schema: pb3gir75kkooyea; Owner: admin
--

CREATE TABLE pb3gir75kkooyea.portal_permission (
    nc_id integer NOT NULL,
    created_at1 timestamp without time zone,
    updated_at1 timestamp without time zone,
    created_by character varying,
    updated_by character varying,
    nc_order numeric,
    id text NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    version bigint DEFAULT 1 NOT NULL,
    code text NOT NULL,
    name text NOT NULL,
    kind text NOT NULL,
    route text,
    CONSTRAINT p3_portal_permission_8be33f8f42ab CHECK ((version >= 1)),
    CONSTRAINT p3_portal_permission_e2f136b55d47 CHECK ((kind = ANY (ARRAY['MENU'::text, 'PAGE'::text, 'ACTION'::text])))
);


ALTER TABLE pb3gir75kkooyea.portal_permission OWNER TO admin;

--
-- Name: CONSTRAINT p3_portal_permission_8be33f8f42ab ON portal_permission; Type: COMMENT; Schema: pb3gir75kkooyea; Owner: admin
--

COMMENT ON CONSTRAINT p3_portal_permission_8be33f8f42ab ON pb3gir75kkooyea.portal_permission IS 'P3|8be33f8f42ab2d2d63bfe75f344c30ecd1767dc589b0e5e724b707972024ee42|CHECK ((version >= 1))';


--
-- Name: CONSTRAINT p3_portal_permission_e2f136b55d47 ON portal_permission; Type: COMMENT; Schema: pb3gir75kkooyea; Owner: admin
--

COMMENT ON CONSTRAINT p3_portal_permission_e2f136b55d47 ON pb3gir75kkooyea.portal_permission IS 'P3|e2f136b55d47a1413a200c95f007f78d1057cf520ebfcba77f90f38fa86b5a53|CHECK ((kind = ANY (ARRAY[''MENU''::text, ''PAGE''::text, ''ACTION''::text])))';


--
-- Name: portal_permission_nc_id_seq; Type: SEQUENCE; Schema: pb3gir75kkooyea; Owner: admin
--

CREATE SEQUENCE pb3gir75kkooyea.portal_permission_nc_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE pb3gir75kkooyea.portal_permission_nc_id_seq OWNER TO admin;

--
-- Name: portal_permission_nc_id_seq; Type: SEQUENCE OWNED BY; Schema: pb3gir75kkooyea; Owner: admin
--

ALTER SEQUENCE pb3gir75kkooyea.portal_permission_nc_id_seq OWNED BY pb3gir75kkooyea.portal_permission.nc_id;


--
-- Name: portal_role; Type: TABLE; Schema: pb3gir75kkooyea; Owner: admin
--

CREATE TABLE pb3gir75kkooyea.portal_role (
    nc_id integer NOT NULL,
    created_at1 timestamp without time zone,
    updated_at1 timestamp without time zone,
    created_by character varying,
    updated_by character varying,
    nc_order numeric,
    id text NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    version bigint DEFAULT 1 NOT NULL,
    code text NOT NULL,
    name text NOT NULL,
    description text,
    status text DEFAULT 'DISABLED'::text NOT NULL,
    CONSTRAINT p3_portal_role_123fb4975c95 CHECK ((version >= 1)),
    CONSTRAINT p3_portal_role_f444ada05f76 CHECK ((status = ANY (ARRAY['ENABLED'::text, 'DISABLED'::text])))
);


ALTER TABLE pb3gir75kkooyea.portal_role OWNER TO admin;

--
-- Name: CONSTRAINT p3_portal_role_123fb4975c95 ON portal_role; Type: COMMENT; Schema: pb3gir75kkooyea; Owner: admin
--

COMMENT ON CONSTRAINT p3_portal_role_123fb4975c95 ON pb3gir75kkooyea.portal_role IS 'P3|123fb4975c958c114e8f7be536b51c9922ca2f3ef8b609664742dff470a7d11f|CHECK ((version >= 1))';


--
-- Name: CONSTRAINT p3_portal_role_f444ada05f76 ON portal_role; Type: COMMENT; Schema: pb3gir75kkooyea; Owner: admin
--

COMMENT ON CONSTRAINT p3_portal_role_f444ada05f76 ON pb3gir75kkooyea.portal_role IS 'P3|f444ada05f76b10b6a54142e6809a9aace863325969a165468209c289374bbd7|CHECK ((status = ANY (ARRAY[''ENABLED''::text, ''DISABLED''::text])))';


--
-- Name: portal_role_nc_id_seq; Type: SEQUENCE; Schema: pb3gir75kkooyea; Owner: admin
--

CREATE SEQUENCE pb3gir75kkooyea.portal_role_nc_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE pb3gir75kkooyea.portal_role_nc_id_seq OWNER TO admin;

--
-- Name: portal_role_nc_id_seq; Type: SEQUENCE OWNED BY; Schema: pb3gir75kkooyea; Owner: admin
--

ALTER SEQUENCE pb3gir75kkooyea.portal_role_nc_id_seq OWNED BY pb3gir75kkooyea.portal_role.nc_id;


--
-- Name: portal_role_permission; Type: TABLE; Schema: pb3gir75kkooyea; Owner: admin
--

CREATE TABLE pb3gir75kkooyea.portal_role_permission (
    nc_id integer NOT NULL,
    created_at1 timestamp without time zone,
    updated_at1 timestamp without time zone,
    created_by character varying,
    updated_by character varying,
    nc_order numeric,
    id text NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    version bigint DEFAULT 1 NOT NULL,
    role_id text NOT NULL,
    permission_id text NOT NULL,
    data_scope text DEFAULT 'SELF'::text NOT NULL,
    CONSTRAINT p3_portal_role_permission_1d907ab4e6b3 CHECK ((data_scope = ANY (ARRAY['SELF'::text, 'ASSIGNED_APPS'::text, 'ALL_PORTAL'::text]))),
    CONSTRAINT p3_portal_role_permission_eca0dd2173be CHECK ((version >= 1))
);


ALTER TABLE pb3gir75kkooyea.portal_role_permission OWNER TO admin;

--
-- Name: CONSTRAINT p3_portal_role_permission_1d907ab4e6b3 ON portal_role_permission; Type: COMMENT; Schema: pb3gir75kkooyea; Owner: admin
--

COMMENT ON CONSTRAINT p3_portal_role_permission_1d907ab4e6b3 ON pb3gir75kkooyea.portal_role_permission IS 'P3|1d907ab4e6b377bdcb16ae4245d3adfffd1736542c59f3f816063944d96517e2|CHECK ((data_scope = ANY (ARRAY[''SELF''::text, ''ASSIGNED_APPS''::text, ''ALL_PORTAL''::text])))';


--
-- Name: CONSTRAINT p3_portal_role_permission_eca0dd2173be ON portal_role_permission; Type: COMMENT; Schema: pb3gir75kkooyea; Owner: admin
--

COMMENT ON CONSTRAINT p3_portal_role_permission_eca0dd2173be ON pb3gir75kkooyea.portal_role_permission IS 'P3|eca0dd2173beec1347010f10cd4087b9afe1fb81be69beb7dc673eb4ed027104|CHECK ((version >= 1))';


--
-- Name: portal_role_permission_nc_id_seq; Type: SEQUENCE; Schema: pb3gir75kkooyea; Owner: admin
--

CREATE SEQUENCE pb3gir75kkooyea.portal_role_permission_nc_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE pb3gir75kkooyea.portal_role_permission_nc_id_seq OWNER TO admin;

--
-- Name: portal_role_permission_nc_id_seq; Type: SEQUENCE OWNED BY; Schema: pb3gir75kkooyea; Owner: admin
--

ALTER SEQUENCE pb3gir75kkooyea.portal_role_permission_nc_id_seq OWNED BY pb3gir75kkooyea.portal_role_permission.nc_id;


--
-- Name: portal_runtime_entity; Type: TABLE; Schema: pb3gir75kkooyea; Owner: admin
--

CREATE TABLE pb3gir75kkooyea.portal_runtime_entity (
    resource text NOT NULL,
    runtime_id text NOT NULL,
    "position" integer DEFAULT 0 NOT NULL,
    payload jsonb NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT portal_runtime_entity_payload_check CHECK ((jsonb_typeof(payload) = 'object'::text))
);


ALTER TABLE pb3gir75kkooyea.portal_runtime_entity OWNER TO admin;

--
-- Name: portal_runtime_entity_domain; Type: TABLE; Schema: pb3gir75kkooyea; Owner: admin
--

CREATE TABLE pb3gir75kkooyea.portal_runtime_entity_domain (
    resource text NOT NULL,
    initialized_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE pb3gir75kkooyea.portal_runtime_entity_domain OWNER TO admin;

--
-- Name: portal_session; Type: TABLE; Schema: pb3gir75kkooyea; Owner: admin
--

CREATE TABLE pb3gir75kkooyea.portal_session (
    nc_id integer NOT NULL,
    created_at1 timestamp without time zone,
    updated_at1 timestamp without time zone,
    created_by character varying,
    updated_by character varying,
    nc_order numeric,
    id text NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    version bigint DEFAULT 1 NOT NULL,
    user_id text NOT NULL,
    identity_mapping_id text NOT NULL,
    token_hash text NOT NULL,
    expires_at timestamp with time zone NOT NULL,
    revoked_at timestamp with time zone,
    CONSTRAINT p3_portal_session_485e575a2257 CHECK ((version >= 1))
);


ALTER TABLE pb3gir75kkooyea.portal_session OWNER TO admin;

--
-- Name: CONSTRAINT p3_portal_session_485e575a2257 ON portal_session; Type: COMMENT; Schema: pb3gir75kkooyea; Owner: admin
--

COMMENT ON CONSTRAINT p3_portal_session_485e575a2257 ON pb3gir75kkooyea.portal_session IS 'P3|485e575a225724b188d681a0a854149306b8fc49637a393b8893d9ab93a571d9|CHECK ((version >= 1))';


--
-- Name: portal_session_nc_id_seq; Type: SEQUENCE; Schema: pb3gir75kkooyea; Owner: admin
--

CREATE SEQUENCE pb3gir75kkooyea.portal_session_nc_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE pb3gir75kkooyea.portal_session_nc_id_seq OWNER TO admin;

--
-- Name: portal_session_nc_id_seq; Type: SEQUENCE OWNED BY; Schema: pb3gir75kkooyea; Owner: admin
--

ALTER SEQUENCE pb3gir75kkooyea.portal_session_nc_id_seq OWNED BY pb3gir75kkooyea.portal_session.nc_id;


--
-- Name: portal_user_application_scope; Type: TABLE; Schema: pb3gir75kkooyea; Owner: admin
--

CREATE TABLE pb3gir75kkooyea.portal_user_application_scope (
    nc_id integer NOT NULL,
    created_at1 timestamp without time zone,
    updated_at1 timestamp without time zone,
    created_by character varying,
    updated_by character varying,
    nc_order numeric,
    id text NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    version bigint DEFAULT 1 NOT NULL,
    user_id text NOT NULL,
    application_id text NOT NULL,
    CONSTRAINT p3_portal_user_application_scop_f04211de0815 CHECK ((version >= 1))
);


ALTER TABLE pb3gir75kkooyea.portal_user_application_scope OWNER TO admin;

--
-- Name: CONSTRAINT p3_portal_user_application_scop_f04211de0815 ON portal_user_application_scope; Type: COMMENT; Schema: pb3gir75kkooyea; Owner: admin
--

COMMENT ON CONSTRAINT p3_portal_user_application_scop_f04211de0815 ON pb3gir75kkooyea.portal_user_application_scope IS 'P3|f04211de0815614d68c98b5b11c34ebe80e1746dc237cbdba0ebf27910c49202|CHECK ((version >= 1))';


--
-- Name: portal_user_application_scope_nc_id_seq; Type: SEQUENCE; Schema: pb3gir75kkooyea; Owner: admin
--

CREATE SEQUENCE pb3gir75kkooyea.portal_user_application_scope_nc_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE pb3gir75kkooyea.portal_user_application_scope_nc_id_seq OWNER TO admin;

--
-- Name: portal_user_application_scope_nc_id_seq; Type: SEQUENCE OWNED BY; Schema: pb3gir75kkooyea; Owner: admin
--

ALTER SEQUENCE pb3gir75kkooyea.portal_user_application_scope_nc_id_seq OWNED BY pb3gir75kkooyea.portal_user_application_scope.nc_id;


--
-- Name: portal_user_role; Type: TABLE; Schema: pb3gir75kkooyea; Owner: admin
--

CREATE TABLE pb3gir75kkooyea.portal_user_role (
    nc_id integer NOT NULL,
    created_at1 timestamp without time zone,
    updated_at1 timestamp without time zone,
    created_by character varying,
    updated_by character varying,
    nc_order numeric,
    id text NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    version bigint DEFAULT 1 NOT NULL,
    user_id text NOT NULL,
    role_id text NOT NULL,
    granted_by text NOT NULL,
    expires_at timestamp with time zone,
    CONSTRAINT p3_portal_user_role_12b81bc0c5f8 CHECK ((version >= 1))
);


ALTER TABLE pb3gir75kkooyea.portal_user_role OWNER TO admin;

--
-- Name: CONSTRAINT p3_portal_user_role_12b81bc0c5f8 ON portal_user_role; Type: COMMENT; Schema: pb3gir75kkooyea; Owner: admin
--

COMMENT ON CONSTRAINT p3_portal_user_role_12b81bc0c5f8 ON pb3gir75kkooyea.portal_user_role IS 'P3|12b81bc0c5f80bc4dfe99b4d27457f0720bef1303a119c6e5fcff127c8eb3234|CHECK ((version >= 1))';


--
-- Name: portal_user_role_nc_id_seq; Type: SEQUENCE; Schema: pb3gir75kkooyea; Owner: admin
--

CREATE SEQUENCE pb3gir75kkooyea.portal_user_role_nc_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE pb3gir75kkooyea.portal_user_role_nc_id_seq OWNER TO admin;

--
-- Name: portal_user_role_nc_id_seq; Type: SEQUENCE OWNED BY; Schema: pb3gir75kkooyea; Owner: admin
--

ALTER SEQUENCE pb3gir75kkooyea.portal_user_role_nc_id_seq OWNED BY pb3gir75kkooyea.portal_user_role.nc_id;


--
-- Name: push_integration_config; Type: TABLE; Schema: pb3gir75kkooyea; Owner: admin
--

CREATE TABLE pb3gir75kkooyea.push_integration_config (
    nc_id integer NOT NULL,
    created_at1 timestamp without time zone,
    updated_at1 timestamp without time zone,
    created_by character varying,
    updated_by character varying,
    nc_order numeric,
    id text NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    version bigint DEFAULT 1 NOT NULL,
    application_id text NOT NULL,
    kind text NOT NULL,
    mode text DEFAULT 'PUSH'::text NOT NULL,
    credential_ref text,
    field_mapping text DEFAULT '{}'::text NOT NULL,
    value_mapping text DEFAULT '{}'::text NOT NULL,
    target_key_kind text NOT NULL,
    status text DEFAULT 'UNCONFIGURED'::text NOT NULL,
    last_received_at timestamp with time zone,
    enabled text DEFAULT 'DISABLED'::text NOT NULL,
    remark text,
    CONSTRAINT p3_push_integration_config_01a340c66c84 CHECK ((version >= 1)),
    CONSTRAINT p3_push_integration_config_106561401841 CHECK ((mode = 'PUSH'::text)),
    CONSTRAINT p3_push_integration_config_5279b4a53053 CHECK (((value_mapping IS NULL) OR (jsonb_typeof((value_mapping)::jsonb) IS NOT NULL))),
    CONSTRAINT p3_push_integration_config_554dbdb7dd2c CHECK ((kind = ANY (ARRAY['TODO'::text, 'MESSAGE'::text]))),
    CONSTRAINT p3_push_integration_config_6fcd83f64002 CHECK (((field_mapping IS NULL) OR (jsonb_typeof((field_mapping)::jsonb) IS NOT NULL))),
    CONSTRAINT p3_push_integration_config_707055140713 CHECK ((target_key_kind = ANY (ARRAY['UNIFIED_USER_ID'::text, 'EXTERNAL_USER_ID'::text]))),
    CONSTRAINT p3_push_integration_config_dbd995363960 CHECK ((status = ANY (ARRAY['NORMAL'::text, 'ABNORMAL'::text, 'UNCONFIGURED'::text, 'DISABLED'::text]))),
    CONSTRAINT push_integration_config_enabled_check CHECK ((enabled = ANY (ARRAY['ENABLED'::text, 'DISABLED'::text])))
);


ALTER TABLE pb3gir75kkooyea.push_integration_config OWNER TO admin;

--
-- Name: CONSTRAINT p3_push_integration_config_01a340c66c84 ON push_integration_config; Type: COMMENT; Schema: pb3gir75kkooyea; Owner: admin
--

COMMENT ON CONSTRAINT p3_push_integration_config_01a340c66c84 ON pb3gir75kkooyea.push_integration_config IS 'P3|01a340c66c84d0062c7897cb9728463fdf53679a2f892f3fc249d824c25d55a5|CHECK ((version >= 1))';


--
-- Name: CONSTRAINT p3_push_integration_config_106561401841 ON push_integration_config; Type: COMMENT; Schema: pb3gir75kkooyea; Owner: admin
--

COMMENT ON CONSTRAINT p3_push_integration_config_106561401841 ON pb3gir75kkooyea.push_integration_config IS 'P3|106561401841007aafd790386ab5a8a4add53feef61730eb30f57327a1822e00|CHECK ((mode = ''PUSH''::text))';


--
-- Name: CONSTRAINT p3_push_integration_config_5279b4a53053 ON push_integration_config; Type: COMMENT; Schema: pb3gir75kkooyea; Owner: admin
--

COMMENT ON CONSTRAINT p3_push_integration_config_5279b4a53053 ON pb3gir75kkooyea.push_integration_config IS 'P3|5279b4a530539d833f4b9e2fc918c89a95aa1060a2f74d227678ea0e391c49b8|CHECK (((value_mapping IS NULL) OR (jsonb_typeof((value_mapping)::jsonb) IS NOT NULL)))';


--
-- Name: CONSTRAINT p3_push_integration_config_554dbdb7dd2c ON push_integration_config; Type: COMMENT; Schema: pb3gir75kkooyea; Owner: admin
--

COMMENT ON CONSTRAINT p3_push_integration_config_554dbdb7dd2c ON pb3gir75kkooyea.push_integration_config IS 'P3|554dbdb7dd2c383086750f01f1f1a9a415b93ad6994f996fcb167e12c6b0c581|CHECK ((kind = ANY (ARRAY[''TODO''::text, ''MESSAGE''::text])))';


--
-- Name: CONSTRAINT p3_push_integration_config_6fcd83f64002 ON push_integration_config; Type: COMMENT; Schema: pb3gir75kkooyea; Owner: admin
--

COMMENT ON CONSTRAINT p3_push_integration_config_6fcd83f64002 ON pb3gir75kkooyea.push_integration_config IS 'P3|6fcd83f6400260a8c4a1932fc8fec4e9384a7e8086e5ef025ba3ec5bc114fe23|CHECK (((field_mapping IS NULL) OR (jsonb_typeof((field_mapping)::jsonb) IS NOT NULL)))';


--
-- Name: CONSTRAINT p3_push_integration_config_707055140713 ON push_integration_config; Type: COMMENT; Schema: pb3gir75kkooyea; Owner: admin
--

COMMENT ON CONSTRAINT p3_push_integration_config_707055140713 ON pb3gir75kkooyea.push_integration_config IS 'P3|707055140713ef685852941da79cb0dbf486092fff766a18784d531b972aae4c|CHECK ((target_key_kind = ANY (ARRAY[''UNIFIED_USER_ID''::text, ''EXTERNAL_USER_ID''::text])))';


--
-- Name: CONSTRAINT p3_push_integration_config_dbd995363960 ON push_integration_config; Type: COMMENT; Schema: pb3gir75kkooyea; Owner: admin
--

COMMENT ON CONSTRAINT p3_push_integration_config_dbd995363960 ON pb3gir75kkooyea.push_integration_config IS 'P3|dbd995363960ec54950ce2de5263efde55cd944a377b3004c75f629fe1beafbd|CHECK ((status = ANY (ARRAY[''NORMAL''::text, ''ABNORMAL''::text, ''UNCONFIGURED''::text, ''DISABLED''::text])))';


--
-- Name: push_integration_config_nc_id_seq; Type: SEQUENCE; Schema: pb3gir75kkooyea; Owner: admin
--

CREATE SEQUENCE pb3gir75kkooyea.push_integration_config_nc_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE pb3gir75kkooyea.push_integration_config_nc_id_seq OWNER TO admin;

--
-- Name: push_integration_config_nc_id_seq; Type: SEQUENCE OWNED BY; Schema: pb3gir75kkooyea; Owner: admin
--

ALTER SEQUENCE pb3gir75kkooyea.push_integration_config_nc_id_seq OWNED BY pb3gir75kkooyea.push_integration_config.nc_id;


--
-- Name: sms_application; Type: TABLE; Schema: pb3gir75kkooyea; Owner: admin
--

CREATE TABLE pb3gir75kkooyea.sms_application (
    nc_id integer NOT NULL,
    created_at1 timestamp without time zone,
    updated_at1 timestamp without time zone,
    created_by character varying,
    updated_by character varying,
    nc_order numeric,
    id text NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    version bigint DEFAULT 1 NOT NULL,
    application_id text NOT NULL,
    sms_app_id text NOT NULL,
    secret_ref text,
    daily_limit bigint,
    status text DEFAULT 'DISABLED'::text NOT NULL,
    CONSTRAINT p3_sms_application_8185c4a9b499 CHECK ((status = ANY (ARRAY['ENABLED'::text, 'DISABLED'::text]))),
    CONSTRAINT p3_sms_application_e27454d3e97e CHECK ((version >= 1))
);


ALTER TABLE pb3gir75kkooyea.sms_application OWNER TO admin;

--
-- Name: CONSTRAINT p3_sms_application_8185c4a9b499 ON sms_application; Type: COMMENT; Schema: pb3gir75kkooyea; Owner: admin
--

COMMENT ON CONSTRAINT p3_sms_application_8185c4a9b499 ON pb3gir75kkooyea.sms_application IS 'P3|8185c4a9b499dcbebe494165d526cf0a4abfa11e23865709c3ac9d056fa31f26|CHECK ((status = ANY (ARRAY[''ENABLED''::text, ''DISABLED''::text])))';


--
-- Name: CONSTRAINT p3_sms_application_e27454d3e97e ON sms_application; Type: COMMENT; Schema: pb3gir75kkooyea; Owner: admin
--

COMMENT ON CONSTRAINT p3_sms_application_e27454d3e97e ON pb3gir75kkooyea.sms_application IS 'P3|e27454d3e97e9a31a0956a469fd4dfa6dba3e0a2a7f4ab7877a98779cdcb22d5|CHECK ((version >= 1))';


--
-- Name: sms_application_nc_id_seq; Type: SEQUENCE; Schema: pb3gir75kkooyea; Owner: admin
--

CREATE SEQUENCE pb3gir75kkooyea.sms_application_nc_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE pb3gir75kkooyea.sms_application_nc_id_seq OWNER TO admin;

--
-- Name: sms_application_nc_id_seq; Type: SEQUENCE OWNED BY; Schema: pb3gir75kkooyea; Owner: admin
--

ALTER SEQUENCE pb3gir75kkooyea.sms_application_nc_id_seq OWNED BY pb3gir75kkooyea.sms_application.nc_id;


--
-- Name: sms_application_template; Type: TABLE; Schema: pb3gir75kkooyea; Owner: admin
--

CREATE TABLE pb3gir75kkooyea.sms_application_template (
    nc_id integer NOT NULL,
    created_at1 timestamp without time zone,
    updated_at1 timestamp without time zone,
    created_by character varying,
    updated_by character varying,
    nc_order numeric,
    id text NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    version bigint DEFAULT 1 NOT NULL,
    sms_application_id text NOT NULL,
    template_id text NOT NULL,
    CONSTRAINT p3_sms_application_template_43ad448abd70 CHECK ((version >= 1))
);


ALTER TABLE pb3gir75kkooyea.sms_application_template OWNER TO admin;

--
-- Name: CONSTRAINT p3_sms_application_template_43ad448abd70 ON sms_application_template; Type: COMMENT; Schema: pb3gir75kkooyea; Owner: admin
--

COMMENT ON CONSTRAINT p3_sms_application_template_43ad448abd70 ON pb3gir75kkooyea.sms_application_template IS 'P3|43ad448abd704386e41806e5365ae2fb6ebbb44c8ee56256dbaaa6c8e9b43b64|CHECK ((version >= 1))';


--
-- Name: sms_application_template_nc_id_seq; Type: SEQUENCE; Schema: pb3gir75kkooyea; Owner: admin
--

CREATE SEQUENCE pb3gir75kkooyea.sms_application_template_nc_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE pb3gir75kkooyea.sms_application_template_nc_id_seq OWNER TO admin;

--
-- Name: sms_application_template_nc_id_seq; Type: SEQUENCE OWNED BY; Schema: pb3gir75kkooyea; Owner: admin
--

ALTER SEQUENCE pb3gir75kkooyea.sms_application_template_nc_id_seq OWNED BY pb3gir75kkooyea.sms_application_template.nc_id;


--
-- Name: sms_channel; Type: TABLE; Schema: pb3gir75kkooyea; Owner: admin
--

CREATE TABLE pb3gir75kkooyea.sms_channel (
    nc_id integer NOT NULL,
    created_at1 timestamp without time zone,
    updated_at1 timestamp without time zone,
    created_by character varying,
    updated_by character varying,
    nc_order numeric,
    id text NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    version bigint DEFAULT 1 NOT NULL,
    code text NOT NULL,
    name text NOT NULL,
    provider text NOT NULL,
    api_url text NOT NULL,
    secret_ref text NOT NULL,
    sign_name text NOT NULL,
    status text DEFAULT 'DISABLED'::text NOT NULL,
    runtime_status text DEFAULT 'UNCONFIGURED'::text NOT NULL,
    CONSTRAINT p3_sms_channel_912f298682c7 CHECK ((version >= 1)),
    CONSTRAINT p3_sms_channel_9e15f0eb37af CHECK ((runtime_status = ANY (ARRAY['NORMAL'::text, 'ABNORMAL'::text, 'UNCONFIGURED'::text, 'DISABLED'::text]))),
    CONSTRAINT p3_sms_channel_e2f7985595a0 CHECK ((status = ANY (ARRAY['ENABLED'::text, 'DISABLED'::text])))
);


ALTER TABLE pb3gir75kkooyea.sms_channel OWNER TO admin;

--
-- Name: CONSTRAINT p3_sms_channel_912f298682c7 ON sms_channel; Type: COMMENT; Schema: pb3gir75kkooyea; Owner: admin
--

COMMENT ON CONSTRAINT p3_sms_channel_912f298682c7 ON pb3gir75kkooyea.sms_channel IS 'P3|912f298682c75abaee869e3345224756419dc6c769218533325185fc7cffd4fd|CHECK ((version >= 1))';


--
-- Name: CONSTRAINT p3_sms_channel_9e15f0eb37af ON sms_channel; Type: COMMENT; Schema: pb3gir75kkooyea; Owner: admin
--

COMMENT ON CONSTRAINT p3_sms_channel_9e15f0eb37af ON pb3gir75kkooyea.sms_channel IS 'P3|9e15f0eb37af80b5b914bae7333c611c7f09830e2aa7f4e9701676a71f503304|CHECK ((runtime_status = ANY (ARRAY[''NORMAL''::text, ''ABNORMAL''::text, ''UNCONFIGURED''::text, ''DISABLED''::text])))';


--
-- Name: CONSTRAINT p3_sms_channel_e2f7985595a0 ON sms_channel; Type: COMMENT; Schema: pb3gir75kkooyea; Owner: admin
--

COMMENT ON CONSTRAINT p3_sms_channel_e2f7985595a0 ON pb3gir75kkooyea.sms_channel IS 'P3|e2f7985595a0ef5373b5e1a0cb5ddfd13238c77e9c64bffbb9a5daefd4c4a468|CHECK ((status = ANY (ARRAY[''ENABLED''::text, ''DISABLED''::text])))';


--
-- Name: sms_channel_nc_id_seq; Type: SEQUENCE; Schema: pb3gir75kkooyea; Owner: admin
--

CREATE SEQUENCE pb3gir75kkooyea.sms_channel_nc_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE pb3gir75kkooyea.sms_channel_nc_id_seq OWNER TO admin;

--
-- Name: sms_channel_nc_id_seq; Type: SEQUENCE OWNED BY; Schema: pb3gir75kkooyea; Owner: admin
--

ALTER SEQUENCE pb3gir75kkooyea.sms_channel_nc_id_seq OWNED BY pb3gir75kkooyea.sms_channel.nc_id;


--
-- Name: sms_send_attempt; Type: TABLE; Schema: pb3gir75kkooyea; Owner: admin
--

CREATE TABLE pb3gir75kkooyea.sms_send_attempt (
    nc_id integer NOT NULL,
    created_at1 timestamp without time zone,
    updated_at1 timestamp without time zone,
    created_by character varying,
    updated_by character varying,
    nc_order numeric,
    id text NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    version bigint DEFAULT 1 NOT NULL,
    send_id text NOT NULL,
    attempt_no bigint NOT NULL,
    provider_request_id text,
    status text NOT NULL,
    delivery_certainty text DEFAULT 'UNKNOWN'::text NOT NULL,
    fee_minor_units bigint,
    currency text,
    finished_at timestamp with time zone,
    provider_summary text,
    CONSTRAINT p3_sms_send_attempt_3deb9e252a72 CHECK ((delivery_certainty = ANY (ARRAY['UNKNOWN'::text, 'CONFIRMED_SUCCESS'::text, 'CONFIRMED_FAILURE'::text]))),
    CONSTRAINT p3_sms_send_attempt_84b82df41412 CHECK ((attempt_no >= 1)),
    CONSTRAINT p3_sms_send_attempt_a9951d0b969e CHECK ((status = ANY (ARRAY['PENDING'::text, 'SENDING'::text, 'SUCCESS'::text, 'FAILED'::text]))),
    CONSTRAINT p3_sms_send_attempt_b5bf19a14472 CHECK ((version >= 1))
);


ALTER TABLE pb3gir75kkooyea.sms_send_attempt OWNER TO admin;

--
-- Name: CONSTRAINT p3_sms_send_attempt_3deb9e252a72 ON sms_send_attempt; Type: COMMENT; Schema: pb3gir75kkooyea; Owner: admin
--

COMMENT ON CONSTRAINT p3_sms_send_attempt_3deb9e252a72 ON pb3gir75kkooyea.sms_send_attempt IS 'P3|3deb9e252a723f3baf3c8329cebda0aa66326c81d1fc4d5de05c9f57f8bf3966|CHECK ((delivery_certainty = ANY (ARRAY[''UNKNOWN''::text, ''CONFIRMED_SUCCESS''::text, ''CONFIRMED_FAILURE''::text])))';


--
-- Name: CONSTRAINT p3_sms_send_attempt_84b82df41412 ON sms_send_attempt; Type: COMMENT; Schema: pb3gir75kkooyea; Owner: admin
--

COMMENT ON CONSTRAINT p3_sms_send_attempt_84b82df41412 ON pb3gir75kkooyea.sms_send_attempt IS 'P3|84b82df4141263057587ba80788734bc8afe5834f6f2b4580279678582ab08d9|CHECK ((attempt_no >= 1))';


--
-- Name: CONSTRAINT p3_sms_send_attempt_a9951d0b969e ON sms_send_attempt; Type: COMMENT; Schema: pb3gir75kkooyea; Owner: admin
--

COMMENT ON CONSTRAINT p3_sms_send_attempt_a9951d0b969e ON pb3gir75kkooyea.sms_send_attempt IS 'P3|a9951d0b969e912009eb736553d8e7a2551b3f9c8633d791c2cd8633eb606027|CHECK ((status = ANY (ARRAY[''PENDING''::text, ''SENDING''::text, ''SUCCESS''::text, ''FAILED''::text])))';


--
-- Name: CONSTRAINT p3_sms_send_attempt_b5bf19a14472 ON sms_send_attempt; Type: COMMENT; Schema: pb3gir75kkooyea; Owner: admin
--

COMMENT ON CONSTRAINT p3_sms_send_attempt_b5bf19a14472 ON pb3gir75kkooyea.sms_send_attempt IS 'P3|b5bf19a14472908fdc2f983f5fc85c6e2215dc263bde700ce64596f21833dd98|CHECK ((version >= 1))';


--
-- Name: sms_send_attempt_nc_id_seq; Type: SEQUENCE; Schema: pb3gir75kkooyea; Owner: admin
--

CREATE SEQUENCE pb3gir75kkooyea.sms_send_attempt_nc_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE pb3gir75kkooyea.sms_send_attempt_nc_id_seq OWNER TO admin;

--
-- Name: sms_send_attempt_nc_id_seq; Type: SEQUENCE OWNED BY; Schema: pb3gir75kkooyea; Owner: admin
--

ALTER SEQUENCE pb3gir75kkooyea.sms_send_attempt_nc_id_seq OWNED BY pb3gir75kkooyea.sms_send_attempt.nc_id;


--
-- Name: sms_send_record; Type: TABLE; Schema: pb3gir75kkooyea; Owner: admin
--

CREATE TABLE pb3gir75kkooyea.sms_send_record (
    nc_id integer NOT NULL,
    created_at1 timestamp without time zone,
    updated_at1 timestamp without time zone,
    created_by character varying,
    updated_by character varying,
    nc_order numeric,
    id text NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    version bigint DEFAULT 1 NOT NULL,
    application_id text NOT NULL,
    template_id text NOT NULL,
    channel_id text NOT NULL,
    request_key text NOT NULL,
    payload_hash text NOT NULL,
    mobile_masked text NOT NULL,
    recipient_secret_ref text NOT NULL,
    variables_secret_ref text NOT NULL,
    content_summary text,
    status text DEFAULT 'PENDING'::text NOT NULL,
    retry_count bigint DEFAULT 0 NOT NULL,
    failure_reason text,
    CONSTRAINT p3_sms_send_record_6098449abf5f CHECK ((status = ANY (ARRAY['PENDING'::text, 'SENDING'::text, 'SUCCESS'::text, 'FAILED'::text]))),
    CONSTRAINT p3_sms_send_record_b5ce0a95d239 CHECK ((retry_count >= 0)),
    CONSTRAINT p3_sms_send_record_fa4f8ee1da7c CHECK ((version >= 1))
);


ALTER TABLE pb3gir75kkooyea.sms_send_record OWNER TO admin;

--
-- Name: CONSTRAINT p3_sms_send_record_6098449abf5f ON sms_send_record; Type: COMMENT; Schema: pb3gir75kkooyea; Owner: admin
--

COMMENT ON CONSTRAINT p3_sms_send_record_6098449abf5f ON pb3gir75kkooyea.sms_send_record IS 'P3|6098449abf5fc71af0bd98b9e68e030815d64f004c0bede6abf9a49640f9c8b2|CHECK ((status = ANY (ARRAY[''PENDING''::text, ''SENDING''::text, ''SUCCESS''::text, ''FAILED''::text])))';


--
-- Name: CONSTRAINT p3_sms_send_record_b5ce0a95d239 ON sms_send_record; Type: COMMENT; Schema: pb3gir75kkooyea; Owner: admin
--

COMMENT ON CONSTRAINT p3_sms_send_record_b5ce0a95d239 ON pb3gir75kkooyea.sms_send_record IS 'P3|b5ce0a95d239796816f45544c209a84f2e6e3557a0dd41ff1d7de079e2568547|CHECK ((retry_count >= 0))';


--
-- Name: CONSTRAINT p3_sms_send_record_fa4f8ee1da7c ON sms_send_record; Type: COMMENT; Schema: pb3gir75kkooyea; Owner: admin
--

COMMENT ON CONSTRAINT p3_sms_send_record_fa4f8ee1da7c ON pb3gir75kkooyea.sms_send_record IS 'P3|fa4f8ee1da7c6f5977e222cd0726c8b38e4519bb63a94150d1a68278f34c8272|CHECK ((version >= 1))';


--
-- Name: sms_send_record_nc_id_seq; Type: SEQUENCE; Schema: pb3gir75kkooyea; Owner: admin
--

CREATE SEQUENCE pb3gir75kkooyea.sms_send_record_nc_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE pb3gir75kkooyea.sms_send_record_nc_id_seq OWNER TO admin;

--
-- Name: sms_send_record_nc_id_seq; Type: SEQUENCE OWNED BY; Schema: pb3gir75kkooyea; Owner: admin
--

ALTER SEQUENCE pb3gir75kkooyea.sms_send_record_nc_id_seq OWNED BY pb3gir75kkooyea.sms_send_record.nc_id;


--
-- Name: sms_template; Type: TABLE; Schema: pb3gir75kkooyea; Owner: admin
--

CREATE TABLE pb3gir75kkooyea.sms_template (
    nc_id integer NOT NULL,
    created_at1 timestamp without time zone,
    updated_at1 timestamp without time zone,
    created_by character varying,
    updated_by character varying,
    nc_order numeric,
    id text NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    version bigint DEFAULT 1 NOT NULL,
    code text NOT NULL,
    name text NOT NULL,
    scene_type text NOT NULL,
    content text NOT NULL,
    variables text DEFAULT '{}'::text NOT NULL,
    sign_name text NOT NULL,
    provider_template_id text,
    status text DEFAULT 'DISABLED'::text NOT NULL,
    CONSTRAINT p3_sms_template_0d0b15823b51 CHECK (((variables IS NULL) OR (jsonb_typeof((variables)::jsonb) IS NOT NULL))),
    CONSTRAINT p3_sms_template_7ecb536cd51c CHECK ((status = ANY (ARRAY['ENABLED'::text, 'DISABLED'::text]))),
    CONSTRAINT p3_sms_template_a336c511ae25 CHECK ((version >= 1))
);


ALTER TABLE pb3gir75kkooyea.sms_template OWNER TO admin;

--
-- Name: CONSTRAINT p3_sms_template_0d0b15823b51 ON sms_template; Type: COMMENT; Schema: pb3gir75kkooyea; Owner: admin
--

COMMENT ON CONSTRAINT p3_sms_template_0d0b15823b51 ON pb3gir75kkooyea.sms_template IS 'P3|0d0b15823b510f5e07b1998a7dfadbac5c59522d0b6d835dd9414fbd4847f97a|CHECK (((variables IS NULL) OR (jsonb_typeof((variables)::jsonb) IS NOT NULL)))';


--
-- Name: CONSTRAINT p3_sms_template_7ecb536cd51c ON sms_template; Type: COMMENT; Schema: pb3gir75kkooyea; Owner: admin
--

COMMENT ON CONSTRAINT p3_sms_template_7ecb536cd51c ON pb3gir75kkooyea.sms_template IS 'P3|7ecb536cd51c02d6f32ed07b9f995bda6f27981d31e9b9fd63aabce37a257bb4|CHECK ((status = ANY (ARRAY[''ENABLED''::text, ''DISABLED''::text])))';


--
-- Name: CONSTRAINT p3_sms_template_a336c511ae25 ON sms_template; Type: COMMENT; Schema: pb3gir75kkooyea; Owner: admin
--

COMMENT ON CONSTRAINT p3_sms_template_a336c511ae25 ON pb3gir75kkooyea.sms_template IS 'P3|a336c511ae25ec078c30e23a09384806de1e6c3964ddc4156df65ca666cad748|CHECK ((version >= 1))';


--
-- Name: sms_template_nc_id_seq; Type: SEQUENCE; Schema: pb3gir75kkooyea; Owner: admin
--

CREATE SEQUENCE pb3gir75kkooyea.sms_template_nc_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE pb3gir75kkooyea.sms_template_nc_id_seq OWNER TO admin;

--
-- Name: sms_template_nc_id_seq; Type: SEQUENCE OWNED BY; Schema: pb3gir75kkooyea; Owner: admin
--

ALTER SEQUENCE pb3gir75kkooyea.sms_template_nc_id_seq OWNED BY pb3gir75kkooyea.sms_template.nc_id;


--
-- Name: sso_config; Type: TABLE; Schema: pb3gir75kkooyea; Owner: admin
--

CREATE TABLE pb3gir75kkooyea.sso_config (
    nc_id integer NOT NULL,
    created_at1 timestamp without time zone,
    updated_at1 timestamp without time zone,
    created_by character varying,
    updated_by character varying,
    nc_order numeric,
    id text NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    version bigint DEFAULT 1 NOT NULL,
    application_id text NOT NULL,
    protocol text NOT NULL,
    client_id text,
    secret_ref text,
    endpoints text DEFAULT '{}'::text NOT NULL,
    user_key_field text,
    token_expire_seconds bigint,
    status text DEFAULT 'UNCONFIGURED'::text NOT NULL,
    enabled text DEFAULT 'DISABLED'::text NOT NULL,
    remark text,
    CONSTRAINT p3_sso_config_061254b8193d CHECK (((endpoints IS NULL) OR (jsonb_typeof((endpoints)::jsonb) IS NOT NULL))),
    CONSTRAINT p3_sso_config_9980d02cf243 CHECK ((version >= 1)),
    CONSTRAINT p3_sso_config_eace3eddbdc3 CHECK ((status = ANY (ARRAY['NORMAL'::text, 'ABNORMAL'::text, 'UNCONFIGURED'::text, 'DISABLED'::text]))),
    CONSTRAINT sso_config_enabled_check CHECK ((enabled = ANY (ARRAY['ENABLED'::text, 'DISABLED'::text])))
);


ALTER TABLE pb3gir75kkooyea.sso_config OWNER TO admin;

--
-- Name: CONSTRAINT p3_sso_config_061254b8193d ON sso_config; Type: COMMENT; Schema: pb3gir75kkooyea; Owner: admin
--

COMMENT ON CONSTRAINT p3_sso_config_061254b8193d ON pb3gir75kkooyea.sso_config IS 'P3|061254b8193d7ade1e7b80e70bedd1801c2deb5cecbc73b19705af35b37bb815|CHECK (((endpoints IS NULL) OR (jsonb_typeof((endpoints)::jsonb) IS NOT NULL)))';


--
-- Name: CONSTRAINT p3_sso_config_9980d02cf243 ON sso_config; Type: COMMENT; Schema: pb3gir75kkooyea; Owner: admin
--

COMMENT ON CONSTRAINT p3_sso_config_9980d02cf243 ON pb3gir75kkooyea.sso_config IS 'P3|9980d02cf2431b8d300fbd4c97dfac35be82f8be761da120e920b25076ee9854|CHECK ((version >= 1))';


--
-- Name: CONSTRAINT p3_sso_config_eace3eddbdc3 ON sso_config; Type: COMMENT; Schema: pb3gir75kkooyea; Owner: admin
--

COMMENT ON CONSTRAINT p3_sso_config_eace3eddbdc3 ON pb3gir75kkooyea.sso_config IS 'P3|eace3eddbdc31df43c253c631f88a5f92969c1671a25a4ba070d24fdd20aa642|CHECK ((status = ANY (ARRAY[''NORMAL''::text, ''ABNORMAL''::text, ''UNCONFIGURED''::text, ''DISABLED''::text])))';


--
-- Name: sso_config_nc_id_seq; Type: SEQUENCE; Schema: pb3gir75kkooyea; Owner: admin
--

CREATE SEQUENCE pb3gir75kkooyea.sso_config_nc_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE pb3gir75kkooyea.sso_config_nc_id_seq OWNER TO admin;

--
-- Name: sso_config_nc_id_seq; Type: SEQUENCE OWNED BY; Schema: pb3gir75kkooyea; Owner: admin
--

ALTER SEQUENCE pb3gir75kkooyea.sso_config_nc_id_seq OWNED BY pb3gir75kkooyea.sso_config.nc_id;


--
-- Name: system_config; Type: TABLE; Schema: pb3gir75kkooyea; Owner: admin
--

CREATE TABLE pb3gir75kkooyea.system_config (
    nc_id integer NOT NULL,
    created_at1 timestamp without time zone,
    updated_at1 timestamp without time zone,
    created_by character varying,
    updated_by character varying,
    nc_order numeric,
    id text NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    version bigint DEFAULT 1 NOT NULL,
    code text NOT NULL,
    value text,
    unit text NOT NULL,
    status text DEFAULT 'UNCONFIGURED'::text NOT NULL,
    description text NOT NULL,
    CONSTRAINT p3_system_config_ade90e9096ea CHECK ((version >= 1)),
    CONSTRAINT p3_system_config_c165b4c2d2e7 CHECK ((((status = 'UNCONFIGURED'::text) AND ((value)::jsonb IS NULL)) OR ((status = 'CONFIGURED'::text) AND ((value)::jsonb IS NOT NULL)))),
    CONSTRAINT p3_system_config_c29ccc91b551 CHECK (((value IS NULL) OR (jsonb_typeof((value)::jsonb) IS NOT NULL))),
    CONSTRAINT p3_system_config_e8b959b2603c CHECK ((status = ANY (ARRAY['UNCONFIGURED'::text, 'CONFIGURED'::text])))
);


ALTER TABLE pb3gir75kkooyea.system_config OWNER TO admin;

--
-- Name: CONSTRAINT p3_system_config_ade90e9096ea ON system_config; Type: COMMENT; Schema: pb3gir75kkooyea; Owner: admin
--

COMMENT ON CONSTRAINT p3_system_config_ade90e9096ea ON pb3gir75kkooyea.system_config IS 'P3|ade90e9096ea8657466dcd92989facd48310083e79195bae6a592b3f0ddfec5c|CHECK ((version >= 1))';


--
-- Name: CONSTRAINT p3_system_config_c165b4c2d2e7 ON system_config; Type: COMMENT; Schema: pb3gir75kkooyea; Owner: admin
--

COMMENT ON CONSTRAINT p3_system_config_c165b4c2d2e7 ON pb3gir75kkooyea.system_config IS 'P3|c165b4c2d2e7a3f6f342aec199b84c4c0b5bebf99c6c6d930aa41e7f0bea0566|CHECK ((((status = ''UNCONFIGURED''::text) AND ((value)::jsonb IS NULL)) OR ((status = ''CONFIGURED''::text) AND ((value)::jsonb IS NOT NULL))))';


--
-- Name: CONSTRAINT p3_system_config_c29ccc91b551 ON system_config; Type: COMMENT; Schema: pb3gir75kkooyea; Owner: admin
--

COMMENT ON CONSTRAINT p3_system_config_c29ccc91b551 ON pb3gir75kkooyea.system_config IS 'P3|c29ccc91b5519b22711d50e4a805211f52b6599188ef25ea578b66ce61dbd518|CHECK (((value IS NULL) OR (jsonb_typeof((value)::jsonb) IS NOT NULL)))';


--
-- Name: CONSTRAINT p3_system_config_e8b959b2603c ON system_config; Type: COMMENT; Schema: pb3gir75kkooyea; Owner: admin
--

COMMENT ON CONSTRAINT p3_system_config_e8b959b2603c ON pb3gir75kkooyea.system_config IS 'P3|e8b959b2603c01f0c8cfd673c6f6900b7503deba3efa1d43f78ca848eb910dc6|CHECK ((status = ANY (ARRAY[''UNCONFIGURED''::text, ''CONFIGURED''::text])))';


--
-- Name: system_config_nc_id_seq; Type: SEQUENCE; Schema: pb3gir75kkooyea; Owner: admin
--

CREATE SEQUENCE pb3gir75kkooyea.system_config_nc_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE pb3gir75kkooyea.system_config_nc_id_seq OWNER TO admin;

--
-- Name: system_config_nc_id_seq; Type: SEQUENCE OWNED BY; Schema: pb3gir75kkooyea; Owner: admin
--

ALTER SEQUENCE pb3gir75kkooyea.system_config_nc_id_seq OWNED BY pb3gir75kkooyea.system_config.nc_id;


--
-- Name: todo_item; Type: TABLE; Schema: pb3gir75kkooyea; Owner: admin
--

CREATE TABLE pb3gir75kkooyea.todo_item (
    nc_id integer NOT NULL,
    created_at1 timestamp without time zone,
    updated_at1 timestamp without time zone,
    created_by character varying,
    updated_by character varying,
    nc_order numeric,
    id text NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    version bigint DEFAULT 1 NOT NULL,
    application_id text NOT NULL,
    source_todo_id text NOT NULL,
    target_user_id text NOT NULL,
    title text NOT NULL,
    business_type text,
    summary text,
    status text DEFAULT 'PENDING'::text NOT NULL,
    priority text DEFAULT 'MEDIUM'::text NOT NULL,
    source_created_at timestamp with time zone NOT NULL,
    source_updated_at timestamp with time zone NOT NULL,
    source_revision bigint NOT NULL,
    due_at timestamp with time zone,
    terminal_at timestamp with time zone,
    business_url text NOT NULL,
    runtime_id text,
    received_at timestamp with time zone,
    archived_at timestamp with time zone,
    CONSTRAINT p3_todo_item_17704daf8cc1 CHECK ((((status = 'PENDING'::text) AND (terminal_at IS NULL)) OR ((status <> 'PENDING'::text) AND (terminal_at IS NOT NULL)))),
    CONSTRAINT p3_todo_item_42b2122efa6a CHECK ((version >= 1)),
    CONSTRAINT p3_todo_item_9aec774b552c CHECK ((priority = ANY (ARRAY['HIGH'::text, 'MEDIUM'::text, 'LOW'::text]))),
    CONSTRAINT p3_todo_item_9c8d70bfa76f CHECK ((source_revision >= 1)),
    CONSTRAINT p3_todo_item_e0177c24c192 CHECK ((status = ANY (ARRAY['PENDING'::text, 'COMPLETED'::text, 'WITHDRAWN'::text, 'EXPIRED'::text])))
);


ALTER TABLE pb3gir75kkooyea.todo_item OWNER TO admin;

--
-- Name: COLUMN todo_item.priority; Type: COMMENT; Schema: pb3gir75kkooyea; Owner: admin
--

COMMENT ON COLUMN pb3gir75kkooyea.todo_item.priority IS 'Legacy compatibility field; hidden from portal UI and public PUSH contract; not used for cross-application ranking.';


--
-- Name: CONSTRAINT p3_todo_item_17704daf8cc1 ON todo_item; Type: COMMENT; Schema: pb3gir75kkooyea; Owner: admin
--

COMMENT ON CONSTRAINT p3_todo_item_17704daf8cc1 ON pb3gir75kkooyea.todo_item IS 'P3|17704daf8cc1a74cda97ab93f23f6c11104832ed6912d51f67c0904c4407fdde|CHECK ((((status = ''PENDING''::text) AND (terminal_at IS NULL)) OR ((status <> ''PENDING''::text) AND (terminal_at IS NOT NULL))))';


--
-- Name: CONSTRAINT p3_todo_item_42b2122efa6a ON todo_item; Type: COMMENT; Schema: pb3gir75kkooyea; Owner: admin
--

COMMENT ON CONSTRAINT p3_todo_item_42b2122efa6a ON pb3gir75kkooyea.todo_item IS 'P3|42b2122efa6ac622c46ee465bee1f02111fa730cef99b9f1dc28e66f94f3d415|CHECK ((version >= 1))';


--
-- Name: CONSTRAINT p3_todo_item_9aec774b552c ON todo_item; Type: COMMENT; Schema: pb3gir75kkooyea; Owner: admin
--

COMMENT ON CONSTRAINT p3_todo_item_9aec774b552c ON pb3gir75kkooyea.todo_item IS 'P3|9aec774b552ca0d3b25da6542719fa1a370734c4c6370b00886e10408502cdde|CHECK ((priority = ANY (ARRAY[''HIGH''::text, ''MEDIUM''::text, ''LOW''::text])))';


--
-- Name: CONSTRAINT p3_todo_item_9c8d70bfa76f ON todo_item; Type: COMMENT; Schema: pb3gir75kkooyea; Owner: admin
--

COMMENT ON CONSTRAINT p3_todo_item_9c8d70bfa76f ON pb3gir75kkooyea.todo_item IS 'P3|9c8d70bfa76fcb67e5728687a9b5c621e0948e3f69304dc829cb25dc14bb074a|CHECK ((source_revision >= 1))';


--
-- Name: CONSTRAINT p3_todo_item_e0177c24c192 ON todo_item; Type: COMMENT; Schema: pb3gir75kkooyea; Owner: admin
--

COMMENT ON CONSTRAINT p3_todo_item_e0177c24c192 ON pb3gir75kkooyea.todo_item IS 'P3|e0177c24c192d936fe48a90f61c4752d123ad109de97155cedba712c4d10de33|CHECK ((status = ANY (ARRAY[''PENDING''::text, ''COMPLETED''::text, ''WITHDRAWN''::text, ''EXPIRED''::text])))';


--
-- Name: todo_item_nc_id_seq; Type: SEQUENCE; Schema: pb3gir75kkooyea; Owner: admin
--

CREATE SEQUENCE pb3gir75kkooyea.todo_item_nc_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE pb3gir75kkooyea.todo_item_nc_id_seq OWNER TO admin;

--
-- Name: todo_item_nc_id_seq; Type: SEQUENCE OWNED BY; Schema: pb3gir75kkooyea; Owner: admin
--

ALTER SEQUENCE pb3gir75kkooyea.todo_item_nc_id_seq OWNED BY pb3gir75kkooyea.todo_item.nc_id;


--
-- Name: unified_user; Type: TABLE; Schema: pb3gir75kkooyea; Owner: admin
--

CREATE TABLE pb3gir75kkooyea.unified_user (
    nc_id integer NOT NULL,
    created_at1 timestamp without time zone,
    updated_at1 timestamp without time zone,
    created_by character varying,
    updated_by character varying,
    nc_order numeric,
    id text NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    version bigint DEFAULT 1 NOT NULL,
    display_name text,
    org_key text,
    org_name text,
    status text DEFAULT 'NORMAL'::text NOT NULL,
    first_login_at timestamp with time zone,
    last_login_at timestamp with time zone,
    CONSTRAINT p3_unified_user_739b419ca5e8 CHECK ((version >= 1)),
    CONSTRAINT p3_unified_user_a3fa466b5bf1 CHECK ((status = ANY (ARRAY['NORMAL'::text, 'ABNORMAL'::text, 'DISABLED'::text])))
);


ALTER TABLE pb3gir75kkooyea.unified_user OWNER TO admin;

--
-- Name: CONSTRAINT p3_unified_user_739b419ca5e8 ON unified_user; Type: COMMENT; Schema: pb3gir75kkooyea; Owner: admin
--

COMMENT ON CONSTRAINT p3_unified_user_739b419ca5e8 ON pb3gir75kkooyea.unified_user IS 'P3|739b419ca5e81fd189fbae9b05b4aab5e22d4e62fe8f8cd3ddae01fae2c33880|CHECK ((version >= 1))';


--
-- Name: CONSTRAINT p3_unified_user_a3fa466b5bf1 ON unified_user; Type: COMMENT; Schema: pb3gir75kkooyea; Owner: admin
--

COMMENT ON CONSTRAINT p3_unified_user_a3fa466b5bf1 ON pb3gir75kkooyea.unified_user IS 'P3|a3fa466b5bf1305531c13423e6f7589219e145d08762c532eceba47e38019b57|CHECK ((status = ANY (ARRAY[''NORMAL''::text, ''ABNORMAL''::text, ''DISABLED''::text])))';


--
-- Name: unified_user_nc_id_seq; Type: SEQUENCE; Schema: pb3gir75kkooyea; Owner: admin
--

CREATE SEQUENCE pb3gir75kkooyea.unified_user_nc_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE pb3gir75kkooyea.unified_user_nc_id_seq OWNER TO admin;

--
-- Name: unified_user_nc_id_seq; Type: SEQUENCE OWNED BY; Schema: pb3gir75kkooyea; Owner: admin
--

ALTER SEQUENCE pb3gir75kkooyea.unified_user_nc_id_seq OWNED BY pb3gir75kkooyea.unified_user.nc_id;


--
-- Name: announcement nc_id; Type: DEFAULT; Schema: pb3gir75kkooyea; Owner: admin
--

ALTER TABLE ONLY pb3gir75kkooyea.announcement ALTER COLUMN nc_id SET DEFAULT nextval('pb3gir75kkooyea.announcement_nc_id_seq'::regclass);


--
-- Name: announcement_attachment nc_id; Type: DEFAULT; Schema: pb3gir75kkooyea; Owner: admin
--

ALTER TABLE ONLY pb3gir75kkooyea.announcement_attachment ALTER COLUMN nc_id SET DEFAULT nextval('pb3gir75kkooyea.announcement_attachment_nc_id_seq'::regclass);


--
-- Name: announcement_org_scope nc_id; Type: DEFAULT; Schema: pb3gir75kkooyea; Owner: admin
--

ALTER TABLE ONLY pb3gir75kkooyea.announcement_org_scope ALTER COLUMN nc_id SET DEFAULT nextval('pb3gir75kkooyea.announcement_org_scope_nc_id_seq'::regclass);


--
-- Name: application nc_id; Type: DEFAULT; Schema: pb3gir75kkooyea; Owner: admin
--

ALTER TABLE ONLY pb3gir75kkooyea.application ALTER COLUMN nc_id SET DEFAULT nextval('pb3gir75kkooyea.application_nc_id_seq'::regclass);


--
-- Name: application_category nc_id; Type: DEFAULT; Schema: pb3gir75kkooyea; Owner: admin
--

ALTER TABLE ONLY pb3gir75kkooyea.application_category ALTER COLUMN nc_id SET DEFAULT nextval('pb3gir75kkooyea.application_category_nc_id_seq'::regclass);


--
-- Name: application_user_mapping nc_id; Type: DEFAULT; Schema: pb3gir75kkooyea; Owner: admin
--

ALTER TABLE ONLY pb3gir75kkooyea.application_user_mapping ALTER COLUMN nc_id SET DEFAULT nextval('pb3gir75kkooyea.application_user_mapping_nc_id_seq'::regclass);


--
-- Name: audit_event nc_id; Type: DEFAULT; Schema: pb3gir75kkooyea; Owner: admin
--

ALTER TABLE ONLY pb3gir75kkooyea.audit_event ALTER COLUMN nc_id SET DEFAULT nextval('pb3gir75kkooyea.audit_event_nc_id_seq'::regclass);


--
-- Name: identity_mapping nc_id; Type: DEFAULT; Schema: pb3gir75kkooyea; Owner: admin
--

ALTER TABLE ONLY pb3gir75kkooyea.identity_mapping ALTER COLUMN nc_id SET DEFAULT nextval('pb3gir75kkooyea.identity_mapping_nc_id_seq'::regclass);


--
-- Name: identity_source nc_id; Type: DEFAULT; Schema: pb3gir75kkooyea; Owner: admin
--

ALTER TABLE ONLY pb3gir75kkooyea.identity_source ALTER COLUMN nc_id SET DEFAULT nextval('pb3gir75kkooyea.identity_source_nc_id_seq'::regclass);


--
-- Name: ingest_receipt nc_id; Type: DEFAULT; Schema: pb3gir75kkooyea; Owner: admin
--

ALTER TABLE ONLY pb3gir75kkooyea.ingest_receipt ALTER COLUMN nc_id SET DEFAULT nextval('pb3gir75kkooyea.ingest_receipt_nc_id_seq'::regclass);


--
-- Name: login_request nc_id; Type: DEFAULT; Schema: pb3gir75kkooyea; Owner: admin
--

ALTER TABLE ONLY pb3gir75kkooyea.login_request ALTER COLUMN nc_id SET DEFAULT nextval('pb3gir75kkooyea.login_request_nc_id_seq'::regclass);


--
-- Name: mapping_exception nc_id; Type: DEFAULT; Schema: pb3gir75kkooyea; Owner: admin
--

ALTER TABLE ONLY pb3gir75kkooyea.mapping_exception ALTER COLUMN nc_id SET DEFAULT nextval('pb3gir75kkooyea.mapping_exception_nc_id_seq'::regclass);


--
-- Name: message nc_id; Type: DEFAULT; Schema: pb3gir75kkooyea; Owner: admin
--

ALTER TABLE ONLY pb3gir75kkooyea.message ALTER COLUMN nc_id SET DEFAULT nextval('pb3gir75kkooyea.message_nc_id_seq'::regclass);


--
-- Name: message_recipient nc_id; Type: DEFAULT; Schema: pb3gir75kkooyea; Owner: admin
--

ALTER TABLE ONLY pb3gir75kkooyea.message_recipient ALTER COLUMN nc_id SET DEFAULT nextval('pb3gir75kkooyea.message_recipient_nc_id_seq'::regclass);


--
-- Name: monitor_status nc_id; Type: DEFAULT; Schema: pb3gir75kkooyea; Owner: admin
--

ALTER TABLE ONLY pb3gir75kkooyea.monitor_status ALTER COLUMN nc_id SET DEFAULT nextval('pb3gir75kkooyea.monitor_status_nc_id_seq'::regclass);


--
-- Name: portal_permission nc_id; Type: DEFAULT; Schema: pb3gir75kkooyea; Owner: admin
--

ALTER TABLE ONLY pb3gir75kkooyea.portal_permission ALTER COLUMN nc_id SET DEFAULT nextval('pb3gir75kkooyea.portal_permission_nc_id_seq'::regclass);


--
-- Name: portal_role nc_id; Type: DEFAULT; Schema: pb3gir75kkooyea; Owner: admin
--

ALTER TABLE ONLY pb3gir75kkooyea.portal_role ALTER COLUMN nc_id SET DEFAULT nextval('pb3gir75kkooyea.portal_role_nc_id_seq'::regclass);


--
-- Name: portal_role_permission nc_id; Type: DEFAULT; Schema: pb3gir75kkooyea; Owner: admin
--

ALTER TABLE ONLY pb3gir75kkooyea.portal_role_permission ALTER COLUMN nc_id SET DEFAULT nextval('pb3gir75kkooyea.portal_role_permission_nc_id_seq'::regclass);


--
-- Name: portal_session nc_id; Type: DEFAULT; Schema: pb3gir75kkooyea; Owner: admin
--

ALTER TABLE ONLY pb3gir75kkooyea.portal_session ALTER COLUMN nc_id SET DEFAULT nextval('pb3gir75kkooyea.portal_session_nc_id_seq'::regclass);


--
-- Name: portal_user_application_scope nc_id; Type: DEFAULT; Schema: pb3gir75kkooyea; Owner: admin
--

ALTER TABLE ONLY pb3gir75kkooyea.portal_user_application_scope ALTER COLUMN nc_id SET DEFAULT nextval('pb3gir75kkooyea.portal_user_application_scope_nc_id_seq'::regclass);


--
-- Name: portal_user_role nc_id; Type: DEFAULT; Schema: pb3gir75kkooyea; Owner: admin
--

ALTER TABLE ONLY pb3gir75kkooyea.portal_user_role ALTER COLUMN nc_id SET DEFAULT nextval('pb3gir75kkooyea.portal_user_role_nc_id_seq'::regclass);


--
-- Name: push_integration_config nc_id; Type: DEFAULT; Schema: pb3gir75kkooyea; Owner: admin
--

ALTER TABLE ONLY pb3gir75kkooyea.push_integration_config ALTER COLUMN nc_id SET DEFAULT nextval('pb3gir75kkooyea.push_integration_config_nc_id_seq'::regclass);


--
-- Name: sms_application nc_id; Type: DEFAULT; Schema: pb3gir75kkooyea; Owner: admin
--

ALTER TABLE ONLY pb3gir75kkooyea.sms_application ALTER COLUMN nc_id SET DEFAULT nextval('pb3gir75kkooyea.sms_application_nc_id_seq'::regclass);


--
-- Name: sms_application_template nc_id; Type: DEFAULT; Schema: pb3gir75kkooyea; Owner: admin
--

ALTER TABLE ONLY pb3gir75kkooyea.sms_application_template ALTER COLUMN nc_id SET DEFAULT nextval('pb3gir75kkooyea.sms_application_template_nc_id_seq'::regclass);


--
-- Name: sms_channel nc_id; Type: DEFAULT; Schema: pb3gir75kkooyea; Owner: admin
--

ALTER TABLE ONLY pb3gir75kkooyea.sms_channel ALTER COLUMN nc_id SET DEFAULT nextval('pb3gir75kkooyea.sms_channel_nc_id_seq'::regclass);


--
-- Name: sms_send_attempt nc_id; Type: DEFAULT; Schema: pb3gir75kkooyea; Owner: admin
--

ALTER TABLE ONLY pb3gir75kkooyea.sms_send_attempt ALTER COLUMN nc_id SET DEFAULT nextval('pb3gir75kkooyea.sms_send_attempt_nc_id_seq'::regclass);


--
-- Name: sms_send_record nc_id; Type: DEFAULT; Schema: pb3gir75kkooyea; Owner: admin
--

ALTER TABLE ONLY pb3gir75kkooyea.sms_send_record ALTER COLUMN nc_id SET DEFAULT nextval('pb3gir75kkooyea.sms_send_record_nc_id_seq'::regclass);


--
-- Name: sms_template nc_id; Type: DEFAULT; Schema: pb3gir75kkooyea; Owner: admin
--

ALTER TABLE ONLY pb3gir75kkooyea.sms_template ALTER COLUMN nc_id SET DEFAULT nextval('pb3gir75kkooyea.sms_template_nc_id_seq'::regclass);


--
-- Name: sso_config nc_id; Type: DEFAULT; Schema: pb3gir75kkooyea; Owner: admin
--

ALTER TABLE ONLY pb3gir75kkooyea.sso_config ALTER COLUMN nc_id SET DEFAULT nextval('pb3gir75kkooyea.sso_config_nc_id_seq'::regclass);


--
-- Name: system_config nc_id; Type: DEFAULT; Schema: pb3gir75kkooyea; Owner: admin
--

ALTER TABLE ONLY pb3gir75kkooyea.system_config ALTER COLUMN nc_id SET DEFAULT nextval('pb3gir75kkooyea.system_config_nc_id_seq'::regclass);


--
-- Name: todo_item nc_id; Type: DEFAULT; Schema: pb3gir75kkooyea; Owner: admin
--

ALTER TABLE ONLY pb3gir75kkooyea.todo_item ALTER COLUMN nc_id SET DEFAULT nextval('pb3gir75kkooyea.todo_item_nc_id_seq'::regclass);


--
-- Name: unified_user nc_id; Type: DEFAULT; Schema: pb3gir75kkooyea; Owner: admin
--

ALTER TABLE ONLY pb3gir75kkooyea.unified_user ALTER COLUMN nc_id SET DEFAULT nextval('pb3gir75kkooyea.unified_user_nc_id_seq'::regclass);


--
-- Data for Name: account_opening_request; Type: TABLE DATA; Schema: pb3gir75kkooyea; Owner: admin
--

COPY pb3gir75kkooyea.account_opening_request (id, runtime_id, created_at, updated_at, version, request_no, user_id, application_id, reason, contact, remark, status, submitted_at, handled_by, handled_at, handle_note) FROM stdin;
P4FIX_OPEN_PENDING	MOCK_OPEN_PENDING	2026-09-17 12:00:00+00	2026-09-17 12:00:00+00	1	OPEN-20260917-00001	P4FIX_USER_1	P4FIX_APP_6	首次使用该业务系统，申请开通子系统账号	门户内联系	请按统一身份信息创建账号	PENDING	2026-09-17 12:00:00+00	\N	\N	\N
P4FIX_OPEN_PROCESSING	MOCK_OPEN_PROCESSING	2026-09-17 02:00:00+00	2026-09-17 16:00:00+00	1	OPEN-20260917-00002	P4FIX_USER_2	P4FIX_APP_6	业务经办需要使用该系统，申请开通账号	卫生健康业务处	已有政务身份，请核对后开通	PROCESSING	2026-09-17 02:00:00+00	P4FIX_ADMIN	\N	已转目标子系统管理员处理
P4FIX_OPEN_COMPLETED	MOCK_OPEN_COMPLETED	2026-09-16 10:00:00+00	2026-09-17 20:00:00+00	1	OPEN-20260916-00001	P4FIX_EDITOR	P4FIX_APP_6	信息发布工作需要使用目标系统	门户运行保障中心		COMPLETED	2026-09-16 10:00:00+00	P4FIX_ADMIN	2026-09-17 20:00:00+00	子系统账号已开通，可返回应用中心完成账号关联
\.


--
-- Data for Name: announcement; Type: TABLE DATA; Schema: pb3gir75kkooyea; Owner: admin
--

COPY pb3gir75kkooyea.announcement (nc_id, created_at1, updated_at1, created_by, updated_by, nc_order, id, created_at, updated_at, version, title, announcement_type, content, scope, status, effective_start, effective_end, publisher_id, published_at, runtime_id, publish_mode, scheduled_publish_at, submitted_at, submitted_by, withdrawn_at, withdrawn_by, withdrawn_reason, last_edited_at, last_edited_by, deleted_at, deleted_by, delete_reason) FROM stdin;
5	\N	\N	\N	\N	\N	P4FIX_ANN_5	2026-09-18 00:00:00+00	2026-09-18 00:00:00+00	1	运行保障值班安排	通知	请核对值班分工，及时记录运行问题与处理情况。	ORG	DRAFT	\N	\N	\N	\N	MOCK_ANN_5	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
6	\N	\N	\N	\N	\N	P4FIX_ANN_6	2026-09-18 00:00:00+00	2026-09-18 00:00:00+00	1	信息发布审核工作安排	通知	发布前须核对内容、发布范围与有效期。	ORG	DRAFT	\N	\N	\N	\N	MOCK_ANN_6	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
7	\N	\N	\N	\N	\N	P4FIX_ANN_7	2026-09-18 00:00:00+00	2026-09-18 00:00:00+00	1	原维护时段安排撤回通知	通知	原维护时段安排已撤回，后续安排另行通知。	ALL	WITHDRAWN	2026-09-16 18:00:00+00	\N	P4FIX_EDITOR	2026-09-16 18:00:00+00	MOCK_ANN_7	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
8	\N	\N	\N	\N	\N	P4FIX_ANN_8	2026-09-18 00:00:00+00	2026-09-18 00:00:00+00	1	个人信息保护提示	提示	请妥善保管账号，勿向他人提供验证码或身份核验资料。	ALL	PUBLISHED	2026-09-16 17:00:00+00	\N	P4FIX_EDITOR	2026-09-16 17:00:00+00	MOCK_ANN_8	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
10	\N	\N	\N	\N	\N	P4FIX_e734e220-0e95-4b44-b923-8e1b3cc8cb51	2026-09-18 14:50:12.746+00	2026-09-18 14:50:12.746+00	1	P4验收草稿删除	通知	仅用于本次新增删除验收	ALL	DRAFT	\N	\N	\N	\N	MOCK_e734e220-0e95-4b44-b923-8e1b3cc8cb51	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-09-18 14:50:13.407+00	P4FIX_ADMIN	DRAFT_DELETE
1	\N	\N	\N	\N	\N	P4FIX_ANN_1	2026-09-18 00:00:00+00	2026-09-18 00:00:00+00	1	关于门户服务使用安排的通知	通知	请通过应用中心查看服务入口，业务办理要求以来源系统说明为准。	ALL	PUBLISHED	2026-09-17 00:00:00+00	\N	P4FIX_EDITOR	2026-09-17 00:00:00+00	MOCK_ANN_1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
2	\N	\N	\N	\N	\N	P4FIX_ANN_2	2026-09-18 00:00:00+00	2026-09-18 00:00:00+00	1	关于完善应用接入资料的通知	通知	请整理应用目录、责任分工与接口字段，提交接入资料核验。	GOV	DRAFT	\N	\N	\N	\N	MOCK_ANN_2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
3	\N	\N	\N	\N	\N	P4FIX_ANN_3	2026-09-18 00:00:00+00	2026-09-18 00:00:00+00	1	公众服务事项办理指引	通知	请在办事前核对材料清单，关注待办与消息中的办理要求。	CITIZEN	PUBLISHED	2026-09-16 22:00:00+00	\N	P4FIX_EDITOR	2026-09-16 22:00:00+00	MOCK_ANN_3	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
4	\N	\N	\N	\N	\N	P4FIX_ANN_4	2026-09-18 00:00:00+00	2026-09-18 00:00:00+00	1	卫生健康统计报送安排	通知	请核对本期统计报表，并在规定期限内完成报送。	GOV	PUBLISHED	2026-09-16 21:00:00+00	\N	P4FIX_EDITOR	2026-09-16 21:00:00+00	MOCK_ANN_4	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
\.


--
-- Data for Name: announcement_attachment; Type: TABLE DATA; Schema: pb3gir75kkooyea; Owner: admin
--

COPY pb3gir75kkooyea.announcement_attachment (nc_id, created_at1, updated_at1, created_by, updated_by, nc_order, id, created_at, updated_at, version, announcement_id, file_name, size_bytes, mime_type, attachment, uploaded_by, sort_order, runtime_id) FROM stdin;
\.


--
-- Data for Name: announcement_org_scope; Type: TABLE DATA; Schema: pb3gir75kkooyea; Owner: admin
--

COPY pb3gir75kkooyea.announcement_org_scope (nc_id, created_at1, updated_at1, created_by, updated_by, nc_order, id, created_at, updated_at, version, announcement_id, identity_source_code, org_key) FROM stdin;
1	\N	\N	\N	\N	\N	P4FIX_ORG_MOCK_ANN_5	2026-09-18 00:00:00+00	2026-09-18 00:00:00+00	1	P4FIX_ANN_5	P4FIX_SOURCE_GOV	P4FIX_PORTAL
2	\N	\N	\N	\N	\N	P4FIX_ORG_MOCK_ANN_6	2026-09-18 00:00:00+00	2026-09-18 00:00:00+00	1	P4FIX_ANN_6	P4FIX_SOURCE_GOV	P4FIX_PORTAL
\.


--
-- Data for Name: announcement_read_receipt; Type: TABLE DATA; Schema: pb3gir75kkooyea; Owner: admin
--

COPY pb3gir75kkooyea.announcement_read_receipt (id, created_at, updated_at, version, announcement_id, user_id, read_at) FROM stdin;
P4FIX_ANN_READ_f0cc24f0c40bf50668f0a4c6ad55d9ed077f538eeccef6cc9a29e0992f2a04b8	2026-09-18 14:49:12.945+00	2026-09-18 14:49:12.945+00	1	P4FIX_ANN_1	P4FIX_USER_1	2026-09-18 14:49:12.945+00
P4FIX_ANN_READ_2e2c2447d12fabdc368bd98ce5afcbeaf355fecbb9880b7db0d51cf66816b409	2026-09-18 14:49:28.247+00	2026-09-18 14:49:28.247+00	1	P4FIX_ANN_3	P4FIX_USER_1	2026-09-18 14:49:28.247+00
P4FIX_ANN_READ_d7b6d60bcf14c5873bedb7bc80f1a32817070dafdd5a9bac136727d0d97a57dd	2026-09-18 16:13:46.074+00	2026-09-18 16:13:46.074+00	1	P4FIX_ANN_1	P4FIX_ADMIN	2026-09-18 16:13:46.074+00
P4FIX_ANN_READ_97e7d3cfd8dc474dd73b914bda3d3aec4541dde8bef1567658f4f20651b9e6f3	2026-09-19 11:16:53.826+00	2026-09-19 11:16:53.826+00	1	P4FIX_ANN_8	P4FIX_ADMIN	2026-09-19 11:16:53.826+00
P4FIX_ANN_READ_c1562dbe33f50fc55b436d0adb8ca063e56fa2548fcb934374168082f5cc7528	2026-09-19 12:56:57.465+00	2026-09-19 12:56:57.465+00	1	P4FIX_ANN_4	P4FIX_ADMIN	2026-09-19 12:56:57.465+00
P4FIX_ANN_READ_e5fe125e7299a8a6a1dd824e78f1fde8b17c8b4398be4ed34f079c5b99435d01	2026-09-20 06:58:39.092+00	2026-09-20 06:58:39.092+00	1	P4FIX_ANN_1	P4FIX_EDITOR	2026-09-20 06:58:39.092+00
\.


--
-- Data for Name: application; Type: TABLE DATA; Schema: pb3gir75kkooyea; Owner: admin
--

COPY pb3gir75kkooyea.application (nc_id, created_at1, updated_at1, created_by, updated_by, nc_order, id, created_at, updated_at, version, code, name, category_id, network_zone, user_type, application_url, logo_url, description, contact_name, technical_contact, sort_order, status, runtime_status, allowed_origins, binding_methods, runtime_id, runtime_payload, deleted_at) FROM stdin;
3	\N	\N	\N	\N	\N	P4FIX_APP_2	2026-09-18 00:00:00+00	2026-09-17 23:00:00+00	1	P4FIX_WJ_APP_02	福建省妇幼卫生信息系统	P4FIX_CAT_1	政务外网(卫健专网)	BOTH	https://p4.invalid/app/2	\N	汇集妇女儿童保健记录，支持孕产期管理及妇幼统计。	\N	\N	2	ENABLED	UNCONFIGURED	[]	["SELF","ADMIN"]	MOCK_APP_2	{"id": "MOCK_APP_2", "url": "https://p4.invalid/app/2", "code": "WJ_APP_02", "name": "福建省妇幼卫生信息系统", "status": "ENABLED", "version": 1, "category": "公众服务", "sourceNo": 2, "userType": "BOTH", "createdAt": "2026-09-16T00:00:00.000Z", "sortOrder": 2, "updatedAt": "2026-09-17T23:00:00.000Z", "accessMode": "BIND", "categoryId": "MOCK_CAT_1", "platformId": "MOCK_PLATFORM_1", "platformNo": 1, "description": "汇集妇女儿童保健记录，支持孕产期管理及妇幼统计。", "networkZone": "政务外网(卫健专网)", "mockScenario": "AUTO_BIND", "platformName": "福建省全民健康信息平台", "postGrantMode": "DIRECT", "runtimeStatus": "NORMAL", "integrationNote": "服务地址与接入参数待配置", "connectionStatus": "UNCONFIGURED", "accountBindingMode": "AUTO", "accountOpeningMode": "NONE"}	\N
4	\N	\N	\N	\N	\N	P4FIX_APP_3	2026-09-18 00:00:00+00	2026-09-17 23:00:00+00	1	P4FIX_WJ_APP_03	福建省产前筛查与诊断管理系统	P4FIX_CAT_2	政务外网(卫健专网)	BOTH	https://p4.invalid/app/3	\N	管理产前筛查、风险评估、诊断转介与随访。	\N	\N	3	ENABLED	UNCONFIGURED	[]	["SELF","ADMIN"]	MOCK_APP_3	{"id": "MOCK_APP_3", "url": "https://p4.invalid/app/3", "code": "WJ_APP_03", "name": "福建省产前筛查与诊断管理系统", "status": "ENABLED", "version": 1, "category": "政务协同", "sourceNo": 3, "userType": "BOTH", "createdAt": "2026-09-16T00:00:00.000Z", "sortOrder": 3, "updatedAt": "2026-09-17T23:00:00.000Z", "accessMode": "BIND", "categoryId": "MOCK_CAT_2", "platformId": "MOCK_PLATFORM_1", "platformNo": 1, "description": "管理产前筛查、风险评估、诊断转介与随访。", "networkZone": "政务外网(卫健专网)", "mockScenario": "OTP_BIND", "platformName": "福建省全民健康信息平台", "postGrantMode": "DIRECT", "runtimeStatus": "NORMAL", "integrationNote": "服务地址与接入参数待配置", "connectionStatus": "UNCONFIGURED", "accountBindingMode": "SELF", "accountOpeningMode": "NONE"}	\N
5	\N	\N	\N	\N	\N	P4FIX_APP_4	2026-09-18 00:00:00+00	2026-09-17 23:00:00+00	1	P4FIX_WJ_APP_04	福建省地中海贫血信息管理系统	P4FIX_CAT_2	政务外网(卫健专网)	BOTH	https://p4.invalid/app/4	\N	管理地中海贫血筛查、检测结果与遗传咨询。	\N	\N	4	ENABLED	UNCONFIGURED	[]	["SELF","ADMIN"]	MOCK_APP_4	{"id": "MOCK_APP_4", "url": "https://p4.invalid/app/4", "code": "WJ_APP_04", "name": "福建省地中海贫血信息管理系统", "status": "ENABLED", "version": 1, "category": "政务协同", "sourceNo": 4, "userType": "BOTH", "createdAt": "2026-09-16T00:00:00.000Z", "sortOrder": 4, "updatedAt": "2026-09-17T23:00:00.000Z", "accessMode": "BIND", "categoryId": "MOCK_CAT_2", "platformId": "MOCK_PLATFORM_1", "platformNo": 1, "description": "管理地中海贫血筛查、检测结果与遗传咨询。", "networkZone": "政务外网(卫健专网)", "mockScenario": "CREDENTIAL_BIND", "platformName": "福建省全民健康信息平台", "postGrantMode": "DIRECT", "runtimeStatus": "NORMAL", "integrationNote": "服务地址与接入参数待配置", "connectionStatus": "UNCONFIGURED", "accountBindingMode": "SELF", "accountOpeningMode": "NONE"}	\N
6	\N	\N	\N	\N	\N	P4FIX_APP_5	2026-09-18 00:00:00+00	2026-09-17 23:00:00+00	1	P4FIX_WJ_APP_05	福建省慢病报告与管理系统	P4FIX_CAT_2	政务外网(卫健专网)	BOTH	https://p4.invalid/app/5	\N	汇总慢性病报告，支持病例核查与随访管理。	\N	\N	5	ENABLED	UNCONFIGURED	[]	["SELF","ADMIN"]	MOCK_APP_5	{"id": "MOCK_APP_5", "url": "https://p4.invalid/app/5", "code": "WJ_APP_05", "name": "福建省慢病报告与管理系统", "status": "ENABLED", "version": 1, "category": "政务协同", "sourceNo": 5, "userType": "BOTH", "createdAt": "2026-09-16T00:00:00.000Z", "sortOrder": 5, "updatedAt": "2026-09-17T23:00:00.000Z", "accessMode": "BIND", "categoryId": "MOCK_CAT_2", "platformId": "MOCK_PLATFORM_1", "platformNo": 1, "description": "汇总慢性病报告，支持病例核查与随访管理。", "networkZone": "政务外网(卫健专网)", "mockScenario": "REVIEW_BIND", "platformName": "福建省全民健康信息平台", "postGrantMode": "DIRECT", "runtimeStatus": "NORMAL", "integrationNote": "服务地址与接入参数待配置", "connectionStatus": "UNCONFIGURED", "accountBindingMode": "REVIEW", "accountOpeningMode": "NONE"}	\N
7	\N	\N	\N	\N	\N	P4FIX_APP_6	2026-09-18 00:00:00+00	2026-09-17 23:00:00+00	1	P4FIX_WJ_APP_06	福建省区域影像平台	P4FIX_CAT_2	政务外网(卫健专网)	BOTH	https://p4.invalid/app/6	\N	汇集区域医学影像，支持影像调阅与诊疗协作。	\N	\N	6	ENABLED	UNCONFIGURED	[]	["SELF","ADMIN"]	MOCK_APP_6	{"id": "MOCK_APP_6", "url": "https://p4.invalid/app/6", "code": "WJ_APP_06", "name": "福建省区域影像平台", "status": "ENABLED", "version": 1, "category": "政务协同", "sourceNo": 6, "userType": "BOTH", "createdAt": "2026-09-16T00:00:00.000Z", "sortOrder": 6, "updatedAt": "2026-09-17T23:00:00.000Z", "accessMode": "BIND", "categoryId": "MOCK_CAT_2", "platformId": "MOCK_PLATFORM_1", "platformNo": 1, "description": "汇集区域医学影像，支持影像调阅与诊疗协作。", "networkZone": "政务外网(卫健专网)", "mockScenario": "NO_ACCOUNT", "platformName": "福建省全民健康信息平台", "postGrantMode": "DIRECT", "runtimeStatus": "NORMAL", "integrationNote": "服务地址与接入参数待配置", "connectionStatus": "UNCONFIGURED", "accountBindingMode": "SELF", "accountOpeningMode": "REQUEST"}	\N
2	\N	\N	\N	\N	\N	P4FIX_APP_1	2026-09-18 00:00:00+00	2026-09-17 23:00:00+00	1	P4FIX_WJ_APP_01	福建省新生儿疾病筛查管理系统	P4FIX_CAT_1	政务外网(卫健专网)	BOTH	https://p4.invalid/app/1	\N	管理新生儿筛查登记、结果反馈、阳性召回与随访。	\N	\N	1	ENABLED	UNCONFIGURED	[]	["SELF","ADMIN"]	MOCK_APP_1	{"id": "MOCK_APP_1", "url": "https://p4.invalid/app/1", "code": "WJ_APP_01", "name": "福建省新生儿疾病筛查管理系统", "status": "ENABLED", "version": 1, "category": "公众服务", "sourceNo": 1, "userType": "BOTH", "createdAt": "2026-09-16T00:00:00.000Z", "sortOrder": 1, "updatedAt": "2026-09-17T23:00:00.000Z", "accessMode": "DIRECT", "categoryId": "MOCK_CAT_1", "platformId": "MOCK_PLATFORM_1", "platformNo": 1, "description": "管理新生儿筛查登记、结果反馈、阳性召回与随访。", "networkZone": "政务外网(卫健专网)", "mockScenario": "DIRECT", "platformName": "福建省全民健康信息平台", "postGrantMode": "DIRECT", "runtimeStatus": "NORMAL", "integrationNote": "服务地址与接入参数待配置", "connectionStatus": "UNCONFIGURED", "accountBindingMode": "ADMIN", "accountOpeningMode": "NONE"}	\N
8	\N	\N	\N	\N	\N	P4FIX_APP_7	2026-09-18 00:00:00+00	2026-09-17 23:00:00+00	1	P4FIX_WJ_APP_07	质控评分系统	P4FIX_CAT_2	政务外网(卫健专网)	GOV	https://p4.invalid/app/7	\N	管理质量控制指标、评分记录及问题整改。	\N	\N	7	ENABLED	UNCONFIGURED	[]	["SELF","ADMIN"]	MOCK_APP_7	{"id": "MOCK_APP_7", "url": "https://p4.invalid/app/7", "code": "WJ_APP_07", "name": "质控评分系统", "status": "ENABLED", "version": 1, "category": "政务协同", "sourceNo": 7, "userType": "GOV", "createdAt": "2026-09-16T00:00:00.000Z", "sortOrder": 7, "updatedAt": "2026-09-17T23:00:00.000Z", "accessMode": "BIND", "categoryId": "MOCK_CAT_2", "platformId": "MOCK_PLATFORM_1", "platformNo": 1, "description": "管理质量控制指标、评分记录及问题整改。", "networkZone": "政务外网(卫健专网)", "mockScenario": "BOUND_EXISTING", "platformName": "福建省全民健康信息平台", "postGrantMode": "DIRECT", "runtimeStatus": "NORMAL", "integrationNote": "服务地址与接入参数待配置", "connectionStatus": "UNCONFIGURED", "accountBindingMode": "ADMIN", "accountOpeningMode": "NONE"}	\N
9	\N	\N	\N	\N	\N	P4FIX_APP_8	2026-09-18 00:00:00+00	2026-09-17 23:00:00+00	1	P4FIX_WJ_APP_08	省级平台决策支持展示系统	P4FIX_CAT_2	政务外网(卫健专网)	GOV	https://p4.invalid/app/8	\N	汇总卫生健康指标，支持资源配置与管理决策。	\N	\N	8	ENABLED	UNCONFIGURED	[]	["SELF","ADMIN"]	MOCK_APP_8	{"id": "MOCK_APP_8", "url": "https://p4.invalid/app/8", "code": "WJ_APP_08", "name": "省级平台决策支持展示系统", "status": "ENABLED", "version": 1, "category": "政务协同", "sourceNo": 8, "userType": "GOV", "createdAt": "2026-09-16T00:00:00.000Z", "sortOrder": 8, "updatedAt": "2026-09-17T23:00:00.000Z", "accessMode": "BIND", "categoryId": "MOCK_CAT_2", "platformId": "MOCK_PLATFORM_1", "platformNo": 1, "description": "汇总卫生健康指标，支持资源配置与管理决策。", "networkZone": "政务外网(卫健专网)", "mockScenario": "BOUND_EXISTING", "platformName": "福建省全民健康信息平台", "postGrantMode": "DIRECT", "runtimeStatus": "NORMAL", "integrationNote": "服务地址与接入参数待配置", "connectionStatus": "UNCONFIGURED", "accountBindingMode": "ADMIN", "accountOpeningMode": "NONE"}	\N
10	\N	\N	\N	\N	\N	P4FIX_APP_9	2026-09-18 00:00:00+00	2026-09-17 23:00:00+00	1	P4FIX_WJ_APP_09	单点登录系统	P4FIX_CAT_2	政务外网(卫健专网)	GOV	https://p4.invalid/app/9	\N	衔接统一登录与应用访问，管理身份关联和访问审计。	\N	\N	9	ENABLED	UNCONFIGURED	[]	["SELF","ADMIN"]	MOCK_APP_9	{"id": "MOCK_APP_9", "url": "https://p4.invalid/app/9", "code": "WJ_APP_09", "name": "单点登录系统", "status": "ENABLED", "version": 1, "category": "政务协同", "sourceNo": 9, "userType": "GOV", "createdAt": "2026-09-16T00:00:00.000Z", "sortOrder": 9, "updatedAt": "2026-09-17T23:00:00.000Z", "accessMode": "BIND", "categoryId": "MOCK_CAT_2", "platformId": "MOCK_PLATFORM_1", "platformNo": 1, "description": "衔接统一登录与应用访问，管理身份关联和访问审计。", "networkZone": "政务外网(卫健专网)", "mockScenario": "BOUND_EXISTING", "platformName": "福建省全民健康信息平台", "postGrantMode": "DIRECT", "runtimeStatus": "NORMAL", "integrationNote": "服务地址与接入参数待配置", "connectionStatus": "UNCONFIGURED", "accountBindingMode": "ADMIN", "accountOpeningMode": "NONE"}	\N
11	\N	\N	\N	\N	\N	P4FIX_APP_10	2026-09-18 00:00:00+00	2026-09-17 23:00:00+00	1	P4FIX_WJ_APP_10	福建省血液信息联网平台	P4FIX_CAT_2	政务外网	GOV	https://p4.invalid/app/10	\N	汇集采供血信息，支持血液资源协同与质量追溯。	\N	\N	10	ENABLED	UNCONFIGURED	[]	["SELF","ADMIN"]	MOCK_APP_10	{"id": "MOCK_APP_10", "url": "https://p4.invalid/app/10", "code": "WJ_APP_10", "name": "福建省血液信息联网平台", "status": "ENABLED", "version": 1, "category": "政务协同", "sourceNo": 10, "userType": "GOV", "createdAt": "2026-09-16T00:00:00.000Z", "sortOrder": 10, "updatedAt": "2026-09-17T23:00:00.000Z", "accessMode": "BIND", "categoryId": "MOCK_CAT_2", "platformId": "MOCK_PLATFORM_1", "platformNo": 1, "description": "汇集采供血信息，支持血液资源协同与质量追溯。", "networkZone": "政务外网", "mockScenario": "BOUND_EXISTING", "platformName": "福建省全民健康信息平台", "postGrantMode": "DIRECT", "runtimeStatus": "NORMAL", "integrationNote": "服务地址与接入参数待配置", "connectionStatus": "UNCONFIGURED", "accountBindingMode": "ADMIN", "accountOpeningMode": "NONE"}	\N
12	\N	\N	\N	\N	\N	P4FIX_APP_11	2026-09-18 00:00:00+00	2026-09-17 23:00:00+00	1	P4FIX_WJ_APP_11	福建省免疫规划管理信息系统	P4FIX_CAT_2	政务外网(卫健专网)	BOTH	https://p4.invalid/app/11	\N	管理免疫规划接种记录、接种安排与覆盖统计。	\N	\N	11	ENABLED	UNCONFIGURED	[]	["SELF","ADMIN"]	MOCK_APP_11	{"id": "MOCK_APP_11", "url": "https://p4.invalid/app/11", "code": "WJ_APP_11", "name": "福建省免疫规划管理信息系统", "status": "ENABLED", "version": 1, "category": "政务协同", "sourceNo": 11, "userType": "BOTH", "createdAt": "2026-09-16T00:00:00.000Z", "sortOrder": 11, "updatedAt": "2026-09-17T23:00:00.000Z", "accessMode": "BIND", "categoryId": "MOCK_CAT_2", "platformId": "MOCK_PLATFORM_1", "platformNo": 1, "description": "管理免疫规划接种记录、接种安排与覆盖统计。", "networkZone": "政务外网(卫健专网)", "mockScenario": "ACCOUNT_DISABLED", "platformName": "福建省全民健康信息平台", "postGrantMode": "DIRECT", "runtimeStatus": "NORMAL", "integrationNote": "服务地址与接入参数待配置", "connectionStatus": "UNCONFIGURED", "accountBindingMode": "SELF", "accountOpeningMode": "NONE"}	\N
13	\N	\N	\N	\N	\N	P4FIX_APP_12	2026-09-18 00:00:00+00	2026-09-17 23:00:00+00	1	P4FIX_WJ_APP_12	中医馆健康信息系统	P4FIX_CAT_2	政务外网(卫健专网)	BOTH	https://p4.invalid/app/12	\N	管理中医馆服务记录，支持中医诊疗与健康管理协同。	\N	\N	12	ENABLED	UNCONFIGURED	[]	["SELF","ADMIN"]	MOCK_APP_12	{"id": "MOCK_APP_12", "url": "https://p4.invalid/app/12", "code": "WJ_APP_12", "name": "中医馆健康信息系统", "status": "ENABLED", "version": 1, "category": "政务协同", "sourceNo": 12, "userType": "BOTH", "createdAt": "2026-09-16T00:00:00.000Z", "sortOrder": 12, "updatedAt": "2026-09-17T23:00:00.000Z", "accessMode": "BIND", "categoryId": "MOCK_CAT_2", "platformId": "MOCK_PLATFORM_1", "platformNo": 1, "description": "管理中医馆服务记录，支持中医诊疗与健康管理协同。", "networkZone": "政务外网(卫健专网)", "mockScenario": "CONFLICT", "platformName": "福建省全民健康信息平台", "postGrantMode": "DIRECT", "runtimeStatus": "NORMAL", "integrationNote": "服务地址与接入参数待配置", "connectionStatus": "UNCONFIGURED", "accountBindingMode": "SELF", "accountOpeningMode": "NONE"}	\N
14	\N	\N	\N	\N	\N	P4FIX_APP_13	2026-09-18 00:00:00+00	2026-09-17 23:00:00+00	1	P4FIX_WJ_APP_13	福建省肝炎筛查与规范化治疗管理系统	P4FIX_CAT_2	政务外网(卫健专网)	BOTH	https://p4.invalid/app/13	\N	管理肝炎筛查、诊断转介、规范化治疗及随访。	\N	\N	13	ENABLED	UNCONFIGURED	[]	["SELF","ADMIN"]	MOCK_APP_13	{"id": "MOCK_APP_13", "url": "https://p4.invalid/app/13", "code": "WJ_APP_13", "name": "福建省肝炎筛查与规范化治疗管理系统", "status": "ENABLED", "version": 1, "category": "政务协同", "sourceNo": 13, "userType": "BOTH", "createdAt": "2026-09-16T00:00:00.000Z", "sortOrder": 13, "updatedAt": "2026-09-17T23:00:00.000Z", "accessMode": "REQUEST", "categoryId": "MOCK_CAT_2", "platformId": "MOCK_PLATFORM_1", "platformNo": 1, "description": "管理肝炎筛查、诊断转介、规范化治疗及随访。", "networkZone": "政务外网(卫健专网)", "mockScenario": "REQUEST_DIRECT", "platformName": "福建省全民健康信息平台", "postGrantMode": "DIRECT", "runtimeStatus": "NORMAL", "integrationNote": "服务地址与接入参数待配置", "connectionStatus": "UNCONFIGURED", "accountBindingMode": "ADMIN", "accountOpeningMode": "NONE"}	\N
15	\N	\N	\N	\N	\N	P4FIX_APP_14	2026-09-18 00:00:00+00	2026-09-17 23:00:00+00	1	P4FIX_WJ_APP_14	福建省全员人口计划生育服务与管理系统	P4FIX_CAT_2	政务外网(卫健专网)	GOV	https://p4.invalid/app/14	\N	维护人口服务信息，支持计划生育服务登记与核验。	\N	\N	14	ENABLED	UNCONFIGURED	[]	["SELF","ADMIN"]	MOCK_APP_14	{"id": "MOCK_APP_14", "url": "https://p4.invalid/app/14", "code": "WJ_APP_14", "name": "福建省全员人口计划生育服务与管理系统", "status": "ENABLED", "version": 1, "category": "政务协同", "sourceNo": 14, "userType": "GOV", "createdAt": "2026-09-16T00:00:00.000Z", "sortOrder": 14, "updatedAt": "2026-09-17T23:00:00.000Z", "accessMode": "BIND", "categoryId": "MOCK_CAT_2", "platformId": "MOCK_PLATFORM_2", "platformNo": 2, "description": "维护人口服务信息，支持计划生育服务登记与核验。", "networkZone": "政务外网(卫健专网)", "mockScenario": "BOUND_EXISTING", "platformName": "福建省全员人口计划生育服务与管理平台", "postGrantMode": "DIRECT", "runtimeStatus": "NORMAL", "integrationNote": "服务地址与接入参数待配置", "connectionStatus": "UNCONFIGURED", "accountBindingMode": "ADMIN", "accountOpeningMode": "NONE"}	\N
16	\N	\N	\N	\N	\N	P4FIX_APP_15	2026-09-18 00:00:00+00	2026-09-17 23:00:00+00	1	P4FIX_WJ_APP_15	福建省流动人口服务与管理信息系统	P4FIX_CAT_2	政务外网(卫健专网)	GOV	https://p4.invalid/app/15	\N	管理流动人口服务登记及跨区域协作事项。	\N	\N	15	ENABLED	UNCONFIGURED	[]	["SELF","ADMIN"]	MOCK_APP_15	{"id": "MOCK_APP_15", "url": "https://p4.invalid/app/15", "code": "WJ_APP_15", "name": "福建省流动人口服务与管理信息系统", "status": "ENABLED", "version": 1, "category": "政务协同", "sourceNo": 15, "userType": "GOV", "createdAt": "2026-09-16T00:00:00.000Z", "sortOrder": 15, "updatedAt": "2026-09-17T23:00:00.000Z", "accessMode": "BIND", "categoryId": "MOCK_CAT_2", "platformId": "MOCK_PLATFORM_2", "platformNo": 2, "description": "管理流动人口服务登记及跨区域协作事项。", "networkZone": "政务外网(卫健专网)", "mockScenario": "BOUND_EXISTING", "platformName": "福建省全员人口计划生育服务与管理平台", "postGrantMode": "DIRECT", "runtimeStatus": "NORMAL", "integrationNote": "服务地址与接入参数待配置", "connectionStatus": "UNCONFIGURED", "accountBindingMode": "ADMIN", "accountOpeningMode": "NONE"}	\N
17	\N	\N	\N	\N	\N	P4FIX_APP_16	2026-09-18 00:00:00+00	2026-09-17 23:00:00+00	1	P4FIX_WJ_APP_16	福建省人口计生综合服务信息平台	P4FIX_CAT_2	政务外网(卫健专网)	GOV	https://p4.invalid/app/16	\N	汇集人口计生服务事项，支持综合查询与协同。	\N	\N	16	ENABLED	UNCONFIGURED	[]	["SELF","ADMIN"]	MOCK_APP_16	{"id": "MOCK_APP_16", "url": "https://p4.invalid/app/16", "code": "WJ_APP_16", "name": "福建省人口计生综合服务信息平台", "status": "ENABLED", "version": 1, "category": "政务协同", "sourceNo": 16, "userType": "GOV", "createdAt": "2026-09-16T00:00:00.000Z", "sortOrder": 16, "updatedAt": "2026-09-17T23:00:00.000Z", "accessMode": "BIND", "categoryId": "MOCK_CAT_2", "platformId": "MOCK_PLATFORM_2", "platformNo": 2, "description": "汇集人口计生服务事项，支持综合查询与协同。", "networkZone": "政务外网(卫健专网)", "mockScenario": "BOUND_EXISTING", "platformName": "福建省全员人口计划生育服务与管理平台", "postGrantMode": "DIRECT", "runtimeStatus": "NORMAL", "integrationNote": "服务地址与接入参数待配置", "connectionStatus": "UNCONFIGURED", "accountBindingMode": "ADMIN", "accountOpeningMode": "NONE"}	\N
18	\N	\N	\N	\N	\N	P4FIX_APP_17	2026-09-18 00:00:00+00	2026-09-17 23:00:00+00	1	P4FIX_WJ_APP_17	全员人口数据库药具发放服务管理	P4FIX_CAT_2	互联网	BOTH	https://p4.invalid/app/17	\N	管理药具需求、库存、发放登记与服务统计。	\N	\N	17	ENABLED	UNCONFIGURED	[]	["SELF","ADMIN"]	MOCK_APP_17	{"id": "MOCK_APP_17", "url": "https://p4.invalid/app/17", "code": "WJ_APP_17", "name": "全员人口数据库药具发放服务管理", "status": "ENABLED", "version": 1, "category": "政务协同", "sourceNo": 17, "userType": "BOTH", "createdAt": "2026-09-16T00:00:00.000Z", "sortOrder": 17, "updatedAt": "2026-09-17T23:00:00.000Z", "accessMode": "REQUEST", "categoryId": "MOCK_CAT_2", "platformId": "MOCK_PLATFORM_2", "platformNo": 2, "description": "管理药具需求、库存、发放登记与服务统计。", "networkZone": "互联网", "mockScenario": "REQUEST_BIND", "platformName": "福建省全员人口计划生育服务与管理平台", "postGrantMode": "BIND", "runtimeStatus": "NORMAL", "integrationNote": "服务地址与接入参数待配置", "connectionStatus": "UNCONFIGURED", "accountBindingMode": "SELF", "accountOpeningMode": "NONE"}	\N
19	\N	\N	\N	\N	\N	P4FIX_APP_18	2026-09-18 00:00:00+00	2026-09-17 23:00:00+00	1	P4FIX_WJ_APP_18	福建省互联网医院监管平台	P4FIX_CAT_3	政务外网	GOV	https://p4.invalid/app/18	\N	汇集互联网医院信息，支持资质核验与诊疗监管。	\N	\N	18	ENABLED	UNCONFIGURED	[]	["SELF","ADMIN"]	MOCK_APP_18	{"id": "MOCK_APP_18", "url": "https://p4.invalid/app/18", "code": "WJ_APP_18", "name": "福建省互联网医院监管平台", "status": "ENABLED", "version": 1, "category": "行业监管", "sourceNo": 18, "userType": "GOV", "createdAt": "2026-09-16T00:00:00.000Z", "sortOrder": 18, "updatedAt": "2026-09-17T23:00:00.000Z", "accessMode": "BIND", "categoryId": "MOCK_CAT_3", "platformId": "MOCK_PLATFORM_3", "platformNo": 3, "description": "汇集互联网医院信息，支持资质核验与诊疗监管。", "networkZone": "政务外网", "mockScenario": "BOUND_EXISTING", "platformName": "福建省卫健委综合监管平台", "postGrantMode": "DIRECT", "runtimeStatus": "NORMAL", "integrationNote": "服务地址与接入参数待配置", "connectionStatus": "UNCONFIGURED", "accountBindingMode": "ADMIN", "accountOpeningMode": "NONE"}	\N
20	\N	\N	\N	\N	\N	P4FIX_APP_19	2026-09-18 00:00:00+00	2026-09-17 23:00:00+00	1	P4FIX_WJ_APP_19	省医改效果监测管理系统	P4FIX_CAT_3	政务外网(卫健专网)	GOV	https://p4.invalid/app/19	\N	管理医改指标填报、数据核验及改革成效分析。	\N	\N	19	ENABLED	UNCONFIGURED	[]	["SELF","ADMIN"]	MOCK_APP_19	{"id": "MOCK_APP_19", "url": "https://p4.invalid/app/19", "code": "WJ_APP_19", "name": "省医改效果监测管理系统", "status": "ENABLED", "version": 1, "category": "行业监管", "sourceNo": 19, "userType": "GOV", "createdAt": "2026-09-16T00:00:00.000Z", "sortOrder": 19, "updatedAt": "2026-09-17T23:00:00.000Z", "accessMode": "BIND", "categoryId": "MOCK_CAT_3", "platformId": "MOCK_PLATFORM_3", "platformNo": 3, "description": "管理医改指标填报、数据核验及改革成效分析。", "networkZone": "政务外网(卫健专网)", "mockScenario": "BOUND_EXISTING", "platformName": "福建省卫健委综合监管平台", "postGrantMode": "DIRECT", "runtimeStatus": "NORMAL", "integrationNote": "服务地址与接入参数待配置", "connectionStatus": "UNCONFIGURED", "accountBindingMode": "ADMIN", "accountOpeningMode": "NONE"}	\N
21	\N	\N	\N	\N	\N	P4FIX_APP_20	2026-09-18 00:00:00+00	2026-09-17 23:00:00+00	1	P4FIX_WJ_APP_20	省属公立医院运营监管系统	P4FIX_CAT_3	政务外网(卫健专网)	GOV	https://p4.invalid/app/20	\N	汇集医院运营指标，支持运行监测与异常核查。	\N	\N	20	ENABLED	UNCONFIGURED	[]	["SELF","ADMIN"]	MOCK_APP_20	{"id": "MOCK_APP_20", "url": "https://p4.invalid/app/20", "code": "WJ_APP_20", "name": "省属公立医院运营监管系统", "status": "ENABLED", "version": 1, "category": "行业监管", "sourceNo": 20, "userType": "GOV", "createdAt": "2026-09-16T00:00:00.000Z", "sortOrder": 20, "updatedAt": "2026-09-17T23:00:00.000Z", "accessMode": "BIND", "categoryId": "MOCK_CAT_3", "platformId": "MOCK_PLATFORM_3", "platformNo": 3, "description": "汇集医院运营指标，支持运行监测与异常核查。", "networkZone": "政务外网(卫健专网)", "mockScenario": "BOUND_EXISTING", "platformName": "福建省卫健委综合监管平台", "postGrantMode": "DIRECT", "runtimeStatus": "NORMAL", "integrationNote": "服务地址与接入参数待配置", "connectionStatus": "UNCONFIGURED", "accountBindingMode": "ADMIN", "accountOpeningMode": "NONE"}	\N
22	\N	\N	\N	\N	\N	P4FIX_APP_21	2026-09-18 00:00:00+00	2026-09-17 23:00:00+00	1	P4FIX_WJ_APP_21	福建省公立医院绩效考核系统	P4FIX_CAT_3	互联网	GOV	https://p4.invalid/app/21	\N	管理医院绩效填报、考核资料与评价结果。	\N	\N	21	ENABLED	UNCONFIGURED	[]	["SELF","ADMIN"]	MOCK_APP_21	{"id": "MOCK_APP_21", "url": "https://p4.invalid/app/21", "code": "WJ_APP_21", "name": "福建省公立医院绩效考核系统", "status": "ENABLED", "version": 1, "category": "行业监管", "sourceNo": 21, "userType": "GOV", "createdAt": "2026-09-16T00:00:00.000Z", "sortOrder": 21, "updatedAt": "2026-09-17T23:00:00.000Z", "accessMode": "BIND", "categoryId": "MOCK_CAT_3", "platformId": "MOCK_PLATFORM_3", "platformNo": 3, "description": "管理医院绩效填报、考核资料与评价结果。", "networkZone": "互联网", "mockScenario": "BOUND_EXISTING", "platformName": "福建省卫健委综合监管平台", "postGrantMode": "DIRECT", "runtimeStatus": "NORMAL", "integrationNote": "服务地址与接入参数待配置", "connectionStatus": "UNCONFIGURED", "accountBindingMode": "ADMIN", "accountOpeningMode": "NONE"}	\N
23	\N	\N	\N	\N	\N	P4FIX_APP_22	2026-09-18 00:00:00+00	2026-09-17 23:00:00+00	1	P4FIX_WJ_APP_22	财务管理系统	P4FIX_CAT_3	政务外网	GOV	https://p4.invalid/app/22	\N	管理财务报表、预算执行信息与收支核对。	\N	\N	22	ENABLED	UNCONFIGURED	[]	["SELF","ADMIN"]	MOCK_APP_22	{"id": "MOCK_APP_22", "url": "https://p4.invalid/app/22", "code": "WJ_APP_22", "name": "财务管理系统", "status": "ENABLED", "version": 1, "category": "行业监管", "sourceNo": 22, "userType": "GOV", "createdAt": "2026-09-16T00:00:00.000Z", "sortOrder": 22, "updatedAt": "2026-09-17T23:00:00.000Z", "accessMode": "BIND", "categoryId": "MOCK_CAT_3", "platformId": "MOCK_PLATFORM_3", "platformNo": 3, "description": "管理财务报表、预算执行信息与收支核对。", "networkZone": "政务外网", "mockScenario": "BOUND_EXISTING", "platformName": "福建省卫健委综合监管平台", "postGrantMode": "DIRECT", "runtimeStatus": "NORMAL", "integrationNote": "服务地址与接入参数待配置", "connectionStatus": "UNCONFIGURED", "accountBindingMode": "ADMIN", "accountOpeningMode": "NONE"}	\N
24	\N	\N	\N	\N	\N	P4FIX_APP_23	2026-09-18 00:00:00+00	2026-09-17 23:00:00+00	1	P4FIX_WJ_APP_23	医疗技术临床应用管理信息系统	P4FIX_CAT_3	政务外网(卫健专网)	GOV	https://p4.invalid/app/23	\N	管理医疗技术应用备案、质量信息与规范执行情况。	\N	\N	23	ENABLED	UNCONFIGURED	[]	["SELF","ADMIN"]	MOCK_APP_23	{"id": "MOCK_APP_23", "url": "https://p4.invalid/app/23", "code": "WJ_APP_23", "name": "医疗技术临床应用管理信息系统", "status": "ENABLED", "version": 1, "category": "行业监管", "sourceNo": 23, "userType": "GOV", "createdAt": "2026-09-16T00:00:00.000Z", "sortOrder": 23, "updatedAt": "2026-09-17T23:00:00.000Z", "accessMode": "BIND", "categoryId": "MOCK_CAT_3", "platformId": "MOCK_PLATFORM_3", "platformNo": 3, "description": "管理医疗技术应用备案、质量信息与规范执行情况。", "networkZone": "政务外网(卫健专网)", "mockScenario": "BOUND_EXISTING", "platformName": "福建省卫健委综合监管平台", "postGrantMode": "DIRECT", "runtimeStatus": "NORMAL", "integrationNote": "服务地址与接入参数待配置", "connectionStatus": "UNCONFIGURED", "accountBindingMode": "ADMIN", "accountOpeningMode": "NONE"}	\N
25	\N	\N	\N	\N	\N	P4FIX_APP_24	2026-09-18 00:00:00+00	2026-09-17 23:00:00+00	1	P4FIX_WJ_APP_24	住院医师专科医师培训及一体化系统	P4FIX_CAT_4	互联网	BOTH	https://p4.invalid/app/24	\N	管理医师培训报名、轮转安排与考核记录。	\N	\N	24	ENABLED	UNCONFIGURED	[]	["SELF","ADMIN"]	MOCK_APP_24	{"id": "MOCK_APP_24", "url": "https://p4.invalid/app/24", "code": "WJ_APP_24", "name": "住院医师专科医师培训及一体化系统", "status": "ENABLED", "version": 1, "category": "培训考试", "sourceNo": 24, "userType": "BOTH", "createdAt": "2026-09-16T00:00:00.000Z", "sortOrder": 24, "updatedAt": "2026-09-17T23:00:00.000Z", "accessMode": "BIND", "categoryId": "MOCK_CAT_4", "platformId": "MOCK_PLATFORM_3", "platformNo": 3, "description": "管理医师培训报名、轮转安排与考核记录。", "networkZone": "互联网", "mockScenario": "BOUND_EXISTING", "platformName": "福建省卫健委综合监管平台", "postGrantMode": "DIRECT", "runtimeStatus": "NORMAL", "integrationNote": "服务地址与接入参数待配置", "connectionStatus": "UNCONFIGURED", "accountBindingMode": "ADMIN", "accountOpeningMode": "NONE"}	\N
26	\N	\N	\N	\N	\N	P4FIX_APP_25	2026-09-18 00:00:00+00	2026-09-17 23:00:00+00	1	P4FIX_WJ_APP_25	福建省中医医师规范化培训管理平台	P4FIX_CAT_4	互联网	BOTH	https://p4.invalid/app/25	\N	管理中医医师培训计划、过程记录及结业考核。	\N	\N	25	ENABLED	UNCONFIGURED	[]	["SELF","ADMIN"]	MOCK_APP_25	{"id": "MOCK_APP_25", "url": "https://p4.invalid/app/25", "code": "WJ_APP_25", "name": "福建省中医医师规范化培训管理平台", "status": "ENABLED", "version": 1, "category": "培训考试", "sourceNo": 25, "userType": "BOTH", "createdAt": "2026-09-16T00:00:00.000Z", "sortOrder": 25, "updatedAt": "2026-09-17T23:00:00.000Z", "accessMode": "BIND", "categoryId": "MOCK_CAT_4", "platformId": "MOCK_PLATFORM_3", "platformNo": 3, "description": "管理中医医师培训计划、过程记录及结业考核。", "networkZone": "互联网", "mockScenario": "BOUND_EXISTING", "platformName": "福建省卫健委综合监管平台", "postGrantMode": "DIRECT", "runtimeStatus": "NORMAL", "integrationNote": "服务地址与接入参数待配置", "connectionStatus": "UNCONFIGURED", "accountBindingMode": "ADMIN", "accountOpeningMode": "NONE"}	\N
27	\N	\N	\N	\N	\N	P4FIX_APP_26	2026-09-18 00:00:00+00	2026-09-17 23:00:00+00	1	P4FIX_WJ_APP_26	福建省中医医术确有专长人员医师资格考核报名系统	P4FIX_CAT_4	互联网	BOTH	https://p4.invalid/app/26	\N	管理中医专长医师考核报名、材料补正与资格审核。	\N	\N	26	ENABLED	UNCONFIGURED	[]	["SELF","ADMIN"]	MOCK_APP_26	{"id": "MOCK_APP_26", "url": "https://p4.invalid/app/26", "code": "WJ_APP_26", "name": "福建省中医医术确有专长人员医师资格考核报名系统", "status": "ENABLED", "version": 1, "category": "培训考试", "sourceNo": 26, "userType": "BOTH", "createdAt": "2026-09-16T00:00:00.000Z", "sortOrder": 26, "updatedAt": "2026-09-17T23:00:00.000Z", "accessMode": "BIND", "categoryId": "MOCK_CAT_4", "platformId": "MOCK_PLATFORM_3", "platformNo": 3, "description": "管理中医专长医师考核报名、材料补正与资格审核。", "networkZone": "互联网", "mockScenario": "BOUND_EXISTING", "platformName": "福建省卫健委综合监管平台", "postGrantMode": "DIRECT", "runtimeStatus": "NORMAL", "integrationNote": "服务地址与接入参数待配置", "connectionStatus": "UNCONFIGURED", "accountBindingMode": "ADMIN", "accountOpeningMode": "NONE"}	\N
28	\N	\N	\N	\N	\N	P4FIX_APP_27	2026-09-18 00:00:00+00	2026-09-17 23:00:00+00	1	P4FIX_WJ_APP_27	福建省卫生健康科技计划项目管理信息系统	P4FIX_CAT_4	政务外网互联网区	GOV	https://p4.invalid/app/27	\N	管理科技项目申报、评审、过程检查及验收。	\N	\N	27	ENABLED	UNCONFIGURED	[]	["SELF","ADMIN"]	MOCK_APP_27	{"id": "MOCK_APP_27", "url": "https://p4.invalid/app/27", "code": "WJ_APP_27", "name": "福建省卫生健康科技计划项目管理信息系统", "status": "ENABLED", "version": 1, "category": "培训考试", "sourceNo": 27, "userType": "GOV", "createdAt": "2026-09-16T00:00:00.000Z", "sortOrder": 27, "updatedAt": "2026-09-17T23:00:00.000Z", "accessMode": "BIND", "categoryId": "MOCK_CAT_4", "platformId": "MOCK_PLATFORM_3", "platformNo": 3, "description": "管理科技项目申报、评审、过程检查及验收。", "networkZone": "政务外网互联网区", "mockScenario": "BOUND_EXISTING", "platformName": "福建省卫健委综合监管平台", "postGrantMode": "DIRECT", "runtimeStatus": "NORMAL", "integrationNote": "服务地址与接入参数待配置", "connectionStatus": "UNCONFIGURED", "accountBindingMode": "ADMIN", "accountOpeningMode": "NONE"}	\N
29	\N	\N	\N	\N	\N	P4FIX_APP_28	2026-09-18 00:00:00+00	2026-09-17 23:00:00+00	1	P4FIX_WJ_APP_28	福建省卫生专业技术资格考试报名系统	P4FIX_CAT_4	互联网	BOTH	https://p4.invalid/app/28	\N	管理卫生资格考试报名、资料核验及通知。	\N	\N	28	ENABLED	UNCONFIGURED	[]	["SELF","ADMIN"]	MOCK_APP_28	{"id": "MOCK_APP_28", "url": "https://p4.invalid/app/28", "code": "WJ_APP_28", "name": "福建省卫生专业技术资格考试报名系统", "status": "ENABLED", "version": 1, "category": "培训考试", "sourceNo": 28, "userType": "BOTH", "createdAt": "2026-09-16T00:00:00.000Z", "sortOrder": 28, "updatedAt": "2026-09-17T23:00:00.000Z", "accessMode": "BIND", "categoryId": "MOCK_CAT_4", "platformId": "MOCK_PLATFORM_3", "platformNo": 3, "description": "管理卫生资格考试报名、资料核验及通知。", "networkZone": "互联网", "mockScenario": "BOUND_EXISTING", "platformName": "福建省卫健委综合监管平台", "postGrantMode": "DIRECT", "runtimeStatus": "NORMAL", "integrationNote": "服务地址与接入参数待配置", "connectionStatus": "UNCONFIGURED", "accountBindingMode": "ADMIN", "accountOpeningMode": "NONE"}	\N
30	\N	\N	\N	\N	\N	P4FIX_APP_29	2026-09-18 00:00:00+00	2026-09-17 23:00:00+00	1	P4FIX_WJ_APP_29	国家卫生健康信息统计直报系统	P4FIX_CAT_3	互联网	GOV	https://p4.invalid/app/29	\N	支持卫生统计报表填报、审核、汇总与直报。	\N	\N	29	ENABLED	UNCONFIGURED	[]	["SELF","ADMIN"]	MOCK_APP_29	{"id": "MOCK_APP_29", "url": "https://p4.invalid/app/29", "code": "WJ_APP_29", "name": "国家卫生健康信息统计直报系统", "status": "ENABLED", "version": 1, "category": "行业监管", "sourceNo": 29, "userType": "GOV", "createdAt": "2026-09-16T00:00:00.000Z", "sortOrder": 29, "updatedAt": "2026-09-17T23:00:00.000Z", "accessMode": "BIND", "categoryId": "MOCK_CAT_3", "platformId": "MOCK_PLATFORM_3", "platformNo": 3, "description": "支持卫生统计报表填报、审核、汇总与直报。", "networkZone": "互联网", "mockScenario": "BOUND_EXISTING", "platformName": "福建省卫健委综合监管平台", "postGrantMode": "DIRECT", "runtimeStatus": "NORMAL", "integrationNote": "服务地址与接入参数待配置", "connectionStatus": "UNCONFIGURED", "accountBindingMode": "ADMIN", "accountOpeningMode": "NONE"}	\N
31	\N	\N	\N	\N	\N	P4FIX_APP_30	2026-09-18 00:00:00+00	2026-09-17 23:00:00+00	1	P4FIX_WJ_APP_30	福建省集中消毒餐具追溯系统	P4FIX_CAT_3	政务外网互联网区	GOV	https://p4.invalid/app/30	\N	管理消毒餐具批次、检验信息与流向追溯。	\N	\N	30	ENABLED	UNCONFIGURED	[]	["SELF","ADMIN"]	MOCK_APP_30	{"id": "MOCK_APP_30", "url": "https://p4.invalid/app/30", "code": "WJ_APP_30", "name": "福建省集中消毒餐具追溯系统", "status": "ENABLED", "version": 1, "category": "行业监管", "sourceNo": 30, "userType": "GOV", "createdAt": "2026-09-16T00:00:00.000Z", "sortOrder": 30, "updatedAt": "2026-09-17T23:00:00.000Z", "accessMode": "BIND", "categoryId": "MOCK_CAT_3", "platformId": "MOCK_PLATFORM_3", "platformNo": 3, "description": "管理消毒餐具批次、检验信息与流向追溯。", "networkZone": "政务外网互联网区", "mockScenario": "BOUND_EXISTING", "platformName": "福建省卫健委综合监管平台", "postGrantMode": "DIRECT", "runtimeStatus": "NORMAL", "integrationNote": "服务地址与接入参数待配置", "connectionStatus": "UNCONFIGURED", "accountBindingMode": "ADMIN", "accountOpeningMode": "NONE"}	\N
32	\N	\N	\N	\N	\N	P4FIX_APP_31	2026-09-18 00:00:00+00	2026-09-17 23:00:00+00	1	P4FIX_WJ_APP_31	福建省职业病防治综合管理系统	P4FIX_CAT_3	政务外网互联网区	GOV	https://p4.invalid/app/31	\N	汇集职业病防治信息，支持监测报告与防治协作。	\N	\N	31	ENABLED	UNCONFIGURED	[]	["SELF","ADMIN"]	MOCK_APP_31	{"id": "MOCK_APP_31", "url": "https://p4.invalid/app/31", "code": "WJ_APP_31", "name": "福建省职业病防治综合管理系统", "status": "ENABLED", "version": 1, "category": "行业监管", "sourceNo": 31, "userType": "GOV", "createdAt": "2026-09-16T00:00:00.000Z", "sortOrder": 31, "updatedAt": "2026-09-17T23:00:00.000Z", "accessMode": "BIND", "categoryId": "MOCK_CAT_3", "platformId": "MOCK_PLATFORM_3", "platformNo": 3, "description": "汇集职业病防治信息，支持监测报告与防治协作。", "networkZone": "政务外网互联网区", "mockScenario": "BOUND_EXISTING", "platformName": "福建省卫健委综合监管平台", "postGrantMode": "DIRECT", "runtimeStatus": "NORMAL", "integrationNote": "服务地址与接入参数待配置", "connectionStatus": "UNCONFIGURED", "accountBindingMode": "ADMIN", "accountOpeningMode": "NONE"}	\N
33	\N	\N	\N	\N	\N	P4FIX_APP_32	2026-09-18 00:00:00+00	2026-09-17 23:00:00+00	1	P4FIX_WJ_APP_32	福建省保健对象医疗管理信息系统	P4FIX_CAT_3	政务外网(卫健专网)	GOV	https://p4.invalid/app/32	\N	管理保健服务安排、医疗保障事项及服务记录。	\N	\N	32	ENABLED	UNCONFIGURED	[]	["SELF","ADMIN"]	MOCK_APP_32	{"id": "MOCK_APP_32", "url": "https://p4.invalid/app/32", "code": "WJ_APP_32", "name": "福建省保健对象医疗管理信息系统", "status": "ENABLED", "version": 1, "category": "行业监管", "sourceNo": 32, "userType": "GOV", "createdAt": "2026-09-16T00:00:00.000Z", "sortOrder": 32, "updatedAt": "2026-09-17T23:00:00.000Z", "accessMode": "BIND", "categoryId": "MOCK_CAT_3", "platformId": "MOCK_PLATFORM_4", "platformNo": 4, "description": "管理保健服务安排、医疗保障事项及服务记录。", "networkZone": "政务外网(卫健专网)", "mockScenario": "BOUND_EXISTING", "platformName": "福建省保健对象医疗管理信息系统", "postGrantMode": "DIRECT", "runtimeStatus": "NORMAL", "integrationNote": "服务地址与接入参数待配置", "connectionStatus": "UNCONFIGURED", "accountBindingMode": "ADMIN", "accountOpeningMode": "NONE"}	\N
34	\N	\N	\N	\N	\N	P4FIX_APP_33	2026-09-18 00:00:00+00	2026-09-17 23:00:00+00	1	P4FIX_WJ_APP_33	福建省职业病与化学中毒预防控制中心门户网站	P4FIX_CAT_3	政务外网互联网区	BOTH	https://p4.invalid/app/33	\N	发布职业病及化学中毒防治资讯、办事指引和健康知识。	\N	\N	33	ENABLED	UNCONFIGURED	[]	["SELF","ADMIN"]	MOCK_APP_33	{"id": "MOCK_APP_33", "url": "https://p4.invalid/app/33", "code": "WJ_APP_33", "name": "福建省职业病与化学中毒预防控制中心门户网站", "status": "ENABLED", "version": 1, "category": "行业监管", "sourceNo": 33, "userType": "BOTH", "createdAt": "2026-09-16T00:00:00.000Z", "sortOrder": 33, "updatedAt": "2026-09-17T23:00:00.000Z", "accessMode": "BIND", "categoryId": "MOCK_CAT_3", "platformId": "MOCK_PLATFORM_5", "platformNo": 5, "description": "发布职业病及化学中毒防治资讯、办事指引和健康知识。", "networkZone": "政务外网互联网区", "mockScenario": "BOUND_EXISTING", "platformName": "省职控制中心门户网站", "postGrantMode": "DIRECT", "runtimeStatus": "NORMAL", "integrationNote": "服务地址与接入参数待配置", "connectionStatus": "UNCONFIGURED", "accountBindingMode": "ADMIN", "accountOpeningMode": "NONE"}	\N
35	\N	\N	\N	\N	\N	P4FIX_APP_34	2026-09-18 00:00:00+00	2026-09-17 23:00:00+00	1	P4FIX_WJ_APP_34	福建省卫生监督电子执法全过程记录系统	P4FIX_CAT_5	政务外网公用网络区	GOV	https://p4.invalid/app/34	\N	管理卫生监督执法记录、证据索引与过程留痕。	\N	\N	34	ENABLED	UNCONFIGURED	[]	["SELF","ADMIN"]	MOCK_APP_34	{"id": "MOCK_APP_34", "url": "https://p4.invalid/app/34", "code": "WJ_APP_34", "name": "福建省卫生监督电子执法全过程记录系统", "status": "ENABLED", "version": 1, "category": "卫生监督", "sourceNo": 34, "userType": "GOV", "createdAt": "2026-09-16T00:00:00.000Z", "sortOrder": 34, "updatedAt": "2026-09-17T23:00:00.000Z", "accessMode": "BIND", "categoryId": "MOCK_CAT_5", "platformId": "MOCK_PLATFORM_6", "platformNo": 6, "description": "管理卫生监督执法记录、证据索引与过程留痕。", "networkZone": "政务外网公用网络区", "mockScenario": "BOUND_EXISTING", "platformName": "省卫监所综合管理系统", "postGrantMode": "DIRECT", "runtimeStatus": "NORMAL", "integrationNote": "服务地址与接入参数待配置", "connectionStatus": "UNCONFIGURED", "accountBindingMode": "ADMIN", "accountOpeningMode": "NONE"}	\N
36	\N	\N	\N	\N	\N	P4FIX_APP_35	2026-09-18 00:00:00+00	2026-09-17 23:00:00+00	1	P4FIX_WJ_APP_35	福建省医疗卫生信用信息归集系统	P4FIX_CAT_5	互联网	GOV	https://p4.invalid/app/35	\N	归集医疗卫生信用信息，支持信用核验与监管查询。	\N	\N	35	ENABLED	UNCONFIGURED	[]	["SELF","ADMIN"]	MOCK_APP_35	{"id": "MOCK_APP_35", "url": "https://p4.invalid/app/35", "code": "WJ_APP_35", "name": "福建省医疗卫生信用信息归集系统", "status": "ENABLED", "version": 1, "category": "卫生监督", "sourceNo": 35, "userType": "GOV", "createdAt": "2026-09-16T00:00:00.000Z", "sortOrder": 35, "updatedAt": "2026-09-17T23:00:00.000Z", "accessMode": "BIND", "categoryId": "MOCK_CAT_5", "platformId": "MOCK_PLATFORM_6", "platformNo": 6, "description": "归集医疗卫生信用信息，支持信用核验与监管查询。", "networkZone": "互联网", "mockScenario": "BOUND_EXISTING", "platformName": "省卫监所综合管理系统", "postGrantMode": "DIRECT", "runtimeStatus": "NORMAL", "integrationNote": "服务地址与接入参数待配置", "connectionStatus": "UNCONFIGURED", "accountBindingMode": "ADMIN", "accountOpeningMode": "NONE"}	\N
37	\N	\N	\N	\N	\N	P4FIX_APP_36	2026-09-18 00:00:00+00	2026-09-17 23:00:00+00	1	P4FIX_WJ_APP_36	福建省医疗卫生不良执业记分系统	P4FIX_CAT_5	互联网	GOV	https://p4.invalid/app/36	\N	管理不良执业行为登记、记分与整改记录。	\N	\N	36	ENABLED	UNCONFIGURED	[]	["SELF","ADMIN"]	MOCK_APP_36	{"id": "MOCK_APP_36", "url": "https://p4.invalid/app/36", "code": "WJ_APP_36", "name": "福建省医疗卫生不良执业记分系统", "status": "ENABLED", "version": 1, "category": "卫生监督", "sourceNo": 36, "userType": "GOV", "createdAt": "2026-09-16T00:00:00.000Z", "sortOrder": 36, "updatedAt": "2026-09-17T23:00:00.000Z", "accessMode": "BIND", "categoryId": "MOCK_CAT_5", "platformId": "MOCK_PLATFORM_6", "platformNo": 6, "description": "管理不良执业行为登记、记分与整改记录。", "networkZone": "互联网", "mockScenario": "BOUND_EXISTING", "platformName": "省卫监所综合管理系统", "postGrantMode": "DIRECT", "runtimeStatus": "NORMAL", "integrationNote": "服务地址与接入参数待配置", "connectionStatus": "UNCONFIGURED", "accountBindingMode": "ADMIN", "accountOpeningMode": "NONE"}	\N
38	\N	\N	\N	\N	\N	P4FIX_APP_37	2026-09-18 00:00:00+00	2026-09-17 23:00:00+00	1	P4FIX_WJ_APP_37	福建省诊所诊疗监督系统	P4FIX_CAT_5	互联网	GOV	https://p4.invalid/app/37	\N	汇集诊所诊疗活动，支持合规核查与监督管理。	\N	\N	37	ENABLED	UNCONFIGURED	[]	["SELF","ADMIN"]	MOCK_APP_37	{"id": "MOCK_APP_37", "url": "https://p4.invalid/app/37", "code": "WJ_APP_37", "name": "福建省诊所诊疗监督系统", "status": "ENABLED", "version": 1, "category": "卫生监督", "sourceNo": 37, "userType": "GOV", "createdAt": "2026-09-16T00:00:00.000Z", "sortOrder": 37, "updatedAt": "2026-09-17T23:00:00.000Z", "accessMode": "BIND", "categoryId": "MOCK_CAT_5", "platformId": "MOCK_PLATFORM_6", "platformNo": 6, "description": "汇集诊所诊疗活动，支持合规核查与监督管理。", "networkZone": "互联网", "mockScenario": "BOUND_EXISTING", "platformName": "省卫监所综合管理系统", "postGrantMode": "DIRECT", "runtimeStatus": "NORMAL", "integrationNote": "服务地址与接入参数待配置", "connectionStatus": "UNCONFIGURED", "accountBindingMode": "ADMIN", "accountOpeningMode": "NONE"}	\N
39	\N	\N	\N	\N	\N	P4FIX_APP_38	2026-09-18 00:00:00+00	2026-09-17 23:00:00+00	1	P4FIX_WJ_APP_38	福建省医疗服务资质检测系统	P4FIX_CAT_5	政务外网、互联网	GOV	https://p4.invalid/app/38	\N	核验医疗服务资质，记录检测及复核结果。	\N	\N	38	ENABLED	UNCONFIGURED	[]	["SELF","ADMIN"]	MOCK_APP_38	{"id": "MOCK_APP_38", "url": "https://p4.invalid/app/38", "code": "WJ_APP_38", "name": "福建省医疗服务资质检测系统", "status": "ENABLED", "version": 1, "category": "卫生监督", "sourceNo": 38, "userType": "GOV", "createdAt": "2026-09-16T00:00:00.000Z", "sortOrder": 38, "updatedAt": "2026-09-17T23:00:00.000Z", "accessMode": "BIND", "categoryId": "MOCK_CAT_5", "platformId": "MOCK_PLATFORM_6", "platformNo": 6, "description": "核验医疗服务资质，记录检测及复核结果。", "networkZone": "政务外网、互联网", "mockScenario": "BOUND_EXISTING", "platformName": "省卫监所综合管理系统", "postGrantMode": "DIRECT", "runtimeStatus": "ABNORMAL", "integrationNote": "服务地址与接入参数待配置", "connectionStatus": "UNCONFIGURED", "accountBindingMode": "ADMIN", "accountOpeningMode": "NONE"}	\N
40	\N	\N	\N	\N	\N	P4FIX_APP_39	2026-09-18 00:00:00+00	2026-09-17 23:00:00+00	1	P4FIX_WJ_APP_39	福建省食源性疾病省级平台系统	P4FIX_CAT_6	政务外网	GOV	https://p4.invalid/app/39	\N	管理食源性疾病监测报告、事件核查及分析。	\N	\N	39	ENABLED	UNCONFIGURED	[]	["SELF","ADMIN"]	MOCK_APP_39	{"id": "MOCK_APP_39", "url": "https://p4.invalid/app/39", "code": "WJ_APP_39", "name": "福建省食源性疾病省级平台系统", "status": "ENABLED", "version": 1, "category": "疾病防控", "sourceNo": 39, "userType": "GOV", "createdAt": "2026-09-16T00:00:00.000Z", "sortOrder": 39, "updatedAt": "2026-09-17T23:00:00.000Z", "accessMode": "BIND", "categoryId": "MOCK_CAT_6", "platformId": "MOCK_PLATFORM_7", "platformNo": 7, "description": "管理食源性疾病监测报告、事件核查及分析。", "networkZone": "政务外网", "mockScenario": "BOUND_EXISTING", "platformName": "省疾控中心综合管理系统", "postGrantMode": "DIRECT", "runtimeStatus": "NORMAL", "integrationNote": "服务地址与接入参数待配置", "connectionStatus": "UNCONFIGURED", "accountBindingMode": "ADMIN", "accountOpeningMode": "NONE"}	\N
41	\N	\N	\N	\N	\N	P4FIX_APP_40	2026-09-18 00:00:00+00	2026-09-17 23:00:00+00	1	P4FIX_WJ_APP_40	福建省疾病预防控制中心信息门户系统	P4FIX_CAT_6	政务外网	GOV	https://p4.invalid/app/40	\N	汇集疾控业务入口、工作通知与信息发布服务。	\N	\N	40	ENABLED	UNCONFIGURED	[]	["SELF","ADMIN"]	MOCK_APP_40	{"id": "MOCK_APP_40", "url": "https://p4.invalid/app/40", "code": "WJ_APP_40", "name": "福建省疾病预防控制中心信息门户系统", "status": "ENABLED", "version": 1, "category": "疾病防控", "sourceNo": 40, "userType": "GOV", "createdAt": "2026-09-16T00:00:00.000Z", "sortOrder": 40, "updatedAt": "2026-09-17T23:00:00.000Z", "accessMode": "BIND", "categoryId": "MOCK_CAT_6", "platformId": "MOCK_PLATFORM_7", "platformNo": 7, "description": "汇集疾控业务入口、工作通知与信息发布服务。", "networkZone": "政务外网", "mockScenario": "BOUND_EXISTING", "platformName": "省疾控中心综合管理系统", "postGrantMode": "DIRECT", "runtimeStatus": "UNCONFIGURED", "integrationNote": "服务地址与接入参数待配置", "connectionStatus": "UNCONFIGURED", "accountBindingMode": "ADMIN", "accountOpeningMode": "NONE"}	\N
42	\N	\N	\N	\N	\N	P4FIX_APP_41	2026-09-18 00:00:00+00	2026-09-17 23:00:00+00	1	P4FIX_WJ_APP_41	福建省慢性病防控指标系统	P4FIX_CAT_6	政务外网	GOV	https://p4.invalid/app/41	\N	管理慢性病防控指标采集、质量核验与评估。	\N	\N	41	ENABLED	UNCONFIGURED	[]	["SELF","ADMIN"]	MOCK_APP_41	{"id": "MOCK_APP_41", "url": "https://p4.invalid/app/41", "code": "WJ_APP_41", "name": "福建省慢性病防控指标系统", "status": "ENABLED", "version": 1, "category": "疾病防控", "sourceNo": 41, "userType": "GOV", "createdAt": "2026-09-16T00:00:00.000Z", "sortOrder": 41, "updatedAt": "2026-09-17T23:00:00.000Z", "accessMode": "BIND", "categoryId": "MOCK_CAT_6", "platformId": "MOCK_PLATFORM_7", "platformNo": 7, "description": "管理慢性病防控指标采集、质量核验与评估。", "networkZone": "政务外网", "mockScenario": "BOUND_EXISTING", "platformName": "省疾控中心综合管理系统", "postGrantMode": "DIRECT", "runtimeStatus": "NORMAL", "integrationNote": "服务地址与接入参数待配置", "connectionStatus": "UNCONFIGURED", "accountBindingMode": "ADMIN", "accountOpeningMode": "NONE"}	\N
43	\N	\N	\N	\N	\N	P4FIX_APP_43	2026-09-18 00:00:00+00	2026-09-17 23:00:00+00	1	P4FIX_WJ_APP_43	福建省疫苗冷链监测系统	P4FIX_CAT_6	政务外网	GOV	https://p4.invalid/app/43	\N	监测疫苗储运温度、冷链设备运行及异常处置。	\N	\N	43	DISABLED	UNCONFIGURED	[]	["SELF","ADMIN"]	MOCK_APP_43	{"id": "MOCK_APP_43", "url": "https://p4.invalid/app/43", "code": "WJ_APP_43", "name": "福建省疫苗冷链监测系统", "status": "DISABLED", "version": 1, "category": "疾病防控", "sourceNo": 43, "userType": "GOV", "createdAt": "2026-09-16T00:00:00.000Z", "sortOrder": 43, "updatedAt": "2026-09-17T23:00:00.000Z", "accessMode": "BIND", "categoryId": "MOCK_CAT_6", "platformId": "MOCK_PLATFORM_7", "platformNo": 7, "description": "监测疫苗储运温度、冷链设备运行及异常处置。", "networkZone": "政务外网", "mockScenario": "BOUND_EXISTING", "platformName": "省疾控中心综合管理系统", "postGrantMode": "DIRECT", "runtimeStatus": "DISABLED", "integrationNote": "服务地址与接入参数待配置", "connectionStatus": "UNCONFIGURED", "accountBindingMode": "ADMIN", "accountOpeningMode": "NONE"}	\N
\.


--
-- Data for Name: application_access_grant; Type: TABLE DATA; Schema: pb3gir75kkooyea; Owner: admin
--

COPY pb3gir75kkooyea.application_access_grant (id, runtime_id, created_at, updated_at, version, user_id, application_id, status, granted_by, granted_at, expires_at) FROM stdin;
P4FIX_GRANT_CITIZEN_APP13	MOCK_GRANT_CITIZEN_APP13	2026-09-16 00:00:00+00	2026-09-17 23:00:00+00	1	P4FIX_USER_1	P4FIX_APP_13	ACTIVE	P4FIX_ADMIN	2026-09-17 08:00:00+00	\N
P4FIX_GRANT_GOV_APP17	MOCK_GRANT_GOV_APP17	2026-09-16 00:00:00+00	2026-09-17 23:00:00+00	1	P4FIX_USER_2	P4FIX_APP_17	ACTIVE	P4FIX_ADMIN	2026-09-17 12:00:00+00	\N
\.


--
-- Data for Name: application_access_request; Type: TABLE DATA; Schema: pb3gir75kkooyea; Owner: admin
--

COPY pb3gir75kkooyea.application_access_request (id, runtime_id, created_at, updated_at, version, request_no, user_id, application_id, reason, contact, remark, status, submitted_at, reviewed_by, reviewed_at, review_note, withdrawn_at, expired_at) FROM stdin;
P4FIX_REQ_CITIZEN_EXPIRED	MOCK_REQ_CITIZEN_EXPIRED	2026-09-15 22:00:00+00	2026-09-16 04:00:00+00	1	REQ-20260915-00001	P4FIX_USER_1	P4FIX_APP_13	历史申请：未在有效期内完成后续处理			EXPIRED	2026-09-15 22:00:00+00	\N	\N	申请已失效，可重新发起申请	\N	2026-09-16 04:00:00+00
P4FIX_REQ_CITIZEN_WITHDRAWN	MOCK_REQ_CITIZEN_WITHDRAWN	2026-09-16 10:00:00+00	2026-09-16 13:00:00+00	1	REQ-20260916-00001	P4FIX_USER_1	P4FIX_APP_13	历史申请：业务使用需要			WITHDRAWN	2026-09-16 10:00:00+00	\N	\N	用户主动撤回	2026-09-16 13:00:00+00	\N
P4FIX_REQ_CITIZEN_REJECTED	MOCK_REQ_CITIZEN_REJECTED	2026-09-16 18:00:00+00	2026-09-16 21:00:00+00	1	REQ-20260916-00002	P4FIX_USER_1	P4FIX_APP_13	历史申请：业务使用需要			REJECTED	2026-09-16 18:00:00+00	P4FIX_ADMIN	2026-09-16 21:00:00+00	资料不完整，请补充后重新申请	\N	\N
P4FIX_REQ_CITIZEN_APPROVED	MOCK_REQ_CITIZEN_APPROVED	2026-09-17 06:00:00+00	2026-09-17 08:00:00+00	1	REQ-20260917-00001	P4FIX_USER_1	P4FIX_APP_13	申请访问公众业务应用			APPROVED	2026-09-17 06:00:00+00	P4FIX_ADMIN	2026-09-17 08:00:00+00	审核通过，可直接进入应用	\N	\N
P4FIX_REQ_CITIZEN_PENDING	MOCK_REQ_CITIZEN_PENDING	2026-09-17 16:00:00+00	2026-09-17 16:00:00+00	1	REQ-20260918-00001	P4FIX_USER_1	P4FIX_APP_17	申请访问需要账号确认的业务应用			PENDING	2026-09-17 16:00:00+00	\N	\N	\N	\N	\N
P4FIX_REQ_GOV_REJECTED	MOCK_REQ_GOV_REJECTED	2026-09-17 17:00:00+00	2026-09-17 18:00:00+00	1	REQ-20260918-00002	P4FIX_USER_2	P4FIX_APP_13	申请业务使用权限			REJECTED	2026-09-17 17:00:00+00	P4FIX_ADMIN	2026-09-17 18:00:00+00	资料不完整，可查看原因后重新申请	\N	\N
P4FIX_REQ_GOV_APPROVED_BIND	MOCK_REQ_GOV_APPROVED_BIND	2026-09-17 10:00:00+00	2026-09-17 12:00:00+00	1	REQ-20260917-00002	P4FIX_USER_2	P4FIX_APP_17	申请业务使用权限并确认历史账号			APPROVED	2026-09-17 10:00:00+00	P4FIX_ADMIN	2026-09-17 12:00:00+00	审核通过，请继续完成账号确认	\N	\N
\.


--
-- Data for Name: application_category; Type: TABLE DATA; Schema: pb3gir75kkooyea; Owner: admin
--

COPY pb3gir75kkooyea.application_category (nc_id, created_at1, updated_at1, created_by, updated_by, nc_order, id, created_at, updated_at, version, code, name, icon, sort_order, status, remark, runtime_id, runtime_payload, deleted_at) FROM stdin;
1	\N	\N	\N	\N	\N	P4FIX_CAT_1	2026-09-18 00:00:00+00	2026-09-17 23:00:00+00	1	P4FIX_PUBLIC	公众服务	\N	0	ENABLED	P4 fixture	MOCK_CAT_1	{"id": "MOCK_CAT_1", "code": "PUBLIC", "name": "公众服务", "status": "ENABLED", "version": 1, "createdAt": "2026-09-16T00:00:00.000Z", "sortOrder": 0, "updatedAt": "2026-09-17T23:00:00.000Z"}	\N
2	\N	\N	\N	\N	\N	P4FIX_CAT_2	2026-09-18 00:00:00+00	2026-09-17 23:00:00+00	1	P4FIX_GOV	政务协同	\N	1	ENABLED	P4 fixture	MOCK_CAT_2	{"id": "MOCK_CAT_2", "code": "GOV", "name": "政务协同", "status": "ENABLED", "version": 1, "createdAt": "2026-09-16T00:00:00.000Z", "sortOrder": 1, "updatedAt": "2026-09-17T23:00:00.000Z"}	\N
3	\N	\N	\N	\N	\N	P4FIX_CAT_3	2026-09-18 00:00:00+00	2026-09-17 23:00:00+00	1	P4FIX_REGULATION	行业监管	\N	2	ENABLED	P4 fixture	MOCK_CAT_3	{"id": "MOCK_CAT_3", "code": "REGULATION", "name": "行业监管", "status": "ENABLED", "version": 1, "createdAt": "2026-09-16T00:00:00.000Z", "sortOrder": 2, "updatedAt": "2026-09-17T23:00:00.000Z"}	\N
4	\N	\N	\N	\N	\N	P4FIX_CAT_4	2026-09-18 00:00:00+00	2026-09-17 23:00:00+00	1	P4FIX_TRAINING	培训考试	\N	3	ENABLED	P4 fixture	MOCK_CAT_4	{"id": "MOCK_CAT_4", "code": "TRAINING", "name": "培训考试", "status": "ENABLED", "version": 1, "createdAt": "2026-09-16T00:00:00.000Z", "sortOrder": 3, "updatedAt": "2026-09-17T23:00:00.000Z"}	\N
5	\N	\N	\N	\N	\N	P4FIX_CAT_5	2026-09-18 00:00:00+00	2026-09-17 23:00:00+00	1	P4FIX_SUPERVISION	卫生监督	\N	4	ENABLED	P4 fixture	MOCK_CAT_5	{"id": "MOCK_CAT_5", "code": "SUPERVISION", "name": "卫生监督", "status": "ENABLED", "version": 1, "createdAt": "2026-09-16T00:00:00.000Z", "sortOrder": 4, "updatedAt": "2026-09-17T23:00:00.000Z"}	\N
6	\N	\N	\N	\N	\N	P4FIX_CAT_6	2026-09-18 00:00:00+00	2026-09-17 23:00:00+00	1	P4FIX_PREVENTION	疾病防控	\N	5	ENABLED	P4 fixture	MOCK_CAT_6	{"id": "MOCK_CAT_6", "code": "PREVENTION", "name": "疾病防控", "status": "ENABLED", "version": 1, "createdAt": "2026-09-16T00:00:00.000Z", "sortOrder": 5, "updatedAt": "2026-09-17T23:00:00.000Z"}	\N
\.


--
-- Data for Name: application_user_mapping; Type: TABLE DATA; Schema: pb3gir75kkooyea; Owner: admin
--

COPY pb3gir75kkooyea.application_user_mapping (nc_id, created_at1, updated_at1, created_by, updated_by, nc_order, id, created_at, updated_at, version, user_id, application_id, external_user_id, external_account, binding_method, status, active_account_key, verified_method, verified_at, bound_at, unbound_at, conflict_reason) FROM stdin;
3	\N	\N	\N	\N	\N	P4FIX_MAP_MOCK_USER_1_1	2026-09-18 00:00:00+00	2026-09-17 23:00:00+00	1	P4FIX_USER_1	P4FIX_APP_1	P4FIX_P4_SUBJECT_MOCK_USER_1_1	linxiao_01	ADMIN	BOUND	["P4FIX_APP_1","P4FIX_P4_SUBJECT_MOCK_USER_1_1"]	\N	\N	2026-09-17 00:00:00+00	\N	\N
4	\N	\N	\N	\N	\N	P4FIX_MAP_MOCK_USER_1_2	2026-09-18 00:00:00+00	2026-09-17 23:00:00+00	1	P4FIX_USER_1	P4FIX_APP_2	P4FIX_P4_SUBJECT_MOCK_USER_1_2	linxiao_02	ADMIN	BOUND	["P4FIX_APP_2","P4FIX_P4_SUBJECT_MOCK_USER_1_2"]	\N	\N	2026-09-17 00:00:00+00	\N	\N
36	\N	\N	\N	\N	\N	P4FIX_MAP_MOCK_EDITOR_4	2026-09-18 00:00:00+00	2026-09-17 23:00:00+00	1	P4FIX_EDITOR	P4FIX_APP_4	P4FIX_P4_SUBJECT_MOCK_EDITOR_4	zhengying_04	ADMIN	BOUND	["P4FIX_APP_4","P4FIX_P4_SUBJECT_MOCK_EDITOR_4"]	\N	\N	2026-09-17 00:00:00+00	\N	\N
37	\N	\N	\N	\N	\N	P4FIX_MAP_MOCK_EDITOR_5	2026-09-18 00:00:00+00	2026-09-17 23:00:00+00	1	P4FIX_EDITOR	P4FIX_APP_5	P4FIX_P4_SUBJECT_MOCK_EDITOR_5	zhengying_05	ADMIN	BOUND	["P4FIX_APP_5","P4FIX_P4_SUBJECT_MOCK_EDITOR_5"]	\N	\N	2026-09-17 00:00:00+00	\N	\N
38	\N	\N	\N	\N	\N	P4FIX_MAP_MOCK_EDITOR_6	2026-09-18 00:00:00+00	2026-09-17 23:00:00+00	1	P4FIX_EDITOR	P4FIX_APP_6	P4FIX_P4_SUBJECT_MOCK_EDITOR_6	zhengying_06	ADMIN	BOUND	["P4FIX_APP_6","P4FIX_P4_SUBJECT_MOCK_EDITOR_6"]	\N	\N	2026-09-17 00:00:00+00	\N	\N
39	\N	\N	\N	\N	\N	P4FIX_MAP_MOCK_EDITOR_7	2026-09-18 00:00:00+00	2026-09-17 23:00:00+00	1	P4FIX_EDITOR	P4FIX_APP_7	P4FIX_P4_SUBJECT_MOCK_EDITOR_7	zhengying_07	ADMIN	BOUND	["P4FIX_APP_7","P4FIX_P4_SUBJECT_MOCK_EDITOR_7"]	\N	\N	2026-09-17 00:00:00+00	\N	\N
40	\N	\N	\N	\N	\N	P4FIX_MAP_MOCK_EDITOR_8	2026-09-18 00:00:00+00	2026-09-17 23:00:00+00	1	P4FIX_EDITOR	P4FIX_APP_8	P4FIX_P4_SUBJECT_MOCK_EDITOR_8	zhengying_08	ADMIN	BOUND	["P4FIX_APP_8","P4FIX_P4_SUBJECT_MOCK_EDITOR_8"]	\N	\N	2026-09-17 00:00:00+00	\N	\N
41	\N	\N	\N	\N	\N	P4FIX_MAP_MOCK_EDITOR_26	2026-09-18 00:00:00+00	2026-09-17 23:00:00+00	1	P4FIX_EDITOR	P4FIX_APP_26	P4FIX_P4_SUBJECT_MOCK_EDITOR_26	zhengying_26	ADMIN	FAILED	\N	\N	\N	\N	\N	账号核验未通过，待补充关联资料
42	\N	\N	\N	\N	\N	P4FIX_MAP_MOCK_EDITOR_28	2026-09-18 00:00:00+00	2026-09-17 23:00:00+00	1	P4FIX_EDITOR	P4FIX_APP_28	P4FIX_P4_SUBJECT_MOCK_EDITOR_28	zhengying_28	ADMIN	CONFLICT	\N	\N	\N	\N	\N	身份资料不一致，待人工核查
5	\N	\N	\N	\N	\N	P4FIX_MAP_MOCK_USER_1_3	2026-09-18 00:00:00+00	2026-09-17 23:00:00+00	1	P4FIX_USER_1	P4FIX_APP_3	P4FIX_P4_SUBJECT_MOCK_USER_1_3	linxiao_03	ADMIN	BOUND	["P4FIX_APP_3","P4FIX_P4_SUBJECT_MOCK_USER_1_3"]	\N	\N	2026-09-17 00:00:00+00	\N	\N
6	\N	\N	\N	\N	\N	P4FIX_MAP_MOCK_USER_1_4	2026-09-18 00:00:00+00	2026-09-17 23:00:00+00	1	P4FIX_USER_1	P4FIX_APP_4	P4FIX_P4_SUBJECT_MOCK_USER_1_4	linxiao_04	ADMIN	BOUND	["P4FIX_APP_4","P4FIX_P4_SUBJECT_MOCK_USER_1_4"]	\N	\N	2026-09-17 00:00:00+00	\N	\N
7	\N	\N	\N	\N	\N	P4FIX_MAP_MOCK_USER_1_5	2026-09-18 00:00:00+00	2026-09-17 23:00:00+00	1	P4FIX_USER_1	P4FIX_APP_5	P4FIX_P4_SUBJECT_MOCK_USER_1_5	linxiao_05	ADMIN	BOUND	["P4FIX_APP_5","P4FIX_P4_SUBJECT_MOCK_USER_1_5"]	\N	\N	2026-09-17 00:00:00+00	\N	\N
8	\N	\N	\N	\N	\N	P4FIX_MAP_MOCK_USER_1_6	2026-09-18 00:00:00+00	2026-09-17 23:00:00+00	1	P4FIX_USER_1	P4FIX_APP_6	P4FIX_P4_SUBJECT_MOCK_USER_1_6	linxiao_06	ADMIN	BOUND	["P4FIX_APP_6","P4FIX_P4_SUBJECT_MOCK_USER_1_6"]	\N	\N	2026-09-17 00:00:00+00	\N	\N
9	\N	\N	\N	\N	\N	P4FIX_MAP_MOCK_USER_1_11	2026-09-18 00:00:00+00	2026-09-17 23:00:00+00	1	P4FIX_USER_1	P4FIX_APP_11	P4FIX_P4_SUBJECT_MOCK_USER_1_11	linxiao_11	ADMIN	BOUND	["P4FIX_APP_11","P4FIX_P4_SUBJECT_MOCK_USER_1_11"]	\N	\N	2026-09-17 00:00:00+00	\N	\N
10	\N	\N	\N	\N	\N	P4FIX_MAP_MOCK_USER_1_12	2026-09-18 00:00:00+00	2026-09-17 23:00:00+00	1	P4FIX_USER_1	P4FIX_APP_12	P4FIX_P4_SUBJECT_MOCK_USER_1_12	linxiao_12	ADMIN	BOUND	["P4FIX_APP_12","P4FIX_P4_SUBJECT_MOCK_USER_1_12"]	\N	\N	2026-09-17 00:00:00+00	\N	\N
11	\N	\N	\N	\N	\N	P4FIX_MAP_MOCK_USER_1_26	2026-09-18 00:00:00+00	2026-09-17 23:00:00+00	1	P4FIX_USER_1	P4FIX_APP_26	P4FIX_P4_SUBJECT_MOCK_USER_1_26	linxiao_26	ADMIN	FAILED	\N	\N	\N	\N	\N	账号核验未通过，待补充关联资料
12	\N	\N	\N	\N	\N	P4FIX_MAP_MOCK_USER_1_28	2026-09-18 00:00:00+00	2026-09-17 23:00:00+00	1	P4FIX_USER_1	P4FIX_APP_28	P4FIX_P4_SUBJECT_MOCK_USER_1_28	linxiao_28	ADMIN	CONFLICT	\N	\N	\N	\N	\N	身份资料不一致，待人工核查
13	\N	\N	\N	\N	\N	P4FIX_MAP_MOCK_USER_2_1	2026-09-18 00:00:00+00	2026-09-17 23:00:00+00	1	P4FIX_USER_2	P4FIX_APP_1	P4FIX_P4_SUBJECT_MOCK_USER_2_1	chenning_01	ADMIN	BOUND	["P4FIX_APP_1","P4FIX_P4_SUBJECT_MOCK_USER_2_1"]	\N	\N	2026-09-17 00:00:00+00	\N	\N
14	\N	\N	\N	\N	\N	P4FIX_MAP_MOCK_USER_2_2	2026-09-18 00:00:00+00	2026-09-17 23:00:00+00	1	P4FIX_USER_2	P4FIX_APP_2	P4FIX_P4_SUBJECT_MOCK_USER_2_2	chenning_02	ADMIN	BOUND	["P4FIX_APP_2","P4FIX_P4_SUBJECT_MOCK_USER_2_2"]	\N	\N	2026-09-17 00:00:00+00	\N	\N
15	\N	\N	\N	\N	\N	P4FIX_MAP_MOCK_USER_2_3	2026-09-18 00:00:00+00	2026-09-17 23:00:00+00	1	P4FIX_USER_2	P4FIX_APP_3	P4FIX_P4_SUBJECT_MOCK_USER_2_3	chenning_03	ADMIN	BOUND	["P4FIX_APP_3","P4FIX_P4_SUBJECT_MOCK_USER_2_3"]	\N	\N	2026-09-17 00:00:00+00	\N	\N
16	\N	\N	\N	\N	\N	P4FIX_MAP_MOCK_USER_2_4	2026-09-18 00:00:00+00	2026-09-17 23:00:00+00	1	P4FIX_USER_2	P4FIX_APP_4	P4FIX_P4_SUBJECT_MOCK_USER_2_4	chenning_04	ADMIN	BOUND	["P4FIX_APP_4","P4FIX_P4_SUBJECT_MOCK_USER_2_4"]	\N	\N	2026-09-17 00:00:00+00	\N	\N
17	\N	\N	\N	\N	\N	P4FIX_MAP_MOCK_USER_2_5	2026-09-18 00:00:00+00	2026-09-17 23:00:00+00	1	P4FIX_USER_2	P4FIX_APP_5	P4FIX_P4_SUBJECT_MOCK_USER_2_5	chenning_05	ADMIN	BOUND	["P4FIX_APP_5","P4FIX_P4_SUBJECT_MOCK_USER_2_5"]	\N	\N	2026-09-17 00:00:00+00	\N	\N
18	\N	\N	\N	\N	\N	P4FIX_MAP_MOCK_USER_2_6	2026-09-18 00:00:00+00	2026-09-17 23:00:00+00	1	P4FIX_USER_2	P4FIX_APP_6	P4FIX_P4_SUBJECT_MOCK_USER_2_6	chenning_06	ADMIN	BOUND	["P4FIX_APP_6","P4FIX_P4_SUBJECT_MOCK_USER_2_6"]	\N	\N	2026-09-17 00:00:00+00	\N	\N
19	\N	\N	\N	\N	\N	P4FIX_MAP_MOCK_USER_2_7	2026-09-18 00:00:00+00	2026-09-17 23:00:00+00	1	P4FIX_USER_2	P4FIX_APP_7	P4FIX_P4_SUBJECT_MOCK_USER_2_7	chenning_07	ADMIN	BOUND	["P4FIX_APP_7","P4FIX_P4_SUBJECT_MOCK_USER_2_7"]	\N	\N	2026-09-17 00:00:00+00	\N	\N
20	\N	\N	\N	\N	\N	P4FIX_MAP_MOCK_USER_2_8	2026-09-18 00:00:00+00	2026-09-17 23:00:00+00	1	P4FIX_USER_2	P4FIX_APP_8	P4FIX_P4_SUBJECT_MOCK_USER_2_8	chenning_08	ADMIN	BOUND	["P4FIX_APP_8","P4FIX_P4_SUBJECT_MOCK_USER_2_8"]	\N	\N	2026-09-17 00:00:00+00	\N	\N
21	\N	\N	\N	\N	\N	P4FIX_MAP_MOCK_USER_2_26	2026-09-18 00:00:00+00	2026-09-17 23:00:00+00	1	P4FIX_USER_2	P4FIX_APP_26	P4FIX_P4_SUBJECT_MOCK_USER_2_26	chenning_26	ADMIN	FAILED	\N	\N	\N	\N	\N	账号核验未通过，待补充关联资料
22	\N	\N	\N	\N	\N	P4FIX_MAP_MOCK_USER_2_28	2026-09-18 00:00:00+00	2026-09-17 23:00:00+00	1	P4FIX_USER_2	P4FIX_APP_28	P4FIX_P4_SUBJECT_MOCK_USER_2_28	chenning_28	ADMIN	CONFLICT	\N	\N	\N	\N	\N	身份资料不一致，待人工核查
23	\N	\N	\N	\N	\N	P4FIX_MAP_MOCK_ADMIN_1	2026-09-18 00:00:00+00	2026-09-17 23:00:00+00	1	P4FIX_ADMIN	P4FIX_APP_1	P4FIX_P4_SUBJECT_MOCK_ADMIN_1	zhouming_01	ADMIN	BOUND	["P4FIX_APP_1","P4FIX_P4_SUBJECT_MOCK_ADMIN_1"]	\N	\N	2026-09-17 00:00:00+00	\N	\N
24	\N	\N	\N	\N	\N	P4FIX_MAP_MOCK_ADMIN_2	2026-09-18 00:00:00+00	2026-09-17 23:00:00+00	1	P4FIX_ADMIN	P4FIX_APP_2	P4FIX_P4_SUBJECT_MOCK_ADMIN_2	zhouming_02	ADMIN	BOUND	["P4FIX_APP_2","P4FIX_P4_SUBJECT_MOCK_ADMIN_2"]	\N	\N	2026-09-17 00:00:00+00	\N	\N
25	\N	\N	\N	\N	\N	P4FIX_MAP_MOCK_ADMIN_3	2026-09-18 00:00:00+00	2026-09-17 23:00:00+00	1	P4FIX_ADMIN	P4FIX_APP_3	P4FIX_P4_SUBJECT_MOCK_ADMIN_3	zhouming_03	ADMIN	BOUND	["P4FIX_APP_3","P4FIX_P4_SUBJECT_MOCK_ADMIN_3"]	\N	\N	2026-09-17 00:00:00+00	\N	\N
26	\N	\N	\N	\N	\N	P4FIX_MAP_MOCK_ADMIN_4	2026-09-18 00:00:00+00	2026-09-17 23:00:00+00	1	P4FIX_ADMIN	P4FIX_APP_4	P4FIX_P4_SUBJECT_MOCK_ADMIN_4	zhouming_04	ADMIN	BOUND	["P4FIX_APP_4","P4FIX_P4_SUBJECT_MOCK_ADMIN_4"]	\N	\N	2026-09-17 00:00:00+00	\N	\N
27	\N	\N	\N	\N	\N	P4FIX_MAP_MOCK_ADMIN_5	2026-09-18 00:00:00+00	2026-09-17 23:00:00+00	1	P4FIX_ADMIN	P4FIX_APP_5	P4FIX_P4_SUBJECT_MOCK_ADMIN_5	zhouming_05	ADMIN	BOUND	["P4FIX_APP_5","P4FIX_P4_SUBJECT_MOCK_ADMIN_5"]	\N	\N	2026-09-17 00:00:00+00	\N	\N
28	\N	\N	\N	\N	\N	P4FIX_MAP_MOCK_ADMIN_6	2026-09-18 00:00:00+00	2026-09-17 23:00:00+00	1	P4FIX_ADMIN	P4FIX_APP_6	P4FIX_P4_SUBJECT_MOCK_ADMIN_6	zhouming_06	ADMIN	BOUND	["P4FIX_APP_6","P4FIX_P4_SUBJECT_MOCK_ADMIN_6"]	\N	\N	2026-09-17 00:00:00+00	\N	\N
29	\N	\N	\N	\N	\N	P4FIX_MAP_MOCK_ADMIN_7	2026-09-18 00:00:00+00	2026-09-17 23:00:00+00	1	P4FIX_ADMIN	P4FIX_APP_7	P4FIX_P4_SUBJECT_MOCK_ADMIN_7	zhouming_07	ADMIN	BOUND	["P4FIX_APP_7","P4FIX_P4_SUBJECT_MOCK_ADMIN_7"]	\N	\N	2026-09-17 00:00:00+00	\N	\N
30	\N	\N	\N	\N	\N	P4FIX_MAP_MOCK_ADMIN_8	2026-09-18 00:00:00+00	2026-09-17 23:00:00+00	1	P4FIX_ADMIN	P4FIX_APP_8	P4FIX_P4_SUBJECT_MOCK_ADMIN_8	zhouming_08	ADMIN	BOUND	["P4FIX_APP_8","P4FIX_P4_SUBJECT_MOCK_ADMIN_8"]	\N	\N	2026-09-17 00:00:00+00	\N	\N
31	\N	\N	\N	\N	\N	P4FIX_MAP_MOCK_ADMIN_26	2026-09-18 00:00:00+00	2026-09-17 23:00:00+00	1	P4FIX_ADMIN	P4FIX_APP_26	P4FIX_P4_SUBJECT_MOCK_ADMIN_26	zhouming_26	ADMIN	FAILED	\N	\N	\N	\N	\N	账号核验未通过，待补充关联资料
32	\N	\N	\N	\N	\N	P4FIX_MAP_MOCK_ADMIN_28	2026-09-18 00:00:00+00	2026-09-17 23:00:00+00	1	P4FIX_ADMIN	P4FIX_APP_28	P4FIX_P4_SUBJECT_MOCK_ADMIN_28	zhouming_28	ADMIN	CONFLICT	\N	\N	\N	\N	\N	身份资料不一致，待人工核查
33	\N	\N	\N	\N	\N	P4FIX_MAP_MOCK_EDITOR_1	2026-09-18 00:00:00+00	2026-09-17 23:00:00+00	1	P4FIX_EDITOR	P4FIX_APP_1	P4FIX_P4_SUBJECT_MOCK_EDITOR_1	zhengying_01	ADMIN	BOUND	["P4FIX_APP_1","P4FIX_P4_SUBJECT_MOCK_EDITOR_1"]	\N	\N	2026-09-17 00:00:00+00	\N	\N
34	\N	\N	\N	\N	\N	P4FIX_MAP_MOCK_EDITOR_2	2026-09-18 00:00:00+00	2026-09-17 23:00:00+00	1	P4FIX_EDITOR	P4FIX_APP_2	P4FIX_P4_SUBJECT_MOCK_EDITOR_2	zhengying_02	ADMIN	BOUND	["P4FIX_APP_2","P4FIX_P4_SUBJECT_MOCK_EDITOR_2"]	\N	\N	2026-09-17 00:00:00+00	\N	\N
35	\N	\N	\N	\N	\N	P4FIX_MAP_MOCK_EDITOR_3	2026-09-18 00:00:00+00	2026-09-17 23:00:00+00	1	P4FIX_EDITOR	P4FIX_APP_3	P4FIX_P4_SUBJECT_MOCK_EDITOR_3	zhengying_03	ADMIN	BOUND	["P4FIX_APP_3","P4FIX_P4_SUBJECT_MOCK_EDITOR_3"]	\N	\N	2026-09-17 00:00:00+00	\N	\N
\.


--
-- Data for Name: audit_event; Type: TABLE DATA; Schema: pb3gir75kkooyea; Owner: admin
--

COPY pb3gir75kkooyea.audit_event (nc_id, created_at1, updated_at1, created_by, updated_by, nc_order, id, created_at, updated_at, version, kind, event_code, request_id, actor_user_id, actor_kind, application_id, object_type, object_id, result, summary, details, resolution_status) FROM stdin;
1	\N	\N	\N	\N	\N	P4FIX_LOG_login_0	2026-09-18 00:00:00+00	2026-09-18 00:00:00+00	1	LOGIN	P4FIX_login	P4FIX_P4_REQUEST_0_0	P4FIX_USER_1	USER	P4FIX_APP_1	P4_FIXTURE	P4FIX_APP_1	SUCCESS	身份登录记录	{"fixture":true,"source":"P4 offline dataset"}	\N
2	\N	\N	\N	\N	\N	P4FIX_LOG_login_1	2026-09-18 00:00:00+00	2026-09-18 00:00:00+00	1	LOGIN	P4FIX_login	P4FIX_P4_REQUEST_0_1	P4FIX_USER_2	USER	P4FIX_APP_2	P4_FIXTURE	P4FIX_APP_2	SUCCESS	身份登录记录	{"fixture":true,"source":"P4 offline dataset"}	\N
3	\N	\N	\N	\N	\N	P4FIX_LOG_login_2	2026-09-18 00:00:00+00	2026-09-18 00:00:00+00	1	LOGIN	P4FIX_login	P4FIX_P4_REQUEST_0_2	P4FIX_ADMIN	USER	P4FIX_APP_3	P4_FIXTURE	P4FIX_APP_3	SUCCESS	身份登录记录	{"fixture":true,"source":"P4 offline dataset"}	\N
4	\N	\N	\N	\N	\N	P4FIX_LOG_login_3	2026-09-18 00:00:00+00	2026-09-18 00:00:00+00	1	LOGIN	P4FIX_login	P4FIX_P4_REQUEST_0_3	P4FIX_EDITOR	USER	P4FIX_APP_4	P4_FIXTURE	P4FIX_APP_4	SUCCESS	身份登录记录	{"fixture":true,"source":"P4 offline dataset"}	\N
5	\N	\N	\N	\N	\N	P4FIX_LOG_auth_0	2026-09-18 00:00:00+00	2026-09-18 00:00:00+00	1	AUTH	P4FIX_auth	P4FIX_P4_REQUEST_1_0	P4FIX_USER_1	USER	P4FIX_APP_1	P4_FIXTURE	P4FIX_APP_1	SUCCESS	访问权限核验记录	{"fixture":true,"source":"P4 offline dataset"}	\N
6	\N	\N	\N	\N	\N	P4FIX_LOG_auth_1	2026-09-18 00:00:00+00	2026-09-18 00:00:00+00	1	AUTH	P4FIX_auth	P4FIX_P4_REQUEST_1_1	P4FIX_USER_2	USER	P4FIX_APP_2	P4_FIXTURE	P4FIX_APP_2	SUCCESS	访问权限核验记录	{"fixture":true,"source":"P4 offline dataset"}	\N
7	\N	\N	\N	\N	\N	P4FIX_LOG_auth_2	2026-09-18 00:00:00+00	2026-09-18 00:00:00+00	1	AUTH	P4FIX_auth	P4FIX_P4_REQUEST_1_2	P4FIX_ADMIN	USER	P4FIX_APP_3	P4_FIXTURE	P4FIX_APP_3	SUCCESS	访问权限核验记录	{"fixture":true,"source":"P4 offline dataset"}	\N
8	\N	\N	\N	\N	\N	P4FIX_LOG_auth_3	2026-09-18 00:00:00+00	2026-09-18 00:00:00+00	1	AUTH	P4FIX_auth	P4FIX_P4_REQUEST_1_3	P4FIX_EDITOR	USER	P4FIX_APP_4	P4_FIXTURE	P4FIX_APP_4	DENIED	访问权限核验记录	{"fixture":true,"source":"P4 offline dataset"}	\N
9	\N	\N	\N	\N	\N	P4FIX_LOG_access_0	2026-09-18 00:00:00+00	2026-09-18 00:00:00+00	1	ACCESS	P4FIX_access	P4FIX_P4_REQUEST_2_0	P4FIX_USER_1	USER	P4FIX_APP_1	P4_FIXTURE	P4FIX_APP_1	SUCCESS	应用访问记录	{"fixture":true,"source":"P4 offline dataset"}	\N
10	\N	\N	\N	\N	\N	P4FIX_LOG_access_1	2026-09-18 00:00:00+00	2026-09-18 00:00:00+00	1	ACCESS	P4FIX_access	P4FIX_P4_REQUEST_2_1	P4FIX_USER_2	USER	P4FIX_APP_2	P4_FIXTURE	P4FIX_APP_2	SUCCESS	应用访问记录	{"fixture":true,"source":"P4 offline dataset"}	\N
11	\N	\N	\N	\N	\N	P4FIX_LOG_access_2	2026-09-18 00:00:00+00	2026-09-18 00:00:00+00	1	ACCESS	P4FIX_access	P4FIX_P4_REQUEST_2_2	P4FIX_ADMIN	USER	P4FIX_APP_3	P4_FIXTURE	P4FIX_APP_3	SUCCESS	应用访问记录	{"fixture":true,"source":"P4 offline dataset"}	\N
12	\N	\N	\N	\N	\N	P4FIX_LOG_access_3	2026-09-18 00:00:00+00	2026-09-18 00:00:00+00	1	ACCESS	P4FIX_access	P4FIX_P4_REQUEST_2_3	P4FIX_EDITOR	USER	P4FIX_APP_4	P4_FIXTURE	P4FIX_APP_4	SUCCESS	应用访问记录	{"fixture":true,"source":"P4 offline dataset"}	\N
13	\N	\N	\N	\N	\N	P4FIX_LOG_operation_0	2026-09-18 00:00:00+00	2026-09-18 00:00:00+00	1	OPERATION	P4FIX_operation	P4FIX_P4_REQUEST_3_0	P4FIX_USER_1	USER	P4FIX_APP_1	P4_FIXTURE	P4FIX_APP_1	SUCCESS	公告维护记录	{"fixture":true,"source":"P4 offline dataset"}	\N
14	\N	\N	\N	\N	\N	P4FIX_LOG_operation_1	2026-09-18 00:00:00+00	2026-09-18 00:00:00+00	1	OPERATION	P4FIX_operation	P4FIX_P4_REQUEST_3_1	P4FIX_USER_2	USER	P4FIX_APP_2	P4_FIXTURE	P4FIX_APP_2	SUCCESS	公告维护记录	{"fixture":true,"source":"P4 offline dataset"}	\N
15	\N	\N	\N	\N	\N	P4FIX_LOG_operation_2	2026-09-18 00:00:00+00	2026-09-18 00:00:00+00	1	OPERATION	P4FIX_operation	P4FIX_P4_REQUEST_3_2	P4FIX_ADMIN	USER	P4FIX_APP_3	P4_FIXTURE	P4FIX_APP_3	SUCCESS	公告维护记录	{"fixture":true,"source":"P4 offline dataset"}	\N
16	\N	\N	\N	\N	\N	P4FIX_LOG_operation_3	2026-09-18 00:00:00+00	2026-09-18 00:00:00+00	1	OPERATION	P4FIX_operation	P4FIX_P4_REQUEST_3_3	P4FIX_EDITOR	USER	P4FIX_APP_4	P4_FIXTURE	P4FIX_APP_4	SUCCESS	公告维护记录	{"fixture":true,"source":"P4 offline dataset"}	\N
17	\N	\N	\N	\N	\N	P4FIX_LOG_api_0	2026-09-18 00:00:00+00	2026-09-18 00:00:00+00	1	API	P4FIX_api	P4FIX_P4_REQUEST_4_0	P4FIX_USER_1	USER	P4FIX_APP_1	P4_FIXTURE	P4FIX_APP_1	SUCCESS	数据接收记录	{"fixture":true,"source":"P4 offline dataset"}	\N
18	\N	\N	\N	\N	\N	P4FIX_LOG_api_1	2026-09-18 00:00:00+00	2026-09-18 00:00:00+00	1	API	P4FIX_api	P4FIX_P4_REQUEST_4_1	P4FIX_USER_2	USER	P4FIX_APP_2	P4_FIXTURE	P4FIX_APP_2	SUCCESS	数据接收记录	{"fixture":true,"source":"P4 offline dataset"}	\N
19	\N	\N	\N	\N	\N	P4FIX_LOG_api_2	2026-09-18 00:00:00+00	2026-09-18 00:00:00+00	1	API	P4FIX_api	P4FIX_P4_REQUEST_4_2	P4FIX_ADMIN	USER	P4FIX_APP_3	P4_FIXTURE	P4FIX_APP_3	SUCCESS	数据接收记录	{"fixture":true,"source":"P4 offline dataset"}	\N
20	\N	\N	\N	\N	\N	P4FIX_LOG_api_3	2026-09-18 00:00:00+00	2026-09-18 00:00:00+00	1	API	P4FIX_api	P4FIX_P4_REQUEST_4_3	P4FIX_EDITOR	USER	P4FIX_APP_4	P4_FIXTURE	P4FIX_APP_4	SUCCESS	数据接收记录	{"fixture":true,"source":"P4 offline dataset"}	\N
21	\N	\N	\N	\N	\N	P4FIX_LOG_error_0	2026-09-18 00:00:00+00	2026-09-18 00:00:00+00	1	ERROR	P4FIX_error	P4FIX_P4_REQUEST_5_0	P4FIX_USER_1	USER	P4FIX_APP_1	P4_FIXTURE	P4FIX_APP_1	FAILURE	接入参数未配置，需核对接口资料	{"fixture":true,"source":"P4 offline dataset"}	OPEN
22	\N	\N	\N	\N	\N	P4FIX_LOG_error_1	2026-09-18 00:00:00+00	2026-09-18 00:00:00+00	1	ERROR	P4FIX_error	P4FIX_P4_REQUEST_5_1	P4FIX_USER_2	USER	P4FIX_APP_2	P4_FIXTURE	P4FIX_APP_2	FAILURE	接入参数未配置，需核对接口资料	{"fixture":true,"source":"P4 offline dataset"}	OPEN
23	\N	\N	\N	\N	\N	P4FIX_LOG_error_2	2026-09-18 00:00:00+00	2026-09-18 00:00:00+00	1	ERROR	P4FIX_error	P4FIX_P4_REQUEST_5_2	P4FIX_ADMIN	USER	P4FIX_APP_3	P4_FIXTURE	P4FIX_APP_3	FAILURE	接入参数未配置，需核对接口资料	{"fixture":true,"source":"P4 offline dataset"}	OPEN
24	\N	\N	\N	\N	\N	P4FIX_LOG_error_3	2026-09-18 00:00:00+00	2026-09-18 00:00:00+00	1	ERROR	P4FIX_error	P4FIX_P4_REQUEST_5_3	P4FIX_EDITOR	USER	P4FIX_APP_4	P4_FIXTURE	P4FIX_APP_4	FAILURE	接入参数未配置，需核对接口资料	{"fixture":true,"source":"P4 offline dataset"}	OPEN
25	\N	\N	\N	\N	\N	P4EV_b8e6a531-c2d4-4ec2-bc90-951fcc28c889	2026-09-18 14:47:14.382+00	2026-09-18 14:47:14.382+00	1	LOGIN	LOGIN	25b27829-529a-4288-a438-cebc6a57627d	P4FIX_USER_1	USER	\N	portal	\N	SUCCESS	LOGIN	{"actorName":"林晓","applicationName":null,"objectType":"portal","previousActor":null}	\N
26	\N	\N	\N	\N	\N	P4EV_fc045687-abaa-4311-a723-7a5fc810debb	2026-09-18 14:47:24.911+00	2026-09-18 14:47:24.911+00	1	LOGIN	LOGOUT	cb89b7ec-e7e3-41eb-a98f-f4e5f005a412	P4FIX_USER_1	USER	\N	portal	\N	SUCCESS	LOGOUT	{"actorName":"林晓","applicationName":null,"objectType":"portal","previousActor":null}	\N
27	\N	\N	\N	\N	\N	P4EV_436cd5cb-91fd-44be-98af-51d74cefd3ca	2026-09-18 14:48:13.986+00	2026-09-18 14:48:13.986+00	1	LOGIN	LOGIN	1f619ff3-e7da-4f7c-9f88-087ac55c9545	P4FIX_USER_1	USER	\N	portal	\N	SUCCESS	LOGIN	{"actorName":"林晓","applicationName":null,"objectType":"portal","previousActor":null}	\N
28	\N	\N	\N	\N	\N	P4EV_b586117f-4454-4198-86ac-759f8c62d924	2026-09-18 14:48:28.461+00	2026-09-18 14:48:28.461+00	1	LOGIN	LOGIN	1ca18b8e-771e-4674-8c4f-f469a99fa69f	P4FIX_USER_1	USER	\N	portal	\N	SUCCESS	LOGIN	{"actorName":"林晓","applicationName":null,"objectType":"portal","previousActor":null}	\N
29	\N	\N	\N	\N	\N	P4EV_9eaea936-374c-4e2d-b0b8-363a1a825901	2026-09-18 14:48:29.52+00	2026-09-18 14:48:29.52+00	1	ACCESS	enterApp	9e642b1e-e4af-4dc1-bb4b-7a81d90fdc5b	P4FIX_USER_1	USER	P4FIX_APP_1	application	MOCK_APP_1	SUCCESS	enterApp	{"actorName":"林晓","applicationName":"福建省新生儿疾病筛查管理系统","objectType":"application","previousActor":null}	\N
30	\N	\N	\N	\N	\N	P4EV_23ff9f67-45d3-4bcb-acca-d56ac8cf0c57	2026-09-18 14:48:30.194+00	2026-09-18 14:48:30.194+00	1	LOGIN	SWITCH_USER	6bb32f05-903a-4e7c-8716-354eb6649d91	P4FIX_USER_2	USER	\N	portal	\N	SUCCESS	SWITCH_USER	{"actorName":"陈宁","applicationName":null,"objectType":"portal","previousActor":"MOCK_USER_1"}	\N
31	\N	\N	\N	\N	\N	P4EV_4e549067-2e69-4637-863e-c7e606a83095	2026-09-18 14:48:31.205+00	2026-09-18 14:48:31.205+00	1	LOGIN	SWITCH_USER	b65c0c50-f941-4843-bab1-60318ead7cc6	P4FIX_ADMIN	USER	\N	portal	\N	SUCCESS	SWITCH_USER	{"actorName":"周明","applicationName":null,"objectType":"portal","previousActor":"MOCK_USER_2"}	\N
32	\N	\N	\N	\N	\N	P4EV_92669f84-ad8f-472a-8f84-568445e5ece3	2026-09-18 14:48:32.587+00	2026-09-18 14:48:32.587+00	1	OPERATION	DOWNLOAD_CONTRACT	398a9ae3-8f35-4275-bf5f-b56d475679a2	P4FIX_ADMIN	USER	P4FIX_APP_1	application	\N	SUCCESS	DOWNLOAD_CONTRACT	{"actorName":"周明","applicationName":"福建省新生儿疾病筛查管理系统","objectType":"application","previousActor":null}	\N
33	\N	\N	\N	\N	\N	P4EV_c144c1f3-e55d-49c4-bb84-4ec58a339362	2026-09-18 14:48:33.294+00	2026-09-18 14:48:33.294+00	1	LOGIN	LOGOUT	6000aa38-d794-429c-8628-60efc79a37ff	P4FIX_ADMIN	USER	\N	portal	\N	SUCCESS	LOGOUT	{"actorName":"周明","applicationName":null,"objectType":"portal","previousActor":null}	\N
34	\N	\N	\N	\N	\N	P4EV_47246d39-f961-4013-8c25-da227d32fed9	2026-09-18 14:49:12.947+00	2026-09-18 14:49:12.947+00	1	OPERATION	markAnnouncementRead	036d5dfb-c10b-45c9-9e97-23468d0dc63a	P4FIX_USER_1	USER	\N	announcement	MOCK_ANN_1	SUCCESS	markAnnouncementRead	{"actorName":"林晓","applicationName":null,"objectType":"announcement","previousActor":null}	\N
35	\N	\N	\N	\N	\N	P4EV_e2140708-3a51-4018-8a2f-2a7899bd860a	2026-09-18 14:49:16.77+00	2026-09-18 14:49:16.77+00	1	OPERATION	markAnnouncementRead	3bb789b4-1acb-4160-8a50-d01ec51f9255	P4FIX_USER_1	USER	\N	announcement	MOCK_ANN_1	SUCCESS	markAnnouncementRead	{"actorName":"林晓","applicationName":null,"objectType":"announcement","previousActor":null}	\N
36	\N	\N	\N	\N	\N	P4EV_30cf8635-ffb7-42a1-b1d1-fc8ca174b84f	2026-09-18 14:49:21.959+00	2026-09-18 14:49:21.959+00	1	OPERATION	markRead	7af19920-488c-451c-bf8f-617c713363bb	P4FIX_USER_1	USER	\N	portal	MOCK_MSG_0_0	SUCCESS	markRead	{"actorName":"林晓","applicationName":null,"objectType":"portal","previousActor":null}	\N
37	\N	\N	\N	\N	\N	P4EV_52f032b5-b7b4-458e-aac1-b350bd8805ed	2026-09-18 14:49:28.248+00	2026-09-18 14:49:28.248+00	1	OPERATION	markAnnouncementRead	3f02197d-90e4-46f9-9c3d-0b12515c9b93	P4FIX_USER_1	USER	\N	announcement	MOCK_ANN_3	SUCCESS	markAnnouncementRead	{"actorName":"林晓","applicationName":null,"objectType":"announcement","previousActor":null}	\N
38	\N	\N	\N	\N	\N	P4EV_ca3eabfe-1239-4f23-a617-6e563087d5c3	2026-09-18 14:49:35.189+00	2026-09-18 14:49:35.189+00	1	OPERATION	markRead	58ef7dd9-b42f-475e-90d3-147f279b8e2c	P4FIX_USER_1	USER	\N	portal	MOCK_MSG_0_1	SUCCESS	markRead	{"actorName":"林晓","applicationName":null,"objectType":"portal","previousActor":null}	\N
39	\N	\N	\N	\N	\N	P4EV_e12ba6ae-d642-4fdc-966f-acb8685d6860	2026-09-18 14:49:42.283+00	2026-09-18 14:49:42.283+00	1	LOGIN	LOGIN	c1fe3f2b-89a8-49b3-a27a-fc9a75d0b9f1	P4FIX_ADMIN	USER	\N	portal	\N	SUCCESS	LOGIN	{"actorName":"周明","applicationName":null,"objectType":"portal","previousActor":null}	\N
40	\N	\N	\N	\N	\N	P4EV_9cb6ec31-7c07-4c97-a7ea-dee23507e77d	2026-09-18 14:49:43.312+00	2026-09-18 14:49:43.312+00	1	ERROR	saveRules	d5d95b3f-8c3e-4331-82cb-07f95df05d61	P4FIX_ADMIN	USER	\N	portal	\N	FAILURE	门户会话有效期超出允许范围	{"actorName":"周明","applicationName":null,"objectType":"portal","previousActor":null}	\N
41	\N	\N	\N	\N	\N	P4EV_c31beb02-619b-4500-8133-d3f1418bcb48	2026-09-18 14:50:11.053+00	2026-09-18 14:50:11.053+00	1	LOGIN	LOGIN	295f88a6-6802-48b3-81a5-1a523127bb03	P4FIX_ADMIN	USER	\N	portal	\N	SUCCESS	LOGIN	{"actorName":"周明","applicationName":null,"objectType":"portal","previousActor":null}	\N
42	\N	\N	\N	\N	\N	P4EV_1f209b31-ebf0-41ad-a1d8-82f3e53bf5bf	2026-09-18 14:50:12.066+00	2026-09-18 14:50:12.066+00	1	OPERATION	saveRules	3cd53ee3-f0e0-4bf0-af63-532c96c39126	P4FIX_ADMIN	USER	\N	portal	\N	SUCCESS	saveRules	{"actorName":"周明","applicationName":null,"objectType":"portal","previousActor":null}	\N
43	\N	\N	\N	\N	\N	P4EV_41b6e3ed-d84a-423f-8b4c-1cad9ee4018a	2026-09-18 14:50:12.748+00	2026-09-18 14:50:12.748+00	1	OPERATION	saveAnnouncement	ad678231-1eeb-4d27-872d-af4de769f84f	P4FIX_ADMIN	USER	\N	announcement	MOCK_e734e220-0e95-4b44-b923-8e1b3cc8cb51	SUCCESS	saveAnnouncement	{"actorName":"周明","applicationName":null,"objectType":"announcement","previousActor":null}	\N
44	\N	\N	\N	\N	\N	P4EV_78c7ffb8-d95d-4902-9424-2077e7374b66	2026-09-18 14:50:13.408+00	2026-09-18 14:50:13.408+00	1	OPERATION	removeAnnouncement	21f5ed07-13c6-4793-9b5d-5a722cba31be	P4FIX_ADMIN	USER	\N	announcement	MOCK_e734e220-0e95-4b44-b923-8e1b3cc8cb51	SUCCESS	removeAnnouncement	{"actorName":"周明","applicationName":null,"objectType":"announcement","previousActor":null}	\N
45	\N	\N	\N	\N	\N	P4EV_ea31deed-fdd6-45e1-bf3e-dc38fc565da1	2026-09-18 14:50:14.762+00	2026-09-18 14:50:14.762+00	1	OPERATION	saveIntegration	3b88ff42-06a7-4186-9260-e98cc2c97836	P4FIX_ADMIN	USER	P4FIX_APP_1	application	MOCK_INT_MOCK_APP_1TODO	SUCCESS	saveIntegration	{"actorName":"周明","applicationName":"福建省新生儿疾病筛查管理系统","objectType":"application","previousActor":null}	\N
46	\N	\N	\N	\N	\N	P4EV_6f63477e-2ac9-4394-a2a1-aca8ec5f4ad0	2026-09-18 14:50:15.466+00	2026-09-18 14:50:15.466+00	1	LOGIN	LOGOUT	1eb4584a-30f8-49ef-8a8d-dccb448e0c71	P4FIX_ADMIN	USER	\N	portal	\N	SUCCESS	LOGOUT	{"actorName":"周明","applicationName":null,"objectType":"portal","previousActor":null}	\N
47	\N	\N	\N	\N	\N	P4EV_97b33f3f-4539-4cba-9e05-6a280a13746b	2026-09-18 14:50:38.363+00	2026-09-18 14:50:38.363+00	1	LOGIN	SWITCH_USER	0f943424-0eda-45a1-8a87-30059c9ded38	P4FIX_ADMIN	USER	\N	portal	\N	SUCCESS	SWITCH_USER	{"actorName":"周明","applicationName":null,"objectType":"portal","previousActor":"MOCK_USER_1"}	\N
48	\N	\N	\N	\N	\N	P4EV_a7e35512-235f-4d27-aab8-e8574d3b3a8a	2026-09-18 14:58:02.181+00	2026-09-18 14:58:02.181+00	1	LOGIN	SWITCH_USER	a40768ba-784d-45e9-a955-5f153a286b3a	P4FIX_USER_2	USER	\N	portal	\N	SUCCESS	SWITCH_USER	{"actorName":"陈宁","applicationName":null,"objectType":"portal","previousActor":"MOCK_ADMIN"}	\N
49	\N	\N	\N	\N	\N	P4EV_fa3d4f3e-09ec-4798-a816-7e91caa12de5	2026-09-18 14:58:20.08+00	2026-09-18 14:58:20.08+00	1	LOGIN	SWITCH_USER	81734cbe-fbba-4e7c-bf62-cc4ffcfd48ce	P4FIX_USER_1	USER	\N	portal	\N	SUCCESS	SWITCH_USER	{"actorName":"林晓","applicationName":null,"objectType":"portal","previousActor":"MOCK_USER_2"}	\N
50	\N	\N	\N	\N	\N	P4EV_624f08cb-a516-435b-8724-d10c9f5a44e0	2026-09-18 15:05:14.893+00	2026-09-18 15:05:14.893+00	1	OPERATION	markRead	004eefb8-1aff-4faf-9f01-f1dbee7a304e	P4FIX_USER_1	USER	\N	portal	MOCK_MSG_0_3	SUCCESS	markRead	{"actorName":"林晓","applicationName":null,"objectType":"portal","previousActor":null}	\N
51	\N	\N	\N	\N	\N	P4EV_423c145a-6166-4aaf-8160-3fd7dc4b51b3	2026-09-18 15:06:02.551+00	2026-09-18 15:06:02.551+00	1	OPERATION	markAnnouncementRead	b750458c-10ca-4045-a385-22c059bb8a7a	P4FIX_USER_1	USER	\N	announcement	MOCK_ANN_3	SUCCESS	markAnnouncementRead	{"actorName":"林晓","applicationName":null,"objectType":"announcement","previousActor":null}	\N
52	\N	\N	\N	\N	\N	P4EV_403a1c9c-2999-4217-aca8-c0ebab909930	2026-09-18 15:09:39.334+00	2026-09-18 15:09:39.334+00	1	LOGIN	SWITCH_USER	fcdd4c08-f0ec-4d83-98fd-d045416d98d2	P4FIX_USER_2	USER	\N	portal	\N	SUCCESS	SWITCH_USER	{"actorName":"陈宁","applicationName":null,"objectType":"portal","previousActor":"MOCK_USER_1"}	\N
53	\N	\N	\N	\N	\N	P4EV_d058b15a-ea15-48b5-9c10-f07905f4db61	2026-09-18 15:10:47.37+00	2026-09-18 15:10:47.37+00	1	ACCESS	enterApp	7dffe031-6636-40aa-9f4c-fd0ee979bbda	P4FIX_USER_2	USER	P4FIX_APP_6	application	MOCK_APP_6	SUCCESS	enterApp	{"actorName":"陈宁","applicationName":"福建省区域影像平台","objectType":"application","previousActor":null}	\N
54	\N	\N	\N	\N	\N	P4EV_90c241c8-fd08-4ee9-af6a-732c8ca6b4c3	2026-09-18 15:12:52.799+00	2026-09-18 15:12:52.799+00	1	LOGIN	SWITCH_USER	1551d763-366b-4ab7-ac9e-ef019426da90	P4FIX_USER_1	USER	\N	portal	\N	SUCCESS	SWITCH_USER	{"actorName":"林晓","applicationName":null,"objectType":"portal","previousActor":"MOCK_USER_2"}	\N
55	\N	\N	\N	\N	\N	P4EV_479a1f46-381f-4dd3-aa15-e56382122028	2026-09-18 15:12:56.182+00	2026-09-18 15:12:56.182+00	1	LOGIN	SWITCH_USER	5aa4c90b-d90f-4d25-be32-48903c4941f5	P4FIX_ADMIN	USER	\N	portal	\N	SUCCESS	SWITCH_USER	{"actorName":"周明","applicationName":null,"objectType":"portal","previousActor":"MOCK_USER_1"}	\N
56	\N	\N	\N	\N	\N	P4EV_a987d19d-a255-459d-a559-5db822076702	2026-09-18 15:13:03.486+00	2026-09-18 15:13:03.486+00	1	LOGIN	SWITCH_USER	914f7c3a-378e-4f90-b926-4ad4e183a401	P4FIX_USER_1	USER	\N	portal	\N	SUCCESS	SWITCH_USER	{"actorName":"林晓","applicationName":null,"objectType":"portal","previousActor":"MOCK_ADMIN"}	\N
57	\N	\N	\N	\N	\N	P4EV_7b284ebf-e064-40d8-a0e1-6051a2b0f480	2026-09-18 15:15:56.543+00	2026-09-18 15:15:56.543+00	1	OPERATION	markRead	b76b1212-8230-4664-9d11-dbe02490bb6a	P4FIX_USER_1	USER	\N	portal	MOCK_MSG_0_2	SUCCESS	markRead	{"actorName":"林晓","applicationName":null,"objectType":"portal","previousActor":null}	\N
58	\N	\N	\N	\N	\N	P4EV_6ee924d8-287a-4d27-83db-78579aca07a0	2026-09-18 15:16:22.837+00	2026-09-18 15:16:22.837+00	1	OPERATION	markRead	7851353f-6637-4543-8eb0-a9cdd6e7f61d	P4FIX_USER_1	USER	\N	portal	MOCK_MSG_0_4	SUCCESS	markRead	{"actorName":"林晓","applicationName":null,"objectType":"portal","previousActor":null}	\N
59	\N	\N	\N	\N	\N	P4EV_d98edf15-0efa-4ccd-bc8b-2f7f10666eb4	2026-09-18 15:16:49.863+00	2026-09-18 15:16:49.863+00	1	OPERATION	markAnnouncementRead	a108ae25-bdaa-4a95-b612-08caccad3082	P4FIX_USER_1	USER	\N	announcement	MOCK_ANN_3	SUCCESS	markAnnouncementRead	{"actorName":"林晓","applicationName":null,"objectType":"announcement","previousActor":null}	\N
60	\N	\N	\N	\N	\N	P4EV_53362f9a-ac8a-4fab-a6c7-ad76179642a0	2026-09-18 15:25:15.413+00	2026-09-18 15:25:15.413+00	1	LOGIN	LOGOUT	e0181d99-9bf5-479c-9958-b55479b896a5	P4FIX_USER_1	USER	\N	portal	\N	SUCCESS	LOGOUT	{"actorName":"林晓","applicationName":null,"objectType":"portal","previousActor":null}	\N
61	\N	\N	\N	\N	\N	P4EV_f29bc563-b801-4453-bd8b-1ff46baf3814	2026-09-18 15:25:33.92+00	2026-09-18 15:25:33.92+00	1	LOGIN	LOGIN	a9dc30ae-b1c6-4fc7-b5b0-3ff4ee31fc20	P4FIX_USER_1	USER	\N	portal	\N	SUCCESS	LOGIN	{"actorName":"林晓","applicationName":null,"objectType":"portal","previousActor":null}	\N
62	\N	\N	\N	\N	\N	P4EV_25e7331f-f12e-413b-bf2e-941ba8db5e58	2026-09-18 15:25:42.092+00	2026-09-18 15:25:42.092+00	1	LOGIN	SWITCH_USER	4813bd87-e3da-4071-89ee-748736cab032	P4FIX_ADMIN	USER	\N	portal	\N	SUCCESS	SWITCH_USER	{"actorName":"周明","applicationName":null,"objectType":"portal","previousActor":"MOCK_USER_1"}	\N
63	\N	\N	\N	\N	\N	P4EV_987ce12e-de58-4b76-a0ba-27f973bca099	2026-09-18 15:29:35.964+00	2026-09-18 15:29:35.964+00	1	LOGIN	SWITCH_USER	9e652944-b032-4f0b-9a03-5e8aa4d3f5d9	P4FIX_USER_1	USER	\N	portal	\N	SUCCESS	SWITCH_USER	{"actorName":"林晓","applicationName":null,"objectType":"portal","previousActor":"MOCK_ADMIN"}	\N
64	\N	\N	\N	\N	\N	P4EV_3d2daf20-b605-4094-afb3-3b7f84e827cf	2026-09-18 15:29:41.998+00	2026-09-18 15:29:41.998+00	1	LOGIN	SWITCH_USER	d3856c58-20b9-4101-9f37-a1d04e9e845d	P4FIX_USER_2	USER	\N	portal	\N	SUCCESS	SWITCH_USER	{"actorName":"陈宁","applicationName":null,"objectType":"portal","previousActor":"MOCK_USER_1"}	\N
65	\N	\N	\N	\N	\N	P4EV_bce695bf-e9b6-435c-87c0-879d440411ad	2026-09-18 15:31:44.195+00	2026-09-18 15:31:44.195+00	1	OPERATION	markRead	ceb68d6e-d5a1-4190-b621-0016207f0ad5	P4FIX_USER_2	USER	\N	portal	MOCK_MSG_1_1	SUCCESS	markRead	{"actorName":"陈宁","applicationName":null,"objectType":"portal","previousActor":null}	\N
66	\N	\N	\N	\N	\N	P4EV_b79cae4a-81a1-4ac9-86cc-2b6ca9a9fff0	2026-09-18 15:43:42.46+00	2026-09-18 15:43:42.46+00	1	LOGIN	SWITCH_USER	7848e953-982d-4dfc-abe6-f0cbab6a6ba7	P4FIX_ADMIN	USER	\N	portal	\N	SUCCESS	SWITCH_USER	{"actorName":"周明","applicationName":null,"objectType":"portal","previousActor":"MOCK_USER_2"}	\N
67	\N	\N	\N	\N	\N	P4EV_94ad557c-c821-4a41-9764-0ef0597dbad9	2026-09-18 15:48:12.995+00	2026-09-18 15:48:12.995+00	1	OPERATION	markRead	87f4e208-25ce-43b2-8f7c-f73c589b6443	P4FIX_ADMIN	USER	\N	portal	MOCK_MSG_2_0	SUCCESS	markRead	{"actorName":"周明","applicationName":null,"objectType":"portal","previousActor":null}	\N
68	\N	\N	\N	\N	\N	P4EV_aa15079e-0297-4f1c-98cc-51aab92ac26c	2026-09-18 15:48:33.068+00	2026-09-18 15:48:33.068+00	1	OPERATION	markRead	c955f617-570a-4c1d-9c61-f43ea6599b71	P4FIX_ADMIN	USER	\N	portal	MOCK_MSG_2_1	SUCCESS	markRead	{"actorName":"周明","applicationName":null,"objectType":"portal","previousActor":null}	\N
69	\N	\N	\N	\N	\N	P4EV_f5de39d0-6e4c-4b35-8d6a-c9833a3f91e9	2026-09-18 15:52:59.915+00	2026-09-18 15:52:59.915+00	1	LOGIN	SWITCH_USER	7e425720-5859-4eac-b227-b3c3ec3cceb0	P4FIX_EDITOR	USER	\N	portal	\N	SUCCESS	SWITCH_USER	{"actorName":"郑颖","applicationName":null,"objectType":"portal","previousActor":"MOCK_ADMIN"}	\N
70	\N	\N	\N	\N	\N	P4EV_839202f8-feef-4336-bed2-8c830a369a0b	2026-09-18 15:53:07.075+00	2026-09-18 15:53:07.075+00	1	LOGIN	SWITCH_USER	36a916f5-eed1-45b5-badc-acd4e3db397d	P4FIX_ADMIN	USER	\N	portal	\N	SUCCESS	SWITCH_USER	{"actorName":"周明","applicationName":null,"objectType":"portal","previousActor":"MOCK_EDITOR"}	\N
71	\N	\N	\N	\N	\N	P4EV_493ed5fd-16e7-4944-a78a-94c7bf31b369	2026-09-18 15:53:43.147+00	2026-09-18 15:53:43.147+00	1	OPERATION	DOWNLOAD_CONTRACT	d96b5dd8-f0cf-4d5a-b5df-3a198d39da8b	P4FIX_ADMIN	USER	P4FIX_APP_1	application	\N	SUCCESS	DOWNLOAD_CONTRACT	{"actorName":"周明","applicationName":"福建省新生儿疾病筛查管理系统","objectType":"application","previousActor":null}	\N
72	\N	\N	\N	\N	\N	P4EV_94274933-d53b-4338-8f12-f39aac188442	2026-09-18 15:55:24.295+00	2026-09-18 15:55:24.295+00	1	LOGIN	SWITCH_USER	f81527e2-c0fb-4a6d-98e1-8615acd09e83	P4FIX_USER_1	USER	\N	portal	\N	SUCCESS	SWITCH_USER	{"actorName":"林晓","applicationName":null,"objectType":"portal","previousActor":"MOCK_ADMIN"}	\N
73	\N	\N	\N	\N	\N	P4EV_4a6d1d9e-5125-47c4-9c81-a71e2e5a4c79	2026-09-18 15:56:30.924+00	2026-09-18 15:56:30.924+00	1	LOGIN	SWITCH_USER	9e484d7e-9271-4130-b5db-5ba48224a984	P4FIX_ADMIN	USER	\N	portal	\N	SUCCESS	SWITCH_USER	{"actorName":"周明","applicationName":null,"objectType":"portal","previousActor":"MOCK_USER_1"}	\N
74	\N	\N	\N	\N	\N	P4EV_08e8f1ea-c828-4eef-8251-52abcaf5447c	2026-09-18 15:57:08.381+00	2026-09-18 15:57:08.381+00	1	LOGIN	SWITCH_USER	f4e97673-c0a4-4cae-997f-de887496fcd3	P4FIX_USER_1	USER	\N	portal	\N	SUCCESS	SWITCH_USER	{"actorName":"林晓","applicationName":null,"objectType":"portal","previousActor":"MOCK_ADMIN"}	\N
75	\N	\N	\N	\N	\N	P4EV_6ee3f628-363a-4ba0-a985-b1688d269c2b	2026-09-18 15:58:30.223+00	2026-09-18 15:58:30.223+00	1	OPERATION	markRead	5d5ceaeb-90df-485d-9ccf-e6bddc0e593c	P4FIX_USER_1	USER	\N	portal	MOCK_MSG_0_5	SUCCESS	markRead	{"actorName":"林晓","applicationName":null,"objectType":"portal","previousActor":null}	\N
76	\N	\N	\N	\N	\N	P4EV_4cf34b2a-641f-4c33-9340-75a8b7c53f5a	2026-09-18 16:06:19.229+00	2026-09-18 16:06:19.229+00	1	LOGIN	SWITCH_USER	d7f3058e-c6ab-40bc-ba5d-b3ec3ece5f3d	P4FIX_ADMIN	USER	\N	portal	\N	SUCCESS	SWITCH_USER	{"actorName":"周明","applicationName":null,"objectType":"portal","previousActor":"MOCK_USER_1"}	\N
77	\N	\N	\N	\N	\N	P4EV_cdf842d8-a13c-4fec-bd71-21a6464dac44	2026-09-18 16:12:43.996+00	2026-09-18 16:12:43.996+00	1	OPERATION	markRead	3ae3ad79-992b-4754-9438-1eadf370e191	P4FIX_ADMIN	USER	\N	portal	MOCK_MSG_2_2	SUCCESS	markRead	{"actorName":"周明","applicationName":null,"objectType":"portal","previousActor":null}	\N
78	\N	\N	\N	\N	\N	P4EV_5f6c5a1a-02c5-4dfd-9a73-fd4b374dc7cf	2026-09-18 16:13:40.362+00	2026-09-18 16:13:40.362+00	1	OPERATION	markRead	4c2f0045-0bc6-433f-a92b-bf49db1a0de9	P4FIX_ADMIN	USER	\N	portal	MOCK_MSG_2_3	SUCCESS	markRead	{"actorName":"周明","applicationName":null,"objectType":"portal","previousActor":null}	\N
79	\N	\N	\N	\N	\N	P4EV_c9537b1b-2d34-4387-904d-59a51ab9c906	2026-09-18 16:13:46.076+00	2026-09-18 16:13:46.076+00	1	OPERATION	markAnnouncementRead	064fd7b9-89ec-4908-b748-ab352068b35b	P4FIX_ADMIN	USER	\N	announcement	MOCK_ANN_1	SUCCESS	markAnnouncementRead	{"actorName":"周明","applicationName":null,"objectType":"announcement","previousActor":null}	\N
80	\N	\N	\N	\N	\N	P4EV_fd946ef8-e544-4b64-a7ed-bd2e81af8cf3	2026-09-18 16:19:28.694+00	2026-09-18 16:19:28.694+00	1	LOGIN	SWITCH_USER	2dcb05bd-6f7c-4424-b09d-5ad5463de2c4	P4FIX_USER_2	USER	\N	portal	\N	SUCCESS	SWITCH_USER	{"actorName":"陈宁","applicationName":null,"objectType":"portal","previousActor":"MOCK_ADMIN"}	\N
81	\N	\N	\N	\N	\N	P4EV_93ff3bb2-377b-46ef-8368-3ed7d93787a0	2026-09-18 16:19:31.879+00	2026-09-18 16:19:31.879+00	1	LOGIN	SWITCH_USER	aec7ce29-eaff-4491-9522-f664cc18f3cb	P4FIX_USER_1	USER	\N	portal	\N	SUCCESS	SWITCH_USER	{"actorName":"林晓","applicationName":null,"objectType":"portal","previousActor":"MOCK_USER_2"}	\N
82	\N	\N	\N	\N	\N	P4EV_bc6609fe-0ade-41ab-bb98-766d50cecd2a	2026-09-18 16:26:00.199+00	2026-09-18 16:26:00.199+00	1	LOGIN	SWITCH_USER	c9668489-597d-4814-883d-23232111390c	P4FIX_ADMIN	USER	\N	portal	\N	SUCCESS	SWITCH_USER	{"actorName":"周明","applicationName":null,"objectType":"portal","previousActor":"MOCK_USER_1"}	\N
83	\N	\N	\N	\N	\N	P4EV_b97fa4fd-8269-4116-9be4-b8fbe65476fd	2026-09-18 16:26:57.193+00	2026-09-18 16:26:57.193+00	1	LOGIN	SWITCH_USER	c0e88f40-e161-4492-acf2-4f62064cf3c8	P4FIX_USER_2	USER	\N	portal	\N	SUCCESS	SWITCH_USER	{"actorName":"陈宁","applicationName":null,"objectType":"portal","previousActor":"MOCK_ADMIN"}	\N
84	\N	\N	\N	\N	\N	P4EV_bed116da-361c-40bd-b442-484fb3260409	2026-09-18 16:27:06.301+00	2026-09-18 16:27:06.301+00	1	OPERATION	markRead	2e5f39eb-fbe8-4c69-8662-217740e8815f	P4FIX_USER_2	USER	\N	portal	MOCK_MSG_1_2	SUCCESS	markRead	{"actorName":"陈宁","applicationName":null,"objectType":"portal","previousActor":null}	\N
85	\N	\N	\N	\N	\N	P4EV_837ee1a1-9d74-4483-a325-109eae46fdde	2026-09-18 16:32:04.312+00	2026-09-18 16:32:04.312+00	1	OPERATION	markRead	9599d90d-e45e-4612-8081-0ea1d371e456	P4FIX_USER_2	USER	\N	portal	MOCK_MSG_1_0	SUCCESS	markRead	{"actorName":"陈宁","applicationName":null,"objectType":"portal","previousActor":null}	\N
86	\N	\N	\N	\N	\N	P4EV_2cb9ff1f-95e2-4338-8df2-5903833d1aee	2026-09-18 16:34:53.814+00	2026-09-18 16:34:53.814+00	1	LOGIN	SWITCH_USER	81ab6e1f-8056-48cb-9222-383d45868c48	P4FIX_USER_1	USER	\N	portal	\N	SUCCESS	SWITCH_USER	{"actorName":"林晓","applicationName":null,"objectType":"portal","previousActor":"MOCK_USER_2"}	\N
87	\N	\N	\N	\N	\N	P4EV_9926f060-5a05-4620-af09-12ea5fc3477d	2026-09-18 16:36:12.422+00	2026-09-18 16:36:12.422+00	1	LOGIN	SWITCH_USER	7c012378-8fd3-4e0c-9381-28364160fb0a	P4FIX_USER_2	USER	\N	portal	\N	SUCCESS	SWITCH_USER	{"actorName":"陈宁","applicationName":null,"objectType":"portal","previousActor":"MOCK_USER_1"}	\N
88	\N	\N	\N	\N	\N	P4EV_e19a90d2-6eb8-4b78-8ed9-eb41a5c467ac	2026-09-18 16:38:00.822+00	2026-09-18 16:38:00.822+00	1	LOGIN	SWITCH_USER	5f32bac3-2595-4bd3-857d-63f0e19dcef2	P4FIX_USER_1	USER	\N	portal	\N	SUCCESS	SWITCH_USER	{"actorName":"林晓","applicationName":null,"objectType":"portal","previousActor":"MOCK_USER_2"}	\N
89	\N	\N	\N	\N	\N	P4EV_36c8bb09-f488-4794-ad4e-ffd5b308c59a	2026-09-18 16:38:37.478+00	2026-09-18 16:38:37.478+00	1	LOGIN	SWITCH_USER	dfd646a6-bda6-44c6-aa72-f68d1c0d3fa2	P4FIX_USER_2	USER	\N	portal	\N	SUCCESS	SWITCH_USER	{"actorName":"陈宁","applicationName":null,"objectType":"portal","previousActor":"MOCK_USER_1"}	\N
90	\N	\N	\N	\N	\N	P4EV_f1b15b34-7542-4899-b5ee-6d1136bab88a	2026-09-18 16:38:50.608+00	2026-09-18 16:38:50.608+00	1	LOGIN	SWITCH_USER	3b287dff-7b8b-4ade-80f6-6b2e47c4c930	P4FIX_USER_1	USER	\N	portal	\N	SUCCESS	SWITCH_USER	{"actorName":"林晓","applicationName":null,"objectType":"portal","previousActor":"MOCK_USER_2"}	\N
91	\N	\N	\N	\N	\N	P4EV_088c0a3e-2d8c-4da5-a989-c0af8170769a	2026-09-18 16:44:30.936+00	2026-09-18 16:44:30.936+00	1	LOGIN	SWITCH_USER	0262fcf5-40dd-4e9b-b39f-9eca7cdb5994	P4FIX_ADMIN	USER	\N	portal	\N	SUCCESS	SWITCH_USER	{"actorName":"周明","applicationName":null,"objectType":"portal","previousActor":"MOCK_USER_1"}	\N
92	\N	\N	\N	\N	\N	P4EV_8a4f33e1-42a4-4621-b1d8-c61db0251abd	2026-09-18 17:28:40.53+00	2026-09-18 17:28:40.53+00	1	OPERATION	saveRules	f5ee5d27-163c-47e4-877b-63196a4b0bbb	P4FIX_ADMIN	USER	\N	portal	\N	SUCCESS	saveRules	{"actorName":"周明","applicationName":null,"objectType":"portal","previousActor":null}	\N
93	\N	\N	\N	\N	\N	P4EV_7451a06b-1898-4a96-8607-5ec96bd888cf	2026-09-18 17:34:16.493+00	2026-09-18 17:34:16.493+00	1	LOGIN	SWITCH_USER	c9e66e40-de74-4fbb-8dda-238938739f15	P4FIX_USER_1	USER	\N	portal	\N	SUCCESS	SWITCH_USER	{"actorName":"林晓","applicationName":null,"objectType":"portal","previousActor":"MOCK_ADMIN"}	\N
94	\N	\N	\N	\N	\N	P4EV_d34415ae-058b-475e-ac3d-1d5602700f41	2026-09-18 17:35:16.722+00	2026-09-18 17:35:16.722+00	1	LOGIN	SWITCH_USER	cc102605-c86b-44fa-bbdb-20b542fe2cf4	P4FIX_ADMIN	USER	\N	portal	\N	SUCCESS	SWITCH_USER	{"actorName":"周明","applicationName":null,"objectType":"portal","previousActor":"MOCK_USER_1"}	\N
95	\N	\N	\N	\N	\N	P4EV_8ca75701-f66a-4ecc-afde-1a977454a8ce	2026-09-18 17:54:57.26+00	2026-09-18 17:54:57.26+00	1	LOGIN	SWITCH_USER	f48b3451-0347-4225-b013-745efb9aee59	P4FIX_USER_1	USER	\N	portal	\N	SUCCESS	SWITCH_USER	{"actorName":"林晓","applicationName":null,"objectType":"portal","previousActor":"MOCK_ADMIN"}	\N
96	\N	\N	\N	\N	\N	P4EV_75381c67-d00d-48a8-bc19-421da5cd7d9a	2026-09-18 17:55:24.958+00	2026-09-18 17:55:24.958+00	1	LOGIN	SWITCH_USER	70da5109-e0ac-48c0-94c5-cb684096194c	P4FIX_USER_2	USER	\N	portal	\N	SUCCESS	SWITCH_USER	{"actorName":"陈宁","applicationName":null,"objectType":"portal","previousActor":"MOCK_USER_1"}	\N
97	\N	\N	\N	\N	\N	P4EV_0c4892b4-d0b7-4627-b4db-f80d5688c1b6	2026-09-18 17:55:50.245+00	2026-09-18 17:55:50.245+00	1	LOGIN	SWITCH_USER	8289c524-da13-47bc-826a-22e9372a8c99	P4FIX_ADMIN	USER	\N	portal	\N	SUCCESS	SWITCH_USER	{"actorName":"周明","applicationName":null,"objectType":"portal","previousActor":"MOCK_USER_2"}	\N
98	\N	\N	\N	\N	\N	P4EV_0ebc46f8-07b2-49be-92d9-d23773a3ff79	2026-09-18 17:56:57.759+00	2026-09-18 17:56:57.759+00	1	LOGIN	SWITCH_USER	b160a642-f528-46d7-8ba3-5adf1d2d97cc	P4FIX_EDITOR	USER	\N	portal	\N	SUCCESS	SWITCH_USER	{"actorName":"郑颖","applicationName":null,"objectType":"portal","previousActor":"MOCK_ADMIN"}	\N
99	\N	\N	\N	\N	\N	P4EV_75790399-5c1c-4b4a-bf0a-d896e8286fd6	2026-09-18 17:57:08.27+00	2026-09-18 17:57:08.27+00	1	LOGIN	SWITCH_USER	addd4245-e4b9-4b05-a49b-a0a9e8fc28b6	P4FIX_ADMIN	USER	\N	portal	\N	SUCCESS	SWITCH_USER	{"actorName":"周明","applicationName":null,"objectType":"portal","previousActor":"MOCK_EDITOR"}	\N
100	\N	\N	\N	\N	\N	P4EV_92001071-709f-4fb4-a8cc-b024d451f175	2026-09-18 18:00:21.536+00	2026-09-18 18:00:21.536+00	1	LOGIN	SWITCH_USER	749b06d2-a8d9-47af-84ff-c34852136528	P4FIX_USER_1	USER	\N	portal	\N	SUCCESS	SWITCH_USER	{"actorName":"林晓","applicationName":null,"objectType":"portal","previousActor":"MOCK_ADMIN"}	\N
101	\N	\N	\N	\N	\N	P4SC_AUDIT_SESSION_OPEN	2026-09-19 01:00:00+00	2026-09-19 01:00:00+00	1	LOGIN	SESSION_OPEN	P4SC_REQUEST_SESSION_OPEN	P4FIX_USER_1	USER	P4FIX_APP_1	application	MOCK_APP_1	SUCCESS	建立门户会话	{"dataSource":"FIXTURE","actorName":"林晓","applicationName":"福建省新生儿疾病筛查管理系统","scenario":"SESSION_OPEN","realExternalCall":false}	\N
102	\N	\N	\N	\N	\N	P4SC_AUDIT_SESSION_EXPIRED	2026-09-19 01:00:00+00	2026-09-19 01:00:00+00	1	LOGIN	SESSION_EXPIRED	P4SC_REQUEST_SESSION_EXPIRED	P4FIX_USER_1	USER	P4FIX_APP_2	application	MOCK_APP_2	FAILURE	会话已过期	{"dataSource":"FIXTURE","actorName":"林晓","applicationName":"福建省妇幼卫生信息系统","scenario":"SESSION_EXPIRED","realExternalCall":false}	\N
103	\N	\N	\N	\N	\N	P4SC_AUDIT_IDENTITY_ACCEPTED	2026-09-19 01:00:00+00	2026-09-19 01:00:00+00	1	AUTH	IDENTITY_ACCEPTED	P4SC_REQUEST_IDENTITY_ACCEPTED	P4FIX_USER_1	USER	P4FIX_APP_3	application	MOCK_APP_3	SUCCESS	闽政通身份已识别	{"dataSource":"FIXTURE","actorName":"林晓","applicationName":"福建省产前筛查与诊断管理系统","scenario":"IDENTITY_ACCEPTED","realExternalCall":false}	\N
104	\N	\N	\N	\N	\N	P4SC_AUDIT_SCOPE_DENIED	2026-09-19 01:00:00+00	2026-09-19 01:00:00+00	1	AUTH	SCOPE_DENIED	P4SC_REQUEST_SCOPE_DENIED	P4FIX_USER_1	USER	P4FIX_APP_4	application	MOCK_APP_4	DENIED	闽政务专属应用访问被拒绝	{"dataSource":"FIXTURE","actorName":"林晓","applicationName":"福建省地中海贫血信息管理系统","scenario":"SCOPE_DENIED","realExternalCall":false}	\N
105	\N	\N	\N	\N	\N	P4SC_AUDIT_APP_ENTRY	2026-09-19 01:00:00+00	2026-09-19 01:00:00+00	1	ACCESS	APP_ENTRY	P4SC_REQUEST_APP_ENTRY	P4FIX_USER_1	USER	P4FIX_APP_5	application	MOCK_APP_5	SUCCESS	应用入口请求已受理	{"dataSource":"FIXTURE","actorName":"林晓","applicationName":"福建省慢病报告与管理系统","scenario":"APP_ENTRY","realExternalCall":false}	\N
128	\N	\N	\N	\N	\N	P4EV_ae0af2bd-210b-49d6-b6af-0813fb0acc55	2026-09-19 12:21:31.999+00	2026-09-19 12:21:31.999+00	1	LOGIN	SWITCH_USER	3f1cd03e-ec9f-44c7-b956-735bc001840d	P4FIX_USER_2	USER	\N	portal	\N	SUCCESS	SWITCH_USER	{"actorName":"陈宁","applicationName":null,"objectType":"portal","previousActor":"MOCK_USER_1","objectIds":[],"accessOutcome":null}	\N
106	\N	\N	\N	\N	\N	P4SC_AUDIT_APP_DISABLED	2026-09-19 01:00:00+00	2026-09-19 01:00:00+00	1	ACCESS	APP_DISABLED	P4SC_REQUEST_APP_DISABLED	P4FIX_USER_1	USER	P4FIX_APP_6	application	MOCK_APP_6	FAILURE	应用已停用，未发起访问	{"dataSource":"FIXTURE","actorName":"林晓","applicationName":"福建省区域影像平台","scenario":"APP_DISABLED","realExternalCall":false}	\N
107	\N	\N	\N	\N	\N	P4SC_AUDIT_CONFIG_SAVED	2026-09-19 01:00:00+00	2026-09-19 01:00:00+00	1	OPERATION	CONFIG_SAVED	P4SC_REQUEST_CONFIG_SAVED	P4FIX_USER_1	USER	P4FIX_APP_11	application	MOCK_APP_11	SUCCESS	接入参数保存	{"dataSource":"FIXTURE","actorName":"林晓","applicationName":"福建省免疫规划管理信息系统","scenario":"CONFIG_SAVED","realExternalCall":false}	\N
108	\N	\N	\N	\N	\N	P4SC_AUDIT_VERSION_CONFLICT	2026-09-19 01:00:00+00	2026-09-19 01:00:00+00	1	OPERATION	VERSION_CONFLICT	P4SC_REQUEST_VERSION_CONFLICT	P4FIX_USER_1	USER	P4FIX_APP_12	application	MOCK_APP_12	FAILURE	配置版本冲突，未覆盖修改	{"dataSource":"FIXTURE","actorName":"林晓","applicationName":"中医馆健康信息系统","scenario":"VERSION_CONFLICT","realExternalCall":false}	\N
109	\N	\N	\N	\N	\N	P4SC_AUDIT_PUSH_APPLIED	2026-09-19 01:00:00+00	2026-09-19 01:00:00+00	1	API	PUSH_APPLIED	P4SC_REQUEST_PUSH_APPLIED	P4FIX_USER_2	USER	P4FIX_APP_1	application	MOCK_APP_1	SUCCESS	接收待办事件	{"dataSource":"FIXTURE","actorName":"陈宁","applicationName":"福建省新生儿疾病筛查管理系统","scenario":"PUSH_APPLIED","realExternalCall":false}	\N
110	\N	\N	\N	\N	\N	P4SC_AUDIT_PUSH_DUPLICATE	2026-09-19 01:00:00+00	2026-09-19 01:00:00+00	1	API	PUSH_DUPLICATE	P4SC_REQUEST_PUSH_DUPLICATE	P4FIX_USER_2	USER	P4FIX_APP_2	application	MOCK_APP_2	SUCCESS	重复事件返回原处理结果	{"dataSource":"FIXTURE","actorName":"陈宁","applicationName":"福建省妇幼卫生信息系统","scenario":"PUSH_DUPLICATE","realExternalCall":false}	\N
111	\N	\N	\N	\N	\N	P4SC_AUDIT_INVALID_CREDENTIAL	2026-09-19 01:00:00+00	2026-09-19 01:00:00+00	1	API	INVALID_CREDENTIAL	P4SC_REQUEST_INVALID_CREDENTIAL	P4FIX_USER_2	USER	P4FIX_APP_3	application	MOCK_APP_3	DENIED	接入凭据不匹配	{"dataSource":"FIXTURE","actorName":"陈宁","applicationName":"福建省产前筛查与诊断管理系统","scenario":"INVALID_CREDENTIAL","realExternalCall":false}	\N
112	\N	\N	\N	\N	\N	P4SC_AUDIT_UPSTREAM_TIMEOUT	2026-09-19 01:00:00+00	2026-09-19 01:00:00+00	1	ERROR	UPSTREAM_TIMEOUT	P4SC_REQUEST_UPSTREAM_TIMEOUT	P4FIX_USER_2	USER	P4FIX_APP_4	application	MOCK_APP_4	FAILURE	来源连接超时	{"dataSource":"FIXTURE","actorName":"陈宁","applicationName":"福建省地中海贫血信息管理系统","scenario":"UPSTREAM_TIMEOUT","realExternalCall":false}	\N
113	\N	\N	\N	\N	\N	P4EV_3b95d27f-49a0-44cc-a9d5-1e680126768f	2026-09-19 11:12:45.421+00	2026-09-19 11:12:45.421+00	1	LOGIN	LOGIN	6837ffae-dc59-4f09-b0b6-2b79fd9be089	P4FIX_USER_1	USER	\N	portal	\N	SUCCESS	LOGIN	{"actorName":"林晓","applicationName":null,"objectType":"portal","previousActor":null,"objectIds":[],"accessOutcome":null}	\N
114	\N	\N	\N	\N	\N	P4EV_7776a34c-a243-4230-9c9b-e75652caee0e	2026-09-19 11:14:29.918+00	2026-09-19 11:14:29.918+00	1	LOGIN	SWITCH_USER	d69aa763-ca45-4b23-8bd8-a4bd88c4f306	P4FIX_ADMIN	USER	\N	portal	\N	SUCCESS	SWITCH_USER	{"actorName":"周明","applicationName":null,"objectType":"portal","previousActor":"MOCK_USER_1","objectIds":[],"accessOutcome":null}	\N
115	\N	\N	\N	\N	\N	P4EV_c647a9e8-8d1e-4378-af05-ae62f0094f7c	2026-09-19 11:15:15.566+00	2026-09-19 11:15:15.566+00	1	LOGIN	LOGIN	aa7fec3b-e441-418d-938f-65ddb9cd74fb	P4FIX_USER_1	USER	\N	portal	\N	SUCCESS	LOGIN	{"actorName":"林晓","applicationName":null,"objectType":"portal","previousActor":null,"objectIds":[],"accessOutcome":null}	\N
116	\N	\N	\N	\N	\N	P4EV_0f8144e3-427b-4c1a-aa3f-639129accc54	2026-09-19 11:15:48.136+00	2026-09-19 11:15:48.136+00	1	LOGIN	SWITCH_USER	cd0a410c-049d-4157-b862-79a7365fce4c	P4FIX_USER_2	USER	\N	portal	\N	SUCCESS	SWITCH_USER	{"actorName":"陈宁","applicationName":null,"objectType":"portal","previousActor":"MOCK_USER_1","objectIds":[],"accessOutcome":null}	\N
117	\N	\N	\N	\N	\N	P4EV_8f9e3538-0f66-4d51-9b6b-176c4c58b9d5	2026-09-19 11:16:03.612+00	2026-09-19 11:16:03.612+00	1	LOGIN	SWITCH_USER	f29e5ae0-4507-4fe1-9ad8-9e7246af4f98	P4FIX_ADMIN	USER	\N	portal	\N	SUCCESS	SWITCH_USER	{"actorName":"周明","applicationName":null,"objectType":"portal","previousActor":"MOCK_USER_2","objectIds":[],"accessOutcome":null}	\N
118	\N	\N	\N	\N	\N	P4EV_c85ae775-b641-427d-8834-f0e972ed7355	2026-09-19 11:16:27.077+00	2026-09-19 11:16:27.077+00	1	OPERATION	markRead	9909f864-6d60-4ca5-b4d6-f0e8e825d4dc	P4FIX_ADMIN	USER	P4FIX_APP_5	application	MOCK_MSG_2_4	SUCCESS	markRead	{"actorName":"周明","applicationName":"福建省慢病报告与管理系统","objectType":"application","previousActor":null,"objectIds":[],"accessOutcome":null}	\N
119	\N	\N	\N	\N	\N	P4EV_9bc317eb-4891-44e2-b46c-e871833d6050	2026-09-19 11:16:53.829+00	2026-09-19 11:16:53.829+00	1	OPERATION	markAnnouncementRead	5dab5039-8724-4021-a2a4-b70e647791c1	P4FIX_ADMIN	USER	\N	announcement	MOCK_ANN_8	SUCCESS	markAnnouncementRead	{"actorName":"周明","applicationName":null,"objectType":"announcement","previousActor":null,"objectIds":[],"accessOutcome":null}	\N
120	\N	\N	\N	\N	\N	P4EV_760500f4-f07a-4d8c-b105-e553da981cfb	2026-09-19 11:50:54.21+00	2026-09-19 11:50:54.21+00	1	ERROR	saveIntegration	3fba9843-ba86-4585-baa4-f17e4527328b	P4FIX_ADMIN	USER	P4FIX_APP_3	application	MOCK_INT_MOCK_APP_3TODO	FAILURE	启用接入需配置服务端凭据引用	{"actorName":"周明","applicationName":"福建省产前筛查与诊断管理系统","objectType":"application","previousActor":null,"objectIds":[],"accessOutcome":null}	\N
121	\N	\N	\N	\N	\N	P4EV_e6443d46-22f3-4b91-8f13-06d5096c87b2	2026-09-19 12:02:04.187+00	2026-09-19 12:02:04.187+00	1	LOGIN	LOGOUT	48bb1862-01b5-4449-b00b-a14d0fd50d96	P4FIX_ADMIN	USER	\N	portal	\N	SUCCESS	LOGOUT	{"actorName":"周明","applicationName":null,"objectType":"portal","previousActor":null,"objectIds":[],"accessOutcome":null}	\N
122	\N	\N	\N	\N	\N	P4EV_9df90602-3eda-49d6-acc9-240f929572e5	2026-09-19 12:02:17.819+00	2026-09-19 12:02:17.819+00	1	LOGIN	LOGIN	7096de8b-4dc1-4b2b-944b-e2e02802f673	P4FIX_USER_1	USER	\N	portal	\N	SUCCESS	LOGIN	{"actorName":"林晓","applicationName":null,"objectType":"portal","previousActor":null,"objectIds":[],"accessOutcome":null}	\N
123	\N	\N	\N	\N	\N	P4EV_54e1ad6e-32f0-4c33-9720-556bf58d4728	2026-09-19 12:02:30.338+00	2026-09-19 12:02:30.338+00	1	LOGIN	SWITCH_USER	835ad9c7-c664-427d-b449-70dafa4403b3	P4FIX_USER_2	USER	\N	portal	\N	SUCCESS	SWITCH_USER	{"actorName":"陈宁","applicationName":null,"objectType":"portal","previousActor":"MOCK_USER_1","objectIds":[],"accessOutcome":null}	\N
124	\N	\N	\N	\N	\N	P4EV_572c1aed-7920-4e44-9fa8-3be7c9d16f63	2026-09-19 12:02:51.196+00	2026-09-19 12:02:51.196+00	1	LOGIN	SWITCH_USER	745a6e95-2c46-4f3a-8457-1c9242432043	P4FIX_ADMIN	USER	\N	portal	\N	SUCCESS	SWITCH_USER	{"actorName":"周明","applicationName":null,"objectType":"portal","previousActor":"MOCK_USER_2","objectIds":[],"accessOutcome":null}	\N
125	\N	\N	\N	\N	\N	P4EV_940c74e2-13d8-4bd5-b5d8-d45314a11dc6	2026-09-19 12:03:22.84+00	2026-09-19 12:03:22.84+00	1	LOGIN	SWITCH_USER	b22592b1-7435-4105-81ad-346610454c34	P4FIX_USER_1	USER	\N	portal	\N	SUCCESS	SWITCH_USER	{"actorName":"林晓","applicationName":null,"objectType":"portal","previousActor":"MOCK_ADMIN","objectIds":[],"accessOutcome":null}	\N
126	\N	\N	\N	\N	\N	P4EV_21b5e63a-809e-410f-9198-621dd6af2263	2026-09-19 12:03:41.499+00	2026-09-19 12:03:41.499+00	1	LOGIN	SWITCH_USER	849f0968-82a0-4967-8f39-178d985c6b4e	P4FIX_ADMIN	USER	\N	portal	\N	SUCCESS	SWITCH_USER	{"actorName":"周明","applicationName":null,"objectType":"portal","previousActor":"MOCK_USER_1","objectIds":[],"accessOutcome":null}	\N
127	\N	\N	\N	\N	\N	P4EV_c92c2c08-e464-416e-adc9-d4e3e8b2f99d	2026-09-19 12:15:38.956+00	2026-09-19 12:15:38.956+00	1	LOGIN	SWITCH_USER	734a1a2b-52e8-41f6-9a86-ca4fdadd957d	P4FIX_USER_1	USER	\N	portal	\N	SUCCESS	SWITCH_USER	{"actorName":"林晓","applicationName":null,"objectType":"portal","previousActor":"MOCK_ADMIN","objectIds":[],"accessOutcome":null}	\N
129	\N	\N	\N	\N	\N	P4EV_0bbeaea4-8d02-4c6a-abd1-969c05a456cb	2026-09-19 12:21:35.417+00	2026-09-19 12:21:35.417+00	1	LOGIN	SWITCH_USER	fe8a77e5-979d-47f9-b27b-a83404326d07	P4FIX_ADMIN	USER	\N	portal	\N	SUCCESS	SWITCH_USER	{"actorName":"周明","applicationName":null,"objectType":"portal","previousActor":"MOCK_USER_2","objectIds":[],"accessOutcome":null}	\N
130	\N	\N	\N	\N	\N	P4EV_64ad353c-324b-4eaa-ac26-6ebc45252077	2026-09-19 12:24:49.192+00	2026-09-19 12:24:49.192+00	1	LOGIN	SWITCH_USER	841537f3-b889-4d45-b2ed-b8e96a6c1e73	P4FIX_EDITOR	USER	\N	portal	\N	SUCCESS	SWITCH_USER	{"actorName":"郑颖","applicationName":null,"objectType":"portal","previousActor":"MOCK_ADMIN","objectIds":[],"accessOutcome":null}	\N
131	\N	\N	\N	\N	\N	P4EV_29c513d2-d137-4ae5-9951-2939e1d7cd82	2026-09-19 12:24:54.88+00	2026-09-19 12:24:54.88+00	1	LOGIN	SWITCH_USER	b5d07d71-d489-45bb-873f-0ef229e424ec	P4FIX_ADMIN	USER	\N	portal	\N	SUCCESS	SWITCH_USER	{"actorName":"周明","applicationName":null,"objectType":"portal","previousActor":"MOCK_EDITOR","objectIds":[],"accessOutcome":null}	\N
132	\N	\N	\N	\N	\N	P4EV_d9808401-597e-4f08-b59b-18902630f530	2026-09-19 12:56:48.4+00	2026-09-19 12:56:48.4+00	1	OPERATION	markRead	786da0c2-f6c9-4ae6-a8f7-6716f6b0b446	P4FIX_ADMIN	USER	P4FIX_APP_6	application	MOCK_MSG_2_5	SUCCESS	markRead	{"actorName":"周明","applicationName":"福建省区域影像平台","objectType":"application","previousActor":null,"objectIds":[],"accessOutcome":null}	\N
133	\N	\N	\N	\N	\N	P4EV_ab05b453-2017-4dae-ac76-4744ff784fbb	2026-09-19 12:56:57.467+00	2026-09-19 12:56:57.467+00	1	OPERATION	markAnnouncementRead	4daf1600-47bf-4e28-99ce-7c63c6bb660a	P4FIX_ADMIN	USER	\N	announcement	MOCK_ANN_4	SUCCESS	markAnnouncementRead	{"actorName":"周明","applicationName":null,"objectType":"announcement","previousActor":null,"objectIds":[],"accessOutcome":null}	\N
134	\N	\N	\N	\N	\N	P4EV_1b265db9-e69f-4466-a552-67463aa2f262	2026-09-19 13:03:07.429+00	2026-09-19 13:03:07.429+00	1	LOGIN	LOGOUT	a1b90735-0d68-42ba-8de2-9dda27151f31	P4FIX_ADMIN	USER	\N	portal	\N	SUCCESS	LOGOUT	{"actorName":"周明","applicationName":null,"objectType":"portal","previousActor":null,"objectIds":[],"accessOutcome":null}	\N
135	\N	\N	\N	\N	\N	P4EV_cf83015e-6994-4e7f-9928-4397fb000915	2026-09-19 13:04:30.415+00	2026-09-19 13:04:30.415+00	1	LOGIN	LOGIN	9f6d570b-b8ed-44db-beaf-c27fc3a63f54	P4FIX_USER_1	USER	\N	portal	\N	SUCCESS	LOGIN	{"actorName":"林晓","applicationName":null,"objectType":"portal","previousActor":null,"objectIds":[],"accessOutcome":null}	\N
136	\N	\N	\N	\N	\N	P4EV_d19ab288-0cd9-4bf9-b1fa-bda7eafa86ff	2026-09-19 13:04:47.791+00	2026-09-19 13:04:47.791+00	1	LOGIN	SWITCH_USER	20d72c69-abc4-4f24-9c16-35a3592c4f14	P4FIX_ADMIN	USER	\N	portal	\N	SUCCESS	SWITCH_USER	{"actorName":"周明","applicationName":null,"objectType":"portal","previousActor":"MOCK_USER_1","objectIds":[],"accessOutcome":null}	\N
137	\N	\N	\N	\N	\N	P4EV_8d058844-de0a-4470-9f63-9639b6952480	2026-09-19 13:13:58.022+00	2026-09-19 13:13:58.022+00	1	LOGIN	SWITCH_USER	ac68082b-9710-43f5-a7cc-44c1d51483c5	P4FIX_USER_1	USER	\N	portal	\N	SUCCESS	SWITCH_USER	{"actorName":"林晓","applicationName":null,"objectType":"portal","previousActor":"MOCK_ADMIN","objectIds":[],"accessOutcome":null}	\N
138	\N	\N	\N	\N	\N	P4EV_c7b58e3f-19bd-45e6-aa4f-c9a52d655095	2026-09-19 13:14:34.149+00	2026-09-19 13:14:34.149+00	1	LOGIN	SWITCH_USER	9f3c6eaa-4160-4d8a-92f8-4a6c506fe74e	P4FIX_ADMIN	USER	\N	portal	\N	SUCCESS	SWITCH_USER	{"actorName":"周明","applicationName":null,"objectType":"portal","previousActor":"MOCK_USER_1","objectIds":[],"accessOutcome":null}	\N
139	\N	\N	\N	\N	\N	P4EV_3bf02a15-5708-4a25-87be-ae549ad2ae96	2026-09-19 13:16:16.869+00	2026-09-19 13:16:16.869+00	1	OPERATION	DOWNLOAD_CONTRACT	70125771-2978-4084-a0a8-f7f62a82a3ec	P4FIX_ADMIN	USER	\N	portal	\N	SUCCESS	DOWNLOAD_CONTRACT	{"actorName":"周明","applicationName":null,"objectType":"portal","previousActor":null,"objectIds":[],"accessOutcome":null}	\N
140	\N	\N	\N	\N	\N	P4EV_4e0b5d81-9aa7-4d8b-a7d3-dd8fee0f9c1e	2026-09-20 01:20:16.554+00	2026-09-20 01:20:16.554+00	1	LOGIN	LOGIN	1ae404e5-b009-4de9-a42e-b8f7e6846aee	P4FIX_USER_1	USER	\N	portal	\N	SUCCESS	LOGIN	{"actorName":"林晓","applicationName":null,"objectType":"portal","previousActor":null,"objectIds":[],"accessOutcome":null}	\N
141	\N	\N	\N	\N	\N	P4EV_7a648445-845b-4430-b41e-813fcb4d97f7	2026-09-20 01:20:43.178+00	2026-09-20 01:20:43.178+00	1	LOGIN	SWITCH_USER	bfb0205f-827d-459c-bddf-db3dd44162c5	P4FIX_USER_2	USER	\N	portal	\N	SUCCESS	SWITCH_USER	{"actorName":"陈宁","applicationName":null,"objectType":"portal","previousActor":"MOCK_USER_1","objectIds":[],"accessOutcome":null}	\N
142	\N	\N	\N	\N	\N	P4EV_96d92c78-5be1-4a5a-90ef-1ab0953e4a3e	2026-09-20 01:21:13.354+00	2026-09-20 01:21:13.354+00	1	LOGIN	SWITCH_USER	3e4e3d54-de15-43b9-897c-f4156d7502f2	P4FIX_USER_1	USER	\N	portal	\N	SUCCESS	SWITCH_USER	{"actorName":"林晓","applicationName":null,"objectType":"portal","previousActor":"MOCK_USER_2","objectIds":[],"accessOutcome":null}	\N
143	\N	\N	\N	\N	\N	P4EV_ca4b12c6-33b8-45c6-b3c8-b1923d301103	2026-09-20 03:46:52.643+00	2026-09-20 03:46:52.643+00	1	LOGIN	LOGIN	3a59e729-0432-418e-a2e0-2f4455ceaecf	P4FIX_USER_1	USER	\N	portal	\N	SUCCESS	LOGIN	{"actorName":"林晓","applicationName":null,"objectType":"portal","previousActor":null,"objectIds":[],"accessOutcome":null}	\N
144	\N	\N	\N	\N	\N	P4EV_e267df0b-d477-486a-8268-67c2a5e11e22	2026-09-20 03:47:37.816+00	2026-09-20 03:47:37.816+00	1	LOGIN	SWITCH_USER	b58b4896-9227-413f-87a0-b96744c4ec12	P4FIX_ADMIN	USER	\N	portal	\N	SUCCESS	SWITCH_USER	{"actorName":"周明","applicationName":null,"objectType":"portal","previousActor":"MOCK_USER_1","objectIds":[],"accessOutcome":null}	\N
145	\N	\N	\N	\N	\N	P4EV_82a77b1c-cdd4-42c4-802f-35f0fed607de	2026-09-20 03:48:19.127+00	2026-09-20 03:48:19.127+00	1	LOGIN	SWITCH_USER	1cbe67a1-e21b-4625-8d2d-bc2d1818ac1d	P4FIX_USER_1	USER	\N	portal	\N	SUCCESS	SWITCH_USER	{"actorName":"林晓","applicationName":null,"objectType":"portal","previousActor":"MOCK_ADMIN","objectIds":[],"accessOutcome":null}	\N
146	\N	\N	\N	\N	\N	P4EV_ff5c1e30-700e-48de-96f1-7e0c2f339d73	2026-09-20 03:56:17.917+00	2026-09-20 03:56:17.917+00	1	LOGIN	SWITCH_USER	2240e872-900d-475d-8552-dd683f29de1f	P4FIX_ADMIN	USER	\N	portal	\N	SUCCESS	SWITCH_USER	{"actorName":"周明","applicationName":null,"objectType":"portal","previousActor":"MOCK_USER_1","objectIds":[],"accessOutcome":null}	\N
147	\N	\N	\N	\N	\N	P4EV_80dc1392-c6b4-47fb-83ec-fb456ac044f3	2026-09-20 03:57:24.474+00	2026-09-20 03:57:24.474+00	1	LOGIN	SWITCH_USER	901625e8-8681-4df0-afd6-c5b034b9694b	P4FIX_USER_1	USER	\N	portal	\N	SUCCESS	SWITCH_USER	{"actorName":"林晓","applicationName":null,"objectType":"portal","previousActor":"MOCK_ADMIN","objectIds":[],"accessOutcome":null}	\N
148	\N	\N	\N	\N	\N	P4EV_83d6d2c8-b197-4f4d-89a8-ba5ac2e1c507	2026-09-20 03:57:29.103+00	2026-09-20 03:57:29.103+00	1	LOGIN	SWITCH_USER	5c4e4b79-4cc5-4386-9016-098f483fd6dd	P4FIX_USER_2	USER	\N	portal	\N	SUCCESS	SWITCH_USER	{"actorName":"陈宁","applicationName":null,"objectType":"portal","previousActor":"MOCK_USER_1","objectIds":[],"accessOutcome":null}	\N
149	\N	\N	\N	\N	\N	P4EV_afe72496-ed26-47ca-a4a0-06209f716de9	2026-09-20 04:31:44.798+00	2026-09-20 04:31:44.798+00	1	LOGIN	SWITCH_USER	467a412c-5ddc-46b3-aad4-6beceefcbce7	P4FIX_USER_1	USER	\N	portal	\N	SUCCESS	SWITCH_USER	{"actorName":"林晓","applicationName":null,"objectType":"portal","previousActor":"MOCK_USER_2","objectIds":[],"accessOutcome":null}	\N
150	\N	\N	\N	\N	\N	P4EV_1417cd13-9d4b-4ecd-8d80-49a07876b913	2026-09-20 04:31:47.957+00	2026-09-20 04:31:47.957+00	1	LOGIN	SWITCH_USER	79033721-aa46-4beb-8b85-f895e0f3344d	P4FIX_ADMIN	USER	\N	portal	\N	SUCCESS	SWITCH_USER	{"actorName":"周明","applicationName":null,"objectType":"portal","previousActor":"MOCK_USER_1","objectIds":[],"accessOutcome":null}	\N
151	\N	\N	\N	\N	\N	P4EV_c26c4b02-0099-48d5-a00e-279da5442ae0	2026-09-20 04:32:32.472+00	2026-09-20 04:32:32.472+00	1	LOGIN	LOGOUT	4f28cfe3-c029-4a3c-a124-fd55296176b6	P4FIX_ADMIN	USER	\N	portal	\N	SUCCESS	LOGOUT	{"actorName":"周明","applicationName":null,"objectType":"portal","previousActor":null,"objectIds":[],"accessOutcome":null}	\N
152	\N	\N	\N	\N	\N	P4EV_4623d1d1-f5a4-4182-8738-cc739c59f018	2026-09-20 04:35:06.61+00	2026-09-20 04:35:06.61+00	1	LOGIN	LOGIN	b48dd6bc-d58f-4d5e-b7d5-92ad8c3a50b2	P4FIX_USER_2	USER	\N	portal	\N	SUCCESS	LOGIN	{"actorName":"陈宁","applicationName":null,"objectType":"portal","previousActor":null,"objectIds":[],"accessOutcome":null}	\N
153	\N	\N	\N	\N	\N	P4EV_1f127e7c-7e6a-4c2c-910c-b530d1c2f730	2026-09-20 04:35:12.583+00	2026-09-20 04:35:12.583+00	1	LOGIN	SWITCH_USER	9935c30d-617a-4793-ac26-f57780f2339f	P4FIX_ADMIN	USER	\N	portal	\N	SUCCESS	SWITCH_USER	{"actorName":"周明","applicationName":null,"objectType":"portal","previousActor":"MOCK_USER_2","objectIds":[],"accessOutcome":null}	\N
154	\N	\N	\N	\N	\N	P4EV_37d54a27-2732-42ef-8d7f-7f7f30e2d418	2026-09-20 04:36:55.994+00	2026-09-20 04:36:55.994+00	1	LOGIN	LOGOUT	a9f920b3-00e2-4824-9465-26965555a1f2	P4FIX_ADMIN	USER	\N	portal	\N	SUCCESS	LOGOUT	{"actorName":"周明","applicationName":null,"objectType":"portal","previousActor":null,"objectIds":[],"accessOutcome":null}	\N
155	\N	\N	\N	\N	\N	P4EV_3f9c49cc-55ef-4e80-b0d4-56e1f673d222	2026-09-20 04:37:29.542+00	2026-09-20 04:37:29.542+00	1	LOGIN	LOGIN	bd7f317c-7332-49a3-aea4-c9337df85cbf	P4FIX_USER_1	USER	\N	portal	\N	SUCCESS	LOGIN	{"actorName":"林晓","applicationName":null,"objectType":"portal","previousActor":null,"objectIds":[],"accessOutcome":null}	\N
156	\N	\N	\N	\N	\N	P4EV_b12548f6-66c2-48b7-ba59-efeb0f5ae18a	2026-09-20 06:35:17.445+00	2026-09-20 06:35:17.445+00	1	LOGIN	SWITCH_USER	e1ef7296-5a0a-4a92-b74e-6cba99f0e996	P4FIX_USER_2	USER	\N	portal	\N	SUCCESS	SWITCH_USER	{"actorName":"陈宁","applicationName":null,"objectType":"portal","previousActor":"MOCK_USER_1","objectIds":[],"accessOutcome":null}	\N
157	\N	\N	\N	\N	\N	P4EV_fa9af628-19d0-4fda-ba33-eecc2a677d2a	2026-09-20 06:35:31.246+00	2026-09-20 06:35:31.246+00	1	LOGIN	SWITCH_USER	7ad7cfd9-d0c9-4ce9-8ad3-7b0c85fead48	P4FIX_USER_1	USER	\N	portal	\N	SUCCESS	SWITCH_USER	{"actorName":"林晓","applicationName":null,"objectType":"portal","previousActor":"MOCK_USER_2","objectIds":[],"accessOutcome":null}	\N
158	\N	\N	\N	\N	\N	P4EV_86e1a7ee-9e21-4bbe-a95e-0af9fa809236	2026-09-20 06:35:47.077+00	2026-09-20 06:35:47.077+00	1	LOGIN	SWITCH_USER	c9a6974c-5136-4d48-add4-c21fdeee0a75	P4FIX_ADMIN	USER	\N	portal	\N	SUCCESS	SWITCH_USER	{"actorName":"周明","applicationName":null,"objectType":"portal","previousActor":"MOCK_USER_1","objectIds":[],"accessOutcome":null}	\N
159	\N	\N	\N	\N	\N	P4EV_ef7853e2-b11c-4960-aeda-41ea14fc6960	2026-09-20 06:43:39.407+00	2026-09-20 06:43:39.407+00	1	LOGIN	SWITCH_USER	3833d046-0e4c-47ce-aaab-8e145d5db46d	P4FIX_USER_1	USER	\N	portal	\N	SUCCESS	SWITCH_USER	{"actorName":"林晓","applicationName":null,"objectType":"portal","previousActor":"MOCK_ADMIN","objectIds":[],"accessOutcome":null}	\N
160	\N	\N	\N	\N	\N	P4EV_35018ed5-61bd-4f24-9a19-54d290f33849	2026-09-20 06:46:13.275+00	2026-09-20 06:46:13.275+00	1	LOGIN	SWITCH_USER	c40d75e2-e5fe-42e2-a203-b51ee969f10d	P4FIX_ADMIN	USER	\N	portal	\N	SUCCESS	SWITCH_USER	{"actorName":"周明","applicationName":null,"objectType":"portal","previousActor":"MOCK_USER_1","objectIds":[],"accessOutcome":null}	\N
161	\N	\N	\N	\N	\N	P4EV_f48824eb-4be9-45b6-80e5-f5cf4460898d	2026-09-20 06:54:31.277+00	2026-09-20 06:54:31.277+00	1	OPERATION	markRead	945e75a3-924b-4230-9d73-534b82700546	P4FIX_ADMIN	USER	P4FIX_APP_7	application	MOCK_MSG_2_6	SUCCESS	markRead	{"actorName":"周明","applicationName":"质控评分系统","objectType":"application","previousActor":null,"objectIds":[],"accessOutcome":null}	\N
162	\N	\N	\N	\N	\N	P4EV_7e4e8386-dc7c-4f52-9fb0-c144cc185fda	2026-09-20 06:57:44.258+00	2026-09-20 06:57:44.258+00	1	LOGIN	SWITCH_USER	7437ba92-dd73-42ea-bc73-a5263adb46c4	P4FIX_EDITOR	USER	\N	portal	\N	SUCCESS	SWITCH_USER	{"actorName":"郑颖","applicationName":null,"objectType":"portal","previousActor":"MOCK_ADMIN","objectIds":[],"accessOutcome":null}	\N
163	\N	\N	\N	\N	\N	P4EV_b054add9-3be9-4291-8651-e446e89b9ffd	2026-09-20 06:57:49.95+00	2026-09-20 06:57:49.95+00	1	LOGIN	SWITCH_USER	458a25fb-0dbc-47d3-af56-a5b19631bade	P4FIX_ADMIN	USER	\N	portal	\N	SUCCESS	SWITCH_USER	{"actorName":"周明","applicationName":null,"objectType":"portal","previousActor":"MOCK_EDITOR","objectIds":[],"accessOutcome":null}	\N
164	\N	\N	\N	\N	\N	P4EV_20df7e98-aa3f-479e-9b75-8f41e68b3229	2026-09-20 06:57:57.992+00	2026-09-20 06:57:57.992+00	1	LOGIN	SWITCH_USER	1e92c281-577a-495b-9728-8fd217f3bee2	P4FIX_EDITOR	USER	\N	portal	\N	SUCCESS	SWITCH_USER	{"actorName":"郑颖","applicationName":null,"objectType":"portal","previousActor":"MOCK_ADMIN","objectIds":[],"accessOutcome":null}	\N
165	\N	\N	\N	\N	\N	P4EV_7e61ecd5-15fc-4a62-ba3c-68b814604d81	2026-09-20 06:58:39.096+00	2026-09-20 06:58:39.096+00	1	OPERATION	markAnnouncementRead	696c0416-e9e1-499c-ad21-343ef4e71718	P4FIX_EDITOR	USER	\N	announcement	MOCK_ANN_1	SUCCESS	markAnnouncementRead	{"actorName":"郑颖","applicationName":null,"objectType":"announcement","previousActor":null,"objectIds":[],"accessOutcome":null}	\N
166	\N	\N	\N	\N	\N	P4EV_fce476ed-3628-4a82-b07a-173915b92c82	2026-09-20 06:59:48.65+00	2026-09-20 06:59:48.65+00	1	LOGIN	SWITCH_USER	504e2a13-28ea-47f5-bc48-6f49924eabc0	P4FIX_USER_1	USER	\N	portal	\N	SUCCESS	SWITCH_USER	{"actorName":"林晓","applicationName":null,"objectType":"portal","previousActor":"MOCK_EDITOR","objectIds":[],"accessOutcome":null}	\N
167	\N	\N	\N	\N	\N	P4EV_3a1f01f6-09ce-49ee-8466-6a580ee29f65	2026-09-20 07:01:33.271+00	2026-09-20 07:01:33.271+00	1	LOGIN	SWITCH_USER	1d0abc8b-9627-4bf0-9325-b6264201de5e	P4FIX_ADMIN	USER	\N	portal	\N	SUCCESS	SWITCH_USER	{"actorName":"周明","applicationName":null,"objectType":"portal","previousActor":"MOCK_USER_1","objectIds":[],"accessOutcome":null}	\N
168	\N	\N	\N	\N	\N	P4EV_6c289790-dfce-4d4c-aea1-caafe08a6fcc	2026-09-20 07:01:51.878+00	2026-09-20 07:01:51.878+00	1	LOGIN	SWITCH_USER	924e083e-2888-4cf7-9676-52fc8a2e1752	P4FIX_EDITOR	USER	\N	portal	\N	SUCCESS	SWITCH_USER	{"actorName":"郑颖","applicationName":null,"objectType":"portal","previousActor":"MOCK_ADMIN","objectIds":[],"accessOutcome":null}	\N
169	\N	\N	\N	\N	\N	P4EV_8b079bdd-296d-44a0-8c66-2772924744d6	2026-09-20 07:02:56.62+00	2026-09-20 07:02:56.62+00	1	LOGIN	SWITCH_USER	559123a7-9576-4b1e-9e14-e1635560ae07	P4FIX_ADMIN	USER	\N	portal	\N	SUCCESS	SWITCH_USER	{"actorName":"周明","applicationName":null,"objectType":"portal","previousActor":"MOCK_EDITOR","objectIds":[],"accessOutcome":null}	\N
170	\N	\N	\N	\N	\N	P4EV_d0ef5ac5-64b6-49a1-b66f-67e1e2a318bf	2026-09-20 07:08:25.979+00	2026-09-20 07:08:25.979+00	1	LOGIN	SWITCH_USER	d1130df9-0410-408b-8dea-57674a4b6902	P4FIX_USER_2	USER	\N	portal	\N	SUCCESS	SWITCH_USER	{"actorName":"陈宁","applicationName":null,"objectType":"portal","previousActor":"MOCK_ADMIN","objectIds":[],"accessOutcome":null}	\N
171	\N	\N	\N	\N	\N	P4EV_3899c665-3e54-4d4d-a763-75c2de5d9049	2026-09-20 07:08:36.058+00	2026-09-20 07:08:36.058+00	1	LOGIN	SWITCH_USER	2ee573af-1571-42f6-a6e2-74a60bd04129	P4FIX_ADMIN	USER	\N	portal	\N	SUCCESS	SWITCH_USER	{"actorName":"周明","applicationName":null,"objectType":"portal","previousActor":"MOCK_USER_2","objectIds":[],"accessOutcome":null}	\N
172	\N	\N	\N	\N	\N	P4EV_93b4b09b-75f1-49ec-97bd-9bdbece86c1b	2026-09-20 07:16:02.915+00	2026-09-20 07:16:02.915+00	1	LOGIN	LOGOUT	2216dc75-5571-40f9-8327-a86d18fa7472	P4FIX_ADMIN	USER	\N	portal	\N	SUCCESS	LOGOUT	{"actorName":"周明","applicationName":null,"objectType":"portal","previousActor":null,"objectIds":[],"accessOutcome":null}	\N
173	\N	\N	\N	\N	\N	P4EV_52d40e0a-5390-48d8-9b45-ae9616d7014b	2026-09-20 07:16:23.059+00	2026-09-20 07:16:23.059+00	1	LOGIN	LOGIN	c3b33874-cc5c-420f-bd62-e8cc25cff786	P4FIX_USER_1	USER	\N	portal	\N	SUCCESS	LOGIN	{"actorName":"林晓","applicationName":null,"objectType":"portal","previousActor":null,"objectIds":[],"accessOutcome":null}	\N
174	\N	\N	\N	\N	\N	P4EV_173bc0ba-43da-415e-bdbc-b83789c7592a	2026-09-20 07:16:29.358+00	2026-09-20 07:16:29.358+00	1	LOGIN	SWITCH_USER	13e4ccd0-19dc-4e5f-927e-4aae307ff6e3	P4FIX_ADMIN	USER	\N	portal	\N	SUCCESS	SWITCH_USER	{"actorName":"周明","applicationName":null,"objectType":"portal","previousActor":"MOCK_USER_1","objectIds":[],"accessOutcome":null}	\N
175	\N	\N	\N	\N	\N	P4EV_edb7c3c2-93a0-4cff-8845-5e5c715f21f6	2026-09-20 07:18:46.862+00	2026-09-20 07:18:46.862+00	1	ERROR	setPortalUserStatus	d0c8eec9-4c4b-49a0-be91-ae9e0f0a0d34	P4FIX_ADMIN	USER	\N	portal	MOCK_USER_1	FAILURE	该动作尚未开放	{"actorName":"周明","applicationName":null,"objectType":"portal","previousActor":null,"objectIds":[],"accessOutcome":null}	\N
176	\N	\N	\N	\N	\N	P4EV_c4c3a4e6-0c3c-45fe-9326-1e795b6cceb6	2026-09-20 07:24:17.461+00	2026-09-20 07:24:17.461+00	1	LOGIN	SWITCH_USER	9bce29ce-945c-4733-a024-1eae9bedf391	P4FIX_USER_1	USER	\N	portal	\N	SUCCESS	SWITCH_USER	{"actorName":"林晓","applicationName":null,"objectType":"portal","previousActor":"MOCK_ADMIN","objectIds":[],"accessOutcome":null}	\N
177	\N	\N	\N	\N	\N	P4EV_489ba699-8a85-4ec2-993b-f309cddd0791	2026-09-20 07:24:26.063+00	2026-09-20 07:24:26.063+00	1	LOGIN	SWITCH_USER	0fcc6bc2-3f26-4f57-b82e-562fddd31c13	P4FIX_ADMIN	USER	\N	portal	\N	SUCCESS	SWITCH_USER	{"actorName":"周明","applicationName":null,"objectType":"portal","previousActor":"MOCK_USER_1","objectIds":[],"accessOutcome":null}	\N
178	\N	\N	\N	\N	\N	P4EV_8854f638-adad-4c89-b481-a1a13c61d69e	2026-09-20 07:24:30.644+00	2026-09-20 07:24:30.644+00	1	OPERATION	markRead	8d8484c4-77f5-4954-8ec9-749b281a4311	P4FIX_ADMIN	USER	P4FIX_APP_8	application	MOCK_MSG_2_7	SUCCESS	markRead	{"actorName":"周明","applicationName":"省级平台决策支持展示系统","objectType":"application","previousActor":null,"objectIds":[],"accessOutcome":null}	\N
179	\N	\N	\N	\N	\N	P4EV_1180f113-c768-4d47-9c2d-46ae116f405c	2026-09-20 07:37:38.52+00	2026-09-20 07:37:38.52+00	1	LOGIN	SWITCH_USER	8ec36510-6801-42f3-8ba7-05359ba68678	P4FIX_USER_1	USER	\N	portal	\N	SUCCESS	SWITCH_USER	{"actorName":"林晓","applicationName":null,"objectType":"portal","previousActor":"MOCK_ADMIN","objectIds":[],"accessOutcome":null}	\N
180	\N	\N	\N	\N	\N	P4EV_8f6068dc-02d0-49af-9b31-cca98fa0f55f	2026-09-20 07:38:04.173+00	2026-09-20 07:38:04.173+00	1	ERROR	discoverApplicationAccountCandidates	a364ff0d-378c-42cd-9f35-9121cee11f28	P4FIX_USER_1	USER	P4FIX_APP_13	application	\N	FAILURE	该应用无需账号关联	{"actorName":"林晓","applicationName":"福建省肝炎筛查与规范化治疗管理系统","objectType":"application","previousActor":null,"objectIds":[],"accessOutcome":null}	\N
181	\N	\N	\N	\N	\N	P4EV_95c6c69e-1f7e-4c6f-835a-1d7bd38b698d	2026-09-20 07:38:12.688+00	2026-09-20 07:38:12.688+00	1	ERROR	discoverApplicationAccountCandidates	c7b0abb2-733c-43ac-be9d-1d62de0fe37d	P4FIX_USER_1	USER	P4FIX_APP_13	application	\N	FAILURE	该应用无需账号关联	{"actorName":"林晓","applicationName":"福建省肝炎筛查与规范化治疗管理系统","objectType":"application","previousActor":null,"objectIds":[],"accessOutcome":null}	\N
182	\N	\N	\N	\N	\N	P4EV_0fad7765-7ca7-472a-a16c-7d2c5b50897c	2026-09-20 07:38:30.426+00	2026-09-20 07:38:30.426+00	1	ERROR	discoverApplicationAccountCandidates	f6ef78a4-8648-494a-b030-5a205adde262	P4FIX_USER_1	USER	P4FIX_APP_25	application	\N	FAILURE	该应用无需账号关联	{"actorName":"林晓","applicationName":"福建省中医医师规范化培训管理平台","objectType":"application","previousActor":null,"objectIds":[],"accessOutcome":null}	\N
183	\N	\N	\N	\N	\N	P4EV_4b7443f1-b1c5-41c8-8c19-40dbe4945fe5	2026-09-20 07:38:34.376+00	2026-09-20 07:38:34.376+00	1	ERROR	discoverApplicationAccountCandidates	9ab73409-e437-46de-9b77-c45b0f375b50	P4FIX_USER_1	USER	P4FIX_APP_25	application	\N	FAILURE	该应用无需账号关联	{"actorName":"林晓","applicationName":"福建省中医医师规范化培训管理平台","objectType":"application","previousActor":null,"objectIds":[],"accessOutcome":null}	\N
184	\N	\N	\N	\N	\N	P4EV_e0d4c6dd-ed26-44cb-b82e-99963a4eb2da	2026-09-20 07:38:42.961+00	2026-09-20 07:38:42.961+00	1	ERROR	discoverApplicationAccountCandidates	32ece694-8bee-403e-b806-e2746534deb1	P4FIX_USER_1	USER	P4FIX_APP_26	application	\N	FAILURE	该应用无需账号关联	{"actorName":"林晓","applicationName":"福建省中医医术确有专长人员医师资格考核报名系统","objectType":"application","previousActor":null,"objectIds":[],"accessOutcome":null}	\N
185	\N	\N	\N	\N	\N	P4EV_8d0f3ad5-bd47-4d37-bd26-bb0e30237112	2026-09-20 07:38:49.032+00	2026-09-20 07:38:49.032+00	1	ACCESS	enterApp	797fc846-1f02-4cfa-920c-c567564019fe	P4FIX_USER_1	USER	P4FIX_APP_12	application	MOCK_APP_12	SUCCESS	enterApp	{"actorName":"林晓","applicationName":"中医馆健康信息系统","objectType":"application","previousActor":null,"objectIds":[],"accessOutcome":"ENTRY_REQUEST_ONLY"}	\N
186	\N	\N	\N	\N	\N	P4EV_9fdb229a-a1c1-4bbe-8120-8063e2daba94	2026-09-20 07:39:08.739+00	2026-09-20 07:39:08.739+00	1	ERROR	discoverApplicationAccountCandidates	abe85ad9-a038-4ea4-86db-abda892dcaaf	P4FIX_USER_1	USER	P4FIX_APP_25	application	\N	FAILURE	该应用无需账号关联	{"actorName":"林晓","applicationName":"福建省中医医师规范化培训管理平台","objectType":"application","previousActor":null,"objectIds":[],"accessOutcome":null}	\N
187	\N	\N	\N	\N	\N	P4EV_2e1f1b22-b51a-4ce6-bde7-b6cfeffc0286	2026-09-20 07:40:30.638+00	2026-09-20 07:40:30.638+00	1	LOGIN	SWITCH_USER	1f9ebae2-51de-45fe-9b6d-e9f472d6bdd7	P4FIX_ADMIN	USER	\N	portal	\N	SUCCESS	SWITCH_USER	{"actorName":"周明","applicationName":null,"objectType":"portal","previousActor":"MOCK_USER_1","objectIds":[],"accessOutcome":null}	\N
188	\N	\N	\N	\N	\N	P4EV_7c91ab89-70d1-47f7-abc8-eb8c0614531c	2026-09-20 07:41:38.009+00	2026-09-20 07:41:38.009+00	1	ACCESS	enterApp	3bb64d53-e348-4c96-96ae-198e456ae63f	P4FIX_ADMIN	USER	P4FIX_APP_3	application	MOCK_APP_3	SUCCESS	enterApp	{"actorName":"周明","applicationName":"福建省产前筛查与诊断管理系统","objectType":"application","previousActor":null,"objectIds":[],"accessOutcome":"ENTRY_REQUEST_ONLY"}	\N
189	\N	\N	\N	\N	\N	P4EV_dc8a700f-2151-4776-89e3-0fc8eec3c33d	2026-09-20 08:10:14.509+00	2026-09-20 08:10:14.509+00	1	ACCESS	enterApp	4b81c63b-38ab-4ef4-93fb-5a72d4e1e718	P4FIX_ADMIN	USER	P4FIX_APP_1	application	MOCK_APP_1	SUCCESS	enterApp	{"actorName":"周明","applicationName":"福建省新生儿疾病筛查管理系统","objectType":"application","previousActor":null,"objectIds":[],"accessOutcome":"ENTRY_REQUEST_ONLY"}	\N
190	\N	\N	\N	\N	\N	P4EV_1467eb1d-50dc-4406-a7ec-924a02c82272	2026-09-20 08:10:27.248+00	2026-09-20 08:10:27.248+00	1	ERROR	discoverApplicationAccountCandidates	d9483118-c4ba-4949-9b9c-708942e888a9	P4FIX_ADMIN	USER	P4FIX_APP_10	application	\N	FAILURE	该应用无需账号关联	{"actorName":"周明","applicationName":"福建省血液信息联网平台","objectType":"application","previousActor":null,"objectIds":[],"accessOutcome":null}	\N
191	\N	\N	\N	\N	\N	P4EV_3bdee9fb-982f-4c60-a5d3-4380135275fe	2026-09-20 08:10:58.77+00	2026-09-20 08:10:58.77+00	1	ACCESS	enterApp	71547f8a-ef83-4318-a9ef-7575a56f6944	P4FIX_ADMIN	USER	P4FIX_APP_7	application	MOCK_APP_7	SUCCESS	enterApp	{"actorName":"周明","applicationName":"质控评分系统","objectType":"application","previousActor":null,"objectIds":[],"accessOutcome":"ENTRY_REQUEST_ONLY"}	\N
192	\N	\N	\N	\N	\N	P4EV_44e0dfbf-334b-45e3-aabb-1c471e3e7bca	2026-09-20 09:08:04.16+00	2026-09-20 09:08:04.16+00	1	ERROR	discoverApplicationAccountCandidates	f175874a-c4ef-4cda-9307-eae399b8dd50	P4FIX_ADMIN	USER	P4FIX_APP_10	application	\N	FAILURE	该应用无需账号关联	{"actorName":"周明","applicationName":"福建省血液信息联网平台","objectType":"application","previousActor":null,"objectIds":[],"accessOutcome":null}	\N
193	\N	\N	\N	\N	\N	P4EV_e6e81aa6-eb31-4ec8-9cb8-cf9b332dc3d7	2026-09-20 09:08:04.654+00	2026-09-20 09:08:04.654+00	1	ERROR	discoverApplicationAccountCandidates	01cc7deb-5052-4510-8480-fd2a59d2f36b	P4FIX_ADMIN	USER	P4FIX_APP_10	application	\N	FAILURE	该应用无需账号关联	{"actorName":"周明","applicationName":"福建省血液信息联网平台","objectType":"application","previousActor":null,"objectIds":[],"accessOutcome":null}	\N
194	\N	\N	\N	\N	\N	P4EV_e761c3be-1233-488e-920f-b93b93b2e560	2026-09-20 09:08:06.711+00	2026-09-20 09:08:06.711+00	1	ERROR	discoverApplicationAccountCandidates	1f2f286a-b01f-4a0d-83a0-06d0b46e9f16	P4FIX_ADMIN	USER	P4FIX_APP_10	application	\N	FAILURE	该应用无需账号关联	{"actorName":"周明","applicationName":"福建省血液信息联网平台","objectType":"application","previousActor":null,"objectIds":[],"accessOutcome":null}	\N
195	\N	\N	\N	\N	\N	P4EV_64f35a84-0a63-48d7-a42e-481858cb1cc1	2026-09-20 09:08:09.407+00	2026-09-20 09:08:09.407+00	1	ERROR	discoverApplicationAccountCandidates	f9df11cf-766a-40a7-adb3-f0b17189f1dc	P4FIX_ADMIN	USER	P4FIX_APP_12	application	\N	FAILURE	该应用无需账号关联	{"actorName":"周明","applicationName":"中医馆健康信息系统","objectType":"application","previousActor":null,"objectIds":[],"accessOutcome":null}	\N
196	\N	\N	\N	\N	\N	P4EV_e2545559-9449-48f8-9735-27d34a70b620	2026-09-20 09:08:09.888+00	2026-09-20 09:08:09.888+00	1	ERROR	discoverApplicationAccountCandidates	7850d349-9e69-4693-aa81-f21f31c678d6	P4FIX_ADMIN	USER	P4FIX_APP_12	application	\N	FAILURE	该应用无需账号关联	{"actorName":"周明","applicationName":"中医馆健康信息系统","objectType":"application","previousActor":null,"objectIds":[],"accessOutcome":null}	\N
197	\N	\N	\N	\N	\N	P4EV_2c7202ca-835c-4ceb-9eed-ec8fd43f8826	2026-09-20 09:08:12.461+00	2026-09-20 09:08:12.461+00	1	ERROR	discoverApplicationAccountCandidates	f1888393-9e33-4d2f-919a-4b63e3b261b3	P4FIX_ADMIN	USER	P4FIX_APP_9	application	\N	FAILURE	该应用无需账号关联	{"actorName":"周明","applicationName":"单点登录系统","objectType":"application","previousActor":null,"objectIds":[],"accessOutcome":null}	\N
198	\N	\N	\N	\N	\N	P4EV_525af652-b0f2-48d0-8b25-c1f2d4445e3f	2026-09-20 09:08:12.94+00	2026-09-20 09:08:12.94+00	1	ERROR	discoverApplicationAccountCandidates	821e3bbb-9092-4530-b17c-5918b9cb4426	P4FIX_ADMIN	USER	P4FIX_APP_9	application	\N	FAILURE	该应用无需账号关联	{"actorName":"周明","applicationName":"单点登录系统","objectType":"application","previousActor":null,"objectIds":[],"accessOutcome":null}	\N
199	\N	\N	\N	\N	\N	P4EV_48d9c7dd-61c1-4446-9ff4-d2527d12f24f	2026-09-20 09:08:21.863+00	2026-09-20 09:08:21.863+00	1	ERROR	discoverApplicationAccountCandidates	faa608ad-85cf-4dce-a78c-ef1b173a0748	P4FIX_ADMIN	USER	P4FIX_APP_26	application	\N	FAILURE	该应用无需账号关联	{"actorName":"周明","applicationName":"福建省中医医术确有专长人员医师资格考核报名系统","objectType":"application","previousActor":null,"objectIds":[],"accessOutcome":null}	\N
200	\N	\N	\N	\N	\N	P4EV_3ac13acc-4014-4240-b2cb-a2c2a8e4a7d6	2026-09-20 09:08:27.833+00	2026-09-20 09:08:27.833+00	1	ERROR	discoverApplicationAccountCandidates	699c9c81-3799-4026-b1d6-2ecd26d34e48	P4FIX_ADMIN	USER	P4FIX_APP_19	application	\N	FAILURE	该应用无需账号关联	{"actorName":"周明","applicationName":"省医改效果监测管理系统","objectType":"application","previousActor":null,"objectIds":[],"accessOutcome":null}	\N
201	\N	\N	\N	\N	\N	P4EV_6a068641-80eb-45ef-a51d-34007ca5d9e7	2026-09-20 09:08:28.345+00	2026-09-20 09:08:28.345+00	1	ERROR	discoverApplicationAccountCandidates	b6e30fa2-6999-4a21-91b7-6dea1a927704	P4FIX_ADMIN	USER	P4FIX_APP_19	application	\N	FAILURE	该应用无需账号关联	{"actorName":"周明","applicationName":"省医改效果监测管理系统","objectType":"application","previousActor":null,"objectIds":[],"accessOutcome":null}	\N
202	\N	\N	\N	\N	\N	P4EV_344fe9ad-2515-41a8-8ff0-035a74a3c625	2026-09-20 09:08:31.037+00	2026-09-20 09:08:31.037+00	1	ERROR	discoverApplicationAccountCandidates	b9c5594d-8d90-4232-b1f5-0016a4b3be81	P4FIX_ADMIN	USER	P4FIX_APP_12	application	\N	FAILURE	该应用无需账号关联	{"actorName":"周明","applicationName":"中医馆健康信息系统","objectType":"application","previousActor":null,"objectIds":[],"accessOutcome":null}	\N
203	\N	\N	\N	\N	\N	P4EV_f24fa8f9-71a6-40a2-9b4e-39e47e5b649e	2026-09-20 09:08:31.511+00	2026-09-20 09:08:31.511+00	1	ERROR	discoverApplicationAccountCandidates	b992fd61-6015-4e7e-9c6c-60e3f8e0d41e	P4FIX_ADMIN	USER	P4FIX_APP_12	application	\N	FAILURE	该应用无需账号关联	{"actorName":"周明","applicationName":"中医馆健康信息系统","objectType":"application","previousActor":null,"objectIds":[],"accessOutcome":null}	\N
204	\N	\N	\N	\N	\N	P4EV_693703d6-a6c5-44ef-88e7-bf5e48fc762c	2026-09-20 09:08:37.559+00	2026-09-20 09:08:37.559+00	1	LOGIN	SWITCH_USER	fd20e402-bf1b-443d-9132-e1a14b1a3941	P4FIX_USER_1	USER	\N	portal	\N	SUCCESS	SWITCH_USER	{"actorName":"林晓","applicationName":null,"objectType":"portal","previousActor":"MOCK_ADMIN","objectIds":[],"accessOutcome":null}	\N
205	\N	\N	\N	\N	\N	P4EV_95a36617-2374-4156-a13e-ff0422740f04	2026-09-20 09:08:55.982+00	2026-09-20 09:08:55.982+00	1	ERROR	discoverApplicationAccountCandidates	f117b92d-e365-4af7-9bc2-be822e9f0f20	P4FIX_USER_1	USER	P4FIX_APP_13	application	\N	FAILURE	该应用无需账号关联	{"actorName":"林晓","applicationName":"福建省肝炎筛查与规范化治疗管理系统","objectType":"application","previousActor":null,"objectIds":[],"accessOutcome":null}	\N
206	\N	\N	\N	\N	\N	P4EV_7a25fb49-ff22-4ce7-bb80-87504b23812c	2026-09-20 09:08:56.468+00	2026-09-20 09:08:56.468+00	1	ERROR	discoverApplicationAccountCandidates	38ae423a-7e42-4761-bee8-91fda87f9cfe	P4FIX_USER_1	USER	P4FIX_APP_13	application	\N	FAILURE	该应用无需账号关联	{"actorName":"林晓","applicationName":"福建省肝炎筛查与规范化治疗管理系统","objectType":"application","previousActor":null,"objectIds":[],"accessOutcome":null}	\N
207	\N	\N	\N	\N	\N	P4EV_7f48475f-e3cf-4a4d-907d-37901d8e01e0	2026-09-20 09:09:55.581+00	2026-09-20 09:09:55.581+00	1	LOGIN	SWITCH_USER	051df45f-d482-4180-b006-561e0fcf299a	P4FIX_USER_2	USER	\N	portal	\N	SUCCESS	SWITCH_USER	{"actorName":"陈宁","applicationName":null,"objectType":"portal","previousActor":"MOCK_USER_1","objectIds":[],"accessOutcome":null}	\N
208	\N	\N	\N	\N	\N	P4EV_656278e9-e79b-4052-813c-692b9407b901	2026-09-20 09:10:00.024+00	2026-09-20 09:10:00.024+00	1	LOGIN	SWITCH_USER	e6056a56-9d23-4895-aa27-f4f0da74f604	P4FIX_ADMIN	USER	\N	portal	\N	SUCCESS	SWITCH_USER	{"actorName":"周明","applicationName":null,"objectType":"portal","previousActor":"MOCK_USER_2","objectIds":[],"accessOutcome":null}	\N
209	\N	\N	\N	\N	\N	P4EV_1e38aa1a-a92c-4101-bf47-21d833dfece8	2026-09-20 09:11:31.624+00	2026-09-20 09:11:31.624+00	1	LOGIN	SWITCH_USER	cd2afc32-60c2-4af9-a474-fc9709c798a1	P4FIX_USER_1	USER	\N	portal	\N	SUCCESS	SWITCH_USER	{"actorName":"林晓","applicationName":null,"objectType":"portal","previousActor":"MOCK_ADMIN","objectIds":[],"accessOutcome":null}	\N
210	\N	\N	\N	\N	\N	P4EV_cbaa41f7-b917-4d6b-8797-48c635613564	2026-09-20 09:11:41.563+00	2026-09-20 09:11:41.563+00	1	ERROR	discoverApplicationAccountCandidates	3378c8ce-7538-4ed1-a305-6091d07b48f8	P4FIX_USER_1	USER	P4FIX_APP_13	application	\N	FAILURE	该应用无需账号关联	{"actorName":"林晓","applicationName":"福建省肝炎筛查与规范化治疗管理系统","objectType":"application","previousActor":null,"objectIds":[],"accessOutcome":null}	\N
211	\N	\N	\N	\N	\N	P4EV_dcf587d4-f902-4b8f-a792-c928e457ca4b	2026-09-20 09:11:42.047+00	2026-09-20 09:11:42.047+00	1	ERROR	discoverApplicationAccountCandidates	c25beca9-4340-4f7e-bd8a-08e7f69c0795	P4FIX_USER_1	USER	P4FIX_APP_13	application	\N	FAILURE	该应用无需账号关联	{"actorName":"林晓","applicationName":"福建省肝炎筛查与规范化治疗管理系统","objectType":"application","previousActor":null,"objectIds":[],"accessOutcome":null}	\N
212	\N	\N	\N	\N	\N	P4EV_b7060d61-8e02-4da6-b3d6-701c27ac6744	2026-09-20 09:39:44.558+00	2026-09-20 09:39:44.558+00	1	OPERATION	markRead	450e7fc8-acbd-4a54-bd41-ab6f3144d549	P4FIX_USER_1	USER	P4FIX_APP_11	application	MOCK_MSG_0_6	SUCCESS	markRead	{"actorName":"林晓","applicationName":"福建省免疫规划管理信息系统","objectType":"application","previousActor":null,"objectIds":[],"accessOutcome":null}	\N
213	\N	\N	\N	\N	\N	P4EV_202e639f-9eac-4dde-8276-f30a6269aca3	2026-09-20 09:40:07.761+00	2026-09-20 09:40:07.761+00	1	LOGIN	SWITCH_USER	d128b9b9-9682-4db3-b42a-d22af54a4f3f	P4FIX_USER_2	USER	\N	portal	\N	SUCCESS	SWITCH_USER	{"actorName":"陈宁","applicationName":null,"objectType":"portal","previousActor":"MOCK_USER_1","objectIds":[],"accessOutcome":null}	\N
214	\N	\N	\N	\N	\N	P4EV_9d3a01e0-4bb5-48a1-9994-16c0f85467d9	2026-09-20 09:40:21.595+00	2026-09-20 09:40:21.595+00	1	LOGIN	SWITCH_USER	d90adcf9-403b-4794-9223-a57f15ebdbb1	P4FIX_ADMIN	USER	\N	portal	\N	SUCCESS	SWITCH_USER	{"actorName":"周明","applicationName":null,"objectType":"portal","previousActor":"MOCK_USER_2","objectIds":[],"accessOutcome":null}	\N
215	\N	\N	\N	\N	\N	P4EV_113f63a4-1ef0-4aa6-ba91-74c5f19d5a2d	2026-09-23 01:22:33.376+00	2026-09-23 01:22:33.376+00	1	LOGIN	LOGIN	bf36c7b2-f9c7-445a-bf32-4114c512f51d	P4FIX_ADMIN	USER	\N	portal	\N	SUCCESS	LOGIN	{"actorName":"周明","actorAccount":"zhouming","userType":"GOV","identitySource":"MINZHENGWU","loginMethod":"QR","errorCode":null,"applicationName":null,"accessMode":null,"objectType":"portal","previousActor":null,"objectIds":[],"accessOutcome":null}	\N
217	\N	\N	\N	\N	\N	P4EV_2ecf974d-3dc8-487f-82b0-12e8c9087b4c	2026-09-23 01:23:14.83+00	2026-09-23 01:23:14.83+00	1	LOGIN	LOGIN	029b1aff-99d5-4264-a168-ffe2c55c8d80	P4FIX_ADMIN	USER	\N	portal	\N	SUCCESS	LOGIN	{"actorName":"周明","actorAccount":"zhouming","userType":"GOV","identitySource":"MINZHENGWU","loginMethod":"QR","errorCode":null,"applicationName":null,"accessMode":null,"objectType":"portal","previousActor":null,"objectIds":[],"accessOutcome":null}	\N
218	\N	\N	\N	\N	\N	P4EV_6c19ccd3-c576-4363-8e2c-86cb0117599b	2026-09-23 01:23:45.05+00	2026-09-23 01:23:45.05+00	1	LOGIN	LOGIN	ba9083c0-bdc5-4990-9c0d-d0012d67926c	P4FIX_ADMIN	USER	\N	portal	\N	SUCCESS	LOGIN	{"actorName":"周明","actorAccount":"zhouming","userType":"GOV","identitySource":"MINZHENGWU","loginMethod":"QR","errorCode":null,"applicationName":null,"accessMode":null,"objectType":"portal","previousActor":null,"objectIds":[],"accessOutcome":null}	\N
220	\N	\N	\N	\N	\N	P4EV_ead18718-fd25-4fb1-8ae8-21151fca3ed5	2026-09-23 01:24:37.626+00	2026-09-23 01:24:37.626+00	1	LOGIN	LOGIN	b7b9abd9-1334-46ea-81c1-917709de7545	P4FIX_ADMIN	USER	\N	portal	\N	SUCCESS	LOGIN	{"actorName":"周明","actorAccount":"zhouming","userType":"GOV","identitySource":"MINZHENGWU","loginMethod":"QR","errorCode":null,"applicationName":null,"accessMode":null,"objectType":"portal","previousActor":null,"objectIds":[],"accessOutcome":null}	\N
222	\N	\N	\N	\N	\N	P4EV_518eb3e4-2b8a-4c4f-bb8b-e63fe5999ae4	2026-09-23 07:12:51.19+00	2026-09-23 07:12:51.19+00	1	LOGIN	LOGIN	23c8368d-1e71-4b09-9331-420c117726cb	P4FIX_ADMIN	USER	\N	portal	\N	SUCCESS	LOGIN	{"actorName":"周明","actorAccount":"zhouming","userType":"GOV","identitySource":"MINZHENGWU","loginMethod":"QR","errorCode":null,"applicationName":null,"accessMode":null,"objectType":"portal","previousActor":null,"objectIds":[],"accessOutcome":null}	\N
223	\N	\N	\N	\N	\N	P4EV_c66808f1-c3f2-402d-a028-932ecd27af5d	2026-09-23 07:26:37.982+00	2026-09-23 07:26:37.982+00	1	LOGIN	LOGIN	579613c6-7378-4a2d-888c-bd443319acfd	P4FIX_ADMIN	USER	\N	portal	\N	SUCCESS	LOGIN	{"actorName":"周明","actorAccount":"zhouming","userType":"GOV","identitySource":"MINZHENGWU","loginMethod":"QR","errorCode":null,"applicationName":null,"accessMode":null,"objectType":"portal","previousActor":null,"objectIds":[],"accessOutcome":null}	\N
224	\N	\N	\N	\N	\N	P4EV_03236770-791f-460e-a6bc-efbf0a0dfeac	2026-09-23 07:26:40.289+00	2026-09-23 07:26:40.289+00	1	LOGIN	LOGIN	bd09c75c-d49e-44bc-9c35-b01650586f32	P4FIX_USER_1	USER	\N	portal	\N	SUCCESS	LOGIN	{"actorName":"林晓","actorAccount":"linxiao","userType":"CITIZEN","identitySource":"MINZHENGTONG","loginMethod":"QR","errorCode":null,"applicationName":null,"accessMode":null,"objectType":"portal","previousActor":null,"objectIds":[],"accessOutcome":null}	\N
231	\N	\N	\N	\N	\N	P4EV_9a5de5fa-ad40-4607-9dbb-1c1794cf81ea	2026-09-23 08:37:15.607+00	2026-09-23 08:37:15.607+00	1	LOGIN	LOGIN	c3604206-a0c9-48b6-bfbb-59fe43165e8a	P4FIX_USER_1	USER	\N	portal	\N	SUCCESS	LOGIN	{"actorName":"林晓","actorAccount":"linxiao","userType":"CITIZEN","identitySource":"MINZHENGTONG","loginMethod":"QR","errorCode":null,"applicationName":null,"accessMode":null,"objectType":"portal","previousActor":null,"objectIds":[],"accessOutcome":null}	\N
232	\N	\N	\N	\N	\N	P4EV_4f497644-b9e2-413f-83c3-00ed021dc861	2026-09-23 08:39:03.839+00	2026-09-23 08:39:03.839+00	1	LOGIN	SWITCH_USER	c6cb6f8c-9125-452a-a78b-3fcf5c85247e	P4FIX_USER_2	USER	\N	portal	\N	SUCCESS	SWITCH_USER	{"actorName":"陈宁","actorAccount":"chenning","userType":"GOV","identitySource":"MINZHENGWU","loginMethod":"QR","errorCode":null,"applicationName":null,"accessMode":null,"objectType":"portal","previousActor":"MOCK_USER_1","objectIds":[],"accessOutcome":null}	\N
233	\N	\N	\N	\N	\N	P4EV_16f9b0e2-4023-4ad5-832f-91ea3154e3d7	2026-09-23 08:39:56.415+00	2026-09-23 08:39:56.415+00	1	LOGIN	SWITCH_USER	3ac83534-3403-40a1-ae9c-ed29c8270316	P4FIX_USER_1	USER	\N	portal	\N	SUCCESS	SWITCH_USER	{"actorName":"林晓","actorAccount":"linxiao","userType":"CITIZEN","identitySource":"MINZHENGTONG","loginMethod":"QR","errorCode":null,"applicationName":null,"accessMode":null,"objectType":"portal","previousActor":"MOCK_USER_2","objectIds":[],"accessOutcome":null}	\N
234	\N	\N	\N	\N	\N	P4EV_ad9e16d3-3537-4c80-9733-7e70d4e48c08	2026-09-23 08:40:05.022+00	2026-09-23 08:40:05.022+00	1	LOGIN	SWITCH_USER	851efb4c-8d92-4349-be47-351f9bfc563e	P4FIX_ADMIN	USER	\N	portal	\N	SUCCESS	SWITCH_USER	{"actorName":"周明","actorAccount":"zhouming","userType":"GOV","identitySource":"MINZHENGWU","loginMethod":"QR","errorCode":null,"applicationName":null,"accessMode":null,"objectType":"portal","previousActor":"MOCK_USER_1","objectIds":[],"accessOutcome":null}	\N
235	\N	\N	\N	\N	\N	P4EV_e1e1f7c7-1b47-4621-a9d3-fd30cc253a4b	2026-09-23 08:40:23.409+00	2026-09-23 08:40:23.409+00	1	LOGIN	SWITCH_USER	1342246d-6995-4979-9be5-426ce1d7cd06	P4FIX_EDITOR	USER	\N	portal	\N	SUCCESS	SWITCH_USER	{"actorName":"郑颖","actorAccount":"zhengying","userType":"GOV","identitySource":"MINZHENGWU","loginMethod":"QR","errorCode":null,"applicationName":null,"accessMode":null,"objectType":"portal","previousActor":"MOCK_ADMIN","objectIds":[],"accessOutcome":null}	\N
236	\N	\N	\N	\N	\N	P4EV_19cb5d9e-8d4e-4f79-ab93-57dd5ce4dbbb	2026-09-23 08:40:39.499+00	2026-09-23 08:40:39.499+00	1	LOGIN	LOGOUT	1f8efe54-495f-4b92-b753-3d29e66a734d	P4FIX_EDITOR	USER	\N	portal	\N	SUCCESS	LOGOUT	{"actorName":"郑颖","actorAccount":"zhengying","userType":"GOV","identitySource":"MINZHENGWU","loginMethod":"QR","errorCode":null,"applicationName":null,"accessMode":null,"objectType":"portal","previousActor":null,"objectIds":[],"accessOutcome":null}	\N
237	\N	\N	\N	\N	\N	P4EV_2420fff0-65f6-4a4d-9b1d-6b2983ea6b1b	2026-09-23 08:43:52.212+00	2026-09-23 08:43:52.212+00	1	LOGIN	LOGIN	0a4ab515-d5e7-4959-b708-c56b5faf3480	P4FIX_USER_1	USER	\N	portal	\N	SUCCESS	LOGIN	{"actorName":"林晓","actorAccount":"linxiao","userType":"CITIZEN","identitySource":"MINZHENGTONG","loginMethod":"QR","errorCode":null,"applicationName":null,"accessMode":null,"objectType":"portal","previousActor":null,"objectIds":[],"accessOutcome":null}	\N
238	\N	\N	\N	\N	\N	P4EV_e34a7d4d-2962-4ec8-ba46-e657e95f6b8f	2026-09-23 08:45:02.013+00	2026-09-23 08:45:02.013+00	1	LOGIN	SWITCH_USER	9c4b5ef4-1748-4b15-b1fe-9327a5822947	P4FIX_ADMIN	USER	\N	portal	\N	SUCCESS	SWITCH_USER	{"actorName":"周明","actorAccount":"zhouming","userType":"GOV","identitySource":"MINZHENGWU","loginMethod":"QR","errorCode":null,"applicationName":null,"accessMode":null,"objectType":"portal","previousActor":"MOCK_USER_1","objectIds":[],"accessOutcome":null}	\N
239	\N	\N	\N	\N	\N	P4EV_a40513d2-ed6e-4a86-a854-466c75648726	2026-09-23 08:45:25.651+00	2026-09-23 08:45:25.651+00	1	LOGIN	SWITCH_USER	e792c982-7763-47ed-9cb4-fc707e66eb6a	P4FIX_EDITOR	USER	\N	portal	\N	SUCCESS	SWITCH_USER	{"actorName":"郑颖","actorAccount":"zhengying","userType":"GOV","identitySource":"MINZHENGWU","loginMethod":"QR","errorCode":null,"applicationName":null,"accessMode":null,"objectType":"portal","previousActor":"MOCK_ADMIN","objectIds":[],"accessOutcome":null}	\N
240	\N	\N	\N	\N	\N	P4EV_676d7522-044e-4d99-ac36-8b226f4fdb8d	2026-09-23 09:56:59.774+00	2026-09-23 09:56:59.774+00	1	LOGIN	LOGIN	ff5001eb-e641-45fe-ad20-c54235646a16	P4FIX_USER_1	USER	\N	portal	\N	SUCCESS	LOGIN	{"actorName":"林晓","actorAccount":"linxiao","userType":"CITIZEN","identitySource":"MINZHENGTONG","loginMethod":"QR","errorCode":null,"applicationName":null,"accessMode":null,"objectType":"portal","previousActor":null,"objectIds":[],"accessOutcome":null}	\N
241	\N	\N	\N	\N	\N	P4EV_eda8f091-029b-4f62-92dd-c388f8e89d2e	2026-09-23 10:02:02.068+00	2026-09-23 10:02:02.068+00	1	LOGIN	SWITCH_USER	114dccf3-bff5-4ae8-88a7-67ee4e5ed14f	P4FIX_USER_2	USER	\N	portal	\N	SUCCESS	SWITCH_USER	{"actorName":"陈宁","actorAccount":"chenning","userType":"GOV","identitySource":"MINZHENGWU","loginMethod":"QR","errorCode":null,"applicationName":null,"accessMode":null,"objectType":"portal","previousActor":"MOCK_USER_1","objectIds":[],"accessOutcome":null}	\N
242	\N	\N	\N	\N	\N	P4EV_07361d5f-eb56-493a-8038-fac3a231ea6e	2026-09-23 10:02:23.09+00	2026-09-23 10:02:23.09+00	1	LOGIN	SWITCH_USER	82cad4cc-e614-4a2e-bc0c-d5c7b4730773	P4FIX_ADMIN	USER	\N	portal	\N	SUCCESS	SWITCH_USER	{"actorName":"周明","actorAccount":"zhouming","userType":"GOV","identitySource":"MINZHENGWU","loginMethod":"QR","errorCode":null,"applicationName":null,"accessMode":null,"objectType":"portal","previousActor":"MOCK_USER_2","objectIds":[],"accessOutcome":null}	\N
243	\N	\N	\N	\N	\N	P4EV_fe6cb490-4446-4f92-baa9-f989425813f2	2026-09-23 10:02:43.564+00	2026-09-23 10:02:43.564+00	1	LOGIN	SWITCH_USER	80d4ae08-a1db-416d-ab08-d5595ea40e0e	P4FIX_EDITOR	USER	\N	portal	\N	SUCCESS	SWITCH_USER	{"actorName":"郑颖","actorAccount":"zhengying","userType":"GOV","identitySource":"MINZHENGWU","loginMethod":"QR","errorCode":null,"applicationName":null,"accessMode":null,"objectType":"portal","previousActor":"MOCK_ADMIN","objectIds":[],"accessOutcome":null}	\N
244	\N	\N	\N	\N	\N	P4EV_6256dce0-3e26-469f-870b-e4a06a3d4555	2026-09-23 10:02:58.314+00	2026-09-23 10:02:58.314+00	1	LOGIN	SWITCH_USER	cf811b22-b460-4bb7-b62b-af5c854d61b1	P4FIX_USER_1	USER	\N	portal	\N	SUCCESS	SWITCH_USER	{"actorName":"林晓","actorAccount":"linxiao","userType":"CITIZEN","identitySource":"MINZHENGTONG","loginMethod":"QR","errorCode":null,"applicationName":null,"accessMode":null,"objectType":"portal","previousActor":"MOCK_EDITOR","objectIds":[],"accessOutcome":null}	\N
245	\N	\N	\N	\N	\N	P4EV_e915b81a-8c2e-435d-8877-a46d003aea93	2026-09-23 11:58:59.946+00	2026-09-23 11:58:59.946+00	1	LOGIN	LOGIN	8137bc20-8204-4145-bf93-d469e2347074	P4FIX_LOCAL_ADMIN	USER	\N	portal	\N	SUCCESS	LOGIN	{"actorName":"门户管理员","actorAccount":"admin","userType":null,"identitySource":"PORTAL_LOCAL","loginMethod":"PASSWORD","errorCode":null,"applicationName":null,"accessMode":null,"objectType":"portal","previousActor":null,"objectIds":[],"accessOutcome":null}	\N
246	\N	\N	\N	\N	\N	P4EV_1cb3eb80-162a-4dd5-864d-be47c62dcb29	2026-09-23 12:02:35.623+00	2026-09-23 12:02:35.623+00	1	LOGIN	LOGIN	b39db9ec-724a-4d7f-8ebe-5e0dd30289e4	P4FIX_ADMIN	USER	\N	portal	\N	SUCCESS	LOGIN	{"actorName":"周明","actorAccount":"zhouming","userType":"GOV","identitySource":"MINZHENGWU","loginMethod":"QR","errorCode":null,"applicationName":null,"accessMode":null,"objectType":"portal","previousActor":null,"objectIds":[],"accessOutcome":null}	\N
247	\N	\N	\N	\N	\N	P4EV_acb2a2df-5bf5-4957-984a-d370adc6c494	2026-09-23 12:11:00.109+00	2026-09-23 12:11:00.109+00	1	LOGIN	LOGIN	db065187-79ee-4d57-b89f-997845eb3b86	P4FIX_ADMIN	USER	\N	portal	\N	SUCCESS	LOGIN	{"actorName":"周明","actorAccount":"zhouming","userType":"GOV","identitySource":"MINZHENGWU","loginMethod":"QR","errorCode":null,"applicationName":null,"accessMode":null,"objectType":"portal","previousActor":null,"objectIds":[],"accessOutcome":null}	\N
248	\N	\N	\N	\N	\N	P4EV_b8f76900-b643-427a-96bc-d1f9ea03f7b6	2026-09-23 12:27:33.377+00	2026-09-23 12:27:33.377+00	1	LOGIN	LOGIN	3770a582-ccb2-4a2f-b9c7-7f6cd882f4b7	P4FIX_USER_1	USER	\N	portal	\N	SUCCESS	LOGIN	{"actorName":"林晓","actorAccount":"linxiao","userType":"CITIZEN","identitySource":"MINZHENGTONG","loginMethod":"QR","errorCode":null,"applicationName":null,"accessMode":null,"objectType":"portal","previousActor":null,"objectIds":[],"accessOutcome":null}	\N
249	\N	\N	\N	\N	\N	P4EV_7abf8e37-0808-43cd-9435-94e8e77feaaf	2026-09-23 12:27:41.397+00	2026-09-23 12:27:41.397+00	1	LOGIN	SWITCH_USER	9bd95b23-8608-493c-8a57-bb7a9b044c90	P4FIX_USER_2	USER	\N	portal	\N	SUCCESS	SWITCH_USER	{"actorName":"陈宁","actorAccount":"chenning","userType":"GOV","identitySource":"MINZHENGWU","loginMethod":"QR","errorCode":null,"applicationName":null,"accessMode":null,"objectType":"portal","previousActor":"MOCK_USER_1","objectIds":[],"accessOutcome":null}	\N
250	\N	\N	\N	\N	\N	P4EV_3bbaa34f-957c-4475-ac21-5809c7046bc0	2026-09-23 12:27:47.136+00	2026-09-23 12:27:47.136+00	1	LOGIN	SWITCH_USER	9c96199e-7c7e-4e76-b6f9-8e825ef93c1d	P4FIX_ADMIN	USER	\N	portal	\N	SUCCESS	SWITCH_USER	{"actorName":"周明","actorAccount":"zhouming","userType":"GOV","identitySource":"MINZHENGWU","loginMethod":"QR","errorCode":null,"applicationName":null,"accessMode":null,"objectType":"portal","previousActor":"MOCK_USER_2","objectIds":[],"accessOutcome":null}	\N
251	\N	\N	\N	\N	\N	P4EV_f3552e04-dadf-4ffb-a325-71b9f2e53d6d	2026-09-23 12:27:54.464+00	2026-09-23 12:27:54.464+00	1	LOGIN	SWITCH_USER	b38b7a06-ec54-4175-9772-84781fbc43d3	P4FIX_EDITOR	USER	\N	portal	\N	SUCCESS	SWITCH_USER	{"actorName":"郑颖","actorAccount":"zhengying","userType":"GOV","identitySource":"MINZHENGWU","loginMethod":"QR","errorCode":null,"applicationName":null,"accessMode":null,"objectType":"portal","previousActor":"MOCK_ADMIN","objectIds":[],"accessOutcome":null}	\N
252	\N	\N	\N	\N	\N	P4EV_de4d637b-baa6-45a4-ba90-ee21e385462e	2026-09-23 12:36:22.956+00	2026-09-23 12:36:22.956+00	1	LOGIN	LOGIN	ae402939-07f9-4c85-88b8-37219dc1bf35	P4FIX_USER_1	USER	\N	portal	\N	SUCCESS	LOGIN	{"actorName":"林晓","actorAccount":"linxiao","userType":"CITIZEN","identitySource":"MINZHENGTONG","loginMethod":"QR","errorCode":null,"applicationName":null,"accessMode":null,"objectType":"portal","previousActor":null,"objectIds":[],"accessOutcome":null}	\N
253	\N	\N	\N	\N	\N	P4EV_13e2ec8c-e017-4787-bbe8-3e45fee8d126	2026-09-23 12:36:33.501+00	2026-09-23 12:36:33.501+00	1	LOGIN	SWITCH_USER	23af51e0-7944-49e5-85eb-7b1dfb014716	P4FIX_USER_2	USER	\N	portal	\N	SUCCESS	SWITCH_USER	{"actorName":"陈宁","actorAccount":"chenning","userType":"GOV","identitySource":"MINZHENGWU","loginMethod":"QR","errorCode":null,"applicationName":null,"accessMode":null,"objectType":"portal","previousActor":"MOCK_USER_1","objectIds":[],"accessOutcome":null}	\N
254	\N	\N	\N	\N	\N	P4EV_2b003884-1662-4d7e-a26a-ee5bbb0e25be	2026-09-23 12:37:05.933+00	2026-09-23 12:37:05.933+00	1	ERROR	openTodo	03954081-84db-49ec-ab91-98dc06b40ccd	P4FIX_USER_2	USER	P4FIX_APP_1	todo	MOCK_TODO_1_0	FAILURE	SSO接入异常或未配置	{"actorName":"陈宁","actorAccount":"chenning","userType":"GOV","identitySource":"MINZHENGWU","loginMethod":"QR","errorCode":"UPSTREAM_UNAVAILABLE","applicationName":"福建省新生儿疾病筛查管理系统","accessMode":"DIRECT","objectType":"todo","previousActor":null,"objectIds":[],"accessOutcome":"ENTRY_REQUEST_ONLY"}	\N
255	\N	\N	\N	\N	\N	P4EV_667ad1ed-fd95-49c2-a659-1a5468b1f747	2026-09-23 12:37:43.123+00	2026-09-23 12:37:43.123+00	1	OPERATION	discoverApplicationAccountCandidates	5bcb9f39-82cb-4db8-a26d-22ece6acdd0b	P4FIX_USER_2	USER	P4FIX_APP_11	application	\N	SUCCESS	discoverApplicationAccountCandidates	{"actorName":"陈宁","actorAccount":"chenning","userType":"GOV","identitySource":"MINZHENGWU","loginMethod":"QR","errorCode":null,"applicationName":"福建省免疫规划管理信息系统","accessMode":"BIND","objectType":"application","previousActor":null,"objectIds":[],"accessOutcome":null}	\N
256	\N	\N	\N	\N	\N	P4EV_0e8ae92f-5092-45f5-b792-15f7ebf49a43	2026-09-23 12:37:44.205+00	2026-09-23 12:37:44.205+00	1	OPERATION	discoverApplicationAccountCandidates	980ddcfd-f899-4649-b319-045d2b8a5fe6	P4FIX_USER_2	USER	P4FIX_APP_11	application	\N	SUCCESS	discoverApplicationAccountCandidates	{"actorName":"陈宁","actorAccount":"chenning","userType":"GOV","identitySource":"MINZHENGWU","loginMethod":"QR","errorCode":null,"applicationName":"福建省免疫规划管理信息系统","accessMode":"BIND","objectType":"application","previousActor":null,"objectIds":[],"accessOutcome":null}	\N
257	\N	\N	\N	\N	\N	P4EV_46a0a5f2-bf4d-434f-98d8-0237f4a62a02	2026-09-23 12:37:50.744+00	2026-09-23 12:37:50.744+00	1	OPERATION	discoverApplicationAccountCandidates	5e06ff1f-f9ee-4c7f-9334-efe698e66d1b	P4FIX_USER_2	USER	P4FIX_APP_10	application	\N	SUCCESS	discoverApplicationAccountCandidates	{"actorName":"陈宁","actorAccount":"chenning","userType":"GOV","identitySource":"MINZHENGWU","loginMethod":"QR","errorCode":null,"applicationName":"福建省血液信息联网平台","accessMode":"BIND","objectType":"application","previousActor":null,"objectIds":[],"accessOutcome":null}	\N
258	\N	\N	\N	\N	\N	P4EV_e9f0e28d-1c80-40ce-b68b-af50a2c97f91	2026-09-23 12:37:51.779+00	2026-09-23 12:37:51.779+00	1	OPERATION	discoverApplicationAccountCandidates	74b85172-4179-4341-8487-8a19fdeabbc4	P4FIX_USER_2	USER	P4FIX_APP_10	application	\N	SUCCESS	discoverApplicationAccountCandidates	{"actorName":"陈宁","actorAccount":"chenning","userType":"GOV","identitySource":"MINZHENGWU","loginMethod":"QR","errorCode":null,"applicationName":"福建省血液信息联网平台","accessMode":"BIND","objectType":"application","previousActor":null,"objectIds":[],"accessOutcome":null}	\N
259	\N	\N	\N	\N	\N	P4EV_e4901890-1529-4643-9372-1cf9f41bf1f7	2026-09-23 12:38:02.609+00	2026-09-23 12:38:02.609+00	1	OPERATION	discoverApplicationAccountCandidates	cf060d5f-1523-4493-8eb8-e581ef57a9cc	P4FIX_USER_2	USER	P4FIX_APP_9	application	\N	SUCCESS	discoverApplicationAccountCandidates	{"actorName":"陈宁","actorAccount":"chenning","userType":"GOV","identitySource":"MINZHENGWU","loginMethod":"QR","errorCode":null,"applicationName":"单点登录系统","accessMode":"BIND","objectType":"application","previousActor":null,"objectIds":[],"accessOutcome":null}	\N
260	\N	\N	\N	\N	\N	P4EV_094ca01b-31b0-49e2-b900-7964af9ad86e	2026-09-23 12:38:03.67+00	2026-09-23 12:38:03.67+00	1	OPERATION	discoverApplicationAccountCandidates	932daa34-b571-4087-b433-c141e0707b4d	P4FIX_USER_2	USER	P4FIX_APP_9	application	\N	SUCCESS	discoverApplicationAccountCandidates	{"actorName":"陈宁","actorAccount":"chenning","userType":"GOV","identitySource":"MINZHENGWU","loginMethod":"QR","errorCode":null,"applicationName":"单点登录系统","accessMode":"BIND","objectType":"application","previousActor":null,"objectIds":[],"accessOutcome":null}	\N
261	\N	\N	\N	\N	\N	P4EV_b064e1f9-f470-443e-b9a7-9e412bb05ae2	2026-09-23 12:38:24.401+00	2026-09-23 12:38:24.401+00	1	OPERATION	discoverApplicationAccountCandidates	7bc59be9-deba-4d1c-aef0-391d1ddb06d3	P4FIX_USER_2	USER	P4FIX_APP_17	application	\N	SUCCESS	discoverApplicationAccountCandidates	{"actorName":"陈宁","actorAccount":"chenning","userType":"GOV","identitySource":"MINZHENGWU","loginMethod":"QR","errorCode":null,"applicationName":"全员人口数据库药具发放服务管理","accessMode":"REQUEST","objectType":"application","previousActor":null,"objectIds":[],"accessOutcome":null}	\N
262	\N	\N	\N	\N	\N	P4EV_0730d46a-51d1-4d53-9584-355dbf0c30d0	2026-09-23 12:38:25.416+00	2026-09-23 12:38:25.416+00	1	OPERATION	discoverApplicationAccountCandidates	df88a9ae-4cf8-454f-b6cf-b288c0551b4c	P4FIX_USER_2	USER	P4FIX_APP_17	application	\N	SUCCESS	discoverApplicationAccountCandidates	{"actorName":"陈宁","actorAccount":"chenning","userType":"GOV","identitySource":"MINZHENGWU","loginMethod":"QR","errorCode":null,"applicationName":"全员人口数据库药具发放服务管理","accessMode":"REQUEST","objectType":"application","previousActor":null,"objectIds":[],"accessOutcome":null}	\N
263	\N	\N	\N	\N	\N	P4EV_41d20096-bd09-490d-bc35-095b14ef771f	2026-09-23 12:38:56.072+00	2026-09-23 12:38:56.072+00	1	LOGIN	SWITCH_USER	9a1761ec-b6b7-48b7-815c-a2d8bd233f90	P4FIX_USER_1	USER	\N	portal	\N	SUCCESS	SWITCH_USER	{"actorName":"林晓","actorAccount":"linxiao","userType":"CITIZEN","identitySource":"MINZHENGTONG","loginMethod":"QR","errorCode":null,"applicationName":null,"accessMode":null,"objectType":"portal","previousActor":"MOCK_USER_2","objectIds":[],"accessOutcome":null}	\N
264	\N	\N	\N	\N	\N	P4EV_b804702b-15a1-40f5-a9be-fc2c0307682d	2026-09-23 12:44:24.032+00	2026-09-23 12:44:24.032+00	1	LOGIN	SWITCH_USER	1d4ae0c7-55ef-40e8-99ba-05142334810d	P4FIX_USER_2	USER	\N	portal	\N	SUCCESS	SWITCH_USER	{"actorName":"陈宁","actorAccount":"chenning","userType":"GOV","identitySource":"MINZHENGWU","loginMethod":"QR","errorCode":null,"applicationName":null,"accessMode":null,"objectType":"portal","previousActor":"MOCK_USER_1","objectIds":[],"accessOutcome":null}	\N
265	\N	\N	\N	\N	\N	P4EV_9ef6b053-ede3-4cc2-89c3-9bc485d309ca	2026-09-23 12:44:28.542+00	2026-09-23 12:44:28.542+00	1	LOGIN	SWITCH_USER	1bce7b6c-6c93-4d79-ba0f-09aa3399026a	P4FIX_ADMIN	USER	\N	portal	\N	SUCCESS	SWITCH_USER	{"actorName":"周明","actorAccount":"zhouming","userType":"GOV","identitySource":"MINZHENGWU","loginMethod":"QR","errorCode":null,"applicationName":null,"accessMode":null,"objectType":"portal","previousActor":"MOCK_USER_2","objectIds":[],"accessOutcome":null}	\N
\.


--
-- Data for Name: identity_mapping; Type: TABLE DATA; Schema: pb3gir75kkooyea; Owner: admin
--

COPY pb3gir75kkooyea.identity_mapping (nc_id, created_at1, updated_at1, created_by, updated_by, nc_order, id, created_at, updated_at, version, user_id, source_id, external_subject_id, external_account, status, verified_at) FROM stdin;
3	\N	\N	\N	\N	\N	P4FIX_IDENTITY_MOCK_USER_1	2026-09-18 00:00:00+00	2026-09-18 00:00:00+00	1	P4FIX_USER_1	P4FIX_SOURCE_CITIZEN	P4FIX_SUBJECT_MOCK_USER_1	linxiao	BOUND	\N
4	\N	\N	\N	\N	\N	P4FIX_IDENTITY_MOCK_USER_2	2026-09-18 00:00:00+00	2026-09-18 00:00:00+00	1	P4FIX_USER_2	P4FIX_SOURCE_GOV	P4FIX_SUBJECT_MOCK_USER_2	chenning	BOUND	\N
5	\N	\N	\N	\N	\N	P4FIX_IDENTITY_MOCK_ADMIN	2026-09-18 00:00:00+00	2026-09-18 00:00:00+00	1	P4FIX_ADMIN	P4FIX_SOURCE_GOV	P4FIX_SUBJECT_MOCK_ADMIN	zhouming	BOUND	\N
6	\N	\N	\N	\N	\N	P4FIX_IDENTITY_MOCK_EDITOR	2026-09-18 00:00:00+00	2026-09-18 00:00:00+00	1	P4FIX_EDITOR	P4FIX_SOURCE_GOV	P4FIX_SUBJECT_MOCK_EDITOR	zhengying	BOUND	\N
\.


--
-- Data for Name: identity_source; Type: TABLE DATA; Schema: pb3gir75kkooyea; Owner: admin
--

COPY pb3gir75kkooyea.identity_source (nc_id, created_at1, updated_at1, created_by, updated_by, nc_order, id, created_at, updated_at, version, code, name, kind, protocol, config_secret_ref, register_url, status) FROM stdin;
2	\N	\N	\N	\N	\N	P4FIX_SOURCE_CITIZEN	2026-09-18 00:00:00+00	2026-09-18 00:00:00+00	1	P4FIX_SOURCE_CITIZEN	闽政通	CITIZEN	\N	\N	\N	DISABLED
3	\N	\N	\N	\N	\N	P4FIX_SOURCE_GOV	2026-09-18 00:00:00+00	2026-09-18 00:00:00+00	1	P4FIX_SOURCE_GOV	闽政务	GOV	\N	\N	\N	DISABLED
\.


--
-- Data for Name: ingest_receipt; Type: TABLE DATA; Schema: pb3gir75kkooyea; Owner: admin
--

COPY pb3gir75kkooyea.ingest_receipt (nc_id, created_at1, updated_at1, created_by, updated_by, nc_order, id, created_at, updated_at, version, application_id, kind, event_id, payload_hash, status, result, applied_at) FROM stdin;
1	\N	\N	\N	\N	\N	P4FIX_RECEIPT_0	2026-09-18 00:00:00+00	2026-09-18 00:00:00+00	1	P4FIX_APP_1	TODO	P4FIX_EVENT_0	b31c514d6dd438a18d0fd16386fd8fd70694511782038469df41f546c4c0fce8	RECEIVED	{"fixture":true,"disposition":"RECEIVED"}	\N
2	\N	\N	\N	\N	\N	P4FIX_RECEIPT_1	2026-09-18 00:00:00+00	2026-09-18 00:00:00+00	1	P4FIX_APP_2	MESSAGE	P4FIX_EVENT_1	17a6d4b6c8ca7edea5f9d37599c4e161b39b8f94ab15156725985fbc2a778b33	APPLIED	{"fixture":true,"disposition":"APPLIED"}	2026-09-18 00:00:00+00
3	\N	\N	\N	\N	\N	P4FIX_RECEIPT_2	2026-09-18 00:00:00+00	2026-09-18 00:00:00+00	1	P4FIX_APP_3	TODO	P4FIX_EVENT_2	32088f84f55f039bb6fd68ecce0428150aa9ff6b77bc61d6b580b5534b3bff7c	REJECTED	{"fixture":true,"disposition":"REJECTED"}	\N
\.


--
-- Data for Name: login_request; Type: TABLE DATA; Schema: pb3gir75kkooyea; Owner: admin
--

COPY pb3gir75kkooyea.login_request (nc_id, created_at1, updated_at1, created_by, updated_by, nc_order, id, created_at, updated_at, version, source_id, state_hash, method, status, expires_at, consumed_at, failure_code) FROM stdin;
\.


--
-- Data for Name: mapping_exception; Type: TABLE DATA; Schema: pb3gir75kkooyea; Owner: admin
--

COPY pb3gir75kkooyea.mapping_exception (nc_id, created_at1, updated_at1, created_by, updated_by, nc_order, id, created_at, updated_at, version, mapping_id, identity_mapping_id, exception_type, summary, resolution_status, resolved_by, resolved_at, resolution_note) FROM stdin;
1	\N	\N	\N	\N	\N	P4FIX_EXCEPTION_MOCK_MAP_MOCK_USER_1_26	2026-09-18 00:00:00+00	2026-09-18 00:00:00+00	1	P4FIX_MAP_MOCK_USER_1_26	\N	FAILED	账号核验未通过，待补充关联资料	OPEN	\N	\N	\N
2	\N	\N	\N	\N	\N	P4FIX_EXCEPTION_MOCK_MAP_MOCK_USER_1_28	2026-09-18 00:00:00+00	2026-09-18 00:00:00+00	1	P4FIX_MAP_MOCK_USER_1_28	\N	CONFLICT	身份资料不一致，待人工核查	OPEN	\N	\N	\N
3	\N	\N	\N	\N	\N	P4FIX_EXCEPTION_MOCK_MAP_MOCK_USER_2_26	2026-09-18 00:00:00+00	2026-09-18 00:00:00+00	1	P4FIX_MAP_MOCK_USER_2_26	\N	FAILED	账号核验未通过，待补充关联资料	OPEN	\N	\N	\N
4	\N	\N	\N	\N	\N	P4FIX_EXCEPTION_MOCK_MAP_MOCK_USER_2_28	2026-09-18 00:00:00+00	2026-09-18 00:00:00+00	1	P4FIX_MAP_MOCK_USER_2_28	\N	CONFLICT	身份资料不一致，待人工核查	OPEN	\N	\N	\N
5	\N	\N	\N	\N	\N	P4FIX_EXCEPTION_MOCK_MAP_MOCK_ADMIN_26	2026-09-18 00:00:00+00	2026-09-18 00:00:00+00	1	P4FIX_MAP_MOCK_ADMIN_26	\N	FAILED	账号核验未通过，待补充关联资料	OPEN	\N	\N	\N
6	\N	\N	\N	\N	\N	P4FIX_EXCEPTION_MOCK_MAP_MOCK_ADMIN_28	2026-09-18 00:00:00+00	2026-09-18 00:00:00+00	1	P4FIX_MAP_MOCK_ADMIN_28	\N	CONFLICT	身份资料不一致，待人工核查	OPEN	\N	\N	\N
7	\N	\N	\N	\N	\N	P4FIX_EXCEPTION_MOCK_MAP_MOCK_EDITOR_26	2026-09-18 00:00:00+00	2026-09-18 00:00:00+00	1	P4FIX_MAP_MOCK_EDITOR_26	\N	FAILED	账号核验未通过，待补充关联资料	OPEN	\N	\N	\N
8	\N	\N	\N	\N	\N	P4FIX_EXCEPTION_MOCK_MAP_MOCK_EDITOR_28	2026-09-18 00:00:00+00	2026-09-18 00:00:00+00	1	P4FIX_MAP_MOCK_EDITOR_28	\N	CONFLICT	身份资料不一致，待人工核查	OPEN	\N	\N	\N
\.


--
-- Data for Name: message; Type: TABLE DATA; Schema: pb3gir75kkooyea; Owner: admin
--

COPY pb3gir75kkooyea.message (nc_id, created_at1, updated_at1, created_by, updated_by, nc_order, id, created_at, updated_at, version, application_id, source_kind, source_key, source_message_id, message_type, title, content, business_url, source_created_at, runtime_id, received_at) FROM stdin;
3	\N	\N	\N	\N	\N	P4FIX_MSG_0_1	2026-09-18 00:00:00+00	2026-09-18 14:49:35.187+00	2	P4FIX_APP_2	APPLICATION	P4FIX_APP_2	P4FIX_P4_MSG_0_1	BUSINESS	资料核验进度通知	资料核验进度通知。请查看相关事项详情并按办理要求完成后续操作。	https://p4.invalid/app/2	2026-09-17 22:00:00+00	MOCK_MSG_0_1	2026-09-18 00:00:00+00
9	\N	\N	\N	\N	\N	P4FIX_MSG_0_7	2026-09-18 00:00:00+00	2026-09-18 00:00:00+00	1	P4FIX_APP_12	APPLICATION	P4FIX_APP_12	P4FIX_P4_MSG_0_7	BUSINESS	办理意见已反馈	办理意见已反馈。请查看相关事项详情并按办理要求完成后续操作。	https://p4.invalid/app/12	2026-09-18 00:00:00+00	MOCK_MSG_0_7	2026-09-18 00:00:00+00
2	\N	\N	\N	\N	\N	P4FIX_MSG_0_0	2026-09-18 00:00:00+00	2026-09-18 14:49:21.957+00	2	P4FIX_APP_1	APPLICATION	P4FIX_APP_1	P4FIX_P4_MSG_0_0	BUSINESS	服务申请已受理	服务申请已受理。请查看相关事项详情并按办理要求完成后续操作。	https://p4.invalid/app/1	2026-09-17 23:00:00+00	MOCK_MSG_0_0	2026-09-18 00:00:00+00
4	\N	\N	\N	\N	\N	P4FIX_MSG_0_2	2026-09-18 00:00:00+00	2026-09-18 15:15:56.541+00	2	P4FIX_APP_3	APPLICATION	P4FIX_APP_3	P4FIX_P4_MSG_0_2	TODO_REMINDER	办理期限提醒	办理期限提醒。请查看相关事项详情并按办理要求完成后续操作。	https://p4.invalid/app/3	2026-09-17 21:00:00+00	MOCK_MSG_0_2	2026-09-18 00:00:00+00
5	\N	\N	\N	\N	\N	P4FIX_MSG_0_3	2026-09-18 00:00:00+00	2026-09-18 15:05:14.89+00	2	P4FIX_APP_4	APPLICATION	P4FIX_APP_4	P4FIX_P4_MSG_0_3	BUSINESS	服务安排更新	服务安排更新。请查看相关事项详情并按办理要求完成后续操作。	https://p4.invalid/app/4	2026-09-17 20:00:00+00	MOCK_MSG_0_3	2026-09-18 00:00:00+00
6	\N	\N	\N	\N	\N	P4FIX_MSG_0_4	2026-09-18 00:00:00+00	2026-09-18 15:16:22.835+00	2	P4FIX_APP_5	APPLICATION	P4FIX_APP_5	P4FIX_P4_MSG_0_4	BUSINESS	账号关联结果通知	账号关联结果通知。请查看相关事项详情并按办理要求完成后续操作。	https://p4.invalid/app/5	2026-09-17 19:00:00+00	MOCK_MSG_0_4	2026-09-18 00:00:00+00
7	\N	\N	\N	\N	\N	P4FIX_MSG_0_5	2026-09-18 00:00:00+00	2026-09-18 15:58:30.221+00	2	P4FIX_APP_6	APPLICATION	P4FIX_APP_6	P4FIX_P4_MSG_0_5	BUSINESS	业务信息变更提醒	业务信息变更提醒。请查看相关事项详情并按办理要求完成后续操作。	https://p4.invalid/app/6	2026-09-17 18:00:00+00	MOCK_MSG_0_5	2026-09-18 00:00:00+00
8	\N	\N	\N	\N	\N	P4FIX_MSG_0_6	2026-09-18 00:00:00+00	2026-09-20 09:39:44.555+00	2	P4FIX_APP_11	APPLICATION	P4FIX_APP_11	P4FIX_P4_MSG_0_6	BUSINESS	材料补正通知	材料补正通知。请查看相关事项详情并按办理要求完成后续操作。	https://p4.invalid/app/11	2026-09-17 17:00:00+00	MOCK_MSG_0_6	2026-09-18 00:00:00+00
10	\N	\N	\N	\N	\N	P4FIX_MSG_0_8	2026-09-18 00:00:00+00	2026-09-18 00:00:00+00	1	\N	PORTAL	PORTAL	P4FIX_P4_MSG_0_8	SYSTEM	门户维护安排	门户维护安排。请查看相关事项详情并按办理要求完成后续操作。	\N	2026-09-17 15:00:00+00	MOCK_MSG_0_8	2026-09-18 00:00:00+00
11	\N	\N	\N	\N	\N	P4FIX_MSG_0_9	2026-09-18 00:00:00+00	2026-09-18 00:00:00+00	1	\N	PORTAL	PORTAL	P4FIX_P4_MSG_0_9	SYSTEM	信息安全提醒	信息安全提醒。请查看相关事项详情并按办理要求完成后续操作。	\N	2026-09-17 14:00:00+00	MOCK_MSG_0_9	2026-09-18 00:00:00+00
12	\N	\N	\N	\N	\N	P4FIX_MSG_1_0	2026-09-18 00:00:00+00	2026-09-18 16:32:04.31+00	2	P4FIX_APP_1	APPLICATION	P4FIX_APP_1	P4FIX_P4_MSG_1_0	BUSINESS	服务申请已受理	服务申请已受理。请查看相关事项详情并按办理要求完成后续操作。	https://p4.invalid/app/1	2026-09-17 23:00:00+00	MOCK_MSG_1_0	2026-09-18 00:00:00+00
13	\N	\N	\N	\N	\N	P4FIX_MSG_1_1	2026-09-18 00:00:00+00	2026-09-18 15:31:44.193+00	2	P4FIX_APP_2	APPLICATION	P4FIX_APP_2	P4FIX_P4_MSG_1_1	BUSINESS	资料核验进度通知	资料核验进度通知。请查看相关事项详情并按办理要求完成后续操作。	https://p4.invalid/app/2	2026-09-17 22:00:00+00	MOCK_MSG_1_1	2026-09-18 00:00:00+00
14	\N	\N	\N	\N	\N	P4FIX_MSG_1_2	2026-09-18 00:00:00+00	2026-09-18 16:27:06.299+00	2	P4FIX_APP_3	APPLICATION	P4FIX_APP_3	P4FIX_P4_MSG_1_2	TODO_REMINDER	办理期限提醒	办理期限�������������醒。请查看相关事项详情并按办理要求完成后续操作。	https://p4.invalid/app/3	2026-09-17 21:00:00+00	MOCK_MSG_1_2	2026-09-18 00:00:00+00
15	\N	\N	\N	\N	\N	P4FIX_MSG_1_3	2026-09-18 00:00:00+00	2026-09-18 00:00:00+00	1	P4FIX_APP_4	APPLICATION	P4FIX_APP_4	P4FIX_P4_MSG_1_3	BUSINESS	服务安排更新	服务安排更新。请查看相关事项详情并按办理要求完成后续操作。	https://p4.invalid/app/4	2026-09-17 20:00:00+00	MOCK_MSG_1_3	2026-09-18 00:00:00+00
16	\N	\N	\N	\N	\N	P4FIX_MSG_1_4	2026-09-18 00:00:00+00	2026-09-18 00:00:00+00	1	P4FIX_APP_5	APPLICATION	P4FIX_APP_5	P4FIX_P4_MSG_1_4	BUSINESS	账号关联结果通知	账号关联结果通知。请查看相关事项详情并按办理要求完成后续操作。	https://p4.invalid/app/5	2026-09-17 19:00:00+00	MOCK_MSG_1_4	2026-09-18 00:00:00+00
17	\N	\N	\N	\N	\N	P4FIX_MSG_1_5	2026-09-18 00:00:00+00	2026-09-18 00:00:00+00	1	P4FIX_APP_6	APPLICATION	P4FIX_APP_6	P4FIX_P4_MSG_1_5	BUSINESS	业务信息变更提醒	业务信息变更提醒。请查看相关事项详情并按办理要求完成后续操作。	https://p4.invalid/app/6	2026-09-17 18:00:00+00	MOCK_MSG_1_5	2026-09-18 00:00:00+00
18	\N	\N	\N	\N	\N	P4FIX_MSG_1_6	2026-09-18 00:00:00+00	2026-09-18 00:00:00+00	1	P4FIX_APP_7	APPLICATION	P4FIX_APP_7	P4FIX_P4_MSG_1_6	BUSINESS	材料补正通知	材料补正通知。请查看相关事项详情并按办理要求完成后续操作。	https://p4.invalid/app/7	2026-09-17 17:00:00+00	MOCK_MSG_1_6	2026-09-18 00:00:00+00
19	\N	\N	\N	\N	\N	P4FIX_MSG_1_7	2026-09-18 00:00:00+00	2026-09-18 00:00:00+00	1	P4FIX_APP_8	APPLICATION	P4FIX_APP_8	P4FIX_P4_MSG_1_7	BUSINESS	办理意见已反馈	办理意见已反馈。请查看相关事项详情并按办理要求完成后续操作。	https://p4.invalid/app/8	2026-09-17 16:00:00+00	MOCK_MSG_1_7	2026-09-18 00:00:00+00
20	\N	\N	\N	\N	\N	P4FIX_MSG_1_8	2026-09-18 00:00:00+00	2026-09-18 00:00:00+00	1	\N	PORTAL	PORTAL	P4FIX_P4_MSG_1_8	SYSTEM	门户维护安排	门户维护安排。请查看相关事项详情并按办理要求完成后续操作。	\N	2026-09-17 15:00:00+00	MOCK_MSG_1_8	2026-09-18 00:00:00+00
21	\N	\N	\N	\N	\N	P4FIX_MSG_1_9	2026-09-18 00:00:00+00	2026-09-18 00:00:00+00	1	\N	PORTAL	PORTAL	P4FIX_P4_MSG_1_9	SYSTEM	信息安全提醒	信息安全提醒。请查看相关事项详情并按办理要求完成后续操作。	\N	2026-09-17 14:00:00+00	MOCK_MSG_1_9	2026-09-18 00:00:00+00
22	\N	\N	\N	\N	\N	P4FIX_MSG_2_0	2026-09-18 00:00:00+00	2026-09-18 15:48:12.994+00	2	P4FIX_APP_1	APPLICATION	P4FIX_APP_1	P4FIX_P4_MSG_2_0	BUSINESS	服务申请已受理	服务申请已受理。请查看相关事项详情并按办理要求完成后续操作。	https://p4.invalid/app/1	2026-09-17 23:00:00+00	MOCK_MSG_2_0	2026-09-18 00:00:00+00
23	\N	\N	\N	\N	\N	P4FIX_MSG_2_1	2026-09-18 00:00:00+00	2026-09-18 15:48:33.066+00	2	P4FIX_APP_2	APPLICATION	P4FIX_APP_2	P4FIX_P4_MSG_2_1	BUSINESS	资料核验进度通知	资料核验进度通知。请查看相关事项详情并按办理要求完成后续操作。	https://p4.invalid/app/2	2026-09-17 22:00:00+00	MOCK_MSG_2_1	2026-09-18 00:00:00+00
24	\N	\N	\N	\N	\N	P4FIX_MSG_2_2	2026-09-18 00:00:00+00	2026-09-18 16:12:43.994+00	2	P4FIX_APP_3	APPLICATION	P4FIX_APP_3	P4FIX_P4_MSG_2_2	TODO_REMINDER	办理期限提醒	办理期限提醒。请查看相关事项详情并按办理要求完成后续操作。	https://p4.invalid/app/3	2026-09-17 21:00:00+00	MOCK_MSG_2_2	2026-09-18 00:00:00+00
25	\N	\N	\N	\N	\N	P4FIX_MSG_2_3	2026-09-18 00:00:00+00	2026-09-18 16:13:40.36+00	2	P4FIX_APP_4	APPLICATION	P4FIX_APP_4	P4FIX_P4_MSG_2_3	BUSINESS	服务安排更新	服务安排更新。请查看相关事项详情并按办理要求完成后续操作。	https://p4.invalid/app/4	2026-09-17 20:00:00+00	MOCK_MSG_2_3	2026-09-18 00:00:00+00
26	\N	\N	\N	\N	\N	P4FIX_MSG_2_4	2026-09-18 00:00:00+00	2026-09-19 11:16:27.075+00	2	P4FIX_APP_5	APPLICATION	P4FIX_APP_5	P4FIX_P4_MSG_2_4	BUSINESS	账号关联结果通知	账号关联结果通知。请查看相关事项详情并按办理要求完成后续操作。	https://p4.invalid/app/5	2026-09-17 19:00:00+00	MOCK_MSG_2_4	2026-09-18 00:00:00+00
27	\N	\N	\N	\N	\N	P4FIX_MSG_2_5	2026-09-18 00:00:00+00	2026-09-19 12:56:48.398+00	2	P4FIX_APP_6	APPLICATION	P4FIX_APP_6	P4FIX_P4_MSG_2_5	BUSINESS	业务信息变更提醒	业务信息变更提醒。请查看相关事项详情并按办理要求完成后续操作。	https://p4.invalid/app/6	2026-09-17 18:00:00+00	MOCK_MSG_2_5	2026-09-18 00:00:00+00
28	\N	\N	\N	\N	\N	P4FIX_MSG_2_6	2026-09-18 00:00:00+00	2026-09-20 06:54:31.275+00	2	P4FIX_APP_7	APPLICATION	P4FIX_APP_7	P4FIX_P4_MSG_2_6	BUSINESS	材料补正通知	材料补正通知。请查看相关事项详情并按办理要求完成后续操作。	https://p4.invalid/app/7	2026-09-17 17:00:00+00	MOCK_MSG_2_6	2026-09-18 00:00:00+00
29	\N	\N	\N	\N	\N	P4FIX_MSG_2_7	2026-09-18 00:00:00+00	2026-09-20 07:24:30.642+00	2	P4FIX_APP_8	APPLICATION	P4FIX_APP_8	P4FIX_P4_MSG_2_7	BUSINESS	办理意见已反馈	办理意见已反馈。请查看相关事项详情并按办理要求完成后续操作。	https://p4.invalid/app/8	2026-09-17 16:00:00+00	MOCK_MSG_2_7	2026-09-18 00:00:00+00
30	\N	\N	\N	\N	\N	P4FIX_MSG_2_8	2026-09-18 00:00:00+00	2026-09-18 00:00:00+00	1	\N	PORTAL	PORTAL	P4FIX_P4_MSG_2_8	SYSTEM	门户维护安排	门户维护安排。请查看相关事项详情并按办理要求完成后续操作。	\N	2026-09-17 15:00:00+00	MOCK_MSG_2_8	2026-09-18 00:00:00+00
31	\N	\N	\N	\N	\N	P4FIX_MSG_2_9	2026-09-18 00:00:00+00	2026-09-18 00:00:00+00	1	\N	PORTAL	PORTAL	P4FIX_P4_MSG_2_9	SYSTEM	信息安全提醒	信息安全提醒。请查看相关事项详情并按办理要求完成后续操作。	\N	2026-09-17 14:00:00+00	MOCK_MSG_2_9	2026-09-18 00:00:00+00
32	\N	\N	\N	\N	\N	P4FIX_MSG_3_0	2026-09-18 00:00:00+00	2026-09-18 00:00:00+00	1	P4FIX_APP_1	APPLICATION	P4FIX_APP_1	P4FIX_P4_MSG_3_0	BUSINESS	服务申请已受理	服务申请已受理。请查看相关事项详情并按办理要求完成后续操作。	https://p4.invalid/app/1	2026-09-17 23:00:00+00	MOCK_MSG_3_0	2026-09-18 00:00:00+00
33	\N	\N	\N	\N	\N	P4FIX_MSG_3_1	2026-09-18 00:00:00+00	2026-09-18 00:00:00+00	1	P4FIX_APP_2	APPLICATION	P4FIX_APP_2	P4FIX_P4_MSG_3_1	BUSINESS	资料核验进度通知	资料核验进度通知。请查看相关事项详情并按办理要求完成后续操作。	https://p4.invalid/app/2	2026-09-17 22:00:00+00	MOCK_MSG_3_1	2026-09-18 00:00:00+00
34	\N	\N	\N	\N	\N	P4FIX_MSG_3_2	2026-09-18 00:00:00+00	2026-09-18 00:00:00+00	1	P4FIX_APP_3	APPLICATION	P4FIX_APP_3	P4FIX_P4_MSG_3_2	TODO_REMINDER	办理期限提醒	办理期限提醒。请查看相关事项详情并按办理要求完成后续操作。	https://p4.invalid/app/3	2026-09-17 21:00:00+00	MOCK_MSG_3_2	2026-09-18 00:00:00+00
35	\N	\N	\N	\N	\N	P4FIX_MSG_3_3	2026-09-18 00:00:00+00	2026-09-18 00:00:00+00	1	P4FIX_APP_4	APPLICATION	P4FIX_APP_4	P4FIX_P4_MSG_3_3	BUSINESS	服务安排更新	服务安排更新。请查看相关事项详情并按办理要求完成后续操作。	https://p4.invalid/app/4	2026-09-17 20:00:00+00	MOCK_MSG_3_3	2026-09-18 00:00:00+00
36	\N	\N	\N	\N	\N	P4FIX_MSG_3_4	2026-09-18 00:00:00+00	2026-09-18 00:00:00+00	1	P4FIX_APP_5	APPLICATION	P4FIX_APP_5	P4FIX_P4_MSG_3_4	BUSINESS	账号关联结果通知	账号关联结果通知。请查看相关事项详情并按办理要求完成后续操作。	https://p4.invalid/app/5	2026-09-17 19:00:00+00	MOCK_MSG_3_4	2026-09-18 00:00:00+00
37	\N	\N	\N	\N	\N	P4FIX_MSG_3_5	2026-09-18 00:00:00+00	2026-09-18 00:00:00+00	1	P4FIX_APP_6	APPLICATION	P4FIX_APP_6	P4FIX_P4_MSG_3_5	BUSINESS	业务信息变更提醒	业务信息变更提醒。请查看相关事项详情并按办理要求完成后续操作。	https://p4.invalid/app/6	2026-09-17 18:00:00+00	MOCK_MSG_3_5	2026-09-18 00:00:00+00
38	\N	\N	\N	\N	\N	P4FIX_MSG_3_6	2026-09-18 00:00:00+00	2026-09-18 00:00:00+00	1	P4FIX_APP_7	APPLICATION	P4FIX_APP_7	P4FIX_P4_MSG_3_6	BUSINESS	材料补正通知	材料补正通知。请查看相关事项详情并按办理要求完成后续操作。	https://p4.invalid/app/7	2026-09-17 17:00:00+00	MOCK_MSG_3_6	2026-09-18 00:00:00+00
39	\N	\N	\N	\N	\N	P4FIX_MSG_3_7	2026-09-18 00:00:00+00	2026-09-18 00:00:00+00	1	P4FIX_APP_8	APPLICATION	P4FIX_APP_8	P4FIX_P4_MSG_3_7	BUSINESS	办理意见已反馈	办理意见已反馈。请查看相关事项详情并按办理要求完成后续操作。	https://p4.invalid/app/8	2026-09-17 16:00:00+00	MOCK_MSG_3_7	2026-09-18 00:00:00+00
40	\N	\N	\N	\N	\N	P4FIX_MSG_3_8	2026-09-18 00:00:00+00	2026-09-18 00:00:00+00	1	\N	PORTAL	PORTAL	P4FIX_P4_MSG_3_8	SYSTEM	门户维护安排	门户维护安排。请查看相关事项详情并按办理要求完成后续操作。	\N	2026-09-17 15:00:00+00	MOCK_MSG_3_8	2026-09-18 00:00:00+00
41	\N	\N	\N	\N	\N	P4FIX_MSG_3_9	2026-09-18 00:00:00+00	2026-09-18 00:00:00+00	1	\N	PORTAL	PORTAL	P4FIX_P4_MSG_3_9	SYSTEM	信息安全提醒	信息安全提醒。请查看相关事项详情并按办理要求完成后续操作。	\N	2026-09-17 14:00:00+00	MOCK_MSG_3_9	2026-09-18 00:00:00+00
\.


--
-- Data for Name: message_recipient; Type: TABLE DATA; Schema: pb3gir75kkooyea; Owner: admin
--

COPY pb3gir75kkooyea.message_recipient (nc_id, created_at1, updated_at1, created_by, updated_by, nc_order, id, created_at, updated_at, version, message_id, user_id, read_status, read_at, received_at, deleted_at) FROM stdin;
3	\N	\N	\N	\N	\N	P4FIX_RECIPIENT_MOCK_MSG_0_0	2026-09-18 00:00:00+00	2026-09-18 14:49:21.957+00	2	P4FIX_MSG_0_0	P4FIX_USER_1	READ	2026-09-18 14:49:21.957+00	2026-09-18 00:00:00+00	\N
4	\N	\N	\N	\N	\N	P4FIX_RECIPIENT_MOCK_MSG_0_1	2026-09-18 00:00:00+00	2026-09-18 14:49:35.187+00	2	P4FIX_MSG_0_1	P4FIX_USER_1	READ	2026-09-18 14:49:35.187+00	2026-09-18 00:00:00+00	\N
5	\N	\N	\N	\N	\N	P4FIX_RECIPIENT_MOCK_MSG_0_2	2026-09-18 00:00:00+00	2026-09-18 15:15:56.541+00	2	P4FIX_MSG_0_2	P4FIX_USER_1	READ	2026-09-18 15:15:56.541+00	2026-09-18 00:00:00+00	\N
6	\N	\N	\N	\N	\N	P4FIX_RECIPIENT_MOCK_MSG_0_3	2026-09-18 00:00:00+00	2026-09-18 15:05:14.89+00	2	P4FIX_MSG_0_3	P4FIX_USER_1	READ	2026-09-18 15:05:14.89+00	2026-09-18 00:00:00+00	\N
7	\N	\N	\N	\N	\N	P4FIX_RECIPIENT_MOCK_MSG_0_4	2026-09-18 00:00:00+00	2026-09-18 15:16:22.835+00	2	P4FIX_MSG_0_4	P4FIX_USER_1	READ	2026-09-18 15:16:22.835+00	2026-09-18 00:00:00+00	\N
8	\N	\N	\N	\N	\N	P4FIX_RECIPIENT_MOCK_MSG_0_5	2026-09-18 00:00:00+00	2026-09-18 15:58:30.221+00	2	P4FIX_MSG_0_5	P4FIX_USER_1	READ	2026-09-18 15:58:30.221+00	2026-09-18 00:00:00+00	\N
10	\N	\N	\N	\N	\N	P4FIX_RECIPIENT_MOCK_MSG_0_7	2026-09-18 00:00:00+00	2026-09-18 00:00:00+00	1	P4FIX_MSG_0_7	P4FIX_USER_1	UNREAD	\N	2026-09-18 00:00:00+00	\N
9	\N	\N	\N	\N	\N	P4FIX_RECIPIENT_MOCK_MSG_0_6	2026-09-18 00:00:00+00	2026-09-20 09:39:44.555+00	2	P4FIX_MSG_0_6	P4FIX_USER_1	READ	2026-09-20 09:39:44.555+00	2026-09-18 00:00:00+00	\N
11	\N	\N	\N	\N	\N	P4FIX_RECIPIENT_MOCK_MSG_0_8	2026-09-18 00:00:00+00	2026-09-18 00:00:00+00	1	P4FIX_MSG_0_8	P4FIX_USER_1	READ	2026-09-17 23:00:00+00	2026-09-18 00:00:00+00	\N
12	\N	\N	\N	\N	\N	P4FIX_RECIPIENT_MOCK_MSG_0_9	2026-09-18 00:00:00+00	2026-09-18 00:00:00+00	1	P4FIX_MSG_0_9	P4FIX_USER_1	READ	2026-09-17 23:00:00+00	2026-09-18 00:00:00+00	\N
13	\N	\N	\N	\N	\N	P4FIX_RECIPIENT_MOCK_MSG_1_0	2026-09-18 00:00:00+00	2026-09-18 16:32:04.31+00	2	P4FIX_MSG_1_0	P4FIX_USER_2	READ	2026-09-18 16:32:04.31+00	2026-09-18 00:00:00+00	\N
14	\N	\N	\N	\N	\N	P4FIX_RECIPIENT_MOCK_MSG_1_1	2026-09-18 00:00:00+00	2026-09-18 15:31:44.193+00	2	P4FIX_MSG_1_1	P4FIX_USER_2	READ	2026-09-18 15:31:44.193+00	2026-09-18 00:00:00+00	\N
15	\N	\N	\N	\N	\N	P4FIX_RECIPIENT_MOCK_MSG_1_2	2026-09-18 00:00:00+00	2026-09-18 16:27:06.299+00	2	P4FIX_MSG_1_2	P4FIX_USER_2	READ	2026-09-18 16:27:06.299+00	2026-09-18 00:00:00+00	\N
16	\N	\N	\N	\N	\N	P4FIX_RECIPIENT_MOCK_MSG_1_3	2026-09-18 00:00:00+00	2026-09-18 00:00:00+00	1	P4FIX_MSG_1_3	P4FIX_USER_2	UNREAD	\N	2026-09-18 00:00:00+00	\N
17	\N	\N	\N	\N	\N	P4FIX_RECIPIENT_MOCK_MSG_1_4	2026-09-18 00:00:00+00	2026-09-18 00:00:00+00	1	P4FIX_MSG_1_4	P4FIX_USER_2	UNREAD	\N	2026-09-18 00:00:00+00	\N
18	\N	\N	\N	\N	\N	P4FIX_RECIPIENT_MOCK_MSG_1_5	2026-09-18 00:00:00+00	2026-09-18 00:00:00+00	1	P4FIX_MSG_1_5	P4FIX_USER_2	UNREAD	\N	2026-09-18 00:00:00+00	\N
19	\N	\N	\N	\N	\N	P4FIX_RECIPIENT_MOCK_MSG_1_6	2026-09-18 00:00:00+00	2026-09-18 00:00:00+00	1	P4FIX_MSG_1_6	P4FIX_USER_2	UNREAD	\N	2026-09-18 00:00:00+00	\N
20	\N	\N	\N	\N	\N	P4FIX_RECIPIENT_MOCK_MSG_1_7	2026-09-18 00:00:00+00	2026-09-18 00:00:00+00	1	P4FIX_MSG_1_7	P4FIX_USER_2	UNREAD	\N	2026-09-18 00:00:00+00	\N
21	\N	\N	\N	\N	\N	P4FIX_RECIPIENT_MOCK_MSG_1_8	2026-09-18 00:00:00+00	2026-09-18 00:00:00+00	1	P4FIX_MSG_1_8	P4FIX_USER_2	READ	2026-09-17 23:00:00+00	2026-09-18 00:00:00+00	\N
22	\N	\N	\N	\N	\N	P4FIX_RECIPIENT_MOCK_MSG_1_9	2026-09-18 00:00:00+00	2026-09-18 00:00:00+00	1	P4FIX_MSG_1_9	P4FIX_USER_2	READ	2026-09-17 23:00:00+00	2026-09-18 00:00:00+00	\N
23	\N	\N	\N	\N	\N	P4FIX_RECIPIENT_MOCK_MSG_2_0	2026-09-18 00:00:00+00	2026-09-18 15:48:12.994+00	2	P4FIX_MSG_2_0	P4FIX_ADMIN	READ	2026-09-18 15:48:12.994+00	2026-09-18 00:00:00+00	\N
24	\N	\N	\N	\N	\N	P4FIX_RECIPIENT_MOCK_MSG_2_1	2026-09-18 00:00:00+00	2026-09-18 15:48:33.066+00	2	P4FIX_MSG_2_1	P4FIX_ADMIN	READ	2026-09-18 15:48:33.066+00	2026-09-18 00:00:00+00	\N
25	\N	\N	\N	\N	\N	P4FIX_RECIPIENT_MOCK_MSG_2_2	2026-09-18 00:00:00+00	2026-09-18 16:12:43.994+00	2	P4FIX_MSG_2_2	P4FIX_ADMIN	READ	2026-09-18 16:12:43.994+00	2026-09-18 00:00:00+00	\N
26	\N	\N	\N	\N	\N	P4FIX_RECIPIENT_MOCK_MSG_2_3	2026-09-18 00:00:00+00	2026-09-18 16:13:40.36+00	2	P4FIX_MSG_2_3	P4FIX_ADMIN	READ	2026-09-18 16:13:40.36+00	2026-09-18 00:00:00+00	\N
27	\N	\N	\N	\N	\N	P4FIX_RECIPIENT_MOCK_MSG_2_4	2026-09-18 00:00:00+00	2026-09-19 11:16:27.075+00	2	P4FIX_MSG_2_4	P4FIX_ADMIN	READ	2026-09-19 11:16:27.075+00	2026-09-18 00:00:00+00	\N
28	\N	\N	\N	\N	\N	P4FIX_RECIPIENT_MOCK_MSG_2_5	2026-09-18 00:00:00+00	2026-09-19 12:56:48.398+00	2	P4FIX_MSG_2_5	P4FIX_ADMIN	READ	2026-09-19 12:56:48.398+00	2026-09-18 00:00:00+00	\N
29	\N	\N	\N	\N	\N	P4FIX_RECIPIENT_MOCK_MSG_2_6	2026-09-18 00:00:00+00	2026-09-20 06:54:31.275+00	2	P4FIX_MSG_2_6	P4FIX_ADMIN	READ	2026-09-20 06:54:31.275+00	2026-09-18 00:00:00+00	\N
30	\N	\N	\N	\N	\N	P4FIX_RECIPIENT_MOCK_MSG_2_7	2026-09-18 00:00:00+00	2026-09-20 07:24:30.642+00	2	P4FIX_MSG_2_7	P4FIX_ADMIN	READ	2026-09-20 07:24:30.642+00	2026-09-18 00:00:00+00	\N
31	\N	\N	\N	\N	\N	P4FIX_RECIPIENT_MOCK_MSG_2_8	2026-09-18 00:00:00+00	2026-09-18 00:00:00+00	1	P4FIX_MSG_2_8	P4FIX_ADMIN	READ	2026-09-17 23:00:00+00	2026-09-18 00:00:00+00	\N
32	\N	\N	\N	\N	\N	P4FIX_RECIPIENT_MOCK_MSG_2_9	2026-09-18 00:00:00+00	2026-09-18 00:00:00+00	1	P4FIX_MSG_2_9	P4FIX_ADMIN	READ	2026-09-17 23:00:00+00	2026-09-18 00:00:00+00	\N
33	\N	\N	\N	\N	\N	P4FIX_RECIPIENT_MOCK_MSG_3_0	2026-09-18 00:00:00+00	2026-09-18 00:00:00+00	1	P4FIX_MSG_3_0	P4FIX_EDITOR	UNREAD	\N	2026-09-18 00:00:00+00	\N
34	\N	\N	\N	\N	\N	P4FIX_RECIPIENT_MOCK_MSG_3_1	2026-09-18 00:00:00+00	2026-09-18 00:00:00+00	1	P4FIX_MSG_3_1	P4FIX_EDITOR	UNREAD	\N	2026-09-18 00:00:00+00	\N
35	\N	\N	\N	\N	\N	P4FIX_RECIPIENT_MOCK_MSG_3_2	2026-09-18 00:00:00+00	2026-09-18 00:00:00+00	1	P4FIX_MSG_3_2	P4FIX_EDITOR	UNREAD	\N	2026-09-18 00:00:00+00	\N
36	\N	\N	\N	\N	\N	P4FIX_RECIPIENT_MOCK_MSG_3_3	2026-09-18 00:00:00+00	2026-09-18 00:00:00+00	1	P4FIX_MSG_3_3	P4FIX_EDITOR	UNREAD	\N	2026-09-18 00:00:00+00	\N
37	\N	\N	\N	\N	\N	P4FIX_RECIPIENT_MOCK_MSG_3_4	2026-09-18 00:00:00+00	2026-09-18 00:00:00+00	1	P4FIX_MSG_3_4	P4FIX_EDITOR	UNREAD	\N	2026-09-18 00:00:00+00	\N
38	\N	\N	\N	\N	\N	P4FIX_RECIPIENT_MOCK_MSG_3_5	2026-09-18 00:00:00+00	2026-09-18 00:00:00+00	1	P4FIX_MSG_3_5	P4FIX_EDITOR	UNREAD	\N	2026-09-18 00:00:00+00	\N
39	\N	\N	\N	\N	\N	P4FIX_RECIPIENT_MOCK_MSG_3_6	2026-09-18 00:00:00+00	2026-09-18 00:00:00+00	1	P4FIX_MSG_3_6	P4FIX_EDITOR	UNREAD	\N	2026-09-18 00:00:00+00	\N
40	\N	\N	\N	\N	\N	P4FIX_RECIPIENT_MOCK_MSG_3_7	2026-09-18 00:00:00+00	2026-09-18 00:00:00+00	1	P4FIX_MSG_3_7	P4FIX_EDITOR	UNREAD	\N	2026-09-18 00:00:00+00	\N
41	\N	\N	\N	\N	\N	P4FIX_RECIPIENT_MOCK_MSG_3_8	2026-09-18 00:00:00+00	2026-09-18 00:00:00+00	1	P4FIX_MSG_3_8	P4FIX_EDITOR	READ	2026-09-17 23:00:00+00	2026-09-18 00:00:00+00	\N
42	\N	\N	\N	\N	\N	P4FIX_RECIPIENT_MOCK_MSG_3_9	2026-09-18 00:00:00+00	2026-09-18 00:00:00+00	1	P4FIX_MSG_3_9	P4FIX_EDITOR	READ	2026-09-17 23:00:00+00	2026-09-18 00:00:00+00	\N
\.


--
-- Data for Name: monitor_status; Type: TABLE DATA; Schema: pb3gir75kkooyea; Owner: admin
--

COPY pb3gir75kkooyea.monitor_status (nc_id, created_at1, updated_at1, created_by, updated_by, nc_order, id, created_at, updated_at, version, target_key, service_type, status, last_success_at, last_failure_at, failure_count, response_time_ms, last_error) FROM stdin;
4	\N	\N	\N	\N	\N	P4FIX_MONITOR_3	2026-09-18 00:00:00+00	2026-09-18 00:00:00+00	1	P4FIX_APP_4	IDENTITY	DISABLED	\N	\N	0	\N	\N
1	\N	\N	\N	\N	\N	P4FIX_MONITOR_0	2026-09-18 00:00:00+00	2026-09-19 11:09:56.982+00	1	P4FIX_APP_1	SSO	UNCONFIGURED	\N	\N	0	\N	\N
7	\N	\N	\N	\N	\N	P4FIX_SCENARIO_MONITOR_MOCK_APP_1_TODO	2026-09-19 11:09:56.982+00	2026-09-19 11:09:56.982+00	1	P4FIX_APP_1	TODO	NORMAL	2026-09-19 01:00:00+00	\N	0	126	\N
8	\N	\N	\N	\N	\N	P4FIX_SCENARIO_MONITOR_MOCK_APP_1_MESSAGE	2026-09-19 11:09:56.982+00	2026-09-19 11:09:56.982+00	1	P4FIX_APP_1	MESSAGE	ABNORMAL	\N	2026-09-19 01:00:00+00	1	\N	接口响应超时（场景样本）
9	\N	\N	\N	\N	\N	P4FIX_SCENARIO_MONITOR_MOCK_APP_2_SSO	2026-09-19 11:09:56.982+00	2026-09-19 11:09:56.982+00	1	P4FIX_APP_2	SSO	NORMAL	2026-09-19 01:00:00+00	\N	0	126	\N
2	\N	\N	\N	\N	\N	P4FIX_MONITOR_1	2026-09-18 00:00:00+00	2026-09-19 11:09:56.982+00	1	P4FIX_APP_2	TODO	ABNORMAL	\N	2026-09-19 01:00:00+00	1	\N	接口响应超时（场景样本）
11	\N	\N	\N	\N	\N	P4FIX_SCENARIO_MONITOR_MOCK_APP_2_MESSAGE	2026-09-19 11:09:56.982+00	2026-09-19 11:09:56.982+00	1	P4FIX_APP_2	MESSAGE	DISABLED	\N	\N	0	\N	\N
12	\N	\N	\N	\N	\N	P4FIX_SCENARIO_MONITOR_MOCK_APP_3_SSO	2026-09-19 11:09:56.982+00	2026-09-19 11:09:56.982+00	1	P4FIX_APP_3	SSO	ABNORMAL	\N	2026-09-19 01:00:00+00	1	\N	接口响应超时（场景样本）
13	\N	\N	\N	\N	\N	P4FIX_SCENARIO_MONITOR_MOCK_APP_3_TODO	2026-09-19 11:09:56.982+00	2026-09-19 11:09:56.982+00	1	P4FIX_APP_3	TODO	DISABLED	\N	\N	0	\N	\N
3	\N	\N	\N	\N	\N	P4FIX_MONITOR_2	2026-09-18 00:00:00+00	2026-09-19 11:09:56.982+00	1	P4FIX_APP_3	MESSAGE	UNCONFIGURED	\N	\N	0	\N	\N
15	\N	\N	\N	\N	\N	P4FIX_SCENARIO_MONITOR_MOCK_APP_4_SSO	2026-09-19 11:09:56.982+00	2026-09-19 11:09:56.982+00	1	P4FIX_APP_4	SSO	DISABLED	\N	\N	0	\N	\N
16	\N	\N	\N	\N	\N	P4FIX_SCENARIO_MONITOR_MOCK_APP_4_TODO	2026-09-19 11:09:56.982+00	2026-09-19 11:09:56.982+00	1	P4FIX_APP_4	TODO	UNCONFIGURED	\N	\N	0	\N	\N
17	\N	\N	\N	\N	\N	P4FIX_SCENARIO_MONITOR_MOCK_APP_4_MESSAGE	2026-09-19 11:09:56.982+00	2026-09-19 11:09:56.982+00	1	P4FIX_APP_4	MESSAGE	NORMAL	2026-09-19 01:00:00+00	\N	0	126	\N
\.


--
-- Data for Name: portal_demo_restore_archive; Type: TABLE DATA; Schema: pb3gir75kkooyea; Owner: admin
--

COPY pb3gir75kkooyea.portal_demo_restore_archive (archive_key, resource, runtime_id, original_payload, archived_at, reason) FROM stdin;
\.


--
-- Data for Name: portal_permission; Type: TABLE DATA; Schema: pb3gir75kkooyea; Owner: admin
--

COPY pb3gir75kkooyea.portal_permission (nc_id, created_at1, updated_at1, created_by, updated_by, nc_order, id, created_at, updated_at, version, code, name, kind, route) FROM stdin;
1	\N	\N	\N	\N	\N	P4FIX_PERM_super	2026-09-18 00:00:00+00	2026-09-18 00:00:00+00	1	P4FIX_super	超级管理权限	ACTION	\N
2	\N	\N	\N	\N	\N	P4FIX_PERM_application	2026-09-18 00:00:00+00	2026-09-18 00:00:00+00	1	P4FIX_application	应用管理权限	ACTION	\N
3	\N	\N	\N	\N	\N	P4FIX_PERM_integration	2026-09-18 00:00:00+00	2026-09-18 00:00:00+00	1	P4FIX_integration	集成管理权限	ACTION	\N
4	\N	\N	\N	\N	\N	P4FIX_PERM_announcement	2026-09-18 00:00:00+00	2026-09-18 00:00:00+00	1	P4FIX_announcement	公告管理权限	ACTION	\N
5	\N	\N	\N	\N	\N	P4FIX_PERM_audit	2026-09-18 00:00:00+00	2026-09-18 00:00:00+00	1	P4FIX_audit	审计权限	ACTION	\N
6	\N	\N	\N	\N	\N	P4FIX_PERM_identity	2026-09-18 00:00:00+00	2026-09-18 00:00:00+00	1	P4FIX_identity	身份映射权限	ACTION	\N
\.


--
-- Data for Name: portal_role; Type: TABLE DATA; Schema: pb3gir75kkooyea; Owner: admin
--

COPY pb3gir75kkooyea.portal_role (nc_id, created_at1, updated_at1, created_by, updated_by, nc_order, id, created_at, updated_at, version, code, name, description, status) FROM stdin;
1	\N	\N	\N	\N	\N	P4FIX_ROLE_USER	2026-09-18 00:00:00+00	2026-09-18 00:00:00+00	1	P4FIX_USER	普通用户	P4 fixture；权限范围：本人；不授予来源系统业务权限	ENABLED
2	\N	\N	\N	\N	\N	P4FIX_ROLE_ADMIN	2026-09-18 00:00:00+00	2026-09-18 00:00:00+00	1	P4FIX_ADMIN	门户管理员	P4 fixture；权限范围：超级管理权限、应用管理权限、集成管理权限、公告管理权限、审计权限、身份映射权限；不授予来源系统业务权限	ENABLED
3	\N	\N	\N	\N	\N	P4FIX_ROLE_EDITOR	2026-09-18 00:00:00+00	2026-09-18 00:00:00+00	1	P4FIX_EDITOR	门户管理员	P4 fixture；权限范围：公告管理权限；不授予来源系统业务权限	ENABLED
\.


--
-- Data for Name: portal_role_permission; Type: TABLE DATA; Schema: pb3gir75kkooyea; Owner: admin
--

COPY pb3gir75kkooyea.portal_role_permission (nc_id, created_at1, updated_at1, created_by, updated_by, nc_order, id, created_at, updated_at, version, role_id, permission_id, data_scope) FROM stdin;
1	\N	\N	\N	\N	\N	P4FIX_RP_ADMIN_super	2026-09-18 00:00:00+00	2026-09-18 00:00:00+00	1	P4FIX_ROLE_ADMIN	P4FIX_PERM_super	ALL_PORTAL
2	\N	\N	\N	\N	\N	P4FIX_RP_ADMIN_application	2026-09-18 00:00:00+00	2026-09-18 00:00:00+00	1	P4FIX_ROLE_ADMIN	P4FIX_PERM_application	ALL_PORTAL
3	\N	\N	\N	\N	\N	P4FIX_RP_ADMIN_integration	2026-09-18 00:00:00+00	2026-09-18 00:00:00+00	1	P4FIX_ROLE_ADMIN	P4FIX_PERM_integration	ALL_PORTAL
4	\N	\N	\N	\N	\N	P4FIX_RP_ADMIN_announcement	2026-09-18 00:00:00+00	2026-09-18 00:00:00+00	1	P4FIX_ROLE_ADMIN	P4FIX_PERM_announcement	ALL_PORTAL
5	\N	\N	\N	\N	\N	P4FIX_RP_ADMIN_audit	2026-09-18 00:00:00+00	2026-09-18 00:00:00+00	1	P4FIX_ROLE_ADMIN	P4FIX_PERM_audit	ALL_PORTAL
6	\N	\N	\N	\N	\N	P4FIX_RP_ADMIN_identity	2026-09-18 00:00:00+00	2026-09-18 00:00:00+00	1	P4FIX_ROLE_ADMIN	P4FIX_PERM_identity	ALL_PORTAL
7	\N	\N	\N	\N	\N	P4FIX_RP_EDITOR_announcement	2026-09-18 00:00:00+00	2026-09-18 00:00:00+00	1	P4FIX_ROLE_EDITOR	P4FIX_PERM_announcement	ALL_PORTAL
\.


--
-- Data for Name: portal_runtime_entity; Type: TABLE DATA; Schema: pb3gir75kkooyea; Owner: admin
--

COPY pb3gir75kkooyea.portal_runtime_entity (resource, runtime_id, "position", payload, updated_at) FROM stdin;
users	MOCK_USER_1	0	{"id": "MOCK_USER_1", "kind": "USER", "name": "林晓", "email": "未提供", "mobile": "未提供", "orgKey": "PUBLIC", "scopes": [], "status": "NORMAL", "account": "linxiao", "orgName": "公众服务", "roleIds": [], "jobTitle": "办事人员", "roleName": "普通用户", "userType": "CITIZEN", "department": "个人服务", "identitySource": "闽政通"}	2026-09-23 06:59:56.546313+00
users	MOCK_USER_2	1	{"id": "MOCK_USER_2", "kind": "USER", "name": "陈宁", "email": "未提供", "mobile": "未提供", "orgKey": "HEALTH", "scopes": [], "status": "NORMAL", "account": "chenning", "orgName": "卫生健康业务处", "roleIds": [], "jobTitle": "业务经办", "roleName": "普通用户", "userType": "GOV", "department": "业务协同科", "identitySource": "闽政务"}	2026-09-23 06:59:56.546313+00
users	MOCK_ADMIN	2	{"id": "MOCK_ADMIN", "kind": "ADMIN", "name": "周明", "email": "未提供", "mobile": "未提供", "orgKey": "PORTAL", "scopes": ["super", "application", "integration", "announcement", "audit", "identity"], "status": "NORMAL", "account": "zhouming", "orgName": "门户运行保障中心", "roleIds": ["ROLE_SUPER"], "jobTitle": "系统管理", "roleName": "门户超级管理员", "userType": "GOV", "department": "运行保障科", "identitySource": "闽政务"}	2026-09-23 06:59:56.546313+00
users	MOCK_EDITOR	3	{"id": "MOCK_EDITOR", "kind": "ADMIN", "name": "郑颖", "email": "未提供", "mobile": "未提供", "orgKey": "PORTAL", "scopes": ["announcement"], "status": "NORMAL", "account": "zhengying", "orgName": "门户运行保障中心", "roleIds": ["ROLE_CONTENT"], "jobTitle": "信息编辑", "roleName": "内容管理员", "userType": "GOV", "department": "信息发布科", "identitySource": "闽政务", "scopeDescription": "公告权限"}	2026-09-23 06:59:56.546313+00
roles	ROLE_SUPER	0	{"id": "ROLE_SUPER", "scopes": ["super", "application", "integration", "announcement", "audit", "identity"], "status": "ENABLED", "builtIn": true, "version": 1, "roleCode": "PORTAL_SUPER_ADMIN", "roleName": "门户超级管理员", "createdAt": "2026-09-16T00:00:00.000Z", "updatedAt": "2026-09-17T23:00:00.000Z", "description": "负责门户系统自身的用户、角色、应用、集成、内容、审计等管理，不授予子系统业务权限。"}	2026-09-23 06:59:56.546313+00
roles	ROLE_APP	1	{"id": "ROLE_APP", "scopes": ["application"], "status": "ENABLED", "builtIn": true, "version": 1, "roleCode": "PORTAL_APP_ADMIN", "roleName": "应用管理员", "createdAt": "2026-09-16T00:00:00.000Z", "updatedAt": "2026-09-17T23:00:00.000Z", "description": "维护门户应用目录、分类及应用接入信息。"}	2026-09-23 06:59:56.546313+00
roles	ROLE_CONTENT	2	{"id": "ROLE_CONTENT", "scopes": ["announcement"], "status": "ENABLED", "builtIn": true, "version": 1, "roleCode": "PORTAL_CONTENT_ADMIN", "roleName": "内容管理员", "createdAt": "2026-09-16T00:00:00.000Z", "updatedAt": "2026-09-17T23:00:00.000Z", "description": "维护通知公告等门户内容。"}	2026-09-23 06:59:56.546313+00
roles	ROLE_INTEGRATION	3	{"id": "ROLE_INTEGRATION", "scopes": ["integration"], "status": "ENABLED", "builtIn": true, "version": 1, "roleCode": "PORTAL_INTEGRATION_ADMIN", "roleName": "集成管理员", "createdAt": "2026-09-16T00:00:00.000Z", "updatedAt": "2026-09-17T23:00:00.000Z", "description": "维护SSO、待办、消息等集成配置及运行监控。"}	2026-09-23 06:59:56.546313+00
roles	ROLE_IDENTITY	4	{"id": "ROLE_IDENTITY", "scopes": ["identity"], "status": "ENABLED", "builtIn": true, "version": 1, "roleCode": "PORTAL_IDENTITY_ADMIN", "roleName": "身份映射管理员", "createdAt": "2026-09-16T00:00:00.000Z", "updatedAt": "2026-09-17T23:00:00.000Z", "description": "维护统一身份索引与子系统账号映射。"}	2026-09-23 06:59:56.546313+00
roles	ROLE_AUDIT	5	{"id": "ROLE_AUDIT", "scopes": ["audit"], "status": "ENABLED", "builtIn": true, "version": 1, "roleCode": "PORTAL_AUDITOR", "roleName": "审计员", "createdAt": "2026-09-16T00:00:00.000Z", "updatedAt": "2026-09-17T23:00:00.000Z", "description": "查看门户登录、访问、操作、接口及异常日志。"}	2026-09-23 06:59:56.546313+00
mappings	MOCK_MAP_MOCK_USER_1_1	0	{"id": "MOCK_MAP_MOCK_USER_1_1", "appId": "MOCK_APP_1", "status": "BOUND", "userId": "MOCK_USER_1", "appName": "福建省新生儿疾病筛查管理系统", "boundAt": "2026-09-17T00:00:00.000Z", "version": 1, "userName": "林晓", "createdAt": "2026-09-16T00:00:00.000Z", "updatedAt": "2026-09-17T23:00:00.000Z", "bindingMethod": "ADMIN", "conflictReason": null, "externalUserId": "P4_SUBJECT_MOCK_USER_1_1", "externalAccount": "linxiao_01"}	2026-09-23 06:59:56.546313+00
mappings	MOCK_MAP_MOCK_USER_1_2	1	{"id": "MOCK_MAP_MOCK_USER_1_2", "appId": "MOCK_APP_2", "status": "BOUND", "userId": "MOCK_USER_1", "appName": "福建省妇幼卫生信息系统", "boundAt": "2026-09-17T00:00:00.000Z", "version": 1, "userName": "林晓", "createdAt": "2026-09-16T00:00:00.000Z", "updatedAt": "2026-09-17T23:00:00.000Z", "bindingMethod": "ADMIN", "conflictReason": null, "externalUserId": "P4_SUBJECT_MOCK_USER_1_2", "externalAccount": "linxiao_02"}	2026-09-23 06:59:56.546313+00
mappings	MOCK_MAP_MOCK_USER_1_3	2	{"id": "MOCK_MAP_MOCK_USER_1_3", "appId": "MOCK_APP_3", "status": "BOUND", "userId": "MOCK_USER_1", "appName": "福建省产前筛查与诊断管理系统", "boundAt": "2026-09-17T00:00:00.000Z", "version": 1, "userName": "林晓", "createdAt": "2026-09-16T00:00:00.000Z", "updatedAt": "2026-09-17T23:00:00.000Z", "bindingMethod": "ADMIN", "conflictReason": null, "externalUserId": "P4_SUBJECT_MOCK_USER_1_3", "externalAccount": "linxiao_03"}	2026-09-23 06:59:56.546313+00
mappings	MOCK_MAP_MOCK_USER_1_4	3	{"id": "MOCK_MAP_MOCK_USER_1_4", "appId": "MOCK_APP_4", "status": "BOUND", "userId": "MOCK_USER_1", "appName": "福建省地中海贫血信息管理系统", "boundAt": "2026-09-17T00:00:00.000Z", "version": 1, "userName": "林晓", "createdAt": "2026-09-16T00:00:00.000Z", "updatedAt": "2026-09-17T23:00:00.000Z", "bindingMethod": "ADMIN", "conflictReason": null, "externalUserId": "P4_SUBJECT_MOCK_USER_1_4", "externalAccount": "linxiao_04"}	2026-09-23 06:59:56.546313+00
mappings	MOCK_MAP_MOCK_USER_1_5	4	{"id": "MOCK_MAP_MOCK_USER_1_5", "appId": "MOCK_APP_5", "status": "BOUND", "userId": "MOCK_USER_1", "appName": "福建省慢病报告与管理系统", "boundAt": "2026-09-17T00:00:00.000Z", "version": 1, "userName": "林晓", "createdAt": "2026-09-16T00:00:00.000Z", "updatedAt": "2026-09-17T23:00:00.000Z", "bindingMethod": "ADMIN", "conflictReason": null, "externalUserId": "P4_SUBJECT_MOCK_USER_1_5", "externalAccount": "linxiao_05"}	2026-09-23 06:59:56.546313+00
mappings	MOCK_MAP_MOCK_USER_1_6	5	{"id": "MOCK_MAP_MOCK_USER_1_6", "appId": "MOCK_APP_6", "status": "BOUND", "userId": "MOCK_USER_1", "appName": "福建省区域影像平台", "boundAt": "2026-09-17T00:00:00.000Z", "version": 1, "userName": "林晓", "createdAt": "2026-09-16T00:00:00.000Z", "updatedAt": "2026-09-17T23:00:00.000Z", "bindingMethod": "ADMIN", "conflictReason": null, "externalUserId": "P4_SUBJECT_MOCK_USER_1_6", "externalAccount": "linxiao_06"}	2026-09-23 06:59:56.546313+00
visits	a0cd44eb207229291f09532ff11a0d90	5	{"at": "2026-09-17T22:00:00.000Z", "appId": "MOCK_APP_2", "userId": "MOCK_USER_2"}	2026-09-23 06:59:56.546313+00
visits	4c929c6fbd81b5fa6b7d7833b5ae1615	6	{"at": "2026-09-17T21:00:00.000Z", "appId": "MOCK_APP_3", "userId": "MOCK_USER_2"}	2026-09-23 06:59:56.546313+00
mappings	MOCK_MAP_MOCK_USER_1_11	6	{"id": "MOCK_MAP_MOCK_USER_1_11", "appId": "MOCK_APP_11", "status": "BOUND", "userId": "MOCK_USER_1", "appName": "福建省免疫规划管理信息系统", "boundAt": "2026-09-17T00:00:00.000Z", "version": 1, "userName": "林晓", "createdAt": "2026-09-16T00:00:00.000Z", "updatedAt": "2026-09-17T23:00:00.000Z", "bindingMethod": "ADMIN", "conflictReason": null, "externalUserId": "P4_SUBJECT_MOCK_USER_1_11", "externalAccount": "linxiao_11"}	2026-09-23 06:59:56.546313+00
mappings	MOCK_MAP_MOCK_USER_1_12	7	{"id": "MOCK_MAP_MOCK_USER_1_12", "appId": "MOCK_APP_12", "status": "BOUND", "userId": "MOCK_USER_1", "appName": "中医馆健康信息系统", "boundAt": "2026-09-17T00:00:00.000Z", "version": 1, "userName": "林晓", "createdAt": "2026-09-16T00:00:00.000Z", "updatedAt": "2026-09-17T23:00:00.000Z", "bindingMethod": "ADMIN", "conflictReason": null, "externalUserId": "P4_SUBJECT_MOCK_USER_1_12", "externalAccount": "linxiao_12"}	2026-09-23 06:59:56.546313+00
mappings	MOCK_MAP_MOCK_USER_1_26	8	{"id": "MOCK_MAP_MOCK_USER_1_26", "appId": "MOCK_APP_26", "status": "FAILED", "userId": "MOCK_USER_1", "appName": "福建省中医医术确有专长人员医师资格考核报名系统", "boundAt": null, "version": 1, "userName": "林晓", "createdAt": "2026-09-16T00:00:00.000Z", "updatedAt": "2026-09-17T23:00:00.000Z", "bindingMethod": "ADMIN", "conflictReason": "账号核验未通过，待补充关联资料", "externalUserId": "P4_SUBJECT_MOCK_USER_1_26", "externalAccount": "linxiao_26"}	2026-09-23 06:59:56.546313+00
mappings	MOCK_MAP_MOCK_USER_1_28	9	{"id": "MOCK_MAP_MOCK_USER_1_28", "appId": "MOCK_APP_28", "status": "CONFLICT", "userId": "MOCK_USER_1", "appName": "福建省卫生专业技术资格考试报名系统", "boundAt": null, "version": 1, "userName": "林晓", "createdAt": "2026-09-16T00:00:00.000Z", "updatedAt": "2026-09-17T23:00:00.000Z", "bindingMethod": "ADMIN", "conflictReason": "身份资料不一致，待人工核查", "externalUserId": "P4_SUBJECT_MOCK_USER_1_28", "externalAccount": "linxiao_28"}	2026-09-23 06:59:56.546313+00
mappings	MOCK_MAP_MOCK_USER_2_1	10	{"id": "MOCK_MAP_MOCK_USER_2_1", "appId": "MOCK_APP_1", "status": "BOUND", "userId": "MOCK_USER_2", "appName": "福建省新生儿疾病筛查管理系统", "boundAt": "2026-09-17T00:00:00.000Z", "version": 1, "userName": "陈宁", "createdAt": "2026-09-16T00:00:00.000Z", "updatedAt": "2026-09-17T23:00:00.000Z", "bindingMethod": "ADMIN", "conflictReason": null, "externalUserId": "P4_SUBJECT_MOCK_USER_2_1", "externalAccount": "chenning_01"}	2026-09-23 06:59:56.546313+00
mappings	MOCK_MAP_MOCK_USER_2_2	11	{"id": "MOCK_MAP_MOCK_USER_2_2", "appId": "MOCK_APP_2", "status": "BOUND", "userId": "MOCK_USER_2", "appName": "福建省妇幼卫生信息系统", "boundAt": "2026-09-17T00:00:00.000Z", "version": 1, "userName": "陈宁", "createdAt": "2026-09-16T00:00:00.000Z", "updatedAt": "2026-09-17T23:00:00.000Z", "bindingMethod": "ADMIN", "conflictReason": null, "externalUserId": "P4_SUBJECT_MOCK_USER_2_2", "externalAccount": "chenning_02"}	2026-09-23 06:59:56.546313+00
mappings	MOCK_MAP_MOCK_USER_2_3	12	{"id": "MOCK_MAP_MOCK_USER_2_3", "appId": "MOCK_APP_3", "status": "BOUND", "userId": "MOCK_USER_2", "appName": "福建省产前筛查与诊断管理系统", "boundAt": "2026-09-17T00:00:00.000Z", "version": 1, "userName": "陈宁", "createdAt": "2026-09-16T00:00:00.000Z", "updatedAt": "2026-09-17T23:00:00.000Z", "bindingMethod": "ADMIN", "conflictReason": null, "externalUserId": "P4_SUBJECT_MOCK_USER_2_3", "externalAccount": "chenning_03"}	2026-09-23 06:59:56.546313+00
mappings	MOCK_MAP_MOCK_USER_2_4	13	{"id": "MOCK_MAP_MOCK_USER_2_4", "appId": "MOCK_APP_4", "status": "BOUND", "userId": "MOCK_USER_2", "appName": "福建省地中海贫血信息管理系统", "boundAt": "2026-09-17T00:00:00.000Z", "version": 1, "userName": "陈宁", "createdAt": "2026-09-16T00:00:00.000Z", "updatedAt": "2026-09-17T23:00:00.000Z", "bindingMethod": "ADMIN", "conflictReason": null, "externalUserId": "P4_SUBJECT_MOCK_USER_2_4", "externalAccount": "chenning_04"}	2026-09-23 06:59:56.546313+00
mappings	MOCK_MAP_MOCK_USER_2_5	14	{"id": "MOCK_MAP_MOCK_USER_2_5", "appId": "MOCK_APP_5", "status": "BOUND", "userId": "MOCK_USER_2", "appName": "福建省慢病报告与管理系统", "boundAt": "2026-09-17T00:00:00.000Z", "version": 1, "userName": "陈宁", "createdAt": "2026-09-16T00:00:00.000Z", "updatedAt": "2026-09-17T23:00:00.000Z", "bindingMethod": "ADMIN", "conflictReason": null, "externalUserId": "P4_SUBJECT_MOCK_USER_2_5", "externalAccount": "chenning_05"}	2026-09-23 06:59:56.546313+00
mappings	MOCK_MAP_MOCK_USER_2_6	15	{"id": "MOCK_MAP_MOCK_USER_2_6", "appId": "MOCK_APP_6", "status": "BOUND", "userId": "MOCK_USER_2", "appName": "福建省区域影像平台", "boundAt": "2026-09-17T00:00:00.000Z", "version": 1, "userName": "陈宁", "createdAt": "2026-09-16T00:00:00.000Z", "updatedAt": "2026-09-17T23:00:00.000Z", "bindingMethod": "ADMIN", "conflictReason": null, "externalUserId": "P4_SUBJECT_MOCK_USER_2_6", "externalAccount": "chenning_06"}	2026-09-23 06:59:56.546313+00
mappings	MOCK_MAP_MOCK_USER_2_7	16	{"id": "MOCK_MAP_MOCK_USER_2_7", "appId": "MOCK_APP_7", "status": "BOUND", "userId": "MOCK_USER_2", "appName": "质控评分系统", "boundAt": "2026-09-17T00:00:00.000Z", "version": 1, "userName": "陈宁", "createdAt": "2026-09-16T00:00:00.000Z", "updatedAt": "2026-09-17T23:00:00.000Z", "bindingMethod": "ADMIN", "conflictReason": null, "externalUserId": "P4_SUBJECT_MOCK_USER_2_7", "externalAccount": "chenning_07"}	2026-09-23 06:59:56.546313+00
mappings	MOCK_MAP_MOCK_USER_2_8	17	{"id": "MOCK_MAP_MOCK_USER_2_8", "appId": "MOCK_APP_8", "status": "BOUND", "userId": "MOCK_USER_2", "appName": "省级平台决策支持展示系统", "boundAt": "2026-09-17T00:00:00.000Z", "version": 1, "userName": "陈宁", "createdAt": "2026-09-16T00:00:00.000Z", "updatedAt": "2026-09-17T23:00:00.000Z", "bindingMethod": "ADMIN", "conflictReason": null, "externalUserId": "P4_SUBJECT_MOCK_USER_2_8", "externalAccount": "chenning_08"}	2026-09-23 06:59:56.546313+00
mappings	MOCK_MAP_MOCK_USER_2_26	18	{"id": "MOCK_MAP_MOCK_USER_2_26", "appId": "MOCK_APP_26", "status": "FAILED", "userId": "MOCK_USER_2", "appName": "福建省中医医术确有专长人员医师资格考核报名系统", "boundAt": null, "version": 1, "userName": "陈宁", "createdAt": "2026-09-16T00:00:00.000Z", "updatedAt": "2026-09-17T23:00:00.000Z", "bindingMethod": "ADMIN", "conflictReason": "账号核验未通过，待补充关联资料", "externalUserId": "P4_SUBJECT_MOCK_USER_2_26", "externalAccount": "chenning_26"}	2026-09-23 06:59:56.546313+00
mappings	MOCK_MAP_MOCK_USER_2_28	19	{"id": "MOCK_MAP_MOCK_USER_2_28", "appId": "MOCK_APP_28", "status": "CONFLICT", "userId": "MOCK_USER_2", "appName": "福建省卫生专业技术资格考试报名系统", "boundAt": null, "version": 1, "userName": "陈宁", "createdAt": "2026-09-16T00:00:00.000Z", "updatedAt": "2026-09-17T23:00:00.000Z", "bindingMethod": "ADMIN", "conflictReason": "身份资料不一致，待人工核查", "externalUserId": "P4_SUBJECT_MOCK_USER_2_28", "externalAccount": "chenning_28"}	2026-09-23 06:59:56.546313+00
mappings	MOCK_MAP_MOCK_ADMIN_1	20	{"id": "MOCK_MAP_MOCK_ADMIN_1", "appId": "MOCK_APP_1", "status": "BOUND", "userId": "MOCK_ADMIN", "appName": "福建省新生儿疾病筛查管理系统", "boundAt": "2026-09-17T00:00:00.000Z", "version": 1, "userName": "周明", "createdAt": "2026-09-16T00:00:00.000Z", "updatedAt": "2026-09-17T23:00:00.000Z", "bindingMethod": "ADMIN", "conflictReason": null, "externalUserId": "P4_SUBJECT_MOCK_ADMIN_1", "externalAccount": "zhouming_01"}	2026-09-23 06:59:56.546313+00
mappings	MOCK_MAP_MOCK_ADMIN_2	21	{"id": "MOCK_MAP_MOCK_ADMIN_2", "appId": "MOCK_APP_2", "status": "BOUND", "userId": "MOCK_ADMIN", "appName": "福建省妇幼卫生信息系统", "boundAt": "2026-09-17T00:00:00.000Z", "version": 1, "userName": "周明", "createdAt": "2026-09-16T00:00:00.000Z", "updatedAt": "2026-09-17T23:00:00.000Z", "bindingMethod": "ADMIN", "conflictReason": null, "externalUserId": "P4_SUBJECT_MOCK_ADMIN_2", "externalAccount": "zhouming_02"}	2026-09-23 06:59:56.546313+00
mappings	MOCK_MAP_MOCK_ADMIN_3	22	{"id": "MOCK_MAP_MOCK_ADMIN_3", "appId": "MOCK_APP_3", "status": "BOUND", "userId": "MOCK_ADMIN", "appName": "福建省产前筛查与诊断管理系统", "boundAt": "2026-09-17T00:00:00.000Z", "version": 1, "userName": "周明", "createdAt": "2026-09-16T00:00:00.000Z", "updatedAt": "2026-09-17T23:00:00.000Z", "bindingMethod": "ADMIN", "conflictReason": null, "externalUserId": "P4_SUBJECT_MOCK_ADMIN_3", "externalAccount": "zhouming_03"}	2026-09-23 06:59:56.546313+00
mappings	MOCK_MAP_MOCK_ADMIN_4	23	{"id": "MOCK_MAP_MOCK_ADMIN_4", "appId": "MOCK_APP_4", "status": "BOUND", "userId": "MOCK_ADMIN", "appName": "福建省地中海贫血信息管理系统", "boundAt": "2026-09-17T00:00:00.000Z", "version": 1, "userName": "周明", "createdAt": "2026-09-16T00:00:00.000Z", "updatedAt": "2026-09-17T23:00:00.000Z", "bindingMethod": "ADMIN", "conflictReason": null, "externalUserId": "P4_SUBJECT_MOCK_ADMIN_4", "externalAccount": "zhouming_04"}	2026-09-23 06:59:56.546313+00
mappings	MOCK_MAP_MOCK_ADMIN_5	24	{"id": "MOCK_MAP_MOCK_ADMIN_5", "appId": "MOCK_APP_5", "status": "BOUND", "userId": "MOCK_ADMIN", "appName": "福建省慢病报告与管理系统", "boundAt": "2026-09-17T00:00:00.000Z", "version": 1, "userName": "周明", "createdAt": "2026-09-16T00:00:00.000Z", "updatedAt": "2026-09-17T23:00:00.000Z", "bindingMethod": "ADMIN", "conflictReason": null, "externalUserId": "P4_SUBJECT_MOCK_ADMIN_5", "externalAccount": "zhouming_05"}	2026-09-23 06:59:56.546313+00
mappings	MOCK_MAP_MOCK_ADMIN_6	25	{"id": "MOCK_MAP_MOCK_ADMIN_6", "appId": "MOCK_APP_6", "status": "BOUND", "userId": "MOCK_ADMIN", "appName": "福建省区域影像平台", "boundAt": "2026-09-17T00:00:00.000Z", "version": 1, "userName": "周明", "createdAt": "2026-09-16T00:00:00.000Z", "updatedAt": "2026-09-17T23:00:00.000Z", "bindingMethod": "ADMIN", "conflictReason": null, "externalUserId": "P4_SUBJECT_MOCK_ADMIN_6", "externalAccount": "zhouming_06"}	2026-09-23 06:59:56.546313+00
mappings	MOCK_MAP_MOCK_ADMIN_7	26	{"id": "MOCK_MAP_MOCK_ADMIN_7", "appId": "MOCK_APP_7", "status": "BOUND", "userId": "MOCK_ADMIN", "appName": "质控评分系统", "boundAt": "2026-09-17T00:00:00.000Z", "version": 1, "userName": "周明", "createdAt": "2026-09-16T00:00:00.000Z", "updatedAt": "2026-09-17T23:00:00.000Z", "bindingMethod": "ADMIN", "conflictReason": null, "externalUserId": "P4_SUBJECT_MOCK_ADMIN_7", "externalAccount": "zhouming_07"}	2026-09-23 06:59:56.546313+00
mappings	MOCK_MAP_MOCK_ADMIN_8	27	{"id": "MOCK_MAP_MOCK_ADMIN_8", "appId": "MOCK_APP_8", "status": "BOUND", "userId": "MOCK_ADMIN", "appName": "省级平台决策支持展示系统", "boundAt": "2026-09-17T00:00:00.000Z", "version": 1, "userName": "周明", "createdAt": "2026-09-16T00:00:00.000Z", "updatedAt": "2026-09-17T23:00:00.000Z", "bindingMethod": "ADMIN", "conflictReason": null, "externalUserId": "P4_SUBJECT_MOCK_ADMIN_8", "externalAccount": "zhouming_08"}	2026-09-23 06:59:56.546313+00
mappings	MOCK_MAP_MOCK_ADMIN_26	28	{"id": "MOCK_MAP_MOCK_ADMIN_26", "appId": "MOCK_APP_26", "status": "FAILED", "userId": "MOCK_ADMIN", "appName": "福建省中医医术确有专长人员医师资格考核报名系统", "boundAt": null, "version": 1, "userName": "周明", "createdAt": "2026-09-16T00:00:00.000Z", "updatedAt": "2026-09-17T23:00:00.000Z", "bindingMethod": "ADMIN", "conflictReason": "账号核验未通过，待补充关联资料", "externalUserId": "P4_SUBJECT_MOCK_ADMIN_26", "externalAccount": "zhouming_26"}	2026-09-23 06:59:56.546313+00
mappings	MOCK_MAP_MOCK_ADMIN_28	29	{"id": "MOCK_MAP_MOCK_ADMIN_28", "appId": "MOCK_APP_28", "status": "CONFLICT", "userId": "MOCK_ADMIN", "appName": "福建省卫生专业技术资格考试报名系统", "boundAt": null, "version": 1, "userName": "周明", "createdAt": "2026-09-16T00:00:00.000Z", "updatedAt": "2026-09-17T23:00:00.000Z", "bindingMethod": "ADMIN", "conflictReason": "身份资料不一致，待人工核查", "externalUserId": "P4_SUBJECT_MOCK_ADMIN_28", "externalAccount": "zhouming_28"}	2026-09-23 06:59:56.546313+00
mappings	MOCK_MAP_MOCK_EDITOR_1	30	{"id": "MOCK_MAP_MOCK_EDITOR_1", "appId": "MOCK_APP_1", "status": "BOUND", "userId": "MOCK_EDITOR", "appName": "福建省新生儿疾病筛查管理系统", "boundAt": "2026-09-17T00:00:00.000Z", "version": 1, "userName": "郑颖", "createdAt": "2026-09-16T00:00:00.000Z", "updatedAt": "2026-09-17T23:00:00.000Z", "bindingMethod": "ADMIN", "conflictReason": null, "externalUserId": "P4_SUBJECT_MOCK_EDITOR_1", "externalAccount": "zhengying_01"}	2026-09-23 06:59:56.546313+00
mappings	MOCK_MAP_MOCK_EDITOR_2	31	{"id": "MOCK_MAP_MOCK_EDITOR_2", "appId": "MOCK_APP_2", "status": "BOUND", "userId": "MOCK_EDITOR", "appName": "福建省妇幼卫生信息系统", "boundAt": "2026-09-17T00:00:00.000Z", "version": 1, "userName": "郑颖", "createdAt": "2026-09-16T00:00:00.000Z", "updatedAt": "2026-09-17T23:00:00.000Z", "bindingMethod": "ADMIN", "conflictReason": null, "externalUserId": "P4_SUBJECT_MOCK_EDITOR_2", "externalAccount": "zhengying_02"}	2026-09-23 06:59:56.546313+00
mappings	MOCK_MAP_MOCK_EDITOR_3	32	{"id": "MOCK_MAP_MOCK_EDITOR_3", "appId": "MOCK_APP_3", "status": "BOUND", "userId": "MOCK_EDITOR", "appName": "福建省产前筛查与诊断管理系统", "boundAt": "2026-09-17T00:00:00.000Z", "version": 1, "userName": "郑颖", "createdAt": "2026-09-16T00:00:00.000Z", "updatedAt": "2026-09-17T23:00:00.000Z", "bindingMethod": "ADMIN", "conflictReason": null, "externalUserId": "P4_SUBJECT_MOCK_EDITOR_3", "externalAccount": "zhengying_03"}	2026-09-23 06:59:56.546313+00
mappings	MOCK_MAP_MOCK_EDITOR_4	33	{"id": "MOCK_MAP_MOCK_EDITOR_4", "appId": "MOCK_APP_4", "status": "BOUND", "userId": "MOCK_EDITOR", "appName": "福建省地中海贫血信息管理系统", "boundAt": "2026-09-17T00:00:00.000Z", "version": 1, "userName": "郑颖", "createdAt": "2026-09-16T00:00:00.000Z", "updatedAt": "2026-09-17T23:00:00.000Z", "bindingMethod": "ADMIN", "conflictReason": null, "externalUserId": "P4_SUBJECT_MOCK_EDITOR_4", "externalAccount": "zhengying_04"}	2026-09-23 06:59:56.546313+00
mappings	MOCK_MAP_MOCK_EDITOR_5	34	{"id": "MOCK_MAP_MOCK_EDITOR_5", "appId": "MOCK_APP_5", "status": "BOUND", "userId": "MOCK_EDITOR", "appName": "福建省慢病报告与管理系统", "boundAt": "2026-09-17T00:00:00.000Z", "version": 1, "userName": "郑颖", "createdAt": "2026-09-16T00:00:00.000Z", "updatedAt": "2026-09-17T23:00:00.000Z", "bindingMethod": "ADMIN", "conflictReason": null, "externalUserId": "P4_SUBJECT_MOCK_EDITOR_5", "externalAccount": "zhengying_05"}	2026-09-23 06:59:56.546313+00
mappings	MOCK_MAP_MOCK_EDITOR_6	35	{"id": "MOCK_MAP_MOCK_EDITOR_6", "appId": "MOCK_APP_6", "status": "BOUND", "userId": "MOCK_EDITOR", "appName": "福建省区域影像平台", "boundAt": "2026-09-17T00:00:00.000Z", "version": 1, "userName": "郑颖", "createdAt": "2026-09-16T00:00:00.000Z", "updatedAt": "2026-09-17T23:00:00.000Z", "bindingMethod": "ADMIN", "conflictReason": null, "externalUserId": "P4_SUBJECT_MOCK_EDITOR_6", "externalAccount": "zhengying_06"}	2026-09-23 06:59:56.546313+00
mappings	MOCK_MAP_MOCK_EDITOR_7	36	{"id": "MOCK_MAP_MOCK_EDITOR_7", "appId": "MOCK_APP_7", "status": "BOUND", "userId": "MOCK_EDITOR", "appName": "质控评分系统", "boundAt": "2026-09-17T00:00:00.000Z", "version": 1, "userName": "郑颖", "createdAt": "2026-09-16T00:00:00.000Z", "updatedAt": "2026-09-17T23:00:00.000Z", "bindingMethod": "ADMIN", "conflictReason": null, "externalUserId": "P4_SUBJECT_MOCK_EDITOR_7", "externalAccount": "zhengying_07"}	2026-09-23 06:59:56.546313+00
mappings	MOCK_MAP_MOCK_EDITOR_8	37	{"id": "MOCK_MAP_MOCK_EDITOR_8", "appId": "MOCK_APP_8", "status": "BOUND", "userId": "MOCK_EDITOR", "appName": "省级平台决策支持展示系统", "boundAt": "2026-09-17T00:00:00.000Z", "version": 1, "userName": "郑颖", "createdAt": "2026-09-16T00:00:00.000Z", "updatedAt": "2026-09-17T23:00:00.000Z", "bindingMethod": "ADMIN", "conflictReason": null, "externalUserId": "P4_SUBJECT_MOCK_EDITOR_8", "externalAccount": "zhengying_08"}	2026-09-23 06:59:56.546313+00
mappings	MOCK_MAP_MOCK_EDITOR_26	38	{"id": "MOCK_MAP_MOCK_EDITOR_26", "appId": "MOCK_APP_26", "status": "FAILED", "userId": "MOCK_EDITOR", "appName": "福建省中医医术确有专长人员医师资格考核报名系统", "boundAt": null, "version": 1, "userName": "郑颖", "createdAt": "2026-09-16T00:00:00.000Z", "updatedAt": "2026-09-17T23:00:00.000Z", "bindingMethod": "ADMIN", "conflictReason": "账号核验未通过，待补充关联资料", "externalUserId": "P4_SUBJECT_MOCK_EDITOR_26", "externalAccount": "zhengying_26"}	2026-09-23 06:59:56.546313+00
mappings	MOCK_MAP_MOCK_EDITOR_28	39	{"id": "MOCK_MAP_MOCK_EDITOR_28", "appId": "MOCK_APP_28", "status": "CONFLICT", "userId": "MOCK_EDITOR", "appName": "福建省卫生专业技术资格考试报名系统", "boundAt": null, "version": 1, "userName": "郑颖", "createdAt": "2026-09-16T00:00:00.000Z", "updatedAt": "2026-09-17T23:00:00.000Z", "bindingMethod": "ADMIN", "conflictReason": "身份资料不一致，待人工核查", "externalUserId": "P4_SUBJECT_MOCK_EDITOR_28", "externalAccount": "zhengying_28"}	2026-09-23 06:59:56.546313+00
settings	MOCK_CONFIG_0	0	{"id": "MOCK_CONFIG_0", "code": "retention.message_days", "name": "消息留存周期（天）", "unit": "day", "value": 90, "status": "CONFIGURED", "version": 3, "createdAt": "2026-09-16T00:00:00.000Z", "updatedAt": "2026-09-18T17:28:40.527Z"}	2026-09-23 06:59:56.546313+00
settings	MOCK_CONFIG_1	1	{"id": "MOCK_CONFIG_1", "code": "retention.todo_terminal_days", "name": "终态待办留存周期（天）", "unit": "day", "value": 180, "status": "CONFIGURED", "version": 3, "createdAt": "2026-09-16T00:00:00.000Z", "updatedAt": "2026-09-18T17:28:40.527Z"}	2026-09-23 06:59:56.546313+00
settings	MOCK_CONFIG_2	2	{"id": "MOCK_CONFIG_2", "code": "retention.log_days", "name": "日志留存周期（天）", "unit": "day", "value": 180, "status": "CONFIGURED", "version": 3, "createdAt": "2026-09-16T00:00:00.000Z", "updatedAt": "2026-09-18T17:28:40.527Z"}	2026-09-23 06:59:56.546313+00
settings	MOCK_CONFIG_3	3	{"id": "MOCK_CONFIG_3", "code": "auth.session_ttl_seconds", "name": "会话有效期（秒）", "unit": "second", "value": 7200, "status": "CONFIGURED", "version": 3, "createdAt": "2026-09-16T00:00:00.000Z", "updatedAt": "2026-09-18T17:28:40.527Z"}	2026-09-23 06:59:56.546313+00
settings	MOCK_CONFIG_4	4	{"id": "MOCK_CONFIG_4", "code": "integration.timeout_ms", "name": "接口超时（毫秒）", "unit": "millisecond", "value": 5000, "status": "CONFIGURED", "version": 3, "createdAt": "2026-09-16T00:00:00.000Z", "updatedAt": "2026-09-18T17:28:40.527Z"}	2026-09-23 06:59:56.546313+00
settings	MOCK_CONFIG_5	5	{"id": "MOCK_CONFIG_5", "code": "integration.max_retries", "name": "接口重试上限", "unit": "count", "value": 3, "status": "CONFIGURED", "version": 3, "createdAt": "2026-09-16T00:00:00.000Z", "updatedAt": "2026-09-18T17:28:40.527Z"}	2026-09-23 06:59:56.546313+00
settings	MOCK_CONFIG_6	6	{"id": "MOCK_CONFIG_6", "code": "monitor.failure_threshold", "name": "连续失败告警阈值", "unit": "count", "value": 5, "status": "CONFIGURED", "version": 3, "createdAt": "2026-09-16T00:00:00.000Z", "updatedAt": "2026-09-18T17:28:40.527Z"}	2026-09-23 06:59:56.546313+00
settings	MOCK_CONFIG_7	7	{"id": "MOCK_CONFIG_7", "code": "portal.page_size", "name": "列表每页条数", "unit": "count", "value": 15, "status": "CONFIGURED", "version": 3, "createdAt": "2026-09-16T00:00:00.000Z", "updatedAt": "2026-09-18T17:28:40.527Z"}	2026-09-23 06:59:56.546313+00
settings	RULE_retention.announcement_expired_days	8	{"id": "RULE_retention.announcement_expired_days", "max": 3650, "min": 0, "code": "retention.announcement_expired_days", "help": "0 表示不自动删除；仅处理已发布且有失效时间的公告。清理记录保留在回收档案和审计中。", "name": "公告过期后自动删除", "unit": "天", "group": "公告规则", "value": 0, "status": "CONFIGURED", "default": 0, "version": 3, "updatedAt": "2026-09-18T17:28:40.527Z"}	2026-09-23 06:59:56.546313+00
integrations	MOCK_INT_MOCK_APP_1SSO	0	{"id": "MOCK_INT_MOCK_APP_1SSO", "kind": "SSO", "mode": "SSO", "name": "福建省新生儿疾病筛查管理系统 · SSO", "appId": "MOCK_APP_1", "remark": "接入参数待业务系统确认", "status": "UNCONFIGURED", "appName": "福建省新生儿疾病筛查管理系统", "enabled": "DISABLED", "version": 1, "createdAt": "2026-09-16T00:00:00.000Z", "updatedAt": "2026-09-17T23:00:00.000Z", "valueMapping": {}, "lastCheckedAt": "2026-09-17T23:00:00.000Z", "connectionStatus": "UNCONFIGURED"}	2026-09-23 06:59:56.546313+00
integrations	MOCK_INT_MOCK_APP_1TODO	1	{"id": "MOCK_INT_MOCK_APP_1TODO", "kind": "TODO", "mode": "PUSH", "name": "福建省新生儿疾病筛查管理系统 · TODO", "appId": "MOCK_APP_1", "remark": "接入参数待业务系统确认", "status": "DISABLED", "appName": "福建省新生儿疾病筛查管理系统", "enabled": "DISABLED", "version": 2, "clientId": "", "protocol": "PUSH", "tokenUrl": "", "createdAt": "2026-09-16T00:00:00.000Z", "updatedAt": "2026-09-18T14:50:14.759Z", "callbackUrl": "", "authorizeUrl": "", "fieldMapping": {}, "valueMapping": {}, "credentialRef": "", "lastCheckedAt": "2026-09-17T22:00:00.000Z", "connectionStatus": "UNCONFIGURED"}	2026-09-23 06:59:56.546313+00
integrations	MOCK_INT_MOCK_APP_1MESSAGE	2	{"id": "MOCK_INT_MOCK_APP_1MESSAGE", "kind": "MESSAGE", "mode": "PUSH", "name": "福建省新生儿疾病筛查管理系统 · MESSAGE", "appId": "MOCK_APP_1", "remark": "接入参数待业务系统确认", "status": "UNCONFIGURED", "appName": "福建省新生儿疾病筛查管理系统", "enabled": "DISABLED", "version": 1, "createdAt": "2026-09-16T00:00:00.000Z", "updatedAt": "2026-09-17T23:00:00.000Z", "valueMapping": {}, "lastCheckedAt": "2026-09-17T21:00:00.000Z", "connectionStatus": "UNCONFIGURED"}	2026-09-23 06:59:56.546313+00
integrations	MOCK_INT_MOCK_APP_2SSO	3	{"id": "MOCK_INT_MOCK_APP_2SSO", "kind": "SSO", "mode": "SSO", "name": "福建省妇幼卫生信息系统 · SSO", "appId": "MOCK_APP_2", "remark": "接入参数待业务系统确认", "status": "UNCONFIGURED", "appName": "福建省妇幼卫生信息系统", "enabled": "DISABLED", "version": 1, "createdAt": "2026-09-16T00:00:00.000Z", "updatedAt": "2026-09-17T23:00:00.000Z", "valueMapping": {}, "lastCheckedAt": "2026-09-17T23:00:00.000Z", "connectionStatus": "UNCONFIGURED"}	2026-09-23 06:59:56.546313+00
integrations	MOCK_INT_MOCK_APP_2TODO	4	{"id": "MOCK_INT_MOCK_APP_2TODO", "kind": "TODO", "mode": "PUSH", "name": "福建省妇幼卫生信息系统 · TODO", "appId": "MOCK_APP_2", "remark": "接入参数待业务系统确认", "status": "UNCONFIGURED", "appName": "福建省妇幼卫生信息系统", "enabled": "DISABLED", "version": 1, "createdAt": "2026-09-16T00:00:00.000Z", "updatedAt": "2026-09-17T23:00:00.000Z", "valueMapping": {}, "lastCheckedAt": "2026-09-17T22:00:00.000Z", "connectionStatus": "UNCONFIGURED"}	2026-09-23 06:59:56.546313+00
integrations	MOCK_INT_MOCK_APP_2MESSAGE	5	{"id": "MOCK_INT_MOCK_APP_2MESSAGE", "kind": "MESSAGE", "mode": "PUSH", "name": "福建省妇幼卫生信息系统 · MESSAGE", "appId": "MOCK_APP_2", "remark": "接入参数待业务系统确认", "status": "DISABLED", "appName": "福建省妇幼卫生信息系统", "enabled": "DISABLED", "version": 1, "createdAt": "2026-09-16T00:00:00.000Z", "updatedAt": "2026-09-17T23:00:00.000Z", "valueMapping": {}, "lastCheckedAt": "2026-09-17T21:00:00.000Z", "connectionStatus": "UNCONFIGURED"}	2026-09-23 06:59:56.546313+00
integrations	MOCK_INT_MOCK_APP_3SSO	6	{"id": "MOCK_INT_MOCK_APP_3SSO", "kind": "SSO", "mode": "SSO", "name": "福建省产前筛查与诊断管理系统 · SSO", "appId": "MOCK_APP_3", "remark": "接入参数待业务系统确认", "status": "UNCONFIGURED", "appName": "福建省产前筛查与诊断管理系统", "enabled": "DISABLED", "version": 1, "createdAt": "2026-09-16T00:00:00.000Z", "updatedAt": "2026-09-17T23:00:00.000Z", "valueMapping": {}, "lastCheckedAt": "2026-09-17T23:00:00.000Z", "connectionStatus": "UNCONFIGURED"}	2026-09-23 06:59:56.546313+00
integrations	MOCK_INT_MOCK_APP_3TODO	7	{"id": "MOCK_INT_MOCK_APP_3TODO", "kind": "TODO", "mode": "PUSH", "name": "福建省产前筛查与诊断管理系统 · TODO", "appId": "MOCK_APP_3", "remark": "接入参数待业务系统确认", "status": "DISABLED", "appName": "福建省产前筛查与诊断管理系统", "enabled": "DISABLED", "version": 1, "createdAt": "2026-09-16T00:00:00.000Z", "updatedAt": "2026-09-17T23:00:00.000Z", "valueMapping": {}, "lastCheckedAt": "2026-09-17T22:00:00.000Z", "connectionStatus": "UNCONFIGURED"}	2026-09-23 06:59:56.546313+00
integrations	MOCK_INT_MOCK_APP_3MESSAGE	8	{"id": "MOCK_INT_MOCK_APP_3MESSAGE", "kind": "MESSAGE", "mode": "PUSH", "name": "福建省产前筛查与诊断管理系统 · MESSAGE", "appId": "MOCK_APP_3", "remark": "接入参数待业务系统确认", "status": "UNCONFIGURED", "appName": "福建省产前筛查与诊断管理系统", "enabled": "DISABLED", "version": 1, "createdAt": "2026-09-16T00:00:00.000Z", "updatedAt": "2026-09-17T23:00:00.000Z", "valueMapping": {}, "lastCheckedAt": "2026-09-17T21:00:00.000Z", "connectionStatus": "UNCONFIGURED"}	2026-09-23 06:59:56.546313+00
integrations	MOCK_INT_MOCK_APP_4SSO	9	{"id": "MOCK_INT_MOCK_APP_4SSO", "kind": "SSO", "mode": "SSO", "name": "福建省地中海贫血信息管理系统 · SSO", "appId": "MOCK_APP_4", "remark": "接入参数待业务系统确认", "status": "DISABLED", "appName": "福建省地中海贫血信息管理系统", "enabled": "DISABLED", "version": 1, "createdAt": "2026-09-16T00:00:00.000Z", "updatedAt": "2026-09-17T23:00:00.000Z", "valueMapping": {}, "lastCheckedAt": "2026-09-17T23:00:00.000Z", "connectionStatus": "UNCONFIGURED"}	2026-09-23 06:59:56.546313+00
integrations	MOCK_INT_MOCK_APP_4TODO	10	{"id": "MOCK_INT_MOCK_APP_4TODO", "kind": "TODO", "mode": "PUSH", "name": "福建省地中海贫血信息管理系统 · TODO", "appId": "MOCK_APP_4", "remark": "接入参数待业务系统确认", "status": "UNCONFIGURED", "appName": "福建省地中海贫血信息管理系统", "enabled": "DISABLED", "version": 1, "createdAt": "2026-09-16T00:00:00.000Z", "updatedAt": "2026-09-17T23:00:00.000Z", "valueMapping": {}, "lastCheckedAt": "2026-09-17T22:00:00.000Z", "connectionStatus": "UNCONFIGURED"}	2026-09-23 06:59:56.546313+00
integrations	MOCK_INT_MOCK_APP_4MESSAGE	11	{"id": "MOCK_INT_MOCK_APP_4MESSAGE", "kind": "MESSAGE", "mode": "PUSH", "name": "福建省地中海贫血信息管理系统 · MESSAGE", "appId": "MOCK_APP_4", "remark": "接入参数待业务系统确认", "status": "UNCONFIGURED", "appName": "福建省地中海贫血信息管理系统", "enabled": "DISABLED", "version": 1, "createdAt": "2026-09-16T00:00:00.000Z", "updatedAt": "2026-09-17T23:00:00.000Z", "valueMapping": {}, "lastCheckedAt": "2026-09-17T21:00:00.000Z", "connectionStatus": "UNCONFIGURED"}	2026-09-23 06:59:56.546313+00
integrations	MOCK_INT_MOCK_APP_5SSO	12	{"id": "MOCK_INT_MOCK_APP_5SSO", "kind": "SSO", "mode": "SSO", "name": "福建省慢病报告与管理系统 · SSO", "appId": "MOCK_APP_5", "remark": "接入参数待业务系统确认", "status": "UNCONFIGURED", "appName": "福建省慢病报告与管理系统", "enabled": "DISABLED", "version": 1, "createdAt": "2026-09-16T00:00:00.000Z", "updatedAt": "2026-09-17T23:00:00.000Z", "valueMapping": {}, "lastCheckedAt": "2026-09-17T23:00:00.000Z", "connectionStatus": "UNCONFIGURED"}	2026-09-23 06:59:56.546313+00
integrations	MOCK_INT_MOCK_APP_5TODO	13	{"id": "MOCK_INT_MOCK_APP_5TODO", "kind": "TODO", "mode": "PUSH", "name": "福建省慢病报告与管理系统 · TODO", "appId": "MOCK_APP_5", "remark": "接入参数待业务系统确认", "status": "UNCONFIGURED", "appName": "福建省慢病报告与管理系统", "enabled": "DISABLED", "version": 1, "createdAt": "2026-09-16T00:00:00.000Z", "updatedAt": "2026-09-17T23:00:00.000Z", "valueMapping": {}, "lastCheckedAt": "2026-09-17T22:00:00.000Z", "connectionStatus": "UNCONFIGURED"}	2026-09-23 06:59:56.546313+00
integrations	MOCK_INT_MOCK_APP_5MESSAGE	14	{"id": "MOCK_INT_MOCK_APP_5MESSAGE", "kind": "MESSAGE", "mode": "PUSH", "name": "福建省慢病报告与管理系统 · MESSAGE", "appId": "MOCK_APP_5", "remark": "接入参数待业务系统确认", "status": "UNCONFIGURED", "appName": "福建省慢病报告与管理系统", "enabled": "DISABLED", "version": 1, "createdAt": "2026-09-16T00:00:00.000Z", "updatedAt": "2026-09-17T23:00:00.000Z", "valueMapping": {}, "lastCheckedAt": "2026-09-17T21:00:00.000Z", "connectionStatus": "UNCONFIGURED"}	2026-09-23 06:59:56.546313+00
integrations	MOCK_INT_MOCK_APP_6SSO	15	{"id": "MOCK_INT_MOCK_APP_6SSO", "kind": "SSO", "mode": "SSO", "name": "福建省区域影像平台 · SSO", "appId": "MOCK_APP_6", "remark": "接入参数待业务系统确认", "status": "UNCONFIGURED", "appName": "福建省区域影像平台", "enabled": "DISABLED", "version": 1, "createdAt": "2026-09-16T00:00:00.000Z", "updatedAt": "2026-09-17T23:00:00.000Z", "valueMapping": {}, "lastCheckedAt": "2026-09-17T23:00:00.000Z", "connectionStatus": "UNCONFIGURED"}	2026-09-23 06:59:56.546313+00
integrations	MOCK_INT_MOCK_APP_6TODO	16	{"id": "MOCK_INT_MOCK_APP_6TODO", "kind": "TODO", "mode": "PUSH", "name": "福建省区域影像平台 · TODO", "appId": "MOCK_APP_6", "remark": "接入参数���业务系统确认", "status": "UNCONFIGURED", "appName": "福建省区域影像平台", "enabled": "DISABLED", "version": 1, "createdAt": "2026-09-16T00:00:00.000Z", "updatedAt": "2026-09-17T23:00:00.000Z", "valueMapping": {}, "lastCheckedAt": "2026-09-17T22:00:00.000Z", "connectionStatus": "UNCONFIGURED"}	2026-09-23 06:59:56.546313+00
visits	a15dc3adcb9d8131735a8c61e0872c2b	7	{"at": "2026-09-17T20:00:00.000Z", "appId": "MOCK_APP_4", "userId": "MOCK_USER_2"}	2026-09-23 06:59:56.546313+00
visits	0b574e9144751e8019314eab1bbf0e8f	8	{"at": "2026-09-17T23:00:00.000Z", "appId": "MOCK_APP_1", "userId": "MOCK_ADMIN"}	2026-09-23 06:59:56.546313+00
integrations	MOCK_INT_MOCK_APP_6MESSAGE	17	{"id": "MOCK_INT_MOCK_APP_6MESSAGE", "kind": "MESSAGE", "mode": "PUSH", "name": "福建省区域影像平台 · MESSAGE", "appId": "MOCK_APP_6", "remark": "接入参数待业务系统确认", "status": "DISABLED", "appName": "福建省区域影像平台", "enabled": "DISABLED", "version": 1, "createdAt": "2026-09-16T00:00:00.000Z", "updatedAt": "2026-09-17T23:00:00.000Z", "valueMapping": {}, "lastCheckedAt": "2026-09-17T21:00:00.000Z", "connectionStatus": "UNCONFIGURED"}	2026-09-23 06:59:56.546313+00
integrations	MOCK_INT_MOCK_APP_7SSO	18	{"id": "MOCK_INT_MOCK_APP_7SSO", "kind": "SSO", "mode": "SSO", "name": "质控评分系统 · SSO", "appId": "MOCK_APP_7", "remark": "接入参数待业务系统确认", "status": "UNCONFIGURED", "appName": "质控评分系统", "enabled": "DISABLED", "version": 1, "createdAt": "2026-09-16T00:00:00.000Z", "updatedAt": "2026-09-17T23:00:00.000Z", "valueMapping": {}, "lastCheckedAt": "2026-09-17T23:00:00.000Z", "connectionStatus": "UNCONFIGURED"}	2026-09-23 06:59:56.546313+00
integrations	MOCK_INT_MOCK_APP_7TODO	19	{"id": "MOCK_INT_MOCK_APP_7TODO", "kind": "TODO", "mode": "PUSH", "name": "质控评分系统 · TODO", "appId": "MOCK_APP_7", "remark": "接入参数待业务系统确认", "status": "DISABLED", "appName": "质控评分系统", "enabled": "DISABLED", "version": 1, "createdAt": "2026-09-16T00:00:00.000Z", "updatedAt": "2026-09-17T23:00:00.000Z", "valueMapping": {}, "lastCheckedAt": "2026-09-17T22:00:00.000Z", "connectionStatus": "UNCONFIGURED"}	2026-09-23 06:59:56.546313+00
integrations	MOCK_INT_MOCK_APP_7MESSAGE	20	{"id": "MOCK_INT_MOCK_APP_7MESSAGE", "kind": "MESSAGE", "mode": "PUSH", "name": "质控评分系统 · MESSAGE", "appId": "MOCK_APP_7", "remark": "接入参数待业���系统确认", "status": "UNCONFIGURED", "appName": "质控评分系统", "enabled": "DISABLED", "version": 1, "createdAt": "2026-09-16T00:00:00.000Z", "updatedAt": "2026-09-17T23:00:00.000Z", "valueMapping": {}, "lastCheckedAt": "2026-09-17T21:00:00.000Z", "connectionStatus": "UNCONFIGURED"}	2026-09-23 06:59:56.546313+00
integrations	MOCK_INT_MOCK_APP_8SSO	21	{"id": "MOCK_INT_MOCK_APP_8SSO", "kind": "SSO", "mode": "SSO", "name": "省级平台决策支持展示系统 · SSO", "appId": "MOCK_APP_8", "remark": "接入参数待业务系统确认", "status": "DISABLED", "appName": "省级平台决���支���展���系���", "enabled": "DISABLED", "version": 1, "createdAt": "2026-09-16T00:00:00.000Z", "updatedAt": "2026-09-17T23:00:00.000Z", "valueMapping": {}, "lastCheckedAt": "2026-09-17T23:00:00.000Z", "connectionStatus": "UNCONFIGURED"}	2026-09-23 06:59:56.546313+00
integrations	MOCK_INT_MOCK_APP_8TODO	22	{"id": "MOCK_INT_MOCK_APP_8TODO", "kind": "TODO", "mode": "PUSH", "name": "省级平台决策支持展示系统 · TODO", "appId": "MOCK_APP_8", "remark": "接入参数待业务系统确认", "status": "UNCONFIGURED", "appName": "省级平台决策支持展示系统", "enabled": "DISABLED", "version": 1, "createdAt": "2026-09-16T00:00:00.000Z", "updatedAt": "2026-09-17T23:00:00.000Z", "valueMapping": {}, "lastCheckedAt": "2026-09-17T22:00:00.000Z", "connectionStatus": "UNCONFIGURED"}	2026-09-23 06:59:56.546313+00
integrations	MOCK_INT_MOCK_APP_8MESSAGE	23	{"id": "MOCK_INT_MOCK_APP_8MESSAGE", "kind": "MESSAGE", "mode": "PUSH", "name": "省级平台决策支持展示系统 · MESSAGE", "appId": "MOCK_APP_8", "remark": "接入参数待业务系统确认", "status": "UNCONFIGURED", "appName": "省���平�����决���支���展�����系统", "enabled": "DISABLED", "version": 1, "createdAt": "2026-09-16T00:00:00.000Z", "updatedAt": "2026-09-17T23:00:00.000Z", "valueMapping": {}, "lastCheckedAt": "2026-09-17T21:00:00.000Z", "connectionStatus": "UNCONFIGURED"}	2026-09-23 06:59:56.546313+00
integrations	MOCK_INT_MOCK_APP_9SSO	24	{"id": "MOCK_INT_MOCK_APP_9SSO", "kind": "SSO", "mode": "SSO", "name": "单点登录系统 · SSO", "appId": "MOCK_APP_9", "remark": "接入参数待业务系统确认", "status": "UNCONFIGURED", "appName": "单点登录系统", "enabled": "DISABLED", "version": 1, "createdAt": "2026-09-16T00:00:00.000Z", "updatedAt": "2026-09-17T23:00:00.000Z", "valueMapping": {}, "lastCheckedAt": "2026-09-17T23:00:00.000Z", "connectionStatus": "UNCONFIGURED"}	2026-09-23 06:59:56.546313+00
integrations	MOCK_INT_MOCK_APP_9TODO	25	{"id": "MOCK_INT_MOCK_APP_9TODO", "kind": "TODO", "mode": "PUSH", "name": "单点登录系统 · TODO", "appId": "MOCK_APP_9", "remark": "接入参数待业务系统确认", "status": "UNCONFIGURED", "appName": "单点登录系统", "enabled": "DISABLED", "version": 1, "createdAt": "2026-09-16T00:00:00.000Z", "updatedAt": "2026-09-17T23:00:00.000Z", "valueMapping": {}, "lastCheckedAt": "2026-09-17T22:00:00.000Z", "connectionStatus": "UNCONFIGURED"}	2026-09-23 06:59:56.546313+00
integrations	MOCK_INT_MOCK_APP_9MESSAGE	26	{"id": "MOCK_INT_MOCK_APP_9MESSAGE", "kind": "MESSAGE", "mode": "PUSH", "name": "单点登录系统 · MESSAGE", "appId": "MOCK_APP_9", "remark": "接入参数待业务系统确认", "status": "UNCONFIGURED", "appName": "单点登录系统", "enabled": "DISABLED", "version": 1, "createdAt": "2026-09-16T00:00:00.000Z", "updatedAt": "2026-09-17T23:00:00.000Z", "valueMapping": {}, "lastCheckedAt": "2026-09-17T21:00:00.000Z", "connectionStatus": "UNCONFIGURED"}	2026-09-23 06:59:56.546313+00
integrations	MOCK_INT_MOCK_APP_10SSO	27	{"id": "MOCK_INT_MOCK_APP_10SSO", "kind": "SSO", "mode": "SSO", "name": "福建省血液信息联网平台 · SSO", "appId": "MOCK_APP_10", "remark": "接入参数待业务系统确认", "status": "UNCONFIGURED", "appName": "福建省血液信息联网平台", "enabled": "DISABLED", "version": 1, "createdAt": "2026-09-16T00:00:00.000Z", "updatedAt": "2026-09-17T23:00:00.000Z", "valueMapping": {}, "lastCheckedAt": "2026-09-17T23:00:00.000Z", "connectionStatus": "UNCONFIGURED"}	2026-09-23 06:59:56.546313+00
integrations	MOCK_INT_MOCK_APP_10TODO	28	{"id": "MOCK_INT_MOCK_APP_10TODO", "kind": "TODO", "mode": "PUSH", "name": "福建省血液信息联网平台 · TODO", "appId": "MOCK_APP_10", "remark": "接入参数待业务系统确认", "status": "UNCONFIGURED", "appName": "福建省血液信息联网平台", "enabled": "DISABLED", "version": 1, "createdAt": "2026-09-16T00:00:00.000Z", "updatedAt": "2026-09-17T23:00:00.000Z", "valueMapping": {}, "lastCheckedAt": "2026-09-17T22:00:00.000Z", "connectionStatus": "UNCONFIGURED"}	2026-09-23 06:59:56.546313+00
integrations	MOCK_INT_MOCK_APP_10MESSAGE	29	{"id": "MOCK_INT_MOCK_APP_10MESSAGE", "kind": "MESSAGE", "mode": "PUSH", "name": "福建省血液信息联网平台 · MESSAGE", "appId": "MOCK_APP_10", "remark": "接入参数待业务系统确认", "status": "DISABLED", "appName": "福建省血液信息联网平台", "enabled": "DISABLED", "version": 1, "createdAt": "2026-09-16T00:00:00.000Z", "updatedAt": "2026-09-17T23:00:00.000Z", "valueMapping": {}, "lastCheckedAt": "2026-09-17T21:00:00.000Z", "connectionStatus": "UNCONFIGURED"}	2026-09-23 06:59:56.546313+00
integrations	MOCK_INT_MOCK_APP_11SSO	30	{"id": "MOCK_INT_MOCK_APP_11SSO", "kind": "SSO", "mode": "SSO", "name": "福建省免疫规划管理信息系统 · SSO", "appId": "MOCK_APP_11", "remark": "接入参数待业务系统确认", "status": "UNCONFIGURED", "appName": "���建省免疫规划管理信息系统", "enabled": "DISABLED", "version": 1, "createdAt": "2026-09-16T00:00:00.000Z", "updatedAt": "2026-09-17T23:00:00.000Z", "valueMapping": {}, "lastCheckedAt": "2026-09-17T23:00:00.000Z", "connectionStatus": "UNCONFIGURED"}	2026-09-23 06:59:56.546313+00
integrations	MOCK_INT_MOCK_APP_11TODO	31	{"id": "MOCK_INT_MOCK_APP_11TODO", "kind": "TODO", "mode": "PUSH", "name": "福建省免疫规划管理信息系统 · TODO", "appId": "MOCK_APP_11", "remark": "接入参数待业务系统确认", "status": "DISABLED", "appName": "福建省免疫规���管理信息系统", "enabled": "DISABLED", "version": 1, "createdAt": "2026-09-16T00:00:00.000Z", "updatedAt": "2026-09-17T23:00:00.000Z", "valueMapping": {}, "lastCheckedAt": "2026-09-17T22:00:00.000Z", "connectionStatus": "UNCONFIGURED"}	2026-09-23 06:59:56.546313+00
integrations	MOCK_INT_MOCK_APP_11MESSAGE	32	{"id": "MOCK_INT_MOCK_APP_11MESSAGE", "kind": "MESSAGE", "mode": "PUSH", "name": "福建省免疫规划管理信息系统 · MESSAGE", "appId": "MOCK_APP_11", "remark": "接入参数待业务系统确认", "status": "UNCONFIGURED", "appName": "福建省免疫规划管理信息系统", "enabled": "DISABLED", "version": 1, "createdAt": "2026-09-16T00:00:00.000Z", "updatedAt": "2026-09-17T23:00:00.000Z", "valueMapping": {}, "lastCheckedAt": "2026-09-17T21:00:00.000Z", "connectionStatus": "UNCONFIGURED"}	2026-09-23 06:59:56.546313+00
integrations	MOCK_INT_MOCK_APP_12SSO	33	{"id": "MOCK_INT_MOCK_APP_12SSO", "kind": "SSO", "mode": "SSO", "name": "中医馆健康信息系统 · SSO", "appId": "MOCK_APP_12", "remark": "接入参数待业务系统确认", "status": "DISABLED", "appName": "中医馆健康信息系统", "enabled": "DISABLED", "version": 1, "createdAt": "2026-09-16T00:00:00.000Z", "updatedAt": "2026-09-17T23:00:00.000Z", "valueMapping": {}, "lastCheckedAt": "2026-09-17T23:00:00.000Z", "connectionStatus": "UNCONFIGURED"}	2026-09-23 06:59:56.546313+00
integrations	MOCK_INT_MOCK_APP_12TODO	34	{"id": "MOCK_INT_MOCK_APP_12TODO", "kind": "TODO", "mode": "PUSH", "name": "中医馆健康信息�����统 · TODO", "appId": "MOCK_APP_12", "remark": "接入参数待业务系统确认", "status": "UNCONFIGURED", "appName": "中医馆健康信息系统", "enabled": "DISABLED", "version": 1, "createdAt": "2026-09-16T00:00:00.000Z", "updatedAt": "2026-09-17T23:00:00.000Z", "valueMapping": {}, "lastCheckedAt": "2026-09-17T22:00:00.000Z", "connectionStatus": "UNCONFIGURED"}	2026-09-23 06:59:56.546313+00
integrations	MOCK_INT_MOCK_APP_12MESSAGE	35	{"id": "MOCK_INT_MOCK_APP_12MESSAGE", "kind": "MESSAGE", "mode": "PUSH", "name": "中医馆健康信息系统 · MESSAGE", "appId": "MOCK_APP_12", "remark": "接入参数待业��系统确认", "status": "UNCONFIGURED", "appName": "中医馆健康信息系统", "enabled": "DISABLED", "version": 1, "createdAt": "2026-09-16T00:00:00.000Z", "updatedAt": "2026-09-17T23:00:00.000Z", "valueMapping": {}, "lastCheckedAt": "2026-09-17T21:00:00.000Z", "connectionStatus": "UNCONFIGURED"}	2026-09-23 06:59:56.546313+00
integrations	MOCK_INT_MOCK_APP_13SSO	36	{"id": "MOCK_INT_MOCK_APP_13SSO", "kind": "SSO", "mode": "SSO", "name": "福建省肝炎筛查与规范化治疗管理系统 · SSO", "appId": "MOCK_APP_13", "remark": "接入参数待业务系统确认", "status": "UNCONFIGURED", "appName": "福建省肝炎筛查与规范化治疗管理系统", "enabled": "DISABLED", "version": 1, "createdAt": "2026-09-16T00:00:00.000Z", "updatedAt": "2026-09-17T23:00:00.000Z", "valueMapping": {}, "lastCheckedAt": "2026-09-17T23:00:00.000Z", "connectionStatus": "UNCONFIGURED"}	2026-09-23 06:59:56.546313+00
integrations	MOCK_INT_MOCK_APP_13TODO	37	{"id": "MOCK_INT_MOCK_APP_13TODO", "kind": "TODO", "mode": "PUSH", "name": "福建省肝炎筛查与规范化治疗管理系统 · TODO", "appId": "MOCK_APP_13", "remark": "接入参数待业务系统确认", "status": "UNCONFIGURED", "appName": "福建省肝炎筛查与规范化治疗管理系统", "enabled": "DISABLED", "version": 1, "createdAt": "2026-09-16T00:00:00.000Z", "updatedAt": "2026-09-17T23:00:00.000Z", "valueMapping": {}, "lastCheckedAt": "2026-09-17T22:00:00.000Z", "connectionStatus": "UNCONFIGURED"}	2026-09-23 06:59:56.546313+00
integrations	MOCK_INT_MOCK_APP_13MESSAGE	38	{"id": "MOCK_INT_MOCK_APP_13MESSAGE", "kind": "MESSAGE", "mode": "PUSH", "name": "福建省肝炎筛查与规范�������治疗管理系统 · MESSAGE", "appId": "MOCK_APP_13", "remark": "接入参数待业务系统确认", "status": "UNCONFIGURED", "appName": "福建省肝炎筛查与规范化治疗管理系统", "enabled": "DISABLED", "version": 1, "createdAt": "2026-09-16T00:00:00.000Z", "updatedAt": "2026-09-17T23:00:00.000Z", "valueMapping": {}, "lastCheckedAt": "2026-09-17T21:00:00.000Z", "connectionStatus": "UNCONFIGURED"}	2026-09-23 06:59:56.546313+00
integrations	MOCK_INT_MOCK_APP_14SSO	39	{"id": "MOCK_INT_MOCK_APP_14SSO", "kind": "SSO", "mode": "SSO", "name": "福建省全员人口计划生育服务与管理系统 · SSO", "appId": "MOCK_APP_14", "remark": "接入参数待业务系统确认", "status": "UNCONFIGURED", "appName": "福建省全员人口计划生育服务与管理系统", "enabled": "DISABLED", "version": 1, "createdAt": "2026-09-16T00:00:00.000Z", "updatedAt": "2026-09-17T23:00:00.000Z", "valueMapping": {}, "lastCheckedAt": "2026-09-17T23:00:00.000Z", "connectionStatus": "UNCONFIGURED"}	2026-09-23 06:59:56.546313+00
integrations	MOCK_INT_MOCK_APP_14TODO	40	{"id": "MOCK_INT_MOCK_APP_14TODO", "kind": "TODO", "mode": "PUSH", "name": "福建省全员人口计划生育服务与管理系统 · TODO", "appId": "MOCK_APP_14", "remark": "接入参数待业务系统确认", "status": "UNCONFIGURED", "appName": "福建省全����人��计划生育服务与管理系统", "enabled": "DISABLED", "version": 1, "createdAt": "2026-09-16T00:00:00.000Z", "updatedAt": "2026-09-17T23:00:00.000Z", "valueMapping": {}, "lastCheckedAt": "2026-09-17T22:00:00.000Z", "connectionStatus": "UNCONFIGURED"}	2026-09-23 06:59:56.546313+00
integrations	MOCK_INT_MOCK_APP_14MESSAGE	41	{"id": "MOCK_INT_MOCK_APP_14MESSAGE", "kind": "MESSAGE", "mode": "PUSH", "name": "福建省全员人口计划生育服务与管理系统 · MESSAGE", "appId": "MOCK_APP_14", "remark": "接入参数待业务系统确认", "status": "DISABLED", "appName": "福建省全员人口计划生育服务与管理系统", "enabled": "DISABLED", "version": 1, "createdAt": "2026-09-16T00:00:00.000Z", "updatedAt": "2026-09-17T23:00:00.000Z", "valueMapping": {}, "lastCheckedAt": "2026-09-17T21:00:00.000Z", "connectionStatus": "UNCONFIGURED"}	2026-09-23 06:59:56.546313+00
integrations	MOCK_INT_MOCK_APP_15SSO	42	{"id": "MOCK_INT_MOCK_APP_15SSO", "kind": "SSO", "mode": "SSO", "name": "福建省流动人口服务与管理信息系统 · SSO", "appId": "MOCK_APP_15", "remark": "接入参数待业务系统确认", "status": "UNCONFIGURED", "appName": "福建省流动人口服务与管理信息系统", "enabled": "DISABLED", "version": 1, "createdAt": "2026-09-16T00:00:00.000Z", "updatedAt": "2026-09-17T23:00:00.000Z", "valueMapping": {}, "lastCheckedAt": "2026-09-17T23:00:00.000Z", "connectionStatus": "UNCONFIGURED"}	2026-09-23 06:59:56.546313+00
integrations	MOCK_INT_MOCK_APP_15TODO	43	{"id": "MOCK_INT_MOCK_APP_15TODO", "kind": "TODO", "mode": "PUSH", "name": "福建省流动人口服务与管理信息系统 · TODO", "appId": "MOCK_APP_15", "remark": "接入参数待业务系统确认", "status": "DISABLED", "appName": "福建省流动人口服务与管理信息系统", "enabled": "DISABLED", "version": 1, "createdAt": "2026-09-16T00:00:00.000Z", "updatedAt": "2026-09-17T23:00:00.000Z", "valueMapping": {}, "lastCheckedAt": "2026-09-17T22:00:00.000Z", "connectionStatus": "UNCONFIGURED"}	2026-09-23 06:59:56.546313+00
integrations	MOCK_INT_MOCK_APP_15MESSAGE	44	{"id": "MOCK_INT_MOCK_APP_15MESSAGE", "kind": "MESSAGE", "mode": "PUSH", "name": "福建省流动人口服务与管理信息系统 · MESSAGE", "appId": "MOCK_APP_15", "remark": "接入参数待业务系统确认", "status": "UNCONFIGURED", "appName": "福建省流动人口服务与管理信息系统", "enabled": "DISABLED", "version": 1, "createdAt": "2026-09-16T00:00:00.000Z", "updatedAt": "2026-09-17T23:00:00.000Z", "valueMapping": {}, "lastCheckedAt": "2026-09-17T21:00:00.000Z", "connectionStatus": "UNCONFIGURED"}	2026-09-23 06:59:56.546313+00
integrations	MOCK_INT_MOCK_APP_16SSO	45	{"id": "MOCK_INT_MOCK_APP_16SSO", "kind": "SSO", "mode": "SSO", "name": "福建省人口计生综合服务信息平台 · SSO", "appId": "MOCK_APP_16", "remark": "接入参数待业务系统确认", "status": "DISABLED", "appName": "福建省人口计生综合服务信息平台", "enabled": "DISABLED", "version": 1, "createdAt": "2026-09-16T00:00:00.000Z", "updatedAt": "2026-09-17T23:00:00.000Z", "valueMapping": {}, "lastCheckedAt": "2026-09-17T23:00:00.000Z", "connectionStatus": "UNCONFIGURED"}	2026-09-23 06:59:56.546313+00
integrations	MOCK_INT_MOCK_APP_16TODO	46	{"id": "MOCK_INT_MOCK_APP_16TODO", "kind": "TODO", "mode": "PUSH", "name": "福建省人口计生综合服务信息平台 · TODO", "appId": "MOCK_APP_16", "remark": "接入参数待业务系统确认", "status": "UNCONFIGURED", "appName": "福建省人口计生综合服务信息平台", "enabled": "DISABLED", "version": 1, "createdAt": "2026-09-16T00:00:00.000Z", "updatedAt": "2026-09-17T23:00:00.000Z", "valueMapping": {}, "lastCheckedAt": "2026-09-17T22:00:00.000Z", "connectionStatus": "UNCONFIGURED"}	2026-09-23 06:59:56.546313+00
integrations	MOCK_INT_MOCK_APP_16MESSAGE	47	{"id": "MOCK_INT_MOCK_APP_16MESSAGE", "kind": "MESSAGE", "mode": "PUSH", "name": "福建省人口计生综合服务信息平台 · MESSAGE", "appId": "MOCK_APP_16", "remark": "接入参数待业务系统确认", "status": "UNCONFIGURED", "appName": "福建省人口计生综合服务信息平台", "enabled": "DISABLED", "version": 1, "createdAt": "2026-09-16T00:00:00.000Z", "updatedAt": "2026-09-17T23:00:00.000Z", "valueMapping": {}, "lastCheckedAt": "2026-09-17T21:00:00.000Z", "connectionStatus": "UNCONFIGURED"}	2026-09-23 06:59:56.546313+00
integrations	MOCK_INT_MOCK_APP_17SSO	48	{"id": "MOCK_INT_MOCK_APP_17SSO", "kind": "SSO", "mode": "SSO", "name": "全员人口数据库药具发放服务管理 · SSO", "appId": "MOCK_APP_17", "remark": "接入参数待业务系统确认", "status": "UNCONFIGURED", "appName": "全员人口数据库药具发放服务管理", "enabled": "DISABLED", "version": 1, "createdAt": "2026-09-16T00:00:00.000Z", "updatedAt": "2026-09-17T23:00:00.000Z", "valueMapping": {}, "lastCheckedAt": "2026-09-17T23:00:00.000Z", "connectionStatus": "UNCONFIGURED"}	2026-09-23 06:59:56.546313+00
integrations	MOCK_INT_MOCK_APP_17TODO	49	{"id": "MOCK_INT_MOCK_APP_17TODO", "kind": "TODO", "mode": "PUSH", "name": "全员人口数据库药具发放服务管理 · TODO", "appId": "MOCK_APP_17", "remark": "接入参数待业务系统确认", "status": "UNCONFIGURED", "appName": "全员人口数据库药具发放服务管理", "enabled": "DISABLED", "version": 1, "createdAt": "2026-09-16T00:00:00.000Z", "updatedAt": "2026-09-17T23:00:00.000Z", "valueMapping": {}, "lastCheckedAt": "2026-09-17T22:00:00.000Z", "connectionStatus": "UNCONFIGURED"}	2026-09-23 06:59:56.546313+00
integrations	MOCK_INT_MOCK_APP_17MESSAGE	50	{"id": "MOCK_INT_MOCK_APP_17MESSAGE", "kind": "MESSAGE", "mode": "PUSH", "name": "全员人口数据库药具发放服务管理 · MESSAGE", "appId": "MOCK_APP_17", "remark": "接入参数待业务系统确认", "status": "UNCONFIGURED", "appName": "全员人口数据库药具发放服务管理", "enabled": "DISABLED", "version": 1, "createdAt": "2026-09-16T00:00:00.000Z", "updatedAt": "2026-09-17T23:00:00.000Z", "valueMapping": {}, "lastCheckedAt": "2026-09-17T21:00:00.000Z", "connectionStatus": "UNCONFIGURED"}	2026-09-23 06:59:56.546313+00
integrations	MOCK_INT_MOCK_APP_18SSO	51	{"id": "MOCK_INT_MOCK_APP_18SSO", "kind": "SSO", "mode": "SSO", "name": "福建省互联网医院监管平台 · SSO", "appId": "MOCK_APP_18", "remark": "接入参数待业务系统确认", "status": "UNCONFIGURED", "appName": "福建省互联网医院监管平台", "enabled": "DISABLED", "version": 1, "createdAt": "2026-09-16T00:00:00.000Z", "updatedAt": "2026-09-17T23:00:00.000Z", "valueMapping": {}, "lastCheckedAt": "2026-09-17T23:00:00.000Z", "connectionStatus": "UNCONFIGURED"}	2026-09-23 06:59:56.546313+00
integrations	MOCK_INT_MOCK_APP_18TODO	52	{"id": "MOCK_INT_MOCK_APP_18TODO", "kind": "TODO", "mode": "PUSH", "name": "福建省互联网医院监管平台 · TODO", "appId": "MOCK_APP_18", "remark": "接入参数待业务系统确认", "status": "UNCONFIGURED", "appName": "福建省互联网医院监管平台", "enabled": "DISABLED", "version": 1, "createdAt": "2026-09-16T00:00:00.000Z", "updatedAt": "2026-09-17T23:00:00.000Z", "valueMapping": {}, "lastCheckedAt": "2026-09-17T22:00:00.000Z", "connectionStatus": "UNCONFIGURED"}	2026-09-23 06:59:56.546313+00
integrations	MOCK_INT_MOCK_APP_18MESSAGE	53	{"id": "MOCK_INT_MOCK_APP_18MESSAGE", "kind": "MESSAGE", "mode": "PUSH", "name": "福建省互联网医院监管平台 · MESSAGE", "appId": "MOCK_APP_18", "remark": "接入参数待业务系统确认", "status": "DISABLED", "appName": "福建省互联网医院监管平台", "enabled": "DISABLED", "version": 1, "createdAt": "2026-09-16T00:00:00.000Z", "updatedAt": "2026-09-17T23:00:00.000Z", "valueMapping": {}, "lastCheckedAt": "2026-09-17T21:00:00.000Z", "connectionStatus": "UNCONFIGURED"}	2026-09-23 06:59:56.546313+00
integrations	MOCK_INT_MOCK_APP_19SSO	54	{"id": "MOCK_INT_MOCK_APP_19SSO", "kind": "SSO", "mode": "SSO", "name": "省医改效果监测管理系统 · SSO", "appId": "MOCK_APP_19", "remark": "接入参数待业务系统确认", "status": "UNCONFIGURED", "appName": "省医改效果监测管理系统", "enabled": "DISABLED", "version": 1, "createdAt": "2026-09-16T00:00:00.000Z", "updatedAt": "2026-09-17T23:00:00.000Z", "valueMapping": {}, "lastCheckedAt": "2026-09-17T23:00:00.000Z", "connectionStatus": "UNCONFIGURED"}	2026-09-23 06:59:56.546313+00
integrations	MOCK_INT_MOCK_APP_19TODO	55	{"id": "MOCK_INT_MOCK_APP_19TODO", "kind": "TODO", "mode": "PUSH", "name": "省医改效果监测管理系统 · TODO", "appId": "MOCK_APP_19", "remark": "接入参数待业务系统确认", "status": "DISABLED", "appName": "省医改效果监测管理系统", "enabled": "DISABLED", "version": 1, "createdAt": "2026-09-16T00:00:00.000Z", "updatedAt": "2026-09-17T23:00:00.000Z", "valueMapping": {}, "lastCheckedAt": "2026-09-17T22:00:00.000Z", "connectionStatus": "UNCONFIGURED"}	2026-09-23 06:59:56.546313+00
integrations	MOCK_INT_MOCK_APP_19MESSAGE	56	{"id": "MOCK_INT_MOCK_APP_19MESSAGE", "kind": "MESSAGE", "mode": "PUSH", "name": "省医改效果监测管理系统 · MESSAGE", "appId": "MOCK_APP_19", "remark": "接入参数待业务系统确认", "status": "UNCONFIGURED", "appName": "省医改效果监测管理系统", "enabled": "DISABLED", "version": 1, "createdAt": "2026-09-16T00:00:00.000Z", "updatedAt": "2026-09-17T23:00:00.000Z", "valueMapping": {}, "lastCheckedAt": "2026-09-17T21:00:00.000Z", "connectionStatus": "UNCONFIGURED"}	2026-09-23 06:59:56.546313+00
visits	ccd953923b26e1c226cd24861794ab0d	9	{"at": "2026-09-17T22:00:00.000Z", "appId": "MOCK_APP_2", "userId": "MOCK_ADMIN"}	2026-09-23 06:59:56.546313+00
integrations	MOCK_INT_MOCK_APP_20SSO	57	{"id": "MOCK_INT_MOCK_APP_20SSO", "kind": "SSO", "mode": "SSO", "name": "省属公立医院运营监管系统 · SSO", "appId": "MOCK_APP_20", "remark": "接入参数待业务系统确认", "status": "DISABLED", "appName": "省属公立医院运营监管系统", "enabled": "DISABLED", "version": 1, "createdAt": "2026-09-16T00:00:00.000Z", "updatedAt": "2026-09-17T23:00:00.000Z", "valueMapping": {}, "lastCheckedAt": "2026-09-17T23:00:00.000Z", "connectionStatus": "UNCONFIGURED"}	2026-09-23 06:59:56.546313+00
integrations	MOCK_INT_MOCK_APP_20TODO	58	{"id": "MOCK_INT_MOCK_APP_20TODO", "kind": "TODO", "mode": "PUSH", "name": "省属公立医院运营监管系统 · TODO", "appId": "MOCK_APP_20", "remark": "接入参数待业务系统确认", "status": "UNCONFIGURED", "appName": "省属公立医院运营监管系统", "enabled": "DISABLED", "version": 1, "createdAt": "2026-09-16T00:00:00.000Z", "updatedAt": "2026-09-17T23:00:00.000Z", "valueMapping": {}, "lastCheckedAt": "2026-09-17T22:00:00.000Z", "connectionStatus": "UNCONFIGURED"}	2026-09-23 06:59:56.546313+00
integrations	MOCK_INT_MOCK_APP_20MESSAGE	59	{"id": "MOCK_INT_MOCK_APP_20MESSAGE", "kind": "MESSAGE", "mode": "PUSH", "name": "省属公立医院运营监管系统 · MESSAGE", "appId": "MOCK_APP_20", "remark": "接入参数待业务系统确认", "status": "UNCONFIGURED", "appName": "省属公立医院运营监管系统", "enabled": "DISABLED", "version": 1, "createdAt": "2026-09-16T00:00:00.000Z", "updatedAt": "2026-09-17T23:00:00.000Z", "valueMapping": {}, "lastCheckedAt": "2026-09-17T21:00:00.000Z", "connectionStatus": "UNCONFIGURED"}	2026-09-23 06:59:56.546313+00
integrations	MOCK_INT_MOCK_APP_21SSO	60	{"id": "MOCK_INT_MOCK_APP_21SSO", "kind": "SSO", "mode": "SSO", "name": "福建省公立医院绩效考核系统 · SSO", "appId": "MOCK_APP_21", "remark": "接入参数待业务系统确认", "status": "UNCONFIGURED", "appName": "福建省公立医院绩效考核系统", "enabled": "DISABLED", "version": 1, "createdAt": "2026-09-16T00:00:00.000Z", "updatedAt": "2026-09-17T23:00:00.000Z", "valueMapping": {}, "lastCheckedAt": "2026-09-17T23:00:00.000Z", "connectionStatus": "UNCONFIGURED"}	2026-09-23 06:59:56.546313+00
integrations	MOCK_INT_MOCK_APP_21TODO	61	{"id": "MOCK_INT_MOCK_APP_21TODO", "kind": "TODO", "mode": "PUSH", "name": "福建省公立医院绩效考核系统 · TODO", "appId": "MOCK_APP_21", "remark": "接入参数待业务系统确认", "status": "UNCONFIGURED", "appName": "福建省公立医院绩效考核系统", "enabled": "DISABLED", "version": 1, "createdAt": "2026-09-16T00:00:00.000Z", "updatedAt": "2026-09-17T23:00:00.000Z", "valueMapping": {}, "lastCheckedAt": "2026-09-17T22:00:00.000Z", "connectionStatus": "UNCONFIGURED"}	2026-09-23 06:59:56.546313+00
integrations	MOCK_INT_MOCK_APP_21MESSAGE	62	{"id": "MOCK_INT_MOCK_APP_21MESSAGE", "kind": "MESSAGE", "mode": "PUSH", "name": "福建省公立医院绩效考核系统 · MESSAGE", "appId": "MOCK_APP_21", "remark": "接入参数待业务系统确认", "status": "UNCONFIGURED", "appName": "福建省公立医院绩效考核系统", "enabled": "DISABLED", "version": 1, "createdAt": "2026-09-16T00:00:00.000Z", "updatedAt": "2026-09-17T23:00:00.000Z", "valueMapping": {}, "lastCheckedAt": "2026-09-17T21:00:00.000Z", "connectionStatus": "UNCONFIGURED"}	2026-09-23 06:59:56.546313+00
integrations	MOCK_INT_MOCK_APP_22SSO	63	{"id": "MOCK_INT_MOCK_APP_22SSO", "kind": "SSO", "mode": "SSO", "name": "财务管理系统 · SSO", "appId": "MOCK_APP_22", "remark": "接入参数待业务系统确认", "status": "UNCONFIGURED", "appName": "财务管理系统", "enabled": "DISABLED", "version": 1, "createdAt": "2026-09-16T00:00:00.000Z", "updatedAt": "2026-09-17T23:00:00.000Z", "valueMapping": {}, "lastCheckedAt": "2026-09-17T23:00:00.000Z", "connectionStatus": "UNCONFIGURED"}	2026-09-23 06:59:56.546313+00
integrations	MOCK_INT_MOCK_APP_22TODO	64	{"id": "MOCK_INT_MOCK_APP_22TODO", "kind": "TODO", "mode": "PUSH", "name": "财务管理系统 · TODO", "appId": "MOCK_APP_22", "remark": "接入参数待业务系统确认", "status": "UNCONFIGURED", "appName": "财务管理系统", "enabled": "DISABLED", "version": 1, "createdAt": "2026-09-16T00:00:00.000Z", "updatedAt": "2026-09-17T23:00:00.000Z", "valueMapping": {}, "lastCheckedAt": "2026-09-17T22:00:00.000Z", "connectionStatus": "UNCONFIGURED"}	2026-09-23 06:59:56.546313+00
integrations	MOCK_INT_MOCK_APP_22MESSAGE	65	{"id": "MOCK_INT_MOCK_APP_22MESSAGE", "kind": "MESSAGE", "mode": "PUSH", "name": "财务管理系统 · MESSAGE", "appId": "MOCK_APP_22", "remark": "接入参数待业务系统确认", "status": "DISABLED", "appName": "财务管理系统", "enabled": "DISABLED", "version": 1, "createdAt": "2026-09-16T00:00:00.000Z", "updatedAt": "2026-09-17T23:00:00.000Z", "valueMapping": {}, "lastCheckedAt": "2026-09-17T21:00:00.000Z", "connectionStatus": "UNCONFIGURED"}	2026-09-23 06:59:56.546313+00
integrations	MOCK_INT_MOCK_APP_23SSO	66	{"id": "MOCK_INT_MOCK_APP_23SSO", "kind": "SSO", "mode": "SSO", "name": "医疗技术临床应用管理信息系统 · SSO", "appId": "MOCK_APP_23", "remark": "接入参数待业务系统确认", "status": "UNCONFIGURED", "appName": "医疗技术临床应用管理信息系统", "enabled": "DISABLED", "version": 1, "createdAt": "2026-09-16T00:00:00.000Z", "updatedAt": "2026-09-17T23:00:00.000Z", "valueMapping": {}, "lastCheckedAt": "2026-09-17T23:00:00.000Z", "connectionStatus": "UNCONFIGURED"}	2026-09-23 06:59:56.546313+00
integrations	MOCK_INT_MOCK_APP_23TODO	67	{"id": "MOCK_INT_MOCK_APP_23TODO", "kind": "TODO", "mode": "PUSH", "name": "医疗技术临床应用管理信息系统 · TODO", "appId": "MOCK_APP_23", "remark": "接入参数待业务系统确认", "status": "DISABLED", "appName": "医疗技术临床应用管理信息系统", "enabled": "DISABLED", "version": 1, "createdAt": "2026-09-16T00:00:00.000Z", "updatedAt": "2026-09-17T23:00:00.000Z", "valueMapping": {}, "lastCheckedAt": "2026-09-17T22:00:00.000Z", "connectionStatus": "UNCONFIGURED"}	2026-09-23 06:59:56.546313+00
integrations	MOCK_INT_MOCK_APP_23MESSAGE	68	{"id": "MOCK_INT_MOCK_APP_23MESSAGE", "kind": "MESSAGE", "mode": "PUSH", "name": "医疗技术临床应用管理信息系统 · MESSAGE", "appId": "MOCK_APP_23", "remark": "接入参数待业务系统确认", "status": "UNCONFIGURED", "appName": "医疗技术临床应用管理信息系统", "enabled": "DISABLED", "version": 1, "createdAt": "2026-09-16T00:00:00.000Z", "updatedAt": "2026-09-17T23:00:00.000Z", "valueMapping": {}, "lastCheckedAt": "2026-09-17T21:00:00.000Z", "connectionStatus": "UNCONFIGURED"}	2026-09-23 06:59:56.546313+00
integrations	MOCK_INT_MOCK_APP_24SSO	69	{"id": "MOCK_INT_MOCK_APP_24SSO", "kind": "SSO", "mode": "SSO", "name": "住院医师专科医师培训及一体化系统 · SSO", "appId": "MOCK_APP_24", "remark": "接入参数待业务系统确认", "status": "DISABLED", "appName": "住院医师专科医师培训及一体化系统", "enabled": "DISABLED", "version": 1, "createdAt": "2026-09-16T00:00:00.000Z", "updatedAt": "2026-09-17T23:00:00.000Z", "valueMapping": {}, "lastCheckedAt": "2026-09-17T23:00:00.000Z", "connectionStatus": "UNCONFIGURED"}	2026-09-23 06:59:56.546313+00
visits	e017797496fa3c637869926f0a4a633e	10	{"at": "2026-09-17T21:00:00.000Z", "appId": "MOCK_APP_3", "userId": "MOCK_ADMIN"}	2026-09-23 06:59:56.546313+00
visits	6bbc18dad1d51c0658aaa337abb9ad85	11	{"at": "2026-09-17T20:00:00.000Z", "appId": "MOCK_APP_4", "userId": "MOCK_ADMIN"}	2026-09-23 06:59:56.546313+00
integrations	MOCK_INT_MOCK_APP_24TODO	70	{"id": "MOCK_INT_MOCK_APP_24TODO", "kind": "TODO", "mode": "PUSH", "name": "住院医师专科医师培训及一体化系统 · TODO", "appId": "MOCK_APP_24", "remark": "接入参数待业务系统确认", "status": "UNCONFIGURED", "appName": "住院医师专科医师培训及一体化系统", "enabled": "DISABLED", "version": 1, "createdAt": "2026-09-16T00:00:00.000Z", "updatedAt": "2026-09-17T23:00:00.000Z", "valueMapping": {}, "lastCheckedAt": "2026-09-17T22:00:00.000Z", "connectionStatus": "UNCONFIGURED"}	2026-09-23 06:59:56.546313+00
integrations	MOCK_INT_MOCK_APP_24MESSAGE	71	{"id": "MOCK_INT_MOCK_APP_24MESSAGE", "kind": "MESSAGE", "mode": "PUSH", "name": "住院医师专科医师培训及一体化系统 · MESSAGE", "appId": "MOCK_APP_24", "remark": "接入参数待业务系统确认", "status": "UNCONFIGURED", "appName": "住院医师专科医师培训及一体化系统", "enabled": "DISABLED", "version": 1, "createdAt": "2026-09-16T00:00:00.000Z", "updatedAt": "2026-09-17T23:00:00.000Z", "valueMapping": {}, "lastCheckedAt": "2026-09-17T21:00:00.000Z", "connectionStatus": "UNCONFIGURED"}	2026-09-23 06:59:56.546313+00
integrations	MOCK_INT_MOCK_APP_25SSO	72	{"id": "MOCK_INT_MOCK_APP_25SSO", "kind": "SSO", "mode": "SSO", "name": "福建省中医医师规范化培训管理平台 · SSO", "appId": "MOCK_APP_25", "remark": "接入参数待业务系统确认", "status": "UNCONFIGURED", "appName": "福建省中医医师规范化培训管理平台", "enabled": "DISABLED", "version": 1, "createdAt": "2026-09-16T00:00:00.000Z", "updatedAt": "2026-09-17T23:00:00.000Z", "valueMapping": {}, "lastCheckedAt": "2026-09-17T23:00:00.000Z", "connectionStatus": "UNCONFIGURED"}	2026-09-23 06:59:56.546313+00
integrations	MOCK_INT_MOCK_APP_25TODO	73	{"id": "MOCK_INT_MOCK_APP_25TODO", "kind": "TODO", "mode": "PUSH", "name": "福建省中医医师规范化培训管理平台 · TODO", "appId": "MOCK_APP_25", "remark": "接入参数待业务系统确认", "status": "UNCONFIGURED", "appName": "福建省中医医师规范化培训管理平台", "enabled": "DISABLED", "version": 1, "createdAt": "2026-09-16T00:00:00.000Z", "updatedAt": "2026-09-17T23:00:00.000Z", "valueMapping": {}, "lastCheckedAt": "2026-09-17T22:00:00.000Z", "connectionStatus": "UNCONFIGURED"}	2026-09-23 06:59:56.546313+00
integrations	MOCK_INT_MOCK_APP_25MESSAGE	74	{"id": "MOCK_INT_MOCK_APP_25MESSAGE", "kind": "MESSAGE", "mode": "PUSH", "name": "福建省中医医师规范化培训管理平台 · MESSAGE", "appId": "MOCK_APP_25", "remark": "接入参数待业务系统确认", "status": "UNCONFIGURED", "appName": "福建省中医医师规范化培训管理平台", "enabled": "DISABLED", "version": 1, "createdAt": "2026-09-16T00:00:00.000Z", "updatedAt": "2026-09-17T23:00:00.000Z", "valueMapping": {}, "lastCheckedAt": "2026-09-17T21:00:00.000Z", "connectionStatus": "UNCONFIGURED"}	2026-09-23 06:59:56.546313+00
integrations	MOCK_INT_MOCK_APP_26SSO	75	{"id": "MOCK_INT_MOCK_APP_26SSO", "kind": "SSO", "mode": "SSO", "name": "福建省中医医术确有专长人员医师资格考核报名系统 · SSO", "appId": "MOCK_APP_26", "remark": "接入参数待业务系统确认", "status": "UNCONFIGURED", "appName": "福建省中医医术确有专长人员医师资格考核报名系统", "enabled": "DISABLED", "version": 1, "createdAt": "2026-09-16T00:00:00.000Z", "updatedAt": "2026-09-17T23:00:00.000Z", "valueMapping": {}, "lastCheckedAt": "2026-09-17T23:00:00.000Z", "connectionStatus": "UNCONFIGURED"}	2026-09-23 06:59:56.546313+00
integrations	MOCK_INT_MOCK_APP_26TODO	76	{"id": "MOCK_INT_MOCK_APP_26TODO", "kind": "TODO", "mode": "PUSH", "name": "福建省中医医术确有专长人员医师资格考核报名系统 · TODO", "appId": "MOCK_APP_26", "remark": "接入参数待业务系统确认", "status": "UNCONFIGURED", "appName": "福建省中医医术确有专长人员医师资格考核报名系统", "enabled": "DISABLED", "version": 1, "createdAt": "2026-09-16T00:00:00.000Z", "updatedAt": "2026-09-17T23:00:00.000Z", "valueMapping": {}, "lastCheckedAt": "2026-09-17T22:00:00.000Z", "connectionStatus": "UNCONFIGURED"}	2026-09-23 06:59:56.546313+00
integrations	MOCK_INT_MOCK_APP_26MESSAGE	77	{"id": "MOCK_INT_MOCK_APP_26MESSAGE", "kind": "MESSAGE", "mode": "PUSH", "name": "福建省中医医术确有专长人员医师资格考核报名系统 · MESSAGE", "appId": "MOCK_APP_26", "remark": "接入参数待业务系统确认", "status": "DISABLED", "appName": "福建省中医医术确有专长人员医师资格考核报名系统", "enabled": "DISABLED", "version": 1, "createdAt": "2026-09-16T00:00:00.000Z", "updatedAt": "2026-09-17T23:00:00.000Z", "valueMapping": {}, "lastCheckedAt": "2026-09-17T21:00:00.000Z", "connectionStatus": "UNCONFIGURED"}	2026-09-23 06:59:56.546313+00
integrations	MOCK_INT_MOCK_APP_27SSO	78	{"id": "MOCK_INT_MOCK_APP_27SSO", "kind": "SSO", "mode": "SSO", "name": "福建省卫生健康科技计划项目管理信息系统 · SSO", "appId": "MOCK_APP_27", "remark": "接入参数待业务系统确认", "status": "UNCONFIGURED", "appName": "福建省卫生健康科技计划项目管理信息系统", "enabled": "DISABLED", "version": 1, "createdAt": "2026-09-16T00:00:00.000Z", "updatedAt": "2026-09-17T23:00:00.000Z", "valueMapping": {}, "lastCheckedAt": "2026-09-17T23:00:00.000Z", "connectionStatus": "UNCONFIGURED"}	2026-09-23 06:59:56.546313+00
integrations	MOCK_INT_MOCK_APP_27TODO	79	{"id": "MOCK_INT_MOCK_APP_27TODO", "kind": "TODO", "mode": "PUSH", "name": "福建省卫生健康科技计划项目管理信息系统 · TODO", "appId": "MOCK_APP_27", "remark": "接入参数待业务系统确认", "status": "DISABLED", "appName": "福建省卫生健康科技计划项目管理信息系统", "enabled": "DISABLED", "version": 1, "createdAt": "2026-09-16T00:00:00.000Z", "updatedAt": "2026-09-17T23:00:00.000Z", "valueMapping": {}, "lastCheckedAt": "2026-09-17T22:00:00.000Z", "connectionStatus": "UNCONFIGURED"}	2026-09-23 06:59:56.546313+00
integrations	MOCK_INT_MOCK_APP_27MESSAGE	80	{"id": "MOCK_INT_MOCK_APP_27MESSAGE", "kind": "MESSAGE", "mode": "PUSH", "name": "福建省卫生健康科技计划项目管理信息系统 · MESSAGE", "appId": "MOCK_APP_27", "remark": "接入参数待业务系统确认", "status": "UNCONFIGURED", "appName": "福建省卫生健康科技计划项目管理信息系统", "enabled": "DISABLED", "version": 1, "createdAt": "2026-09-16T00:00:00.000Z", "updatedAt": "2026-09-17T23:00:00.000Z", "valueMapping": {}, "lastCheckedAt": "2026-09-17T21:00:00.000Z", "connectionStatus": "UNCONFIGURED"}	2026-09-23 06:59:56.546313+00
integrations	MOCK_INT_MOCK_APP_28SSO	81	{"id": "MOCK_INT_MOCK_APP_28SSO", "kind": "SSO", "mode": "SSO", "name": "福建省卫生专业技术资格考试报名系统 · SSO", "appId": "MOCK_APP_28", "remark": "接入参数待业务系统确认", "status": "DISABLED", "appName": "福建省卫生专业技术资格考试报名系统", "enabled": "DISABLED", "version": 1, "createdAt": "2026-09-16T00:00:00.000Z", "updatedAt": "2026-09-17T23:00:00.000Z", "valueMapping": {}, "lastCheckedAt": "2026-09-17T23:00:00.000Z", "connectionStatus": "UNCONFIGURED"}	2026-09-23 06:59:56.546313+00
visits	bd7de435988eb25efa6dc78d0f13f38a	12	{"at": "2026-09-17T23:00:00.000Z", "appId": "MOCK_APP_1", "userId": "MOCK_EDITOR"}	2026-09-23 06:59:56.546313+00
visits	04ca78f18239ba5ea226ada121546ee1	13	{"at": "2026-09-17T22:00:00.000Z", "appId": "MOCK_APP_2", "userId": "MOCK_EDITOR"}	2026-09-23 06:59:56.546313+00
visits	b6d1f5ecef0f742e97fe9c04cc7d993c	14	{"at": "2026-09-17T21:00:00.000Z", "appId": "MOCK_APP_3", "userId": "MOCK_EDITOR"}	2026-09-23 06:59:56.546313+00
integrations	MOCK_INT_MOCK_APP_28TODO	82	{"id": "MOCK_INT_MOCK_APP_28TODO", "kind": "TODO", "mode": "PUSH", "name": "福建省卫生专业技术资格考试报名系统 · TODO", "appId": "MOCK_APP_28", "remark": "接入参数待业务系统确认", "status": "UNCONFIGURED", "appName": "福建省卫生专业技术资格考试报名系统", "enabled": "DISABLED", "version": 1, "createdAt": "2026-09-16T00:00:00.000Z", "updatedAt": "2026-09-17T23:00:00.000Z", "valueMapping": {}, "lastCheckedAt": "2026-09-17T22:00:00.000Z", "connectionStatus": "UNCONFIGURED"}	2026-09-23 06:59:56.546313+00
integrations	MOCK_INT_MOCK_APP_28MESSAGE	83	{"id": "MOCK_INT_MOCK_APP_28MESSAGE", "kind": "MESSAGE", "mode": "PUSH", "name": "福建省卫生专业技术资格考试报名系统 · MESSAGE", "appId": "MOCK_APP_28", "remark": "接入参数待业务系统确认", "status": "UNCONFIGURED", "appName": "福建省卫生专业技术资格考试报名系统", "enabled": "DISABLED", "version": 1, "createdAt": "2026-09-16T00:00:00.000Z", "updatedAt": "2026-09-17T23:00:00.000Z", "valueMapping": {}, "lastCheckedAt": "2026-09-17T21:00:00.000Z", "connectionStatus": "UNCONFIGURED"}	2026-09-23 06:59:56.546313+00
integrations	MOCK_INT_MOCK_APP_29SSO	84	{"id": "MOCK_INT_MOCK_APP_29SSO", "kind": "SSO", "mode": "SSO", "name": "国家卫生健康信息统计直报系统 · SSO", "appId": "MOCK_APP_29", "remark": "接入参数待业务系统确认", "status": "UNCONFIGURED", "appName": "国家卫生健康信息统计直报系统", "enabled": "DISABLED", "version": 1, "createdAt": "2026-09-16T00:00:00.000Z", "updatedAt": "2026-09-17T23:00:00.000Z", "valueMapping": {}, "lastCheckedAt": "2026-09-17T23:00:00.000Z", "connectionStatus": "UNCONFIGURED"}	2026-09-23 06:59:56.546313+00
integrations	MOCK_INT_MOCK_APP_29TODO	85	{"id": "MOCK_INT_MOCK_APP_29TODO", "kind": "TODO", "mode": "PUSH", "name": "国家卫生健康信息统计直报系统 · TODO", "appId": "MOCK_APP_29", "remark": "接入参数待业务系统确认", "status": "UNCONFIGURED", "appName": "国家卫生健康信息统计直报系统", "enabled": "DISABLED", "version": 1, "createdAt": "2026-09-16T00:00:00.000Z", "updatedAt": "2026-09-17T23:00:00.000Z", "valueMapping": {}, "lastCheckedAt": "2026-09-17T22:00:00.000Z", "connectionStatus": "UNCONFIGURED"}	2026-09-23 06:59:56.546313+00
integrations	MOCK_INT_MOCK_APP_29MESSAGE	86	{"id": "MOCK_INT_MOCK_APP_29MESSAGE", "kind": "MESSAGE", "mode": "PUSH", "name": "国家卫生健康信息统计直报系统 · MESSAGE", "appId": "MOCK_APP_29", "remark": "接入参数待业务系统确认", "status": "UNCONFIGURED", "appName": "国家卫生健康信息统计直报系统", "enabled": "DISABLED", "version": 1, "createdAt": "2026-09-16T00:00:00.000Z", "updatedAt": "2026-09-17T23:00:00.000Z", "valueMapping": {}, "lastCheckedAt": "2026-09-17T21:00:00.000Z", "connectionStatus": "UNCONFIGURED"}	2026-09-23 06:59:56.546313+00
integrations	MOCK_INT_MOCK_APP_30SSO	87	{"id": "MOCK_INT_MOCK_APP_30SSO", "kind": "SSO", "mode": "SSO", "name": "福建省集中消毒餐具追溯系统 · SSO", "appId": "MOCK_APP_30", "remark": "接入参数待业务系���确认", "status": "UNCONFIGURED", "appName": "福建省集中消毒餐具追溯系统", "enabled": "DISABLED", "version": 1, "createdAt": "2026-09-16T00:00:00.000Z", "updatedAt": "2026-09-17T23:00:00.000Z", "valueMapping": {}, "lastCheckedAt": "2026-09-17T23:00:00.000Z", "connectionStatus": "UNCONFIGURED"}	2026-09-23 06:59:56.546313+00
integrations	MOCK_INT_MOCK_APP_30TODO	88	{"id": "MOCK_INT_MOCK_APP_30TODO", "kind": "TODO", "mode": "PUSH", "name": "福建省集中消毒餐具追溯系统 · TODO", "appId": "MOCK_APP_30", "remark": "接入参数待业务系统确认", "status": "UNCONFIGURED", "appName": "福建省集中消毒餐具追溯系统", "enabled": "DISABLED", "version": 1, "createdAt": "2026-09-16T00:00:00.000Z", "updatedAt": "2026-09-17T23:00:00.000Z", "valueMapping": {}, "lastCheckedAt": "2026-09-17T22:00:00.000Z", "connectionStatus": "UNCONFIGURED"}	2026-09-23 06:59:56.546313+00
integrations	MOCK_INT_MOCK_APP_30MESSAGE	89	{"id": "MOCK_INT_MOCK_APP_30MESSAGE", "kind": "MESSAGE", "mode": "PUSH", "name": "福建省集中消毒餐具追溯系统 · MESSAGE", "appId": "MOCK_APP_30", "remark": "���入���数待业务系统确认", "status": "DISABLED", "appName": "福建省集中消毒餐具追溯系统", "enabled": "DISABLED", "version": 1, "createdAt": "2026-09-16T00:00:00.000Z", "updatedAt": "2026-09-17T23:00:00.000Z", "valueMapping": {}, "lastCheckedAt": "2026-09-17T21:00:00.000Z", "connectionStatus": "UNCONFIGURED"}	2026-09-23 06:59:56.546313+00
integrations	MOCK_INT_MOCK_APP_31SSO	90	{"id": "MOCK_INT_MOCK_APP_31SSO", "kind": "SSO", "mode": "SSO", "name": "福建省职业病防治综合管理系统 · SSO", "appId": "MOCK_APP_31", "remark": "接入参数待业务系统确认", "status": "UNCONFIGURED", "appName": "福建省职业病防治综合管理系统", "enabled": "DISABLED", "version": 1, "createdAt": "2026-09-16T00:00:00.000Z", "updatedAt": "2026-09-17T23:00:00.000Z", "valueMapping": {}, "lastCheckedAt": "2026-09-17T23:00:00.000Z", "connectionStatus": "UNCONFIGURED"}	2026-09-23 06:59:56.546313+00
integrations	MOCK_INT_MOCK_APP_31TODO	91	{"id": "MOCK_INT_MOCK_APP_31TODO", "kind": "TODO", "mode": "PUSH", "name": "福建省职业病防治综合管理系统 · TODO", "appId": "MOCK_APP_31", "remark": "接入参数待业务系统确认", "status": "DISABLED", "appName": "福建省职业病防治综合管理系统", "enabled": "DISABLED", "version": 1, "createdAt": "2026-09-16T00:00:00.000Z", "updatedAt": "2026-09-17T23:00:00.000Z", "valueMapping": {}, "lastCheckedAt": "2026-09-17T22:00:00.000Z", "connectionStatus": "UNCONFIGURED"}	2026-09-23 06:59:56.546313+00
integrations	MOCK_INT_MOCK_APP_31MESSAGE	92	{"id": "MOCK_INT_MOCK_APP_31MESSAGE", "kind": "MESSAGE", "mode": "PUSH", "name": "福建省职业病防治综合管理系统 · MESSAGE", "appId": "MOCK_APP_31", "remark": "接入参数待业务系统确认", "status": "UNCONFIGURED", "appName": "福建省职业病防治综合管理系统", "enabled": "DISABLED", "version": 1, "createdAt": "2026-09-16T00:00:00.000Z", "updatedAt": "2026-09-17T23:00:00.000Z", "valueMapping": {}, "lastCheckedAt": "2026-09-17T21:00:00.000Z", "connectionStatus": "UNCONFIGURED"}	2026-09-23 06:59:56.546313+00
integrations	MOCK_INT_MOCK_APP_32SSO	93	{"id": "MOCK_INT_MOCK_APP_32SSO", "kind": "SSO", "mode": "SSO", "name": "福建省保健对象医疗管理信息系统 · SSO", "appId": "MOCK_APP_32", "remark": "接入参数待业务系统确认", "status": "DISABLED", "appName": "福建省保健对象医疗管理信息系统", "enabled": "DISABLED", "version": 1, "createdAt": "2026-09-16T00:00:00.000Z", "updatedAt": "2026-09-17T23:00:00.000Z", "valueMapping": {}, "lastCheckedAt": "2026-09-17T23:00:00.000Z", "connectionStatus": "UNCONFIGURED"}	2026-09-23 06:59:56.546313+00
integrations	MOCK_INT_MOCK_APP_32TODO	94	{"id": "MOCK_INT_MOCK_APP_32TODO", "kind": "TODO", "mode": "PUSH", "name": "福建省保健对象医疗管理信息系统 · TODO", "appId": "MOCK_APP_32", "remark": "接入参数待业务系统确认", "status": "UNCONFIGURED", "appName": "福建省保健对象医疗管理信息系统", "enabled": "DISABLED", "version": 1, "createdAt": "2026-09-16T00:00:00.000Z", "updatedAt": "2026-09-17T23:00:00.000Z", "valueMapping": {}, "lastCheckedAt": "2026-09-17T22:00:00.000Z", "connectionStatus": "UNCONFIGURED"}	2026-09-23 06:59:56.546313+00
visits	eb46fc293e1085a94b74974ea4b91841	15	{"at": "2026-09-17T20:00:00.000Z", "appId": "MOCK_APP_4", "userId": "MOCK_EDITOR"}	2026-09-23 06:59:56.546313+00
integrations	MOCK_INT_MOCK_APP_32MESSAGE	95	{"id": "MOCK_INT_MOCK_APP_32MESSAGE", "kind": "MESSAGE", "mode": "PUSH", "name": "福建省保健对象医疗管理信息系统 · MESSAGE", "appId": "MOCK_APP_32", "remark": "接入参数待业务系统确认", "status": "UNCONFIGURED", "appName": "福建省保健对象医疗管理信息系统", "enabled": "DISABLED", "version": 1, "createdAt": "2026-09-16T00:00:00.000Z", "updatedAt": "2026-09-17T23:00:00.000Z", "valueMapping": {}, "lastCheckedAt": "2026-09-17T21:00:00.000Z", "connectionStatus": "UNCONFIGURED"}	2026-09-23 06:59:56.546313+00
integrations	MOCK_INT_MOCK_APP_33SSO	96	{"id": "MOCK_INT_MOCK_APP_33SSO", "kind": "SSO", "mode": "SSO", "name": "福建省职业病与化学中毒预防控制中心门户网站 · SSO", "appId": "MOCK_APP_33", "remark": "接入参数待业务系统确认", "status": "UNCONFIGURED", "appName": "福建省职业病与化学中毒预防控制中心门户网站", "enabled": "DISABLED", "version": 1, "createdAt": "2026-09-16T00:00:00.000Z", "updatedAt": "2026-09-17T23:00:00.000Z", "valueMapping": {}, "lastCheckedAt": "2026-09-17T23:00:00.000Z", "connectionStatus": "UNCONFIGURED"}	2026-09-23 06:59:56.546313+00
integrations	MOCK_INT_MOCK_APP_33TODO	97	{"id": "MOCK_INT_MOCK_APP_33TODO", "kind": "TODO", "mode": "PUSH", "name": "福建省职业病与化学中毒预防控制中心门户网站 · TODO", "appId": "MOCK_APP_33", "remark": "接入参数待业务系统确认", "status": "UNCONFIGURED", "appName": "福建省职业病与化学中毒预防控制中心门户网站", "enabled": "DISABLED", "version": 1, "createdAt": "2026-09-16T00:00:00.000Z", "updatedAt": "2026-09-17T23:00:00.000Z", "valueMapping": {}, "lastCheckedAt": "2026-09-17T22:00:00.000Z", "connectionStatus": "UNCONFIGURED"}	2026-09-23 06:59:56.546313+00
integrations	MOCK_INT_MOCK_APP_33MESSAGE	98	{"id": "MOCK_INT_MOCK_APP_33MESSAGE", "kind": "MESSAGE", "mode": "PUSH", "name": "福建省职业病与化学中毒预防控制中心门户网站 · MESSAGE", "appId": "MOCK_APP_33", "remark": "接入参数待业务系统确认", "status": "UNCONFIGURED", "appName": "福建省�����业病与化学中毒预防控制中心门户网站", "enabled": "DISABLED", "version": 1, "createdAt": "2026-09-16T00:00:00.000Z", "updatedAt": "2026-09-17T23:00:00.000Z", "valueMapping": {}, "lastCheckedAt": "2026-09-17T21:00:00.000Z", "connectionStatus": "UNCONFIGURED"}	2026-09-23 06:59:56.546313+00
integrations	MOCK_INT_MOCK_APP_34SSO	99	{"id": "MOCK_INT_MOCK_APP_34SSO", "kind": "SSO", "mode": "SSO", "name": "福建省卫生监督电子执法全过程记录系统 · SSO", "appId": "MOCK_APP_34", "remark": "接入参数待业务系统确认", "status": "UNCONFIGURED", "appName": "福建省卫生���督���子执法全过程记录系统", "enabled": "DISABLED", "version": 1, "createdAt": "2026-09-16T00:00:00.000Z", "updatedAt": "2026-09-17T23:00:00.000Z", "valueMapping": {}, "lastCheckedAt": "2026-09-17T23:00:00.000Z", "connectionStatus": "UNCONFIGURED"}	2026-09-23 06:59:56.546313+00
integrations	MOCK_INT_MOCK_APP_34TODO	100	{"id": "MOCK_INT_MOCK_APP_34TODO", "kind": "TODO", "mode": "PUSH", "name": "福建省卫生监督电子执法全过程记录系统 · TODO", "appId": "MOCK_APP_34", "remark": "接入参数待业务系统确认", "status": "UNCONFIGURED", "appName": "福建省卫生监督电子执法全过程记录系统", "enabled": "DISABLED", "version": 1, "createdAt": "2026-09-16T00:00:00.000Z", "updatedAt": "2026-09-17T23:00:00.000Z", "valueMapping": {}, "lastCheckedAt": "2026-09-17T22:00:00.000Z", "connectionStatus": "UNCONFIGURED"}	2026-09-23 06:59:56.546313+00
integrations	MOCK_INT_MOCK_APP_34MESSAGE	101	{"id": "MOCK_INT_MOCK_APP_34MESSAGE", "kind": "MESSAGE", "mode": "PUSH", "name": "福建省卫生监督电子执法全过程记录系统 · MESSAGE", "appId": "MOCK_APP_34", "remark": "接入参数待业务系统确认", "status": "DISABLED", "appName": "福建省卫生监督电子执法全过程记录系统", "enabled": "DISABLED", "version": 1, "createdAt": "2026-09-16T00:00:00.000Z", "updatedAt": "2026-09-17T23:00:00.000Z", "valueMapping": {}, "lastCheckedAt": "2026-09-17T21:00:00.000Z", "connectionStatus": "UNCONFIGURED"}	2026-09-23 06:59:56.546313+00
integrations	MOCK_INT_MOCK_APP_35SSO	102	{"id": "MOCK_INT_MOCK_APP_35SSO", "kind": "SSO", "mode": "SSO", "name": "福建省医疗卫生信用信息归集系统 · SSO", "appId": "MOCK_APP_35", "remark": "接入参数待业务系统确认", "status": "UNCONFIGURED", "appName": "福建省医疗卫生信用信息归集系统", "enabled": "DISABLED", "version": 1, "createdAt": "2026-09-16T00:00:00.000Z", "updatedAt": "2026-09-17T23:00:00.000Z", "valueMapping": {}, "lastCheckedAt": "2026-09-17T23:00:00.000Z", "connectionStatus": "UNCONFIGURED"}	2026-09-23 06:59:56.546313+00
integrations	MOCK_INT_MOCK_APP_35TODO	103	{"id": "MOCK_INT_MOCK_APP_35TODO", "kind": "TODO", "mode": "PUSH", "name": "福建省医疗卫生信用信息归集系统 · TODO", "appId": "MOCK_APP_35", "remark": "接入参数待业务系统确认", "status": "DISABLED", "appName": "福建���医疗卫生信用信息归集系统", "enabled": "DISABLED", "version": 1, "createdAt": "2026-09-16T00:00:00.000Z", "updatedAt": "2026-09-17T23:00:00.000Z", "valueMapping": {}, "lastCheckedAt": "2026-09-17T22:00:00.000Z", "connectionStatus": "UNCONFIGURED"}	2026-09-23 06:59:56.546313+00
integrations	MOCK_INT_MOCK_APP_35MESSAGE	104	{"id": "MOCK_INT_MOCK_APP_35MESSAGE", "kind": "MESSAGE", "mode": "PUSH", "name": "福建省医疗卫生信用信息归集系统 · MESSAGE", "appId": "MOCK_APP_35", "remark": "接入参数待业务系统确认", "status": "UNCONFIGURED", "appName": "福建省医疗卫生信用信息归集系统", "enabled": "DISABLED", "version": 1, "createdAt": "2026-09-16T00:00:00.000Z", "updatedAt": "2026-09-17T23:00:00.000Z", "valueMapping": {}, "lastCheckedAt": "2026-09-17T21:00:00.000Z", "connectionStatus": "UNCONFIGURED"}	2026-09-23 06:59:56.546313+00
integrations	MOCK_INT_MOCK_APP_36SSO	105	{"id": "MOCK_INT_MOCK_APP_36SSO", "kind": "SSO", "mode": "SSO", "name": "福建�����医疗卫生不良执业记分系统 · SSO", "appId": "MOCK_APP_36", "remark": "接入参数待业务系统确认", "status": "DISABLED", "appName": "福建省医疗卫生不良执业记分系统", "enabled": "DISABLED", "version": 1, "createdAt": "2026-09-16T00:00:00.000Z", "updatedAt": "2026-09-17T23:00:00.000Z", "valueMapping": {}, "lastCheckedAt": "2026-09-17T23:00:00.000Z", "connectionStatus": "UNCONFIGURED"}	2026-09-23 06:59:56.546313+00
integrations	MOCK_INT_MOCK_APP_36TODO	106	{"id": "MOCK_INT_MOCK_APP_36TODO", "kind": "TODO", "mode": "PUSH", "name": "福建省医疗卫生不良执业记分系统 · TODO", "appId": "MOCK_APP_36", "remark": "接入参数待业务系统确认", "status": "UNCONFIGURED", "appName": "福建省医疗卫生不良执业记分系统", "enabled": "DISABLED", "version": 1, "createdAt": "2026-09-16T00:00:00.000Z", "updatedAt": "2026-09-17T23:00:00.000Z", "valueMapping": {}, "lastCheckedAt": "2026-09-17T22:00:00.000Z", "connectionStatus": "UNCONFIGURED"}	2026-09-23 06:59:56.546313+00
visits	c89f6fe7008c27ab6893be3b99d960e8	16	{"at": "2026-09-18T14:48:29.518Z", "appId": "MOCK_APP_1", "userId": "MOCK_USER_1"}	2026-09-23 06:59:56.546313+00
visits	dffb849f683ab5be261dbe748dff6f74	17	{"at": "2026-09-18T15:10:47.367Z", "appId": "MOCK_APP_6", "userId": "MOCK_USER_2"}	2026-09-23 06:59:56.546313+00
visits	eaa2a5cb16344fa236fe576a2b353a86	18	{"at": "2026-09-20T07:38:49.028Z", "appId": "MOCK_APP_12", "userId": "MOCK_USER_1"}	2026-09-23 06:59:56.546313+00
integrations	MOCK_INT_MOCK_APP_36MESSAGE	107	{"id": "MOCK_INT_MOCK_APP_36MESSAGE", "kind": "MESSAGE", "mode": "PUSH", "name": "福建省医疗卫生不良执业记分系统 · MESSAGE", "appId": "MOCK_APP_36", "remark": "接入参数待业务系统确认", "status": "UNCONFIGURED", "appName": "福建省医疗卫生不良执业记分系统", "enabled": "DISABLED", "version": 1, "createdAt": "2026-09-16T00:00:00.000Z", "updatedAt": "2026-09-17T23:00:00.000Z", "valueMapping": {}, "lastCheckedAt": "2026-09-17T21:00:00.000Z", "connectionStatus": "UNCONFIGURED"}	2026-09-23 06:59:56.546313+00
integrations	MOCK_INT_MOCK_APP_37SSO	108	{"id": "MOCK_INT_MOCK_APP_37SSO", "kind": "SSO", "mode": "SSO", "name": "福建省诊所诊疗监督系统 · SSO", "appId": "MOCK_APP_37", "remark": "接入参数待业务系统确认", "status": "UNCONFIGURED", "appName": "福建省���所诊疗监督系统", "enabled": "DISABLED", "version": 1, "createdAt": "2026-09-16T00:00:00.000Z", "updatedAt": "2026-09-17T23:00:00.000Z", "valueMapping": {}, "lastCheckedAt": "2026-09-17T23:00:00.000Z", "connectionStatus": "UNCONFIGURED"}	2026-09-23 06:59:56.546313+00
integrations	MOCK_INT_MOCK_APP_37TODO	109	{"id": "MOCK_INT_MOCK_APP_37TODO", "kind": "TODO", "mode": "PUSH", "name": "福建省诊所诊疗监督系统 · TODO", "appId": "MOCK_APP_37", "remark": "接入参数待业务系统确认", "status": "UNCONFIGURED", "appName": "福建省诊所诊���监督系统", "enabled": "DISABLED", "version": 1, "createdAt": "2026-09-16T00:00:00.000Z", "updatedAt": "2026-09-17T23:00:00.000Z", "valueMapping": {}, "lastCheckedAt": "2026-09-17T22:00:00.000Z", "connectionStatus": "UNCONFIGURED"}	2026-09-23 06:59:56.546313+00
integrations	MOCK_INT_MOCK_APP_37MESSAGE	110	{"id": "MOCK_INT_MOCK_APP_37MESSAGE", "kind": "MESSAGE", "mode": "PUSH", "name": "福建省诊所诊疗监督系统 · MESSAGE", "appId": "MOCK_APP_37", "remark": "接入参数待业务系统确认", "status": "UNCONFIGURED", "appName": "福建省诊所��疗监督系统", "enabled": "DISABLED", "version": 1, "createdAt": "2026-09-16T00:00:00.000Z", "updatedAt": "2026-09-17T23:00:00.000Z", "valueMapping": {}, "lastCheckedAt": "2026-09-17T21:00:00.000Z", "connectionStatus": "UNCONFIGURED"}	2026-09-23 06:59:56.546313+00
integrations	MOCK_INT_MOCK_APP_38SSO	111	{"id": "MOCK_INT_MOCK_APP_38SSO", "kind": "SSO", "mode": "SSO", "name": "福建省医疗服务资质检测系统 · SSO", "appId": "MOCK_APP_38", "remark": "接入参数待业务系统确认", "status": "UNCONFIGURED", "appName": "福建省医疗服务资质检测系统", "enabled": "DISABLED", "version": 1, "createdAt": "2026-09-16T00:00:00.000Z", "updatedAt": "2026-09-17T23:00:00.000Z", "valueMapping": {}, "lastCheckedAt": "2026-09-17T23:00:00.000Z", "connectionStatus": "UNCONFIGURED"}	2026-09-23 06:59:56.546313+00
integrations	MOCK_INT_MOCK_APP_38TODO	112	{"id": "MOCK_INT_MOCK_APP_38TODO", "kind": "TODO", "mode": "PUSH", "name": "福建省医疗服务资质检测系统 · TODO", "appId": "MOCK_APP_38", "remark": "接入参数待业务系统确认", "status": "UNCONFIGURED", "appName": "福建省医疗服务资质检测系统", "enabled": "DISABLED", "version": 1, "createdAt": "2026-09-16T00:00:00.000Z", "updatedAt": "2026-09-17T23:00:00.000Z", "valueMapping": {}, "lastCheckedAt": "2026-09-17T22:00:00.000Z", "connectionStatus": "UNCONFIGURED"}	2026-09-23 06:59:56.546313+00
integrations	MOCK_INT_MOCK_APP_38MESSAGE	113	{"id": "MOCK_INT_MOCK_APP_38MESSAGE", "kind": "MESSAGE", "mode": "PUSH", "name": "福建省医疗服务资质检测系统 · MESSAGE", "appId": "MOCK_APP_38", "remark": "接入参数待业务系统确认", "status": "DISABLED", "appName": "福建省医疗服务资质检测系统", "enabled": "DISABLED", "version": 1, "createdAt": "2026-09-16T00:00:00.000Z", "updatedAt": "2026-09-17T23:00:00.000Z", "valueMapping": {}, "lastCheckedAt": "2026-09-17T21:00:00.000Z", "connectionStatus": "UNCONFIGURED"}	2026-09-23 06:59:56.546313+00
integrations	MOCK_INT_MOCK_APP_39SSO	114	{"id": "MOCK_INT_MOCK_APP_39SSO", "kind": "SSO", "mode": "SSO", "name": "福建省食源性疾病省级平台系统 · SSO", "appId": "MOCK_APP_39", "remark": "接入参数待业务系统确认", "status": "UNCONFIGURED", "appName": "福建省食源性疾病省级平台系统", "enabled": "DISABLED", "version": 1, "createdAt": "2026-09-16T00:00:00.000Z", "updatedAt": "2026-09-17T23:00:00.000Z", "valueMapping": {}, "lastCheckedAt": "2026-09-17T23:00:00.000Z", "connectionStatus": "UNCONFIGURED"}	2026-09-23 06:59:56.546313+00
integrations	MOCK_INT_MOCK_APP_39TODO	115	{"id": "MOCK_INT_MOCK_APP_39TODO", "kind": "TODO", "mode": "PUSH", "name": "福建省食源性疾病省级平台系统 · TODO", "appId": "MOCK_APP_39", "remark": "接入参数待业务系统确认", "status": "DISABLED", "appName": "福建省食源性疾病省级平台系统", "enabled": "DISABLED", "version": 1, "createdAt": "2026-09-16T00:00:00.000Z", "updatedAt": "2026-09-17T23:00:00.000Z", "valueMapping": {}, "lastCheckedAt": "2026-09-17T22:00:00.000Z", "connectionStatus": "UNCONFIGURED"}	2026-09-23 06:59:56.546313+00
integrations	MOCK_INT_MOCK_APP_39MESSAGE	116	{"id": "MOCK_INT_MOCK_APP_39MESSAGE", "kind": "MESSAGE", "mode": "PUSH", "name": "福建省食源性疾病省级平台系统 · MESSAGE", "appId": "MOCK_APP_39", "remark": "接入参数待业务系统确认", "status": "UNCONFIGURED", "appName": "福建省食源性疾病省级平台系统", "enabled": "DISABLED", "version": 1, "createdAt": "2026-09-16T00:00:00.000Z", "updatedAt": "2026-09-17T23:00:00.000Z", "valueMapping": {}, "lastCheckedAt": "2026-09-17T21:00:00.000Z", "connectionStatus": "UNCONFIGURED"}	2026-09-23 06:59:56.546313+00
integrations	MOCK_INT_MOCK_APP_40SSO	117	{"id": "MOCK_INT_MOCK_APP_40SSO", "kind": "SSO", "mode": "SSO", "name": "福建省疾病预防控制中心信息门户系统 · SSO", "appId": "MOCK_APP_40", "remark": "接入参数待业务系统确认", "status": "DISABLED", "appName": "福建省疾病预防控制中心信息门户系统", "enabled": "DISABLED", "version": 1, "createdAt": "2026-09-16T00:00:00.000Z", "updatedAt": "2026-09-17T23:00:00.000Z", "valueMapping": {}, "lastCheckedAt": "2026-09-17T23:00:00.000Z", "connectionStatus": "UNCONFIGURED"}	2026-09-23 06:59:56.546313+00
integrations	MOCK_INT_MOCK_APP_40TODO	118	{"id": "MOCK_INT_MOCK_APP_40TODO", "kind": "TODO", "mode": "PUSH", "name": "福建省疾病预防控制中心信息门户系统 · TODO", "appId": "MOCK_APP_40", "remark": "接入参数待业务系统确认", "status": "UNCONFIGURED", "appName": "福建省疾病预防控制中心信息门户系统", "enabled": "DISABLED", "version": 1, "createdAt": "2026-09-16T00:00:00.000Z", "updatedAt": "2026-09-17T23:00:00.000Z", "valueMapping": {}, "lastCheckedAt": "2026-09-17T22:00:00.000Z", "connectionStatus": "UNCONFIGURED"}	2026-09-23 06:59:56.546313+00
integrations	MOCK_INT_MOCK_APP_40MESSAGE	119	{"id": "MOCK_INT_MOCK_APP_40MESSAGE", "kind": "MESSAGE", "mode": "PUSH", "name": "福建省疾病预防控制中心信息门户系统 · MESSAGE", "appId": "MOCK_APP_40", "remark": "接入参数待业务系统确认", "status": "UNCONFIGURED", "appName": "福建省疾病预防控制中心信息门户系统", "enabled": "DISABLED", "version": 1, "createdAt": "2026-09-16T00:00:00.000Z", "updatedAt": "2026-09-17T23:00:00.000Z", "valueMapping": {}, "lastCheckedAt": "2026-09-17T21:00:00.000Z", "connectionStatus": "UNCONFIGURED"}	2026-09-23 06:59:56.546313+00
visits	c1a0b329d2a32ade6e7f2e4cacc3a82d	19	{"at": "2026-09-20T07:41:38.007Z", "appId": "MOCK_APP_3", "userId": "MOCK_ADMIN"}	2026-09-23 06:59:56.546313+00
integrations	MOCK_INT_MOCK_APP_41SSO	120	{"id": "MOCK_INT_MOCK_APP_41SSO", "kind": "SSO", "mode": "SSO", "name": "福建省慢性病防控指标系统 · SSO", "appId": "MOCK_APP_41", "remark": "接入参数待业务系统确认", "status": "UNCONFIGURED", "appName": "福建省慢性病防控指标系统", "enabled": "DISABLED", "version": 1, "createdAt": "2026-09-16T00:00:00.000Z", "updatedAt": "2026-09-17T23:00:00.000Z", "valueMapping": {}, "lastCheckedAt": "2026-09-17T23:00:00.000Z", "connectionStatus": "UNCONFIGURED"}	2026-09-23 06:59:56.546313+00
integrations	MOCK_INT_MOCK_APP_41TODO	121	{"id": "MOCK_INT_MOCK_APP_41TODO", "kind": "TODO", "mode": "PUSH", "name": "福建省慢性病防控指标系统 · TODO", "appId": "MOCK_APP_41", "remark": "接入参数待业务系统确认", "status": "UNCONFIGURED", "appName": "福建省慢性病防控指标系统", "enabled": "DISABLED", "version": 1, "createdAt": "2026-09-16T00:00:00.000Z", "updatedAt": "2026-09-17T23:00:00.000Z", "valueMapping": {}, "lastCheckedAt": "2026-09-17T22:00:00.000Z", "connectionStatus": "UNCONFIGURED"}	2026-09-23 06:59:56.546313+00
integrations	MOCK_INT_MOCK_APP_41MESSAGE	122	{"id": "MOCK_INT_MOCK_APP_41MESSAGE", "kind": "MESSAGE", "mode": "PUSH", "name": "福建省慢性病防控指标系统 · MESSAGE", "appId": "MOCK_APP_41", "remark": "接入参数待业务系统确认", "status": "UNCONFIGURED", "appName": "福建省慢性病防控指标系统", "enabled": "DISABLED", "version": 1, "createdAt": "2026-09-16T00:00:00.000Z", "updatedAt": "2026-09-17T23:00:00.000Z", "valueMapping": {}, "lastCheckedAt": "2026-09-17T21:00:00.000Z", "connectionStatus": "UNCONFIGURED"}	2026-09-23 06:59:56.546313+00
integrations	MOCK_INT_MOCK_APP_43SSO	123	{"id": "MOCK_INT_MOCK_APP_43SSO", "kind": "SSO", "mode": "SSO", "name": "福建省疫苗冷链监测系统 · SSO", "appId": "MOCK_APP_43", "remark": "接入参数待业务系统确认", "status": "DISABLED", "appName": "福建省疫苗冷链监测系统", "enabled": "DISABLED", "version": 1, "createdAt": "2026-09-16T00:00:00.000Z", "updatedAt": "2026-09-17T23:00:00.000Z", "valueMapping": {}, "lastCheckedAt": "2026-09-17T23:00:00.000Z", "connectionStatus": "UNCONFIGURED"}	2026-09-23 06:59:56.546313+00
integrations	MOCK_INT_MOCK_APP_43TODO	124	{"id": "MOCK_INT_MOCK_APP_43TODO", "kind": "TODO", "mode": "PUSH", "name": "福建省疫苗冷链监测系统 · TODO", "appId": "MOCK_APP_43", "remark": "接入参数待业务系统确认", "status": "DISABLED", "appName": "福建省疫苗冷链监测系统", "enabled": "DISABLED", "version": 1, "createdAt": "2026-09-16T00:00:00.000Z", "updatedAt": "2026-09-17T23:00:00.000Z", "valueMapping": {}, "lastCheckedAt": "2026-09-17T22:00:00.000Z", "connectionStatus": "UNCONFIGURED"}	2026-09-23 06:59:56.546313+00
integrations	MOCK_INT_MOCK_APP_43MESSAGE	125	{"id": "MOCK_INT_MOCK_APP_43MESSAGE", "kind": "MESSAGE", "mode": "PUSH", "name": "福建省疫苗冷链监测系统 · MESSAGE", "appId": "MOCK_APP_43", "remark": "接入参数待业务系统确认", "status": "DISABLED", "appName": "福建省疫苗冷链监测系统", "enabled": "DISABLED", "version": 1, "createdAt": "2026-09-16T00:00:00.000Z", "updatedAt": "2026-09-17T23:00:00.000Z", "valueMapping": {}, "lastCheckedAt": "2026-09-17T21:00:00.000Z", "connectionStatus": "UNCONFIGURED"}	2026-09-23 06:59:56.546313+00
monitorSamples	MONITOR_0	0	{"id": "MONITOR_0", "kind": "SSO", "appId": "MOCK_APP_1", "status": "UNCONFIGURED", "version": 1, "dataSource": "FIXTURE", "lastCheckedAt": "2026-09-19T01:00:00.000Z", "responseTimeMs": null}	2026-09-23 06:59:56.546313+00
monitorSamples	SCENARIO_MONITOR_MOCK_APP_1_TODO	1	{"id": "SCENARIO_MONITOR_MOCK_APP_1_TODO", "kind": "TODO", "appId": "MOCK_APP_1", "status": "NORMAL", "version": 1, "dataSource": "FIXTURE", "lastCheckedAt": "2026-09-19T01:00:00.000Z", "responseTimeMs": 126}	2026-09-23 06:59:56.546313+00
monitorSamples	SCENARIO_MONITOR_MOCK_APP_1_MESSAGE	2	{"id": "SCENARIO_MONITOR_MOCK_APP_1_MESSAGE", "kind": "MESSAGE", "appId": "MOCK_APP_1", "status": "ABNORMAL", "version": 1, "dataSource": "FIXTURE", "lastCheckedAt": "2026-09-19T01:00:00.000Z", "responseTimeMs": null}	2026-09-23 06:59:56.546313+00
monitorSamples	SCENARIO_MONITOR_MOCK_APP_2_SSO	3	{"id": "SCENARIO_MONITOR_MOCK_APP_2_SSO", "kind": "SSO", "appId": "MOCK_APP_2", "status": "NORMAL", "version": 1, "dataSource": "FIXTURE", "lastCheckedAt": "2026-09-19T01:00:00.000Z", "responseTimeMs": 126}	2026-09-23 06:59:56.546313+00
monitorSamples	MONITOR_1	4	{"id": "MONITOR_1", "kind": "TODO", "appId": "MOCK_APP_2", "status": "ABNORMAL", "version": 1, "dataSource": "FIXTURE", "lastCheckedAt": "2026-09-19T01:00:00.000Z", "responseTimeMs": null}	2026-09-23 06:59:56.546313+00
monitorSamples	SCENARIO_MONITOR_MOCK_APP_2_MESSAGE	5	{"id": "SCENARIO_MONITOR_MOCK_APP_2_MESSAGE", "kind": "MESSAGE", "appId": "MOCK_APP_2", "status": "DISABLED", "version": 1, "dataSource": "FIXTURE", "lastCheckedAt": "2026-09-19T01:00:00.000Z", "responseTimeMs": null}	2026-09-23 06:59:56.546313+00
monitorSamples	SCENARIO_MONITOR_MOCK_APP_3_SSO	6	{"id": "SCENARIO_MONITOR_MOCK_APP_3_SSO", "kind": "SSO", "appId": "MOCK_APP_3", "status": "ABNORMAL", "version": 1, "dataSource": "FIXTURE", "lastCheckedAt": "2026-09-19T01:00:00.000Z", "responseTimeMs": null}	2026-09-23 06:59:56.546313+00
monitorSamples	SCENARIO_MONITOR_MOCK_APP_3_TODO	7	{"id": "SCENARIO_MONITOR_MOCK_APP_3_TODO", "kind": "TODO", "appId": "MOCK_APP_3", "status": "DISABLED", "version": 1, "dataSource": "FIXTURE", "lastCheckedAt": "2026-09-19T01:00:00.000Z", "responseTimeMs": null}	2026-09-23 06:59:56.546313+00
monitorSamples	MONITOR_2	8	{"id": "MONITOR_2", "kind": "MESSAGE", "appId": "MOCK_APP_3", "status": "UNCONFIGURED", "version": 1, "dataSource": "FIXTURE", "lastCheckedAt": "2026-09-19T01:00:00.000Z", "responseTimeMs": null}	2026-09-23 06:59:56.546313+00
monitorSamples	SCENARIO_MONITOR_MOCK_APP_4_SSO	9	{"id": "SCENARIO_MONITOR_MOCK_APP_4_SSO", "kind": "SSO", "appId": "MOCK_APP_4", "status": "DISABLED", "version": 1, "dataSource": "FIXTURE", "lastCheckedAt": "2026-09-19T01:00:00.000Z", "responseTimeMs": null}	2026-09-23 06:59:56.546313+00
monitorSamples	SCENARIO_MONITOR_MOCK_APP_4_TODO	10	{"id": "SCENARIO_MONITOR_MOCK_APP_4_TODO", "kind": "TODO", "appId": "MOCK_APP_4", "status": "UNCONFIGURED", "version": 1, "dataSource": "FIXTURE", "lastCheckedAt": "2026-09-19T01:00:00.000Z", "responseTimeMs": null}	2026-09-23 06:59:56.546313+00
monitorSamples	SCENARIO_MONITOR_MOCK_APP_4_MESSAGE	11	{"id": "SCENARIO_MONITOR_MOCK_APP_4_MESSAGE", "kind": "MESSAGE", "appId": "MOCK_APP_4", "status": "NORMAL", "version": 1, "dataSource": "FIXTURE", "lastCheckedAt": "2026-09-19T01:00:00.000Z", "responseTimeMs": 126}	2026-09-23 06:59:56.546313+00
visits	93d3f3e6e3b9f2506791aa972518dfc0	0	{"at": "2026-09-17T23:00:00.000Z", "appId": "MOCK_APP_1", "userId": "MOCK_USER_1"}	2026-09-23 06:59:56.546313+00
visits	ba2357255949e7d04aa491899e990b6d	1	{"at": "2026-09-17T22:00:00.000Z", "appId": "MOCK_APP_2", "userId": "MOCK_USER_1"}	2026-09-23 06:59:56.546313+00
visits	a51ffe141c8f594161bae1fe505bd078	2	{"at": "2026-09-17T21:00:00.000Z", "appId": "MOCK_APP_3", "userId": "MOCK_USER_1"}	2026-09-23 06:59:56.546313+00
visits	8e6e1deec7fd355d1d548958ba2824c6	3	{"at": "2026-09-17T20:00:00.000Z", "appId": "MOCK_APP_4", "userId": "MOCK_USER_1"}	2026-09-23 06:59:56.546313+00
visits	24471d8075e260200974f1442312eac6	4	{"at": "2026-09-17T23:00:00.000Z", "appId": "MOCK_APP_1", "userId": "MOCK_USER_2"}	2026-09-23 06:59:56.546313+00
visits	805b46729717f4ab634bd415fb00f2fe	20	{"at": "2026-09-20T08:10:14.506Z", "appId": "MOCK_APP_1", "userId": "MOCK_ADMIN"}	2026-09-23 06:59:56.546313+00
visits	eb78660a2ea4f69dde047e401e1b099c	21	{"at": "2026-09-20T08:10:58.768Z", "appId": "MOCK_APP_7", "userId": "MOCK_ADMIN"}	2026-09-23 06:59:56.546313+00
organizations	MOCK_ORG_PORTAL	0	{"id": "MOCK_ORG_PORTAL", "code": "ORG_PORTAL", "name": "门户运行保障中心", "path": "门户运行保障中心", "type": "PORTAL_UNIT", "remark": "门户本地维护组织", "source": "PORTAL_LOCAL", "status": "ENABLED", "version": 1, "parentId": null, "createdAt": "2026-09-16T00:00:00.000Z", "sortOrder": 1, "updatedAt": "2026-09-17T23:00:00.000Z", "parentName": null}	2026-09-23 07:05:39.571621+00
organizations	MOCK_ORG_HEALTH	1	{"id": "MOCK_ORG_HEALTH", "code": "ORG_HEALTH", "name": "卫生健康业务处", "path": "卫生健康业务处", "type": "GOV_DEPARTMENT", "remark": "政务组织索引", "source": "MINZHENGWU", "status": "ENABLED", "version": 1, "parentId": null, "createdAt": "2026-09-16T00:00:00.000Z", "sortOrder": 2, "updatedAt": "2026-09-17T23:00:00.000Z", "parentName": null}	2026-09-23 07:05:39.571621+00
organizations	MOCK_ORG_PUBLISH	2	{"id": "MOCK_ORG_PUBLISH", "code": "ORG_PUBLISH", "name": "信息发布科", "path": "门户运行保障中心 / 信息发布科", "type": "GOV_DEPARTMENT", "remark": "公告与信息发布维护", "source": "PORTAL_LOCAL", "status": "ENABLED", "version": 1, "parentId": "MOCK_ORG_PORTAL", "createdAt": "2026-09-16T00:00:00.000Z", "sortOrder": 3, "updatedAt": "2026-09-17T23:00:00.000Z", "parentName": "门户运行保障中心"}	2026-09-23 07:05:39.571621+00
dictTypes	MOCK_DICT_TYPE_APP_CATEGORY	0	{"id": "MOCK_DICT_TYPE_APP_CATEGORY", "code": "application_category", "name": "应用系统分类", "status": "ENABLED", "version": 1, "createdAt": "2026-09-16T00:00:00.000Z", "sortOrder": 1, "updatedAt": "2026-09-17T23:00:00.000Z", "description": "应用目录使用的业务分类", "systemLocked": false}	2026-09-23 07:05:39.571621+00
dictTypes	MOCK_DICT_TYPE_ANN_TYPE	1	{"id": "MOCK_DICT_TYPE_ANN_TYPE", "code": "announcement_type", "name": "公告类型", "status": "ENABLED", "version": 1, "createdAt": "2026-09-16T00:00:00.000Z", "sortOrder": 2, "updatedAt": "2026-09-17T23:00:00.000Z", "description": "通知公告业务类型", "systemLocked": false}	2026-09-23 07:05:39.571621+00
dictTypes	MOCK_DICT_TYPE_ORG_TYPE	2	{"id": "MOCK_DICT_TYPE_ORG_TYPE", "code": "organization_type", "name": "组织类型", "status": "ENABLED", "version": 1, "createdAt": "2026-09-16T00:00:00.000Z", "sortOrder": 3, "updatedAt": "2026-09-17T23:00:00.000Z", "description": "门户组织索引类型", "systemLocked": false}	2026-09-23 07:05:39.571621+00
dictTypes	MOCK_DICT_TYPE_ENABLE	3	{"id": "MOCK_DICT_TYPE_ENABLE", "code": "enable_status", "name": "启用状态", "status": "ENABLED", "version": 1, "createdAt": "2026-09-16T00:00:00.000Z", "sortOrder": 90, "updatedAt": "2026-09-17T23:00:00.000Z", "description": "系统受控状态字典", "systemLocked": true}	2026-09-23 07:05:39.571621+00
dictTypes	MOCK_DICT_TYPE_RUNTIME	4	{"id": "MOCK_DICT_TYPE_RUNTIME", "code": "runtime_status", "name": "运行状态", "status": "ENABLED", "version": 1, "createdAt": "2026-09-16T00:00:00.000Z", "sortOrder": 91, "updatedAt": "2026-09-17T23:00:00.000Z", "description": "系统受控运行状态", "systemLocked": true}	2026-09-23 07:05:39.571621+00
dictTypes	MOCK_DICT_TYPE_PROTOCOL	5	{"id": "MOCK_DICT_TYPE_PROTOCOL", "code": "integration_protocol", "name": "接入协议", "status": "ENABLED", "version": 1, "createdAt": "2026-09-16T00:00:00.000Z", "sortOrder": 92, "updatedAt": "2026-09-17T23:00:00.000Z", "description": "代码已支持的接入协议", "systemLocked": true}	2026-09-23 07:05:39.571621+00
dictItems	MOCK_DICT_APP_PUBLIC	0	{"id": "MOCK_DICT_APP_PUBLIC", "label": "公众服务", "value": "PUBLIC", "remark": "应用分类", "status": "ENABLED", "version": 1, "typeCode": "application_category", "createdAt": "2026-09-16T00:00:00.000Z", "sortOrder": 1, "updatedAt": "2026-09-17T23:00:00.000Z", "systemLocked": false}	2026-09-23 07:05:39.571621+00
dictItems	MOCK_DICT_APP_GOV	1	{"id": "MOCK_DICT_APP_GOV", "label": "政务协同", "value": "GOV", "remark": "应用分类", "status": "ENABLED", "version": 1, "typeCode": "application_category", "createdAt": "2026-09-16T00:00:00.000Z", "sortOrder": 2, "updatedAt": "2026-09-17T23:00:00.000Z", "systemLocked": false}	2026-09-23 07:05:39.571621+00
dictItems	MOCK_DICT_APP_REGULATION	2	{"id": "MOCK_DICT_APP_REGULATION", "label": "行业监管", "value": "REGULATION", "remark": "应用分类", "status": "ENABLED", "version": 1, "typeCode": "application_category", "createdAt": "2026-09-16T00:00:00.000Z", "sortOrder": 3, "updatedAt": "2026-09-17T23:00:00.000Z", "systemLocked": false}	2026-09-23 07:05:39.571621+00
dictItems	MOCK_DICT_APP_TRAINING	3	{"id": "MOCK_DICT_APP_TRAINING", "label": "培训考试", "value": "TRAINING", "remark": "应用分类", "status": "ENABLED", "version": 1, "typeCode": "application_category", "createdAt": "2026-09-16T00:00:00.000Z", "sortOrder": 4, "updatedAt": "2026-09-17T23:00:00.000Z", "systemLocked": false}	2026-09-23 07:05:39.571621+00
dictItems	MOCK_DICT_APP_SUPERVISION	4	{"id": "MOCK_DICT_APP_SUPERVISION", "label": "卫生监督", "value": "SUPERVISION", "remark": "应用分类", "status": "ENABLED", "version": 1, "typeCode": "application_category", "createdAt": "2026-09-16T00:00:00.000Z", "sortOrder": 5, "updatedAt": "2026-09-17T23:00:00.000Z", "systemLocked": false}	2026-09-23 07:05:39.571621+00
dictItems	MOCK_DICT_APP_PREVENTION	5	{"id": "MOCK_DICT_APP_PREVENTION", "label": "疾病防控", "value": "PREVENTION", "remark": "应用分类", "status": "ENABLED", "version": 1, "typeCode": "application_category", "createdAt": "2026-09-16T00:00:00.000Z", "sortOrder": 6, "updatedAt": "2026-09-17T23:00:00.000Z", "systemLocked": false}	2026-09-23 07:05:39.571621+00
dictItems	MOCK_DICT_ANN_0	6	{"id": "MOCK_DICT_ANN_0", "label": "通知", "value": "NOTICE", "remark": "", "status": "ENABLED", "version": 1, "typeCode": "announcement_type", "createdAt": "2026-09-16T00:00:00.000Z", "sortOrder": 1, "updatedAt": "2026-09-17T23:00:00.000Z", "systemLocked": false}	2026-09-23 07:05:39.571621+00
dictItems	MOCK_DICT_ANN_1	7	{"id": "MOCK_DICT_ANN_1", "label": "提示", "value": "TIP", "remark": "", "status": "ENABLED", "version": 1, "typeCode": "announcement_type", "createdAt": "2026-09-16T00:00:00.000Z", "sortOrder": 2, "updatedAt": "2026-09-17T23:00:00.000Z", "systemLocked": false}	2026-09-23 07:05:39.571621+00
dictItems	MOCK_DICT_ANN_2	8	{"id": "MOCK_DICT_ANN_2", "label": "工作安排", "value": "WORK", "remark": "", "status": "ENABLED", "version": 1, "typeCode": "announcement_type", "createdAt": "2026-09-16T00:00:00.000Z", "sortOrder": 3, "updatedAt": "2026-09-17T23:00:00.000Z", "systemLocked": false}	2026-09-23 07:05:39.571621+00
dictItems	MOCK_DICT_ORG_0	9	{"id": "MOCK_DICT_ORG_0", "label": "门户单位", "value": "PORTAL_UNIT", "remark": "", "status": "ENABLED", "version": 1, "typeCode": "organization_type", "createdAt": "2026-09-16T00:00:00.000Z", "sortOrder": 1, "updatedAt": "2026-09-17T23:00:00.000Z", "systemLocked": false}	2026-09-23 07:05:39.571621+00
dictItems	MOCK_DICT_ORG_1	10	{"id": "MOCK_DICT_ORG_1", "label": "政务部门", "value": "GOV_DEPARTMENT", "remark": "", "status": "ENABLED", "version": 1, "typeCode": "organization_type", "createdAt": "2026-09-16T00:00:00.000Z", "sortOrder": 2, "updatedAt": "2026-09-17T23:00:00.000Z", "systemLocked": false}	2026-09-23 07:05:39.571621+00
dictItems	MOCK_DICT_ORG_2	11	{"id": "MOCK_DICT_ORG_2", "label": "其他组织", "value": "OTHER", "remark": "", "status": "ENABLED", "version": 1, "typeCode": "organization_type", "createdAt": "2026-09-16T00:00:00.000Z", "sortOrder": 3, "updatedAt": "2026-09-17T23:00:00.000Z", "systemLocked": false}	2026-09-23 07:05:39.571621+00
dictItems	MOCK_DICT_ENABLE_0	12	{"id": "MOCK_DICT_ENABLE_0", "label": "启用", "value": "ENABLED", "remark": "系统受控", "status": "ENABLED", "version": 1, "typeCode": "enable_status", "createdAt": "2026-09-16T00:00:00.000Z", "sortOrder": 1, "updatedAt": "2026-09-17T23:00:00.000Z", "systemLocked": true}	2026-09-23 07:05:39.571621+00
dictItems	MOCK_DICT_ENABLE_1	13	{"id": "MOCK_DICT_ENABLE_1", "label": "停用", "value": "DISABLED", "remark": "系统受控", "status": "ENABLED", "version": 1, "typeCode": "enable_status", "createdAt": "2026-09-16T00:00:00.000Z", "sortOrder": 2, "updatedAt": "2026-09-17T23:00:00.000Z", "systemLocked": true}	2026-09-23 07:05:39.571621+00
dictItems	MOCK_DICT_RUNTIME_0	14	{"id": "MOCK_DICT_RUNTIME_0", "label": "正常", "value": "NORMAL", "remark": "系统受控", "status": "ENABLED", "version": 1, "typeCode": "runtime_status", "createdAt": "2026-09-16T00:00:00.000Z", "sortOrder": 1, "updatedAt": "2026-09-17T23:00:00.000Z", "systemLocked": true}	2026-09-23 07:05:39.571621+00
dictItems	MOCK_DICT_RUNTIME_1	15	{"id": "MOCK_DICT_RUNTIME_1", "label": "异常", "value": "ABNORMAL", "remark": "系统受控", "status": "ENABLED", "version": 1, "typeCode": "runtime_status", "createdAt": "2026-09-16T00:00:00.000Z", "sortOrder": 2, "updatedAt": "2026-09-17T23:00:00.000Z", "systemLocked": true}	2026-09-23 07:05:39.571621+00
dictItems	MOCK_DICT_RUNTIME_2	16	{"id": "MOCK_DICT_RUNTIME_2", "label": "未配置", "value": "UNCONFIGURED", "remark": "系统受控", "status": "ENABLED", "version": 1, "typeCode": "runtime_status", "createdAt": "2026-09-16T00:00:00.000Z", "sortOrder": 3, "updatedAt": "2026-09-17T23:00:00.000Z", "systemLocked": true}	2026-09-23 07:05:39.571621+00
dictItems	MOCK_DICT_RUNTIME_3	17	{"id": "MOCK_DICT_RUNTIME_3", "label": "停用", "value": "DISABLED", "remark": "系统受控", "status": "ENABLED", "version": 1, "typeCode": "runtime_status", "createdAt": "2026-09-16T00:00:00.000Z", "sortOrder": 4, "updatedAt": "2026-09-17T23:00:00.000Z", "systemLocked": true}	2026-09-23 07:05:39.571621+00
dictItems	MOCK_DICT_PROTOCOL_0	18	{"id": "MOCK_DICT_PROTOCOL_0", "label": "OIDC", "value": "OIDC", "remark": "仅展示代码已支持协议", "status": "ENABLED", "version": 1, "typeCode": "integration_protocol", "createdAt": "2026-09-16T00:00:00.000Z", "sortOrder": 1, "updatedAt": "2026-09-17T23:00:00.000Z", "systemLocked": true}	2026-09-23 07:05:39.571621+00
dictItems	MOCK_DICT_PROTOCOL_1	19	{"id": "MOCK_DICT_PROTOCOL_1", "label": "SAML2", "value": "SAML2", "remark": "仅展示代码已支持协议", "status": "ENABLED", "version": 1, "typeCode": "integration_protocol", "createdAt": "2026-09-16T00:00:00.000Z", "sortOrder": 2, "updatedAt": "2026-09-17T23:00:00.000Z", "systemLocked": true}	2026-09-23 07:05:39.571621+00
dictItems	MOCK_DICT_PROTOCOL_2	20	{"id": "MOCK_DICT_PROTOCOL_2", "label": "CUSTOM", "value": "CUSTOM", "remark": "仅展示代码已支持协议", "status": "ENABLED", "version": 1, "typeCode": "integration_protocol", "createdAt": "2026-09-16T00:00:00.000Z", "sortOrder": 3, "updatedAt": "2026-09-17T23:00:00.000Z", "systemLocked": true}	2026-09-23 07:05:39.571621+00
dictItems	MOCK_DICT_PROTOCOL_3	21	{"id": "MOCK_DICT_PROTOCOL_3", "label": "PUSH", "value": "PUSH", "remark": "仅展示代码已支持协议", "status": "ENABLED", "version": 1, "typeCode": "integration_protocol", "createdAt": "2026-09-16T00:00:00.000Z", "sortOrder": 4, "updatedAt": "2026-09-17T23:00:00.000Z", "systemLocked": true}	2026-09-23 07:05:39.571621+00
users	MOCK_LOCAL_ADMIN	4	{"id": "MOCK_LOCAL_ADMIN", "kind": "ADMIN", "name": "门户管理员", "email": "未提供", "mobile": "未提供", "orgKey": "PORTAL", "status": "NORMAL", "account": "admin", "enabled": true, "orgName": "门户运行保障中心", "roleIds": ["ROLE_SUPER"], "authType": "LOCAL", "jobTitle": "系统管理", "roleName": "门户超级管理员", "department": "运行保障科", "adminAccess": true, "adminStatus": "NORMAL", "lastLoginAt": "2026-09-17T19:00:00.000Z", "lockedUntil": null, "permissions": ["application:view", "application:edit", "application:enable", "application:review", "integration:view", "integration:edit", "integration:test", "identity:view", "identity:review", "identity:unbind", "announcement:view", "announcement:edit", "announcement:publish", "admin-user:view", "admin-user:enable", "admin-user:create", "admin-user:assign-role", "admin-user:reset-password", "organization:view", "organization:edit", "dictionary:view", "dictionary:edit", "monitor:view", "monitor:check", "audit:view", "audit:resolve", "role:view", "role:edit", "settings:view", "settings:edit", "system:super"], "adminEnabled": true, "adminSubject": true, "firstLoginAt": "2026-09-09T08:00:00.000Z", "identitySource": "门户本地", "mustChangePassword": false}	2026-09-23 11:58:11.012927+00
\.


--
-- Data for Name: portal_runtime_entity_domain; Type: TABLE DATA; Schema: pb3gir75kkooyea; Owner: admin
--

COPY pb3gir75kkooyea.portal_runtime_entity_domain (resource, initialized_at) FROM stdin;
users	2026-09-23 06:59:56.546313+00
roles	2026-09-23 06:59:56.546313+00
mappings	2026-09-23 06:59:56.546313+00
settings	2026-09-23 06:59:56.546313+00
integrations	2026-09-23 06:59:56.546313+00
monitorSamples	2026-09-23 06:59:56.546313+00
visits	2026-09-23 06:59:56.546313+00
receipts	2026-09-23 06:59:56.546313+00
organizations	2026-09-23 07:05:39.571621+00
dictTypes	2026-09-23 07:05:39.571621+00
dictItems	2026-09-23 07:05:39.571621+00
mappingVerificationEvents	2026-09-23 07:05:39.571621+00
\.


--
-- Data for Name: portal_session; Type: TABLE DATA; Schema: pb3gir75kkooyea; Owner: admin
--

COPY pb3gir75kkooyea.portal_session (nc_id, created_at1, updated_at1, created_by, updated_by, nc_order, id, created_at, updated_at, version, user_id, identity_mapping_id, token_hash, expires_at, revoked_at) FROM stdin;
\.


--
-- Data for Name: portal_user_application_scope; Type: TABLE DATA; Schema: pb3gir75kkooyea; Owner: admin
--

COPY pb3gir75kkooyea.portal_user_application_scope (nc_id, created_at1, updated_at1, created_by, updated_by, nc_order, id, created_at, updated_at, version, user_id, application_id) FROM stdin;
1	\N	\N	\N	\N	\N	P4FIX_SCOPE_MOCK_MAP_MOCK_USER_1_1	2026-09-18 00:00:00+00	2026-09-18 00:00:00+00	1	P4FIX_USER_1	P4FIX_APP_1
2	\N	\N	\N	\N	\N	P4FIX_SCOPE_MOCK_MAP_MOCK_USER_1_2	2026-09-18 00:00:00+00	2026-09-18 00:00:00+00	1	P4FIX_USER_1	P4FIX_APP_2
3	\N	\N	\N	\N	\N	P4FIX_SCOPE_MOCK_MAP_MOCK_USER_1_3	2026-09-18 00:00:00+00	2026-09-18 00:00:00+00	1	P4FIX_USER_1	P4FIX_APP_3
4	\N	\N	\N	\N	\N	P4FIX_SCOPE_MOCK_MAP_MOCK_USER_1_4	2026-09-18 00:00:00+00	2026-09-18 00:00:00+00	1	P4FIX_USER_1	P4FIX_APP_4
5	\N	\N	\N	\N	\N	P4FIX_SCOPE_MOCK_MAP_MOCK_USER_1_5	2026-09-18 00:00:00+00	2026-09-18 00:00:00+00	1	P4FIX_USER_1	P4FIX_APP_5
6	\N	\N	\N	\N	\N	P4FIX_SCOPE_MOCK_MAP_MOCK_USER_1_6	2026-09-18 00:00:00+00	2026-09-18 00:00:00+00	1	P4FIX_USER_1	P4FIX_APP_6
7	\N	\N	\N	\N	\N	P4FIX_SCOPE_MOCK_MAP_MOCK_USER_1_11	2026-09-18 00:00:00+00	2026-09-18 00:00:00+00	1	P4FIX_USER_1	P4FIX_APP_11
8	\N	\N	\N	\N	\N	P4FIX_SCOPE_MOCK_MAP_MOCK_USER_1_12	2026-09-18 00:00:00+00	2026-09-18 00:00:00+00	1	P4FIX_USER_1	P4FIX_APP_12
9	\N	\N	\N	\N	\N	P4FIX_SCOPE_MOCK_MAP_MOCK_USER_2_1	2026-09-18 00:00:00+00	2026-09-18 00:00:00+00	1	P4FIX_USER_2	P4FIX_APP_1
10	\N	\N	\N	\N	\N	P4FIX_SCOPE_MOCK_MAP_MOCK_USER_2_2	2026-09-18 00:00:00+00	2026-09-18 00:00:00+00	1	P4FIX_USER_2	P4FIX_APP_2
11	\N	\N	\N	\N	\N	P4FIX_SCOPE_MOCK_MAP_MOCK_USER_2_3	2026-09-18 00:00:00+00	2026-09-18 00:00:00+00	1	P4FIX_USER_2	P4FIX_APP_3
12	\N	\N	\N	\N	\N	P4FIX_SCOPE_MOCK_MAP_MOCK_USER_2_4	2026-09-18 00:00:00+00	2026-09-18 00:00:00+00	1	P4FIX_USER_2	P4FIX_APP_4
13	\N	\N	\N	\N	\N	P4FIX_SCOPE_MOCK_MAP_MOCK_USER_2_5	2026-09-18 00:00:00+00	2026-09-18 00:00:00+00	1	P4FIX_USER_2	P4FIX_APP_5
14	\N	\N	\N	\N	\N	P4FIX_SCOPE_MOCK_MAP_MOCK_USER_2_6	2026-09-18 00:00:00+00	2026-09-18 00:00:00+00	1	P4FIX_USER_2	P4FIX_APP_6
15	\N	\N	\N	\N	\N	P4FIX_SCOPE_MOCK_MAP_MOCK_USER_2_7	2026-09-18 00:00:00+00	2026-09-18 00:00:00+00	1	P4FIX_USER_2	P4FIX_APP_7
16	\N	\N	\N	\N	\N	P4FIX_SCOPE_MOCK_MAP_MOCK_USER_2_8	2026-09-18 00:00:00+00	2026-09-18 00:00:00+00	1	P4FIX_USER_2	P4FIX_APP_8
17	\N	\N	\N	\N	\N	P4FIX_SCOPE_MOCK_MAP_MOCK_ADMIN_1	2026-09-18 00:00:00+00	2026-09-18 00:00:00+00	1	P4FIX_ADMIN	P4FIX_APP_1
18	\N	\N	\N	\N	\N	P4FIX_SCOPE_MOCK_MAP_MOCK_ADMIN_2	2026-09-18 00:00:00+00	2026-09-18 00:00:00+00	1	P4FIX_ADMIN	P4FIX_APP_2
19	\N	\N	\N	\N	\N	P4FIX_SCOPE_MOCK_MAP_MOCK_ADMIN_3	2026-09-18 00:00:00+00	2026-09-18 00:00:00+00	1	P4FIX_ADMIN	P4FIX_APP_3
20	\N	\N	\N	\N	\N	P4FIX_SCOPE_MOCK_MAP_MOCK_ADMIN_4	2026-09-18 00:00:00+00	2026-09-18 00:00:00+00	1	P4FIX_ADMIN	P4FIX_APP_4
21	\N	\N	\N	\N	\N	P4FIX_SCOPE_MOCK_MAP_MOCK_ADMIN_5	2026-09-18 00:00:00+00	2026-09-18 00:00:00+00	1	P4FIX_ADMIN	P4FIX_APP_5
22	\N	\N	\N	\N	\N	P4FIX_SCOPE_MOCK_MAP_MOCK_ADMIN_6	2026-09-18 00:00:00+00	2026-09-18 00:00:00+00	1	P4FIX_ADMIN	P4FIX_APP_6
23	\N	\N	\N	\N	\N	P4FIX_SCOPE_MOCK_MAP_MOCK_ADMIN_7	2026-09-18 00:00:00+00	2026-09-18 00:00:00+00	1	P4FIX_ADMIN	P4FIX_APP_7
24	\N	\N	\N	\N	\N	P4FIX_SCOPE_MOCK_MAP_MOCK_ADMIN_8	2026-09-18 00:00:00+00	2026-09-18 00:00:00+00	1	P4FIX_ADMIN	P4FIX_APP_8
25	\N	\N	\N	\N	\N	P4FIX_SCOPE_MOCK_MAP_MOCK_EDITOR_1	2026-09-18 00:00:00+00	2026-09-18 00:00:00+00	1	P4FIX_EDITOR	P4FIX_APP_1
26	\N	\N	\N	\N	\N	P4FIX_SCOPE_MOCK_MAP_MOCK_EDITOR_2	2026-09-18 00:00:00+00	2026-09-18 00:00:00+00	1	P4FIX_EDITOR	P4FIX_APP_2
27	\N	\N	\N	\N	\N	P4FIX_SCOPE_MOCK_MAP_MOCK_EDITOR_3	2026-09-18 00:00:00+00	2026-09-18 00:00:00+00	1	P4FIX_EDITOR	P4FIX_APP_3
28	\N	\N	\N	\N	\N	P4FIX_SCOPE_MOCK_MAP_MOCK_EDITOR_4	2026-09-18 00:00:00+00	2026-09-18 00:00:00+00	1	P4FIX_EDITOR	P4FIX_APP_4
29	\N	\N	\N	\N	\N	P4FIX_SCOPE_MOCK_MAP_MOCK_EDITOR_5	2026-09-18 00:00:00+00	2026-09-18 00:00:00+00	1	P4FIX_EDITOR	P4FIX_APP_5
30	\N	\N	\N	\N	\N	P4FIX_SCOPE_MOCK_MAP_MOCK_EDITOR_6	2026-09-18 00:00:00+00	2026-09-18 00:00:00+00	1	P4FIX_EDITOR	P4FIX_APP_6
31	\N	\N	\N	\N	\N	P4FIX_SCOPE_MOCK_MAP_MOCK_EDITOR_7	2026-09-18 00:00:00+00	2026-09-18 00:00:00+00	1	P4FIX_EDITOR	P4FIX_APP_7
32	\N	\N	\N	\N	\N	P4FIX_SCOPE_MOCK_MAP_MOCK_EDITOR_8	2026-09-18 00:00:00+00	2026-09-18 00:00:00+00	1	P4FIX_EDITOR	P4FIX_APP_8
\.


--
-- Data for Name: portal_user_role; Type: TABLE DATA; Schema: pb3gir75kkooyea; Owner: admin
--

COPY pb3gir75kkooyea.portal_user_role (nc_id, created_at1, updated_at1, created_by, updated_by, nc_order, id, created_at, updated_at, version, user_id, role_id, granted_by, expires_at) FROM stdin;
1	\N	\N	\N	\N	\N	P4FIX_UR_MOCK_USER_1	2026-09-18 00:00:00+00	2026-09-18 00:00:00+00	1	P4FIX_USER_1	P4FIX_ROLE_USER	P4FIX_ADMIN	\N
2	\N	\N	\N	\N	\N	P4FIX_UR_MOCK_USER_2	2026-09-18 00:00:00+00	2026-09-18 00:00:00+00	1	P4FIX_USER_2	P4FIX_ROLE_USER	P4FIX_ADMIN	\N
3	\N	\N	\N	\N	\N	P4FIX_UR_MOCK_ADMIN	2026-09-18 00:00:00+00	2026-09-18 00:00:00+00	1	P4FIX_ADMIN	P4FIX_ROLE_ADMIN	P4FIX_ADMIN	\N
4	\N	\N	\N	\N	\N	P4FIX_UR_MOCK_EDITOR	2026-09-18 00:00:00+00	2026-09-18 00:00:00+00	1	P4FIX_EDITOR	P4FIX_ROLE_EDITOR	P4FIX_ADMIN	\N
5	\N	\N	\N	\N	\N	P4FIX_UR_MOCK_LOCAL_ADMIN	2026-09-16 00:00:00+00	2026-09-17 23:00:00+00	1	P4FIX_LOCAL_ADMIN	P4FIX_ROLE_ADMIN	P4FIX_ADMIN	\N
\.


--
-- Data for Name: push_integration_config; Type: TABLE DATA; Schema: pb3gir75kkooyea; Owner: admin
--

COPY pb3gir75kkooyea.push_integration_config (nc_id, created_at1, updated_at1, created_by, updated_by, nc_order, id, created_at, updated_at, version, application_id, kind, mode, credential_ref, field_mapping, value_mapping, target_key_kind, status, last_received_at, enabled, remark) FROM stdin;
1	\N	\N	\N	\N	\N	P4FIX_PUSH_MOCK_APP_1_TODO	2026-09-18 00:00:00+00	2026-09-18 14:50:14.759+00	2	P4FIX_APP_1	TODO	PUSH	\N	{}	{}	UNIFIED_USER_ID	DISABLED	\N	DISABLED	接入参数待业务系统确认
2	\N	\N	\N	\N	\N	P4FIX_PUSH_MOCK_APP_1_MESSAGE	2026-09-18 00:00:00+00	2026-09-17 23:00:00+00	1	P4FIX_APP_1	MESSAGE	PUSH	\N	{}	{}	UNIFIED_USER_ID	UNCONFIGURED	\N	DISABLED	接入参数待业务系统确认
3	\N	\N	\N	\N	\N	P4FIX_PUSH_MOCK_APP_2_TODO	2026-09-18 00:00:00+00	2026-09-17 23:00:00+00	1	P4FIX_APP_2	TODO	PUSH	\N	{}	{}	UNIFIED_USER_ID	UNCONFIGURED	\N	DISABLED	接入参数待业务系统确认
4	\N	\N	\N	\N	\N	P4FIX_PUSH_MOCK_APP_2_MESSAGE	2026-09-18 00:00:00+00	2026-09-17 23:00:00+00	1	P4FIX_APP_2	MESSAGE	PUSH	\N	{}	{}	UNIFIED_USER_ID	DISABLED	\N	DISABLED	接入参数待业务系统确认
5	\N	\N	\N	\N	\N	P4FIX_PUSH_MOCK_APP_3_TODO	2026-09-18 00:00:00+00	2026-09-17 23:00:00+00	1	P4FIX_APP_3	TODO	PUSH	\N	{}	{}	UNIFIED_USER_ID	DISABLED	\N	DISABLED	接入参数待业务系统确认
6	\N	\N	\N	\N	\N	P4FIX_PUSH_MOCK_APP_3_MESSAGE	2026-09-18 00:00:00+00	2026-09-17 23:00:00+00	1	P4FIX_APP_3	MESSAGE	PUSH	\N	{}	{}	UNIFIED_USER_ID	UNCONFIGURED	\N	DISABLED	接入参数待业务系统确认
7	\N	\N	\N	\N	\N	P4FIX_PUSH_MOCK_APP_4_TODO	2026-09-18 00:00:00+00	2026-09-17 23:00:00+00	1	P4FIX_APP_4	TODO	PUSH	\N	{}	{}	UNIFIED_USER_ID	UNCONFIGURED	\N	DISABLED	接入参数待业务系统确认
8	\N	\N	\N	\N	\N	P4FIX_PUSH_MOCK_APP_4_MESSAGE	2026-09-18 00:00:00+00	2026-09-17 23:00:00+00	1	P4FIX_APP_4	MESSAGE	PUSH	\N	{}	{}	UNIFIED_USER_ID	UNCONFIGURED	\N	DISABLED	接入参数待业务系统确认
9	\N	\N	\N	\N	\N	P4FIX_PUSH_MOCK_APP_5_TODO	2026-09-18 00:00:00+00	2026-09-17 23:00:00+00	1	P4FIX_APP_5	TODO	PUSH	\N	{}	{}	UNIFIED_USER_ID	UNCONFIGURED	\N	DISABLED	接入参数待业务系统确认
10	\N	\N	\N	\N	\N	P4FIX_PUSH_MOCK_APP_5_MESSAGE	2026-09-18 00:00:00+00	2026-09-17 23:00:00+00	1	P4FIX_APP_5	MESSAGE	PUSH	\N	{}	{}	UNIFIED_USER_ID	UNCONFIGURED	\N	DISABLED	接入参数待业务系统确认
11	\N	\N	\N	\N	\N	P4FIX_PUSH_MOCK_APP_6_TODO	2026-09-18 00:00:00+00	2026-09-17 23:00:00+00	1	P4FIX_APP_6	TODO	PUSH	\N	{}	{}	UNIFIED_USER_ID	UNCONFIGURED	\N	DISABLED	接入参数待业务系统确认
12	\N	\N	\N	\N	\N	P4FIX_PUSH_MOCK_APP_6_MESSAGE	2026-09-18 00:00:00+00	2026-09-17 23:00:00+00	1	P4FIX_APP_6	MESSAGE	PUSH	\N	{}	{}	UNIFIED_USER_ID	DISABLED	\N	DISABLED	接入参数待业务系统确认
13	\N	\N	\N	\N	\N	P4FIX_PUSH_MOCK_APP_7_TODO	2026-09-18 00:00:00+00	2026-09-17 23:00:00+00	1	P4FIX_APP_7	TODO	PUSH	\N	{}	{}	UNIFIED_USER_ID	DISABLED	\N	DISABLED	接入参数待业务系统确认
14	\N	\N	\N	\N	\N	P4FIX_PUSH_MOCK_APP_7_MESSAGE	2026-09-18 00:00:00+00	2026-09-17 23:00:00+00	1	P4FIX_APP_7	MESSAGE	PUSH	\N	{}	{}	UNIFIED_USER_ID	UNCONFIGURED	\N	DISABLED	接入参数待业务系统确认
15	\N	\N	\N	\N	\N	P4FIX_PUSH_MOCK_APP_8_TODO	2026-09-18 00:00:00+00	2026-09-17 23:00:00+00	1	P4FIX_APP_8	TODO	PUSH	\N	{}	{}	UNIFIED_USER_ID	UNCONFIGURED	\N	DISABLED	接入参数待业务系统确认
16	\N	\N	\N	\N	\N	P4FIX_PUSH_MOCK_APP_8_MESSAGE	2026-09-18 00:00:00+00	2026-09-17 23:00:00+00	1	P4FIX_APP_8	MESSAGE	PUSH	\N	{}	{}	UNIFIED_USER_ID	UNCONFIGURED	\N	DISABLED	接入参数待业务系统确认
17	\N	\N	\N	\N	\N	P4FIX_PUSH_MOCK_APP_9_TODO	2026-09-18 00:00:00+00	2026-09-17 23:00:00+00	1	P4FIX_APP_9	TODO	PUSH	\N	{}	{}	UNIFIED_USER_ID	UNCONFIGURED	\N	DISABLED	接入参数待业务系统确认
18	\N	\N	\N	\N	\N	P4FIX_PUSH_MOCK_APP_9_MESSAGE	2026-09-18 00:00:00+00	2026-09-17 23:00:00+00	1	P4FIX_APP_9	MESSAGE	PUSH	\N	{}	{}	UNIFIED_USER_ID	UNCONFIGURED	\N	DISABLED	接入参数待业务系统确认
19	\N	\N	\N	\N	\N	P4FIX_PUSH_MOCK_APP_10_TODO	2026-09-18 00:00:00+00	2026-09-17 23:00:00+00	1	P4FIX_APP_10	TODO	PUSH	\N	{}	{}	UNIFIED_USER_ID	UNCONFIGURED	\N	DISABLED	接入参数待业务系统确认
20	\N	\N	\N	\N	\N	P4FIX_PUSH_MOCK_APP_10_MESSAGE	2026-09-18 00:00:00+00	2026-09-17 23:00:00+00	1	P4FIX_APP_10	MESSAGE	PUSH	\N	{}	{}	UNIFIED_USER_ID	DISABLED	\N	DISABLED	接入参数待业务系统确认
21	\N	\N	\N	\N	\N	P4FIX_PUSH_MOCK_APP_11_TODO	2026-09-18 00:00:00+00	2026-09-17 23:00:00+00	1	P4FIX_APP_11	TODO	PUSH	\N	{}	{}	UNIFIED_USER_ID	DISABLED	\N	DISABLED	接入参数待业务系统确认
22	\N	\N	\N	\N	\N	P4FIX_PUSH_MOCK_APP_11_MESSAGE	2026-09-18 00:00:00+00	2026-09-17 23:00:00+00	1	P4FIX_APP_11	MESSAGE	PUSH	\N	{}	{}	UNIFIED_USER_ID	UNCONFIGURED	\N	DISABLED	接入参数待业务系统确认
23	\N	\N	\N	\N	\N	P4FIX_PUSH_MOCK_APP_12_TODO	2026-09-18 00:00:00+00	2026-09-17 23:00:00+00	1	P4FIX_APP_12	TODO	PUSH	\N	{}	{}	UNIFIED_USER_ID	UNCONFIGURED	\N	DISABLED	接入参数待业务系统确认
24	\N	\N	\N	\N	\N	P4FIX_PUSH_MOCK_APP_12_MESSAGE	2026-09-18 00:00:00+00	2026-09-17 23:00:00+00	1	P4FIX_APP_12	MESSAGE	PUSH	\N	{}	{}	UNIFIED_USER_ID	UNCONFIGURED	\N	DISABLED	接入参数待业��系统确认
25	\N	\N	\N	\N	\N	P4FIX_PUSH_MOCK_APP_13_TODO	2026-09-18 00:00:00+00	2026-09-17 23:00:00+00	1	P4FIX_APP_13	TODO	PUSH	\N	{}	{}	UNIFIED_USER_ID	UNCONFIGURED	\N	DISABLED	接入参数待业务系统确认
26	\N	\N	\N	\N	\N	P4FIX_PUSH_MOCK_APP_13_MESSAGE	2026-09-18 00:00:00+00	2026-09-17 23:00:00+00	1	P4FIX_APP_13	MESSAGE	PUSH	\N	{}	{}	UNIFIED_USER_ID	UNCONFIGURED	\N	DISABLED	接入参数待业务系统确认
27	\N	\N	\N	\N	\N	P4FIX_PUSH_MOCK_APP_14_TODO	2026-09-18 00:00:00+00	2026-09-17 23:00:00+00	1	P4FIX_APP_14	TODO	PUSH	\N	{}	{}	UNIFIED_USER_ID	UNCONFIGURED	\N	DISABLED	接入参数待业务系统确认
28	\N	\N	\N	\N	\N	P4FIX_PUSH_MOCK_APP_14_MESSAGE	2026-09-18 00:00:00+00	2026-09-17 23:00:00+00	1	P4FIX_APP_14	MESSAGE	PUSH	\N	{}	{}	UNIFIED_USER_ID	DISABLED	\N	DISABLED	接入参数待业务系统确认
29	\N	\N	\N	\N	\N	P4FIX_PUSH_MOCK_APP_15_TODO	2026-09-18 00:00:00+00	2026-09-17 23:00:00+00	1	P4FIX_APP_15	TODO	PUSH	\N	{}	{}	UNIFIED_USER_ID	DISABLED	\N	DISABLED	接入参数待业务系统确认
30	\N	\N	\N	\N	\N	P4FIX_PUSH_MOCK_APP_15_MESSAGE	2026-09-18 00:00:00+00	2026-09-17 23:00:00+00	1	P4FIX_APP_15	MESSAGE	PUSH	\N	{}	{}	UNIFIED_USER_ID	UNCONFIGURED	\N	DISABLED	接入参数待业务系统确认
31	\N	\N	\N	\N	\N	P4FIX_PUSH_MOCK_APP_16_TODO	2026-09-18 00:00:00+00	2026-09-17 23:00:00+00	1	P4FIX_APP_16	TODO	PUSH	\N	{}	{}	UNIFIED_USER_ID	UNCONFIGURED	\N	DISABLED	接入参数待业务系统确认
32	\N	\N	\N	\N	\N	P4FIX_PUSH_MOCK_APP_16_MESSAGE	2026-09-18 00:00:00+00	2026-09-17 23:00:00+00	1	P4FIX_APP_16	MESSAGE	PUSH	\N	{}	{}	UNIFIED_USER_ID	UNCONFIGURED	\N	DISABLED	接入参数待业务系统确认
33	\N	\N	\N	\N	\N	P4FIX_PUSH_MOCK_APP_17_TODO	2026-09-18 00:00:00+00	2026-09-17 23:00:00+00	1	P4FIX_APP_17	TODO	PUSH	\N	{}	{}	UNIFIED_USER_ID	UNCONFIGURED	\N	DISABLED	接入参数待业务系统确认
34	\N	\N	\N	\N	\N	P4FIX_PUSH_MOCK_APP_17_MESSAGE	2026-09-18 00:00:00+00	2026-09-17 23:00:00+00	1	P4FIX_APP_17	MESSAGE	PUSH	\N	{}	{}	UNIFIED_USER_ID	UNCONFIGURED	\N	DISABLED	接入参数待业务系统确认
35	\N	\N	\N	\N	\N	P4FIX_PUSH_MOCK_APP_18_TODO	2026-09-18 00:00:00+00	2026-09-17 23:00:00+00	1	P4FIX_APP_18	TODO	PUSH	\N	{}	{}	UNIFIED_USER_ID	UNCONFIGURED	\N	DISABLED	接入参数待业务系统确认
36	\N	\N	\N	\N	\N	P4FIX_PUSH_MOCK_APP_18_MESSAGE	2026-09-18 00:00:00+00	2026-09-17 23:00:00+00	1	P4FIX_APP_18	MESSAGE	PUSH	\N	{}	{}	UNIFIED_USER_ID	DISABLED	\N	DISABLED	接入参数待业务系统确认
37	\N	\N	\N	\N	\N	P4FIX_PUSH_MOCK_APP_19_TODO	2026-09-18 00:00:00+00	2026-09-17 23:00:00+00	1	P4FIX_APP_19	TODO	PUSH	\N	{}	{}	UNIFIED_USER_ID	DISABLED	\N	DISABLED	接入参数待业务系统确认
38	\N	\N	\N	\N	\N	P4FIX_PUSH_MOCK_APP_19_MESSAGE	2026-09-18 00:00:00+00	2026-09-17 23:00:00+00	1	P4FIX_APP_19	MESSAGE	PUSH	\N	{}	{}	UNIFIED_USER_ID	UNCONFIGURED	\N	DISABLED	接入参数待业务系统确认
39	\N	\N	\N	\N	\N	P4FIX_PUSH_MOCK_APP_20_TODO	2026-09-18 00:00:00+00	2026-09-17 23:00:00+00	1	P4FIX_APP_20	TODO	PUSH	\N	{}	{}	UNIFIED_USER_ID	UNCONFIGURED	\N	DISABLED	接入参数待业务系统确认
40	\N	\N	\N	\N	\N	P4FIX_PUSH_MOCK_APP_20_MESSAGE	2026-09-18 00:00:00+00	2026-09-17 23:00:00+00	1	P4FIX_APP_20	MESSAGE	PUSH	\N	{}	{}	UNIFIED_USER_ID	UNCONFIGURED	\N	DISABLED	接入参数待业务系统确认
41	\N	\N	\N	\N	\N	P4FIX_PUSH_MOCK_APP_21_TODO	2026-09-18 00:00:00+00	2026-09-17 23:00:00+00	1	P4FIX_APP_21	TODO	PUSH	\N	{}	{}	UNIFIED_USER_ID	UNCONFIGURED	\N	DISABLED	接入参数待业务系统确认
42	\N	\N	\N	\N	\N	P4FIX_PUSH_MOCK_APP_21_MESSAGE	2026-09-18 00:00:00+00	2026-09-17 23:00:00+00	1	P4FIX_APP_21	MESSAGE	PUSH	\N	{}	{}	UNIFIED_USER_ID	UNCONFIGURED	\N	DISABLED	接入参数待业务系统确认
43	\N	\N	\N	\N	\N	P4FIX_PUSH_MOCK_APP_22_TODO	2026-09-18 00:00:00+00	2026-09-17 23:00:00+00	1	P4FIX_APP_22	TODO	PUSH	\N	{}	{}	UNIFIED_USER_ID	UNCONFIGURED	\N	DISABLED	接入参数待业务系统确认
44	\N	\N	\N	\N	\N	P4FIX_PUSH_MOCK_APP_22_MESSAGE	2026-09-18 00:00:00+00	2026-09-17 23:00:00+00	1	P4FIX_APP_22	MESSAGE	PUSH	\N	{}	{}	UNIFIED_USER_ID	DISABLED	\N	DISABLED	接入参数待业务系统确认
45	\N	\N	\N	\N	\N	P4FIX_PUSH_MOCK_APP_23_TODO	2026-09-18 00:00:00+00	2026-09-17 23:00:00+00	1	P4FIX_APP_23	TODO	PUSH	\N	{}	{}	UNIFIED_USER_ID	DISABLED	\N	DISABLED	接入参数待业务系统确认
46	\N	\N	\N	\N	\N	P4FIX_PUSH_MOCK_APP_23_MESSAGE	2026-09-18 00:00:00+00	2026-09-17 23:00:00+00	1	P4FIX_APP_23	MESSAGE	PUSH	\N	{}	{}	UNIFIED_USER_ID	UNCONFIGURED	\N	DISABLED	接入参数待业务系统确认
47	\N	\N	\N	\N	\N	P4FIX_PUSH_MOCK_APP_24_TODO	2026-09-18 00:00:00+00	2026-09-17 23:00:00+00	1	P4FIX_APP_24	TODO	PUSH	\N	{}	{}	UNIFIED_USER_ID	UNCONFIGURED	\N	DISABLED	接入参数待业务系统确认
48	\N	\N	\N	\N	\N	P4FIX_PUSH_MOCK_APP_24_MESSAGE	2026-09-18 00:00:00+00	2026-09-17 23:00:00+00	1	P4FIX_APP_24	MESSAGE	PUSH	\N	{}	{}	UNIFIED_USER_ID	UNCONFIGURED	\N	DISABLED	接入参数待业务系统确认
49	\N	\N	\N	\N	\N	P4FIX_PUSH_MOCK_APP_25_TODO	2026-09-18 00:00:00+00	2026-09-17 23:00:00+00	1	P4FIX_APP_25	TODO	PUSH	\N	{}	{}	UNIFIED_USER_ID	UNCONFIGURED	\N	DISABLED	接入参数待业务系统确认
50	\N	\N	\N	\N	\N	P4FIX_PUSH_MOCK_APP_25_MESSAGE	2026-09-18 00:00:00+00	2026-09-17 23:00:00+00	1	P4FIX_APP_25	MESSAGE	PUSH	\N	{}	{}	UNIFIED_USER_ID	UNCONFIGURED	\N	DISABLED	接入参数待业务系统确认
51	\N	\N	\N	\N	\N	P4FIX_PUSH_MOCK_APP_26_TODO	2026-09-18 00:00:00+00	2026-09-17 23:00:00+00	1	P4FIX_APP_26	TODO	PUSH	\N	{}	{}	UNIFIED_USER_ID	UNCONFIGURED	\N	DISABLED	接入参数待业务系统确认
52	\N	\N	\N	\N	\N	P4FIX_PUSH_MOCK_APP_26_MESSAGE	2026-09-18 00:00:00+00	2026-09-17 23:00:00+00	1	P4FIX_APP_26	MESSAGE	PUSH	\N	{}	{}	UNIFIED_USER_ID	DISABLED	\N	DISABLED	接入参数待业务系统确认
53	\N	\N	\N	\N	\N	P4FIX_PUSH_MOCK_APP_27_TODO	2026-09-18 00:00:00+00	2026-09-17 23:00:00+00	1	P4FIX_APP_27	TODO	PUSH	\N	{}	{}	UNIFIED_USER_ID	DISABLED	\N	DISABLED	接入参数待业务系统确认
54	\N	\N	\N	\N	\N	P4FIX_PUSH_MOCK_APP_27_MESSAGE	2026-09-18 00:00:00+00	2026-09-17 23:00:00+00	1	P4FIX_APP_27	MESSAGE	PUSH	\N	{}	{}	UNIFIED_USER_ID	UNCONFIGURED	\N	DISABLED	接入参数待业务系统确认
55	\N	\N	\N	\N	\N	P4FIX_PUSH_MOCK_APP_28_TODO	2026-09-18 00:00:00+00	2026-09-17 23:00:00+00	1	P4FIX_APP_28	TODO	PUSH	\N	{}	{}	UNIFIED_USER_ID	UNCONFIGURED	\N	DISABLED	接入参数待业务系统确认
56	\N	\N	\N	\N	\N	P4FIX_PUSH_MOCK_APP_28_MESSAGE	2026-09-18 00:00:00+00	2026-09-17 23:00:00+00	1	P4FIX_APP_28	MESSAGE	PUSH	\N	{}	{}	UNIFIED_USER_ID	UNCONFIGURED	\N	DISABLED	接入参数待业务系统确认
57	\N	\N	\N	\N	\N	P4FIX_PUSH_MOCK_APP_29_TODO	2026-09-18 00:00:00+00	2026-09-17 23:00:00+00	1	P4FIX_APP_29	TODO	PUSH	\N	{}	{}	UNIFIED_USER_ID	UNCONFIGURED	\N	DISABLED	接入参数待业务系统确认
58	\N	\N	\N	\N	\N	P4FIX_PUSH_MOCK_APP_29_MESSAGE	2026-09-18 00:00:00+00	2026-09-17 23:00:00+00	1	P4FIX_APP_29	MESSAGE	PUSH	\N	{}	{}	UNIFIED_USER_ID	UNCONFIGURED	\N	DISABLED	接入参数待业务系统确认
59	\N	\N	\N	\N	\N	P4FIX_PUSH_MOCK_APP_30_TODO	2026-09-18 00:00:00+00	2026-09-17 23:00:00+00	1	P4FIX_APP_30	TODO	PUSH	\N	{}	{}	UNIFIED_USER_ID	UNCONFIGURED	\N	DISABLED	接入参数待业务系统确认
60	\N	\N	\N	\N	\N	P4FIX_PUSH_MOCK_APP_30_MESSAGE	2026-09-18 00:00:00+00	2026-09-17 23:00:00+00	1	P4FIX_APP_30	MESSAGE	PUSH	\N	{}	{}	UNIFIED_USER_ID	DISABLED	\N	DISABLED	接入参数待业务系统确认
61	\N	\N	\N	\N	\N	P4FIX_PUSH_MOCK_APP_31_TODO	2026-09-18 00:00:00+00	2026-09-17 23:00:00+00	1	P4FIX_APP_31	TODO	PUSH	\N	{}	{}	UNIFIED_USER_ID	DISABLED	\N	DISABLED	接入参数待业务系统确认
62	\N	\N	\N	\N	\N	P4FIX_PUSH_MOCK_APP_31_MESSAGE	2026-09-18 00:00:00+00	2026-09-17 23:00:00+00	1	P4FIX_APP_31	MESSAGE	PUSH	\N	{}	{}	UNIFIED_USER_ID	UNCONFIGURED	\N	DISABLED	接入参数待业务系统确认
63	\N	\N	\N	\N	\N	P4FIX_PUSH_MOCK_APP_32_TODO	2026-09-18 00:00:00+00	2026-09-17 23:00:00+00	1	P4FIX_APP_32	TODO	PUSH	\N	{}	{}	UNIFIED_USER_ID	UNCONFIGURED	\N	DISABLED	接入参数待业务系统确认
64	\N	\N	\N	\N	\N	P4FIX_PUSH_MOCK_APP_32_MESSAGE	2026-09-18 00:00:00+00	2026-09-17 23:00:00+00	1	P4FIX_APP_32	MESSAGE	PUSH	\N	{}	{}	UNIFIED_USER_ID	UNCONFIGURED	\N	DISABLED	接入参数待业务系统确认
65	\N	\N	\N	\N	\N	P4FIX_PUSH_MOCK_APP_33_TODO	2026-09-18 00:00:00+00	2026-09-17 23:00:00+00	1	P4FIX_APP_33	TODO	PUSH	\N	{}	{}	UNIFIED_USER_ID	UNCONFIGURED	\N	DISABLED	接入参数待业务系统确认
66	\N	\N	\N	\N	\N	P4FIX_PUSH_MOCK_APP_33_MESSAGE	2026-09-18 00:00:00+00	2026-09-17 23:00:00+00	1	P4FIX_APP_33	MESSAGE	PUSH	\N	{}	{}	UNIFIED_USER_ID	UNCONFIGURED	\N	DISABLED	接入参数待业务系统确认
67	\N	\N	\N	\N	\N	P4FIX_PUSH_MOCK_APP_34_TODO	2026-09-18 00:00:00+00	2026-09-17 23:00:00+00	1	P4FIX_APP_34	TODO	PUSH	\N	{}	{}	UNIFIED_USER_ID	UNCONFIGURED	\N	DISABLED	接入参数待业务系统确认
68	\N	\N	\N	\N	\N	P4FIX_PUSH_MOCK_APP_34_MESSAGE	2026-09-18 00:00:00+00	2026-09-17 23:00:00+00	1	P4FIX_APP_34	MESSAGE	PUSH	\N	{}	{}	UNIFIED_USER_ID	DISABLED	\N	DISABLED	接入参数待业务系统确认
69	\N	\N	\N	\N	\N	P4FIX_PUSH_MOCK_APP_35_TODO	2026-09-18 00:00:00+00	2026-09-17 23:00:00+00	1	P4FIX_APP_35	TODO	PUSH	\N	{}	{}	UNIFIED_USER_ID	DISABLED	\N	DISABLED	接入参数待业务系统确认
70	\N	\N	\N	\N	\N	P4FIX_PUSH_MOCK_APP_35_MESSAGE	2026-09-18 00:00:00+00	2026-09-17 23:00:00+00	1	P4FIX_APP_35	MESSAGE	PUSH	\N	{}	{}	UNIFIED_USER_ID	UNCONFIGURED	\N	DISABLED	接入参数待业务系统确认
71	\N	\N	\N	\N	\N	P4FIX_PUSH_MOCK_APP_36_TODO	2026-09-18 00:00:00+00	2026-09-17 23:00:00+00	1	P4FIX_APP_36	TODO	PUSH	\N	{}	{}	UNIFIED_USER_ID	UNCONFIGURED	\N	DISABLED	接入参数待业务系统确认
72	\N	\N	\N	\N	\N	P4FIX_PUSH_MOCK_APP_36_MESSAGE	2026-09-18 00:00:00+00	2026-09-17 23:00:00+00	1	P4FIX_APP_36	MESSAGE	PUSH	\N	{}	{}	UNIFIED_USER_ID	UNCONFIGURED	\N	DISABLED	接入参数待业务系统确认
73	\N	\N	\N	\N	\N	P4FIX_PUSH_MOCK_APP_37_TODO	2026-09-18 00:00:00+00	2026-09-17 23:00:00+00	1	P4FIX_APP_37	TODO	PUSH	\N	{}	{}	UNIFIED_USER_ID	UNCONFIGURED	\N	DISABLED	接入参数待业务系统确认
74	\N	\N	\N	\N	\N	P4FIX_PUSH_MOCK_APP_37_MESSAGE	2026-09-18 00:00:00+00	2026-09-17 23:00:00+00	1	P4FIX_APP_37	MESSAGE	PUSH	\N	{}	{}	UNIFIED_USER_ID	UNCONFIGURED	\N	DISABLED	接入参数待业务系统确认
75	\N	\N	\N	\N	\N	P4FIX_PUSH_MOCK_APP_38_TODO	2026-09-18 00:00:00+00	2026-09-17 23:00:00+00	1	P4FIX_APP_38	TODO	PUSH	\N	{}	{}	UNIFIED_USER_ID	UNCONFIGURED	\N	DISABLED	接入参数待业务系统确认
76	\N	\N	\N	\N	\N	P4FIX_PUSH_MOCK_APP_38_MESSAGE	2026-09-18 00:00:00+00	2026-09-17 23:00:00+00	1	P4FIX_APP_38	MESSAGE	PUSH	\N	{}	{}	UNIFIED_USER_ID	DISABLED	\N	DISABLED	接入参数待业务系统确认
77	\N	\N	\N	\N	\N	P4FIX_PUSH_MOCK_APP_39_TODO	2026-09-18 00:00:00+00	2026-09-17 23:00:00+00	1	P4FIX_APP_39	TODO	PUSH	\N	{}	{}	UNIFIED_USER_ID	DISABLED	\N	DISABLED	接入参数待业务系统确认
78	\N	\N	\N	\N	\N	P4FIX_PUSH_MOCK_APP_39_MESSAGE	2026-09-18 00:00:00+00	2026-09-17 23:00:00+00	1	P4FIX_APP_39	MESSAGE	PUSH	\N	{}	{}	UNIFIED_USER_ID	UNCONFIGURED	\N	DISABLED	接入参数待业务系统确认
79	\N	\N	\N	\N	\N	P4FIX_PUSH_MOCK_APP_40_TODO	2026-09-18 00:00:00+00	2026-09-17 23:00:00+00	1	P4FIX_APP_40	TODO	PUSH	\N	{}	{}	UNIFIED_USER_ID	UNCONFIGURED	\N	DISABLED	接入参数待业务系统确认
80	\N	\N	\N	\N	\N	P4FIX_PUSH_MOCK_APP_40_MESSAGE	2026-09-18 00:00:00+00	2026-09-17 23:00:00+00	1	P4FIX_APP_40	MESSAGE	PUSH	\N	{}	{}	UNIFIED_USER_ID	UNCONFIGURED	\N	DISABLED	接入参数待业务系统确认
81	\N	\N	\N	\N	\N	P4FIX_PUSH_MOCK_APP_41_TODO	2026-09-18 00:00:00+00	2026-09-17 23:00:00+00	1	P4FIX_APP_41	TODO	PUSH	\N	{}	{}	UNIFIED_USER_ID	UNCONFIGURED	\N	DISABLED	接入参数待业务系统确认
82	\N	\N	\N	\N	\N	P4FIX_PUSH_MOCK_APP_41_MESSAGE	2026-09-18 00:00:00+00	2026-09-17 23:00:00+00	1	P4FIX_APP_41	MESSAGE	PUSH	\N	{}	{}	UNIFIED_USER_ID	UNCONFIGURED	\N	DISABLED	接入参数待业务系统确认
83	\N	\N	\N	\N	\N	P4FIX_PUSH_MOCK_APP_43_TODO	2026-09-18 00:00:00+00	2026-09-17 23:00:00+00	1	P4FIX_APP_43	TODO	PUSH	\N	{}	{}	UNIFIED_USER_ID	DISABLED	\N	DISABLED	接入参数待业务系统确认
84	\N	\N	\N	\N	\N	P4FIX_PUSH_MOCK_APP_43_MESSAGE	2026-09-18 00:00:00+00	2026-09-17 23:00:00+00	1	P4FIX_APP_43	MESSAGE	PUSH	\N	{}	{}	UNIFIED_USER_ID	DISABLED	\N	DISABLED	接入参数待业务系统确认
\.


--
-- Data for Name: sms_application; Type: TABLE DATA; Schema: pb3gir75kkooyea; Owner: admin
--

COPY pb3gir75kkooyea.sms_application (nc_id, created_at1, updated_at1, created_by, updated_by, nc_order, id, created_at, updated_at, version, application_id, sms_app_id, secret_ref, daily_limit, status) FROM stdin;
\.


--
-- Data for Name: sms_application_template; Type: TABLE DATA; Schema: pb3gir75kkooyea; Owner: admin
--

COPY pb3gir75kkooyea.sms_application_template (nc_id, created_at1, updated_at1, created_by, updated_by, nc_order, id, created_at, updated_at, version, sms_application_id, template_id) FROM stdin;
\.


--
-- Data for Name: sms_channel; Type: TABLE DATA; Schema: pb3gir75kkooyea; Owner: admin
--

COPY pb3gir75kkooyea.sms_channel (nc_id, created_at1, updated_at1, created_by, updated_by, nc_order, id, created_at, updated_at, version, code, name, provider, api_url, secret_ref, sign_name, status, runtime_status) FROM stdin;
\.


--
-- Data for Name: sms_send_attempt; Type: TABLE DATA; Schema: pb3gir75kkooyea; Owner: admin
--

COPY pb3gir75kkooyea.sms_send_attempt (nc_id, created_at1, updated_at1, created_by, updated_by, nc_order, id, created_at, updated_at, version, send_id, attempt_no, provider_request_id, status, delivery_certainty, fee_minor_units, currency, finished_at, provider_summary) FROM stdin;
\.


--
-- Data for Name: sms_send_record; Type: TABLE DATA; Schema: pb3gir75kkooyea; Owner: admin
--

COPY pb3gir75kkooyea.sms_send_record (nc_id, created_at1, updated_at1, created_by, updated_by, nc_order, id, created_at, updated_at, version, application_id, template_id, channel_id, request_key, payload_hash, mobile_masked, recipient_secret_ref, variables_secret_ref, content_summary, status, retry_count, failure_reason) FROM stdin;
\.


--
-- Data for Name: sms_template; Type: TABLE DATA; Schema: pb3gir75kkooyea; Owner: admin
--

COPY pb3gir75kkooyea.sms_template (nc_id, created_at1, updated_at1, created_by, updated_by, nc_order, id, created_at, updated_at, version, code, name, scene_type, content, variables, sign_name, provider_template_id, status) FROM stdin;
\.


--
-- Data for Name: sso_config; Type: TABLE DATA; Schema: pb3gir75kkooyea; Owner: admin
--

COPY pb3gir75kkooyea.sso_config (nc_id, created_at1, updated_at1, created_by, updated_by, nc_order, id, created_at, updated_at, version, application_id, protocol, client_id, secret_ref, endpoints, user_key_field, token_expire_seconds, status, enabled, remark) FROM stdin;
1	\N	\N	\N	\N	\N	P4FIX_SSO_MOCK_APP_1	2026-09-18 00:00:00+00	2026-09-17 23:00:00+00	1	P4FIX_APP_1	UNCONFIGURED	\N	\N	{"authorizeUrl":"","tokenUrl":"","callbackUrl":""}	\N	\N	UNCONFIGURED	DISABLED	接入参数待业务系统确认
2	\N	\N	\N	\N	\N	P4FIX_SSO_MOCK_APP_2	2026-09-18 00:00:00+00	2026-09-17 23:00:00+00	1	P4FIX_APP_2	UNCONFIGURED	\N	\N	{"authorizeUrl":"","tokenUrl":"","callbackUrl":""}	\N	\N	UNCONFIGURED	DISABLED	接入参数待业务系统确认
3	\N	\N	\N	\N	\N	P4FIX_SSO_MOCK_APP_3	2026-09-18 00:00:00+00	2026-09-17 23:00:00+00	1	P4FIX_APP_3	UNCONFIGURED	\N	\N	{"authorizeUrl":"","tokenUrl":"","callbackUrl":""}	\N	\N	UNCONFIGURED	DISABLED	接入参数待业务系统确认
4	\N	\N	\N	\N	\N	P4FIX_SSO_MOCK_APP_4	2026-09-18 00:00:00+00	2026-09-17 23:00:00+00	1	P4FIX_APP_4	UNCONFIGURED	\N	\N	{"authorizeUrl":"","tokenUrl":"","callbackUrl":""}	\N	\N	DISABLED	DISABLED	接入参数待业务系统确认
5	\N	\N	\N	\N	\N	P4FIX_SSO_MOCK_APP_5	2026-09-18 00:00:00+00	2026-09-17 23:00:00+00	1	P4FIX_APP_5	UNCONFIGURED	\N	\N	{"authorizeUrl":"","tokenUrl":"","callbackUrl":""}	\N	\N	UNCONFIGURED	DISABLED	接入参数待业务系统确认
6	\N	\N	\N	\N	\N	P4FIX_SSO_MOCK_APP_6	2026-09-18 00:00:00+00	2026-09-17 23:00:00+00	1	P4FIX_APP_6	UNCONFIGURED	\N	\N	{"authorizeUrl":"","tokenUrl":"","callbackUrl":""}	\N	\N	UNCONFIGURED	DISABLED	接入参数待业务系统确认
7	\N	\N	\N	\N	\N	P4FIX_SSO_MOCK_APP_7	2026-09-18 00:00:00+00	2026-09-17 23:00:00+00	1	P4FIX_APP_7	UNCONFIGURED	\N	\N	{"authorizeUrl":"","tokenUrl":"","callbackUrl":""}	\N	\N	UNCONFIGURED	DISABLED	接入参数待业务系统确认
8	\N	\N	\N	\N	\N	P4FIX_SSO_MOCK_APP_8	2026-09-18 00:00:00+00	2026-09-17 23:00:00+00	1	P4FIX_APP_8	UNCONFIGURED	\N	\N	{"authorizeUrl":"","tokenUrl":"","callbackUrl":""}	\N	\N	DISABLED	DISABLED	接入参数待业务系统确认
9	\N	\N	\N	\N	\N	P4FIX_SSO_MOCK_APP_9	2026-09-18 00:00:00+00	2026-09-17 23:00:00+00	1	P4FIX_APP_9	UNCONFIGURED	\N	\N	{"authorizeUrl":"","tokenUrl":"","callbackUrl":""}	\N	\N	UNCONFIGURED	DISABLED	接入参数待业务系统确认
10	\N	\N	\N	\N	\N	P4FIX_SSO_MOCK_APP_10	2026-09-18 00:00:00+00	2026-09-17 23:00:00+00	1	P4FIX_APP_10	UNCONFIGURED	\N	\N	{"authorizeUrl":"","tokenUrl":"","callbackUrl":""}	\N	\N	UNCONFIGURED	DISABLED	接入参数待业务系统确认
11	\N	\N	\N	\N	\N	P4FIX_SSO_MOCK_APP_11	2026-09-18 00:00:00+00	2026-09-17 23:00:00+00	1	P4FIX_APP_11	UNCONFIGURED	\N	\N	{"authorizeUrl":"","tokenUrl":"","callbackUrl":""}	\N	\N	UNCONFIGURED	DISABLED	接入参数待业务系统确认
12	\N	\N	\N	\N	\N	P4FIX_SSO_MOCK_APP_12	2026-09-18 00:00:00+00	2026-09-17 23:00:00+00	1	P4FIX_APP_12	UNCONFIGURED	\N	\N	{"authorizeUrl":"","tokenUrl":"","callbackUrl":""}	\N	\N	DISABLED	DISABLED	接入参数待业务系统确认
13	\N	\N	\N	\N	\N	P4FIX_SSO_MOCK_APP_13	2026-09-18 00:00:00+00	2026-09-17 23:00:00+00	1	P4FIX_APP_13	UNCONFIGURED	\N	\N	{"authorizeUrl":"","tokenUrl":"","callbackUrl":""}	\N	\N	UNCONFIGURED	DISABLED	接入参数待业务系统确认
14	\N	\N	\N	\N	\N	P4FIX_SSO_MOCK_APP_14	2026-09-18 00:00:00+00	2026-09-17 23:00:00+00	1	P4FIX_APP_14	UNCONFIGURED	\N	\N	{"authorizeUrl":"","tokenUrl":"","callbackUrl":""}	\N	\N	UNCONFIGURED	DISABLED	接入参数待业务系统确认
15	\N	\N	\N	\N	\N	P4FIX_SSO_MOCK_APP_15	2026-09-18 00:00:00+00	2026-09-17 23:00:00+00	1	P4FIX_APP_15	UNCONFIGURED	\N	\N	{"authorizeUrl":"","tokenUrl":"","callbackUrl":""}	\N	\N	UNCONFIGURED	DISABLED	接入参数待业务系统确认
16	\N	\N	\N	\N	\N	P4FIX_SSO_MOCK_APP_16	2026-09-18 00:00:00+00	2026-09-17 23:00:00+00	1	P4FIX_APP_16	UNCONFIGURED	\N	\N	{"authorizeUrl":"","tokenUrl":"","callbackUrl":""}	\N	\N	DISABLED	DISABLED	接入参数待业务系统确认
17	\N	\N	\N	\N	\N	P4FIX_SSO_MOCK_APP_17	2026-09-18 00:00:00+00	2026-09-17 23:00:00+00	1	P4FIX_APP_17	UNCONFIGURED	\N	\N	{"authorizeUrl":"","tokenUrl":"","callbackUrl":""}	\N	\N	UNCONFIGURED	DISABLED	接入参数待业务系统确认
18	\N	\N	\N	\N	\N	P4FIX_SSO_MOCK_APP_18	2026-09-18 00:00:00+00	2026-09-17 23:00:00+00	1	P4FIX_APP_18	UNCONFIGURED	\N	\N	{"authorizeUrl":"","tokenUrl":"","callbackUrl":""}	\N	\N	UNCONFIGURED	DISABLED	接入参数待业务系统确认
19	\N	\N	\N	\N	\N	P4FIX_SSO_MOCK_APP_19	2026-09-18 00:00:00+00	2026-09-17 23:00:00+00	1	P4FIX_APP_19	UNCONFIGURED	\N	\N	{"authorizeUrl":"","tokenUrl":"","callbackUrl":""}	\N	\N	UNCONFIGURED	DISABLED	接入参数待业务系统确认
20	\N	\N	\N	\N	\N	P4FIX_SSO_MOCK_APP_20	2026-09-18 00:00:00+00	2026-09-17 23:00:00+00	1	P4FIX_APP_20	UNCONFIGURED	\N	\N	{"authorizeUrl":"","tokenUrl":"","callbackUrl":""}	\N	\N	DISABLED	DISABLED	接入参数待业务系统确认
21	\N	\N	\N	\N	\N	P4FIX_SSO_MOCK_APP_21	2026-09-18 00:00:00+00	2026-09-17 23:00:00+00	1	P4FIX_APP_21	UNCONFIGURED	\N	\N	{"authorizeUrl":"","tokenUrl":"","callbackUrl":""}	\N	\N	UNCONFIGURED	DISABLED	接入参数待业务系统确认
22	\N	\N	\N	\N	\N	P4FIX_SSO_MOCK_APP_22	2026-09-18 00:00:00+00	2026-09-17 23:00:00+00	1	P4FIX_APP_22	UNCONFIGURED	\N	\N	{"authorizeUrl":"","tokenUrl":"","callbackUrl":""}	\N	\N	UNCONFIGURED	DISABLED	接入参数待业务系统确认
23	\N	\N	\N	\N	\N	P4FIX_SSO_MOCK_APP_23	2026-09-18 00:00:00+00	2026-09-17 23:00:00+00	1	P4FIX_APP_23	UNCONFIGURED	\N	\N	{"authorizeUrl":"","tokenUrl":"","callbackUrl":""}	\N	\N	UNCONFIGURED	DISABLED	接入参数待业务系统确认
24	\N	\N	\N	\N	\N	P4FIX_SSO_MOCK_APP_24	2026-09-18 00:00:00+00	2026-09-17 23:00:00+00	1	P4FIX_APP_24	UNCONFIGURED	\N	\N	{"authorizeUrl":"","tokenUrl":"","callbackUrl":""}	\N	\N	DISABLED	DISABLED	接入参数待业务系统确认
25	\N	\N	\N	\N	\N	P4FIX_SSO_MOCK_APP_25	2026-09-18 00:00:00+00	2026-09-17 23:00:00+00	1	P4FIX_APP_25	UNCONFIGURED	\N	\N	{"authorizeUrl":"","tokenUrl":"","callbackUrl":""}	\N	\N	UNCONFIGURED	DISABLED	接入参数待业务系统确认
26	\N	\N	\N	\N	\N	P4FIX_SSO_MOCK_APP_26	2026-09-18 00:00:00+00	2026-09-17 23:00:00+00	1	P4FIX_APP_26	UNCONFIGURED	\N	\N	{"authorizeUrl":"","tokenUrl":"","callbackUrl":""}	\N	\N	UNCONFIGURED	DISABLED	接入参数待业务系统确认
27	\N	\N	\N	\N	\N	P4FIX_SSO_MOCK_APP_27	2026-09-18 00:00:00+00	2026-09-17 23:00:00+00	1	P4FIX_APP_27	UNCONFIGURED	\N	\N	{"authorizeUrl":"","tokenUrl":"","callbackUrl":""}	\N	\N	UNCONFIGURED	DISABLED	接入参数待业务系统确认
28	\N	\N	\N	\N	\N	P4FIX_SSO_MOCK_APP_28	2026-09-18 00:00:00+00	2026-09-17 23:00:00+00	1	P4FIX_APP_28	UNCONFIGURED	\N	\N	{"authorizeUrl":"","tokenUrl":"","callbackUrl":""}	\N	\N	DISABLED	DISABLED	接入参数待业务系统确认
29	\N	\N	\N	\N	\N	P4FIX_SSO_MOCK_APP_29	2026-09-18 00:00:00+00	2026-09-17 23:00:00+00	1	P4FIX_APP_29	UNCONFIGURED	\N	\N	{"authorizeUrl":"","tokenUrl":"","callbackUrl":""}	\N	\N	UNCONFIGURED	DISABLED	接入参数待业务系统确认
30	\N	\N	\N	\N	\N	P4FIX_SSO_MOCK_APP_30	2026-09-18 00:00:00+00	2026-09-17 23:00:00+00	1	P4FIX_APP_30	UNCONFIGURED	\N	\N	{"authorizeUrl":"","tokenUrl":"","callbackUrl":""}	\N	\N	UNCONFIGURED	DISABLED	接入参数待业务系统确认
31	\N	\N	\N	\N	\N	P4FIX_SSO_MOCK_APP_31	2026-09-18 00:00:00+00	2026-09-17 23:00:00+00	1	P4FIX_APP_31	UNCONFIGURED	\N	\N	{"authorizeUrl":"","tokenUrl":"","callbackUrl":""}	\N	\N	UNCONFIGURED	DISABLED	接入参数待业务系统确认
32	\N	\N	\N	\N	\N	P4FIX_SSO_MOCK_APP_32	2026-09-18 00:00:00+00	2026-09-17 23:00:00+00	1	P4FIX_APP_32	UNCONFIGURED	\N	\N	{"authorizeUrl":"","tokenUrl":"","callbackUrl":""}	\N	\N	DISABLED	DISABLED	接入参数待业务系统确认
33	\N	\N	\N	\N	\N	P4FIX_SSO_MOCK_APP_33	2026-09-18 00:00:00+00	2026-09-17 23:00:00+00	1	P4FIX_APP_33	UNCONFIGURED	\N	\N	{"authorizeUrl":"","tokenUrl":"","callbackUrl":""}	\N	\N	UNCONFIGURED	DISABLED	接入参数待业务系统确认
34	\N	\N	\N	\N	\N	P4FIX_SSO_MOCK_APP_34	2026-09-18 00:00:00+00	2026-09-17 23:00:00+00	1	P4FIX_APP_34	UNCONFIGURED	\N	\N	{"authorizeUrl":"","tokenUrl":"","callbackUrl":""}	\N	\N	UNCONFIGURED	DISABLED	接入参数待业务系统确认
35	\N	\N	\N	\N	\N	P4FIX_SSO_MOCK_APP_35	2026-09-18 00:00:00+00	2026-09-17 23:00:00+00	1	P4FIX_APP_35	UNCONFIGURED	\N	\N	{"authorizeUrl":"","tokenUrl":"","callbackUrl":""}	\N	\N	UNCONFIGURED	DISABLED	接入参数待业务系统确认
36	\N	\N	\N	\N	\N	P4FIX_SSO_MOCK_APP_36	2026-09-18 00:00:00+00	2026-09-17 23:00:00+00	1	P4FIX_APP_36	UNCONFIGURED	\N	\N	{"authorizeUrl":"","tokenUrl":"","callbackUrl":""}	\N	\N	DISABLED	DISABLED	接入参数待业务系统确认
37	\N	\N	\N	\N	\N	P4FIX_SSO_MOCK_APP_37	2026-09-18 00:00:00+00	2026-09-17 23:00:00+00	1	P4FIX_APP_37	UNCONFIGURED	\N	\N	{"authorizeUrl":"","tokenUrl":"","callbackUrl":""}	\N	\N	UNCONFIGURED	DISABLED	接入参数待业务系统确认
38	\N	\N	\N	\N	\N	P4FIX_SSO_MOCK_APP_38	2026-09-18 00:00:00+00	2026-09-17 23:00:00+00	1	P4FIX_APP_38	UNCONFIGURED	\N	\N	{"authorizeUrl":"","tokenUrl":"","callbackUrl":""}	\N	\N	UNCONFIGURED	DISABLED	接入参数待业务系统确认
39	\N	\N	\N	\N	\N	P4FIX_SSO_MOCK_APP_39	2026-09-18 00:00:00+00	2026-09-17 23:00:00+00	1	P4FIX_APP_39	UNCONFIGURED	\N	\N	{"authorizeUrl":"","tokenUrl":"","callbackUrl":""}	\N	\N	UNCONFIGURED	DISABLED	接入参数待业务系统确认
40	\N	\N	\N	\N	\N	P4FIX_SSO_MOCK_APP_40	2026-09-18 00:00:00+00	2026-09-17 23:00:00+00	1	P4FIX_APP_40	UNCONFIGURED	\N	\N	{"authorizeUrl":"","tokenUrl":"","callbackUrl":""}	\N	\N	DISABLED	DISABLED	接入参数待业务系统确认
41	\N	\N	\N	\N	\N	P4FIX_SSO_MOCK_APP_41	2026-09-18 00:00:00+00	2026-09-17 23:00:00+00	1	P4FIX_APP_41	UNCONFIGURED	\N	\N	{"authorizeUrl":"","tokenUrl":"","callbackUrl":""}	\N	\N	UNCONFIGURED	DISABLED	接入参数待业务系统确认
42	\N	\N	\N	\N	\N	P4FIX_SSO_MOCK_APP_43	2026-09-18 00:00:00+00	2026-09-17 23:00:00+00	1	P4FIX_APP_43	UNCONFIGURED	\N	\N	{"authorizeUrl":"","tokenUrl":"","callbackUrl":""}	\N	\N	DISABLED	DISABLED	接入参数待业务系统确认
\.


--
-- Data for Name: system_config; Type: TABLE DATA; Schema: pb3gir75kkooyea; Owner: admin
--

COPY pb3gir75kkooyea.system_config (nc_id, created_at1, updated_at1, created_by, updated_by, nc_order, id, created_at, updated_at, version, code, value, unit, status, description) FROM stdin;
1	2026-09-17 23:14:54	\N	usv2e4vtzr1dkt0q	\N	1	cfg.retention.message_days	2026-09-17 00:00:00+00	2026-09-17 00:00:00+00	1	retention.message_days	\N	day	UNCONFIGURED	消息留存周期
2	2026-09-17 23:14:54	\N	usv2e4vtzr1dkt0q	\N	2	cfg.retention.todo_terminal_days	2026-09-17 00:00:00+00	2026-09-17 00:00:00+00	1	retention.todo_terminal_days	\N	day	UNCONFIGURED	终态待办留存周期
3	2026-09-17 23:14:54	\N	usv2e4vtzr1dkt0q	\N	3	cfg.retention.log_days	2026-09-17 00:00:00+00	2026-09-17 00:00:00+00	1	retention.log_days	\N	day	UNCONFIGURED	日志留存周期
4	2026-09-17 23:14:54	\N	usv2e4vtzr1dkt0q	\N	4	cfg.auth.qr_ttl_seconds	2026-09-17 00:00:00+00	2026-09-17 00:00:00+00	1	auth.qr_ttl_seconds	\N	second	UNCONFIGURED	二维码有效期
5	2026-09-17 23:14:54	\N	usv2e4vtzr1dkt0q	\N	5	cfg.auth.otp_ttl_seconds	2026-09-17 00:00:00+00	2026-09-17 00:00:00+00	1	auth.otp_ttl_seconds	\N	second	UNCONFIGURED	验证码有效期
6	2026-09-17 23:14:54	\N	usv2e4vtzr1dkt0q	\N	6	cfg.auth.session_ttl_seconds	2026-09-17 00:00:00+00	2026-09-17 00:00:00+00	1	auth.session_ttl_seconds	\N	second	UNCONFIGURED	Session有效期
7	2026-09-17 23:14:54	\N	usv2e4vtzr1dkt0q	\N	7	cfg.auth.failure_limit	2026-09-17 00:00:00+00	2026-09-17 00:00:00+00	1	auth.failure_limit	\N	count/window	UNCONFIGURED	登录失败限制
8	2026-09-17 23:14:54	\N	usv2e4vtzr1dkt0q	\N	8	cfg.integration.timeout_ms	2026-09-17 00:00:00+00	2026-09-17 00:00:00+00	1	integration.timeout_ms	\N	ms	UNCONFIGURED	接口超时
9	2026-09-17 23:14:54	\N	usv2e4vtzr1dkt0q	\N	9	cfg.integration.max_retries	2026-09-17 00:00:00+00	2026-09-17 00:00:00+00	1	integration.max_retries	\N	count	UNCONFIGURED	接口重试上限
10	2026-09-17 23:14:54	\N	usv2e4vtzr1dkt0q	\N	10	cfg.sms.max_retries	2026-09-17 00:00:00+00	2026-09-17 00:00:00+00	1	sms.max_retries	\N	count	UNCONFIGURED	短信重试上限
11	2026-09-17 23:14:54	\N	usv2e4vtzr1dkt0q	\N	11	cfg.monitor.failure_threshold	2026-09-17 00:00:00+00	2026-09-17 00:00:00+00	1	monitor.failure_threshold	\N	count	UNCONFIGURED	监控失败阈值
12	2026-09-17 23:14:54	\N	usv2e4vtzr1dkt0q	\N	12	cfg.upload.policy	2026-09-17 00:00:00+00	2026-09-17 00:00:00+00	1	upload.policy	\N	json	UNCONFIGURED	附件类型和大小约束
40	\N	\N	\N	\N	\N	P4BACKUP_20260919	2026-09-19 11:09:00.369643+00	2026-09-19 11:09:00.369643+00	1	P4BACKUP_20260919	{"apps":[{"id":"MOCK_APP_1","url":"https://p4.invalid/app/1","code":"WJ_APP_01","name":"福建省新生儿疾病筛查管理系统","status":"ENABLED","version":1,"category":"公众服务","sourceNo":1,"userType":"BOTH","createdAt":"2026-09-16T00:00:00.000Z","sortOrder":1,"updatedAt":"2026-09-17T23:00:00.000Z","categoryId":"MOCK_CAT_1","platformId":"MOCK_PLATFORM_1","platformNo":1,"description":"管理新生儿筛查登记、结果反馈、阳性召回与随访。","networkZone":"政务外网(卫健专网)","platformName":"福建省全民健康信息平台","runtimeStatus":"NORMAL","integrationNote":"服务地址与接入参数待配置","connectionStatus":"UNCONFIGURED"},{"id":"MOCK_APP_2","url":"https://p4.invalid/app/2","code":"WJ_APP_02","name":"福建省妇幼卫生信息系统","status":"ENABLED","version":1,"category":"公众服务","sourceNo":2,"userType":"BOTH","createdAt":"2026-09-16T00:00:00.000Z","sortOrder":2,"updatedAt":"2026-09-17T23:00:00.000Z","categoryId":"MOCK_CAT_1","platformId":"MOCK_PLATFORM_1","platformNo":1,"description":"汇集妇女儿童保健记录，支持孕产期管理及妇幼统计。","networkZone":"政务外网(卫健专网)","platformName":"福建省全民健康信息平台","runtimeStatus":"NORMAL","integrationNote":"服务地址与接入参数待配置","connectionStatus":"UNCONFIGURED"},{"id":"MOCK_APP_3","url":"https://p4.invalid/app/3","code":"WJ_APP_03","name":"福建省产前筛查与诊断管理系统","status":"ENABLED","version":1,"category":"政务协同","sourceNo":3,"userType":"BOTH","createdAt":"2026-09-16T00:00:00.000Z","sortOrder":3,"updatedAt":"2026-09-17T23:00:00.000Z","categoryId":"MOCK_CAT_2","platformId":"MOCK_PLATFORM_1","platformNo":1,"description":"管理产前筛查、风险评估、诊断转介与随访。","networkZone":"政务外网(卫健专网)","platformName":"福建省全民健康信息平台","runtimeStatus":"NORMAL","integrationNote":"服务地址与接入参数待配置","connectionStatus":"UNCONFIGURED"},{"id":"MOCK_APP_4","url":"https://p4.invalid/app/4","code":"WJ_APP_04","name":"福建省地中海贫血信息管理系统","status":"ENABLED","version":1,"category":"政务协同","sourceNo":4,"userType":"BOTH","createdAt":"2026-09-16T00:00:00.000Z","sortOrder":4,"updatedAt":"2026-09-17T23:00:00.000Z","categoryId":"MOCK_CAT_2","platformId":"MOCK_PLATFORM_1","platformNo":1,"description":"管理地中海贫血筛查、检测结果与遗传咨询。","networkZone":"政务外网(卫健专网)","platformName":"福建省全民健康信息平台","runtimeStatus":"NORMAL","integrationNote":"服务地址与接入参数待配置","connectionStatus":"UNCONFIGURED"},{"id":"MOCK_APP_5","url":"https://p4.invalid/app/5","code":"WJ_APP_05","name":"福建省慢病报告与管理系统","status":"ENABLED","version":1,"category":"政务协同","sourceNo":5,"userType":"BOTH","createdAt":"2026-09-16T00:00:00.000Z","sortOrder":5,"updatedAt":"2026-09-17T23:00:00.000Z","categoryId":"MOCK_CAT_2","platformId":"MOCK_PLATFORM_1","platformNo":1,"description":"汇总慢性病报告，支持病例核查与随访管理。","networkZone":"政务外网(卫健专网)","platformName":"福建省全民健康信息平台","runtimeStatus":"NORMAL","integrationNote":"服务地址与接入参数待配置","connectionStatus":"UNCONFIGURED"},{"id":"MOCK_APP_6","url":"https://p4.invalid/app/6","code":"WJ_APP_06","name":"福建省区域影像平台","status":"ENABLED","version":1,"category":"政务协同","sourceNo":6,"userType":"BOTH","createdAt":"2026-09-16T00:00:00.000Z","sortOrder":6,"updatedAt":"2026-09-17T23:00:00.000Z","categoryId":"MOCK_CAT_2","platformId":"MOCK_PLATFORM_1","platformNo":1,"description":"汇集区域医学影像，支持影像调阅与诊疗协作。","networkZone":"政务外网(卫健专网)","platformName":"福建省全民健康信息平台","runtimeStatus":"NORMAL","integrationNote":"服务地址与接入参数待配置","connectionStatus":"UNCONFIGURED"},{"id":"MOCK_APP_7","url":"https://p4.invalid/app/7","code":"WJ_APP_07","name":"质控评分系统","status":"ENABLED","version":1,"category":"政务协同","sourceNo":7,"userType":"GOV","createdAt":"2026-09-16T00:00:00.000Z","sortOrder":7,"updatedAt":"2026-09-17T23:00:00.000Z","categoryId":"MOCK_CAT_2","platformId":"MOCK_PLATFORM_1","platformNo":1,"description":"管理质量控制指标、评分记录及问题整改。","networkZone":"政务外网(卫健专网)","platformName":"福建省全民健康信息平台","runtimeStatus":"NORMAL","integrationNote":"服务地址与接入参数待配置","connectionStatus":"UNCONFIGURED"},{"id":"MOCK_APP_8","url":"https://p4.invalid/app/8","code":"WJ_APP_08","name":"省级平台决策支持展示系统","status":"ENABLED","version":1,"category":"政务协同","sourceNo":8,"userType":"GOV","createdAt":"2026-09-16T00:00:00.000Z","sortOrder":8,"updatedAt":"2026-09-17T23:00:00.000Z","categoryId":"MOCK_CAT_2","platformId":"MOCK_PLATFORM_1","platformNo":1,"description":"汇总卫生健康指标，支持资源配置与管理决策。","networkZone":"政务外网(卫健专网)","platformName":"福建省全民健康信息平台","runtimeStatus":"NORMAL","integrationNote":"服务地址与接入参数待配置","connectionStatus":"UNCONFIGURED"},{"id":"MOCK_APP_9","url":"https://p4.invalid/app/9","code":"WJ_APP_09","name":"单点登录系统","status":"ENABLED","version":1,"category":"政务协同","sourceNo":9,"userType":"GOV","createdAt":"2026-09-16T00:00:00.000Z","sortOrder":9,"updatedAt":"2026-09-17T23:00:00.000Z","categoryId":"MOCK_CAT_2","platformId":"MOCK_PLATFORM_1","platformNo":1,"description":"衔接统一登录与应用访问，管理身份关联和访问审计。","networkZone":"政务外网(卫健专网)","platformName":"福建省全民健康信息平台","runtimeStatus":"NORMAL","integrationNote":"服务地址与接入参数待配置","connectionStatus":"UNCONFIGURED"},{"id":"MOCK_APP_10","url":"https://p4.invalid/app/10","code":"WJ_APP_10","name":"福建省血液信息联网平台","status":"ENABLED","version":1,"category":"政务协同","sourceNo":10,"userType":"GOV","createdAt":"2026-09-16T00:00:00.000Z","sortOrder":10,"updatedAt":"2026-09-17T23:00:00.000Z","categoryId":"MOCK_CAT_2","platformId":"MOCK_PLATFORM_1","platformNo":1,"description":"汇集采供血信息，支持血液资源协同与质量追溯。","networkZone":"政务外网","platformName":"福建省全民健康信息平台","runtimeStatus":"NORMAL","integrationNote":"服务地址与接入参数待配置","connectionStatus":"UNCONFIGURED"},{"id":"MOCK_APP_11","url":"https://p4.invalid/app/11","code":"WJ_APP_11","name":"福建省免疫规划管理信息系统","status":"ENABLED","version":1,"category":"政务协同","sourceNo":11,"userType":"BOTH","createdAt":"2026-09-16T00:00:00.000Z","sortOrder":11,"updatedAt":"2026-09-17T23:00:00.000Z","categoryId":"MOCK_CAT_2","platformId":"MOCK_PLATFORM_1","platformNo":1,"description":"管理免疫规划接种记录、接种安排与覆盖统计。","networkZone":"政务外网(卫健专网)","platformName":"福建省全民健康信息平台","runtimeStatus":"NORMAL","integrationNote":"服务地址与接入参数待配置","connectionStatus":"UNCONFIGURED"},{"id":"MOCK_APP_12","url":"https://p4.invalid/app/12","code":"WJ_APP_12","name":"中医馆健康信息系统","status":"ENABLED","version":1,"category":"政务协同","sourceNo":12,"userType":"BOTH","createdAt":"2026-09-16T00:00:00.000Z","sortOrder":12,"updatedAt":"2026-09-17T23:00:00.000Z","categoryId":"MOCK_CAT_2","platformId":"MOCK_PLATFORM_1","platformNo":1,"description":"管理中医馆服务记录，支持中医诊疗与健康管理协同。","networkZone":"政务外网(卫健专网)","platformName":"福建省全民健康信息平台","runtimeStatus":"NORMAL","integrationNote":"服务地址与接入参数待配置","connectionStatus":"UNCONFIGURED"},{"id":"MOCK_APP_13","url":"https://p4.invalid/app/13","code":"WJ_APP_13","name":"福建省肝炎筛查与规范化治疗管理系统","status":"ENABLED","version":1,"category":"政务协同","sourceNo":13,"userType":"BOTH","createdAt":"2026-09-16T00:00:00.000Z","sortOrder":13,"updatedAt":"2026-09-17T23:00:00.000Z","categoryId":"MOCK_CAT_2","platformId":"MOCK_PLATFORM_1","platformNo":1,"description":"管理肝炎筛查、诊断转介、规范化治疗及随访。","networkZone":"政务外网(卫健专网)","platformName":"福建省全民健康信息平台","runtimeStatus":"NORMAL","integrationNote":"服务地址与接入参数待配置","connectionStatus":"UNCONFIGURED"},{"id":"MOCK_APP_14","url":"https://p4.invalid/app/14","code":"WJ_APP_14","name":"福建省全员人口计划生育服务与管理系统","status":"ENABLED","version":1,"category":"政务协同","sourceNo":14,"userType":"GOV","createdAt":"2026-09-16T00:00:00.000Z","sortOrder":14,"updatedAt":"2026-09-17T23:00:00.000Z","categoryId":"MOCK_CAT_2","platformId":"MOCK_PLATFORM_2","platformNo":2,"description":"维护人口服务信息，支持计划生育服务登记与核验。","networkZone":"政务外网(卫健专网)","platformName":"福建省全员人口计划生育服务与管理平台","runtimeStatus":"NORMAL","integrationNote":"服务地址与接入参数待配置","connectionStatus":"UNCONFIGURED"},{"id":"MOCK_APP_15","url":"https://p4.invalid/app/15","code":"WJ_APP_15","name":"福建省流动人口服务与管理信息系统","status":"ENABLED","version":1,"category":"政务协同","sourceNo":15,"userType":"GOV","createdAt":"2026-09-16T00:00:00.000Z","sortOrder":15,"updatedAt":"2026-09-17T23:00:00.000Z","categoryId":"MOCK_CAT_2","platformId":"MOCK_PLATFORM_2","platformNo":2,"description":"管理流动人口服务登记及跨区域协作事项。","networkZone":"政务外网(卫健专网)","platformName":"福建省全员人口计划生育服务与管理平台","runtimeStatus":"NORMAL","integrationNote":"服务地址与接入参数待配置","connectionStatus":"UNCONFIGURED"},{"id":"MOCK_APP_16","url":"https://p4.invalid/app/16","code":"WJ_APP_16","name":"福建省人口计生综合服务信息平台","status":"ENABLED","version":1,"category":"政务协同","sourceNo":16,"userType":"GOV","createdAt":"2026-09-16T00:00:00.000Z","sortOrder":16,"updatedAt":"2026-09-17T23:00:00.000Z","categoryId":"MOCK_CAT_2","platformId":"MOCK_PLATFORM_2","platformNo":2,"description":"汇集人口计生服务事项，支持综合查询与协同。","networkZone":"政务外网(卫健专网)","platformName":"福建省全员人口计划生育服务与管理平台","runtimeStatus":"NORMAL","integrationNote":"服务地址与接入参数待配置","connectionStatus":"UNCONFIGURED"},{"id":"MOCK_APP_17","url":"https://p4.invalid/app/17","code":"WJ_APP_17","name":"全员人口数据库药具发放服务管理","status":"ENABLED","version":1,"category":"政务协同","sourceNo":17,"userType":"BOTH","createdAt":"2026-09-16T00:00:00.000Z","sortOrder":17,"updatedAt":"2026-09-17T23:00:00.000Z","categoryId":"MOCK_CAT_2","platformId":"MOCK_PLATFORM_2","platformNo":2,"description":"管理药具需求、库存、发放登记与服务统计。","networkZone":"互联网","platformName":"福建省全员人口计划生育服务与管理平台","runtimeStatus":"NORMAL","integrationNote":"服务地址与接入参数待配置","connectionStatus":"UNCONFIGURED"},{"id":"MOCK_APP_18","url":"https://p4.invalid/app/18","code":"WJ_APP_18","name":"福建省互联网医院监管平台","status":"ENABLED","version":1,"category":"行业监管","sourceNo":18,"userType":"GOV","createdAt":"2026-09-16T00:00:00.000Z","sortOrder":18,"updatedAt":"2026-09-17T23:00:00.000Z","categoryId":"MOCK_CAT_3","platformId":"MOCK_PLATFORM_3","platformNo":3,"description":"汇集互联网医院信息，支持资质核验与诊疗监管。","networkZone":"政务外网","platformName":"福建省卫健委综合监管平台","runtimeStatus":"NORMAL","integrationNote":"服务地址与接入参数待配置","connectionStatus":"UNCONFIGURED"},{"id":"MOCK_APP_19","url":"https://p4.invalid/app/19","code":"WJ_APP_19","name":"省医改效果监测管理系统","status":"ENABLED","version":1,"category":"行业监管","sourceNo":19,"userType":"GOV","createdAt":"2026-09-16T00:00:00.000Z","sortOrder":19,"updatedAt":"2026-09-17T23:00:00.000Z","categoryId":"MOCK_CAT_3","platformId":"MOCK_PLATFORM_3","platformNo":3,"description":"管理医改指标填报、数据核验及改革成效分析。","networkZone":"政务外网(卫健专网)","platformName":"福建省卫健委综合监管平台","runtimeStatus":"NORMAL","integrationNote":"服务地址与接入参数待配置","connectionStatus":"UNCONFIGURED"},{"id":"MOCK_APP_20","url":"https://p4.invalid/app/20","code":"WJ_APP_20","name":"省属公立医院运营监管系统","status":"ENABLED","version":1,"category":"行业监管","sourceNo":20,"userType":"GOV","createdAt":"2026-09-16T00:00:00.000Z","sortOrder":20,"updatedAt":"2026-09-17T23:00:00.000Z","categoryId":"MOCK_CAT_3","platformId":"MOCK_PLATFORM_3","platformNo":3,"description":"汇集医院运营指标，支持运行监测与异常核查。","networkZone":"政务外网(卫健专网)","platformName":"福建省卫健委综合监管平台","runtimeStatus":"NORMAL","integrationNote":"服务地址与接入参数待配置","connectionStatus":"UNCONFIGURED"},{"id":"MOCK_APP_21","url":"https://p4.invalid/app/21","code":"WJ_APP_21","name":"福建省公立医院绩效考核系统","status":"ENABLED","version":1,"category":"行业监管","sourceNo":21,"userType":"GOV","createdAt":"2026-09-16T00:00:00.000Z","sortOrder":21,"updatedAt":"2026-09-17T23:00:00.000Z","categoryId":"MOCK_CAT_3","platformId":"MOCK_PLATFORM_3","platformNo":3,"description":"管理医院绩效填报、考核资料与评价结果。","networkZone":"互联网","platformName":"福建省卫健委综合监管平台","runtimeStatus":"NORMAL","integrationNote":"服务地址与接入参数待配置","connectionStatus":"UNCONFIGURED"},{"id":"MOCK_APP_22","url":"https://p4.invalid/app/22","code":"WJ_APP_22","name":"财务管理系统","status":"ENABLED","version":1,"category":"行业监管","sourceNo":22,"userType":"GOV","createdAt":"2026-09-16T00:00:00.000Z","sortOrder":22,"updatedAt":"2026-09-17T23:00:00.000Z","categoryId":"MOCK_CAT_3","platformId":"MOCK_PLATFORM_3","platformNo":3,"description":"管理财务报表、预算执行信息与收支核对。","networkZone":"政务外网","platformName":"福建省卫健委综合监管平台","runtimeStatus":"NORMAL","integrationNote":"服务地址与接入参数待配置","connectionStatus":"UNCONFIGURED"},{"id":"MOCK_APP_23","url":"https://p4.invalid/app/23","code":"WJ_APP_23","name":"医疗技术临床应用管理信息系统","status":"ENABLED","version":1,"category":"行业监管","sourceNo":23,"userType":"GOV","createdAt":"2026-09-16T00:00:00.000Z","sortOrder":23,"updatedAt":"2026-09-17T23:00:00.000Z","categoryId":"MOCK_CAT_3","platformId":"MOCK_PLATFORM_3","platformNo":3,"description":"管理医疗技术应用备案、质量信息与规范执行情况。","networkZone":"政务外网(卫健专网)","platformName":"福建省卫健委综合监管平台","runtimeStatus":"NORMAL","integrationNote":"服务地址与接入参数待配置","connectionStatus":"UNCONFIGURED"},{"id":"MOCK_APP_24","url":"https://p4.invalid/app/24","code":"WJ_APP_24","name":"住院医师专科医师培训及一体化系统","status":"ENABLED","version":1,"category":"培训考试","sourceNo":24,"userType":"BOTH","createdAt":"2026-09-16T00:00:00.000Z","sortOrder":24,"updatedAt":"2026-09-17T23:00:00.000Z","categoryId":"MOCK_CAT_4","platformId":"MOCK_PLATFORM_3","platformNo":3,"description":"管理医师培训报名、轮转安排与考核记录。","networkZone":"互联网","platformName":"福建省卫健委综合监管平台","runtimeStatus":"NORMAL","integrationNote":"服务地址与接入参数待配置","connectionStatus":"UNCONFIGURED"},{"id":"MOCK_APP_25","url":"https://p4.invalid/app/25","code":"WJ_APP_25","name":"福建省中医医师规范化培训管理平台","status":"ENABLED","version":1,"category":"培训考试","sourceNo":25,"userType":"BOTH","createdAt":"2026-09-16T00:00:00.000Z","sortOrder":25,"updatedAt":"2026-09-17T23:00:00.000Z","categoryId":"MOCK_CAT_4","platformId":"MOCK_PLATFORM_3","platformNo":3,"description":"管理中医医师培训计划、过程记录及结业考核。","networkZone":"互联网","platformName":"福建省卫健委综合监管平台","runtimeStatus":"NORMAL","integrationNote":"服务地址与接入参数待配置","connectionStatus":"UNCONFIGURED"},{"id":"MOCK_APP_26","url":"https://p4.invalid/app/26","code":"WJ_APP_26","name":"福建省中医医术确有专长人员医师资格考核报名系统","status":"ENABLED","version":1,"category":"培训考试","sourceNo":26,"userType":"BOTH","createdAt":"2026-09-16T00:00:00.000Z","sortOrder":26,"updatedAt":"2026-09-17T23:00:00.000Z","categoryId":"MOCK_CAT_4","platformId":"MOCK_PLATFORM_3","platformNo":3,"description":"管理中医专长医师考核报名、材料补正与资格审核。","networkZone":"互联网","platformName":"福建省卫健委综合监管平台","runtimeStatus":"NORMAL","integrationNote":"服务地址与接入参数待配置","connectionStatus":"UNCONFIGURED"},{"id":"MOCK_APP_27","url":"https://p4.invalid/app/27","code":"WJ_APP_27","name":"福建省卫生健康科技计划项目管理信息系统","status":"ENABLED","version":1,"category":"培训考试","sourceNo":27,"userType":"GOV","createdAt":"2026-09-16T00:00:00.000Z","sortOrder":27,"updatedAt":"2026-09-17T23:00:00.000Z","categoryId":"MOCK_CAT_4","platformId":"MOCK_PLATFORM_3","platformNo":3,"description":"管理科技项目申报、评审、过程检查及验收。","networkZone":"政务外网互联网区","platformName":"福建省卫健委综合监管平台","runtimeStatus":"NORMAL","integrationNote":"服务地址与接入参数待配置","connectionStatus":"UNCONFIGURED"},{"id":"MOCK_APP_28","url":"https://p4.invalid/app/28","code":"WJ_APP_28","name":"福建省卫生专业技术资格考试报名系统","status":"ENABLED","version":1,"category":"培训考试","sourceNo":28,"userType":"BOTH","createdAt":"2026-09-16T00:00:00.000Z","sortOrder":28,"updatedAt":"2026-09-17T23:00:00.000Z","categoryId":"MOCK_CAT_4","platformId":"MOCK_PLATFORM_3","platformNo":3,"description":"管理卫生资格考试报名、资料核验及通知。","networkZone":"互联网","platformName":"福建省卫健委综合监管平台","runtimeStatus":"NORMAL","integrationNote":"服务地址与接入参数待配置","connectionStatus":"UNCONFIGURED"},{"id":"MOCK_APP_29","url":"https://p4.invalid/app/29","code":"WJ_APP_29","name":"国家卫生健康信息统计直报系统","status":"ENABLED","version":1,"category":"行业监管","sourceNo":29,"userType":"GOV","createdAt":"2026-09-16T00:00:00.000Z","sortOrder":29,"updatedAt":"2026-09-17T23:00:00.000Z","categoryId":"MOCK_CAT_3","platformId":"MOCK_PLATFORM_3","platformNo":3,"description":"支持卫生统计报表填报、审核、汇总与直报。","networkZone":"互联网","platformName":"福建省卫健委综合监管平台","runtimeStatus":"NORMAL","integrationNote":"服务地址与接入参数待配置","connectionStatus":"UNCONFIGURED"},{"id":"MOCK_APP_30","url":"https://p4.invalid/app/30","code":"WJ_APP_30","name":"福建省集中消毒餐具追溯系统","status":"ENABLED","version":1,"category":"行业监管","sourceNo":30,"userType":"GOV","createdAt":"2026-09-16T00:00:00.000Z","sortOrder":30,"updatedAt":"2026-09-17T23:00:00.000Z","categoryId":"MOCK_CAT_3","platformId":"MOCK_PLATFORM_3","platformNo":3,"description":"管理消毒餐具批次、检验信息与流向追溯。","networkZone":"政务外网互联网区","platformName":"福建省卫健委综合监管平台","runtimeStatus":"NORMAL","integrationNote":"服务地址与接入参数待配置","connectionStatus":"UNCONFIGURED"},{"id":"MOCK_APP_31","url":"https://p4.invalid/app/31","code":"WJ_APP_31","name":"福建省职业病防治综合管理系统","status":"ENABLED","version":1,"category":"行业监管","sourceNo":31,"userType":"GOV","createdAt":"2026-09-16T00:00:00.000Z","sortOrder":31,"updatedAt":"2026-09-17T23:00:00.000Z","categoryId":"MOCK_CAT_3","platformId":"MOCK_PLATFORM_3","platformNo":3,"description":"汇集职业病防治信息，支持监测报告与防治协作。","networkZone":"政务外网互联网区","platformName":"福建省卫健委综合监管平台","runtimeStatus":"NORMAL","integrationNote":"服务地址与接入参数待配置","connectionStatus":"UNCONFIGURED"},{"id":"MOCK_APP_32","url":"https://p4.invalid/app/32","code":"WJ_APP_32","name":"福建省保健对象医疗管理信息系统","status":"ENABLED","version":1,"category":"行业监管","sourceNo":32,"userType":"GOV","createdAt":"2026-09-16T00:00:00.000Z","sortOrder":32,"updatedAt":"2026-09-17T23:00:00.000Z","categoryId":"MOCK_CAT_3","platformId":"MOCK_PLATFORM_4","platformNo":4,"description":"管理保健服务安排、医疗保障事项及服务记录。","networkZone":"政务外网(卫健专网)","platformName":"福建省保健对象医疗管理信息系统","runtimeStatus":"NORMAL","integrationNote":"服务地址与接入参数待配置","connectionStatus":"UNCONFIGURED"},{"id":"MOCK_APP_33","url":"https://p4.invalid/app/33","code":"WJ_APP_33","name":"福建省职业病与化学中毒预防控制中心门户网站","status":"ENABLED","version":1,"category":"行业监管","sourceNo":33,"userType":"BOTH","createdAt":"2026-09-16T00:00:00.000Z","sortOrder":33,"updatedAt":"2026-09-17T23:00:00.000Z","categoryId":"MOCK_CAT_3","platformId":"MOCK_PLATFORM_5","platformNo":5,"description":"发布职业病及化学中毒防治资讯、办事指引和健康知识。","networkZone":"政务外网互联网区","platformName":"省职控制中心门户网站","runtimeStatus":"NORMAL","integrationNote":"服务地址与接入参数待配置","connectionStatus":"UNCONFIGURED"},{"id":"MOCK_APP_34","url":"https://p4.invalid/app/34","code":"WJ_APP_34","name":"福建省卫生监督电子执法全过程记录系统","status":"ENABLED","version":1,"category":"卫生监督","sourceNo":34,"userType":"GOV","createdAt":"2026-09-16T00:00:00.000Z","sortOrder":34,"updatedAt":"2026-09-17T23:00:00.000Z","categoryId":"MOCK_CAT_5","platformId":"MOCK_PLATFORM_6","platformNo":6,"description":"管理卫生监督执法记录、证据索引与过程留痕。","networkZone":"政务外网公用网络区","platformName":"省卫监所综合管理系统","runtimeStatus":"NORMAL","integrationNote":"服务地址与接入参数待配置","connectionStatus":"UNCONFIGURED"},{"id":"MOCK_APP_35","url":"https://p4.invalid/app/35","code":"WJ_APP_35","name":"福建省医疗卫生信用信息归集系统","status":"ENABLED","version":1,"category":"卫生监督","sourceNo":35,"userType":"GOV","createdAt":"2026-09-16T00:00:00.000Z","sortOrder":35,"updatedAt":"2026-09-17T23:00:00.000Z","categoryId":"MOCK_CAT_5","platformId":"MOCK_PLATFORM_6","platformNo":6,"description":"归集医疗卫生信用信息，支持信用核验与监管查询。","networkZone":"互联网","platformName":"省卫监所综合管理系统","runtimeStatus":"NORMAL","integrationNote":"服务地址与接入参数待配置","connectionStatus":"UNCONFIGURED"},{"id":"MOCK_APP_36","url":"https://p4.invalid/app/36","code":"WJ_APP_36","name":"福建省医疗卫生不良执业记分系统","status":"ENABLED","version":1,"category":"卫生监督","sourceNo":36,"userType":"GOV","createdAt":"2026-09-16T00:00:00.000Z","sortOrder":36,"updatedAt":"2026-09-17T23:00:00.000Z","categoryId":"MOCK_CAT_5","platformId":"MOCK_PLATFORM_6","platformNo":6,"description":"管理不良执业行为登记、记分与整改记录。","networkZone":"互联网","platformName":"省卫监所综合管理系统","runtimeStatus":"NORMAL","integrationNote":"服务地址与接入参数待配置","connectionStatus":"UNCONFIGURED"},{"id":"MOCK_APP_37","url":"https://p4.invalid/app/37","code":"WJ_APP_37","name":"福建省诊所诊疗监督系统","status":"ENABLED","version":1,"category":"卫生监督","sourceNo":37,"userType":"GOV","createdAt":"2026-09-16T00:00:00.000Z","sortOrder":37,"updatedAt":"2026-09-17T23:00:00.000Z","categoryId":"MOCK_CAT_5","platformId":"MOCK_PLATFORM_6","platformNo":6,"description":"汇集诊所诊疗活动，支持合规核查与监督管理。","networkZone":"互联网","platformName":"省卫监所综合管理系统","runtimeStatus":"NORMAL","integrationNote":"服务地址与接入参数待配置","connectionStatus":"UNCONFIGURED"},{"id":"MOCK_APP_38","url":"https://p4.invalid/app/38","code":"WJ_APP_38","name":"福建省医疗服务资质检测系统","status":"ENABLED","version":1,"category":"卫生监督","sourceNo":38,"userType":"GOV","createdAt":"2026-09-16T00:00:00.000Z","sortOrder":38,"updatedAt":"2026-09-17T23:00:00.000Z","categoryId":"MOCK_CAT_5","platformId":"MOCK_PLATFORM_6","platformNo":6,"description":"核验医疗服务资质，记录检测及复核结果。","networkZone":"政务外网、互联网","platformName":"省卫监所综合管理系统","runtimeStatus":"ABNORMAL","integrationNote":"服务地址与接入参数待配置","connectionStatus":"UNCONFIGURED"},{"id":"MOCK_APP_39","url":"https://p4.invalid/app/39","code":"WJ_APP_39","name":"福建省食源性疾病省级平台系统","status":"ENABLED","version":1,"category":"疾病防控","sourceNo":39,"userType":"GOV","createdAt":"2026-09-16T00:00:00.000Z","sortOrder":39,"updatedAt":"2026-09-17T23:00:00.000Z","categoryId":"MOCK_CAT_6","platformId":"MOCK_PLATFORM_7","platformNo":7,"description":"管理食源性疾病监测报告、事件核查及分析。","networkZone":"政务外网","platformName":"省疾控中心综合管理系统","runtimeStatus":"NORMAL","integrationNote":"服务地址与接入参数待配置","connectionStatus":"UNCONFIGURED"},{"id":"MOCK_APP_40","url":"https://p4.invalid/app/40","code":"WJ_APP_40","name":"福建省疾病预防控制中心信息门户系统","status":"ENABLED","version":1,"category":"疾病防控","sourceNo":40,"userType":"GOV","createdAt":"2026-09-16T00:00:00.000Z","sortOrder":40,"updatedAt":"2026-09-17T23:00:00.000Z","categoryId":"MOCK_CAT_6","platformId":"MOCK_PLATFORM_7","platformNo":7,"description":"汇集疾控业务入口、工作通知与信息发布服务。","networkZone":"政务外网","platformName":"省疾控中心综合管理系统","runtimeStatus":"UNCONFIGURED","integrationNote":"服务地址与接入参数待配置","connectionStatus":"UNCONFIGURED"},{"id":"MOCK_APP_41","url":"https://p4.invalid/app/41","code":"WJ_APP_41","name":"福建省慢性病防控指标系统","status":"ENABLED","version":1,"category":"疾病防控","sourceNo":41,"userType":"GOV","createdAt":"2026-09-16T00:00:00.000Z","sortOrder":41,"updatedAt":"2026-09-17T23:00:00.000Z","categoryId":"MOCK_CAT_6","platformId":"MOCK_PLATFORM_7","platformNo":7,"description":"管理慢性病防控指标采集、质量核验与评估。","networkZone":"政务外网","platformName":"省疾控中心综合管理系统","runtimeStatus":"NORMAL","integrationNote":"服务地址与接入参数待配置","connectionStatus":"UNCONFIGURED"},{"id":"MOCK_APP_43","url":"https://p4.invalid/app/43","code":"WJ_APP_43","name":"福建省疫苗冷链监测系统","status":"DISABLED","version":1,"category":"疾病防控","sourceNo":43,"userType":"GOV","createdAt":"2026-09-16T00:00:00.000Z","sortOrder":43,"updatedAt":"2026-09-17T23:00:00.000Z","categoryId":"MOCK_CAT_6","platformId":"MOCK_PLATFORM_7","platformNo":7,"description":"监测疫苗储运温度、冷链设备运行及异常处置。","networkZone":"政务外网","platformName":"省疾控中心综合管理系统","runtimeStatus":"DISABLED","integrationNote":"服务地址与接入参数待配置","connectionStatus":"UNCONFIGURED"}],"logs":[{"id":"MOCK_2b73d5a0-274a-4c0f-8e8c-5d7abec9f29d","kind":"operation","name":"saveRules","actor":"周明","status":"SUCCESS","createdAt":"2026-09-18T17:28:40.527Z","description":"操作已记录"},{"id":"MOCK_c496be3c-525a-45fb-a2cb-8f9de1d0819c","kind":"operation","name":"阅读消息","actor":"陈宁","status":"SUCCESS","createdAt":"2026-09-18T16:32:04.310Z","description":"操作已记录"},{"id":"MOCK_4e439319-486c-4783-80a7-42586fe3bb3d","kind":"operation","name":"阅读消息","actor":"陈宁","status":"SUCCESS","createdAt":"2026-09-18T16:27:06.299Z","description":"操作已记录"},{"id":"MOCK_4ba878e2-9c3f-4aa2-a75c-bb9e85801f96","kind":"operation","name":"阅读公告","actor":"周明","status":"SUCCESS","createdAt":"2026-09-18T16:13:46.074Z","description":"操作已记录"},{"id":"MOCK_e04dccb7-b92e-468d-a4a0-2f8e97cd9f8d","kind":"operation","name":"阅读消息","actor":"周明","status":"SUCCESS","createdAt":"2026-09-18T16:13:40.360Z","description":"操作已记录"},{"id":"MOCK_2dece248-bb2a-4cba-83cd-91b40d0af110","kind":"operation","name":"阅读消息","actor":"周明","status":"SUCCESS","createdAt":"2026-09-18T16:12:43.994Z","description":"操作已记录"},{"id":"MOCK_e4a9f29f-6d10-4710-a1ec-b0958660ed4e","kind":"operation","name":"阅读消息","actor":"林晓","status":"SUCCESS","createdAt":"2026-09-18T15:58:30.221Z","description":"操作已记录"},{"id":"MOCK_2d023732-26ab-47a2-bb5c-8721fb6a967c","kind":"operation","name":"阅读消息","actor":"周明","status":"SUCCESS","createdAt":"2026-09-18T15:48:33.066Z","description":"操作已记录"},{"id":"MOCK_0a0e7116-0e04-45b3-b949-a20ee70d529d","kind":"operation","name":"阅读消息","actor":"周明","status":"SUCCESS","createdAt":"2026-09-18T15:48:12.994Z","description":"操作已记录"},{"id":"MOCK_884acd3b-4542-4d3d-8f34-5905adc49c24","kind":"operation","name":"阅读消息","actor":"陈宁","status":"SUCCESS","createdAt":"2026-09-18T15:31:44.193Z","description":"操作已记录"},{"id":"MOCK_2843e278-b1d6-4d45-b59f-1131dfff83db","kind":"operation","name":"阅读公告","actor":"林晓","status":"SUCCESS","createdAt":"2026-09-18T15:16:49.861Z","description":"操作已记录"},{"id":"MOCK_f294ee31-acf1-4398-8a02-4c64a37ce823","kind":"operation","name":"阅读消息","actor":"林晓","status":"SUCCESS","createdAt":"2026-09-18T15:16:22.835Z","description":"操作已记录"},{"id":"MOCK_78f447e0-eb76-4823-9d46-158ae7e41d16","kind":"operation","name":"阅读消息","actor":"林晓","status":"SUCCESS","createdAt":"2026-09-18T15:15:56.541Z","description":"操作已记录"},{"id":"MOCK_ff593f7d-4494-4a5b-bce9-c914f95ee40b","kind":"access","name":"访问应用","actor":"陈宁","status":"SUCCESS","createdAt":"2026-09-18T15:10:47.367Z","description":"操作已记录"},{"id":"MOCK_0cc46335-e3ca-4476-8d7f-60c8bfc97205","kind":"operation","name":"阅读公�����������","actor":"林晓","status":"SUCCESS","createdAt":"2026-09-18T15:06:02.548Z","description":"操作已记录"},{"id":"MOCK_470a1df7-5edc-4a0f-9774-2bef076c4992","kind":"operation","name":"阅读�������息","actor":"林晓","status":"SUCCESS","createdAt":"2026-09-18T15:05:14.890Z","description":"操作已记录"},{"id":"MOCK_475164e7-929a-4eeb-9605-566bcc6dc781","kind":"operation","name":"维护接入配置","actor":"周明","status":"SUCCESS","createdAt":"2026-09-18T14:50:14.759Z","description":"操作已记录"},{"id":"MOCK_e58008fb-fdb5-43be-8a36-d250771f7941","kind":"operation","name":"removeAnnouncement","actor":"周明","status":"SUCCESS","createdAt":"2026-09-18T14:50:13.407Z","description":"操作已记录"},{"id":"MOCK_811d2070-70df-4f56-a913-b8f63e567ca5","kind":"operation","name":"保存公告","actor":"周明","status":"SUCCESS","createdAt":"2026-09-18T14:50:12.746Z","description":"操作已记录"},{"id":"MOCK_4f4485cf-4e6e-4266-bd30-6d8e9d0bf80e","kind":"operation","name":"saveRules","actor":"周明","status":"SUCCESS","createdAt":"2026-09-18T14:50:12.064Z","description":"操作已记录"},{"id":"MOCK_c52da59a-23dc-4a00-a9b6-aa34a1767548","kind":"operation","name":"阅读消息","actor":"林晓","status":"SUCCESS","createdAt":"2026-09-18T14:49:35.187Z","description":"操作已记录"},{"id":"MOCK_4599fdec-fdd9-44f6-856d-e1190dc6f862","kind":"operation","name":"阅读公告","actor":"林晓","status":"SUCCESS","createdAt":"2026-09-18T14:49:28.247Z","description":"操作已记录"},{"id":"MOCK_404e4132-17b1-420e-a0fb-55a1b8859d07","kind":"operation","name":"阅读消息","actor":"林晓","status":"SUCCESS","createdAt":"2026-09-18T14:49:21.957Z","description":"操作已记录"},{"id":"MOCK_96877653-65d8-4071-9225-a23e2bfc2859","kind":"operation","name":"阅读公告","actor":"林晓","status":"SUCCESS","createdAt":"2026-09-18T14:49:16.768Z","description":"操作已记录"},{"id":"MOCK_54888ac6-7836-4a46-a949-3db8bf87a3d0","kind":"operation","name":"阅读公告","actor":"林晓","status":"SUCCESS","createdAt":"2026-09-18T14:49:12.945Z","description":"操作已记录"},{"id":"MOCK_7f447185-8be7-4141-8ffb-88436827f843","kind":"access","name":"���问应用","actor":"林晓","status":"SUCCESS","createdAt":"2026-09-18T14:48:29.518Z","description":"操作已记录"},{"id":"MOCK_LOG_login_0","kind":"login","name":"身份登录","actor":"林晓","appId":"MOCK_APP_1","status":"SUCCESS","userId":"MOCK_USER_1","appName":"福建省新生儿疾病筛查管理系统","version":1,"createdAt":"2026-09-18T00:00:00.000Z","requestId":"P4_REQUEST_0_0","updatedAt":"2026-09-17T23:00:00.000Z","description":"身份登录记录"},{"id":"MOCK_LOG_login_1","kind":"login","name":"身份登录","actor":"陈宁","appId":"MOCK_APP_2","status":"SUCCESS","userId":"MOCK_USER_2","appName":"福建省妇幼卫生信息系统","version":1,"createdAt":"2026-09-17T23:00:00.000Z","requestId":"P4_REQUEST_0_1","updatedAt":"2026-09-17T23:00:00.000Z","description":"身份登录记录"},{"id":"MOCK_LOG_login_2","kind":"login","name":"身份登录","actor":"周明","appId":"MOCK_APP_3","status":"SUCCESS","userId":"MOCK_ADMIN","appName":"福建省产前筛查与诊断管理系统","version":1,"createdAt":"2026-09-17T22:00:00.000Z","requestId":"P4_REQUEST_0_2","updatedAt":"2026-09-17T23:00:00.000Z","description":"身份登录记录"},{"id":"MOCK_LOG_login_3","kind":"login","name":"身份登录","actor":"郑颖","appId":"MOCK_APP_4","status":"SUCCESS","userId":"MOCK_EDITOR","appName":"福建省地中海贫血信息管理系统","version":1,"createdAt":"2026-09-17T21:00:00.000Z","requestId":"P4_REQUEST_0_3","updatedAt":"2026-09-17T23:00:00.000Z","description":"身份登录记录"},{"id":"MOCK_LOG_auth_0","kind":"auth","name":"访问权限核验","actor":"林晓","appId":"MOCK_APP_1","status":"SUCCESS","userId":"MOCK_USER_1","appName":"福建省新生儿疾病筛查管理系统","version":1,"createdAt":"2026-09-17T20:00:00.000Z","requestId":"P4_REQUEST_1_0","updatedAt":"2026-09-17T23:00:00.000Z","description":"访问权限核验记录"},{"id":"MOCK_LOG_auth_1","kind":"auth","name":"访问权限核验","actor":"陈宁","appId":"MOCK_APP_2","status":"SUCCESS","userId":"MOCK_USER_2","appName":"福建省妇幼卫生信息系统","version":1,"createdAt":"2026-09-17T19:00:00.000Z","requestId":"P4_REQUEST_1_1","updatedAt":"2026-09-17T23:00:00.000Z","description":"访问权限核验记录"},{"id":"MOCK_LOG_auth_2","kind":"auth","name":"访问权限核验","actor":"周明","appId":"MOCK_APP_3","status":"SUCCESS","userId":"MOCK_ADMIN","appName":"福建省产前筛查与诊断管理系统","version":1,"createdAt":"2026-09-17T18:00:00.000Z","requestId":"P4_REQUEST_1_2","updatedAt":"2026-09-17T23:00:00.000Z","description":"访问权限核验记录"},{"id":"MOCK_LOG_auth_3","kind":"auth","name":"访问权限核验","actor":"郑颖","appId":"MOCK_APP_4","status":"DENIED","userId":"MOCK_EDITOR","appName":"福建省地中海贫血信息���理系统","version":1,"createdAt":"2026-09-17T17:00:00.000Z","requestId":"P4_REQUEST_1_3","updatedAt":"2026-09-17T23:00:00.000Z","description":"访问权限核验记录"},{"id":"MOCK_LOG_access_0","kind":"access","name":"应用访问","actor":"林晓","appId":"MOCK_APP_1","status":"SUCCESS","userId":"MOCK_USER_1","appName":"福建省新生儿疾病筛查管理系统","version":1,"createdAt":"2026-09-17T16:00:00.000Z","requestId":"P4_REQUEST_2_0","updatedAt":"2026-09-17T23:00:00.000Z","description":"应用访问记录"},{"id":"MOCK_LOG_access_1","kind":"access","name":"应用访问","actor":"陈宁","appId":"MOCK_APP_2","status":"SUCCESS","userId":"MOCK_USER_2","appName":"福建省妇幼卫生信息系统","version":1,"createdAt":"2026-09-17T15:00:00.000Z","requestId":"P4_REQUEST_2_1","updatedAt":"2026-09-17T23:00:00.000Z","description":"应用访问记录"},{"id":"MOCK_LOG_access_2","kind":"access","name":"应用访问","actor":"周明","appId":"MOCK_APP_3","status":"SUCCESS","userId":"MOCK_ADMIN","appName":"福建省产前筛查与诊断管理系统","version":1,"createdAt":"2026-09-17T14:00:00.000Z","requestId":"P4_REQUEST_2_2","updatedAt":"2026-09-17T23:00:00.000Z","description":"应用访问记录"},{"id":"MOCK_LOG_access_3","kind":"access","name":"应用访问","actor":"郑颖","appId":"MOCK_APP_4","status":"SUCCESS","userId":"MOCK_EDITOR","appName":"福建省地中海贫血信息管理系统","version":1,"createdAt":"2026-09-17T13:00:00.000Z","requestId":"P4_REQUEST_2_3","updatedAt":"2026-09-17T23:00:00.000Z","description":"应用访问记录"},{"id":"MOCK_LOG_operation_0","kind":"operation","name":"公告维护","actor":"林晓","appId":"MOCK_APP_1","status":"SUCCESS","userId":"MOCK_USER_1","appName":"福建省新生儿疾病筛查管理系统","version":1,"createdAt":"2026-09-17T12:00:00.000Z","requestId":"P4_REQUEST_3_0","updatedAt":"2026-09-17T23:00:00.000Z","description":"公告维护记录"},{"id":"MOCK_LOG_operation_1","kind":"operation","name":"公告维护","actor":"陈宁","appId":"MOCK_APP_2","status":"SUCCESS","userId":"MOCK_USER_2","appName":"福建省妇幼卫生信息系统","version":1,"createdAt":"2026-09-17T11:00:00.000Z","requestId":"P4_REQUEST_3_1","updatedAt":"2026-09-17T23:00:00.000Z","description":"公告维护记录"},{"id":"MOCK_LOG_operation_2","kind":"operation","name":"公告维护","actor":"周明","appId":"MOCK_APP_3","status":"SUCCESS","userId":"MOCK_ADMIN","appName":"福建省产前筛查与诊断管理系统","version":1,"createdAt":"2026-09-17T10:00:00.000Z","requestId":"P4_REQUEST_3_2","updatedAt":"2026-09-17T23:00:00.000Z","description":"公告维护记录"},{"id":"MOCK_LOG_operation_3","kind":"operation","name":"公告维护","actor":"郑颖","appId":"MOCK_APP_4","status":"SUCCESS","userId":"MOCK_EDITOR","appName":"福建省地中海贫血信息管理系统","version":1,"createdAt":"2026-09-17T09:00:00.000Z","requestId":"P4_REQUEST_3_3","updatedAt":"2026-09-17T23:00:00.000Z","description":"公告维护记录"},{"id":"MOCK_LOG_api_0","kind":"api","name":"数据接收","actor":"林晓","appId":"MOCK_APP_1","status":"SUCCESS","userId":"MOCK_USER_1","appName":"福建省新生儿疾病筛查管理系统","version":1,"createdAt":"2026-09-17T08:00:00.000Z","requestId":"P4_REQUEST_4_0","updatedAt":"2026-09-17T23:00:00.000Z","description":"数据接收记录"},{"id":"MOCK_LOG_api_1","kind":"api","name":"数据接收","actor":"陈宁","appId":"MOCK_APP_2","status":"SUCCESS","userId":"MOCK_USER_2","appName":"福建省妇幼卫生信息系统","version":1,"createdAt":"2026-09-17T07:00:00.000Z","requestId":"P4_REQUEST_4_1","updatedAt":"2026-09-17T23:00:00.000Z","description":"数据接收记录"},{"id":"MOCK_LOG_api_2","kind":"api","name":"数据接收","actor":"周明","appId":"MOCK_APP_3","status":"SUCCESS","userId":"MOCK_ADMIN","appName":"福建省产前筛查与诊断管理系统","version":1,"createdAt":"2026-09-17T06:00:00.000Z","requestId":"P4_REQUEST_4_2","updatedAt":"2026-09-17T23:00:00.000Z","description":"数据接收记录"},{"id":"MOCK_LOG_api_3","kind":"api","name":"数据接收","actor":"郑颖","appId":"MOCK_APP_4","status":"SUCCESS","userId":"MOCK_EDITOR","appName":"福建省地中海贫血信息管理系统","version":1,"createdAt":"2026-09-17T05:00:00.000Z","requestId":"P4_REQUEST_4_3","updatedAt":"2026-09-17T23:00:00.000Z","description":"数据接收记录"},{"id":"MOCK_LOG_error_0","kind":"error","name":"接入异常","actor":"林晓","appId":"MOCK_APP_1","status":"FAILURE","userId":"MOCK_USER_1","appName":"福建省新生儿疾病筛查管理系统","version":1,"createdAt":"2026-09-17T04:00:00.000Z","requestId":"P4_REQUEST_5_0","updatedAt":"2026-09-17T23:00:00.000Z","description":"接入参数未配置，需核对接口资料"},{"id":"MOCK_LOG_error_1","kind":"error","name":"接入异常","actor":"陈宁","appId":"MOCK_APP_2","status":"FAILURE","userId":"MOCK_USER_2","appName":"福建省妇幼卫生信息系统","version":1,"createdAt":"2026-09-17T03:00:00.000Z","requestId":"P4_REQUEST_5_1","updatedAt":"2026-09-17T23:00:00.000Z","description":"接入参数未配置，需核对接口资料"},{"id":"MOCK_LOG_error_2","kind":"error","name":"接入异常","actor":"周明","appId":"MOCK_APP_3","status":"FAILURE","userId":"MOCK_ADMIN","appName":"福建省产前筛查与诊断管理系统","version":1,"createdAt":"2026-09-17T02:00:00.000Z","requestId":"P4_REQUEST_5_2","updatedAt":"2026-09-17T23:00:00.000Z","description":"接入参数未配置，需核对接口资料"},{"id":"MOCK_LOG_error_3","kind":"error","name":"接入异常","actor":"郑颖","appId":"MOCK_APP_4","status":"FAILURE","userId":"MOCK_EDITOR","appName":"福建省地中海贫血信息管理系统","version":1,"createdAt":"2026-09-17T01:00:00.000Z","requestId":"P4_REQUEST_5_3","updatedAt":"2026-09-17T23:00:00.000Z","description":"接入参数未配置，需核对接口资料"}],"roles":[{"id":"ROLE_SUPER","scopes":["super","application","integration","announcement","audit","identity"],"status":"ENABLED","builtIn":true,"version":1,"roleCode":"PORTAL_SUPER_ADMIN","roleName":"门户超级管理员","createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","description":"负责门户系统自身的用户、角色、应用、集成、内容、审计等管理，不授予子系统业务权限。"},{"id":"ROLE_APP","scopes":["application"],"status":"ENABLED","builtIn":true,"version":1,"roleCode":"PORTAL_APP_ADMIN","roleName":"应用管理员","createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","description":"维护门户应用目录、分类及应用接入信息。"},{"id":"ROLE_CONTENT","scopes":["announcement"],"status":"ENABLED","builtIn":true,"version":1,"roleCode":"PORTAL_CONTENT_ADMIN","roleName":"内容管理员","createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","description":"维护通知公告等门户内容。"},{"id":"ROLE_INTEGRATION","scopes":["integration"],"status":"ENABLED","builtIn":true,"version":1,"roleCode":"PORTAL_INTEGRATION_ADMIN","roleName":"集成管理员","createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","description":"维护SSO、待办、消息等集成配置及运行监控。"},{"id":"ROLE_IDENTITY","scopes":["identity"],"status":"ENABLED","builtIn":true,"version":1,"roleCode":"PORTAL_IDENTITY_ADMIN","roleName":"身份映射管理员","createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","description":"维护统一身份索引与子系统账号映射。"},{"id":"ROLE_AUDIT","scopes":["audit"],"status":"ENABLED","builtIn":true,"version":1,"roleCode":"PORTAL_AUDITOR","roleName":"审计员","createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","description":"查看门户登录、访问、操作、接口及异常日志。"}],"todos":[{"id":"MOCK_TODO_0_0","url":"https://p4.invalid/app/1","appId":"MOCK_APP_1","dueAt":"2026-09-17T23:00:00.000Z","title":"核对服务申请资料","status":"PENDING","userId":"MOCK_USER_1","appName":"福建省新生儿疾病筛查管理系统","summary":"福建省新生儿疾病筛查管理系统：核对服务申请资料。请在来源系统查看业务详情。","version":1,"priority":"HIGH","createdAt":"2026-09-17T22:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","terminalAt":null,"businessType":"服务事项","sourceTodoId":"P4_TODO_0_0","sourceRevision":1},{"id":"MOCK_TODO_0_1","url":"https://p4.invalid/app/2","appId":"MOCK_APP_2","dueAt":"2026-09-17T22:00:00.000Z","title":"补充业务登记信息","status":"PENDING","userId":"MOCK_USER_1","appName":"福建省妇幼卫生信息系统","summary":"福建省妇幼卫生信息系统：补充业务登记信息。请在来源系统查看业务详情。","version":1,"priority":"MEDIUM","createdAt":"2026-09-17T21:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","terminalAt":null,"businessType":"服务事项","sourceTodoId":"P4_TODO_0_1","sourceRevision":1},{"id":"MOCK_TODO_0_2","url":"https://p4.invalid/app/3","appId":"MOCK_APP_3","dueAt":"2026-09-17T21:00:00.000Z","title":"确认服务安排","status":"PENDING","userId":"MOCK_USER_1","appName":"福建省产前筛查与诊断管理系统","summary":"福建省产前筛查与诊断管理系统：确认服务安排。请在来源系统查看业务详情。","version":1,"priority":"LOW","createdAt":"2026-09-17T20:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","terminalAt":null,"businessType":"服务事项","sourceTodoId":"P4_TODO_0_2","sourceRevision":1},{"id":"MOCK_TODO_0_3","url":"https://p4.invalid/app/4","appId":"MOCK_APP_4","dueAt":"2026-09-18T12:00:00.000Z","title":"查看材料核验意见","status":"PENDING","userId":"MOCK_USER_1","appName":"福建省地中海贫血信息管理系统","summary":"福建省地中海贫血信息管理系统：查看材料核验意见。请在来源系统查看业务详情。","version":1,"priority":"HIGH","createdAt":"2026-09-17T19:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","terminalAt":null,"businessType":"服务事项","sourceTodoId":"P4_TODO_0_3","sourceRevision":1},{"id":"MOCK_TODO_0_4","url":"https://p4.invalid/app/5","appId":"MOCK_APP_5","dueAt":"2026-09-18T16:00:00.000Z","title":"核对信息更新内容","status":"PENDING","userId":"MOCK_USER_1","appName":"福建省慢病报告与管理系统","summary":"福建省慢病报告与管理系统：核对信息更新内容。请在来源系统查看业务详情。","version":1,"priority":"MEDIUM","createdAt":"2026-09-17T18:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","terminalAt":null,"businessType":"服务事项","sourceTodoId":"P4_TODO_0_4","sourceRevision":1},{"id":"MOCK_TODO_0_5","url":"https://p4.invalid/app/6","appId":"MOCK_APP_6","dueAt":"2026-09-18T20:00:00.000Z","title":"确认事项办理进度","status":"PENDING","userId":"MOCK_USER_1","appName":"福建省区域影像平台","summary":"福建省区域影像平台：确认事项办理进度。请在来源系统查看业务详情。","version":1,"priority":"LOW","createdAt":"2026-09-17T17:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","terminalAt":null,"businessType":"服务事项","sourceTodoId":"P4_TODO_0_5","sourceRevision":1},{"id":"MOCK_TODO_0_6","url":"https://p4.invalid/app/11","appId":"MOCK_APP_11","dueAt":"2026-09-19T00:00:00.000Z","title":"完善服务联系说明","status":"PENDING","userId":"MOCK_USER_1","appName":"福建省免疫规划管理信息系统","summary":"福建省免疫规划管理信息系统：完善服务联系说明。请在来源系统查看业务详情。","version":1,"priority":"HIGH","createdAt":"2026-09-17T16:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","terminalAt":null,"businessType":"服务事项","sourceTodoId":"P4_TODO_0_6","sourceRevision":1},{"id":"MOCK_TODO_0_7","url":"https://p4.invalid/app/12","appId":"MOCK_APP_12","dueAt":"2026-09-19T04:00:00.000Z","title":"查看后续办理要求","status":"PENDING","userId":"MOCK_USER_1","appName":"中医馆健康信息系统","summary":"中医馆健康信息系统：查看后续办理要求。请在来源系统查看业务详情。","version":1,"priority":"MEDIUM","createdAt":"2026-09-17T15:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","terminalAt":null,"businessType":"服务事项","sourceTodoId":"P4_TODO_0_7","sourceRevision":1},{"id":"MOCK_TODO_0_8","url":"https://p4.invalid/app/1","appId":"MOCK_APP_1","dueAt":"2026-09-19T08:00:00.000Z","title":"资料核验已完成","status":"COMPLETED","userId":"MOCK_USER_1","appName":"福建省新生儿疾病筛查管理系统","summary":"福建省新生儿疾病筛查管理系统：资料核验已完成。请在来源系统查看业务详情。","version":1,"priority":"LOW","createdAt":"2026-09-17T14:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","terminalAt":"2026-09-17T23:00:00.000Z","businessType":"服务事项","sourceTodoId":"P4_TODO_0_8","sourceRevision":2},{"id":"MOCK_TODO_0_9","url":"https://p4.invalid/app/2","appId":"MOCK_APP_2","dueAt":"2026-09-19T12:00:00.000Z","title":"业务申请已撤回","status":"WITHDRAWN","userId":"MOCK_USER_1","appName":"福建省妇幼卫生信息系统","summary":"福建省妇幼卫生信息系统：业务申请已撤回。请在来源系统查看业务详情。","version":1,"priority":"HIGH","createdAt":"2026-09-17T13:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","terminalAt":"2026-09-17T23:00:00.000Z","businessType":"服务事项","sourceTodoId":"P4_TODO_0_9","sourceRevision":2},{"id":"MOCK_TODO_0_10","url":"https://p4.invalid/app/3","appId":"MOCK_APP_3","dueAt":"2026-09-19T16:00:00.000Z","title":"办理期限已结束","status":"EXPIRED","userId":"MOCK_USER_1","appName":"福建省产前筛查与诊断管理系统","summary":"福建省产前筛查与诊断管理系统：办理期限已结束。请在来源系统查看业务详情。","version":1,"priority":"MEDIUM","createdAt":"2026-09-17T12:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","terminalAt":"2026-09-17T23:00:00.000Z","businessType":"服务事项","sourceTodoId":"P4_TODO_0_10","sourceRevision":2},{"id":"MOCK_TODO_1_0","url":"https://p4.invalid/app/1","appId":"MOCK_APP_1","dueAt":"2026-09-17T23:00:00.000Z","title":"核对服务申请资料","status":"PENDING","userId":"MOCK_USER_2","appName":"福建省新生儿疾病筛查管理系统","summary":"福建省新生儿疾病筛查管理系统：核对服务申请资料。请在来源系统查看业务详情。","version":1,"priority":"HIGH","createdAt":"2026-09-17T22:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","terminalAt":null,"businessType":"服务事项","sourceTodoId":"P4_TODO_1_0","sourceRevision":1},{"id":"MOCK_TODO_1_1","url":"https://p4.invalid/app/2","appId":"MOCK_APP_2","dueAt":"2026-09-17T22:00:00.000Z","title":"补充业务登记信息","status":"PENDING","userId":"MOCK_USER_2","appName":"福建省妇幼卫生信息系统","summary":"福建省妇幼卫生信息系统：补充业务登记信息。请在来源系统查看业务详情。","version":1,"priority":"MEDIUM","createdAt":"2026-09-17T21:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","terminalAt":null,"businessType":"服务事项","sourceTodoId":"P4_TODO_1_1","sourceRevision":1},{"id":"MOCK_TODO_1_2","url":"https://p4.invalid/app/3","appId":"MOCK_APP_3","dueAt":"2026-09-17T21:00:00.000Z","title":"确认服务安排","status":"PENDING","userId":"MOCK_USER_2","appName":"福建省产前筛查与诊断管理系统","summary":"福建省产前筛查与诊断管理系统：确认服务安排。请在来源系统查看业务详情。","version":1,"priority":"LOW","createdAt":"2026-09-17T20:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","terminalAt":null,"businessType":"服务事项","sourceTodoId":"P4_TODO_1_2","sourceRevision":1},{"id":"MOCK_TODO_1_3","url":"https://p4.invalid/app/4","appId":"MOCK_APP_4","dueAt":"2026-09-18T12:00:00.000Z","title":"查看材料核验意见","status":"PENDING","userId":"MOCK_USER_2","appName":"福建省地中海贫血信息管理系统","summary":"福建省地中海贫血信息管理系统：查看材料核验意见。请在来源系统查看业务详情。","version":1,"priority":"HIGH","createdAt":"2026-09-17T19:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","terminalAt":null,"businessType":"服务事项","sourceTodoId":"P4_TODO_1_3","sourceRevision":1},{"id":"MOCK_TODO_1_4","url":"https://p4.invalid/app/5","appId":"MOCK_APP_5","dueAt":"2026-09-18T16:00:00.000Z","title":"核对信息更新内容","status":"PENDING","userId":"MOCK_USER_2","appName":"福建省慢病报告与管理系统","summary":"福建省慢病报告与管理系统：核对信息更新内容。请在来源系统查看业务详情。","version":1,"priority":"MEDIUM","createdAt":"2026-09-17T18:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","terminalAt":null,"businessType":"服务事项","sourceTodoId":"P4_TODO_1_4","sourceRevision":1},{"id":"MOCK_TODO_1_5","url":"https://p4.invalid/app/6","appId":"MOCK_APP_6","dueAt":"2026-09-18T20:00:00.000Z","title":"确认事项办理进度","status":"PENDING","userId":"MOCK_USER_2","appName":"福建省区域影像平台","summary":"福建省区域影像平台：确认事项办理进度。请在来源系统查看业务详情。","version":1,"priority":"LOW","createdAt":"2026-09-17T17:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","terminalAt":null,"businessType":"服务事项","sourceTodoId":"P4_TODO_1_5","sourceRevision":1},{"id":"MOCK_TODO_1_6","url":"https://p4.invalid/app/7","appId":"MOCK_APP_7","dueAt":"2026-09-19T00:00:00.000Z","title":"完善服务联系说明","status":"PENDING","userId":"MOCK_USER_2","appName":"质控评分系统","summary":"质控评分系统：完善服务联系说明。请在来源系统查看业务详情。","version":1,"priority":"HIGH","createdAt":"2026-09-17T16:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","terminalAt":null,"businessType":"服务事项","sourceTodoId":"P4_TODO_1_6","sourceRevision":1},{"id":"MOCK_TODO_1_7","url":"https://p4.invalid/app/8","appId":"MOCK_APP_8","dueAt":"2026-09-19T04:00:00.000Z","title":"查看后续办理要求","status":"PENDING","userId":"MOCK_USER_2","appName":"省级平台决策支持展示系统","summary":"省级平台决策支持展示系统：查看后续办理要求。请在来源系统查看业务详情。","version":1,"priority":"MEDIUM","createdAt":"2026-09-17T15:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","terminalAt":null,"businessType":"服务事项","sourceTodoId":"P4_TODO_1_7","sourceRevision":1},{"id":"MOCK_TODO_1_8","url":"https://p4.invalid/app/1","appId":"MOCK_APP_1","dueAt":"2026-09-19T08:00:00.000Z","title":"资料核验已完成","status":"COMPLETED","userId":"MOCK_USER_2","appName":"福建省新生儿疾病筛查管理系统","summary":"福建省新生儿疾病筛查管理系统：资料核验已完成。请在来源系统查看业务详情。","version":1,"priority":"LOW","createdAt":"2026-09-17T14:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","terminalAt":"2026-09-17T23:00:00.000Z","businessType":"服务事项","sourceTodoId":"P4_TODO_1_8","sourceRevision":2},{"id":"MOCK_TODO_1_9","url":"https://p4.invalid/app/2","appId":"MOCK_APP_2","dueAt":"2026-09-19T12:00:00.000Z","title":"业务申请已撤回","status":"WITHDRAWN","userId":"MOCK_USER_2","appName":"福建省妇幼卫生信息系统","summary":"福建省妇幼卫生信息系统：业务申请已撤回。请在来源系统查看业务详情。","version":1,"priority":"HIGH","createdAt":"2026-09-17T13:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","terminalAt":"2026-09-17T23:00:00.000Z","businessType":"服务事项","sourceTodoId":"P4_TODO_1_9","sourceRevision":2},{"id":"MOCK_TODO_1_10","url":"https://p4.invalid/app/3","appId":"MOCK_APP_3","dueAt":"2026-09-19T16:00:00.000Z","title":"办理期限已结束","status":"EXPIRED","userId":"MOCK_USER_2","appName":"福建省产前筛查与诊断管理系统","summary":"福建省产前筛查与诊断管理系统：办理期限已结束。请在来源系统查看业务详情。","version":1,"priority":"MEDIUM","createdAt":"2026-09-17T12:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","terminalAt":"2026-09-17T23:00:00.000Z","businessType":"服务事项","sourceTodoId":"P4_TODO_1_10","sourceRevision":2},{"id":"MOCK_TODO_2_0","url":"https://p4.invalid/app/1","appId":"MOCK_APP_1","dueAt":"2026-09-17T23:00:00.000Z","title":"核对服务申请资料","status":"PENDING","userId":"MOCK_ADMIN","appName":"福建省新生儿疾病筛查管理系统","summary":"福建省新生儿疾病筛查管理系统：核对服务申请资料。请在来源系统查看业务详情。","version":1,"priority":"HIGH","createdAt":"2026-09-17T22:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","terminalAt":null,"businessType":"服务事项","sourceTodoId":"P4_TODO_2_0","sourceRevision":1},{"id":"MOCK_TODO_2_1","url":"https://p4.invalid/app/2","appId":"MOCK_APP_2","dueAt":"2026-09-17T22:00:00.000Z","title":"补充业务登记信息","status":"PENDING","userId":"MOCK_ADMIN","appName":"福建省妇幼卫生信息系统","summary":"福建省妇幼卫生信息系统：补充业务登记信息。请在来源系统查看业务详情。","version":1,"priority":"MEDIUM","createdAt":"2026-09-17T21:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","terminalAt":null,"businessType":"服务事项","sourceTodoId":"P4_TODO_2_1","sourceRevision":1},{"id":"MOCK_TODO_2_2","url":"https://p4.invalid/app/3","appId":"MOCK_APP_3","dueAt":"2026-09-17T21:00:00.000Z","title":"确认服务安排","status":"PENDING","userId":"MOCK_ADMIN","appName":"福建省产前筛查与诊断管理系统","summary":"福建省产前筛查与诊断管理系统：确认服务安排。请在来源系统查看业务详情。","version":1,"priority":"LOW","createdAt":"2026-09-17T20:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","terminalAt":null,"businessType":"服务事项","sourceTodoId":"P4_TODO_2_2","sourceRevision":1},{"id":"MOCK_TODO_2_3","url":"https://p4.invalid/app/4","appId":"MOCK_APP_4","dueAt":"2026-09-18T12:00:00.000Z","title":"查看材料核验意见","status":"PENDING","userId":"MOCK_ADMIN","appName":"福建省地中海贫血信息管理系统","summary":"福建省地中海贫血信息管理系统：查看材料核验意见。请在来源系统查看业务详情。","version":1,"priority":"HIGH","createdAt":"2026-09-17T19:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","terminalAt":null,"businessType":"服务事项","sourceTodoId":"P4_TODO_2_3","sourceRevision":1},{"id":"MOCK_TODO_2_4","url":"https://p4.invalid/app/5","appId":"MOCK_APP_5","dueAt":"2026-09-18T16:00:00.000Z","title":"核对信息更新内容","status":"PENDING","userId":"MOCK_ADMIN","appName":"福建省慢病报告与管理系统","summary":"福建省慢病报告与管理系统：核对信息更新内容。请在来源系统查看业务详情。","version":1,"priority":"MEDIUM","createdAt":"2026-09-17T18:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","terminalAt":null,"businessType":"服务事项","sourceTodoId":"P4_TODO_2_4","sourceRevision":1},{"id":"MOCK_TODO_2_5","url":"https://p4.invalid/app/6","appId":"MOCK_APP_6","dueAt":"2026-09-18T20:00:00.000Z","title":"确认事项办理进度","status":"PENDING","userId":"MOCK_ADMIN","appName":"福建省区域影像平台","summary":"福建省区域影像平台：确认事项办理进度。请在来源系统查看业务详情。","version":1,"priority":"LOW","createdAt":"2026-09-17T17:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","terminalAt":null,"businessType":"服务事项","sourceTodoId":"P4_TODO_2_5","sourceRevision":1},{"id":"MOCK_TODO_2_6","url":"https://p4.invalid/app/7","appId":"MOCK_APP_7","dueAt":"2026-09-19T00:00:00.000Z","title":"完善服务联系说明","status":"PENDING","userId":"MOCK_ADMIN","appName":"质控评分系统","summary":"质控评分系统：完善服务联系说明。请在来源系统查看业务详情。","version":1,"priority":"HIGH","createdAt":"2026-09-17T16:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","terminalAt":null,"businessType":"服务事项","sourceTodoId":"P4_TODO_2_6","sourceRevision":1},{"id":"MOCK_TODO_2_7","url":"https://p4.invalid/app/8","appId":"MOCK_APP_8","dueAt":"2026-09-19T04:00:00.000Z","title":"查看后续办理要求","status":"PENDING","userId":"MOCK_ADMIN","appName":"省级平台决策支持展示系统","summary":"省级平台决策支持展示系统：查看后续办理要求。请在来源系统查看业务详情。","version":1,"priority":"MEDIUM","createdAt":"2026-09-17T15:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","terminalAt":null,"businessType":"服务事项","sourceTodoId":"P4_TODO_2_7","sourceRevision":1},{"id":"MOCK_TODO_2_8","url":"https://p4.invalid/app/1","appId":"MOCK_APP_1","dueAt":"2026-09-19T08:00:00.000Z","title":"资料核验已完成","status":"COMPLETED","userId":"MOCK_ADMIN","appName":"福建省新生儿疾病筛查管理系统","summary":"福建省新生儿疾病筛查管理系统：资料核验已完成。请在来源系统查看业务详情。","version":1,"priority":"LOW","createdAt":"2026-09-17T14:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","terminalAt":"2026-09-17T23:00:00.000Z","businessType":"服务事项","sourceTodoId":"P4_TODO_2_8","sourceRevision":2},{"id":"MOCK_TODO_2_9","url":"https://p4.invalid/app/2","appId":"MOCK_APP_2","dueAt":"2026-09-19T12:00:00.000Z","title":"业务申请已撤回","status":"WITHDRAWN","userId":"MOCK_ADMIN","appName":"福建省妇幼卫生信息系统","summary":"福建省妇幼卫生信息系统：业务申请已撤回。请在来源系统查看业务详情。","version":1,"priority":"HIGH","createdAt":"2026-09-17T13:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","terminalAt":"2026-09-17T23:00:00.000Z","businessType":"服务事项","sourceTodoId":"P4_TODO_2_9","sourceRevision":2},{"id":"MOCK_TODO_2_10","url":"https://p4.invalid/app/3","appId":"MOCK_APP_3","dueAt":"2026-09-19T16:00:00.000Z","title":"办理期限已结束","status":"EXPIRED","userId":"MOCK_ADMIN","appName":"福建省产前筛查与诊断管理系统","summary":"福建省产前筛查与诊断管理系统：办理期限已结束。请在来源系统查看业务详情。","version":1,"priority":"MEDIUM","createdAt":"2026-09-17T12:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","terminalAt":"2026-09-17T23:00:00.000Z","businessType":"服务事项","sourceTodoId":"P4_TODO_2_10","sourceRevision":2},{"id":"MOCK_TODO_3_0","url":"https://p4.invalid/app/1","appId":"MOCK_APP_1","dueAt":"2026-09-17T23:00:00.000Z","title":"核对服务申请资料","status":"PENDING","userId":"MOCK_EDITOR","appName":"福建省新生儿疾病筛查管理系统","summary":"福建省新生儿疾病筛查管理系统：核对服务申请��料。请在来源系统查看业务详情。","version":1,"priority":"HIGH","createdAt":"2026-09-17T22:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","terminalAt":null,"businessType":"服务事���","sourceTodoId":"P4_TODO_3_0","sourceRevision":1},{"id":"MOCK_TODO_3_1","url":"https://p4.invalid/app/2","appId":"MOCK_APP_2","dueAt":"2026-09-17T22:00:00.000Z","title":"补充业务登记信息","status":"PENDING","userId":"MOCK_EDITOR","appName":"福建省妇幼卫生信息系统","summary":"福建省妇幼卫生信息系统：补充业务登记信息。请在来源系统查看业务详情。","version":1,"priority":"MEDIUM","createdAt":"2026-09-17T21:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","terminalAt":null,"businessType":"服务事项","sourceTodoId":"P4_TODO_3_1","sourceRevision":1},{"id":"MOCK_TODO_3_2","url":"https://p4.invalid/app/3","appId":"MOCK_APP_3","dueAt":"2026-09-17T21:00:00.000Z","title":"确认服务安排","status":"PENDING","userId":"MOCK_EDITOR","appName":"福建省产前筛查与诊断管理系统","summary":"福建省产前筛查与诊断管理系统：确认服务安排。请在来源系统查看业务详情。","version":1,"priority":"LOW","createdAt":"2026-09-17T20:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","terminalAt":null,"businessType":"服务事项","sourceTodoId":"P4_TODO_3_2","sourceRevision":1},{"id":"MOCK_TODO_3_3","url":"https://p4.invalid/app/4","appId":"MOCK_APP_4","dueAt":"2026-09-18T12:00:00.000Z","title":"查看材料核验意见","status":"PENDING","userId":"MOCK_EDITOR","appName":"福建省地中海贫血信息管理系统","summary":"福建省地中海贫血信息管理系统：查看材料核验意见。请在来源系统查看业务详情。","version":1,"priority":"HIGH","createdAt":"2026-09-17T19:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","terminalAt":null,"businessType":"服务事项","sourceTodoId":"P4_TODO_3_3","sourceRevision":1},{"id":"MOCK_TODO_3_4","url":"https://p4.invalid/app/5","appId":"MOCK_APP_5","dueAt":"2026-09-18T16:00:00.000Z","title":"核对信息更新内容","status":"PENDING","userId":"MOCK_EDITOR","appName":"福建省慢病报告与管理系统","summary":"福建省慢病报告���������管理系统：核对信息更新内容。请在来源系统查看业务详情。","version":1,"priority":"MEDIUM","createdAt":"2026-09-17T18:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","terminalAt":null,"businessType":"服务事项","sourceTodoId":"P4_TODO_3_4","sourceRevision":1},{"id":"MOCK_TODO_3_5","url":"https://p4.invalid/app/6","appId":"MOCK_APP_6","dueAt":"2026-09-18T20:00:00.000Z","title":"确认事项办理进度","status":"PENDING","userId":"MOCK_EDITOR","appName":"福建省区域影像平台","summary":"福建省区域影像平台：确认事项办理进度。请在来源系统查看业��详情。","version":1,"priority":"LOW","createdAt":"2026-09-17T17:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","terminalAt":null,"businessType":"服务事项","sourceTodoId":"P4_TODO_3_5","sourceRevision":1},{"id":"MOCK_TODO_3_6","url":"https://p4.invalid/app/7","appId":"MOCK_APP_7","dueAt":"2026-09-19T00:00:00.000Z","title":"完善服务联系说明","status":"PENDING","userId":"MOCK_EDITOR","appName":"质控评分系统","summary":"质控评分系统：完善服务联系说明。请在来源系统查看业务详情。","version":1,"priority":"HIGH","createdAt":"2026-09-17T16:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","terminalAt":null,"businessType":"服务事项","sourceTodoId":"P4_TODO_3_6","sourceRevision":1},{"id":"MOCK_TODO_3_7","url":"https://p4.invalid/app/8","appId":"MOCK_APP_8","dueAt":"2026-09-19T04:00:00.000Z","title":"查看后续办理要求","status":"PENDING","userId":"MOCK_EDITOR","appName":"省级平台决策支持展示系统","summary":"省级平台决策支持展示系统：查看后续办理要求。请在来源系统查看业务详情。","version":1,"priority":"MEDIUM","createdAt":"2026-09-17T15:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","terminalAt":null,"businessType":"服务事项","sourceTodoId":"P4_TODO_3_7","sourceRevision":1},{"id":"MOCK_TODO_3_8","url":"https://p4.invalid/app/1","appId":"MOCK_APP_1","dueAt":"2026-09-19T08:00:00.000Z","title":"资料核验已完成","status":"COMPLETED","userId":"MOCK_EDITOR","appName":"福建省新生儿疾病筛查管理系统","summary":"福建省新生儿疾病筛查管理系统：资料核验已完成。请在来源系统查看业务详情。","version":1,"priority":"LOW","createdAt":"2026-09-17T14:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","terminalAt":"2026-09-17T23:00:00.000Z","businessType":"服务事项","sourceTodoId":"P4_TODO_3_8","sourceRevision":2},{"id":"MOCK_TODO_3_9","url":"https://p4.invalid/app/2","appId":"MOCK_APP_2","dueAt":"2026-09-19T12:00:00.000Z","title":"业务申请已撤回","status":"WITHDRAWN","userId":"MOCK_EDITOR","appName":"福建省妇幼卫生信息系统","summary":"福建省妇幼卫生信息系统：业务申请已撤回。请在来源系统查看业务详情。","version":1,"priority":"HIGH","createdAt":"2026-09-17T13:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","terminalAt":"2026-09-17T23:00:00.000Z","businessType":"服务事项","sourceTodoId":"P4_TODO_3_9","sourceRevision":2},{"id":"MOCK_TODO_3_10","url":"https://p4.invalid/app/3","appId":"MOCK_APP_3","dueAt":"2026-09-19T16:00:00.000Z","title":"办理期限已结束","status":"EXPIRED","userId":"MOCK_EDITOR","appName":"福建省产前筛查与诊断管理系统","summary":"福建省产前筛查与诊断管理系统：办理期限已结束。请在来源系统查看业务详情。","version":1,"priority":"MEDIUM","createdAt":"2026-09-17T12:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","terminalAt":"2026-09-17T23:00:00.000Z","businessType":"服务事项","sourceTodoId":"P4_TODO_3_10","sourceRevision":2}],"users":[{"id":"MOCK_USER_1","kind":"USER","name":"林晓","email":"未提供","mobile":"未提供","orgKey":"PUBLIC","scopes":[],"status":"NORMAL","account":"linxiao","orgName":"公众服务","roleIds":[],"jobTitle":"办事人员","roleName":"普通用户","userType":"CITIZEN","department":"个人服务","identitySource":"闽政通"},{"id":"MOCK_USER_2","kind":"USER","name":"陈宁","email":"未提供","mobile":"未提供","orgKey":"HEALTH","scopes":[],"status":"NORMAL","account":"chenning","orgName":"卫生健康业务处","roleIds":[],"jobTitle":"业务经办","roleName":"普通用户","userType":"GOV","department":"业务协同科","identitySource":"闽政务"},{"id":"MOCK_ADMIN","kind":"ADMIN","name":"周明","email":"未提供","mobile":"未提供","orgKey":"PORTAL","scopes":["super","application","integration","announcement","audit","identity"],"status":"NORMAL","account":"zhouming","orgName":"门户运行保障中心","roleIds":["ROLE_SUPER"],"jobTitle":"系统管理","roleName":"门户超级管理员","userType":"GOV","department":"运行保障科","identitySource":"闽政务"},{"id":"MOCK_EDITOR","kind":"ADMIN","name":"郑颖","email":"未提供","mobile":"未提供","orgKey":"PORTAL","scopes":["announcement"],"status":"NORMAL","account":"zhengying","orgName":"门户运行保障中心","roleIds":["ROLE_CONTENT"],"jobTitle":"信息编辑","roleName":"内容管理员","userType":"GOV","department":"信息发布科","identitySource":"闽政务","scopeDescription":"公告权限"}],"visits":[{"at":"2026-09-17T23:00:00.000Z","appId":"MOCK_APP_1","userId":"MOCK_USER_1"},{"at":"2026-09-17T22:00:00.000Z","appId":"MOCK_APP_2","userId":"MOCK_USER_1"},{"at":"2026-09-17T21:00:00.000Z","appId":"MOCK_APP_3","userId":"MOCK_USER_1"},{"at":"2026-09-17T20:00:00.000Z","appId":"MOCK_APP_4","userId":"MOCK_USER_1"},{"at":"2026-09-17T23:00:00.000Z","appId":"MOCK_APP_1","userId":"MOCK_USER_2"},{"at":"2026-09-17T22:00:00.000Z","appId":"MOCK_APP_2","userId":"MOCK_USER_2"},{"at":"2026-09-17T21:00:00.000Z","appId":"MOCK_APP_3","userId":"MOCK_USER_2"},{"at":"2026-09-17T20:00:00.000Z","appId":"MOCK_APP_4","userId":"MOCK_USER_2"},{"at":"2026-09-17T23:00:00.000Z","appId":"MOCK_APP_1","userId":"MOCK_ADMIN"},{"at":"2026-09-17T22:00:00.000Z","appId":"MOCK_APP_2","userId":"MOCK_ADMIN"},{"at":"2026-09-17T21:00:00.000Z","appId":"MOCK_APP_3","userId":"MOCK_ADMIN"},{"at":"2026-09-17T20:00:00.000Z","appId":"MOCK_APP_4","userId":"MOCK_ADMIN"},{"at":"2026-09-17T23:00:00.000Z","appId":"MOCK_APP_1","userId":"MOCK_EDITOR"},{"at":"2026-09-17T22:00:00.000Z","appId":"MOCK_APP_2","userId":"MOCK_EDITOR"},{"at":"2026-09-17T21:00:00.000Z","appId":"MOCK_APP_3","userId":"MOCK_EDITOR"},{"at":"2026-09-17T20:00:00.000Z","appId":"MOCK_APP_4","userId":"MOCK_EDITOR"},{"at":"2026-09-18T14:48:29.518Z","appId":"MOCK_APP_1","userId":"MOCK_USER_1"},{"at":"2026-09-18T15:10:47.367Z","appId":"MOCK_APP_6","userId":"MOCK_USER_2"}],"mappings":[{"id":"MOCK_MAP_MOCK_USER_1_1","appId":"MOCK_APP_1","status":"BOUND","userId":"MOCK_USER_1","appName":"福建省新生儿疾病筛查管理系统","boundAt":"2026-09-17T00:00:00.000Z","version":1,"userName":"林晓","createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","bindingMethod":"ADMIN","conflictReason":null,"externalUserId":"P4_SUBJECT_MOCK_USER_1_1","externalAccount":"linxiao_01"},{"id":"MOCK_MAP_MOCK_USER_1_2","appId":"MOCK_APP_2","status":"BOUND","userId":"MOCK_USER_1","appName":"福建省妇幼卫生信息系统","boundAt":"2026-09-17T00:00:00.000Z","version":1,"userName":"林晓","createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","bindingMethod":"ADMIN","conflictReason":null,"externalUserId":"P4_SUBJECT_MOCK_USER_1_2","externalAccount":"linxiao_02"},{"id":"MOCK_MAP_MOCK_USER_1_3","appId":"MOCK_APP_3","status":"BOUND","userId":"MOCK_USER_1","appName":"福建省产前筛查与诊断管理系统","boundAt":"2026-09-17T00:00:00.000Z","version":1,"userName":"林晓","createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","bindingMethod":"ADMIN","conflictReason":null,"externalUserId":"P4_SUBJECT_MOCK_USER_1_3","externalAccount":"linxiao_03"},{"id":"MOCK_MAP_MOCK_USER_1_4","appId":"MOCK_APP_4","status":"BOUND","userId":"MOCK_USER_1","appName":"福建省地中海贫血信息管理系统","boundAt":"2026-09-17T00:00:00.000Z","version":1,"userName":"林晓","createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","bindingMethod":"ADMIN","conflictReason":null,"externalUserId":"P4_SUBJECT_MOCK_USER_1_4","externalAccount":"linxiao_04"},{"id":"MOCK_MAP_MOCK_USER_1_5","appId":"MOCK_APP_5","status":"BOUND","userId":"MOCK_USER_1","appName":"福建省慢病报告与管理系统","boundAt":"2026-09-17T00:00:00.000Z","version":1,"userName":"林晓","createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","bindingMethod":"ADMIN","conflictReason":null,"externalUserId":"P4_SUBJECT_MOCK_USER_1_5","externalAccount":"linxiao_05"},{"id":"MOCK_MAP_MOCK_USER_1_6","appId":"MOCK_APP_6","status":"BOUND","userId":"MOCK_USER_1","appName":"福建省区域影像平台","boundAt":"2026-09-17T00:00:00.000Z","version":1,"userName":"林晓","createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","bindingMethod":"ADMIN","conflictReason":null,"externalUserId":"P4_SUBJECT_MOCK_USER_1_6","externalAccount":"linxiao_06"},{"id":"MOCK_MAP_MOCK_USER_1_11","appId":"MOCK_APP_11","status":"BOUND","userId":"MOCK_USER_1","appName":"福建省免疫规划管理信息系统","boundAt":"2026-09-17T00:00:00.000Z","version":1,"userName":"林晓","createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","bindingMethod":"ADMIN","conflictReason":null,"externalUserId":"P4_SUBJECT_MOCK_USER_1_11","externalAccount":"linxiao_11"},{"id":"MOCK_MAP_MOCK_USER_1_12","appId":"MOCK_APP_12","status":"BOUND","userId":"MOCK_USER_1","appName":"中医馆健康信息系统","boundAt":"2026-09-17T00:00:00.000Z","version":1,"userName":"林晓","createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","bindingMethod":"ADMIN","conflictReason":null,"externalUserId":"P4_SUBJECT_MOCK_USER_1_12","externalAccount":"linxiao_12"},{"id":"MOCK_MAP_MOCK_USER_1_26","appId":"MOCK_APP_26","status":"FAILED","userId":"MOCK_USER_1","appName":"福建省中医医术确有专长人员医师资格考核报名系统","boundAt":null,"version":1,"userName":"林晓","createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","bindingMethod":"ADMIN","conflictReason":"账号核验未通过，待补充关联资料","externalUserId":"P4_SUBJECT_MOCK_USER_1_26","externalAccount":"linxiao_26"},{"id":"MOCK_MAP_MOCK_USER_1_28","appId":"MOCK_APP_28","status":"CONFLICT","userId":"MOCK_USER_1","appName":"福建省卫生专业技术资格考试报名系统","boundAt":null,"version":1,"userName":"林晓","createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","bindingMethod":"ADMIN","conflictReason":"身份资料不一致，待人工核查","externalUserId":"P4_SUBJECT_MOCK_USER_1_28","externalAccount":"linxiao_28"},{"id":"MOCK_MAP_MOCK_USER_2_1","appId":"MOCK_APP_1","status":"BOUND","userId":"MOCK_USER_2","appName":"福建省新生儿疾病筛查管理系统","boundAt":"2026-09-17T00:00:00.000Z","version":1,"userName":"陈宁","createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","bindingMethod":"ADMIN","conflictReason":null,"externalUserId":"P4_SUBJECT_MOCK_USER_2_1","externalAccount":"chenning_01"},{"id":"MOCK_MAP_MOCK_USER_2_2","appId":"MOCK_APP_2","status":"BOUND","userId":"MOCK_USER_2","appName":"福建省妇幼卫生信息系统","boundAt":"2026-09-17T00:00:00.000Z","version":1,"userName":"陈宁","createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","bindingMethod":"ADMIN","conflictReason":null,"externalUserId":"P4_SUBJECT_MOCK_USER_2_2","externalAccount":"chenning_02"},{"id":"MOCK_MAP_MOCK_USER_2_3","appId":"MOCK_APP_3","status":"BOUND","userId":"MOCK_USER_2","appName":"福建省产前筛查与诊断管理系统","boundAt":"2026-09-17T00:00:00.000Z","version":1,"userName":"陈宁","createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","bindingMethod":"ADMIN","conflictReason":null,"externalUserId":"P4_SUBJECT_MOCK_USER_2_3","externalAccount":"chenning_03"},{"id":"MOCK_MAP_MOCK_USER_2_4","appId":"MOCK_APP_4","status":"BOUND","userId":"MOCK_USER_2","appName":"福建省地中海贫血信息管理系统","boundAt":"2026-09-17T00:00:00.000Z","version":1,"userName":"陈宁","createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","bindingMethod":"ADMIN","conflictReason":null,"externalUserId":"P4_SUBJECT_MOCK_USER_2_4","externalAccount":"chenning_04"},{"id":"MOCK_MAP_MOCK_USER_2_5","appId":"MOCK_APP_5","status":"BOUND","userId":"MOCK_USER_2","appName":"福建省慢病报告与管理系统","boundAt":"2026-09-17T00:00:00.000Z","version":1,"userName":"陈宁","createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","bindingMethod":"ADMIN","conflictReason":null,"externalUserId":"P4_SUBJECT_MOCK_USER_2_5","externalAccount":"chenning_05"},{"id":"MOCK_MAP_MOCK_USER_2_6","appId":"MOCK_APP_6","status":"BOUND","userId":"MOCK_USER_2","appName":"福建省区域影像平台","boundAt":"2026-09-17T00:00:00.000Z","version":1,"userName":"陈宁","createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","bindingMethod":"ADMIN","conflictReason":null,"externalUserId":"P4_SUBJECT_MOCK_USER_2_6","externalAccount":"chenning_06"},{"id":"MOCK_MAP_MOCK_USER_2_7","appId":"MOCK_APP_7","status":"BOUND","userId":"MOCK_USER_2","appName":"质控评分系统","boundAt":"2026-09-17T00:00:00.000Z","version":1,"userName":"陈宁","createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","bindingMethod":"ADMIN","conflictReason":null,"externalUserId":"P4_SUBJECT_MOCK_USER_2_7","externalAccount":"chenning_07"},{"id":"MOCK_MAP_MOCK_USER_2_8","appId":"MOCK_APP_8","status":"BOUND","userId":"MOCK_USER_2","appName":"省级平台决策支持展示系统","boundAt":"2026-09-17T00:00:00.000Z","version":1,"userName":"陈宁","createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","bindingMethod":"ADMIN","conflictReason":null,"externalUserId":"P4_SUBJECT_MOCK_USER_2_8","externalAccount":"chenning_08"},{"id":"MOCK_MAP_MOCK_USER_2_26","appId":"MOCK_APP_26","status":"FAILED","userId":"MOCK_USER_2","appName":"福建省中医医术确有专长人员医师资格考核报名系统","boundAt":null,"version":1,"userName":"陈宁","createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","bindingMethod":"ADMIN","conflictReason":"账号核验未通过，待补充关联资料","externalUserId":"P4_SUBJECT_MOCK_USER_2_26","externalAccount":"chenning_26"},{"id":"MOCK_MAP_MOCK_USER_2_28","appId":"MOCK_APP_28","status":"CONFLICT","userId":"MOCK_USER_2","appName":"福建省卫生专业技术资格考试报名系统","boundAt":null,"version":1,"userName":"陈宁","createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","bindingMethod":"ADMIN","conflictReason":"身份资料不一致，待人工核查","externalUserId":"P4_SUBJECT_MOCK_USER_2_28","externalAccount":"chenning_28"},{"id":"MOCK_MAP_MOCK_ADMIN_1","appId":"MOCK_APP_1","status":"BOUND","userId":"MOCK_ADMIN","appName":"福建省新生儿疾病筛查管理系统","boundAt":"2026-09-17T00:00:00.000Z","version":1,"userName":"周明","createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","bindingMethod":"ADMIN","conflictReason":null,"externalUserId":"P4_SUBJECT_MOCK_ADMIN_1","externalAccount":"zhouming_01"},{"id":"MOCK_MAP_MOCK_ADMIN_2","appId":"MOCK_APP_2","status":"BOUND","userId":"MOCK_ADMIN","appName":"福建省妇幼卫生信息系统","boundAt":"2026-09-17T00:00:00.000Z","version":1,"userName":"周明","createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","bindingMethod":"ADMIN","conflictReason":null,"externalUserId":"P4_SUBJECT_MOCK_ADMIN_2","externalAccount":"zhouming_02"},{"id":"MOCK_MAP_MOCK_ADMIN_3","appId":"MOCK_APP_3","status":"BOUND","userId":"MOCK_ADMIN","appName":"福建省产前筛查与诊断管理系统","boundAt":"2026-09-17T00:00:00.000Z","version":1,"userName":"周明","createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","bindingMethod":"ADMIN","conflictReason":null,"externalUserId":"P4_SUBJECT_MOCK_ADMIN_3","externalAccount":"zhouming_03"},{"id":"MOCK_MAP_MOCK_ADMIN_4","appId":"MOCK_APP_4","status":"BOUND","userId":"MOCK_ADMIN","appName":"福建省地中海贫血信息管理系统","boundAt":"2026-09-17T00:00:00.000Z","version":1,"userName":"周明","createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","bindingMethod":"ADMIN","conflictReason":null,"externalUserId":"P4_SUBJECT_MOCK_ADMIN_4","externalAccount":"zhouming_04"},{"id":"MOCK_MAP_MOCK_ADMIN_5","appId":"MOCK_APP_5","status":"BOUND","userId":"MOCK_ADMIN","appName":"福建省慢病报告与管理系统","boundAt":"2026-09-17T00:00:00.000Z","version":1,"userName":"周明","createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","bindingMethod":"ADMIN","conflictReason":null,"externalUserId":"P4_SUBJECT_MOCK_ADMIN_5","externalAccount":"zhouming_05"},{"id":"MOCK_MAP_MOCK_ADMIN_6","appId":"MOCK_APP_6","status":"BOUND","userId":"MOCK_ADMIN","appName":"福建省区域影像平台","boundAt":"2026-09-17T00:00:00.000Z","version":1,"userName":"周明","createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","bindingMethod":"ADMIN","conflictReason":null,"externalUserId":"P4_SUBJECT_MOCK_ADMIN_6","externalAccount":"zhouming_06"},{"id":"MOCK_MAP_MOCK_ADMIN_7","appId":"MOCK_APP_7","status":"BOUND","userId":"MOCK_ADMIN","appName":"质控评分系统","boundAt":"2026-09-17T00:00:00.000Z","version":1,"userName":"周明","createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","bindingMethod":"ADMIN","conflictReason":null,"externalUserId":"P4_SUBJECT_MOCK_ADMIN_7","externalAccount":"zhouming_07"},{"id":"MOCK_MAP_MOCK_ADMIN_8","appId":"MOCK_APP_8","status":"BOUND","userId":"MOCK_ADMIN","appName":"省级平台决策支持展示系统","boundAt":"2026-09-17T00:00:00.000Z","version":1,"userName":"周明","createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","bindingMethod":"ADMIN","conflictReason":null,"externalUserId":"P4_SUBJECT_MOCK_ADMIN_8","externalAccount":"zhouming_08"},{"id":"MOCK_MAP_MOCK_ADMIN_26","appId":"MOCK_APP_26","status":"FAILED","userId":"MOCK_ADMIN","appName":"福建省中医医术确有专长人员医师资格考核报名系统","boundAt":null,"version":1,"userName":"周明","createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","bindingMethod":"ADMIN","conflictReason":"账号核验未通过，待补充关联资料","externalUserId":"P4_SUBJECT_MOCK_ADMIN_26","externalAccount":"zhouming_26"},{"id":"MOCK_MAP_MOCK_ADMIN_28","appId":"MOCK_APP_28","status":"CONFLICT","userId":"MOCK_ADMIN","appName":"福建省卫生专业技术资格考试报名系统","boundAt":null,"version":1,"userName":"周明","createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","bindingMethod":"ADMIN","conflictReason":"身份资料不一致，待人工核查","externalUserId":"P4_SUBJECT_MOCK_ADMIN_28","externalAccount":"zhouming_28"},{"id":"MOCK_MAP_MOCK_EDITOR_1","appId":"MOCK_APP_1","status":"BOUND","userId":"MOCK_EDITOR","appName":"福建省新生儿疾病筛查管理系统","boundAt":"2026-09-17T00:00:00.000Z","version":1,"userName":"郑颖","createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","bindingMethod":"ADMIN","conflictReason":null,"externalUserId":"P4_SUBJECT_MOCK_EDITOR_1","externalAccount":"zhengying_01"},{"id":"MOCK_MAP_MOCK_EDITOR_2","appId":"MOCK_APP_2","status":"BOUND","userId":"MOCK_EDITOR","appName":"福建省妇幼卫生信息系统","boundAt":"2026-09-17T00:00:00.000Z","version":1,"userName":"郑颖","createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","bindingMethod":"ADMIN","conflictReason":null,"externalUserId":"P4_SUBJECT_MOCK_EDITOR_2","externalAccount":"zhengying_02"},{"id":"MOCK_MAP_MOCK_EDITOR_3","appId":"MOCK_APP_3","status":"BOUND","userId":"MOCK_EDITOR","appName":"福建省产前筛查与诊断管理系统","boundAt":"2026-09-17T00:00:00.000Z","version":1,"userName":"郑颖","createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","bindingMethod":"ADMIN","conflictReason":null,"externalUserId":"P4_SUBJECT_MOCK_EDITOR_3","externalAccount":"zhengying_03"},{"id":"MOCK_MAP_MOCK_EDITOR_4","appId":"MOCK_APP_4","status":"BOUND","userId":"MOCK_EDITOR","appName":"福建省地中海贫血信息管理系统","boundAt":"2026-09-17T00:00:00.000Z","version":1,"userName":"郑颖","createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","bindingMethod":"ADMIN","conflictReason":null,"externalUserId":"P4_SUBJECT_MOCK_EDITOR_4","externalAccount":"zhengying_04"},{"id":"MOCK_MAP_MOCK_EDITOR_5","appId":"MOCK_APP_5","status":"BOUND","userId":"MOCK_EDITOR","appName":"福建省慢病报告与管理系统","boundAt":"2026-09-17T00:00:00.000Z","version":1,"userName":"郑颖","createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","bindingMethod":"ADMIN","conflictReason":null,"externalUserId":"P4_SUBJECT_MOCK_EDITOR_5","externalAccount":"zhengying_05"},{"id":"MOCK_MAP_MOCK_EDITOR_6","appId":"MOCK_APP_6","status":"BOUND","userId":"MOCK_EDITOR","appName":"福建省区域影像平台","boundAt":"2026-09-17T00:00:00.000Z","version":1,"userName":"郑颖","createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","bindingMethod":"ADMIN","conflictReason":null,"externalUserId":"P4_SUBJECT_MOCK_EDITOR_6","externalAccount":"zhengying_06"},{"id":"MOCK_MAP_MOCK_EDITOR_7","appId":"MOCK_APP_7","status":"BOUND","userId":"MOCK_EDITOR","appName":"质控评分系统","boundAt":"2026-09-17T00:00:00.000Z","version":1,"userName":"郑颖","createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","bindingMethod":"ADMIN","conflictReason":null,"externalUserId":"P4_SUBJECT_MOCK_EDITOR_7","externalAccount":"zhengying_07"},{"id":"MOCK_MAP_MOCK_EDITOR_8","appId":"MOCK_APP_8","status":"BOUND","userId":"MOCK_EDITOR","appName":"省级平台决策支持展示系统","boundAt":"2026-09-17T00:00:00.000Z","version":1,"userName":"郑颖","createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","bindingMethod":"ADMIN","conflictReason":null,"externalUserId":"P4_SUBJECT_MOCK_EDITOR_8","externalAccount":"zhengying_08"},{"id":"MOCK_MAP_MOCK_EDITOR_26","appId":"MOCK_APP_26","status":"FAILED","userId":"MOCK_EDITOR","appName":"福建省中医医术确有专长人员医师资格考核报名系统","boundAt":null,"version":1,"userName":"郑颖","createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","bindingMethod":"ADMIN","conflictReason":"账号核验未通过，待补充关联资料","externalUserId":"P4_SUBJECT_MOCK_EDITOR_26","externalAccount":"zhengying_26"},{"id":"MOCK_MAP_MOCK_EDITOR_28","appId":"MOCK_APP_28","status":"CONFLICT","userId":"MOCK_EDITOR","appName":"福建省卫生专业技术资格考试报名系统","boundAt":null,"version":1,"userName":"郑颖","createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","bindingMethod":"ADMIN","conflictReason":"身份资料不一致，待人工核查","externalUserId":"P4_SUBJECT_MOCK_EDITOR_28","externalAccount":"zhengying_28"}],"messages":[{"id":"MOCK_MSG_0_0","url":"https://p4.invalid/app/1","appId":"MOCK_APP_1","title":"服务申请已受理","readAt":"2026-09-18T14:49:21.957Z","status":"READ","userId":"MOCK_USER_1","appName":"福建省新生儿疾病筛查管理系统","content":"服务申请已受理。请查看相关事项详情并按办理要求完成后续操作。","version":2,"createdAt":"2026-09-17T23:00:00.000Z","updatedAt":"2026-09-18T14:49:21.957Z","sourceKind":"APPLICATION","messageType":"BUSINESS","sourceMessageId":"P4_MSG_0_0"},{"id":"MOCK_MSG_0_1","url":"https://p4.invalid/app/2","appId":"MOCK_APP_2","title":"资料核验进度通知","readAt":"2026-09-18T14:49:35.187Z","status":"READ","userId":"MOCK_USER_1","appName":"福建省妇幼卫生信息系统","content":"资料核验进度通知。请查看相关事项详情并按办理要求完成后续操作。","version":2,"createdAt":"2026-09-17T22:00:00.000Z","updatedAt":"2026-09-18T14:49:35.187Z","sourceKind":"APPLICATION","messageType":"BUSINESS","sourceMessageId":"P4_MSG_0_1"},{"id":"MOCK_MSG_0_2","url":"https://p4.invalid/app/3","appId":"MOCK_APP_3","title":"办理期限提醒","readAt":"2026-09-18T15:15:56.541Z","status":"READ","userId":"MOCK_USER_1","appName":"福建省产前筛查与诊断管理系统","content":"办理期限提醒。请查看相关事项详情并按办理要求完成后续操作。","version":2,"createdAt":"2026-09-17T21:00:00.000Z","updatedAt":"2026-09-18T15:15:56.541Z","sourceKind":"APPLICATION","messageType":"TODO_REMINDER","sourceMessageId":"P4_MSG_0_2"},{"id":"MOCK_MSG_0_3","url":"https://p4.invalid/app/4","appId":"MOCK_APP_4","title":"服务安排更新","readAt":"2026-09-18T15:05:14.890Z","status":"READ","userId":"MOCK_USER_1","appName":"福建省地中海贫血信息管理系统","content":"服务安排更新。请查看相关事项详情并按办理要求完成后续操作。","version":2,"createdAt":"2026-09-17T20:00:00.000Z","updatedAt":"2026-09-18T15:05:14.890Z","sourceKind":"APPLICATION","messageType":"BUSINESS","sourceMessageId":"P4_MSG_0_3"},{"id":"MOCK_MSG_0_4","url":"https://p4.invalid/app/5","appId":"MOCK_APP_5","title":"账号关联结果通知","readAt":"2026-09-18T15:16:22.835Z","status":"READ","userId":"MOCK_USER_1","appName":"福建省慢病报告与管理系统","content":"账号关联结果通知。请查看相关事项详情并按办理要求完成后续操作。","version":2,"createdAt":"2026-09-17T19:00:00.000Z","updatedAt":"2026-09-18T15:16:22.835Z","sourceKind":"APPLICATION","messageType":"BUSINESS","sourceMessageId":"P4_MSG_0_4"},{"id":"MOCK_MSG_0_5","url":"https://p4.invalid/app/6","appId":"MOCK_APP_6","title":"业务信息变更提醒","readAt":"2026-09-18T15:58:30.221Z","status":"READ","userId":"MOCK_USER_1","appName":"福建省区域影像平台","content":"业务信息变更提醒。请查看相关事项详情并按办理要求完成后续操作。","version":2,"createdAt":"2026-09-17T18:00:00.000Z","updatedAt":"2026-09-18T15:58:30.221Z","sourceKind":"APPLICATION","messageType":"BUSINESS","sourceMessageId":"P4_MSG_0_5"},{"id":"MOCK_MSG_0_6","url":"https://p4.invalid/app/11","appId":"MOCK_APP_11","title":"材料补正通知","readAt":null,"status":"UNREAD","userId":"MOCK_USER_1","appName":"福建省免疫规划管理信息系统","content":"材料补正通知。请查看相关事项详情并按办理要求完成后续操作。","version":1,"createdAt":"2026-09-17T17:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","sourceKind":"APPLICATION","messageType":"BUSINESS","sourceMessageId":"P4_MSG_0_6"},{"id":"MOCK_MSG_0_7","url":"https://p4.invalid/app/12","appId":"MOCK_APP_12","title":"办理意见已反馈","readAt":null,"status":"UNREAD","userId":"MOCK_USER_1","appName":"中医馆健康信息系统","content":"办理意见已反馈。请查看相关事项详情并按办理要求完成后续操作。","version":1,"createdAt":"2026-09-17T16:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","sourceKind":"APPLICATION","messageType":"BUSINESS","sourceMessageId":"P4_MSG_0_7"},{"id":"MOCK_MSG_0_8","url":null,"appId":null,"title":"�����户���护安排","readAt":"2026-09-17T23:00:00.000Z","status":"READ","userId":"MOCK_USER_1","appName":"统一门户","content":"门户维护安排。请查看相关事项详情并按办理要求完成后���操�������。","version":1,"createdAt":"2026-09-17T15:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","sourceKind":"PORTAL","messageType":"SYSTEM","sourceMessageId":"P4_MSG_0_8"},{"id":"MOCK_MSG_0_9","url":null,"appId":null,"title":"信息安全提醒","readAt":"2026-09-17T23:00:00.000Z","status":"READ","userId":"MOCK_USER_1","appName":"统一门户","content":"信息安全提醒。请查看相关事项详情�����������按办理要求完成后续操作。","version":1,"createdAt":"2026-09-17T14:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","sourceKind":"PORTAL","messageType":"SYSTEM","sourceMessageId":"P4_MSG_0_9"},{"id":"MOCK_MSG_1_0","url":"https://p4.invalid/app/1","appId":"MOCK_APP_1","title":"服务申请已受理","readAt":"2026-09-18T16:32:04.310Z","status":"READ","userId":"MOCK_USER_2","appName":"福建省新生儿疾病筛查管理系统","content":"服务申请已受理。请查看相关事项详情并按办理要求完成后续操作。","version":2,"createdAt":"2026-09-17T23:00:00.000Z","updatedAt":"2026-09-18T16:32:04.310Z","sourceKind":"APPLICATION","messageType":"BUSINESS","sourceMessageId":"P4_MSG_1_0"},{"id":"MOCK_MSG_1_1","url":"https://p4.invalid/app/2","appId":"MOCK_APP_2","title":"资料核验进度通知","readAt":"2026-09-18T15:31:44.193Z","status":"READ","userId":"MOCK_USER_2","appName":"福建省妇幼卫生信息系统","content":"资料核验进度通知。请查看相关事项详情并按办理要求完成后续操作。","version":2,"createdAt":"2026-09-17T22:00:00.000Z","updatedAt":"2026-09-18T15:31:44.193Z","sourceKind":"APPLICATION","messageType":"BUSINESS","sourceMessageId":"P4_MSG_1_1"},{"id":"MOCK_MSG_1_2","url":"https://p4.invalid/app/3","appId":"MOCK_APP_3","title":"办理期限提醒","readAt":"2026-09-18T16:27:06.299Z","status":"READ","userId":"MOCK_USER_2","appName":"福建省产前筛查与诊断管理系统","content":"办理期限�������������醒。请查看相关事项详情并按办理要求完成后续操作。","version":2,"createdAt":"2026-09-17T21:00:00.000Z","updatedAt":"2026-09-18T16:27:06.299Z","sourceKind":"APPLICATION","messageType":"TODO_REMINDER","sourceMessageId":"P4_MSG_1_2"},{"id":"MOCK_MSG_1_3","url":"https://p4.invalid/app/4","appId":"MOCK_APP_4","title":"服务安排更新","readAt":null,"status":"UNREAD","userId":"MOCK_USER_2","appName":"福建省地中海贫血信息管理系统","content":"服务安排更新。请查看相关事项详情并按办理要求完成后续操作。","version":1,"createdAt":"2026-09-17T20:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","sourceKind":"APPLICATION","messageType":"BUSINESS","sourceMessageId":"P4_MSG_1_3"},{"id":"MOCK_MSG_1_4","url":"https://p4.invalid/app/5","appId":"MOCK_APP_5","title":"账号关联结果通知","readAt":null,"status":"UNREAD","userId":"MOCK_USER_2","appName":"��建省慢病报告与管理系统","content":"账号关联结果通知。请查看相关事项详情并按办理要求完成后续操作。","version":1,"createdAt":"2026-09-17T19:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","sourceKind":"APPLICATION","messageType":"BUSINESS","sourceMessageId":"P4_MSG_1_4"},{"id":"MOCK_MSG_1_5","url":"https://p4.invalid/app/6","appId":"MOCK_APP_6","title":"业务信息变更提醒","readAt":null,"status":"UNREAD","userId":"MOCK_USER_2","appName":"福建省区域影像平台","content":"业务信息变更提醒。请查看相关事项详情并按办理要求完成后续操作。","version":1,"createdAt":"2026-09-17T18:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","sourceKind":"APPLICATION","messageType":"BUSINESS","sourceMessageId":"P4_MSG_1_5"},{"id":"MOCK_MSG_1_6","url":"https://p4.invalid/app/7","appId":"MOCK_APP_7","title":"材料补正通知","readAt":null,"status":"UNREAD","userId":"MOCK_USER_2","appName":"质控评分系统","content":"材料补正通知。请查看相关事项详情并按办理要求完成后续操作。","version":1,"createdAt":"2026-09-17T17:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","sourceKind":"APPLICATION","messageType":"BUSINESS","sourceMessageId":"P4_MSG_1_6"},{"id":"MOCK_MSG_1_7","url":"https://p4.invalid/app/8","appId":"MOCK_APP_8","title":"办理意见已反馈","readAt":null,"status":"UNREAD","userId":"MOCK_USER_2","appName":"省级平台决策支持展示系统","content":"办理意见已反馈。请查看相关事项详情并按办理要求完成后续操作。","version":1,"createdAt":"2026-09-17T16:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","sourceKind":"APPLICATION","messageType":"BUSINESS","sourceMessageId":"P4_MSG_1_7"},{"id":"MOCK_MSG_1_8","url":null,"appId":null,"title":"门户维护安排","readAt":"2026-09-17T23:00:00.000Z","status":"READ","userId":"MOCK_USER_2","appName":"统一门户","content":"门户维护安排。请查看相关事项详情并按办理要求完成后续操作。","version":1,"createdAt":"2026-09-17T15:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","sourceKind":"PORTAL","messageType":"SYSTEM","sourceMessageId":"P4_MSG_1_8"},{"id":"MOCK_MSG_1_9","url":null,"appId":null,"title":"信息安全提醒","readAt":"2026-09-17T23:00:00.000Z","status":"READ","userId":"MOCK_USER_2","appName":"统一门户","content":"信息安全提醒。请查看相关事项详情并按办理要求完成后续操作。","version":1,"createdAt":"2026-09-17T14:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","sourceKind":"PORTAL","messageType":"SYSTEM","sourceMessageId":"P4_MSG_1_9"},{"id":"MOCK_MSG_2_0","url":"https://p4.invalid/app/1","appId":"MOCK_APP_1","title":"服务申请已受理","readAt":"2026-09-18T15:48:12.994Z","status":"READ","userId":"MOCK_ADMIN","appName":"福建省新生儿疾病筛查管理系统","content":"服务申请已受理。请查看相关事项详情并按办理要求完成后续操作。","version":2,"createdAt":"2026-09-17T23:00:00.000Z","updatedAt":"2026-09-18T15:48:12.994Z","sourceKind":"APPLICATION","messageType":"BUSINESS","sourceMessageId":"P4_MSG_2_0"},{"id":"MOCK_MSG_2_1","url":"https://p4.invalid/app/2","appId":"MOCK_APP_2","title":"资料核验进度通知","readAt":"2026-09-18T15:48:33.066Z","status":"READ","userId":"MOCK_ADMIN","appName":"福建省妇幼卫生信息系统","content":"资料核验进度通知。请查看相关事项详情并按办理要求完成后续操作。","version":2,"createdAt":"2026-09-17T22:00:00.000Z","updatedAt":"2026-09-18T15:48:33.066Z","sourceKind":"APPLICATION","messageType":"BUSINESS","sourceMessageId":"P4_MSG_2_1"},{"id":"MOCK_MSG_2_2","url":"https://p4.invalid/app/3","appId":"MOCK_APP_3","title":"办理期限提醒","readAt":"2026-09-18T16:12:43.994Z","status":"READ","userId":"MOCK_ADMIN","appName":"福建省产前筛查与诊断管理系统","content":"办理期限提醒。请查看相关事项详情并按办理要求完成后续操作。","version":2,"createdAt":"2026-09-17T21:00:00.000Z","updatedAt":"2026-09-18T16:12:43.994Z","sourceKind":"APPLICATION","messageType":"TODO_REMINDER","sourceMessageId":"P4_MSG_2_2"},{"id":"MOCK_MSG_2_3","url":"https://p4.invalid/app/4","appId":"MOCK_APP_4","title":"服务安排更新","readAt":"2026-09-18T16:13:40.360Z","status":"READ","userId":"MOCK_ADMIN","appName":"福建省地中海贫血信息管理系统","content":"服务安排更新。请查看相关事项详情并按办理要求完成后续操作。","version":2,"createdAt":"2026-09-17T20:00:00.000Z","updatedAt":"2026-09-18T16:13:40.360Z","sourceKind":"APPLICATION","messageType":"BUSINESS","sourceMessageId":"P4_MSG_2_3"},{"id":"MOCK_MSG_2_4","url":"https://p4.invalid/app/5","appId":"MOCK_APP_5","title":"账号关联结果通知","readAt":null,"status":"UNREAD","userId":"MOCK_ADMIN","appName":"福建省慢病报告与管理系统","content":"账号关联结果通知。请查看相关事项详情并按办理要求完成后续操作。","version":1,"createdAt":"2026-09-17T19:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","sourceKind":"APPLICATION","messageType":"BUSINESS","sourceMessageId":"P4_MSG_2_4"},{"id":"MOCK_MSG_2_5","url":"https://p4.invalid/app/6","appId":"MOCK_APP_6","title":"业务信息变更提醒","readAt":null,"status":"UNREAD","userId":"MOCK_ADMIN","appName":"福建省区域影像平台","content":"业务信息变更提醒。请查看相关事项详情并按办理要求完成后续操作。","version":1,"createdAt":"2026-09-17T18:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","sourceKind":"APPLICATION","messageType":"BUSINESS","sourceMessageId":"P4_MSG_2_5"},{"id":"MOCK_MSG_2_6","url":"https://p4.invalid/app/7","appId":"MOCK_APP_7","title":"材料补正通知","readAt":null,"status":"UNREAD","userId":"MOCK_ADMIN","appName":"质控评分系统","content":"材料补正通知。请查看相关事项详情并按办理要求完成后续操作。","version":1,"createdAt":"2026-09-17T17:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","sourceKind":"APPLICATION","messageType":"BUSINESS","sourceMessageId":"P4_MSG_2_6"},{"id":"MOCK_MSG_2_7","url":"https://p4.invalid/app/8","appId":"MOCK_APP_8","title":"办理意见已反馈","readAt":null,"status":"UNREAD","userId":"MOCK_ADMIN","appName":"省级平台决策支持展示系统","content":"办理意见已反馈。请查看相关事项详情并按办理要求完成后续操作。","version":1,"createdAt":"2026-09-17T16:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","sourceKind":"APPLICATION","messageType":"BUSINESS","sourceMessageId":"P4_MSG_2_7"},{"id":"MOCK_MSG_2_8","url":null,"appId":null,"title":"门户维护安排","readAt":"2026-09-17T23:00:00.000Z","status":"READ","userId":"MOCK_ADMIN","appName":"统一门户","content":"门户维护安排。请查看相关事项详情并按办理要求完成后续操作。","version":1,"createdAt":"2026-09-17T15:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","sourceKind":"PORTAL","messageType":"SYSTEM","sourceMessageId":"P4_MSG_2_8"},{"id":"MOCK_MSG_2_9","url":null,"appId":null,"title":"信息安全提醒","readAt":"2026-09-17T23:00:00.000Z","status":"READ","userId":"MOCK_ADMIN","appName":"统一门户","content":"信息安全提醒。请查看相关事项详情并按办理要求完成后续操作。","version":1,"createdAt":"2026-09-17T14:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","sourceKind":"PORTAL","messageType":"SYSTEM","sourceMessageId":"P4_MSG_2_9"},{"id":"MOCK_MSG_3_0","url":"https://p4.invalid/app/1","appId":"MOCK_APP_1","title":"服务申请已受理","readAt":null,"status":"UNREAD","userId":"MOCK_EDITOR","appName":"福建省新生儿疾病筛查管理系统","content":"服务申请已受理。请查看相关事项详情并按办理要求完成后续操作。","version":1,"createdAt":"2026-09-17T23:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","sourceKind":"APPLICATION","messageType":"BUSINESS","sourceMessageId":"P4_MSG_3_0"},{"id":"MOCK_MSG_3_1","url":"https://p4.invalid/app/2","appId":"MOCK_APP_2","title":"资料核验进度通知","readAt":null,"status":"UNREAD","userId":"MOCK_EDITOR","appName":"福建省妇幼卫生信息系统","content":"资料核验进度通知。请查看相关事项详情并按办理要求完成后续操作。","version":1,"createdAt":"2026-09-17T22:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","sourceKind":"APPLICATION","messageType":"BUSINESS","sourceMessageId":"P4_MSG_3_1"},{"id":"MOCK_MSG_3_2","url":"https://p4.invalid/app/3","appId":"MOCK_APP_3","title":"办理期限提醒","readAt":null,"status":"UNREAD","userId":"MOCK_EDITOR","appName":"福建省产前筛查与诊断管理系统","content":"办理期限提醒。请查看相关事项详情并按办理要求完成后续操作。","version":1,"createdAt":"2026-09-17T21:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","sourceKind":"APPLICATION","messageType":"TODO_REMINDER","sourceMessageId":"P4_MSG_3_2"},{"id":"MOCK_MSG_3_3","url":"https://p4.invalid/app/4","appId":"MOCK_APP_4","title":"服务安排更新","readAt":null,"status":"UNREAD","userId":"MOCK_EDITOR","appName":"福建省地中海贫血信息管理系统","content":"服务安排更新。请查看相关事项详情并按办理要求完成后续操作。","version":1,"createdAt":"2026-09-17T20:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","sourceKind":"APPLICATION","messageType":"BUSINESS","sourceMessageId":"P4_MSG_3_3"},{"id":"MOCK_MSG_3_4","url":"https://p4.invalid/app/5","appId":"MOCK_APP_5","title":"账号关联结果通知","readAt":null,"status":"UNREAD","userId":"MOCK_EDITOR","appName":"福建省慢病报告与管理系统","content":"账号关联结果通知。请查看相关事项详情并按办理要求完成后续操作。","version":1,"createdAt":"2026-09-17T19:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","sourceKind":"APPLICATION","messageType":"BUSINESS","sourceMessageId":"P4_MSG_3_4"},{"id":"MOCK_MSG_3_5","url":"https://p4.invalid/app/6","appId":"MOCK_APP_6","title":"业务信息变更提醒","readAt":null,"status":"UNREAD","userId":"MOCK_EDITOR","appName":"福建省区域影像平台","content":"业务信息变更提醒。请查看相关事项详情并按办理要求完成后续操作。","version":1,"createdAt":"2026-09-17T18:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","sourceKind":"APPLICATION","messageType":"BUSINESS","sourceMessageId":"P4_MSG_3_5"},{"id":"MOCK_MSG_3_6","url":"https://p4.invalid/app/7","appId":"MOCK_APP_7","title":"材料补正通知","readAt":null,"status":"UNREAD","userId":"MOCK_EDITOR","appName":"质控评分系统","content":"材料补正通知。请查看相关事项详情并按办理要求完成后续操作。","version":1,"createdAt":"2026-09-17T17:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","sourceKind":"APPLICATION","messageType":"BUSINESS","sourceMessageId":"P4_MSG_3_6"},{"id":"MOCK_MSG_3_7","url":"https://p4.invalid/app/8","appId":"MOCK_APP_8","title":"办理意见已反馈","readAt":null,"status":"UNREAD","userId":"MOCK_EDITOR","appName":"省级平台决策支持展示系统","content":"办理意见已反馈。请查看相关事项详情并按办理要求完成后续操作。","version":1,"createdAt":"2026-09-17T16:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","sourceKind":"APPLICATION","messageType":"BUSINESS","sourceMessageId":"P4_MSG_3_7"},{"id":"MOCK_MSG_3_8","url":null,"appId":null,"title":"门户维护安排","readAt":"2026-09-17T23:00:00.000Z","status":"READ","userId":"MOCK_EDITOR","appName":"统一门户","content":"门户维护安排。请查看相关事项详情并按办理要求完成后续操作。","version":1,"createdAt":"2026-09-17T15:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","sourceKind":"PORTAL","messageType":"SYSTEM","sourceMessageId":"P4_MSG_3_8"},{"id":"MOCK_MSG_3_9","url":null,"appId":null,"title":"信息安全提醒","readAt":"2026-09-17T23:00:00.000Z","status":"READ","userId":"MOCK_EDITOR","appName":"统一门户","content":"信息安全提醒。请查看相关事项详情并按办理要求完成后续操作。","version":1,"createdAt":"2026-09-17T14:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","sourceKind":"PORTAL","messageType":"SYSTEM","sourceMessageId":"P4_MSG_3_9"}],"receipts":[],"settings":[{"id":"MOCK_CONFIG_0","code":"retention.message_days","name":"消息留存周期（天）","unit":"day","value":90,"status":"CONFIGURED","version":3,"createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-18T17:28:40.527Z"},{"id":"MOCK_CONFIG_1","code":"retention.todo_terminal_days","name":"终态待办留存周期（天）","unit":"day","value":180,"status":"CONFIGURED","version":3,"createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-18T17:28:40.527Z"},{"id":"MOCK_CONFIG_2","code":"retention.log_days","name":"日志留存周期（天）","unit":"day","value":180,"status":"CONFIGURED","version":3,"createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-18T17:28:40.527Z"},{"id":"MOCK_CONFIG_3","code":"auth.session_ttl_seconds","name":"会话有效期（秒）","unit":"second","value":7200,"status":"CONFIGURED","version":3,"createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-18T17:28:40.527Z"},{"id":"MOCK_CONFIG_4","code":"integration.timeout_ms","name":"接口超时（毫秒）","unit":"millisecond","value":5000,"status":"CONFIGURED","version":3,"createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-18T17:28:40.527Z"},{"id":"MOCK_CONFIG_5","code":"integration.max_retries","name":"接口重试上限","unit":"count","value":3,"status":"CONFIGURED","version":3,"createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-18T17:28:40.527Z"},{"id":"MOCK_CONFIG_6","code":"monitor.failure_threshold","name":"连续失败告警阈值","unit":"count","value":5,"status":"CONFIGURED","version":3,"createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-18T17:28:40.527Z"},{"id":"MOCK_CONFIG_7","code":"portal.page_size","name":"列表每页条数","unit":"count","value":15,"status":"CONFIGURED","version":3,"createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-18T17:28:40.527Z"},{"id":"RULE_retention.announcement_expired_days","max":3650,"min":0,"code":"retention.announcement_expired_days","help":"0 表示不自动删除；仅处理已发布且有失效时间的公告。清理记录保留在回收档案和审计中。","name":"公告过期后自动删除","unit":"天","group":"公告规则","value":0,"status":"CONFIGURED","default":0,"version":3,"updatedAt":"2026-09-18T17:28:40.527Z"}],"platforms":[{"id":"MOCK_PLATFORM_1","name":"福建省全民健康信息平台","sourceNo":1},{"id":"MOCK_PLATFORM_2","name":"福建省全员人口计划生育服务与管理平台","sourceNo":2},{"id":"MOCK_PLATFORM_3","name":"福建省卫健委综合监管平台","sourceNo":3},{"id":"MOCK_PLATFORM_4","name":"福建省保健对象医疗管理信息系统","sourceNo":4},{"id":"MOCK_PLATFORM_5","name":"省职控制中心门户网站","sourceNo":5},{"id":"MOCK_PLATFORM_6","name":"省卫监所综合管理系统","sourceNo":6},{"id":"MOCK_PLATFORM_7","name":"省疾控中心综合管理系统","sourceNo":7}],"categories":[{"id":"MOCK_CAT_1","code":"PUBLIC","name":"公众服务","status":"ENABLED","version":1,"createdAt":"2026-09-16T00:00:00.000Z","sortOrder":0,"updatedAt":"2026-09-17T23:00:00.000Z"},{"id":"MOCK_CAT_2","code":"GOV","name":"政务协同","status":"ENABLED","version":1,"createdAt":"2026-09-16T00:00:00.000Z","sortOrder":1,"updatedAt":"2026-09-17T23:00:00.000Z"},{"id":"MOCK_CAT_3","code":"REGULATION","name":"行业监管","status":"ENABLED","version":1,"createdAt":"2026-09-16T00:00:00.000Z","sortOrder":2,"updatedAt":"2026-09-17T23:00:00.000Z"},{"id":"MOCK_CAT_4","code":"TRAINING","name":"培训考试","status":"ENABLED","version":1,"createdAt":"2026-09-16T00:00:00.000Z","sortOrder":3,"updatedAt":"2026-09-17T23:00:00.000Z"},{"id":"MOCK_CAT_5","code":"SUPERVISION","name":"卫生监督","status":"ENABLED","version":1,"createdAt":"2026-09-16T00:00:00.000Z","sortOrder":4,"updatedAt":"2026-09-17T23:00:00.000Z"},{"id":"MOCK_CAT_6","code":"PREVENTION","name":"疾病防控","status":"ENABLED","version":1,"createdAt":"2026-09-16T00:00:00.000Z","sortOrder":5,"updatedAt":"2026-09-17T23:00:00.000Z"}],"integrations":[{"id":"MOCK_INT_MOCK_APP_1SSO","kind":"SSO","mode":"SSO","name":"福建省新生儿疾病筛查管理系统 · SSO","appId":"MOCK_APP_1","remark":"接入参数待业务系统确认","status":"UNCONFIGURED","appName":"福建省新生儿疾病筛查管理系统","version":1,"createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","lastCheckedAt":"2026-09-17T23:00:00.000Z","connectionStatus":"UNCONFIGURED"},{"id":"MOCK_INT_MOCK_APP_1TODO","kind":"TODO","mode":"PUSH","name":"福建省新生儿疾病筛查管理系统 · TODO","appId":"MOCK_APP_1","remark":"接入参数待业务系统确认","status":"DISABLED","appName":"福建省新生儿疾病筛查管理系统","enabled":"DISABLED","version":2,"clientId":"","protocol":"PUSH","tokenUrl":"","createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-18T14:50:14.759Z","callbackUrl":"","authorizeUrl":"","fieldMapping":{},"credentialRef":"","lastCheckedAt":"2026-09-17T22:00:00.000Z","connectionStatus":"UNCONFIGURED"},{"id":"MOCK_INT_MOCK_APP_1MESSAGE","kind":"MESSAGE","mode":"PUSH","name":"福建省新生儿疾病筛查管理系统 · MESSAGE","appId":"MOCK_APP_1","remark":"接入参数待业务系统确认","status":"ABNORMAL","appName":"福建省新生儿疾病筛查管理系统","version":1,"createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","lastCheckedAt":"2026-09-17T21:00:00.000Z","connectionStatus":"UNCONFIGURED"},{"id":"MOCK_INT_MOCK_APP_2SSO","kind":"SSO","mode":"SSO","name":"福建省妇幼卫生信息系统 · SSO","appId":"MOCK_APP_2","remark":"接入参数待业务系统确认","status":"NORMAL","appName":"福建省妇幼卫生信息系统","version":1,"createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","lastCheckedAt":"2026-09-17T23:00:00.000Z","connectionStatus":"UNCONFIGURED"},{"id":"MOCK_INT_MOCK_APP_2TODO","kind":"TODO","mode":"PUSH","name":"福建省妇幼卫生信息系统 · TODO","appId":"MOCK_APP_2","remark":"接入参数待业务系统确认","status":"ABNORMAL","appName":"福建省妇幼卫生信息系统","version":1,"createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","lastCheckedAt":"2026-09-17T22:00:00.000Z","connectionStatus":"UNCONFIGURED"},{"id":"MOCK_INT_MOCK_APP_2MESSAGE","kind":"MESSAGE","mode":"PUSH","name":"福建省妇幼卫生信息系统 · MESSAGE","appId":"MOCK_APP_2","remark":"接入参数待业务系统确认","status":"DISABLED","appName":"福建省妇幼卫生信息系统","version":1,"createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","lastCheckedAt":"2026-09-17T21:00:00.000Z","connectionStatus":"UNCONFIGURED"},{"id":"MOCK_INT_MOCK_APP_3SSO","kind":"SSO","mode":"SSO","name":"福建省产前筛查与诊断管理系统 · SSO","appId":"MOCK_APP_3","remark":"接入参数待业务系统确认","status":"ABNORMAL","appName":"福建省产前筛查与诊断管理系统","version":1,"createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","lastCheckedAt":"2026-09-17T23:00:00.000Z","connectionStatus":"UNCONFIGURED"},{"id":"MOCK_INT_MOCK_APP_3TODO","kind":"TODO","mode":"PUSH","name":"福建省产前筛查与诊断管理系统 · TODO","appId":"MOCK_APP_3","remark":"接入参数待业务系统确认","status":"DISABLED","appName":"福建省产前筛查与诊断管理系统","version":1,"createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","lastCheckedAt":"2026-09-17T22:00:00.000Z","connectionStatus":"UNCONFIGURED"},{"id":"MOCK_INT_MOCK_APP_3MESSAGE","kind":"MESSAGE","mode":"PUSH","name":"福建省产前筛查与诊断管理系统 · MESSAGE","appId":"MOCK_APP_3","remark":"接入参数待业务系统确认","status":"UNCONFIGURED","appName":"福建省产前筛查与诊断管理系统","version":1,"createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","lastCheckedAt":"2026-09-17T21:00:00.000Z","connectionStatus":"UNCONFIGURED"},{"id":"MOCK_INT_MOCK_APP_4SSO","kind":"SSO","mode":"SSO","name":"福建省地中海贫血信息管理系统 · SSO","appId":"MOCK_APP_4","remark":"接入参数待业务系统确认","status":"DISABLED","appName":"福建省地中海贫血信息管理系统","version":1,"createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","lastCheckedAt":"2026-09-17T23:00:00.000Z","connectionStatus":"UNCONFIGURED"},{"id":"MOCK_INT_MOCK_APP_4TODO","kind":"TODO","mode":"PUSH","name":"福建省地中海贫血信息管理系统 · TODO","appId":"MOCK_APP_4","remark":"接入参数待业务系统确认","status":"UNCONFIGURED","appName":"福建省地中海贫血信息管理系统","version":1,"createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","lastCheckedAt":"2026-09-17T22:00:00.000Z","connectionStatus":"UNCONFIGURED"},{"id":"MOCK_INT_MOCK_APP_4MESSAGE","kind":"MESSAGE","mode":"PUSH","name":"福建省地中海贫血信息管理系统 · MESSAGE","appId":"MOCK_APP_4","remark":"接入参数待业务系统确认","status":"NORMAL","appName":"福建省地中海贫血信息管理系统","version":1,"createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","lastCheckedAt":"2026-09-17T21:00:00.000Z","connectionStatus":"UNCONFIGURED"},{"id":"MOCK_INT_MOCK_APP_5SSO","kind":"SSO","mode":"SSO","name":"福建省慢病报告与管理系统 · SSO","appId":"MOCK_APP_5","remark":"接入参数待业务系统确认","status":"UNCONFIGURED","appName":"福建省慢病报告与管理系统","version":1,"createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","lastCheckedAt":"2026-09-17T23:00:00.000Z","connectionStatus":"UNCONFIGURED"},{"id":"MOCK_INT_MOCK_APP_5TODO","kind":"TODO","mode":"PUSH","name":"福建省慢病报告与管理系统 · TODO","appId":"MOCK_APP_5","remark":"接入参数待业务系统确认","status":"NORMAL","appName":"福建省慢病报告与管理系统","version":1,"createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","lastCheckedAt":"2026-09-17T22:00:00.000Z","connectionStatus":"UNCONFIGURED"},{"id":"MOCK_INT_MOCK_APP_5MESSAGE","kind":"MESSAGE","mode":"PUSH","name":"福建省慢病报告与管理系统 · MESSAGE","appId":"MOCK_APP_5","remark":"接入参数待业务系统确认","status":"ABNORMAL","appName":"福建省慢病报告与管理系统","version":1,"createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","lastCheckedAt":"2026-09-17T21:00:00.000Z","connectionStatus":"UNCONFIGURED"},{"id":"MOCK_INT_MOCK_APP_6SSO","kind":"SSO","mode":"SSO","name":"福建省区域影像平台 · SSO","appId":"MOCK_APP_6","remark":"接入参数待业务系统确认","status":"NORMAL","appName":"福建省区域影像平台","version":1,"createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","lastCheckedAt":"2026-09-17T23:00:00.000Z","connectionStatus":"UNCONFIGURED"},{"id":"MOCK_INT_MOCK_APP_6TODO","kind":"TODO","mode":"PUSH","name":"福建省区域影像平台 · TODO","appId":"MOCK_APP_6","remark":"接入参数待业务系统确认","status":"ABNORMAL","appName":"福建省区域影像平台","version":1,"createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","lastCheckedAt":"2026-09-17T22:00:00.000Z","connectionStatus":"UNCONFIGURED"},{"id":"MOCK_INT_MOCK_APP_6MESSAGE","kind":"MESSAGE","mode":"PUSH","name":"福建省区域影像平台 · MESSAGE","appId":"MOCK_APP_6","remark":"接入参数待业务系统确认","status":"DISABLED","appName":"福建省区域影像平台","version":1,"createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","lastCheckedAt":"2026-09-17T21:00:00.000Z","connectionStatus":"UNCONFIGURED"},{"id":"MOCK_INT_MOCK_APP_7SSO","kind":"SSO","mode":"SSO","name":"质控评分系统 · SSO","appId":"MOCK_APP_7","remark":"接入参数待业务系统确认","status":"ABNORMAL","appName":"质控评分系统","version":1,"createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","lastCheckedAt":"2026-09-17T23:00:00.000Z","connectionStatus":"UNCONFIGURED"},{"id":"MOCK_INT_MOCK_APP_7TODO","kind":"TODO","mode":"PUSH","name":"质控评分系统 · TODO","appId":"MOCK_APP_7","remark":"接入参数待业务系统确认","status":"DISABLED","appName":"质控评分系统","version":1,"createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","lastCheckedAt":"2026-09-17T22:00:00.000Z","connectionStatus":"UNCONFIGURED"},{"id":"MOCK_INT_MOCK_APP_7MESSAGE","kind":"MESSAGE","mode":"PUSH","name":"质控评分系统 · MESSAGE","appId":"MOCK_APP_7","remark":"接入参数待业务系统确认","status":"UNCONFIGURED","appName":"质控评分系统","version":1,"createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","lastCheckedAt":"2026-09-17T21:00:00.000Z","connectionStatus":"UNCONFIGURED"},{"id":"MOCK_INT_MOCK_APP_8SSO","kind":"SSO","mode":"SSO","name":"省级平台决策支持展示系统 · SSO","appId":"MOCK_APP_8","remark":"接入参数待业务系统确认","status":"DISABLED","appName":"省级平台决策支持展示系统","version":1,"createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","lastCheckedAt":"2026-09-17T23:00:00.000Z","connectionStatus":"UNCONFIGURED"},{"id":"MOCK_INT_MOCK_APP_8TODO","kind":"TODO","mode":"PUSH","name":"省级平台决策支持展示系统 · TODO","appId":"MOCK_APP_8","remark":"接入参数待业务系统确认","status":"UNCONFIGURED","appName":"省级平台决策支持展示系统","version":1,"createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","lastCheckedAt":"2026-09-17T22:00:00.000Z","connectionStatus":"UNCONFIGURED"},{"id":"MOCK_INT_MOCK_APP_8MESSAGE","kind":"MESSAGE","mode":"PUSH","name":"省级平台决策支持展示系统 · MESSAGE","appId":"MOCK_APP_8","remark":"接入参数待业务系统确认","status":"NORMAL","appName":"省级平台决策支持展示系统","version":1,"createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","lastCheckedAt":"2026-09-17T21:00:00.000Z","connectionStatus":"UNCONFIGURED"},{"id":"MOCK_INT_MOCK_APP_9SSO","kind":"SSO","mode":"SSO","name":"单点登录系统 · SSO","appId":"MOCK_APP_9","remark":"接入参数待业务系统确认","status":"UNCONFIGURED","appName":"单点登录系统","version":1,"createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","lastCheckedAt":"2026-09-17T23:00:00.000Z","connectionStatus":"UNCONFIGURED"},{"id":"MOCK_INT_MOCK_APP_9TODO","kind":"TODO","mode":"PUSH","name":"单点登录系统 · TODO","appId":"MOCK_APP_9","remark":"接入参数待业务系统确认","status":"NORMAL","appName":"单点登录系统","version":1,"createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","lastCheckedAt":"2026-09-17T22:00:00.000Z","connectionStatus":"UNCONFIGURED"},{"id":"MOCK_INT_MOCK_APP_9MESSAGE","kind":"MESSAGE","mode":"PUSH","name":"单点登录系统 · MESSAGE","appId":"MOCK_APP_9","remark":"接入参数待业务系统确认","status":"ABNORMAL","appName":"单点登录系统","version":1,"createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","lastCheckedAt":"2026-09-17T21:00:00.000Z","connectionStatus":"UNCONFIGURED"},{"id":"MOCK_INT_MOCK_APP_10SSO","kind":"SSO","mode":"SSO","name":"福建省血液信息联网平台 · SSO","appId":"MOCK_APP_10","remark":"接入参数待业务系统确认","status":"NORMAL","appName":"福建省血液信息联网平台","version":1,"createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","lastCheckedAt":"2026-09-17T23:00:00.000Z","connectionStatus":"UNCONFIGURED"},{"id":"MOCK_INT_MOCK_APP_10TODO","kind":"TODO","mode":"PUSH","name":"福建省血液信息联网平台 · TODO","appId":"MOCK_APP_10","remark":"接入参数待业务系统确认","status":"ABNORMAL","appName":"福建省血液信息联网平台","version":1,"createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","lastCheckedAt":"2026-09-17T22:00:00.000Z","connectionStatus":"UNCONFIGURED"},{"id":"MOCK_INT_MOCK_APP_10MESSAGE","kind":"MESSAGE","mode":"PUSH","name":"福建省血液信息联网平台 · MESSAGE","appId":"MOCK_APP_10","remark":"接入参数待业务系统确认","status":"DISABLED","appName":"福建省血液信息联网平台","version":1,"createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","lastCheckedAt":"2026-09-17T21:00:00.000Z","connectionStatus":"UNCONFIGURED"},{"id":"MOCK_INT_MOCK_APP_11SSO","kind":"SSO","mode":"SSO","name":"福建省免疫规划管理信息系统 · SSO","appId":"MOCK_APP_11","remark":"接入参数待业务系统确认","status":"ABNORMAL","appName":"���建省免疫规划管理信息系统","version":1,"createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","lastCheckedAt":"2026-09-17T23:00:00.000Z","connectionStatus":"UNCONFIGURED"},{"id":"MOCK_INT_MOCK_APP_11TODO","kind":"TODO","mode":"PUSH","name":"福建省免疫规划管理信息系统 · TODO","appId":"MOCK_APP_11","remark":"接入参数待业务系统确认","status":"DISABLED","appName":"福建省免疫规���管理信息系统","version":1,"createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","lastCheckedAt":"2026-09-17T22:00:00.000Z","connectionStatus":"UNCONFIGURED"},{"id":"MOCK_INT_MOCK_APP_11MESSAGE","kind":"MESSAGE","mode":"PUSH","name":"福建省免疫规划管理信息系统 · MESSAGE","appId":"MOCK_APP_11","remark":"接入参数待业务系统确认","status":"UNCONFIGURED","appName":"福建省免疫规划管理信息系统","version":1,"createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","lastCheckedAt":"2026-09-17T21:00:00.000Z","connectionStatus":"UNCONFIGURED"},{"id":"MOCK_INT_MOCK_APP_12SSO","kind":"SSO","mode":"SSO","name":"中医馆健康信息系统 · SSO","appId":"MOCK_APP_12","remark":"接入参数待业务系统确认","status":"DISABLED","appName":"中医馆健康信息系统","version":1,"createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","lastCheckedAt":"2026-09-17T23:00:00.000Z","connectionStatus":"UNCONFIGURED"},{"id":"MOCK_INT_MOCK_APP_12TODO","kind":"TODO","mode":"PUSH","name":"中医馆健康信息�����统 · TODO","appId":"MOCK_APP_12","remark":"接入参数待业务系统确认","status":"UNCONFIGURED","appName":"中医馆健康信息系统","version":1,"createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","lastCheckedAt":"2026-09-17T22:00:00.000Z","connectionStatus":"UNCONFIGURED"},{"id":"MOCK_INT_MOCK_APP_12MESSAGE","kind":"MESSAGE","mode":"PUSH","name":"中医馆健康信息系统 · MESSAGE","appId":"MOCK_APP_12","remark":"接入参数待业��系统确认","status":"NORMAL","appName":"中医馆健康信息系统","version":1,"createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","lastCheckedAt":"2026-09-17T21:00:00.000Z","connectionStatus":"UNCONFIGURED"},{"id":"MOCK_INT_MOCK_APP_13SSO","kind":"SSO","mode":"SSO","name":"福建省肝炎筛查与规范化治疗管理系统 · SSO","appId":"MOCK_APP_13","remark":"接入参数待业务系统确认","status":"UNCONFIGURED","appName":"福建省肝炎筛查与规范化治疗管理系统","version":1,"createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","lastCheckedAt":"2026-09-17T23:00:00.000Z","connectionStatus":"UNCONFIGURED"},{"id":"MOCK_INT_MOCK_APP_13TODO","kind":"TODO","mode":"PUSH","name":"福建省肝炎筛查与规范化治疗管理系统 · TODO","appId":"MOCK_APP_13","remark":"接入参数待业务系统确认","status":"NORMAL","appName":"福建省肝炎筛查与规范化治疗管理系统","version":1,"createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","lastCheckedAt":"2026-09-17T22:00:00.000Z","connectionStatus":"UNCONFIGURED"},{"id":"MOCK_INT_MOCK_APP_13MESSAGE","kind":"MESSAGE","mode":"PUSH","name":"福建省肝炎筛查与规范�������治疗管理系统 · MESSAGE","appId":"MOCK_APP_13","remark":"接入参数待业务系统确认","status":"ABNORMAL","appName":"福建省肝炎筛查与规范化治疗管理系统","version":1,"createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","lastCheckedAt":"2026-09-17T21:00:00.000Z","connectionStatus":"UNCONFIGURED"},{"id":"MOCK_INT_MOCK_APP_14SSO","kind":"SSO","mode":"SSO","name":"福建省全员人口计划生育服务与管理系统 · SSO","appId":"MOCK_APP_14","remark":"接入参数待业务系统确认","status":"NORMAL","appName":"福建省全员人口计划生育服务与管理系统","version":1,"createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","lastCheckedAt":"2026-09-17T23:00:00.000Z","connectionStatus":"UNCONFIGURED"},{"id":"MOCK_INT_MOCK_APP_14TODO","kind":"TODO","mode":"PUSH","name":"福建省全员人口计划生育服务与管理系统 · TODO","appId":"MOCK_APP_14","remark":"接入参数待业务系统确认","status":"ABNORMAL","appName":"福建省全����人��计划生育服务与管理系统","version":1,"createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","lastCheckedAt":"2026-09-17T22:00:00.000Z","connectionStatus":"UNCONFIGURED"},{"id":"MOCK_INT_MOCK_APP_14MESSAGE","kind":"MESSAGE","mode":"PUSH","name":"福建省全员人口计划生育服务与管理系统 · MESSAGE","appId":"MOCK_APP_14","remark":"接入参数待业务系统确认","status":"DISABLED","appName":"福建省全员人口计划生育服务与管理系统","version":1,"createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","lastCheckedAt":"2026-09-17T21:00:00.000Z","connectionStatus":"UNCONFIGURED"},{"id":"MOCK_INT_MOCK_APP_15SSO","kind":"SSO","mode":"SSO","name":"福建省流动人口服务与管理信息系统 · SSO","appId":"MOCK_APP_15","remark":"接入参数待业务系统确认","status":"ABNORMAL","appName":"福建省流动人口服务与管理信息系统","version":1,"createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","lastCheckedAt":"2026-09-17T23:00:00.000Z","connectionStatus":"UNCONFIGURED"},{"id":"MOCK_INT_MOCK_APP_15TODO","kind":"TODO","mode":"PUSH","name":"福建省流动人口服务与管理信息系统 · TODO","appId":"MOCK_APP_15","remark":"接入参数待业务系统确认","status":"DISABLED","appName":"福建省流动人口服务与管理信息系统","version":1,"createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","lastCheckedAt":"2026-09-17T22:00:00.000Z","connectionStatus":"UNCONFIGURED"},{"id":"MOCK_INT_MOCK_APP_15MESSAGE","kind":"MESSAGE","mode":"PUSH","name":"福建省流动人口服务与管理信息系统 · MESSAGE","appId":"MOCK_APP_15","remark":"接入参数待业务系统确认","status":"UNCONFIGURED","appName":"福建省流动人口服务与管理信息系统","version":1,"createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","lastCheckedAt":"2026-09-17T21:00:00.000Z","connectionStatus":"UNCONFIGURED"},{"id":"MOCK_INT_MOCK_APP_16SSO","kind":"SSO","mode":"SSO","name":"福建省人口计生综合服务信息平台 · SSO","appId":"MOCK_APP_16","remark":"接入参数待业务系统确认","status":"DISABLED","appName":"福建省人口计生综合服务信息平台","version":1,"createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","lastCheckedAt":"2026-09-17T23:00:00.000Z","connectionStatus":"UNCONFIGURED"},{"id":"MOCK_INT_MOCK_APP_16TODO","kind":"TODO","mode":"PUSH","name":"福建省人口计生综合服务信息平台 · TODO","appId":"MOCK_APP_16","remark":"接入参数待业务系统确认","status":"UNCONFIGURED","appName":"福建省人口计生综合服务信息平台","version":1,"createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","lastCheckedAt":"2026-09-17T22:00:00.000Z","connectionStatus":"UNCONFIGURED"},{"id":"MOCK_INT_MOCK_APP_16MESSAGE","kind":"MESSAGE","mode":"PUSH","name":"福建省人口计生综合服务信息平台 · MESSAGE","appId":"MOCK_APP_16","remark":"接入参数待业务系统确认","status":"NORMAL","appName":"福建省人口计生综合服务信息平台","version":1,"createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","lastCheckedAt":"2026-09-17T21:00:00.000Z","connectionStatus":"UNCONFIGURED"},{"id":"MOCK_INT_MOCK_APP_17SSO","kind":"SSO","mode":"SSO","name":"全员人口数据库药具发放服务管理 · SSO","appId":"MOCK_APP_17","remark":"接入参数待业务系统确认","status":"UNCONFIGURED","appName":"全员人口数据库药具发放服务管理","version":1,"createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","lastCheckedAt":"2026-09-17T23:00:00.000Z","connectionStatus":"UNCONFIGURED"},{"id":"MOCK_INT_MOCK_APP_17TODO","kind":"TODO","mode":"PUSH","name":"全员人口数据库药具发放服务管理 · TODO","appId":"MOCK_APP_17","remark":"接入参数待业务系统确认","status":"NORMAL","appName":"全员人口数据库药具发放服务管理","version":1,"createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","lastCheckedAt":"2026-09-17T22:00:00.000Z","connectionStatus":"UNCONFIGURED"},{"id":"MOCK_INT_MOCK_APP_17MESSAGE","kind":"MESSAGE","mode":"PUSH","name":"全员人口数据库药具发放服务管理 · MESSAGE","appId":"MOCK_APP_17","remark":"接入参数待业务系统确认","status":"ABNORMAL","appName":"全员人口数据库药具发放服务管理","version":1,"createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","lastCheckedAt":"2026-09-17T21:00:00.000Z","connectionStatus":"UNCONFIGURED"},{"id":"MOCK_INT_MOCK_APP_18SSO","kind":"SSO","mode":"SSO","name":"福建省互联网医院监管平台 · SSO","appId":"MOCK_APP_18","remark":"接入参数待业务系统确认","status":"NORMAL","appName":"福建省互联网医院监管平台","version":1,"createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","lastCheckedAt":"2026-09-17T23:00:00.000Z","connectionStatus":"UNCONFIGURED"},{"id":"MOCK_INT_MOCK_APP_18TODO","kind":"TODO","mode":"PUSH","name":"福建省互联网医院监管平台 · TODO","appId":"MOCK_APP_18","remark":"接入参数待业务系统确认","status":"ABNORMAL","appName":"福建省互联网医院监管平台","version":1,"createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","lastCheckedAt":"2026-09-17T22:00:00.000Z","connectionStatus":"UNCONFIGURED"},{"id":"MOCK_INT_MOCK_APP_18MESSAGE","kind":"MESSAGE","mode":"PUSH","name":"福建省互联网医院监管平台 · MESSAGE","appId":"MOCK_APP_18","remark":"接入参数待业务系统确认","status":"DISABLED","appName":"福建省互联网医院监管平台","version":1,"createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","lastCheckedAt":"2026-09-17T21:00:00.000Z","connectionStatus":"UNCONFIGURED"},{"id":"MOCK_INT_MOCK_APP_19SSO","kind":"SSO","mode":"SSO","name":"省医改效果监测管理系统 · SSO","appId":"MOCK_APP_19","remark":"接入参数待业务系统确认","status":"ABNORMAL","appName":"省医改效果监测管理系统","version":1,"createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","lastCheckedAt":"2026-09-17T23:00:00.000Z","connectionStatus":"UNCONFIGURED"},{"id":"MOCK_INT_MOCK_APP_19TODO","kind":"TODO","mode":"PUSH","name":"省医改效果监测管理系统 · TODO","appId":"MOCK_APP_19","remark":"接入参数待业务系统确认","status":"DISABLED","appName":"省医改效果监测管理系统","version":1,"createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","lastCheckedAt":"2026-09-17T22:00:00.000Z","connectionStatus":"UNCONFIGURED"},{"id":"MOCK_INT_MOCK_APP_19MESSAGE","kind":"MESSAGE","mode":"PUSH","name":"省医改效果监测管理系统 · MESSAGE","appId":"MOCK_APP_19","remark":"接入参数待业务系统确认","status":"UNCONFIGURED","appName":"省医改效果监测管理系统","version":1,"createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","lastCheckedAt":"2026-09-17T21:00:00.000Z","connectionStatus":"UNCONFIGURED"},{"id":"MOCK_INT_MOCK_APP_20SSO","kind":"SSO","mode":"SSO","name":"省属公立医院运营监管系统 · SSO","appId":"MOCK_APP_20","remark":"接入参数待业务系统确认","status":"DISABLED","appName":"省属公立医院运营监管系统","version":1,"createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","lastCheckedAt":"2026-09-17T23:00:00.000Z","connectionStatus":"UNCONFIGURED"},{"id":"MOCK_INT_MOCK_APP_20TODO","kind":"TODO","mode":"PUSH","name":"省属公立医院运营监管系统 · TODO","appId":"MOCK_APP_20","remark":"接入参数待业务系统确认","status":"UNCONFIGURED","appName":"省属公立医院运营监管系统","version":1,"createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","lastCheckedAt":"2026-09-17T22:00:00.000Z","connectionStatus":"UNCONFIGURED"},{"id":"MOCK_INT_MOCK_APP_20MESSAGE","kind":"MESSAGE","mode":"PUSH","name":"省属公立医院运营监管系统 · MESSAGE","appId":"MOCK_APP_20","remark":"接入参数待业务系统确认","status":"NORMAL","appName":"省属公立医院运营监管系统","version":1,"createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","lastCheckedAt":"2026-09-17T21:00:00.000Z","connectionStatus":"UNCONFIGURED"},{"id":"MOCK_INT_MOCK_APP_21SSO","kind":"SSO","mode":"SSO","name":"福建省公立医院绩效考核系统 · SSO","appId":"MOCK_APP_21","remark":"接入参数待业务系统确认","status":"UNCONFIGURED","appName":"福建省公立医院绩效考核系统","version":1,"createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","lastCheckedAt":"2026-09-17T23:00:00.000Z","connectionStatus":"UNCONFIGURED"},{"id":"MOCK_INT_MOCK_APP_21TODO","kind":"TODO","mode":"PUSH","name":"福建省公立医院绩效考核系统 · TODO","appId":"MOCK_APP_21","remark":"接入参数待业务系统确认","status":"NORMAL","appName":"福建省公立医院绩效考核系统","version":1,"createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","lastCheckedAt":"2026-09-17T22:00:00.000Z","connectionStatus":"UNCONFIGURED"},{"id":"MOCK_INT_MOCK_APP_21MESSAGE","kind":"MESSAGE","mode":"PUSH","name":"福建省公立医院绩效考核系统 · MESSAGE","appId":"MOCK_APP_21","remark":"接入参数待业务系统确认","status":"ABNORMAL","appName":"福建省公立医院绩效考核系统","version":1,"createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","lastCheckedAt":"2026-09-17T21:00:00.000Z","connectionStatus":"UNCONFIGURED"},{"id":"MOCK_INT_MOCK_APP_22SSO","kind":"SSO","mode":"SSO","name":"财务管理系统 · SSO","appId":"MOCK_APP_22","remark":"接入参数待业务系统确认","status":"NORMAL","appName":"财务管理系统","version":1,"createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","lastCheckedAt":"2026-09-17T23:00:00.000Z","connectionStatus":"UNCONFIGURED"},{"id":"MOCK_INT_MOCK_APP_22TODO","kind":"TODO","mode":"PUSH","name":"财务管理系统 · TODO","appId":"MOCK_APP_22","remark":"接入参数待业务系统确认","status":"ABNORMAL","appName":"财务管理系统","version":1,"createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","lastCheckedAt":"2026-09-17T22:00:00.000Z","connectionStatus":"UNCONFIGURED"},{"id":"MOCK_INT_MOCK_APP_22MESSAGE","kind":"MESSAGE","mode":"PUSH","name":"财务管理系统 · MESSAGE","appId":"MOCK_APP_22","remark":"接入参数待业务系统确认","status":"DISABLED","appName":"财务管理系统","version":1,"createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","lastCheckedAt":"2026-09-17T21:00:00.000Z","connectionStatus":"UNCONFIGURED"},{"id":"MOCK_INT_MOCK_APP_23SSO","kind":"SSO","mode":"SSO","name":"医疗技术临床应用管理信息系统 · SSO","appId":"MOCK_APP_23","remark":"接入参数待业务系统确认","status":"ABNORMAL","appName":"医疗技术临床应用管理信息系统","version":1,"createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","lastCheckedAt":"2026-09-17T23:00:00.000Z","connectionStatus":"UNCONFIGURED"},{"id":"MOCK_INT_MOCK_APP_23TODO","kind":"TODO","mode":"PUSH","name":"医疗技术临床应用管理信息系统 · TODO","appId":"MOCK_APP_23","remark":"接入参数待业务系统确认","status":"DISABLED","appName":"医疗技术临床应用管理信息系统","version":1,"createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","lastCheckedAt":"2026-09-17T22:00:00.000Z","connectionStatus":"UNCONFIGURED"},{"id":"MOCK_INT_MOCK_APP_23MESSAGE","kind":"MESSAGE","mode":"PUSH","name":"医疗技术临床应用管理信息系统 · MESSAGE","appId":"MOCK_APP_23","remark":"接入参数待业务系统确认","status":"UNCONFIGURED","appName":"医疗技术临床应用管理信息系统","version":1,"createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","lastCheckedAt":"2026-09-17T21:00:00.000Z","connectionStatus":"UNCONFIGURED"},{"id":"MOCK_INT_MOCK_APP_24SSO","kind":"SSO","mode":"SSO","name":"住院医师专科医师培训及一体化系统 · SSO","appId":"MOCK_APP_24","remark":"接入参数待业务系统确认","status":"DISABLED","appName":"住院医师专科医师培训及一体化系统","version":1,"createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","lastCheckedAt":"2026-09-17T23:00:00.000Z","connectionStatus":"UNCONFIGURED"},{"id":"MOCK_INT_MOCK_APP_24TODO","kind":"TODO","mode":"PUSH","name":"住院医师专科医师培训及一体化系统 · TODO","appId":"MOCK_APP_24","remark":"接入参数待业务系统确认","status":"UNCONFIGURED","appName":"住院医师专科医师培训及一体化系统","version":1,"createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","lastCheckedAt":"2026-09-17T22:00:00.000Z","connectionStatus":"UNCONFIGURED"},{"id":"MOCK_INT_MOCK_APP_24MESSAGE","kind":"MESSAGE","mode":"PUSH","name":"住院医师专科医师培训及一体化系统 · MESSAGE","appId":"MOCK_APP_24","remark":"接入参数待业务系统确认","status":"NORMAL","appName":"住院医师专科医师培训及一体化系统","version":1,"createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","lastCheckedAt":"2026-09-17T21:00:00.000Z","connectionStatus":"UNCONFIGURED"},{"id":"MOCK_INT_MOCK_APP_25SSO","kind":"SSO","mode":"SSO","name":"福建省中医医师规范化培训管理平台 · SSO","appId":"MOCK_APP_25","remark":"接入参数待业务系统确认","status":"UNCONFIGURED","appName":"福建省中医医师规范化培训管理平台","version":1,"createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","lastCheckedAt":"2026-09-17T23:00:00.000Z","connectionStatus":"UNCONFIGURED"},{"id":"MOCK_INT_MOCK_APP_25TODO","kind":"TODO","mode":"PUSH","name":"福建省中医医师规范化培训管理平台 · TODO","appId":"MOCK_APP_25","remark":"接入参数待业务系统确认","status":"NORMAL","appName":"福建省中医医师规范化培训管理平台","version":1,"createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","lastCheckedAt":"2026-09-17T22:00:00.000Z","connectionStatus":"UNCONFIGURED"},{"id":"MOCK_INT_MOCK_APP_25MESSAGE","kind":"MESSAGE","mode":"PUSH","name":"福建省中医医师规范化培训管理平台 · MESSAGE","appId":"MOCK_APP_25","remark":"接入参数待业务系统确认","status":"ABNORMAL","appName":"福建省中医医师规范化培训管理平台","version":1,"createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","lastCheckedAt":"2026-09-17T21:00:00.000Z","connectionStatus":"UNCONFIGURED"},{"id":"MOCK_INT_MOCK_APP_26SSO","kind":"SSO","mode":"SSO","name":"福建省中医医术确有专长人员医师资格考核报名系统 · SSO","appId":"MOCK_APP_26","remark":"接入参数待业务系统确认","status":"NORMAL","appName":"福建省中医医术确有专长人员医师资格考核报名系统","version":1,"createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","lastCheckedAt":"2026-09-17T23:00:00.000Z","connectionStatus":"UNCONFIGURED"},{"id":"MOCK_INT_MOCK_APP_26TODO","kind":"TODO","mode":"PUSH","name":"福建省中医医术确有专长人员医师资格考核报名系统 · TODO","appId":"MOCK_APP_26","remark":"接入参数待业务系统确认","status":"ABNORMAL","appName":"福建省中医医术确有专长人员医师资格考核报名系统","version":1,"createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","lastCheckedAt":"2026-09-17T22:00:00.000Z","connectionStatus":"UNCONFIGURED"},{"id":"MOCK_INT_MOCK_APP_26MESSAGE","kind":"MESSAGE","mode":"PUSH","name":"福建省中医医术确有专长人员医师资格考核报名系统 · MESSAGE","appId":"MOCK_APP_26","remark":"接入参数待业务系统确认","status":"DISABLED","appName":"福建省中医医术确有专长人员医师资格考核报名系统","version":1,"createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","lastCheckedAt":"2026-09-17T21:00:00.000Z","connectionStatus":"UNCONFIGURED"},{"id":"MOCK_INT_MOCK_APP_27SSO","kind":"SSO","mode":"SSO","name":"福建省卫生健康科技计划项目管理信息系统 · SSO","appId":"MOCK_APP_27","remark":"接入参数待业务系统确认","status":"ABNORMAL","appName":"福建省卫生健康科技计划项目管理信息系统","version":1,"createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","lastCheckedAt":"2026-09-17T23:00:00.000Z","connectionStatus":"UNCONFIGURED"},{"id":"MOCK_INT_MOCK_APP_27TODO","kind":"TODO","mode":"PUSH","name":"福建省卫生健康科技计划项目管理信息系统 · TODO","appId":"MOCK_APP_27","remark":"接入参数待业务系统确认","status":"DISABLED","appName":"福建省卫生健康科技计划项目管理信息系统","version":1,"createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","lastCheckedAt":"2026-09-17T22:00:00.000Z","connectionStatus":"UNCONFIGURED"},{"id":"MOCK_INT_MOCK_APP_27MESSAGE","kind":"MESSAGE","mode":"PUSH","name":"福建省卫生健康科技计划项目管理信息系统 · MESSAGE","appId":"MOCK_APP_27","remark":"接入参数待业务系统确认","status":"UNCONFIGURED","appName":"福建省卫生健康科技计划项目管理信息系统","version":1,"createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","lastCheckedAt":"2026-09-17T21:00:00.000Z","connectionStatus":"UNCONFIGURED"},{"id":"MOCK_INT_MOCK_APP_28SSO","kind":"SSO","mode":"SSO","name":"福建省卫生专业技术资格考试报名系统 · SSO","appId":"MOCK_APP_28","remark":"接入参数待业务系统确认","status":"DISABLED","appName":"福建省卫生专业技术资格考试报名系统","version":1,"createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","lastCheckedAt":"2026-09-17T23:00:00.000Z","connectionStatus":"UNCONFIGURED"},{"id":"MOCK_INT_MOCK_APP_28TODO","kind":"TODO","mode":"PUSH","name":"福建省卫生专业技术资格考试报名系统 · TODO","appId":"MOCK_APP_28","remark":"接入参数待业务系统确认","status":"UNCONFIGURED","appName":"福建省卫生专业技术资格考试报名系统","version":1,"createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","lastCheckedAt":"2026-09-17T22:00:00.000Z","connectionStatus":"UNCONFIGURED"},{"id":"MOCK_INT_MOCK_APP_28MESSAGE","kind":"MESSAGE","mode":"PUSH","name":"福建省卫生专业技术资格考试报名系统 · MESSAGE","appId":"MOCK_APP_28","remark":"接入参数待业务系统确认","status":"NORMAL","appName":"福建省卫生专业技术资格考试报名系统","version":1,"createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","lastCheckedAt":"2026-09-17T21:00:00.000Z","connectionStatus":"UNCONFIGURED"},{"id":"MOCK_INT_MOCK_APP_29SSO","kind":"SSO","mode":"SSO","name":"国家卫生健康信息统计直报系统 · SSO","appId":"MOCK_APP_29","remark":"接入参数待业务系统确认","status":"UNCONFIGURED","appName":"国家卫生健康信息统计直报系统","version":1,"createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","lastCheckedAt":"2026-09-17T23:00:00.000Z","connectionStatus":"UNCONFIGURED"},{"id":"MOCK_INT_MOCK_APP_29TODO","kind":"TODO","mode":"PUSH","name":"国家卫生健康信息统计直报系统 · TODO","appId":"MOCK_APP_29","remark":"接入参数待业务系统确认","status":"NORMAL","appName":"国家卫生健康信息统计直报系统","version":1,"createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","lastCheckedAt":"2026-09-17T22:00:00.000Z","connectionStatus":"UNCONFIGURED"},{"id":"MOCK_INT_MOCK_APP_29MESSAGE","kind":"MESSAGE","mode":"PUSH","name":"国家卫生健康信息统计直报系统 · MESSAGE","appId":"MOCK_APP_29","remark":"接入参数待业务系统确认","status":"ABNORMAL","appName":"国家卫生健康信息统计直报系统","version":1,"createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","lastCheckedAt":"2026-09-17T21:00:00.000Z","connectionStatus":"UNCONFIGURED"},{"id":"MOCK_INT_MOCK_APP_30SSO","kind":"SSO","mode":"SSO","name":"福建省集中消毒餐具追溯系统 · SSO","appId":"MOCK_APP_30","remark":"接入参数待业务系统确认","status":"NORMAL","appName":"福建省集中消毒餐具追溯系统","version":1,"createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","lastCheckedAt":"2026-09-17T23:00:00.000Z","connectionStatus":"UNCONFIGURED"},{"id":"MOCK_INT_MOCK_APP_30TODO","kind":"TODO","mode":"PUSH","name":"福建省集中消毒餐具追溯系统 · TODO","appId":"MOCK_APP_30","remark":"接入参数待业务系统确认","status":"ABNORMAL","appName":"福建省集中消毒餐具追溯系统","version":1,"createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","lastCheckedAt":"2026-09-17T22:00:00.000Z","connectionStatus":"UNCONFIGURED"},{"id":"MOCK_INT_MOCK_APP_30MESSAGE","kind":"MESSAGE","mode":"PUSH","name":"福建省集中消毒餐具追溯系统 · MESSAGE","appId":"MOCK_APP_30","remark":"接入参数待业务系统确认","status":"DISABLED","appName":"福建省集中消毒餐具追溯系统","version":1,"createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","lastCheckedAt":"2026-09-17T21:00:00.000Z","connectionStatus":"UNCONFIGURED"},{"id":"MOCK_INT_MOCK_APP_31SSO","kind":"SSO","mode":"SSO","name":"福建省职业病防治综合管理系统 · SSO","appId":"MOCK_APP_31","remark":"接入参数待业务系统确认","status":"ABNORMAL","appName":"福建省职业病防治综合管理系统","version":1,"createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","lastCheckedAt":"2026-09-17T23:00:00.000Z","connectionStatus":"UNCONFIGURED"},{"id":"MOCK_INT_MOCK_APP_31TODO","kind":"TODO","mode":"PUSH","name":"福建省职业病防治综合管理系统 · TODO","appId":"MOCK_APP_31","remark":"接入参数待业务系统确认","status":"DISABLED","appName":"福建省职业病防治综合管理系统","version":1,"createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","lastCheckedAt":"2026-09-17T22:00:00.000Z","connectionStatus":"UNCONFIGURED"},{"id":"MOCK_INT_MOCK_APP_31MESSAGE","kind":"MESSAGE","mode":"PUSH","name":"福建省职业病防治综合管理系统 · MESSAGE","appId":"MOCK_APP_31","remark":"接入参数待业务系统确认","status":"UNCONFIGURED","appName":"福建省职业病防治综合管理系统","version":1,"createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","lastCheckedAt":"2026-09-17T21:00:00.000Z","connectionStatus":"UNCONFIGURED"},{"id":"MOCK_INT_MOCK_APP_32SSO","kind":"SSO","mode":"SSO","name":"福建省保健对象医疗管理信息系统 · SSO","appId":"MOCK_APP_32","remark":"接入参数待业务系统确认","status":"DISABLED","appName":"福建省保健对象医疗管理信息系统","version":1,"createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","lastCheckedAt":"2026-09-17T23:00:00.000Z","connectionStatus":"UNCONFIGURED"},{"id":"MOCK_INT_MOCK_APP_32TODO","kind":"TODO","mode":"PUSH","name":"福建省保健对象医疗管理信息系统 · TODO","appId":"MOCK_APP_32","remark":"接入参数待业务系统确认","status":"UNCONFIGURED","appName":"福建省保健对象医疗管理信息系统","version":1,"createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","lastCheckedAt":"2026-09-17T22:00:00.000Z","connectionStatus":"UNCONFIGURED"},{"id":"MOCK_INT_MOCK_APP_32MESSAGE","kind":"MESSAGE","mode":"PUSH","name":"福建省保健对象医疗管理信息系统 · MESSAGE","appId":"MOCK_APP_32","remark":"接入参数待业务系统确认","status":"NORMAL","appName":"福建省保健对象医疗管理信息系统","version":1,"createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","lastCheckedAt":"2026-09-17T21:00:00.000Z","connectionStatus":"UNCONFIGURED"},{"id":"MOCK_INT_MOCK_APP_33SSO","kind":"SSO","mode":"SSO","name":"福建省职业病与化学中毒预防控制中心门户网站 · SSO","appId":"MOCK_APP_33","remark":"接入参数待业务系统确认","status":"UNCONFIGURED","appName":"福建省职业病与化学中毒预防控制中心门户网站","version":1,"createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","lastCheckedAt":"2026-09-17T23:00:00.000Z","connectionStatus":"UNCONFIGURED"},{"id":"MOCK_INT_MOCK_APP_33TODO","kind":"TODO","mode":"PUSH","name":"福建省职业病与化学中毒预防控制中心门户网站 · TODO","appId":"MOCK_APP_33","remark":"接入参数待业务系统确认","status":"NORMAL","appName":"福建省职业病与化学中毒预防控制中心门户网站","version":1,"createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","lastCheckedAt":"2026-09-17T22:00:00.000Z","connectionStatus":"UNCONFIGURED"},{"id":"MOCK_INT_MOCK_APP_33MESSAGE","kind":"MESSAGE","mode":"PUSH","name":"福建省职业病与化学中毒预防控制中心门户网站 · MESSAGE","appId":"MOCK_APP_33","remark":"接入参数待业务系统确认","status":"ABNORMAL","appName":"福建省�����业病与化学中毒预防控制中心门户网站","version":1,"createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","lastCheckedAt":"2026-09-17T21:00:00.000Z","connectionStatus":"UNCONFIGURED"},{"id":"MOCK_INT_MOCK_APP_34SSO","kind":"SSO","mode":"SSO","name":"福建省卫生监督电子执法全过程记录系统 · SSO","appId":"MOCK_APP_34","remark":"接入参数待业务系统确认","status":"NORMAL","appName":"福建省卫生���督���子执法全过程记录系统","version":1,"createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","lastCheckedAt":"2026-09-17T23:00:00.000Z","connectionStatus":"UNCONFIGURED"},{"id":"MOCK_INT_MOCK_APP_34TODO","kind":"TODO","mode":"PUSH","name":"福建省卫生监督电子执法全过程记录系统 · TODO","appId":"MOCK_APP_34","remark":"接入参数待业务系统确认","status":"ABNORMAL","appName":"福建省卫生监督电子执法全过程记录系统","version":1,"createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","lastCheckedAt":"2026-09-17T22:00:00.000Z","connectionStatus":"UNCONFIGURED"},{"id":"MOCK_INT_MOCK_APP_34MESSAGE","kind":"MESSAGE","mode":"PUSH","name":"福建省卫生监督电子执法全过程记录系统 · MESSAGE","appId":"MOCK_APP_34","remark":"接入参数待业务系统确认","status":"DISABLED","appName":"福建省卫生监督电子执法全过程记录系统","version":1,"createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","lastCheckedAt":"2026-09-17T21:00:00.000Z","connectionStatus":"UNCONFIGURED"},{"id":"MOCK_INT_MOCK_APP_35SSO","kind":"SSO","mode":"SSO","name":"福建省医疗卫生信用信息归集系统 · SSO","appId":"MOCK_APP_35","remark":"接入参数待业务系统确认","status":"ABNORMAL","appName":"福建省医疗卫生信用信息归集系统","version":1,"createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","lastCheckedAt":"2026-09-17T23:00:00.000Z","connectionStatus":"UNCONFIGURED"},{"id":"MOCK_INT_MOCK_APP_35TODO","kind":"TODO","mode":"PUSH","name":"福建省医疗卫生信用信息归集系统 · TODO","appId":"MOCK_APP_35","remark":"接入参数待业务系统确认","status":"DISABLED","appName":"福建���医疗卫生信用信息归集系统","version":1,"createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","lastCheckedAt":"2026-09-17T22:00:00.000Z","connectionStatus":"UNCONFIGURED"},{"id":"MOCK_INT_MOCK_APP_35MESSAGE","kind":"MESSAGE","mode":"PUSH","name":"福建省医疗卫生信用信息归集系统 · MESSAGE","appId":"MOCK_APP_35","remark":"接入参数待业务系统确认","status":"UNCONFIGURED","appName":"福建省医疗卫生信用信息归集系统","version":1,"createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","lastCheckedAt":"2026-09-17T21:00:00.000Z","connectionStatus":"UNCONFIGURED"},{"id":"MOCK_INT_MOCK_APP_36SSO","kind":"SSO","mode":"SSO","name":"福建�����医疗卫生不良执业记分系统 · SSO","appId":"MOCK_APP_36","remark":"接入参数待业务系统确认","status":"DISABLED","appName":"福建省医疗卫生不良执业记分系统","version":1,"createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","lastCheckedAt":"2026-09-17T23:00:00.000Z","connectionStatus":"UNCONFIGURED"},{"id":"MOCK_INT_MOCK_APP_36TODO","kind":"TODO","mode":"PUSH","name":"福建省医疗卫生不良执业记分系统 · TODO","appId":"MOCK_APP_36","remark":"接入参数待业务系统确认","status":"UNCONFIGURED","appName":"福建省医疗卫生不良执业记分系统","version":1,"createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","lastCheckedAt":"2026-09-17T22:00:00.000Z","connectionStatus":"UNCONFIGURED"},{"id":"MOCK_INT_MOCK_APP_36MESSAGE","kind":"MESSAGE","mode":"PUSH","name":"福建省医疗卫生不良执业记分系统 · MESSAGE","appId":"MOCK_APP_36","remark":"接入参数待业务系统确认","status":"NORMAL","appName":"福建省医疗卫生不良执业记分系统","version":1,"createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","lastCheckedAt":"2026-09-17T21:00:00.000Z","connectionStatus":"UNCONFIGURED"},{"id":"MOCK_INT_MOCK_APP_37SSO","kind":"SSO","mode":"SSO","name":"福建省诊所诊疗监督系统 · SSO","appId":"MOCK_APP_37","remark":"接入参数待业务系统确认","status":"UNCONFIGURED","appName":"福建省���所诊疗监督系统","version":1,"createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","lastCheckedAt":"2026-09-17T23:00:00.000Z","connectionStatus":"UNCONFIGURED"},{"id":"MOCK_INT_MOCK_APP_37TODO","kind":"TODO","mode":"PUSH","name":"福建省诊所诊疗监督系统 · TODO","appId":"MOCK_APP_37","remark":"接入参数待业务系统确认","status":"NORMAL","appName":"福建省诊所诊���监督系统","version":1,"createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","lastCheckedAt":"2026-09-17T22:00:00.000Z","connectionStatus":"UNCONFIGURED"},{"id":"MOCK_INT_MOCK_APP_37MESSAGE","kind":"MESSAGE","mode":"PUSH","name":"福建省诊所诊疗监督系统 · MESSAGE","appId":"MOCK_APP_37","remark":"接入参数待业务系统确认","status":"ABNORMAL","appName":"福建省诊所��疗监督系统","version":1,"createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","lastCheckedAt":"2026-09-17T21:00:00.000Z","connectionStatus":"UNCONFIGURED"},{"id":"MOCK_INT_MOCK_APP_38SSO","kind":"SSO","mode":"SSO","name":"福建省医疗服务资质检测系统 · SSO","appId":"MOCK_APP_38","remark":"接入参数待业务系统确认","status":"NORMAL","appName":"福建省医疗服务资质检测系统","version":1,"createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","lastCheckedAt":"2026-09-17T23:00:00.000Z","connectionStatus":"UNCONFIGURED"},{"id":"MOCK_INT_MOCK_APP_38TODO","kind":"TODO","mode":"PUSH","name":"福建省医疗服务资质检测系统 · TODO","appId":"MOCK_APP_38","remark":"接入参数待业务系统确认","status":"ABNORMAL","appName":"福建省医疗服务资质检测系统","version":1,"createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","lastCheckedAt":"2026-09-17T22:00:00.000Z","connectionStatus":"UNCONFIGURED"},{"id":"MOCK_INT_MOCK_APP_38MESSAGE","kind":"MESSAGE","mode":"PUSH","name":"福建省医疗服务资质检测系统 · MESSAGE","appId":"MOCK_APP_38","remark":"接入参数待业务系统确认","status":"DISABLED","appName":"福建省医疗服务资质检测系统","version":1,"createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","lastCheckedAt":"2026-09-17T21:00:00.000Z","connectionStatus":"UNCONFIGURED"},{"id":"MOCK_INT_MOCK_APP_39SSO","kind":"SSO","mode":"SSO","name":"福建省食源性疾病省级平台系统 · SSO","appId":"MOCK_APP_39","remark":"接入参数待业务系统确认","status":"ABNORMAL","appName":"福建省食源性疾病省级平台系统","version":1,"createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","lastCheckedAt":"2026-09-17T23:00:00.000Z","connectionStatus":"UNCONFIGURED"},{"id":"MOCK_INT_MOCK_APP_39TODO","kind":"TODO","mode":"PUSH","name":"福建省食源性疾病省级平台系统 · TODO","appId":"MOCK_APP_39","remark":"接入参数待业务系统确认","status":"DISABLED","appName":"福建省食源性疾病省级平台系统","version":1,"createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","lastCheckedAt":"2026-09-17T22:00:00.000Z","connectionStatus":"UNCONFIGURED"},{"id":"MOCK_INT_MOCK_APP_39MESSAGE","kind":"MESSAGE","mode":"PUSH","name":"福建省食源性疾病省级平台系统 · MESSAGE","appId":"MOCK_APP_39","remark":"接入参数待业务系统确认","status":"UNCONFIGURED","appName":"福建省食源性疾病省级平台系统","version":1,"createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","lastCheckedAt":"2026-09-17T21:00:00.000Z","connectionStatus":"UNCONFIGURED"},{"id":"MOCK_INT_MOCK_APP_40SSO","kind":"SSO","mode":"SSO","name":"福建省疾病预防控制中心信息门户系统 · SSO","appId":"MOCK_APP_40","remark":"接入参数待业务系统确认","status":"DISABLED","appName":"福建省疾病预防控制中心信息门户系统","version":1,"createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","lastCheckedAt":"2026-09-17T23:00:00.000Z","connectionStatus":"UNCONFIGURED"},{"id":"MOCK_INT_MOCK_APP_40TODO","kind":"TODO","mode":"PUSH","name":"福建省疾病预防控制中心信息门户系统 · TODO","appId":"MOCK_APP_40","remark":"接入参数待业务系统确认","status":"UNCONFIGURED","appName":"福建省疾病预防控制中心信息门户系统","version":1,"createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","lastCheckedAt":"2026-09-17T22:00:00.000Z","connectionStatus":"UNCONFIGURED"},{"id":"MOCK_INT_MOCK_APP_40MESSAGE","kind":"MESSAGE","mode":"PUSH","name":"福建省疾病预防控制中心信息门户系统 · MESSAGE","appId":"MOCK_APP_40","remark":"接入参数待业务系统确认","status":"NORMAL","appName":"福建省疾病预防控制中心信息门户系统","version":1,"createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","lastCheckedAt":"2026-09-17T21:00:00.000Z","connectionStatus":"UNCONFIGURED"},{"id":"MOCK_INT_MOCK_APP_41SSO","kind":"SSO","mode":"SSO","name":"福建省慢性病防控指标系统 · SSO","appId":"MOCK_APP_41","remark":"接入参数待业务系统确认","status":"UNCONFIGURED","appName":"福建省慢性病防控指标系统","version":1,"createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","lastCheckedAt":"2026-09-17T23:00:00.000Z","connectionStatus":"UNCONFIGURED"},{"id":"MOCK_INT_MOCK_APP_41TODO","kind":"TODO","mode":"PUSH","name":"福建省慢性病防控指标系统 · TODO","appId":"MOCK_APP_41","remark":"接入参数待业务系统确认","status":"NORMAL","appName":"福建省慢性病防控指标系统","version":1,"createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","lastCheckedAt":"2026-09-17T22:00:00.000Z","connectionStatus":"UNCONFIGURED"},{"id":"MOCK_INT_MOCK_APP_41MESSAGE","kind":"MESSAGE","mode":"PUSH","name":"福建省慢性病防控指标系统 · MESSAGE","appId":"MOCK_APP_41","remark":"接入参数待业务系统确认","status":"ABNORMAL","appName":"福建省慢性病防控指标系统","version":1,"createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","lastCheckedAt":"2026-09-17T21:00:00.000Z","connectionStatus":"UNCONFIGURED"},{"id":"MOCK_INT_MOCK_APP_43SSO","kind":"SSO","mode":"SSO","name":"福建省疫苗冷链监测系统 · SSO","appId":"MOCK_APP_43","remark":"接入参数待业务系统确认","status":"DISABLED","appName":"福建省疫苗冷链监测系统","version":1,"createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","lastCheckedAt":"2026-09-17T23:00:00.000Z","connectionStatus":"UNCONFIGURED"},{"id":"MOCK_INT_MOCK_APP_43TODO","kind":"TODO","mode":"PUSH","name":"福建省疫苗冷链监测系统 · TODO","appId":"MOCK_APP_43","remark":"接入参数待业务系统确认","status":"DISABLED","appName":"福建省疫苗冷链监测系统","version":1,"createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","lastCheckedAt":"2026-09-17T22:00:00.000Z","connectionStatus":"UNCONFIGURED"},{"id":"MOCK_INT_MOCK_APP_43MESSAGE","kind":"MESSAGE","mode":"PUSH","name":"福建省疫苗冷链监测系统 · MESSAGE","appId":"MOCK_APP_43","remark":"接入参数待业务系统确认","status":"DISABLED","appName":"福建省疫苗冷链监测系统","version":1,"createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","lastCheckedAt":"2026-09-17T21:00:00.000Z","connectionStatus":"UNCONFIGURED"}],"announcements":[{"id":"MOCK_ANN_1","type":"通知","scope":"ALL","title":"关于门户服务使用安排的通知","orgKey":null,"status":"PUBLISHED","content":"请通过应用中心查看服务入口，业务办理要求以来源系统说明为准。","orgName":null,"version":1,"createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","visibility":"SCOPE","attachments":[],"publishedAt":"2026-09-17T00:00:00.000Z","publisherId":"MOCK_EDITOR","effectiveEnd":null,"effectiveStart":"2026-09-17T00:00:00.000Z","identitySource":null},{"id":"MOCK_ANN_2","type":"通知","scope":"GOV","title":"关于完善应用接入资料的通知","orgKey":null,"status":"DRAFT","content":"请整理应用目录、责任分工与接口字段，提交接入资料核验。","orgName":null,"version":1,"createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","visibility":"SCOPE","attachments":[],"publishedAt":null,"publisherId":null,"effectiveEnd":null,"effectiveStart":null,"identitySource":null},{"id":"MOCK_ANN_3","type":"通知","scope":"CITIZEN","title":"公众服务事项办理指引","orgKey":null,"status":"PUBLISHED","content":"请在办事前核对材料清单，关注待办与消息中的办理要求。","orgName":null,"version":1,"createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","visibility":"SCOPE","attachments":[],"publishedAt":"2026-09-16T22:00:00.000Z","publisherId":"MOCK_EDITOR","effectiveEnd":null,"effectiveStart":"2026-09-16T22:00:00.000Z","identitySource":null},{"id":"MOCK_ANN_4","type":"通知","scope":"GOV","title":"卫生健康统计报送安排","orgKey":null,"status":"PUBLISHED","content":"请核对本期统计报表，并在规定期限内完成报送。","orgName":null,"version":1,"createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","visibility":"SCOPE","attachments":[],"publishedAt":"2026-09-16T21:00:00.000Z","publisherId":"MOCK_EDITOR","effectiveEnd":null,"effectiveStart":"2026-09-16T21:00:00.000Z","identitySource":null},{"id":"MOCK_ANN_5","type":"通知","scope":"ORG","title":"运行保障值班安排","orgKey":"PORTAL","status":"DRAFT","content":"请核对值班分工，及时记录运行问题与处理情况。","orgName":"门户运行保障中心","version":1,"createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","visibility":"ADMIN_ONLY","attachments":[],"publishedAt":null,"publisherId":null,"effectiveEnd":null,"effectiveStart":null,"identitySource":"闽政务"},{"id":"MOCK_ANN_6","type":"通知","scope":"ORG","title":"信息发布审核工作安排","orgKey":"PORTAL","status":"DRAFT","content":"发布前须核对内容、发布范围与有效期。","orgName":"门户运行保障中心","version":1,"createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","visibility":"ADMIN_ONLY","attachments":[],"publishedAt":null,"publisherId":null,"effectiveEnd":null,"effectiveStart":null,"identitySource":"闽政务"},{"id":"MOCK_ANN_7","type":"通知","scope":"ALL","title":"原维护时段安排撤回通知","orgKey":null,"status":"WITHDRAWN","content":"原维护时段安排已撤回，后续安排另行通知。","orgName":null,"version":1,"createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","visibility":"SCOPE","attachments":[],"publishedAt":"2026-09-16T18:00:00.000Z","publisherId":"MOCK_EDITOR","effectiveEnd":null,"effectiveStart":"2026-09-16T18:00:00.000Z","identitySource":null},{"id":"MOCK_ANN_8","type":"提示","scope":"ALL","title":"个人信息保护提示","orgKey":null,"status":"PUBLISHED","content":"请妥善保管账号，勿向他人提供验证码或身份核验资料。","orgName":null,"version":1,"createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","visibility":"SCOPE","attachments":[],"publishedAt":"2026-09-16T17:00:00.000Z","publisherId":"MOCK_EDITOR","effectiveEnd":null,"effectiveStart":"2026-09-16T17:00:00.000Z","identitySource":null}],"schemaVersion":3,"announcementReads":[{"readAt":"2026-09-18T14:49:12.945Z","userId":"MOCK_USER_1","announcementId":"MOCK_ANN_1"},{"readAt":"2026-09-18T14:49:28.247Z","userId":"MOCK_USER_1","announcementId":"MOCK_ANN_3"},{"readAt":"2026-09-18T16:13:46.074Z","userId":"MOCK_ADMIN","announcementId":"MOCK_ANN_1"}],"announcementTrash":[{"id":"MOCK_e734e220-0e95-4b44-b923-8e1b3cc8cb51","type":"通知","scope":"ALL","title":"P4验收草稿删除","status":"DRAFT","content":"仅用于本次新增删除验收","version":1,"createdAt":"2026-09-18T14:50:12.746Z","deletedAt":"2026-09-18T14:50:13.407Z","deletedBy":"MOCK_ADMIN","updatedAt":"2026-09-18T14:50:12.746Z","attachments":[],"publishedAt":null,"deleteReason":"DRAFT_DELETE","effectiveEnd":null,"effectiveStart":null}]}	json	CONFIGURED	Backup before 20260919 native sync
13	\N	\N	\N	\N	\N	P4FIX_CONFIG_0	2026-09-18 00:00:00+00	2026-09-18 17:28:40.527+00	3	P4FIX_retention.message_days	90	day	CONFIGURED	消息留存周期（天）
14	\N	\N	\N	\N	\N	P4FIX_CONFIG_1	2026-09-18 00:00:00+00	2026-09-18 17:28:40.527+00	3	P4FIX_retention.todo_terminal_days	180	day	CONFIGURED	终态待办留存周期（天）
15	\N	\N	\N	\N	\N	P4FIX_CONFIG_2	2026-09-18 00:00:00+00	2026-09-18 17:28:40.527+00	3	P4FIX_retention.log_days	180	day	CONFIGURED	日志留存周期（天）
16	\N	\N	\N	\N	\N	P4FIX_CONFIG_3	2026-09-18 00:00:00+00	2026-09-18 17:28:40.527+00	3	P4FIX_auth.session_ttl_seconds	7200	second	CONFIGURED	会话有效期（秒）
17	\N	\N	\N	\N	\N	P4FIX_CONFIG_4	2026-09-18 00:00:00+00	2026-09-18 17:28:40.527+00	3	P4FIX_integration.timeout_ms	5000	millisecond	CONFIGURED	接口超时（毫秒）
18	\N	\N	\N	\N	\N	P4FIX_CONFIG_5	2026-09-18 00:00:00+00	2026-09-18 17:28:40.527+00	3	P4FIX_integration.max_retries	3	count	CONFIGURED	接口重试上限
19	\N	\N	\N	\N	\N	P4FIX_CONFIG_6	2026-09-18 00:00:00+00	2026-09-18 17:28:40.527+00	3	P4FIX_monitor.failure_threshold	5	count	CONFIGURED	连续失败告警阈值
21	\N	\N	\N	\N	\N	P4RUN_STATE	2026-09-18 14:47:13.906633+00	2026-09-23 13:41:52.783981+00	237	P4_RUNTIME_STATE_V1	{"apps":[{"id":"MOCK_APP_1","url":"https://p4.invalid/app/1","code":"WJ_APP_01","name":"福建省新生儿疾病筛查管理系统","status":"ENABLED","version":1,"category":"公众服务","sourceNo":1,"userType":"BOTH","createdAt":"2026-09-18T00:00:00+00:00","sortOrder":1,"updatedAt":"2026-09-17T23:00:00+00:00","accessMode":"DIRECT","categoryId":"MOCK_CAT_1","platformId":"MOCK_PLATFORM_1","platformNo":1,"description":"管理新生儿筛查登记、结果反馈、阳性召回与随访。","networkZone":"政务外网(卫健专网)","mockScenario":"DIRECT","platformName":"福建省全民健康信息平台","postGrantMode":"DIRECT","runtimeStatus":"UNCONFIGURED","integrationNote":"服务地址与接入参数待配置","connectionStatus":"UNCONFIGURED","accountBindingMode":"ADMIN","accountOpeningMode":"NONE","enabled":true,"allowedOrigins":[],"bindingMethods":["SELF","ADMIN"]},{"id":"MOCK_APP_2","url":"https://p4.invalid/app/2","code":"WJ_APP_02","name":"福建省妇幼卫生信息系统","status":"ENABLED","version":1,"category":"公众服务","sourceNo":2,"userType":"BOTH","createdAt":"2026-09-18T00:00:00+00:00","sortOrder":2,"updatedAt":"2026-09-17T23:00:00+00:00","accessMode":"BIND","categoryId":"MOCK_CAT_1","platformId":"MOCK_PLATFORM_1","platformNo":1,"description":"汇集妇女儿童保健记录，支持孕产期管理及妇幼统计。","networkZone":"政务外网(卫健专网)","mockScenario":"AUTO_BIND","platformName":"福建省全民健康信息平台","postGrantMode":"DIRECT","runtimeStatus":"UNCONFIGURED","integrationNote":"服务地址与接入参数待配置","connectionStatus":"UNCONFIGURED","accountBindingMode":"AUTO","accountOpeningMode":"NONE","enabled":true,"allowedOrigins":[],"bindingMethods":["SELF","ADMIN"]},{"id":"MOCK_APP_3","url":"https://p4.invalid/app/3","code":"WJ_APP_03","name":"福建省产前筛查与诊断管理系统","status":"ENABLED","version":1,"category":"政务协同","sourceNo":3,"userType":"BOTH","createdAt":"2026-09-18T00:00:00+00:00","sortOrder":3,"updatedAt":"2026-09-17T23:00:00+00:00","accessMode":"BIND","categoryId":"MOCK_CAT_2","platformId":"MOCK_PLATFORM_1","platformNo":1,"description":"管理产前筛查、风险评估、诊断转介与随访。","networkZone":"政务外网(卫健专网)","mockScenario":"OTP_BIND","platformName":"福建省全民健康信息平台","postGrantMode":"DIRECT","runtimeStatus":"UNCONFIGURED","integrationNote":"服务地址与接入参数待配置","connectionStatus":"UNCONFIGURED","accountBindingMode":"SELF","accountOpeningMode":"NONE","enabled":true,"allowedOrigins":[],"bindingMethods":["SELF","ADMIN"]},{"id":"MOCK_APP_4","url":"https://p4.invalid/app/4","code":"WJ_APP_04","name":"福建省地中海贫血信息管理系统","status":"ENABLED","version":1,"category":"政务协同","sourceNo":4,"userType":"BOTH","createdAt":"2026-09-18T00:00:00+00:00","sortOrder":4,"updatedAt":"2026-09-17T23:00:00+00:00","accessMode":"BIND","categoryId":"MOCK_CAT_2","platformId":"MOCK_PLATFORM_1","platformNo":1,"description":"管理地中海贫血筛查、检测结果与遗传咨询。","networkZone":"政务外网(卫健专网)","mockScenario":"CREDENTIAL_BIND","platformName":"福建省全民健康信息平台","postGrantMode":"DIRECT","runtimeStatus":"UNCONFIGURED","integrationNote":"服务地址与接入参数待配置","connectionStatus":"UNCONFIGURED","accountBindingMode":"SELF","accountOpeningMode":"NONE","enabled":true,"allowedOrigins":[],"bindingMethods":["SELF","ADMIN"]},{"id":"MOCK_APP_5","url":"https://p4.invalid/app/5","code":"WJ_APP_05","name":"福建省慢病报告与管理系统","status":"ENABLED","version":1,"category":"政务协同","sourceNo":5,"userType":"BOTH","createdAt":"2026-09-18T00:00:00+00:00","sortOrder":5,"updatedAt":"2026-09-17T23:00:00+00:00","accessMode":"BIND","categoryId":"MOCK_CAT_2","platformId":"MOCK_PLATFORM_1","platformNo":1,"description":"汇总慢性病报告，支持病例核查与随访管理。","networkZone":"政务外网(卫健专网)","mockScenario":"REVIEW_BIND","platformName":"福建省全民健康信息平台","postGrantMode":"DIRECT","runtimeStatus":"UNCONFIGURED","integrationNote":"服务地址与接入参数待配置","connectionStatus":"UNCONFIGURED","accountBindingMode":"REVIEW","accountOpeningMode":"NONE","enabled":true,"allowedOrigins":[],"bindingMethods":["SELF","ADMIN"]},{"id":"MOCK_APP_6","url":"https://p4.invalid/app/6","code":"WJ_APP_06","name":"福建省区域影像平台","status":"ENABLED","version":1,"category":"政务协同","sourceNo":6,"userType":"BOTH","createdAt":"2026-09-18T00:00:00+00:00","sortOrder":6,"updatedAt":"2026-09-17T23:00:00+00:00","accessMode":"BIND","categoryId":"MOCK_CAT_2","platformId":"MOCK_PLATFORM_1","platformNo":1,"description":"汇集区域医学影像，支持影像调阅与诊疗协作。","networkZone":"政务外网(卫健专网)","mockScenario":"NO_ACCOUNT","platformName":"福建省全民健康信息平台","postGrantMode":"DIRECT","runtimeStatus":"UNCONFIGURED","integrationNote":"服务地址与接入参数待配置","connectionStatus":"UNCONFIGURED","accountBindingMode":"SELF","accountOpeningMode":"REQUEST","enabled":true,"allowedOrigins":[],"bindingMethods":["SELF","ADMIN"]},{"id":"MOCK_APP_7","url":"https://p4.invalid/app/7","code":"WJ_APP_07","name":"质控评分系统","status":"ENABLED","version":1,"category":"政务协同","sourceNo":7,"userType":"GOV","createdAt":"2026-09-18T00:00:00+00:00","sortOrder":7,"updatedAt":"2026-09-17T23:00:00+00:00","accessMode":"BIND","categoryId":"MOCK_CAT_2","platformId":"MOCK_PLATFORM_1","platformNo":1,"description":"管理质量控制指标、评分记录及问题整改。","networkZone":"政务外网(卫健专网)","mockScenario":"BOUND_EXISTING","platformName":"福建省全民健康信息平台","postGrantMode":"DIRECT","runtimeStatus":"UNCONFIGURED","integrationNote":"服务地址与接入参数待配置","connectionStatus":"UNCONFIGURED","accountBindingMode":"ADMIN","accountOpeningMode":"NONE","enabled":true,"allowedOrigins":[],"bindingMethods":["SELF","ADMIN"]},{"id":"MOCK_APP_8","url":"https://p4.invalid/app/8","code":"WJ_APP_08","name":"省级平台决策支持展示系统","status":"ENABLED","version":1,"category":"政务协同","sourceNo":8,"userType":"GOV","createdAt":"2026-09-18T00:00:00+00:00","sortOrder":8,"updatedAt":"2026-09-17T23:00:00+00:00","accessMode":"BIND","categoryId":"MOCK_CAT_2","platformId":"MOCK_PLATFORM_1","platformNo":1,"description":"汇总卫生健康指标，支持资源配置与管理决策。","networkZone":"政务外网(卫健专网)","mockScenario":"BOUND_EXISTING","platformName":"福建省全民健康信息平台","postGrantMode":"DIRECT","runtimeStatus":"UNCONFIGURED","integrationNote":"服务地址与接入参数待配置","connectionStatus":"UNCONFIGURED","accountBindingMode":"ADMIN","accountOpeningMode":"NONE","enabled":true,"allowedOrigins":[],"bindingMethods":["SELF","ADMIN"]},{"id":"MOCK_APP_9","url":"https://p4.invalid/app/9","code":"WJ_APP_09","name":"单点登录系统","status":"ENABLED","version":1,"category":"政务协同","sourceNo":9,"userType":"GOV","createdAt":"2026-09-18T00:00:00+00:00","sortOrder":9,"updatedAt":"2026-09-17T23:00:00+00:00","accessMode":"BIND","categoryId":"MOCK_CAT_2","platformId":"MOCK_PLATFORM_1","platformNo":1,"description":"衔接统一登录与应用访问，管理身份关联和访问审计。","networkZone":"政务外网(卫健专网)","mockScenario":"BOUND_EXISTING","platformName":"福建省全民健康信息平台","postGrantMode":"DIRECT","runtimeStatus":"UNCONFIGURED","integrationNote":"服务地址与接入参数待配置","connectionStatus":"UNCONFIGURED","accountBindingMode":"ADMIN","accountOpeningMode":"NONE","enabled":true,"allowedOrigins":[],"bindingMethods":["SELF","ADMIN"]},{"id":"MOCK_APP_10","url":"https://p4.invalid/app/10","code":"WJ_APP_10","name":"福建省血液信息联网平台","status":"ENABLED","version":1,"category":"政务协同","sourceNo":10,"userType":"GOV","createdAt":"2026-09-18T00:00:00+00:00","sortOrder":10,"updatedAt":"2026-09-17T23:00:00+00:00","accessMode":"BIND","categoryId":"MOCK_CAT_2","platformId":"MOCK_PLATFORM_1","platformNo":1,"description":"汇集采供血信息，支持血液资源协同与质量追溯。","networkZone":"政务外网","mockScenario":"BOUND_EXISTING","platformName":"福建省全民健康信息平台","postGrantMode":"DIRECT","runtimeStatus":"UNCONFIGURED","integrationNote":"服务地址与接入参数待配置","connectionStatus":"UNCONFIGURED","accountBindingMode":"ADMIN","accountOpeningMode":"NONE","enabled":true,"allowedOrigins":[],"bindingMethods":["SELF","ADMIN"]},{"id":"MOCK_APP_11","url":"https://p4.invalid/app/11","code":"WJ_APP_11","name":"福建省免疫规划管理信息系统","status":"ENABLED","version":1,"category":"政务协同","sourceNo":11,"userType":"BOTH","createdAt":"2026-09-18T00:00:00+00:00","sortOrder":11,"updatedAt":"2026-09-17T23:00:00+00:00","accessMode":"BIND","categoryId":"MOCK_CAT_2","platformId":"MOCK_PLATFORM_1","platformNo":1,"description":"管理免疫规划接种记录、接种安排与覆盖统计。","networkZone":"政务外网(卫健专网)","mockScenario":"ACCOUNT_DISABLED","platformName":"福建省全民健康信息平台","postGrantMode":"DIRECT","runtimeStatus":"UNCONFIGURED","integrationNote":"服务地址与接入参数待配置","connectionStatus":"UNCONFIGURED","accountBindingMode":"SELF","accountOpeningMode":"NONE","enabled":true,"allowedOrigins":[],"bindingMethods":["SELF","ADMIN"]},{"id":"MOCK_APP_12","url":"https://p4.invalid/app/12","code":"WJ_APP_12","name":"中医馆健康信息系统","status":"ENABLED","version":1,"category":"政务协同","sourceNo":12,"userType":"BOTH","createdAt":"2026-09-18T00:00:00+00:00","sortOrder":12,"updatedAt":"2026-09-17T23:00:00+00:00","accessMode":"BIND","categoryId":"MOCK_CAT_2","platformId":"MOCK_PLATFORM_1","platformNo":1,"description":"管理中医馆服务记录，支持中医诊疗与健康管理协同。","networkZone":"政务外网(卫健专网)","mockScenario":"CONFLICT","platformName":"福建省全民健康信息平台","postGrantMode":"DIRECT","runtimeStatus":"UNCONFIGURED","integrationNote":"服务地址与接入参数待配置","connectionStatus":"UNCONFIGURED","accountBindingMode":"SELF","accountOpeningMode":"NONE","enabled":true,"allowedOrigins":[],"bindingMethods":["SELF","ADMIN"]},{"id":"MOCK_APP_13","url":"https://p4.invalid/app/13","code":"WJ_APP_13","name":"福建省肝炎筛查与规范化治疗管理系统","status":"ENABLED","version":1,"category":"政务协同","sourceNo":13,"userType":"BOTH","createdAt":"2026-09-18T00:00:00+00:00","sortOrder":13,"updatedAt":"2026-09-17T23:00:00+00:00","accessMode":"REQUEST","categoryId":"MOCK_CAT_2","platformId":"MOCK_PLATFORM_1","platformNo":1,"description":"管理肝炎筛查、诊断转介、规范化治疗及随访。","networkZone":"政务外网(卫健专网)","mockScenario":"REQUEST_DIRECT","platformName":"福建省全民健康信息平台","postGrantMode":"DIRECT","runtimeStatus":"UNCONFIGURED","integrationNote":"服务地址与接入参数待配置","connectionStatus":"UNCONFIGURED","accountBindingMode":"ADMIN","accountOpeningMode":"NONE","enabled":true,"allowedOrigins":[],"bindingMethods":["SELF","ADMIN"]},{"id":"MOCK_APP_14","url":"https://p4.invalid/app/14","code":"WJ_APP_14","name":"福建省全员人口计划生育服务与管理系统","status":"ENABLED","version":1,"category":"政务协同","sourceNo":14,"userType":"GOV","createdAt":"2026-09-18T00:00:00+00:00","sortOrder":14,"updatedAt":"2026-09-17T23:00:00+00:00","accessMode":"BIND","categoryId":"MOCK_CAT_2","platformId":"MOCK_PLATFORM_2","platformNo":2,"description":"维护人口服务信息，支持计划生育服务登记与核验。","networkZone":"政务外网(卫健专网)","mockScenario":"BOUND_EXISTING","platformName":"福建省全员人口计划生育服务与管理平台","postGrantMode":"DIRECT","runtimeStatus":"UNCONFIGURED","integrationNote":"服务地址与接入参数待配置","connectionStatus":"UNCONFIGURED","accountBindingMode":"ADMIN","accountOpeningMode":"NONE","enabled":true,"allowedOrigins":[],"bindingMethods":["SELF","ADMIN"]},{"id":"MOCK_APP_15","url":"https://p4.invalid/app/15","code":"WJ_APP_15","name":"福建省流动人口服务与管理信息系统","status":"ENABLED","version":1,"category":"政务协同","sourceNo":15,"userType":"GOV","createdAt":"2026-09-18T00:00:00+00:00","sortOrder":15,"updatedAt":"2026-09-17T23:00:00+00:00","accessMode":"BIND","categoryId":"MOCK_CAT_2","platformId":"MOCK_PLATFORM_2","platformNo":2,"description":"管理流动人口服务登记及跨区域协作事项。","networkZone":"政务外网(卫健专网)","mockScenario":"BOUND_EXISTING","platformName":"福建省全员人口计划生育服务与管理平台","postGrantMode":"DIRECT","runtimeStatus":"UNCONFIGURED","integrationNote":"服务地址与接入参数待配置","connectionStatus":"UNCONFIGURED","accountBindingMode":"ADMIN","accountOpeningMode":"NONE","enabled":true,"allowedOrigins":[],"bindingMethods":["SELF","ADMIN"]},{"id":"MOCK_APP_16","url":"https://p4.invalid/app/16","code":"WJ_APP_16","name":"福建省人口计生综合服务信息平台","status":"ENABLED","version":1,"category":"政务协同","sourceNo":16,"userType":"GOV","createdAt":"2026-09-18T00:00:00+00:00","sortOrder":16,"updatedAt":"2026-09-17T23:00:00+00:00","accessMode":"BIND","categoryId":"MOCK_CAT_2","platformId":"MOCK_PLATFORM_2","platformNo":2,"description":"汇集人口计生服务事项，支持综合查询与协同。","networkZone":"政务外网(卫健专网)","mockScenario":"BOUND_EXISTING","platformName":"福建省全员人口计划生育服务与管理平台","postGrantMode":"DIRECT","runtimeStatus":"UNCONFIGURED","integrationNote":"服务地址与接入参数待配置","connectionStatus":"UNCONFIGURED","accountBindingMode":"ADMIN","accountOpeningMode":"NONE","enabled":true,"allowedOrigins":[],"bindingMethods":["SELF","ADMIN"]},{"id":"MOCK_APP_17","url":"https://p4.invalid/app/17","code":"WJ_APP_17","name":"全员人口数据库药具发放服务管理","status":"ENABLED","version":1,"category":"政务协同","sourceNo":17,"userType":"BOTH","createdAt":"2026-09-18T00:00:00+00:00","sortOrder":17,"updatedAt":"2026-09-17T23:00:00+00:00","accessMode":"REQUEST","categoryId":"MOCK_CAT_2","platformId":"MOCK_PLATFORM_2","platformNo":2,"description":"管理药具需求、库存、发放登记与服务统计。","networkZone":"互联网","mockScenario":"REQUEST_BIND","platformName":"福建省全员人口计划生育服务与管理平台","postGrantMode":"BIND","runtimeStatus":"UNCONFIGURED","integrationNote":"服务地址与接入参数待配置","connectionStatus":"UNCONFIGURED","accountBindingMode":"SELF","accountOpeningMode":"NONE","enabled":true,"allowedOrigins":[],"bindingMethods":["SELF","ADMIN"]},{"id":"MOCK_APP_18","url":"https://p4.invalid/app/18","code":"WJ_APP_18","name":"福建省互联网医院监管平台","status":"ENABLED","version":1,"category":"行业监管","sourceNo":18,"userType":"GOV","createdAt":"2026-09-18T00:00:00+00:00","sortOrder":18,"updatedAt":"2026-09-17T23:00:00+00:00","accessMode":"BIND","categoryId":"MOCK_CAT_3","platformId":"MOCK_PLATFORM_3","platformNo":3,"description":"汇集互联网医院信息，支持资质核验与诊疗监管。","networkZone":"政务外网","mockScenario":"BOUND_EXISTING","platformName":"福建省卫健委综合监管平台","postGrantMode":"DIRECT","runtimeStatus":"UNCONFIGURED","integrationNote":"服务地址与接入参数待配置","connectionStatus":"UNCONFIGURED","accountBindingMode":"ADMIN","accountOpeningMode":"NONE","enabled":true,"allowedOrigins":[],"bindingMethods":["SELF","ADMIN"]},{"id":"MOCK_APP_19","url":"https://p4.invalid/app/19","code":"WJ_APP_19","name":"省医改效果监测管理系统","status":"ENABLED","version":1,"category":"行业监管","sourceNo":19,"userType":"GOV","createdAt":"2026-09-18T00:00:00+00:00","sortOrder":19,"updatedAt":"2026-09-17T23:00:00+00:00","accessMode":"BIND","categoryId":"MOCK_CAT_3","platformId":"MOCK_PLATFORM_3","platformNo":3,"description":"管理医改指标填报、数据核验及改革成效分析。","networkZone":"政务外网(卫健专网)","mockScenario":"BOUND_EXISTING","platformName":"福建省卫健委综合监管平台","postGrantMode":"DIRECT","runtimeStatus":"UNCONFIGURED","integrationNote":"服务地址与接入参数待配置","connectionStatus":"UNCONFIGURED","accountBindingMode":"ADMIN","accountOpeningMode":"NONE","enabled":true,"allowedOrigins":[],"bindingMethods":["SELF","ADMIN"]},{"id":"MOCK_APP_20","url":"https://p4.invalid/app/20","code":"WJ_APP_20","name":"省属公立医院运营监管系统","status":"ENABLED","version":1,"category":"行业监管","sourceNo":20,"userType":"GOV","createdAt":"2026-09-18T00:00:00+00:00","sortOrder":20,"updatedAt":"2026-09-17T23:00:00+00:00","accessMode":"BIND","categoryId":"MOCK_CAT_3","platformId":"MOCK_PLATFORM_3","platformNo":3,"description":"汇集医院运营指标，支持运行监测与异常核查。","networkZone":"政务外网(卫健专网)","mockScenario":"BOUND_EXISTING","platformName":"福建省卫健委综合监管平台","postGrantMode":"DIRECT","runtimeStatus":"UNCONFIGURED","integrationNote":"服务地址与接入参数待配置","connectionStatus":"UNCONFIGURED","accountBindingMode":"ADMIN","accountOpeningMode":"NONE","enabled":true,"allowedOrigins":[],"bindingMethods":["SELF","ADMIN"]},{"id":"MOCK_APP_21","url":"https://p4.invalid/app/21","code":"WJ_APP_21","name":"福建省公立医院绩效考核系统","status":"ENABLED","version":1,"category":"行业监管","sourceNo":21,"userType":"GOV","createdAt":"2026-09-18T00:00:00+00:00","sortOrder":21,"updatedAt":"2026-09-17T23:00:00+00:00","accessMode":"BIND","categoryId":"MOCK_CAT_3","platformId":"MOCK_PLATFORM_3","platformNo":3,"description":"管理医院绩效填报、考核资料与评价结果。","networkZone":"互联网","mockScenario":"BOUND_EXISTING","platformName":"福建省卫健委综合监管平台","postGrantMode":"DIRECT","runtimeStatus":"UNCONFIGURED","integrationNote":"服务地址与接入参数待配置","connectionStatus":"UNCONFIGURED","accountBindingMode":"ADMIN","accountOpeningMode":"NONE","enabled":true,"allowedOrigins":[],"bindingMethods":["SELF","ADMIN"]},{"id":"MOCK_APP_22","url":"https://p4.invalid/app/22","code":"WJ_APP_22","name":"财务管理系统","status":"ENABLED","version":1,"category":"行业监管","sourceNo":22,"userType":"GOV","createdAt":"2026-09-18T00:00:00+00:00","sortOrder":22,"updatedAt":"2026-09-17T23:00:00+00:00","accessMode":"BIND","categoryId":"MOCK_CAT_3","platformId":"MOCK_PLATFORM_3","platformNo":3,"description":"管理财务报表、预算执行信息与收支核对。","networkZone":"政务外网","mockScenario":"BOUND_EXISTING","platformName":"福建省卫健委综合监管平台","postGrantMode":"DIRECT","runtimeStatus":"UNCONFIGURED","integrationNote":"服务地址与接入参数待配置","connectionStatus":"UNCONFIGURED","accountBindingMode":"ADMIN","accountOpeningMode":"NONE","enabled":true,"allowedOrigins":[],"bindingMethods":["SELF","ADMIN"]},{"id":"MOCK_APP_23","url":"https://p4.invalid/app/23","code":"WJ_APP_23","name":"医疗技术临床应用管理信息系统","status":"ENABLED","version":1,"category":"行业监管","sourceNo":23,"userType":"GOV","createdAt":"2026-09-18T00:00:00+00:00","sortOrder":23,"updatedAt":"2026-09-17T23:00:00+00:00","accessMode":"BIND","categoryId":"MOCK_CAT_3","platformId":"MOCK_PLATFORM_3","platformNo":3,"description":"管理医疗技术应用备案、质量信息与规范执行情况。","networkZone":"政务外网(卫健专网)","mockScenario":"BOUND_EXISTING","platformName":"福建省卫健委综合监管平台","postGrantMode":"DIRECT","runtimeStatus":"UNCONFIGURED","integrationNote":"服务地址与接入参数待配置","connectionStatus":"UNCONFIGURED","accountBindingMode":"ADMIN","accountOpeningMode":"NONE","enabled":true,"allowedOrigins":[],"bindingMethods":["SELF","ADMIN"]},{"id":"MOCK_APP_24","url":"https://p4.invalid/app/24","code":"WJ_APP_24","name":"住院医师专科医师培训及一体化系统","status":"ENABLED","version":1,"category":"培训考试","sourceNo":24,"userType":"BOTH","createdAt":"2026-09-18T00:00:00+00:00","sortOrder":24,"updatedAt":"2026-09-17T23:00:00+00:00","accessMode":"BIND","categoryId":"MOCK_CAT_4","platformId":"MOCK_PLATFORM_3","platformNo":3,"description":"管理医师培训报名、轮转安排与考核记录。","networkZone":"互联网","mockScenario":"BOUND_EXISTING","platformName":"福建省卫健委综合监管平台","postGrantMode":"DIRECT","runtimeStatus":"UNCONFIGURED","integrationNote":"服务地址与接入参数待配置","connectionStatus":"UNCONFIGURED","accountBindingMode":"ADMIN","accountOpeningMode":"NONE","enabled":true,"allowedOrigins":[],"bindingMethods":["SELF","ADMIN"]},{"id":"MOCK_APP_25","url":"https://p4.invalid/app/25","code":"WJ_APP_25","name":"福建省中医医师规范化培训管理平台","status":"ENABLED","version":1,"category":"培训考试","sourceNo":25,"userType":"BOTH","createdAt":"2026-09-18T00:00:00+00:00","sortOrder":25,"updatedAt":"2026-09-17T23:00:00+00:00","accessMode":"BIND","categoryId":"MOCK_CAT_4","platformId":"MOCK_PLATFORM_3","platformNo":3,"description":"管理中医医师培训计划、过程记录及结业考核。","networkZone":"互联网","mockScenario":"BOUND_EXISTING","platformName":"福建省卫健委综合监管平台","postGrantMode":"DIRECT","runtimeStatus":"UNCONFIGURED","integrationNote":"服务地址与接入参数待配置","connectionStatus":"UNCONFIGURED","accountBindingMode":"ADMIN","accountOpeningMode":"NONE","enabled":true,"allowedOrigins":[],"bindingMethods":["SELF","ADMIN"]},{"id":"MOCK_APP_26","url":"https://p4.invalid/app/26","code":"WJ_APP_26","name":"福建省中医医术确有专长人员医师资格考核报名系统","status":"ENABLED","version":1,"category":"培训考试","sourceNo":26,"userType":"BOTH","createdAt":"2026-09-18T00:00:00+00:00","sortOrder":26,"updatedAt":"2026-09-17T23:00:00+00:00","accessMode":"BIND","categoryId":"MOCK_CAT_4","platformId":"MOCK_PLATFORM_3","platformNo":3,"description":"管理中医专长医师考核报名、材料补正与资格审核。","networkZone":"互联网","mockScenario":"BOUND_EXISTING","platformName":"福建省卫健委综合监管平台","postGrantMode":"DIRECT","runtimeStatus":"UNCONFIGURED","integrationNote":"服务地址与接入参数待配置","connectionStatus":"UNCONFIGURED","accountBindingMode":"ADMIN","accountOpeningMode":"NONE","enabled":true,"allowedOrigins":[],"bindingMethods":["SELF","ADMIN"]},{"id":"MOCK_APP_27","url":"https://p4.invalid/app/27","code":"WJ_APP_27","name":"福建省卫生健康科技计划项目管理信息系统","status":"ENABLED","version":1,"category":"培训考试","sourceNo":27,"userType":"GOV","createdAt":"2026-09-18T00:00:00+00:00","sortOrder":27,"updatedAt":"2026-09-17T23:00:00+00:00","accessMode":"BIND","categoryId":"MOCK_CAT_4","platformId":"MOCK_PLATFORM_3","platformNo":3,"description":"管理科技项目申报、评审、过程检查及验收。","networkZone":"政务外网互联网区","mockScenario":"BOUND_EXISTING","platformName":"福建省卫健委综合监管平台","postGrantMode":"DIRECT","runtimeStatus":"UNCONFIGURED","integrationNote":"服务地址与接入参数待配置","connectionStatus":"UNCONFIGURED","accountBindingMode":"ADMIN","accountOpeningMode":"NONE","enabled":true,"allowedOrigins":[],"bindingMethods":["SELF","ADMIN"]},{"id":"MOCK_APP_28","url":"https://p4.invalid/app/28","code":"WJ_APP_28","name":"福建省卫生专业技术资格考试报名系统","status":"ENABLED","version":1,"category":"培训考试","sourceNo":28,"userType":"BOTH","createdAt":"2026-09-18T00:00:00+00:00","sortOrder":28,"updatedAt":"2026-09-17T23:00:00+00:00","accessMode":"BIND","categoryId":"MOCK_CAT_4","platformId":"MOCK_PLATFORM_3","platformNo":3,"description":"管理卫生资格考试报名、资料核验及通知。","networkZone":"互联网","mockScenario":"BOUND_EXISTING","platformName":"福建省卫健委综合监管平台","postGrantMode":"DIRECT","runtimeStatus":"UNCONFIGURED","integrationNote":"服务地址与接入参数待配置","connectionStatus":"UNCONFIGURED","accountBindingMode":"ADMIN","accountOpeningMode":"NONE","enabled":true,"allowedOrigins":[],"bindingMethods":["SELF","ADMIN"]},{"id":"MOCK_APP_29","url":"https://p4.invalid/app/29","code":"WJ_APP_29","name":"国家卫生健康信息统计直报系统","status":"ENABLED","version":1,"category":"行业监管","sourceNo":29,"userType":"GOV","createdAt":"2026-09-18T00:00:00+00:00","sortOrder":29,"updatedAt":"2026-09-17T23:00:00+00:00","accessMode":"BIND","categoryId":"MOCK_CAT_3","platformId":"MOCK_PLATFORM_3","platformNo":3,"description":"支持卫生统计报表填报、审核、汇总与直报。","networkZone":"互联网","mockScenario":"BOUND_EXISTING","platformName":"福建省卫健委综合监管平台","postGrantMode":"DIRECT","runtimeStatus":"UNCONFIGURED","integrationNote":"服务地址与接入参数待配置","connectionStatus":"UNCONFIGURED","accountBindingMode":"ADMIN","accountOpeningMode":"NONE","enabled":true,"allowedOrigins":[],"bindingMethods":["SELF","ADMIN"]},{"id":"MOCK_APP_30","url":"https://p4.invalid/app/30","code":"WJ_APP_30","name":"福建省集中消毒餐具追溯系统","status":"ENABLED","version":1,"category":"行业监管","sourceNo":30,"userType":"GOV","createdAt":"2026-09-18T00:00:00+00:00","sortOrder":30,"updatedAt":"2026-09-17T23:00:00+00:00","accessMode":"BIND","categoryId":"MOCK_CAT_3","platformId":"MOCK_PLATFORM_3","platformNo":3,"description":"管理消毒餐具批次、检验信息与流向追溯。","networkZone":"政务外网互联网区","mockScenario":"BOUND_EXISTING","platformName":"福建省卫健委综合监管平台","postGrantMode":"DIRECT","runtimeStatus":"UNCONFIGURED","integrationNote":"服务地址与接入参数待配置","connectionStatus":"UNCONFIGURED","accountBindingMode":"ADMIN","accountOpeningMode":"NONE","enabled":true,"allowedOrigins":[],"bindingMethods":["SELF","ADMIN"]},{"id":"MOCK_APP_31","url":"https://p4.invalid/app/31","code":"WJ_APP_31","name":"福建省职业病防治综合管理系统","status":"ENABLED","version":1,"category":"行业监管","sourceNo":31,"userType":"GOV","createdAt":"2026-09-18T00:00:00+00:00","sortOrder":31,"updatedAt":"2026-09-17T23:00:00+00:00","accessMode":"BIND","categoryId":"MOCK_CAT_3","platformId":"MOCK_PLATFORM_3","platformNo":3,"description":"汇集职业病防治信息，支持监测报告与防治协作。","networkZone":"政务外网互联网区","mockScenario":"BOUND_EXISTING","platformName":"福建省卫健委综合监管平台","postGrantMode":"DIRECT","runtimeStatus":"UNCONFIGURED","integrationNote":"服务地址与接入参数待配置","connectionStatus":"UNCONFIGURED","accountBindingMode":"ADMIN","accountOpeningMode":"NONE","enabled":true,"allowedOrigins":[],"bindingMethods":["SELF","ADMIN"]},{"id":"MOCK_APP_32","url":"https://p4.invalid/app/32","code":"WJ_APP_32","name":"福建省保健对象医疗管理信息系统","status":"ENABLED","version":1,"category":"行业监管","sourceNo":32,"userType":"GOV","createdAt":"2026-09-18T00:00:00+00:00","sortOrder":32,"updatedAt":"2026-09-17T23:00:00+00:00","accessMode":"BIND","categoryId":"MOCK_CAT_3","platformId":"MOCK_PLATFORM_4","platformNo":4,"description":"管理保健服务安排、医疗保障事项及服务记录。","networkZone":"政务外网(卫健专网)","mockScenario":"BOUND_EXISTING","platformName":"福建省保健对象医疗管理信息系统","postGrantMode":"DIRECT","runtimeStatus":"UNCONFIGURED","integrationNote":"服务地址与接入参数待配置","connectionStatus":"UNCONFIGURED","accountBindingMode":"ADMIN","accountOpeningMode":"NONE","enabled":true,"allowedOrigins":[],"bindingMethods":["SELF","ADMIN"]},{"id":"MOCK_APP_33","url":"https://p4.invalid/app/33","code":"WJ_APP_33","name":"福建省职业病与化学中毒预防控制中心门户网站","status":"ENABLED","version":1,"category":"行业监管","sourceNo":33,"userType":"BOTH","createdAt":"2026-09-18T00:00:00+00:00","sortOrder":33,"updatedAt":"2026-09-17T23:00:00+00:00","accessMode":"BIND","categoryId":"MOCK_CAT_3","platformId":"MOCK_PLATFORM_5","platformNo":5,"description":"发布职业病及化学中毒防治资讯、办事指引和健康知识。","networkZone":"政务外网互联网区","mockScenario":"BOUND_EXISTING","platformName":"省职控制中心门户网站","postGrantMode":"DIRECT","runtimeStatus":"UNCONFIGURED","integrationNote":"服务地址与接入参数待配置","connectionStatus":"UNCONFIGURED","accountBindingMode":"ADMIN","accountOpeningMode":"NONE","enabled":true,"allowedOrigins":[],"bindingMethods":["SELF","ADMIN"]},{"id":"MOCK_APP_34","url":"https://p4.invalid/app/34","code":"WJ_APP_34","name":"福建省卫生监督电子执法全过程记录系统","status":"ENABLED","version":1,"category":"卫生监督","sourceNo":34,"userType":"GOV","createdAt":"2026-09-18T00:00:00+00:00","sortOrder":34,"updatedAt":"2026-09-17T23:00:00+00:00","accessMode":"BIND","categoryId":"MOCK_CAT_5","platformId":"MOCK_PLATFORM_6","platformNo":6,"description":"管理卫生监督执法记录、证据索引与过程留痕。","networkZone":"政务外网公用网络区","mockScenario":"BOUND_EXISTING","platformName":"省卫监所综合管理系统","postGrantMode":"DIRECT","runtimeStatus":"UNCONFIGURED","integrationNote":"服务地址与接入参数待配置","connectionStatus":"UNCONFIGURED","accountBindingMode":"ADMIN","accountOpeningMode":"NONE","enabled":true,"allowedOrigins":[],"bindingMethods":["SELF","ADMIN"]},{"id":"MOCK_APP_35","url":"https://p4.invalid/app/35","code":"WJ_APP_35","name":"福建省医疗卫生信用信息归集系统","status":"ENABLED","version":1,"category":"卫生监督","sourceNo":35,"userType":"GOV","createdAt":"2026-09-18T00:00:00+00:00","sortOrder":35,"updatedAt":"2026-09-17T23:00:00+00:00","accessMode":"BIND","categoryId":"MOCK_CAT_5","platformId":"MOCK_PLATFORM_6","platformNo":6,"description":"归集医疗卫生信用信息，支持信用核验与监管查询。","networkZone":"互联网","mockScenario":"BOUND_EXISTING","platformName":"省卫监所综合管理系统","postGrantMode":"DIRECT","runtimeStatus":"UNCONFIGURED","integrationNote":"服务地址与接入参数待配置","connectionStatus":"UNCONFIGURED","accountBindingMode":"ADMIN","accountOpeningMode":"NONE","enabled":true,"allowedOrigins":[],"bindingMethods":["SELF","ADMIN"]},{"id":"MOCK_APP_36","url":"https://p4.invalid/app/36","code":"WJ_APP_36","name":"福建省医疗卫生不良执业记分系统","status":"ENABLED","version":1,"category":"卫生监督","sourceNo":36,"userType":"GOV","createdAt":"2026-09-18T00:00:00+00:00","sortOrder":36,"updatedAt":"2026-09-17T23:00:00+00:00","accessMode":"BIND","categoryId":"MOCK_CAT_5","platformId":"MOCK_PLATFORM_6","platformNo":6,"description":"管理不良执业行为登记、记分与整改记录。","networkZone":"互联网","mockScenario":"BOUND_EXISTING","platformName":"省卫监所综合管理系统","postGrantMode":"DIRECT","runtimeStatus":"UNCONFIGURED","integrationNote":"服务地址与接入参数待配置","connectionStatus":"UNCONFIGURED","accountBindingMode":"ADMIN","accountOpeningMode":"NONE","enabled":true,"allowedOrigins":[],"bindingMethods":["SELF","ADMIN"]},{"id":"MOCK_APP_37","url":"https://p4.invalid/app/37","code":"WJ_APP_37","name":"福建省诊所诊疗监督系统","status":"ENABLED","version":1,"category":"卫生监督","sourceNo":37,"userType":"GOV","createdAt":"2026-09-18T00:00:00+00:00","sortOrder":37,"updatedAt":"2026-09-17T23:00:00+00:00","accessMode":"BIND","categoryId":"MOCK_CAT_5","platformId":"MOCK_PLATFORM_6","platformNo":6,"description":"汇集诊所诊疗活动，支持合规核查与监督管理。","networkZone":"互联网","mockScenario":"BOUND_EXISTING","platformName":"省卫监所综合管理系统","postGrantMode":"DIRECT","runtimeStatus":"UNCONFIGURED","integrationNote":"服务地址与接入参数待配置","connectionStatus":"UNCONFIGURED","accountBindingMode":"ADMIN","accountOpeningMode":"NONE","enabled":true,"allowedOrigins":[],"bindingMethods":["SELF","ADMIN"]},{"id":"MOCK_APP_38","url":"https://p4.invalid/app/38","code":"WJ_APP_38","name":"福建省医疗服务资质检测系统","status":"ENABLED","version":1,"category":"卫生监督","sourceNo":38,"userType":"GOV","createdAt":"2026-09-18T00:00:00+00:00","sortOrder":38,"updatedAt":"2026-09-17T23:00:00+00:00","accessMode":"BIND","categoryId":"MOCK_CAT_5","platformId":"MOCK_PLATFORM_6","platformNo":6,"description":"核验医疗服务资质，记录检测及复核结果。","networkZone":"政务外网、互联网","mockScenario":"BOUND_EXISTING","platformName":"省卫监所综合管理系统","postGrantMode":"DIRECT","runtimeStatus":"UNCONFIGURED","integrationNote":"服务地址与接入参数待配置","connectionStatus":"UNCONFIGURED","accountBindingMode":"ADMIN","accountOpeningMode":"NONE","enabled":true,"allowedOrigins":[],"bindingMethods":["SELF","ADMIN"]},{"id":"MOCK_APP_39","url":"https://p4.invalid/app/39","code":"WJ_APP_39","name":"福建省食源性疾病省级平台系统","status":"ENABLED","version":1,"category":"疾病防控","sourceNo":39,"userType":"GOV","createdAt":"2026-09-18T00:00:00+00:00","sortOrder":39,"updatedAt":"2026-09-17T23:00:00+00:00","accessMode":"BIND","categoryId":"MOCK_CAT_6","platformId":"MOCK_PLATFORM_7","platformNo":7,"description":"管理食源性疾病监测报告、事件核查及分析。","networkZone":"政务外网","mockScenario":"BOUND_EXISTING","platformName":"省疾控中心综合管理系统","postGrantMode":"DIRECT","runtimeStatus":"UNCONFIGURED","integrationNote":"服务地址与接入参数待配置","connectionStatus":"UNCONFIGURED","accountBindingMode":"ADMIN","accountOpeningMode":"NONE","enabled":true,"allowedOrigins":[],"bindingMethods":["SELF","ADMIN"]},{"id":"MOCK_APP_40","url":"https://p4.invalid/app/40","code":"WJ_APP_40","name":"福建省疾病预防控制中心信息门户系统","status":"ENABLED","version":1,"category":"疾病防控","sourceNo":40,"userType":"GOV","createdAt":"2026-09-18T00:00:00+00:00","sortOrder":40,"updatedAt":"2026-09-17T23:00:00+00:00","accessMode":"BIND","categoryId":"MOCK_CAT_6","platformId":"MOCK_PLATFORM_7","platformNo":7,"description":"汇集疾控业务入口、工作通知与信息发布服务。","networkZone":"政务外网","mockScenario":"BOUND_EXISTING","platformName":"省疾控中心综合管理系统","postGrantMode":"DIRECT","runtimeStatus":"UNCONFIGURED","integrationNote":"服务地址与接入参数待配置","connectionStatus":"UNCONFIGURED","accountBindingMode":"ADMIN","accountOpeningMode":"NONE","enabled":true,"allowedOrigins":[],"bindingMethods":["SELF","ADMIN"]},{"id":"MOCK_APP_41","url":"https://p4.invalid/app/41","code":"WJ_APP_41","name":"福建省慢性病防控指标系统","status":"ENABLED","version":1,"category":"疾病防控","sourceNo":41,"userType":"GOV","createdAt":"2026-09-18T00:00:00+00:00","sortOrder":41,"updatedAt":"2026-09-17T23:00:00+00:00","accessMode":"BIND","categoryId":"MOCK_CAT_6","platformId":"MOCK_PLATFORM_7","platformNo":7,"description":"管理慢性病防控指标采集、质量核验与评估。","networkZone":"政务外网","mockScenario":"BOUND_EXISTING","platformName":"省疾控中心综合管理系统","postGrantMode":"DIRECT","runtimeStatus":"UNCONFIGURED","integrationNote":"服务地址与接入参数待配置","connectionStatus":"UNCONFIGURED","accountBindingMode":"ADMIN","accountOpeningMode":"NONE","enabled":true,"allowedOrigins":[],"bindingMethods":["SELF","ADMIN"]},{"id":"MOCK_APP_43","url":"https://p4.invalid/app/43","code":"WJ_APP_43","name":"福建省疫苗冷链监测系统","status":"DISABLED","version":1,"category":"疾病防控","sourceNo":43,"userType":"GOV","createdAt":"2026-09-18T00:00:00+00:00","sortOrder":43,"updatedAt":"2026-09-17T23:00:00+00:00","accessMode":"BIND","categoryId":"MOCK_CAT_6","platformId":"MOCK_PLATFORM_7","platformNo":7,"description":"监测疫苗储运温度、冷链设备运行及异常处置。","networkZone":"政务外网","mockScenario":"BOUND_EXISTING","platformName":"省疾控中心综合管理系统","postGrantMode":"DIRECT","runtimeStatus":"UNCONFIGURED","integrationNote":"服务地址与接入参数待配置","connectionStatus":"UNCONFIGURED","accountBindingMode":"ADMIN","accountOpeningMode":"NONE","enabled":false,"allowedOrigins":[],"bindingMethods":["SELF","ADMIN"]}],"logs":[{"id":"MOCK_d236c424-513c-4a9f-bd99-2e1787421104","ip":"127.0.0.1","kind":"operation","name":"删除应用","actor":"周明","appId":"MOCK_f3c6d5cc-a891-44a8-a60c-8f2e828e7c64","client":"Chrome / Windows","status":"SUCCESS","userId":"MOCK_ADMIN","account":"zhouming","appName":"DBAPI_53f98b01cecd 已编辑","version":1,"authType":"EXTERNAL","objectId":"MOCK_f3c6d5cc-a891-44a8-a60c-8f2e828e7c64","pageName":"应用列表","userName":"周明","userType":"GOV","actorType":"PORTAL_ADMIN_USER","createdAt":"2026-09-23T07:27:04.004Z","requestId":"MOCK_RUNTIME_84310c58-b982-4fde-9fd8-8077032a1422","actionName":"删除应用","moduleName":"应用管理","objectType":"APPLICATION","description":"删除应用","identitySource":"闽政务"},{"id":"MOCK_fab58068-1766-4916-ba7e-8ee161aae94d","ip":"127.0.0.1","kind":"operation","name":"通过应用访问申请","actor":"周明","appId":"MOCK_f3c6d5cc-a891-44a8-a60c-8f2e828e7c64","client":"Chrome / Windows","status":"SUCCESS","userId":"MOCK_ADMIN","account":"zhouming","appName":"DBAPI_53f98b01cecd 已编辑","version":1,"authType":"EXTERNAL","objectId":"MOCK_31ccf3ff-bfc3-4169-8003-af0b59242d44","pageName":"应用访问申请","userName":"周明","userType":"GOV","actorType":"PORTAL_ADMIN_USER","createdAt":"2026-09-23T07:26:57.774Z","requestId":"MOCK_RUNTIME_7da2ed8b-9328-45af-aee7-1da126bf17fc","actionName":"通过应用访问申请","moduleName":"应用管理","objectType":"APPLICATION","description":"通过应用访问申请","identitySource":"闽政务"},{"id":"MOCK_6ada7601-e85e-4f3c-be5a-fe2089f9e804","ip":"127.0.0.1","kind":"operation","name":"提交应用访问申请","actor":"林晓","appId":"MOCK_f3c6d5cc-a891-44a8-a60c-8f2e828e7c64","client":"Chrome / Windows","status":"SUCCESS","userId":"MOCK_USER_1","account":"linxiao","appName":"DBAPI_53f98b01cecd 已编辑","version":1,"authType":"EXTERNAL","objectId":"MOCK_31ccf3ff-bfc3-4169-8003-af0b59242d44","pageName":"应用访问申请","userName":"林晓","userType":"CITIZEN","actorType":"ACCESS_USER","createdAt":"2026-09-23T07:26:53.565Z","requestId":"MOCK_RUNTIME_a1ffcd67-35f5-410a-b7e6-76d5e7dfe48a","actionName":"提交应用访问申请","moduleName":"应用中心","objectType":"APPLICATION","description":"数据库 API 持久化验收","identitySource":"闽政通"},{"id":"MOCK_fec4b5f8-7f0a-46d1-803c-6c736459bde9","ip":"127.0.0.1","kind":"operation","name":"维护应用信息","actor":"周明","appId":null,"client":"Chrome / Windows","status":"SUCCESS","userId":"MOCK_ADMIN","account":"zhouming","appName":null,"version":1,"authType":"EXTERNAL","objectId":"MOCK_f3c6d5cc-a891-44a8-a60c-8f2e828e7c64","pageName":"应用列表","userName":"周明","userType":"GOV","actorType":"PORTAL_ADMIN_USER","createdAt":"2026-09-23T07:26:49.276Z","requestId":"MOCK_RUNTIME_6510442e-b13f-4c28-bb0f-370635627727","actionName":"维护应用信息","moduleName":"应用管理","objectType":"PORTAL","description":"维护应用信息","identitySource":"闽政务"},{"id":"MOCK_dd7794fa-61cd-4993-8969-5b92a193a3c9","ip":"127.0.0.1","kind":"operation","name":"变更应用启用状态","actor":"周明","appId":null,"client":"Chrome / Windows","status":"SUCCESS","userId":"MOCK_ADMIN","account":"zhouming","appName":null,"version":1,"authType":"EXTERNAL","objectId":"MOCK_f3c6d5cc-a891-44a8-a60c-8f2e828e7c64","pageName":"应用列表","userName":"周明","userType":"GOV","actorType":"PORTAL_ADMIN_USER","createdAt":"2026-09-23T07:26:46.955Z","requestId":"MOCK_RUNTIME_16d9779e-b335-46c3-8c94-59b692044e9f","actionName":"变更应用启用状态","moduleName":"应用管理","objectType":"PORTAL","description":"变更应用启用状态","identitySource":"闽政务"},{"id":"MOCK_4ae5a727-eff2-4284-bcbb-3826175a5569","ip":"127.0.0.1","kind":"operation","name":"维护应用信息","actor":"周明","appId":null,"client":"Chrome / Windows","status":"SUCCESS","userId":"MOCK_ADMIN","account":"zhouming","appName":null,"version":1,"authType":"EXTERNAL","objectId":"MOCK_f3c6d5cc-a891-44a8-a60c-8f2e828e7c64","pageName":"应用列表","userName":"周明","userType":"GOV","actorType":"PORTAL_ADMIN_USER","createdAt":"2026-09-23T07:26:44.635Z","requestId":"MOCK_RUNTIME_0fe5489a-a770-4eb7-b9b5-422e3653b4fe","actionName":"维护应用信息","moduleName":"应用管理","objectType":"PORTAL","description":"维护应用信息","identitySource":"闽政务"},{"id":"MOCK_9a992d0a-c9f5-4fdb-9ba3-7fc549bb3131","ip":"127.0.0.1","kind":"operation","name":"removeAnnouncement","actor":"周明","appId":null,"client":"Chrome / Windows","status":"SUCCESS","userId":"MOCK_ADMIN","account":"zhouming","appName":null,"version":1,"authType":"EXTERNAL","objectId":"MOCK_cb1b1812-1e69-4b00-9e33-22a74864bf22","pageName":"通知公告管理","userName":"周明","userType":"GOV","actorType":"PORTAL_ADMIN_USER","createdAt":"2026-09-23T01:24:38.699Z","requestId":"MOCK_RUNTIME_843cc21a-3da2-47f8-8861-af76f15b7ec9","actionName":"removeAnnouncement","moduleName":"工作台","objectType":"PORTAL","description":"操作已记录","identitySource":"闽政务"},{"id":"MOCK_ff47cd6d-c81b-4e71-90e4-a165f297e163","ip":"127.0.0.1","kind":"operation","name":"保存公告","actor":"周明","appId":null,"client":"Chrome / Windows","status":"SUCCESS","userId":"MOCK_ADMIN","account":"zhouming","appName":null,"version":1,"authType":"EXTERNAL","objectId":"MOCK_cb1b1812-1e69-4b00-9e33-22a74864bf22","pageName":"通知公告管理","userName":"周明","userType":"GOV","actorType":"PORTAL_ADMIN_USER","createdAt":"2026-09-23T01:23:46.105Z","requestId":"MOCK_RUNTIME_cd5b8266-03a8-45f0-9813-ed3d61118399","actionName":"保存公告","moduleName":"工作台","objectType":"PORTAL","description":"保存公告","identitySource":"闽政务"},{"id":"MOCK_10cd97c6-4ea1-477d-9677-fe049ab30dad","ip":"127.0.0.1","kind":"operation","name":"保存公告","actor":"周明","appId":null,"client":"Chrome / Windows","status":"SUCCESS","userId":"MOCK_ADMIN","account":"zhouming","appName":null,"version":1,"authType":"EXTERNAL","objectId":"MOCK_cb1b1812-1e69-4b00-9e33-22a74864bf22","pageName":"通知公告管理","userName":"周明","userType":"GOV","actorType":"PORTAL_ADMIN_USER","createdAt":"2026-09-23T01:22:34.429Z","requestId":"MOCK_RUNTIME_c90df76b-71c2-4627-80d4-3787dc73ea5d","actionName":"保存公告","moduleName":"工作台","objectType":"PORTAL","description":"保存公告","identitySource":"闽政务"},{"id":"MOCK_4f5103c5-9692-4867-a522-99f846a29a2b","kind":"operation","name":"阅读消息","actor":"林晓","status":"SUCCESS","createdAt":"2026-09-20T09:39:44.555Z","description":"操作已记录"},{"id":"MOCK_95fb3cc7-a868-40ed-bbda-2f8140a5b25b","kind":"access","name":"访问应用","actor":"周明","status":"SUCCESS","createdAt":"2026-09-20T08:10:58.768Z","description":"操作已记录"},{"id":"MOCK_5794c324-f612-42a6-8206-2f8c2c7a0e50","kind":"access","name":"访问应用","actor":"周明","status":"SUCCESS","createdAt":"2026-09-20T08:10:14.506Z","description":"操作已记录"},{"id":"MOCK_3e1a5bed-389a-4621-ba96-ae428eb71111","kind":"access","name":"访问应用","actor":"周明","status":"SUCCESS","createdAt":"2026-09-20T07:41:38.007Z","description":"操作已记录"},{"id":"MOCK_6aec16e2-0b37-4038-84fd-89a3f8748340","kind":"access","name":"访问应用","actor":"林晓","status":"SUCCESS","createdAt":"2026-09-20T07:38:49.028Z","description":"操作已记录"},{"id":"MOCK_c509e96c-53b5-4097-ac16-895975773d0e","kind":"operation","name":"阅读消息","actor":"周明","status":"SUCCESS","createdAt":"2026-09-20T07:24:30.642Z","description":"操作已记录"},{"id":"MOCK_b09fb44f-3bbb-409f-986d-fc09640b5b90","kind":"operation","name":"阅读公告","actor":"郑颖","status":"SUCCESS","createdAt":"2026-09-20T06:58:39.092Z","description":"操作已记录"},{"id":"MOCK_701ba2ee-c373-446f-bb30-2c625b949bb2","kind":"operation","name":"阅读消息","actor":"周明","status":"SUCCESS","createdAt":"2026-09-20T06:54:31.275Z","description":"操作已记录"},{"id":"MOCK_80355dd4-5eeb-4590-9f67-0fede0ebd6c2","kind":"operation","name":"阅读公告","actor":"周明","status":"SUCCESS","createdAt":"2026-09-19T12:56:57.465Z","description":"操作已记录"},{"id":"MOCK_7978f752-6f40-4da3-a344-f4c75115230b","kind":"operation","name":"阅读消息","actor":"周明","status":"SUCCESS","createdAt":"2026-09-19T12:56:48.398Z","description":"操作已记录"},{"id":"MOCK_4e805260-e030-4428-b970-447ea6342f73","kind":"operation","name":"阅读公告","actor":"周明","status":"SUCCESS","createdAt":"2026-09-19T11:16:53.826Z","description":"操作已记录"},{"id":"MOCK_6612ae3c-e06d-48c9-9cc3-f0f4b71e1ef1","kind":"operation","name":"阅读消息","actor":"周明","status":"SUCCESS","createdAt":"2026-09-19T11:16:27.075Z","description":"操作已记录"},{"id":"MOCK_2b73d5a0-274a-4c0f-8e8c-5d7abec9f29d","kind":"operation","name":"saveRules","actor":"周明","status":"SUCCESS","createdAt":"2026-09-18T17:28:40.527Z","description":"操作已记录"},{"id":"MOCK_c496be3c-525a-45fb-a2cb-8f9de1d0819c","kind":"operation","name":"阅读消息","actor":"陈宁","status":"SUCCESS","createdAt":"2026-09-18T16:32:04.310Z","description":"操作已记录"},{"id":"MOCK_4e439319-486c-4783-80a7-42586fe3bb3d","kind":"operation","name":"阅读消息","actor":"陈宁","status":"SUCCESS","createdAt":"2026-09-18T16:27:06.299Z","description":"操作已记录"},{"id":"MOCK_4ba878e2-9c3f-4aa2-a75c-bb9e85801f96","kind":"operation","name":"阅读公告","actor":"周明","status":"SUCCESS","createdAt":"2026-09-18T16:13:46.074Z","description":"操作已记录"},{"id":"MOCK_e04dccb7-b92e-468d-a4a0-2f8e97cd9f8d","kind":"operation","name":"阅读消息","actor":"周明","status":"SUCCESS","createdAt":"2026-09-18T16:13:40.360Z","description":"操作已记录"},{"id":"MOCK_2dece248-bb2a-4cba-83cd-91b40d0af110","kind":"operation","name":"阅读消息","actor":"周明","status":"SUCCESS","createdAt":"2026-09-18T16:12:43.994Z","description":"操作已记录"},{"id":"MOCK_e4a9f29f-6d10-4710-a1ec-b0958660ed4e","kind":"operation","name":"阅读消息","actor":"林晓","status":"SUCCESS","createdAt":"2026-09-18T15:58:30.221Z","description":"操作已记录"},{"id":"MOCK_2d023732-26ab-47a2-bb5c-8721fb6a967c","kind":"operation","name":"阅读消息","actor":"周明","status":"SUCCESS","createdAt":"2026-09-18T15:48:33.066Z","description":"操作已记录"},{"id":"MOCK_0a0e7116-0e04-45b3-b949-a20ee70d529d","kind":"operation","name":"阅读消息","actor":"周明","status":"SUCCESS","createdAt":"2026-09-18T15:48:12.994Z","description":"操作已记录"},{"id":"MOCK_884acd3b-4542-4d3d-8f34-5905adc49c24","kind":"operation","name":"阅读消息","actor":"陈宁","status":"SUCCESS","createdAt":"2026-09-18T15:31:44.193Z","description":"操作已记录"},{"id":"MOCK_2843e278-b1d6-4d45-b59f-1131dfff83db","kind":"operation","name":"阅读���告","actor":"林晓","status":"SUCCESS","createdAt":"2026-09-18T15:16:49.861Z","description":"操作已记录"},{"id":"MOCK_f294ee31-acf1-4398-8a02-4c64a37ce823","kind":"operation","name":"阅读���息","actor":"林晓","status":"SUCCESS","createdAt":"2026-09-18T15:16:22.835Z","description":"操作已记录"},{"id":"MOCK_78f447e0-eb76-4823-9d46-158ae7e41d16","kind":"operation","name":"阅读�����������息","actor":"林晓","status":"SUCCESS","createdAt":"2026-09-18T15:15:56.541Z","description":"操作已记录"},{"id":"MOCK_ff593f7d-4494-4a5b-bce9-c914f95ee40b","kind":"access","name":"访问应���","actor":"陈宁","status":"SUCCESS","createdAt":"2026-09-18T15:10:47.367Z","description":"操作已记录"},{"id":"MOCK_0cc46335-e3ca-4476-8d7f-60c8bfc97205","kind":"operation","name":"阅读公�������������","actor":"林晓","status":"SUCCESS","createdAt":"2026-09-18T15:06:02.548Z","description":"操作已记录"},{"id":"MOCK_470a1df7-5edc-4a0f-9774-2bef076c4992","kind":"operation","name":"阅读�������息","actor":"林晓","status":"SUCCESS","createdAt":"2026-09-18T15:05:14.890Z","description":"操作已记录"},{"id":"MOCK_475164e7-929a-4eeb-9605-566bcc6dc781","kind":"operation","name":"维护接入配置","actor":"周明","status":"SUCCESS","createdAt":"2026-09-18T14:50:14.759Z","description":"操作已记录"},{"id":"MOCK_e58008fb-fdb5-43be-8a36-d250771f7941","kind":"operation","name":"removeAnnouncement","actor":"周明","status":"SUCCESS","createdAt":"2026-09-18T14:50:13.407Z","description":"操作已记录"},{"id":"MOCK_811d2070-70df-4f56-a913-b8f63e567ca5","kind":"operation","name":"保存公告","actor":"周明","status":"SUCCESS","createdAt":"2026-09-18T14:50:12.746Z","description":"操作已记录"},{"id":"MOCK_4f4485cf-4e6e-4266-bd30-6d8e9d0bf80e","kind":"operation","name":"saveRules","actor":"周明","status":"SUCCESS","createdAt":"2026-09-18T14:50:12.064Z","description":"操作已记录"},{"id":"MOCK_c52da59a-23dc-4a00-a9b6-aa34a1767548","kind":"operation","name":"阅读消息","actor":"林晓","status":"SUCCESS","createdAt":"2026-09-18T14:49:35.187Z","description":"操作已记录"},{"id":"MOCK_4599fdec-fdd9-44f6-856d-e1190dc6f862","kind":"operation","name":"阅读公告","actor":"林晓","status":"SUCCESS","createdAt":"2026-09-18T14:49:28.247Z","description":"操作已记录"},{"id":"MOCK_404e4132-17b1-420e-a0fb-55a1b8859d07","kind":"operation","name":"阅读消息","actor":"林晓","status":"SUCCESS","createdAt":"2026-09-18T14:49:21.957Z","description":"操作已记录"},{"id":"MOCK_96877653-65d8-4071-9225-a23e2bfc2859","kind":"operation","name":"阅读公告","actor":"林晓","status":"SUCCESS","createdAt":"2026-09-18T14:49:16.768Z","description":"操作已记录"},{"id":"MOCK_54888ac6-7836-4a46-a949-3db8bf87a3d0","kind":"operation","name":"阅读公告","actor":"林晓","status":"SUCCESS","createdAt":"2026-09-18T14:49:12.945Z","description":"操作已记录"},{"id":"MOCK_7f447185-8be7-4141-8ffb-88436827f843","kind":"access","name":"���问应用","actor":"林晓","status":"SUCCESS","createdAt":"2026-09-18T14:48:29.518Z","description":"操作已记录"},{"id":"MOCK_LOG_login_0","kind":"login","name":"身份登录","actor":"林晓","appId":"MOCK_APP_1","status":"SUCCESS","userId":"MOCK_USER_1","appName":"福建省新生儿疾病筛查管理系统","version":1,"createdAt":"2026-09-18T00:00:00.000Z","requestId":"P4_REQUEST_0_0","updatedAt":"2026-09-17T23:00:00.000Z","description":"身份登录记录"},{"id":"MOCK_LOG_login_1","kind":"login","name":"身份登录","actor":"陈宁","appId":"MOCK_APP_2","status":"SUCCESS","userId":"MOCK_USER_2","appName":"福建省妇幼卫生信息系统","version":1,"createdAt":"2026-09-17T23:00:00.000Z","requestId":"P4_REQUEST_0_1","updatedAt":"2026-09-17T23:00:00.000Z","description":"身份登录记录"},{"id":"MOCK_LOG_login_2","kind":"login","name":"身份登录","actor":"周明","appId":"MOCK_APP_3","status":"SUCCESS","userId":"MOCK_ADMIN","appName":"福建省产前筛查与诊断管理系统","version":1,"createdAt":"2026-09-17T22:00:00.000Z","requestId":"P4_REQUEST_0_2","updatedAt":"2026-09-17T23:00:00.000Z","description":"身份登录记录"},{"id":"MOCK_LOG_login_3","kind":"login","name":"身份登录","actor":"郑颖","appId":"MOCK_APP_4","status":"SUCCESS","userId":"MOCK_EDITOR","appName":"福建省地中海贫血信息管理系统","version":1,"createdAt":"2026-09-17T21:00:00.000Z","requestId":"P4_REQUEST_0_3","updatedAt":"2026-09-17T23:00:00.000Z","description":"身份登录记录"},{"id":"MOCK_LOG_auth_0","kind":"auth","name":"访问权限核验","actor":"林晓","appId":"MOCK_APP_1","status":"SUCCESS","userId":"MOCK_USER_1","appName":"福建省新生儿疾病筛查管理系统","version":1,"createdAt":"2026-09-17T20:00:00.000Z","requestId":"P4_REQUEST_1_0","updatedAt":"2026-09-17T23:00:00.000Z","description":"访问权限核验记录"},{"id":"MOCK_LOG_auth_1","kind":"auth","name":"访问权限核验","actor":"陈宁","appId":"MOCK_APP_2","status":"SUCCESS","userId":"MOCK_USER_2","appName":"福建省妇幼卫生信息系统","version":1,"createdAt":"2026-09-17T19:00:00.000Z","requestId":"P4_REQUEST_1_1","updatedAt":"2026-09-17T23:00:00.000Z","description":"访问权限核验记录"},{"id":"MOCK_LOG_auth_2","kind":"auth","name":"访问权限核验","actor":"周明","appId":"MOCK_APP_3","status":"SUCCESS","userId":"MOCK_ADMIN","appName":"福建省产前筛查与诊断管理系统","version":1,"createdAt":"2026-09-17T18:00:00.000Z","requestId":"P4_REQUEST_1_2","updatedAt":"2026-09-17T23:00:00.000Z","description":"访问权限核验记录"},{"id":"MOCK_LOG_auth_3","kind":"auth","name":"访问权限核验","actor":"郑颖","appId":"MOCK_APP_4","status":"DENIED","userId":"MOCK_EDITOR","appName":"福建省地中海贫血信息���理系统","version":1,"createdAt":"2026-09-17T17:00:00.000Z","requestId":"P4_REQUEST_1_3","updatedAt":"2026-09-17T23:00:00.000Z","description":"访问权限核验记录"},{"id":"MOCK_LOG_access_0","kind":"access","name":"应用访问","actor":"林晓","appId":"MOCK_APP_1","status":"SUCCESS","userId":"MOCK_USER_1","appName":"福建省新生儿疾病筛查管理系统","version":1,"createdAt":"2026-09-17T16:00:00.000Z","requestId":"P4_REQUEST_2_0","updatedAt":"2026-09-17T23:00:00.000Z","description":"应用访问记录"},{"id":"MOCK_LOG_access_1","kind":"access","name":"应用访问","actor":"陈宁","appId":"MOCK_APP_2","status":"SUCCESS","userId":"MOCK_USER_2","appName":"福建省妇幼卫生信息系统","version":1,"createdAt":"2026-09-17T15:00:00.000Z","requestId":"P4_REQUEST_2_1","updatedAt":"2026-09-17T23:00:00.000Z","description":"应用访问记录"},{"id":"MOCK_LOG_access_2","kind":"access","name":"应用访问","actor":"周明","appId":"MOCK_APP_3","status":"SUCCESS","userId":"MOCK_ADMIN","appName":"福建省产前筛查与诊断管理系统","version":1,"createdAt":"2026-09-17T14:00:00.000Z","requestId":"P4_REQUEST_2_2","updatedAt":"2026-09-17T23:00:00.000Z","description":"应用访问记录"},{"id":"MOCK_LOG_access_3","kind":"access","name":"应用访问","actor":"郑颖","appId":"MOCK_APP_4","status":"SUCCESS","userId":"MOCK_EDITOR","appName":"福建省地中海贫血信息管理系统","version":1,"createdAt":"2026-09-17T13:00:00.000Z","requestId":"P4_REQUEST_2_3","updatedAt":"2026-09-17T23:00:00.000Z","description":"应用访问记录"},{"id":"MOCK_LOG_operation_0","kind":"operation","name":"公告维护","actor":"林晓","appId":"MOCK_APP_1","status":"SUCCESS","userId":"MOCK_USER_1","appName":"福建省新生儿疾病筛查管理系统","version":1,"createdAt":"2026-09-17T12:00:00.000Z","requestId":"P4_REQUEST_3_0","updatedAt":"2026-09-17T23:00:00.000Z","description":"公告维护记录"},{"id":"MOCK_LOG_operation_1","kind":"operation","name":"公告维护","actor":"陈宁","appId":"MOCK_APP_2","status":"SUCCESS","userId":"MOCK_USER_2","appName":"福建省妇幼卫生信息系统","version":1,"createdAt":"2026-09-17T11:00:00.000Z","requestId":"P4_REQUEST_3_1","updatedAt":"2026-09-17T23:00:00.000Z","description":"公告维护记录"},{"id":"MOCK_LOG_operation_2","kind":"operation","name":"公告维护","actor":"周明","appId":"MOCK_APP_3","status":"SUCCESS","userId":"MOCK_ADMIN","appName":"福建省产前筛查与诊断管理系统","version":1,"createdAt":"2026-09-17T10:00:00.000Z","requestId":"P4_REQUEST_3_2","updatedAt":"2026-09-17T23:00:00.000Z","description":"公告维护记录"},{"id":"MOCK_LOG_operation_3","kind":"operation","name":"公告维护","actor":"郑颖","appId":"MOCK_APP_4","status":"SUCCESS","userId":"MOCK_EDITOR","appName":"福建省地中海贫血信息管理系统","version":1,"createdAt":"2026-09-17T09:00:00.000Z","requestId":"P4_REQUEST_3_3","updatedAt":"2026-09-17T23:00:00.000Z","description":"公告维护记录"},{"id":"MOCK_LOG_api_0","kind":"api","name":"数据接收","actor":"林晓","appId":"MOCK_APP_1","status":"SUCCESS","userId":"MOCK_USER_1","appName":"福建省新生儿疾病筛查管理系统","version":1,"createdAt":"2026-09-17T08:00:00.000Z","requestId":"P4_REQUEST_4_0","updatedAt":"2026-09-17T23:00:00.000Z","description":"数据接收记录"},{"id":"MOCK_LOG_api_1","kind":"api","name":"数据接收","actor":"陈宁","appId":"MOCK_APP_2","status":"SUCCESS","userId":"MOCK_USER_2","appName":"福建省妇幼卫生信息系统","version":1,"createdAt":"2026-09-17T07:00:00.000Z","requestId":"P4_REQUEST_4_1","updatedAt":"2026-09-17T23:00:00.000Z","description":"数据接收记录"},{"id":"MOCK_LOG_api_2","kind":"api","name":"数据接收","actor":"周明","appId":"MOCK_APP_3","status":"SUCCESS","userId":"MOCK_ADMIN","appName":"福建省产前筛查与诊断管理系统","version":1,"createdAt":"2026-09-17T06:00:00.000Z","requestId":"P4_REQUEST_4_2","updatedAt":"2026-09-17T23:00:00.000Z","description":"数据接收记录"},{"id":"MOCK_LOG_api_3","kind":"api","name":"数据接收","actor":"郑颖","appId":"MOCK_APP_4","status":"SUCCESS","userId":"MOCK_EDITOR","appName":"福建省地中海贫血信息管理系统","version":1,"createdAt":"2026-09-17T05:00:00.000Z","requestId":"P4_REQUEST_4_3","updatedAt":"2026-09-17T23:00:00.000Z","description":"数据接收记录"},{"id":"MOCK_LOG_error_0","kind":"error","name":"接入异常","actor":"林晓","appId":"MOCK_APP_1","status":"FAILURE","userId":"MOCK_USER_1","appName":"福建省新生儿疾病筛查管理系统","version":1,"createdAt":"2026-09-17T04:00:00.000Z","requestId":"P4_REQUEST_5_0","updatedAt":"2026-09-17T23:00:00.000Z","description":"接入参数未配置，需核对接口资料"},{"id":"MOCK_LOG_error_1","kind":"error","name":"接入异常","actor":"陈宁","appId":"MOCK_APP_2","status":"FAILURE","userId":"MOCK_USER_2","appName":"福建省妇幼卫生信息系统","version":1,"createdAt":"2026-09-17T03:00:00.000Z","requestId":"P4_REQUEST_5_1","updatedAt":"2026-09-17T23:00:00.000Z","description":"接入参数未配置，需核对接口资料"},{"id":"MOCK_LOG_error_2","kind":"error","name":"接入异常","actor":"周明","appId":"MOCK_APP_3","status":"FAILURE","userId":"MOCK_ADMIN","appName":"福建省产前筛查与诊断管理系统","version":1,"createdAt":"2026-09-17T02:00:00.000Z","requestId":"P4_REQUEST_5_2","updatedAt":"2026-09-17T23:00:00.000Z","description":"接入参数未配置，需核对接口资料"},{"id":"MOCK_LOG_error_3","kind":"error","name":"接入异常","actor":"郑颖","appId":"MOCK_APP_4","status":"FAILURE","userId":"MOCK_EDITOR","appName":"福建省地中海贫血信息管理系统","version":1,"createdAt":"2026-09-17T01:00:00.000Z","requestId":"P4_REQUEST_5_3","updatedAt":"2026-09-17T23:00:00.000Z","description":"接入参数未配置，需核对接口资料"}],"roles":[{"id":"ROLE_SUPER","scopes":["super","application","integration","announcement","audit","identity"],"status":"ENABLED","builtIn":true,"version":1,"roleCode":"PORTAL_SUPER_ADMIN","roleName":"门户超级管理员","createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","description":"负责门户系统自身的用户、角色、应用、集成、内容、审计等管理，不授予子系统业务权限。"},{"id":"ROLE_APP","scopes":["application"],"status":"ENABLED","builtIn":true,"version":1,"roleCode":"PORTAL_APP_ADMIN","roleName":"应用管理员","createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","description":"维护门户应用目录、分类及应用接入信息。"},{"id":"ROLE_CONTENT","scopes":["announcement"],"status":"ENABLED","builtIn":true,"version":1,"roleCode":"PORTAL_CONTENT_ADMIN","roleName":"内容管理员","createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","description":"维护通知公告等门户内容。"},{"id":"ROLE_INTEGRATION","scopes":["integration"],"status":"ENABLED","builtIn":true,"version":1,"roleCode":"PORTAL_INTEGRATION_ADMIN","roleName":"集成管理员","createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","description":"维护SSO、待办、消息等集成配置及运行监控。"},{"id":"ROLE_IDENTITY","scopes":["identity"],"status":"ENABLED","builtIn":true,"version":1,"roleCode":"PORTAL_IDENTITY_ADMIN","roleName":"身份映射管理员","createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","description":"维护统一身份索引与子系统账号映射。"},{"id":"ROLE_AUDIT","scopes":["audit"],"status":"ENABLED","builtIn":true,"version":1,"roleCode":"PORTAL_AUDITOR","roleName":"审计员","createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","description":"查看门户登录、访问、操作、接口及异常日志。"}],"todos":[{"id":"MOCK_TODO_0_0","version":1,"createdAt":"2026-09-18T00:00:00+00:00","updatedAt":"2026-09-18T00:00:00+00:00","receivedAt":"2026-09-18T00:00:00+00:00","sourceCreatedAt":"2026-09-17T22:00:00+00:00","sourceUpdatedAt":"2026-09-17T23:00:00+00:00","appId":"MOCK_APP_1","appName":"福建省新生儿疾病筛查管理系统","sourceTodoId":"P4_TODO_0_0","userId":"MOCK_USER_1","title":"核对服务申请资料","summary":"福建省新生儿疾病筛查管理系统：核对服务申请资料。请在来源系统查看业务详情。","businessType":"","status":"PENDING","url":"https://p4.invalid/app/1"},{"id":"MOCK_TODO_0_1","version":1,"createdAt":"2026-09-18T00:00:00+00:00","updatedAt":"2026-09-18T00:00:00+00:00","receivedAt":"2026-09-18T00:00:00+00:00","sourceCreatedAt":"2026-09-17T21:00:00+00:00","sourceUpdatedAt":"2026-09-17T23:00:00+00:00","appId":"MOCK_APP_2","appName":"福建省妇幼卫生信息系统","sourceTodoId":"P4_TODO_0_1","userId":"MOCK_USER_1","title":"补充业务登记信息","summary":"福建省妇幼卫生信息系统：补充业务登记信息。请在来源系统查看业务详情。","businessType":"","status":"PENDING","url":"https://p4.invalid/app/2"},{"id":"MOCK_TODO_0_10","version":1,"createdAt":"2026-09-18T00:00:00+00:00","updatedAt":"2026-09-18T00:00:00+00:00","receivedAt":"2026-09-18T00:00:00+00:00","sourceCreatedAt":"2026-09-17T12:00:00+00:00","sourceUpdatedAt":"2026-09-17T23:00:00+00:00","appId":"MOCK_APP_3","appName":"福建省产前筛查与诊断管理系统","sourceTodoId":"P4_TODO_0_10","userId":"MOCK_USER_1","title":"办理期限已结束","summary":"福建省产前筛查与诊断管理系统：办理期限已结束。请在来源系统查看业务详情。","businessType":"","status":"EXPIRED","url":"https://p4.invalid/app/3"},{"id":"MOCK_TODO_0_2","version":1,"createdAt":"2026-09-18T00:00:00+00:00","updatedAt":"2026-09-18T00:00:00+00:00","receivedAt":"2026-09-18T00:00:00+00:00","sourceCreatedAt":"2026-09-17T20:00:00+00:00","sourceUpdatedAt":"2026-09-17T23:00:00+00:00","appId":"MOCK_APP_3","appName":"福建省产前筛查与诊断管理系统","sourceTodoId":"P4_TODO_0_2","userId":"MOCK_USER_1","title":"确认服务安排","summary":"福建省产前筛查与诊断管理系统：确认服务安排。请在来源系统查看业务详情。","businessType":"","status":"PENDING","url":"https://p4.invalid/app/3"},{"id":"MOCK_TODO_0_3","version":1,"createdAt":"2026-09-18T00:00:00+00:00","updatedAt":"2026-09-18T00:00:00+00:00","receivedAt":"2026-09-18T00:00:00+00:00","sourceCreatedAt":"2026-09-17T19:00:00+00:00","sourceUpdatedAt":"2026-09-17T23:00:00+00:00","appId":"MOCK_APP_4","appName":"福建省地中海贫血信息管理系统","sourceTodoId":"P4_TODO_0_3","userId":"MOCK_USER_1","title":"查看材料核验意见","summary":"福建省地中海贫血信息管理系统：查看材料核验意见。请在来源系统查看业务详情。","businessType":"","status":"PENDING","url":"https://p4.invalid/app/4"},{"id":"MOCK_TODO_0_4","version":1,"createdAt":"2026-09-18T00:00:00+00:00","updatedAt":"2026-09-18T00:00:00+00:00","receivedAt":"2026-09-18T00:00:00+00:00","sourceCreatedAt":"2026-09-17T18:00:00+00:00","sourceUpdatedAt":"2026-09-17T23:00:00+00:00","appId":"MOCK_APP_5","appName":"福建省慢病报告与管理系统","sourceTodoId":"P4_TODO_0_4","userId":"MOCK_USER_1","title":"核对信息更新内容","summary":"福建省慢病报告与管理系统：核对信息更新内容。请在来源系统查看业务详情。","businessType":"","status":"PENDING","url":"https://p4.invalid/app/5"},{"id":"MOCK_TODO_0_5","version":1,"createdAt":"2026-09-18T00:00:00+00:00","updatedAt":"2026-09-18T00:00:00+00:00","receivedAt":"2026-09-18T00:00:00+00:00","sourceCreatedAt":"2026-09-17T17:00:00+00:00","sourceUpdatedAt":"2026-09-17T23:00:00+00:00","appId":"MOCK_APP_6","appName":"福建省区域影像平台","sourceTodoId":"P4_TODO_0_5","userId":"MOCK_USER_1","title":"确认事项办理进度","summary":"福建省区域影像平台：确认事项办理进度。请在来源系统查看业务详情。","businessType":"","status":"PENDING","url":"https://p4.invalid/app/6"},{"id":"MOCK_TODO_0_6","version":1,"createdAt":"2026-09-18T00:00:00+00:00","updatedAt":"2026-09-18T00:00:00+00:00","receivedAt":"2026-09-18T00:00:00+00:00","sourceCreatedAt":"2026-09-17T16:00:00+00:00","sourceUpdatedAt":"2026-09-17T23:00:00+00:00","appId":"MOCK_APP_11","appName":"福建省免疫规划管理信息系统","sourceTodoId":"P4_TODO_0_6","userId":"MOCK_USER_1","title":"完善服务联系说明","summary":"福建省免疫规划管理信息系统：完善服务联系说明。请在来源系统查看业务详情。","businessType":"","status":"PENDING","url":"https://p4.invalid/app/11"},{"id":"MOCK_TODO_0_7","version":1,"createdAt":"2026-09-18T00:00:00+00:00","updatedAt":"2026-09-18T00:00:00+00:00","receivedAt":"2026-09-18T00:00:00+00:00","sourceCreatedAt":"2026-09-17T15:00:00+00:00","sourceUpdatedAt":"2026-09-17T23:00:00+00:00","appId":"MOCK_APP_12","appName":"中医馆健康信息系统","sourceTodoId":"P4_TODO_0_7","userId":"MOCK_USER_1","title":"查看后续办理要求","summary":"中医馆健康信息系统：查看后续办理要求。请在来源系统查看业务详情。","businessType":"","status":"PENDING","url":"https://p4.invalid/app/12"},{"id":"MOCK_TODO_0_8","version":1,"createdAt":"2026-09-18T00:00:00+00:00","updatedAt":"2026-09-18T00:00:00+00:00","receivedAt":"2026-09-18T00:00:00+00:00","sourceCreatedAt":"2026-09-17T14:00:00+00:00","sourceUpdatedAt":"2026-09-17T23:00:00+00:00","appId":"MOCK_APP_1","appName":"福建省新生儿疾病筛查管理系统","sourceTodoId":"P4_TODO_0_8","userId":"MOCK_USER_1","title":"资料核验已完成","summary":"福建省新生儿疾病筛查管理系统：资料核验已完成。请在来源系统查看业务详情。","businessType":"","status":"COMPLETED","url":"https://p4.invalid/app/1"},{"id":"MOCK_TODO_0_9","version":1,"createdAt":"2026-09-18T00:00:00+00:00","updatedAt":"2026-09-18T00:00:00+00:00","receivedAt":"2026-09-18T00:00:00+00:00","sourceCreatedAt":"2026-09-17T13:00:00+00:00","sourceUpdatedAt":"2026-09-17T23:00:00+00:00","appId":"MOCK_APP_2","appName":"福建省妇幼卫生信息系统","sourceTodoId":"P4_TODO_0_9","userId":"MOCK_USER_1","title":"业务申请已撤回","summary":"福建省妇幼卫生信息系统：业务申请已撤回。请在来源系统查看业务详情。","businessType":"","status":"WITHDRAWN","url":"https://p4.invalid/app/2"},{"id":"MOCK_TODO_1_0","version":1,"createdAt":"2026-09-18T00:00:00+00:00","updatedAt":"2026-09-18T00:00:00+00:00","receivedAt":"2026-09-18T00:00:00+00:00","sourceCreatedAt":"2026-09-17T22:00:00+00:00","sourceUpdatedAt":"2026-09-17T23:00:00+00:00","appId":"MOCK_APP_1","appName":"福建省新生儿疾病筛查管理系统","sourceTodoId":"P4_TODO_1_0","userId":"MOCK_USER_2","title":"核对服务申请资料","summary":"福建省新生儿疾病筛查管理系统：核对服务申请资料。请在来源系统查看业务详情。","businessType":"","status":"PENDING","url":"https://p4.invalid/app/1"},{"id":"MOCK_TODO_1_1","version":1,"createdAt":"2026-09-18T00:00:00+00:00","updatedAt":"2026-09-18T00:00:00+00:00","receivedAt":"2026-09-18T00:00:00+00:00","sourceCreatedAt":"2026-09-17T21:00:00+00:00","sourceUpdatedAt":"2026-09-17T23:00:00+00:00","appId":"MOCK_APP_2","appName":"福建省妇幼卫生信息系统","sourceTodoId":"P4_TODO_1_1","userId":"MOCK_USER_2","title":"补充业务登记信息","summary":"福建省妇幼卫生信息系统：补充业务登记信息。请在来源系统查看业务详情。","businessType":"","status":"PENDING","url":"https://p4.invalid/app/2"},{"id":"MOCK_TODO_1_10","version":1,"createdAt":"2026-09-18T00:00:00+00:00","updatedAt":"2026-09-18T00:00:00+00:00","receivedAt":"2026-09-18T00:00:00+00:00","sourceCreatedAt":"2026-09-17T12:00:00+00:00","sourceUpdatedAt":"2026-09-17T23:00:00+00:00","appId":"MOCK_APP_3","appName":"福建省产前筛查与诊断管理系统","sourceTodoId":"P4_TODO_1_10","userId":"MOCK_USER_2","title":"办理期限已结束","summary":"福建省产前筛查与诊断管理系统：办理期限已结束。请在来源系统查看业务详情。","businessType":"","status":"EXPIRED","url":"https://p4.invalid/app/3"},{"id":"MOCK_TODO_1_2","version":1,"createdAt":"2026-09-18T00:00:00+00:00","updatedAt":"2026-09-18T00:00:00+00:00","receivedAt":"2026-09-18T00:00:00+00:00","sourceCreatedAt":"2026-09-17T20:00:00+00:00","sourceUpdatedAt":"2026-09-17T23:00:00+00:00","appId":"MOCK_APP_3","appName":"福建省产前筛查与诊断管理系统","sourceTodoId":"P4_TODO_1_2","userId":"MOCK_USER_2","title":"确认服务安排","summary":"福建省产前筛查与诊断管理系统：确认服务安排。请在来源系统查看业务详情。","businessType":"","status":"PENDING","url":"https://p4.invalid/app/3"},{"id":"MOCK_TODO_1_3","version":1,"createdAt":"2026-09-18T00:00:00+00:00","updatedAt":"2026-09-18T00:00:00+00:00","receivedAt":"2026-09-18T00:00:00+00:00","sourceCreatedAt":"2026-09-17T19:00:00+00:00","sourceUpdatedAt":"2026-09-17T23:00:00+00:00","appId":"MOCK_APP_4","appName":"福建省地中海贫血信息管理系统","sourceTodoId":"P4_TODO_1_3","userId":"MOCK_USER_2","title":"查看材料核验意见","summary":"福建省地中海贫血信息管理系统：查看材料核验意见。请在来源系统查看业务详情。","businessType":"","status":"PENDING","url":"https://p4.invalid/app/4"},{"id":"MOCK_TODO_1_4","version":1,"createdAt":"2026-09-18T00:00:00+00:00","updatedAt":"2026-09-18T00:00:00+00:00","receivedAt":"2026-09-18T00:00:00+00:00","sourceCreatedAt":"2026-09-17T18:00:00+00:00","sourceUpdatedAt":"2026-09-17T23:00:00+00:00","appId":"MOCK_APP_5","appName":"福建省慢病报告与管理系统","sourceTodoId":"P4_TODO_1_4","userId":"MOCK_USER_2","title":"核对信息更新内容","summary":"福建省慢病报告与管理系统：核对信息更新内容。请在来源系统查看业务详情。","businessType":"","status":"PENDING","url":"https://p4.invalid/app/5"},{"id":"MOCK_TODO_1_5","version":1,"createdAt":"2026-09-18T00:00:00+00:00","updatedAt":"2026-09-18T00:00:00+00:00","receivedAt":"2026-09-18T00:00:00+00:00","sourceCreatedAt":"2026-09-17T17:00:00+00:00","sourceUpdatedAt":"2026-09-17T23:00:00+00:00","appId":"MOCK_APP_6","appName":"福建省区域影像平台","sourceTodoId":"P4_TODO_1_5","userId":"MOCK_USER_2","title":"确认事项办理进度","summary":"福建省区域影像平台：确认事项办理进度。请在来源系统查看业务详情。","businessType":"","status":"PENDING","url":"https://p4.invalid/app/6"},{"id":"MOCK_TODO_1_6","version":1,"createdAt":"2026-09-18T00:00:00+00:00","updatedAt":"2026-09-18T00:00:00+00:00","receivedAt":"2026-09-18T00:00:00+00:00","sourceCreatedAt":"2026-09-17T16:00:00+00:00","sourceUpdatedAt":"2026-09-17T23:00:00+00:00","appId":"MOCK_APP_7","appName":"质控评分系统","sourceTodoId":"P4_TODO_1_6","userId":"MOCK_USER_2","title":"完善服务联系说明","summary":"质控评分系统：完善服务联系说明。请在来源系统查看业务详情。","businessType":"","status":"PENDING","url":"https://p4.invalid/app/7"},{"id":"MOCK_TODO_1_7","version":1,"createdAt":"2026-09-18T00:00:00+00:00","updatedAt":"2026-09-18T00:00:00+00:00","receivedAt":"2026-09-18T00:00:00+00:00","sourceCreatedAt":"2026-09-17T15:00:00+00:00","sourceUpdatedAt":"2026-09-17T23:00:00+00:00","appId":"MOCK_APP_8","appName":"省级平台决策支持展示系统","sourceTodoId":"P4_TODO_1_7","userId":"MOCK_USER_2","title":"查看后续办理要求","summary":"省级平台决策支持展示系统：查看后续办理要求。请在来源系统查看业务详情。","businessType":"","status":"PENDING","url":"https://p4.invalid/app/8"},{"id":"MOCK_TODO_1_8","version":1,"createdAt":"2026-09-18T00:00:00+00:00","updatedAt":"2026-09-18T00:00:00+00:00","receivedAt":"2026-09-18T00:00:00+00:00","sourceCreatedAt":"2026-09-17T14:00:00+00:00","sourceUpdatedAt":"2026-09-17T23:00:00+00:00","appId":"MOCK_APP_1","appName":"福建省新生儿疾病筛查管理系统","sourceTodoId":"P4_TODO_1_8","userId":"MOCK_USER_2","title":"资料核验已完成","summary":"福建省新生儿疾病筛查管理系统：资料核验已完成。请在来源系统查看业务详情。","businessType":"","status":"COMPLETED","url":"https://p4.invalid/app/1"},{"id":"MOCK_TODO_1_9","version":1,"createdAt":"2026-09-18T00:00:00+00:00","updatedAt":"2026-09-18T00:00:00+00:00","receivedAt":"2026-09-18T00:00:00+00:00","sourceCreatedAt":"2026-09-17T13:00:00+00:00","sourceUpdatedAt":"2026-09-17T23:00:00+00:00","appId":"MOCK_APP_2","appName":"福建省妇幼卫生信息系统","sourceTodoId":"P4_TODO_1_9","userId":"MOCK_USER_2","title":"业务申请已撤回","summary":"福建省妇幼卫生信息系统：业务申请已撤回。请在来源系统查看业务详情。","businessType":"","status":"WITHDRAWN","url":"https://p4.invalid/app/2"},{"id":"MOCK_TODO_2_0","version":1,"createdAt":"2026-09-18T00:00:00+00:00","updatedAt":"2026-09-18T00:00:00+00:00","receivedAt":"2026-09-18T00:00:00+00:00","sourceCreatedAt":"2026-09-17T22:00:00+00:00","sourceUpdatedAt":"2026-09-17T23:00:00+00:00","appId":"MOCK_APP_1","appName":"福建省新生儿疾病筛查管理系统","sourceTodoId":"P4_TODO_2_0","userId":"MOCK_ADMIN","title":"核对服务申请资料","summary":"福建省新生儿疾病筛查管理系统：核对服务申请资料。请在来源系统查看业务详情。","businessType":"","status":"PENDING","url":"https://p4.invalid/app/1"},{"id":"MOCK_TODO_2_1","version":1,"createdAt":"2026-09-18T00:00:00+00:00","updatedAt":"2026-09-18T00:00:00+00:00","receivedAt":"2026-09-18T00:00:00+00:00","sourceCreatedAt":"2026-09-17T21:00:00+00:00","sourceUpdatedAt":"2026-09-17T23:00:00+00:00","appId":"MOCK_APP_2","appName":"福建省妇幼卫生信息系统","sourceTodoId":"P4_TODO_2_1","userId":"MOCK_ADMIN","title":"补充业务登记信息","summary":"福建省妇幼卫生信息系统：补充业务登记信息。请在来源系统查看业务详情。","businessType":"","status":"PENDING","url":"https://p4.invalid/app/2"},{"id":"MOCK_TODO_2_10","version":1,"createdAt":"2026-09-18T00:00:00+00:00","updatedAt":"2026-09-18T00:00:00+00:00","receivedAt":"2026-09-18T00:00:00+00:00","sourceCreatedAt":"2026-09-17T12:00:00+00:00","sourceUpdatedAt":"2026-09-17T23:00:00+00:00","appId":"MOCK_APP_3","appName":"福建省产前筛查与诊断管理系统","sourceTodoId":"P4_TODO_2_10","userId":"MOCK_ADMIN","title":"办理期限已结束","summary":"福建省产前筛查与诊断管理系统：办理期限已结束。请在来源系统查看业务详情。","businessType":"","status":"EXPIRED","url":"https://p4.invalid/app/3"},{"id":"MOCK_TODO_2_2","version":1,"createdAt":"2026-09-18T00:00:00+00:00","updatedAt":"2026-09-18T00:00:00+00:00","receivedAt":"2026-09-18T00:00:00+00:00","sourceCreatedAt":"2026-09-17T20:00:00+00:00","sourceUpdatedAt":"2026-09-17T23:00:00+00:00","appId":"MOCK_APP_3","appName":"福建省产前筛查与诊断管理系统","sourceTodoId":"P4_TODO_2_2","userId":"MOCK_ADMIN","title":"确认服务安排","summary":"福建省产前筛查与诊断管理系统：确认服务安排。请在来源系统查看业务详情。","businessType":"","status":"PENDING","url":"https://p4.invalid/app/3"},{"id":"MOCK_TODO_2_3","version":1,"createdAt":"2026-09-18T00:00:00+00:00","updatedAt":"2026-09-18T00:00:00+00:00","receivedAt":"2026-09-18T00:00:00+00:00","sourceCreatedAt":"2026-09-17T19:00:00+00:00","sourceUpdatedAt":"2026-09-17T23:00:00+00:00","appId":"MOCK_APP_4","appName":"福建省地中海贫血信息管理系统","sourceTodoId":"P4_TODO_2_3","userId":"MOCK_ADMIN","title":"查看材料核验意见","summary":"福建省地中海贫血信息管理系统：查看材料核验意见。请在来源系统查看业务详情。","businessType":"","status":"PENDING","url":"https://p4.invalid/app/4"},{"id":"MOCK_TODO_2_4","version":1,"createdAt":"2026-09-18T00:00:00+00:00","updatedAt":"2026-09-18T00:00:00+00:00","receivedAt":"2026-09-18T00:00:00+00:00","sourceCreatedAt":"2026-09-17T18:00:00+00:00","sourceUpdatedAt":"2026-09-17T23:00:00+00:00","appId":"MOCK_APP_5","appName":"福建省慢病报告与管理系统","sourceTodoId":"P4_TODO_2_4","userId":"MOCK_ADMIN","title":"核对信息更新内容","summary":"福建省慢病报告与管理系统：核对信息更新内容。请在来源系统查看业务详情。","businessType":"","status":"PENDING","url":"https://p4.invalid/app/5"},{"id":"MOCK_TODO_2_5","version":1,"createdAt":"2026-09-18T00:00:00+00:00","updatedAt":"2026-09-18T00:00:00+00:00","receivedAt":"2026-09-18T00:00:00+00:00","sourceCreatedAt":"2026-09-17T17:00:00+00:00","sourceUpdatedAt":"2026-09-17T23:00:00+00:00","appId":"MOCK_APP_6","appName":"福建省区域影像平台","sourceTodoId":"P4_TODO_2_5","userId":"MOCK_ADMIN","title":"确认事项办理进度","summary":"福建省区域影像平台：确认事项办理进度。请在来源系统查看业务详情。","businessType":"","status":"PENDING","url":"https://p4.invalid/app/6"},{"id":"MOCK_TODO_2_6","version":1,"createdAt":"2026-09-18T00:00:00+00:00","updatedAt":"2026-09-18T00:00:00+00:00","receivedAt":"2026-09-18T00:00:00+00:00","sourceCreatedAt":"2026-09-17T16:00:00+00:00","sourceUpdatedAt":"2026-09-17T23:00:00+00:00","appId":"MOCK_APP_7","appName":"质控评分系统","sourceTodoId":"P4_TODO_2_6","userId":"MOCK_ADMIN","title":"完善服务联系说明","summary":"质控评分系统：完善服务联系说明。请在来源系统查看业务详情。","businessType":"","status":"PENDING","url":"https://p4.invalid/app/7"},{"id":"MOCK_TODO_2_7","version":1,"createdAt":"2026-09-18T00:00:00+00:00","updatedAt":"2026-09-18T00:00:00+00:00","receivedAt":"2026-09-18T00:00:00+00:00","sourceCreatedAt":"2026-09-17T15:00:00+00:00","sourceUpdatedAt":"2026-09-17T23:00:00+00:00","appId":"MOCK_APP_8","appName":"省级平台决策支持展示系统","sourceTodoId":"P4_TODO_2_7","userId":"MOCK_ADMIN","title":"查看后续办理要求","summary":"省级平台决策支持展示系统：查看后续办理要求。请在来源系统查看业务详情。","businessType":"","status":"PENDING","url":"https://p4.invalid/app/8"},{"id":"MOCK_TODO_2_8","version":1,"createdAt":"2026-09-18T00:00:00+00:00","updatedAt":"2026-09-18T00:00:00+00:00","receivedAt":"2026-09-18T00:00:00+00:00","sourceCreatedAt":"2026-09-17T14:00:00+00:00","sourceUpdatedAt":"2026-09-17T23:00:00+00:00","appId":"MOCK_APP_1","appName":"福建省新生儿疾病筛查管理系统","sourceTodoId":"P4_TODO_2_8","userId":"MOCK_ADMIN","title":"资料核验已完成","summary":"福建省新生儿疾病筛查管理系统：资料核验已完成。请在来源系统查看业务详情。","businessType":"","status":"COMPLETED","url":"https://p4.invalid/app/1"},{"id":"MOCK_TODO_2_9","version":1,"createdAt":"2026-09-18T00:00:00+00:00","updatedAt":"2026-09-18T00:00:00+00:00","receivedAt":"2026-09-18T00:00:00+00:00","sourceCreatedAt":"2026-09-17T13:00:00+00:00","sourceUpdatedAt":"2026-09-17T23:00:00+00:00","appId":"MOCK_APP_2","appName":"福建省妇幼卫生信息系统","sourceTodoId":"P4_TODO_2_9","userId":"MOCK_ADMIN","title":"业务申请已撤回","summary":"福建省妇幼卫生信息系统：业务申请已撤回。请在来源系统查看业务详情。","businessType":"","status":"WITHDRAWN","url":"https://p4.invalid/app/2"},{"id":"MOCK_TODO_3_0","version":1,"createdAt":"2026-09-18T00:00:00+00:00","updatedAt":"2026-09-18T00:00:00+00:00","receivedAt":"2026-09-18T00:00:00+00:00","sourceCreatedAt":"2026-09-17T22:00:00+00:00","sourceUpdatedAt":"2026-09-17T23:00:00+00:00","appId":"MOCK_APP_1","appName":"福建省新生儿疾病筛查管理系统","sourceTodoId":"P4_TODO_3_0","userId":"MOCK_EDITOR","title":"核对服务申请资料","summary":"福建省新生儿疾病筛查管理系统：核对服务申请资料。请在来源系统查看业务详情。","businessType":"","status":"PENDING","url":"https://p4.invalid/app/1"},{"id":"MOCK_TODO_3_1","version":1,"createdAt":"2026-09-18T00:00:00+00:00","updatedAt":"2026-09-18T00:00:00+00:00","receivedAt":"2026-09-18T00:00:00+00:00","sourceCreatedAt":"2026-09-17T21:00:00+00:00","sourceUpdatedAt":"2026-09-17T23:00:00+00:00","appId":"MOCK_APP_2","appName":"福建省妇幼卫生信息系统","sourceTodoId":"P4_TODO_3_1","userId":"MOCK_EDITOR","title":"补充业务登记信息","summary":"福建省妇幼卫生信息系统：补充业务登记信息。请在来源系统查看业务详情。","businessType":"","status":"PENDING","url":"https://p4.invalid/app/2"},{"id":"MOCK_TODO_3_10","version":1,"createdAt":"2026-09-18T00:00:00+00:00","updatedAt":"2026-09-18T00:00:00+00:00","receivedAt":"2026-09-18T00:00:00+00:00","sourceCreatedAt":"2026-09-17T12:00:00+00:00","sourceUpdatedAt":"2026-09-17T23:00:00+00:00","appId":"MOCK_APP_3","appName":"福建省产前筛查与诊断管理系统","sourceTodoId":"P4_TODO_3_10","userId":"MOCK_EDITOR","title":"办理期限已结束","summary":"福建省产前筛查与诊断管理系统：办理期限已结束。请在来源系统查看业务详情。","businessType":"","status":"EXPIRED","url":"https://p4.invalid/app/3"},{"id":"MOCK_TODO_3_2","version":1,"createdAt":"2026-09-18T00:00:00+00:00","updatedAt":"2026-09-18T00:00:00+00:00","receivedAt":"2026-09-18T00:00:00+00:00","sourceCreatedAt":"2026-09-17T20:00:00+00:00","sourceUpdatedAt":"2026-09-17T23:00:00+00:00","appId":"MOCK_APP_3","appName":"福建省产前筛查与诊断管理系统","sourceTodoId":"P4_TODO_3_2","userId":"MOCK_EDITOR","title":"确认服务安排","summary":"福建省产前筛查与诊断管理系统：确认服务安排。请在来源系统查看业务详情。","businessType":"","status":"PENDING","url":"https://p4.invalid/app/3"},{"id":"MOCK_TODO_3_3","version":1,"createdAt":"2026-09-18T00:00:00+00:00","updatedAt":"2026-09-18T00:00:00+00:00","receivedAt":"2026-09-18T00:00:00+00:00","sourceCreatedAt":"2026-09-17T19:00:00+00:00","sourceUpdatedAt":"2026-09-17T23:00:00+00:00","appId":"MOCK_APP_4","appName":"福建省地中海贫血信息管理系统","sourceTodoId":"P4_TODO_3_3","userId":"MOCK_EDITOR","title":"查看材料核验意见","summary":"福建省地中海贫血信息管理系统：查看材料核验意见。请在来源系统查看业务详情。","businessType":"","status":"PENDING","url":"https://p4.invalid/app/4"},{"id":"MOCK_TODO_3_4","version":1,"createdAt":"2026-09-18T00:00:00+00:00","updatedAt":"2026-09-18T00:00:00+00:00","receivedAt":"2026-09-18T00:00:00+00:00","sourceCreatedAt":"2026-09-17T18:00:00+00:00","sourceUpdatedAt":"2026-09-17T23:00:00+00:00","appId":"MOCK_APP_5","appName":"福建省慢病报告与管理系统","sourceTodoId":"P4_TODO_3_4","userId":"MOCK_EDITOR","title":"核对信息更新内容","summary":"��建省慢病报告与管理系统：核对信息更新内容。请在来源系统查看业务详情。","businessType":"","status":"PENDING","url":"https://p4.invalid/app/5"},{"id":"MOCK_TODO_3_5","version":1,"createdAt":"2026-09-18T00:00:00+00:00","updatedAt":"2026-09-18T00:00:00+00:00","receivedAt":"2026-09-18T00:00:00+00:00","sourceCreatedAt":"2026-09-17T17:00:00+00:00","sourceUpdatedAt":"2026-09-17T23:00:00+00:00","appId":"MOCK_APP_6","appName":"福建省区域影像平台","sourceTodoId":"P4_TODO_3_5","userId":"MOCK_EDITOR","title":"确认事项办理进度","summary":"福建省区域影像平台：确认事项办理进度。请在来源系统查看业务详情。","businessType":"","status":"PENDING","url":"https://p4.invalid/app/6"},{"id":"MOCK_TODO_3_6","version":1,"createdAt":"2026-09-18T00:00:00+00:00","updatedAt":"2026-09-18T00:00:00+00:00","receivedAt":"2026-09-18T00:00:00+00:00","sourceCreatedAt":"2026-09-17T16:00:00+00:00","sourceUpdatedAt":"2026-09-17T23:00:00+00:00","appId":"MOCK_APP_7","appName":"质控评分系统","sourceTodoId":"P4_TODO_3_6","userId":"MOCK_EDITOR","title":"完善服务联系说明","summary":"质控评分系统：完善服务联系说明。请在来源系统查看业务详情。","businessType":"","status":"PENDING","url":"https://p4.invalid/app/7"},{"id":"MOCK_TODO_3_7","version":1,"createdAt":"2026-09-18T00:00:00+00:00","updatedAt":"2026-09-18T00:00:00+00:00","receivedAt":"2026-09-18T00:00:00+00:00","sourceCreatedAt":"2026-09-17T15:00:00+00:00","sourceUpdatedAt":"2026-09-17T23:00:00+00:00","appId":"MOCK_APP_8","appName":"省级平台决策支持展示系统","sourceTodoId":"P4_TODO_3_7","userId":"MOCK_EDITOR","title":"查看后续办理要求","summary":"省级平台决策支持展示系统：查看后续办理要求。请在来源系统查看业务详情。","businessType":"","status":"PENDING","url":"https://p4.invalid/app/8"},{"id":"MOCK_TODO_3_8","version":1,"createdAt":"2026-09-18T00:00:00+00:00","updatedAt":"2026-09-18T00:00:00+00:00","receivedAt":"2026-09-18T00:00:00+00:00","sourceCreatedAt":"2026-09-17T14:00:00+00:00","sourceUpdatedAt":"2026-09-17T23:00:00+00:00","appId":"MOCK_APP_1","appName":"福建省新生儿疾病筛查管理系统","sourceTodoId":"P4_TODO_3_8","userId":"MOCK_EDITOR","title":"资料核验已完成","summary":"福建省新生儿疾病筛查管理系统：资料核验已完成。请在来源系统查看业务详情。","businessType":"","status":"COMPLETED","url":"https://p4.invalid/app/1"},{"id":"MOCK_TODO_3_9","version":1,"createdAt":"2026-09-18T00:00:00+00:00","updatedAt":"2026-09-18T00:00:00+00:00","receivedAt":"2026-09-18T00:00:00+00:00","sourceCreatedAt":"2026-09-17T13:00:00+00:00","sourceUpdatedAt":"2026-09-17T23:00:00+00:00","appId":"MOCK_APP_2","appName":"福建省妇幼卫生信息系统","sourceTodoId":"P4_TODO_3_9","userId":"MOCK_EDITOR","title":"业务申请已撤回","summary":"福建省妇幼卫生信息系统：业务申请已撤回。请在来源系统查看业务详情。","businessType":"","status":"WITHDRAWN","url":"https://p4.invalid/app/2"}],"users":[{"id":"MOCK_USER_1","kind":"USER","name":"林晓","email":"未提供","mobile":"未提供","orgKey":"PUBLIC","scopes":[],"status":"NORMAL","account":"linxiao","orgName":"公众服务","roleIds":[],"jobTitle":"办事人员","roleName":"普通用户","userType":"CITIZEN","department":"个人服务","identitySource":"闽政通"},{"id":"MOCK_USER_2","kind":"USER","name":"陈宁","email":"未提供","mobile":"未提供","orgKey":"HEALTH","scopes":[],"status":"NORMAL","account":"chenning","orgName":"卫生健康业务处","roleIds":[],"jobTitle":"业务经办","roleName":"普通用户","userType":"GOV","department":"业务协同科","identitySource":"闽政务"},{"id":"MOCK_ADMIN","kind":"ADMIN","name":"周明","email":"未提供","mobile":"未提供","orgKey":"PORTAL","scopes":["super","application","integration","announcement","audit","identity"],"status":"NORMAL","account":"zhouming","orgName":"门户运行保障中心","roleIds":["ROLE_SUPER"],"jobTitle":"系统管理","roleName":"门户超级管理员","userType":"GOV","department":"运行保障科","identitySource":"闽政务"},{"id":"MOCK_EDITOR","kind":"ADMIN","name":"郑颖","email":"未提供","mobile":"未提供","orgKey":"PORTAL","scopes":["announcement"],"status":"NORMAL","account":"zhengying","orgName":"门户运行保障中心","roleIds":["ROLE_CONTENT"],"jobTitle":"信息编辑","roleName":"内容管理员","userType":"GOV","department":"信息发布科","identitySource":"闽政务","scopeDescription":"公告权限"},{"id":"MOCK_LOCAL_ADMIN","kind":"ADMIN","name":"门户管理员","email":"未提供","mobile":"未提供","orgKey":"PORTAL","status":"NORMAL","account":"admin","enabled":true,"orgName":"门户运行保障中心","roleIds":["ROLE_SUPER"],"authType":"LOCAL","jobTitle":"系统管理","roleName":"门户超级管理员","department":"运行保障科","adminAccess":true,"adminStatus":"NORMAL","lastLoginAt":"2026-09-17T19:00:00.000Z","lockedUntil":null,"permissions":["application:view","application:edit","application:enable","application:review","integration:view","integration:edit","integration:test","identity:view","identity:review","identity:unbind","announcement:view","announcement:edit","announcement:publish","admin-user:view","admin-user:enable","admin-user:create","admin-user:assign-role","admin-user:reset-password","organization:view","organization:edit","dictionary:view","dictionary:edit","monitor:view","monitor:check","audit:view","audit:resolve","role:view","role:edit","settings:view","settings:edit","system:super"],"adminEnabled":true,"adminSubject":true,"firstLoginAt":"2026-09-09T08:00:00.000Z","identitySource":"门户本地","mustChangePassword":false}],"visits":[{"at":"2026-09-17T23:00:00.000Z","appId":"MOCK_APP_1","userId":"MOCK_USER_1"},{"at":"2026-09-17T22:00:00.000Z","appId":"MOCK_APP_2","userId":"MOCK_USER_1"},{"at":"2026-09-17T21:00:00.000Z","appId":"MOCK_APP_3","userId":"MOCK_USER_1"},{"at":"2026-09-17T20:00:00.000Z","appId":"MOCK_APP_4","userId":"MOCK_USER_1"},{"at":"2026-09-17T23:00:00.000Z","appId":"MOCK_APP_1","userId":"MOCK_USER_2"},{"at":"2026-09-17T22:00:00.000Z","appId":"MOCK_APP_2","userId":"MOCK_USER_2"},{"at":"2026-09-17T21:00:00.000Z","appId":"MOCK_APP_3","userId":"MOCK_USER_2"},{"at":"2026-09-17T20:00:00.000Z","appId":"MOCK_APP_4","userId":"MOCK_USER_2"},{"at":"2026-09-17T23:00:00.000Z","appId":"MOCK_APP_1","userId":"MOCK_ADMIN"},{"at":"2026-09-17T22:00:00.000Z","appId":"MOCK_APP_2","userId":"MOCK_ADMIN"},{"at":"2026-09-17T21:00:00.000Z","appId":"MOCK_APP_3","userId":"MOCK_ADMIN"},{"at":"2026-09-17T20:00:00.000Z","appId":"MOCK_APP_4","userId":"MOCK_ADMIN"},{"at":"2026-09-17T23:00:00.000Z","appId":"MOCK_APP_1","userId":"MOCK_EDITOR"},{"at":"2026-09-17T22:00:00.000Z","appId":"MOCK_APP_2","userId":"MOCK_EDITOR"},{"at":"2026-09-17T21:00:00.000Z","appId":"MOCK_APP_3","userId":"MOCK_EDITOR"},{"at":"2026-09-17T20:00:00.000Z","appId":"MOCK_APP_4","userId":"MOCK_EDITOR"},{"at":"2026-09-18T14:48:29.518Z","appId":"MOCK_APP_1","userId":"MOCK_USER_1"},{"at":"2026-09-18T15:10:47.367Z","appId":"MOCK_APP_6","userId":"MOCK_USER_2"},{"at":"2026-09-20T07:38:49.028Z","appId":"MOCK_APP_12","userId":"MOCK_USER_1"},{"at":"2026-09-20T07:41:38.007Z","appId":"MOCK_APP_3","userId":"MOCK_ADMIN"},{"at":"2026-09-20T08:10:14.506Z","appId":"MOCK_APP_1","userId":"MOCK_ADMIN"},{"at":"2026-09-20T08:10:58.768Z","appId":"MOCK_APP_7","userId":"MOCK_ADMIN"}],"mappings":[{"id":"MOCK_MAP_MOCK_USER_1_1","appId":"MOCK_APP_1","status":"BOUND","userId":"MOCK_USER_1","appName":"福建省新生儿疾病筛查管理系统","boundAt":"2026-09-17T00:00:00.000Z","version":1,"userName":"林晓","createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","bindingMethod":"ADMIN","conflictReason":null,"externalUserId":"P4_SUBJECT_MOCK_USER_1_1","externalAccount":"linxiao_01"},{"id":"MOCK_MAP_MOCK_USER_1_2","appId":"MOCK_APP_2","status":"BOUND","userId":"MOCK_USER_1","appName":"福建省妇幼卫生信息系统","boundAt":"2026-09-17T00:00:00.000Z","version":1,"userName":"林晓","createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","bindingMethod":"ADMIN","conflictReason":null,"externalUserId":"P4_SUBJECT_MOCK_USER_1_2","externalAccount":"linxiao_02"},{"id":"MOCK_MAP_MOCK_USER_1_3","appId":"MOCK_APP_3","status":"BOUND","userId":"MOCK_USER_1","appName":"福建省产前筛查与诊断管理系统","boundAt":"2026-09-17T00:00:00.000Z","version":1,"userName":"林晓","createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","bindingMethod":"ADMIN","conflictReason":null,"externalUserId":"P4_SUBJECT_MOCK_USER_1_3","externalAccount":"linxiao_03"},{"id":"MOCK_MAP_MOCK_USER_1_4","appId":"MOCK_APP_4","status":"BOUND","userId":"MOCK_USER_1","appName":"福建省地中海贫血信息管理系统","boundAt":"2026-09-17T00:00:00.000Z","version":1,"userName":"林晓","createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","bindingMethod":"ADMIN","conflictReason":null,"externalUserId":"P4_SUBJECT_MOCK_USER_1_4","externalAccount":"linxiao_04"},{"id":"MOCK_MAP_MOCK_USER_1_5","appId":"MOCK_APP_5","status":"BOUND","userId":"MOCK_USER_1","appName":"福建省慢病报告与管理系统","boundAt":"2026-09-17T00:00:00.000Z","version":1,"userName":"林晓","createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","bindingMethod":"ADMIN","conflictReason":null,"externalUserId":"P4_SUBJECT_MOCK_USER_1_5","externalAccount":"linxiao_05"},{"id":"MOCK_MAP_MOCK_USER_1_6","appId":"MOCK_APP_6","status":"BOUND","userId":"MOCK_USER_1","appName":"福建省区域影像平台","boundAt":"2026-09-17T00:00:00.000Z","version":1,"userName":"林晓","createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","bindingMethod":"ADMIN","conflictReason":null,"externalUserId":"P4_SUBJECT_MOCK_USER_1_6","externalAccount":"linxiao_06"},{"id":"MOCK_MAP_MOCK_USER_1_11","appId":"MOCK_APP_11","status":"BOUND","userId":"MOCK_USER_1","appName":"福建省免疫规划管理信息系统","boundAt":"2026-09-17T00:00:00.000Z","version":1,"userName":"林晓","createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","bindingMethod":"ADMIN","conflictReason":null,"externalUserId":"P4_SUBJECT_MOCK_USER_1_11","externalAccount":"linxiao_11"},{"id":"MOCK_MAP_MOCK_USER_1_12","appId":"MOCK_APP_12","status":"BOUND","userId":"MOCK_USER_1","appName":"中医馆健康信息系统","boundAt":"2026-09-17T00:00:00.000Z","version":1,"userName":"林晓","createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","bindingMethod":"ADMIN","conflictReason":null,"externalUserId":"P4_SUBJECT_MOCK_USER_1_12","externalAccount":"linxiao_12"},{"id":"MOCK_MAP_MOCK_USER_1_26","appId":"MOCK_APP_26","status":"FAILED","userId":"MOCK_USER_1","appName":"福建省中医医术确有专长人员医师资格考核报名系统","boundAt":null,"version":1,"userName":"林晓","createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","bindingMethod":"ADMIN","conflictReason":"账号核验未通过，待补充关联资料","externalUserId":"P4_SUBJECT_MOCK_USER_1_26","externalAccount":"linxiao_26"},{"id":"MOCK_MAP_MOCK_USER_1_28","appId":"MOCK_APP_28","status":"CONFLICT","userId":"MOCK_USER_1","appName":"福建省卫生专业技术资格考试报名系统","boundAt":null,"version":1,"userName":"林晓","createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","bindingMethod":"ADMIN","conflictReason":"身份资料不一致，待人工核查","externalUserId":"P4_SUBJECT_MOCK_USER_1_28","externalAccount":"linxiao_28"},{"id":"MOCK_MAP_MOCK_USER_2_1","appId":"MOCK_APP_1","status":"BOUND","userId":"MOCK_USER_2","appName":"福建省新生儿疾病筛查管理系统","boundAt":"2026-09-17T00:00:00.000Z","version":1,"userName":"陈宁","createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","bindingMethod":"ADMIN","conflictReason":null,"externalUserId":"P4_SUBJECT_MOCK_USER_2_1","externalAccount":"chenning_01"},{"id":"MOCK_MAP_MOCK_USER_2_2","appId":"MOCK_APP_2","status":"BOUND","userId":"MOCK_USER_2","appName":"福建省妇幼卫生信息系统","boundAt":"2026-09-17T00:00:00.000Z","version":1,"userName":"陈宁","createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","bindingMethod":"ADMIN","conflictReason":null,"externalUserId":"P4_SUBJECT_MOCK_USER_2_2","externalAccount":"chenning_02"},{"id":"MOCK_MAP_MOCK_USER_2_3","appId":"MOCK_APP_3","status":"BOUND","userId":"MOCK_USER_2","appName":"福建省产前筛查与诊断管理系统","boundAt":"2026-09-17T00:00:00.000Z","version":1,"userName":"陈宁","createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","bindingMethod":"ADMIN","conflictReason":null,"externalUserId":"P4_SUBJECT_MOCK_USER_2_3","externalAccount":"chenning_03"},{"id":"MOCK_MAP_MOCK_USER_2_4","appId":"MOCK_APP_4","status":"BOUND","userId":"MOCK_USER_2","appName":"福建省地中海贫血信息管理系统","boundAt":"2026-09-17T00:00:00.000Z","version":1,"userName":"陈宁","createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","bindingMethod":"ADMIN","conflictReason":null,"externalUserId":"P4_SUBJECT_MOCK_USER_2_4","externalAccount":"chenning_04"},{"id":"MOCK_MAP_MOCK_USER_2_5","appId":"MOCK_APP_5","status":"BOUND","userId":"MOCK_USER_2","appName":"福建省慢病报告与管理系统","boundAt":"2026-09-17T00:00:00.000Z","version":1,"userName":"陈宁","createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","bindingMethod":"ADMIN","conflictReason":null,"externalUserId":"P4_SUBJECT_MOCK_USER_2_5","externalAccount":"chenning_05"},{"id":"MOCK_MAP_MOCK_USER_2_6","appId":"MOCK_APP_6","status":"BOUND","userId":"MOCK_USER_2","appName":"福建省区域影像平台","boundAt":"2026-09-17T00:00:00.000Z","version":1,"userName":"陈宁","createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","bindingMethod":"ADMIN","conflictReason":null,"externalUserId":"P4_SUBJECT_MOCK_USER_2_6","externalAccount":"chenning_06"},{"id":"MOCK_MAP_MOCK_USER_2_7","appId":"MOCK_APP_7","status":"BOUND","userId":"MOCK_USER_2","appName":"质控评分系统","boundAt":"2026-09-17T00:00:00.000Z","version":1,"userName":"陈宁","createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","bindingMethod":"ADMIN","conflictReason":null,"externalUserId":"P4_SUBJECT_MOCK_USER_2_7","externalAccount":"chenning_07"},{"id":"MOCK_MAP_MOCK_USER_2_8","appId":"MOCK_APP_8","status":"BOUND","userId":"MOCK_USER_2","appName":"省级平台决策支持展示系统","boundAt":"2026-09-17T00:00:00.000Z","version":1,"userName":"陈宁","createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","bindingMethod":"ADMIN","conflictReason":null,"externalUserId":"P4_SUBJECT_MOCK_USER_2_8","externalAccount":"chenning_08"},{"id":"MOCK_MAP_MOCK_USER_2_26","appId":"MOCK_APP_26","status":"FAILED","userId":"MOCK_USER_2","appName":"福建省中医医术确有专长人员医师资格考核报名系统","boundAt":null,"version":1,"userName":"陈宁","createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","bindingMethod":"ADMIN","conflictReason":"账号核验未通过，待补充关联资料","externalUserId":"P4_SUBJECT_MOCK_USER_2_26","externalAccount":"chenning_26"},{"id":"MOCK_MAP_MOCK_USER_2_28","appId":"MOCK_APP_28","status":"CONFLICT","userId":"MOCK_USER_2","appName":"福建省卫生专业技术资格考试报名系统","boundAt":null,"version":1,"userName":"陈宁","createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","bindingMethod":"ADMIN","conflictReason":"身份资料不一致，待人工核查","externalUserId":"P4_SUBJECT_MOCK_USER_2_28","externalAccount":"chenning_28"},{"id":"MOCK_MAP_MOCK_ADMIN_1","appId":"MOCK_APP_1","status":"BOUND","userId":"MOCK_ADMIN","appName":"福建省新生儿疾病筛查管理系统","boundAt":"2026-09-17T00:00:00.000Z","version":1,"userName":"周明","createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","bindingMethod":"ADMIN","conflictReason":null,"externalUserId":"P4_SUBJECT_MOCK_ADMIN_1","externalAccount":"zhouming_01"},{"id":"MOCK_MAP_MOCK_ADMIN_2","appId":"MOCK_APP_2","status":"BOUND","userId":"MOCK_ADMIN","appName":"福建省妇幼卫生信息系统","boundAt":"2026-09-17T00:00:00.000Z","version":1,"userName":"周明","createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","bindingMethod":"ADMIN","conflictReason":null,"externalUserId":"P4_SUBJECT_MOCK_ADMIN_2","externalAccount":"zhouming_02"},{"id":"MOCK_MAP_MOCK_ADMIN_3","appId":"MOCK_APP_3","status":"BOUND","userId":"MOCK_ADMIN","appName":"福建省产前筛查与诊断管理系统","boundAt":"2026-09-17T00:00:00.000Z","version":1,"userName":"周明","createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","bindingMethod":"ADMIN","conflictReason":null,"externalUserId":"P4_SUBJECT_MOCK_ADMIN_3","externalAccount":"zhouming_03"},{"id":"MOCK_MAP_MOCK_ADMIN_4","appId":"MOCK_APP_4","status":"BOUND","userId":"MOCK_ADMIN","appName":"福建省地中海贫血信息管理系统","boundAt":"2026-09-17T00:00:00.000Z","version":1,"userName":"周明","createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","bindingMethod":"ADMIN","conflictReason":null,"externalUserId":"P4_SUBJECT_MOCK_ADMIN_4","externalAccount":"zhouming_04"},{"id":"MOCK_MAP_MOCK_ADMIN_5","appId":"MOCK_APP_5","status":"BOUND","userId":"MOCK_ADMIN","appName":"福建省慢病报告与管理系统","boundAt":"2026-09-17T00:00:00.000Z","version":1,"userName":"周明","createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","bindingMethod":"ADMIN","conflictReason":null,"externalUserId":"P4_SUBJECT_MOCK_ADMIN_5","externalAccount":"zhouming_05"},{"id":"MOCK_MAP_MOCK_ADMIN_6","appId":"MOCK_APP_6","status":"BOUND","userId":"MOCK_ADMIN","appName":"福建省区域影像平台","boundAt":"2026-09-17T00:00:00.000Z","version":1,"userName":"周明","createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","bindingMethod":"ADMIN","conflictReason":null,"externalUserId":"P4_SUBJECT_MOCK_ADMIN_6","externalAccount":"zhouming_06"},{"id":"MOCK_MAP_MOCK_ADMIN_7","appId":"MOCK_APP_7","status":"BOUND","userId":"MOCK_ADMIN","appName":"质控评分系统","boundAt":"2026-09-17T00:00:00.000Z","version":1,"userName":"周明","createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","bindingMethod":"ADMIN","conflictReason":null,"externalUserId":"P4_SUBJECT_MOCK_ADMIN_7","externalAccount":"zhouming_07"},{"id":"MOCK_MAP_MOCK_ADMIN_8","appId":"MOCK_APP_8","status":"BOUND","userId":"MOCK_ADMIN","appName":"省级平台决策支持展示系统","boundAt":"2026-09-17T00:00:00.000Z","version":1,"userName":"周明","createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","bindingMethod":"ADMIN","conflictReason":null,"externalUserId":"P4_SUBJECT_MOCK_ADMIN_8","externalAccount":"zhouming_08"},{"id":"MOCK_MAP_MOCK_ADMIN_26","appId":"MOCK_APP_26","status":"FAILED","userId":"MOCK_ADMIN","appName":"福建省中医医术确有专长人员医师资格考核报名系统","boundAt":null,"version":1,"userName":"周明","createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","bindingMethod":"ADMIN","conflictReason":"账号核验未通过，待补充关联资料","externalUserId":"P4_SUBJECT_MOCK_ADMIN_26","externalAccount":"zhouming_26"},{"id":"MOCK_MAP_MOCK_ADMIN_28","appId":"MOCK_APP_28","status":"CONFLICT","userId":"MOCK_ADMIN","appName":"福建省卫生专业技术资格考试报名系统","boundAt":null,"version":1,"userName":"周明","createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","bindingMethod":"ADMIN","conflictReason":"身份资料不一致，待人工核查","externalUserId":"P4_SUBJECT_MOCK_ADMIN_28","externalAccount":"zhouming_28"},{"id":"MOCK_MAP_MOCK_EDITOR_1","appId":"MOCK_APP_1","status":"BOUND","userId":"MOCK_EDITOR","appName":"福建省新生儿疾病筛查管理系统","boundAt":"2026-09-17T00:00:00.000Z","version":1,"userName":"郑颖","createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","bindingMethod":"ADMIN","conflictReason":null,"externalUserId":"P4_SUBJECT_MOCK_EDITOR_1","externalAccount":"zhengying_01"},{"id":"MOCK_MAP_MOCK_EDITOR_2","appId":"MOCK_APP_2","status":"BOUND","userId":"MOCK_EDITOR","appName":"福建省妇幼卫生信息系统","boundAt":"2026-09-17T00:00:00.000Z","version":1,"userName":"郑颖","createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","bindingMethod":"ADMIN","conflictReason":null,"externalUserId":"P4_SUBJECT_MOCK_EDITOR_2","externalAccount":"zhengying_02"},{"id":"MOCK_MAP_MOCK_EDITOR_3","appId":"MOCK_APP_3","status":"BOUND","userId":"MOCK_EDITOR","appName":"福建省产前筛查与诊断管理系统","boundAt":"2026-09-17T00:00:00.000Z","version":1,"userName":"郑颖","createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","bindingMethod":"ADMIN","conflictReason":null,"externalUserId":"P4_SUBJECT_MOCK_EDITOR_3","externalAccount":"zhengying_03"},{"id":"MOCK_MAP_MOCK_EDITOR_4","appId":"MOCK_APP_4","status":"BOUND","userId":"MOCK_EDITOR","appName":"福建省地中海贫血信息管理系统","boundAt":"2026-09-17T00:00:00.000Z","version":1,"userName":"郑颖","createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","bindingMethod":"ADMIN","conflictReason":null,"externalUserId":"P4_SUBJECT_MOCK_EDITOR_4","externalAccount":"zhengying_04"},{"id":"MOCK_MAP_MOCK_EDITOR_5","appId":"MOCK_APP_5","status":"BOUND","userId":"MOCK_EDITOR","appName":"福建省慢病报告与管理系统","boundAt":"2026-09-17T00:00:00.000Z","version":1,"userName":"郑颖","createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","bindingMethod":"ADMIN","conflictReason":null,"externalUserId":"P4_SUBJECT_MOCK_EDITOR_5","externalAccount":"zhengying_05"},{"id":"MOCK_MAP_MOCK_EDITOR_6","appId":"MOCK_APP_6","status":"BOUND","userId":"MOCK_EDITOR","appName":"福建省区域影像平台","boundAt":"2026-09-17T00:00:00.000Z","version":1,"userName":"郑颖","createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","bindingMethod":"ADMIN","conflictReason":null,"externalUserId":"P4_SUBJECT_MOCK_EDITOR_6","externalAccount":"zhengying_06"},{"id":"MOCK_MAP_MOCK_EDITOR_7","appId":"MOCK_APP_7","status":"BOUND","userId":"MOCK_EDITOR","appName":"质控评分系统","boundAt":"2026-09-17T00:00:00.000Z","version":1,"userName":"郑颖","createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","bindingMethod":"ADMIN","conflictReason":null,"externalUserId":"P4_SUBJECT_MOCK_EDITOR_7","externalAccount":"zhengying_07"},{"id":"MOCK_MAP_MOCK_EDITOR_8","appId":"MOCK_APP_8","status":"BOUND","userId":"MOCK_EDITOR","appName":"省级平台决策支持展示系统","boundAt":"2026-09-17T00:00:00.000Z","version":1,"userName":"郑颖","createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","bindingMethod":"ADMIN","conflictReason":null,"externalUserId":"P4_SUBJECT_MOCK_EDITOR_8","externalAccount":"zhengying_08"},{"id":"MOCK_MAP_MOCK_EDITOR_26","appId":"MOCK_APP_26","status":"FAILED","userId":"MOCK_EDITOR","appName":"福建省中医医术确有专长人员医师资格考核报名系统","boundAt":null,"version":1,"userName":"郑颖","createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","bindingMethod":"ADMIN","conflictReason":"账号核验未通过，待补充关联资料","externalUserId":"P4_SUBJECT_MOCK_EDITOR_26","externalAccount":"zhengying_26"},{"id":"MOCK_MAP_MOCK_EDITOR_28","appId":"MOCK_APP_28","status":"CONFLICT","userId":"MOCK_EDITOR","appName":"福建省卫生专业技术资格考试报名系统","boundAt":null,"version":1,"userName":"郑颖","createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","bindingMethod":"ADMIN","conflictReason":"身份资料不一致，待人工核查","externalUserId":"P4_SUBJECT_MOCK_EDITOR_28","externalAccount":"zhengying_28"}],"messages":[{"id":"MOCK_MSG_0_0","version":2,"createdAt":"2026-09-18T00:00:00+00:00","updatedAt":"2026-09-18T14:49:21.957+00:00","receivedAt":"2026-09-18T00:00:00+00:00","appId":"MOCK_APP_1","appName":"福建省新生儿疾病筛查管理系统","sourceKind":"APPLICATION","sourceMessageId":"P4_MSG_0_0","messageType":"BUSINESS","title":"服务申请已受理","content":"服务申请已受理。请查看相关事项详情并按办理要求完成后续操作。","url":"https://p4.invalid/app/1","userId":"MOCK_USER_1","status":"READ","readAt":"2026-09-18T14:49:21.957+00:00","deleted":false,"deletedAt":null},{"id":"MOCK_MSG_0_1","version":2,"createdAt":"2026-09-18T00:00:00+00:00","updatedAt":"2026-09-18T14:49:35.187+00:00","receivedAt":"2026-09-18T00:00:00+00:00","appId":"MOCK_APP_2","appName":"福建省妇幼卫生信息系统","sourceKind":"APPLICATION","sourceMessageId":"P4_MSG_0_1","messageType":"BUSINESS","title":"资料核验进度通知","content":"资料核验进度通知。请查看相关事项详情并按办理要求完成后续操作。","url":"https://p4.invalid/app/2","userId":"MOCK_USER_1","status":"READ","readAt":"2026-09-18T14:49:35.187+00:00","deleted":false,"deletedAt":null},{"id":"MOCK_MSG_0_2","version":2,"createdAt":"2026-09-18T00:00:00+00:00","updatedAt":"2026-09-18T15:15:56.541+00:00","receivedAt":"2026-09-18T00:00:00+00:00","appId":"MOCK_APP_3","appName":"福建省产前筛查与诊断管理系统","sourceKind":"APPLICATION","sourceMessageId":"P4_MSG_0_2","messageType":"TODO_REMINDER","title":"办理期限提醒","content":"办理期限提醒。请查看相关事项详情并按办理要求完成后续操作。","url":"https://p4.invalid/app/3","userId":"MOCK_USER_1","status":"READ","readAt":"2026-09-18T15:15:56.541+00:00","deleted":false,"deletedAt":null},{"id":"MOCK_MSG_0_3","version":2,"createdAt":"2026-09-18T00:00:00+00:00","updatedAt":"2026-09-18T15:05:14.89+00:00","receivedAt":"2026-09-18T00:00:00+00:00","appId":"MOCK_APP_4","appName":"福建省地中海贫血信息管理系统","sourceKind":"APPLICATION","sourceMessageId":"P4_MSG_0_3","messageType":"BUSINESS","title":"服务安排更新","content":"服务安排更新。请查看相关事项详情并按办理要求完成后续操作。","url":"https://p4.invalid/app/4","userId":"MOCK_USER_1","status":"READ","readAt":"2026-09-18T15:05:14.89+00:00","deleted":false,"deletedAt":null},{"id":"MOCK_MSG_0_4","version":2,"createdAt":"2026-09-18T00:00:00+00:00","updatedAt":"2026-09-18T15:16:22.835+00:00","receivedAt":"2026-09-18T00:00:00+00:00","appId":"MOCK_APP_5","appName":"福建省慢病报告与管理系统","sourceKind":"APPLICATION","sourceMessageId":"P4_MSG_0_4","messageType":"BUSINESS","title":"账号关联结果通知","content":"账号关联结果通知。请查看相关事项详情并按办理要求完成后续操作。","url":"https://p4.invalid/app/5","userId":"MOCK_USER_1","status":"READ","readAt":"2026-09-18T15:16:22.835+00:00","deleted":false,"deletedAt":null},{"id":"MOCK_MSG_0_5","version":2,"createdAt":"2026-09-18T00:00:00+00:00","updatedAt":"2026-09-18T15:58:30.221+00:00","receivedAt":"2026-09-18T00:00:00+00:00","appId":"MOCK_APP_6","appName":"福建省区域影像平台","sourceKind":"APPLICATION","sourceMessageId":"P4_MSG_0_5","messageType":"BUSINESS","title":"业务信息变更提醒","content":"业务信息变更提醒。请查看相关事项详情并按办理要求完成后续操作。","url":"https://p4.invalid/app/6","userId":"MOCK_USER_1","status":"READ","readAt":"2026-09-18T15:58:30.221+00:00","deleted":false,"deletedAt":null},{"id":"MOCK_MSG_0_6","version":2,"createdAt":"2026-09-18T00:00:00+00:00","updatedAt":"2026-09-20T09:39:44.555+00:00","receivedAt":"2026-09-18T00:00:00+00:00","appId":"MOCK_APP_11","appName":"福建省免疫规划管理信息系统","sourceKind":"APPLICATION","sourceMessageId":"P4_MSG_0_6","messageType":"BUSINESS","title":"材料补正通知","content":"材料补正通知。请查看相关事项详情并按办理要求完成后续操作。","url":"https://p4.invalid/app/11","userId":"MOCK_USER_1","status":"READ","readAt":"2026-09-20T09:39:44.555+00:00","deleted":false,"deletedAt":null},{"id":"MOCK_MSG_0_7","version":1,"createdAt":"2026-09-18T00:00:00+00:00","updatedAt":"2026-09-18T00:00:00+00:00","receivedAt":"2026-09-18T00:00:00+00:00","appId":"MOCK_APP_12","appName":"中医馆健康信息系统","sourceKind":"APPLICATION","sourceMessageId":"P4_MSG_0_7","messageType":"BUSINESS","title":"办理意见已反馈","content":"办理意见已反馈。请查看相关事项详情并按办理要求完成后续操作。","url":"https://p4.invalid/app/12","userId":"MOCK_USER_1","status":"UNREAD","readAt":null,"deleted":false,"deletedAt":null},{"id":"MOCK_MSG_0_8","version":1,"createdAt":"2026-09-18T00:00:00+00:00","updatedAt":"2026-09-18T00:00:00+00:00","receivedAt":"2026-09-18T00:00:00+00:00","appId":null,"appName":"","sourceKind":"PORTAL","sourceMessageId":"P4_MSG_0_8","messageType":"SYSTEM","title":"门户维护安排","content":"门户维护安排。请查看相关事项详情并按办理要求完成后续操作。","url":null,"userId":"MOCK_USER_1","status":"READ","readAt":"2026-09-17T23:00:00+00:00","deleted":false,"deletedAt":null},{"id":"MOCK_MSG_0_9","version":1,"createdAt":"2026-09-18T00:00:00+00:00","updatedAt":"2026-09-18T00:00:00+00:00","receivedAt":"2026-09-18T00:00:00+00:00","appId":null,"appName":"","sourceKind":"PORTAL","sourceMessageId":"P4_MSG_0_9","messageType":"SYSTEM","title":"信息安全提醒","content":"信息安全提醒。请查看相关事项详情并按办理要求完成后续操作。","url":null,"userId":"MOCK_USER_1","status":"READ","readAt":"2026-09-17T23:00:00+00:00","deleted":false,"deletedAt":null},{"id":"MOCK_MSG_1_0","version":2,"createdAt":"2026-09-18T00:00:00+00:00","updatedAt":"2026-09-18T16:32:04.31+00:00","receivedAt":"2026-09-18T00:00:00+00:00","appId":"MOCK_APP_1","appName":"福建省新生儿疾病筛查管理系统","sourceKind":"APPLICATION","sourceMessageId":"P4_MSG_1_0","messageType":"BUSINESS","title":"服务申请已受理","content":"服务申请已受理。请查看相关事项详情并按办理要求完成后续操作。","url":"https://p4.invalid/app/1","userId":"MOCK_USER_2","status":"READ","readAt":"2026-09-18T16:32:04.31+00:00","deleted":false,"deletedAt":null},{"id":"MOCK_MSG_1_1","version":2,"createdAt":"2026-09-18T00:00:00+00:00","updatedAt":"2026-09-18T15:31:44.193+00:00","receivedAt":"2026-09-18T00:00:00+00:00","appId":"MOCK_APP_2","appName":"福建省妇幼卫生信息系统","sourceKind":"APPLICATION","sourceMessageId":"P4_MSG_1_1","messageType":"BUSINESS","title":"资料核验进度通知","content":"资料核验进度通知。请查看相关事项详情并按办理要求完成后续操作。","url":"https://p4.invalid/app/2","userId":"MOCK_USER_2","status":"READ","readAt":"2026-09-18T15:31:44.193+00:00","deleted":false,"deletedAt":null},{"id":"MOCK_MSG_1_2","version":2,"createdAt":"2026-09-18T00:00:00+00:00","updatedAt":"2026-09-18T16:27:06.299+00:00","receivedAt":"2026-09-18T00:00:00+00:00","appId":"MOCK_APP_3","appName":"福建省产前筛查与诊断管理系统","sourceKind":"APPLICATION","sourceMessageId":"P4_MSG_1_2","messageType":"TODO_REMINDER","title":"办理期限提醒","content":"办理期限�������������醒。请查看相关事项详情并按办理要求完成后续操作。","url":"https://p4.invalid/app/3","userId":"MOCK_USER_2","status":"READ","readAt":"2026-09-18T16:27:06.299+00:00","deleted":false,"deletedAt":null},{"id":"MOCK_MSG_1_3","version":1,"createdAt":"2026-09-18T00:00:00+00:00","updatedAt":"2026-09-18T00:00:00+00:00","receivedAt":"2026-09-18T00:00:00+00:00","appId":"MOCK_APP_4","appName":"福建省地中海贫血信息管理系统","sourceKind":"APPLICATION","sourceMessageId":"P4_MSG_1_3","messageType":"BUSINESS","title":"服务安排更新","content":"服务安排更新。请查看相关事项详情并按办理要求完成后续操作。","url":"https://p4.invalid/app/4","userId":"MOCK_USER_2","status":"UNREAD","readAt":null,"deleted":false,"deletedAt":null},{"id":"MOCK_MSG_1_4","version":1,"createdAt":"2026-09-18T00:00:00+00:00","updatedAt":"2026-09-18T00:00:00+00:00","receivedAt":"2026-09-18T00:00:00+00:00","appId":"MOCK_APP_5","appName":"福建省慢病报告与管理系统","sourceKind":"APPLICATION","sourceMessageId":"P4_MSG_1_4","messageType":"BUSINESS","title":"账号关联结果通知","content":"账号关联结果通知。请查看相关事项详情并按办理要求完成后续操作。","url":"https://p4.invalid/app/5","userId":"MOCK_USER_2","status":"UNREAD","readAt":null,"deleted":false,"deletedAt":null},{"id":"MOCK_MSG_1_5","version":1,"createdAt":"2026-09-18T00:00:00+00:00","updatedAt":"2026-09-18T00:00:00+00:00","receivedAt":"2026-09-18T00:00:00+00:00","appId":"MOCK_APP_6","appName":"福建省区域影像平台","sourceKind":"APPLICATION","sourceMessageId":"P4_MSG_1_5","messageType":"BUSINESS","title":"业务信息变更提醒","content":"业务信息变更提醒。请查看相关事项详情并按办理要求完成后续操作。","url":"https://p4.invalid/app/6","userId":"MOCK_USER_2","status":"UNREAD","readAt":null,"deleted":false,"deletedAt":null},{"id":"MOCK_MSG_1_6","version":1,"createdAt":"2026-09-18T00:00:00+00:00","updatedAt":"2026-09-18T00:00:00+00:00","receivedAt":"2026-09-18T00:00:00+00:00","appId":"MOCK_APP_7","appName":"质控评分系统","sourceKind":"APPLICATION","sourceMessageId":"P4_MSG_1_6","messageType":"BUSINESS","title":"材料补正通知","content":"材料补正通知。请查看相关事项详情并按办理要求完成后续操作。","url":"https://p4.invalid/app/7","userId":"MOCK_USER_2","status":"UNREAD","readAt":null,"deleted":false,"deletedAt":null},{"id":"MOCK_MSG_1_7","version":1,"createdAt":"2026-09-18T00:00:00+00:00","updatedAt":"2026-09-18T00:00:00+00:00","receivedAt":"2026-09-18T00:00:00+00:00","appId":"MOCK_APP_8","appName":"省级平台决策支持展示系统","sourceKind":"APPLICATION","sourceMessageId":"P4_MSG_1_7","messageType":"BUSINESS","title":"办理意见已反馈","content":"办理意见已反馈。请查看相关事项详情并按办理要求完成后续操作。","url":"https://p4.invalid/app/8","userId":"MOCK_USER_2","status":"UNREAD","readAt":null,"deleted":false,"deletedAt":null},{"id":"MOCK_MSG_1_8","version":1,"createdAt":"2026-09-18T00:00:00+00:00","updatedAt":"2026-09-18T00:00:00+00:00","receivedAt":"2026-09-18T00:00:00+00:00","appId":null,"appName":"","sourceKind":"PORTAL","sourceMessageId":"P4_MSG_1_8","messageType":"SYSTEM","title":"门户维护安排","content":"门户维护安排。请查看相关事项详情并按办理要求完成后续操作。","url":null,"userId":"MOCK_USER_2","status":"READ","readAt":"2026-09-17T23:00:00+00:00","deleted":false,"deletedAt":null},{"id":"MOCK_MSG_1_9","version":1,"createdAt":"2026-09-18T00:00:00+00:00","updatedAt":"2026-09-18T00:00:00+00:00","receivedAt":"2026-09-18T00:00:00+00:00","appId":null,"appName":"","sourceKind":"PORTAL","sourceMessageId":"P4_MSG_1_9","messageType":"SYSTEM","title":"信息安全提醒","content":"信息安全提醒。请查看相关事项详情并按办理要求完成后续操作。","url":null,"userId":"MOCK_USER_2","status":"READ","readAt":"2026-09-17T23:00:00+00:00","deleted":false,"deletedAt":null},{"id":"MOCK_MSG_2_0","version":2,"createdAt":"2026-09-18T00:00:00+00:00","updatedAt":"2026-09-18T15:48:12.994+00:00","receivedAt":"2026-09-18T00:00:00+00:00","appId":"MOCK_APP_1","appName":"福建省新生儿疾病筛查管理系统","sourceKind":"APPLICATION","sourceMessageId":"P4_MSG_2_0","messageType":"BUSINESS","title":"服务申请已受理","content":"服务申请已受理。请查看相关事项详情并按办理要求完成后续操作。","url":"https://p4.invalid/app/1","userId":"MOCK_ADMIN","status":"READ","readAt":"2026-09-18T15:48:12.994+00:00","deleted":false,"deletedAt":null},{"id":"MOCK_MSG_2_1","version":2,"createdAt":"2026-09-18T00:00:00+00:00","updatedAt":"2026-09-18T15:48:33.066+00:00","receivedAt":"2026-09-18T00:00:00+00:00","appId":"MOCK_APP_2","appName":"福建省妇幼卫生信息系统","sourceKind":"APPLICATION","sourceMessageId":"P4_MSG_2_1","messageType":"BUSINESS","title":"资料核验进度通知","content":"资料核验进度通知。请查看相关事项详情并按办理要求完成后续操作。","url":"https://p4.invalid/app/2","userId":"MOCK_ADMIN","status":"READ","readAt":"2026-09-18T15:48:33.066+00:00","deleted":false,"deletedAt":null},{"id":"MOCK_MSG_2_2","version":2,"createdAt":"2026-09-18T00:00:00+00:00","updatedAt":"2026-09-18T16:12:43.994+00:00","receivedAt":"2026-09-18T00:00:00+00:00","appId":"MOCK_APP_3","appName":"福建省产前筛查与诊断管理系统","sourceKind":"APPLICATION","sourceMessageId":"P4_MSG_2_2","messageType":"TODO_REMINDER","title":"办理期限提醒","content":"办理期限提醒。请查看相关事项详情并按办理要求完成后续操作。","url":"https://p4.invalid/app/3","userId":"MOCK_ADMIN","status":"READ","readAt":"2026-09-18T16:12:43.994+00:00","deleted":false,"deletedAt":null},{"id":"MOCK_MSG_2_3","version":2,"createdAt":"2026-09-18T00:00:00+00:00","updatedAt":"2026-09-18T16:13:40.36+00:00","receivedAt":"2026-09-18T00:00:00+00:00","appId":"MOCK_APP_4","appName":"福建省地中海贫血信息管理系统","sourceKind":"APPLICATION","sourceMessageId":"P4_MSG_2_3","messageType":"BUSINESS","title":"服务安排更新","content":"服务安排更新。请查看相关事项详情并按办理要求完成后续操作。","url":"https://p4.invalid/app/4","userId":"MOCK_ADMIN","status":"READ","readAt":"2026-09-18T16:13:40.36+00:00","deleted":false,"deletedAt":null},{"id":"MOCK_MSG_2_4","version":2,"createdAt":"2026-09-18T00:00:00+00:00","updatedAt":"2026-09-19T11:16:27.075+00:00","receivedAt":"2026-09-18T00:00:00+00:00","appId":"MOCK_APP_5","appName":"福建省慢病报告与管理系统","sourceKind":"APPLICATION","sourceMessageId":"P4_MSG_2_4","messageType":"BUSINESS","title":"账号关联结果通知","content":"账号关联结果通知。请查看相关事项详情并按办理要求完成后续操作。","url":"https://p4.invalid/app/5","userId":"MOCK_ADMIN","status":"READ","readAt":"2026-09-19T11:16:27.075+00:00","deleted":false,"deletedAt":null},{"id":"MOCK_MSG_2_5","version":2,"createdAt":"2026-09-18T00:00:00+00:00","updatedAt":"2026-09-19T12:56:48.398+00:00","receivedAt":"2026-09-18T00:00:00+00:00","appId":"MOCK_APP_6","appName":"福建省区域影像平台","sourceKind":"APPLICATION","sourceMessageId":"P4_MSG_2_5","messageType":"BUSINESS","title":"业务信息变更提醒","content":"业务信息变更提醒。请查看相关事项详情并按办理要求完成后续操作。","url":"https://p4.invalid/app/6","userId":"MOCK_ADMIN","status":"READ","readAt":"2026-09-19T12:56:48.398+00:00","deleted":false,"deletedAt":null},{"id":"MOCK_MSG_2_6","version":2,"createdAt":"2026-09-18T00:00:00+00:00","updatedAt":"2026-09-20T06:54:31.275+00:00","receivedAt":"2026-09-18T00:00:00+00:00","appId":"MOCK_APP_7","appName":"质控评分系统","sourceKind":"APPLICATION","sourceMessageId":"P4_MSG_2_6","messageType":"BUSINESS","title":"材料补正通知","content":"材料补正通知。请查看相关事项详情并按办理要求完成后续操作。","url":"https://p4.invalid/app/7","userId":"MOCK_ADMIN","status":"READ","readAt":"2026-09-20T06:54:31.275+00:00","deleted":false,"deletedAt":null},{"id":"MOCK_MSG_2_7","version":2,"createdAt":"2026-09-18T00:00:00+00:00","updatedAt":"2026-09-20T07:24:30.642+00:00","receivedAt":"2026-09-18T00:00:00+00:00","appId":"MOCK_APP_8","appName":"省级平台决策支持展示系统","sourceKind":"APPLICATION","sourceMessageId":"P4_MSG_2_7","messageType":"BUSINESS","title":"办理意见已反馈","content":"办理意见已反馈。请查看相关事项详情并按办理要求完成后续操作。","url":"https://p4.invalid/app/8","userId":"MOCK_ADMIN","status":"READ","readAt":"2026-09-20T07:24:30.642+00:00","deleted":false,"deletedAt":null},{"id":"MOCK_MSG_2_8","version":1,"createdAt":"2026-09-18T00:00:00+00:00","updatedAt":"2026-09-18T00:00:00+00:00","receivedAt":"2026-09-18T00:00:00+00:00","appId":null,"appName":"","sourceKind":"PORTAL","sourceMessageId":"P4_MSG_2_8","messageType":"SYSTEM","title":"门户维护安排","content":"门户维护安排。请查看相关事项详情并按办理要求完成后续操作。","url":null,"userId":"MOCK_ADMIN","status":"READ","readAt":"2026-09-17T23:00:00+00:00","deleted":false,"deletedAt":null},{"id":"MOCK_MSG_2_9","version":1,"createdAt":"2026-09-18T00:00:00+00:00","updatedAt":"2026-09-18T00:00:00+00:00","receivedAt":"2026-09-18T00:00:00+00:00","appId":null,"appName":"","sourceKind":"PORTAL","sourceMessageId":"P4_MSG_2_9","messageType":"SYSTEM","title":"信息安全提醒","content":"信息安全提醒。请查看相关事项详情并按办理要求完成后续操作。","url":null,"userId":"MOCK_ADMIN","status":"READ","readAt":"2026-09-17T23:00:00+00:00","deleted":false,"deletedAt":null},{"id":"MOCK_MSG_3_0","version":1,"createdAt":"2026-09-18T00:00:00+00:00","updatedAt":"2026-09-18T00:00:00+00:00","receivedAt":"2026-09-18T00:00:00+00:00","appId":"MOCK_APP_1","appName":"福建省新生儿疾病筛查管理系统","sourceKind":"APPLICATION","sourceMessageId":"P4_MSG_3_0","messageType":"BUSINESS","title":"服务申请已受理","content":"服务申请已受理。请查看相关事项详情并按办理要求完成后续操作。","url":"https://p4.invalid/app/1","userId":"MOCK_EDITOR","status":"UNREAD","readAt":null,"deleted":false,"deletedAt":null},{"id":"MOCK_MSG_3_1","version":1,"createdAt":"2026-09-18T00:00:00+00:00","updatedAt":"2026-09-18T00:00:00+00:00","receivedAt":"2026-09-18T00:00:00+00:00","appId":"MOCK_APP_2","appName":"福建省妇幼卫生信息系统","sourceKind":"APPLICATION","sourceMessageId":"P4_MSG_3_1","messageType":"BUSINESS","title":"资料核验进度通知","content":"资料核验进度通知。请查看相关事项详情并按办理要求完成后续操作。","url":"https://p4.invalid/app/2","userId":"MOCK_EDITOR","status":"UNREAD","readAt":null,"deleted":false,"deletedAt":null},{"id":"MOCK_MSG_3_2","version":1,"createdAt":"2026-09-18T00:00:00+00:00","updatedAt":"2026-09-18T00:00:00+00:00","receivedAt":"2026-09-18T00:00:00+00:00","appId":"MOCK_APP_3","appName":"福建省产前筛查与诊断管理系统","sourceKind":"APPLICATION","sourceMessageId":"P4_MSG_3_2","messageType":"TODO_REMINDER","title":"办理期限提醒","content":"办理期限提醒。请查看相关事项详情并按办理要求完成后续操作。","url":"https://p4.invalid/app/3","userId":"MOCK_EDITOR","status":"UNREAD","readAt":null,"deleted":false,"deletedAt":null},{"id":"MOCK_MSG_3_3","version":1,"createdAt":"2026-09-18T00:00:00+00:00","updatedAt":"2026-09-18T00:00:00+00:00","receivedAt":"2026-09-18T00:00:00+00:00","appId":"MOCK_APP_4","appName":"福建省地中海贫血信息管理系统","sourceKind":"APPLICATION","sourceMessageId":"P4_MSG_3_3","messageType":"BUSINESS","title":"服务安排更新","content":"服务安排更新。请查看相关事项详情并按办理要求完成后续操作。","url":"https://p4.invalid/app/4","userId":"MOCK_EDITOR","status":"UNREAD","readAt":null,"deleted":false,"deletedAt":null},{"id":"MOCK_MSG_3_4","version":1,"createdAt":"2026-09-18T00:00:00+00:00","updatedAt":"2026-09-18T00:00:00+00:00","receivedAt":"2026-09-18T00:00:00+00:00","appId":"MOCK_APP_5","appName":"福建省慢病报告与管理系统","sourceKind":"APPLICATION","sourceMessageId":"P4_MSG_3_4","messageType":"BUSINESS","title":"账号关联结果通知","content":"账号关联结果通知。请查看相关事项详情并按办理要求完成后续操作。","url":"https://p4.invalid/app/5","userId":"MOCK_EDITOR","status":"UNREAD","readAt":null,"deleted":false,"deletedAt":null},{"id":"MOCK_MSG_3_5","version":1,"createdAt":"2026-09-18T00:00:00+00:00","updatedAt":"2026-09-18T00:00:00+00:00","receivedAt":"2026-09-18T00:00:00+00:00","appId":"MOCK_APP_6","appName":"福建省区域影像平台","sourceKind":"APPLICATION","sourceMessageId":"P4_MSG_3_5","messageType":"BUSINESS","title":"业务信息变更提醒","content":"业务信息变更提醒。请查看相关事项详情并按办理要求完成后续操作。","url":"https://p4.invalid/app/6","userId":"MOCK_EDITOR","status":"UNREAD","readAt":null,"deleted":false,"deletedAt":null},{"id":"MOCK_MSG_3_6","version":1,"createdAt":"2026-09-18T00:00:00+00:00","updatedAt":"2026-09-18T00:00:00+00:00","receivedAt":"2026-09-18T00:00:00+00:00","appId":"MOCK_APP_7","appName":"质控评分系统","sourceKind":"APPLICATION","sourceMessageId":"P4_MSG_3_6","messageType":"BUSINESS","title":"材料补正通知","content":"材料补正通知。请查看相关事项详情并按办理要求完成后续操作。","url":"https://p4.invalid/app/7","userId":"MOCK_EDITOR","status":"UNREAD","readAt":null,"deleted":false,"deletedAt":null},{"id":"MOCK_MSG_3_7","version":1,"createdAt":"2026-09-18T00:00:00+00:00","updatedAt":"2026-09-18T00:00:00+00:00","receivedAt":"2026-09-18T00:00:00+00:00","appId":"MOCK_APP_8","appName":"省级平台决策支持展示系统","sourceKind":"APPLICATION","sourceMessageId":"P4_MSG_3_7","messageType":"BUSINESS","title":"办理意见已反馈","content":"办理意见已反馈。请查看相关事项详情并按办理要求完成后续操作。","url":"https://p4.invalid/app/8","userId":"MOCK_EDITOR","status":"UNREAD","readAt":null,"deleted":false,"deletedAt":null},{"id":"MOCK_MSG_3_8","version":1,"createdAt":"2026-09-18T00:00:00+00:00","updatedAt":"2026-09-18T00:00:00+00:00","receivedAt":"2026-09-18T00:00:00+00:00","appId":null,"appName":"","sourceKind":"PORTAL","sourceMessageId":"P4_MSG_3_8","messageType":"SYSTEM","title":"门户维护安排","content":"门户维护安排。请查看相关事项详情并按办理要求完成后续操作。","url":null,"userId":"MOCK_EDITOR","status":"READ","readAt":"2026-09-17T23:00:00+00:00","deleted":false,"deletedAt":null},{"id":"MOCK_MSG_3_9","version":1,"createdAt":"2026-09-18T00:00:00+00:00","updatedAt":"2026-09-18T00:00:00+00:00","receivedAt":"2026-09-18T00:00:00+00:00","appId":null,"appName":"","sourceKind":"PORTAL","sourceMessageId":"P4_MSG_3_9","messageType":"SYSTEM","title":"信息安全提醒","content":"信息安全提醒。请查看相关事项详情并按办理要求完成后续操作。","url":null,"userId":"MOCK_EDITOR","status":"READ","readAt":"2026-09-17T23:00:00+00:00","deleted":false,"deletedAt":null}],"receipts":[],"settings":[{"id":"MOCK_CONFIG_0","code":"retention.message_days","name":"消息留存周期（天）","unit":"day","value":90,"status":"CONFIGURED","version":3,"createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-18T17:28:40.527Z"},{"id":"MOCK_CONFIG_1","code":"retention.todo_terminal_days","name":"终态待办留存周期（天）","unit":"day","value":180,"status":"CONFIGURED","version":3,"createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-18T17:28:40.527Z"},{"id":"MOCK_CONFIG_2","code":"retention.log_days","name":"日志留存周期（天）","unit":"day","value":180,"status":"CONFIGURED","version":3,"createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-18T17:28:40.527Z"},{"id":"MOCK_CONFIG_3","code":"auth.session_ttl_seconds","name":"会话有效期（秒）","unit":"second","value":7200,"status":"CONFIGURED","version":3,"createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-18T17:28:40.527Z"},{"id":"MOCK_CONFIG_4","code":"integration.timeout_ms","name":"接口超时（毫秒）","unit":"millisecond","value":5000,"status":"CONFIGURED","version":3,"createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-18T17:28:40.527Z"},{"id":"MOCK_CONFIG_5","code":"integration.max_retries","name":"接口重试上限","unit":"count","value":3,"status":"CONFIGURED","version":3,"createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-18T17:28:40.527Z"},{"id":"MOCK_CONFIG_6","code":"monitor.failure_threshold","name":"连续失败告警阈值","unit":"count","value":5,"status":"CONFIGURED","version":3,"createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-18T17:28:40.527Z"},{"id":"MOCK_CONFIG_7","code":"portal.page_size","name":"列表每页条数","unit":"count","value":15,"status":"CONFIGURED","version":3,"createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-18T17:28:40.527Z"},{"id":"RULE_retention.announcement_expired_days","max":3650,"min":0,"code":"retention.announcement_expired_days","help":"0 表示不自动删除；仅处理已发布且有失效时间的公告。清理记录保留在回收档案和审计中。","name":"公告过期后自动删除","unit":"天","group":"公告规则","value":0,"status":"CONFIGURED","default":0,"version":3,"updatedAt":"2026-09-18T17:28:40.527Z"}],"dictItems":[{"id":"MOCK_DICT_APP_PUBLIC","label":"公众服务","value":"PUBLIC","remark":"应用分类","status":"ENABLED","version":1,"typeCode":"application_category","createdAt":"2026-09-16T00:00:00.000Z","sortOrder":1,"updatedAt":"2026-09-17T23:00:00.000Z","systemLocked":false},{"id":"MOCK_DICT_APP_GOV","label":"政务协同","value":"GOV","remark":"应用分类","status":"ENABLED","version":1,"typeCode":"application_category","createdAt":"2026-09-16T00:00:00.000Z","sortOrder":2,"updatedAt":"2026-09-17T23:00:00.000Z","systemLocked":false},{"id":"MOCK_DICT_APP_REGULATION","label":"行业监管","value":"REGULATION","remark":"应用分类","status":"ENABLED","version":1,"typeCode":"application_category","createdAt":"2026-09-16T00:00:00.000Z","sortOrder":3,"updatedAt":"2026-09-17T23:00:00.000Z","systemLocked":false},{"id":"MOCK_DICT_APP_TRAINING","label":"培训考试","value":"TRAINING","remark":"应用分类","status":"ENABLED","version":1,"typeCode":"application_category","createdAt":"2026-09-16T00:00:00.000Z","sortOrder":4,"updatedAt":"2026-09-17T23:00:00.000Z","systemLocked":false},{"id":"MOCK_DICT_APP_SUPERVISION","label":"卫生监督","value":"SUPERVISION","remark":"应用分类","status":"ENABLED","version":1,"typeCode":"application_category","createdAt":"2026-09-16T00:00:00.000Z","sortOrder":5,"updatedAt":"2026-09-17T23:00:00.000Z","systemLocked":false},{"id":"MOCK_DICT_APP_PREVENTION","label":"疾病防控","value":"PREVENTION","remark":"应用分类","status":"ENABLED","version":1,"typeCode":"application_category","createdAt":"2026-09-16T00:00:00.000Z","sortOrder":6,"updatedAt":"2026-09-17T23:00:00.000Z","systemLocked":false},{"id":"MOCK_DICT_ANN_0","label":"通知","value":"NOTICE","remark":"","status":"ENABLED","version":1,"typeCode":"announcement_type","createdAt":"2026-09-16T00:00:00.000Z","sortOrder":1,"updatedAt":"2026-09-17T23:00:00.000Z","systemLocked":false},{"id":"MOCK_DICT_ANN_1","label":"提示","value":"TIP","remark":"","status":"ENABLED","version":1,"typeCode":"announcement_type","createdAt":"2026-09-16T00:00:00.000Z","sortOrder":2,"updatedAt":"2026-09-17T23:00:00.000Z","systemLocked":false},{"id":"MOCK_DICT_ANN_2","label":"工作安排","value":"WORK","remark":"","status":"ENABLED","version":1,"typeCode":"announcement_type","createdAt":"2026-09-16T00:00:00.000Z","sortOrder":3,"updatedAt":"2026-09-17T23:00:00.000Z","systemLocked":false},{"id":"MOCK_DICT_ORG_0","label":"门户单位","value":"PORTAL_UNIT","remark":"","status":"ENABLED","version":1,"typeCode":"organization_type","createdAt":"2026-09-16T00:00:00.000Z","sortOrder":1,"updatedAt":"2026-09-17T23:00:00.000Z","systemLocked":false},{"id":"MOCK_DICT_ORG_1","label":"政务部门","value":"GOV_DEPARTMENT","remark":"","status":"ENABLED","version":1,"typeCode":"organization_type","createdAt":"2026-09-16T00:00:00.000Z","sortOrder":2,"updatedAt":"2026-09-17T23:00:00.000Z","systemLocked":false},{"id":"MOCK_DICT_ORG_2","label":"其他组织","value":"OTHER","remark":"","status":"ENABLED","version":1,"typeCode":"organization_type","createdAt":"2026-09-16T00:00:00.000Z","sortOrder":3,"updatedAt":"2026-09-17T23:00:00.000Z","systemLocked":false},{"id":"MOCK_DICT_ENABLE_0","label":"启用","value":"ENABLED","remark":"系统受控","status":"ENABLED","version":1,"typeCode":"enable_status","createdAt":"2026-09-16T00:00:00.000Z","sortOrder":1,"updatedAt":"2026-09-17T23:00:00.000Z","systemLocked":true},{"id":"MOCK_DICT_ENABLE_1","label":"停用","value":"DISABLED","remark":"系统受控","status":"ENABLED","version":1,"typeCode":"enable_status","createdAt":"2026-09-16T00:00:00.000Z","sortOrder":2,"updatedAt":"2026-09-17T23:00:00.000Z","systemLocked":true},{"id":"MOCK_DICT_RUNTIME_0","label":"正常","value":"NORMAL","remark":"系统受控","status":"ENABLED","version":1,"typeCode":"runtime_status","createdAt":"2026-09-16T00:00:00.000Z","sortOrder":1,"updatedAt":"2026-09-17T23:00:00.000Z","systemLocked":true},{"id":"MOCK_DICT_RUNTIME_1","label":"异常","value":"ABNORMAL","remark":"系统受控","status":"ENABLED","version":1,"typeCode":"runtime_status","createdAt":"2026-09-16T00:00:00.000Z","sortOrder":2,"updatedAt":"2026-09-17T23:00:00.000Z","systemLocked":true},{"id":"MOCK_DICT_RUNTIME_2","label":"未配置","value":"UNCONFIGURED","remark":"系统受控","status":"ENABLED","version":1,"typeCode":"runtime_status","createdAt":"2026-09-16T00:00:00.000Z","sortOrder":3,"updatedAt":"2026-09-17T23:00:00.000Z","systemLocked":true},{"id":"MOCK_DICT_RUNTIME_3","label":"停用","value":"DISABLED","remark":"系统受控","status":"ENABLED","version":1,"typeCode":"runtime_status","createdAt":"2026-09-16T00:00:00.000Z","sortOrder":4,"updatedAt":"2026-09-17T23:00:00.000Z","systemLocked":true},{"id":"MOCK_DICT_PROTOCOL_0","label":"OIDC","value":"OIDC","remark":"仅展示代码已支持协议","status":"ENABLED","version":1,"typeCode":"integration_protocol","createdAt":"2026-09-16T00:00:00.000Z","sortOrder":1,"updatedAt":"2026-09-17T23:00:00.000Z","systemLocked":true},{"id":"MOCK_DICT_PROTOCOL_1","label":"SAML2","value":"SAML2","remark":"仅展示代码已支持协议","status":"ENABLED","version":1,"typeCode":"integration_protocol","createdAt":"2026-09-16T00:00:00.000Z","sortOrder":2,"updatedAt":"2026-09-17T23:00:00.000Z","systemLocked":true},{"id":"MOCK_DICT_PROTOCOL_2","label":"CUSTOM","value":"CUSTOM","remark":"仅展示代码已支持协议","status":"ENABLED","version":1,"typeCode":"integration_protocol","createdAt":"2026-09-16T00:00:00.000Z","sortOrder":3,"updatedAt":"2026-09-17T23:00:00.000Z","systemLocked":true},{"id":"MOCK_DICT_PROTOCOL_3","label":"PUSH","value":"PUSH","remark":"仅展示代码已支持协议","status":"ENABLED","version":1,"typeCode":"integration_protocol","createdAt":"2026-09-16T00:00:00.000Z","sortOrder":4,"updatedAt":"2026-09-17T23:00:00.000Z","systemLocked":true}],"dictTypes":[{"id":"MOCK_DICT_TYPE_APP_CATEGORY","code":"application_category","name":"应用系统分类","status":"ENABLED","version":1,"createdAt":"2026-09-16T00:00:00.000Z","sortOrder":1,"updatedAt":"2026-09-17T23:00:00.000Z","description":"应用目录使用的业务分类","systemLocked":false},{"id":"MOCK_DICT_TYPE_ANN_TYPE","code":"announcement_type","name":"公告类型","status":"ENABLED","version":1,"createdAt":"2026-09-16T00:00:00.000Z","sortOrder":2,"updatedAt":"2026-09-17T23:00:00.000Z","description":"通知公告业务类型","systemLocked":false},{"id":"MOCK_DICT_TYPE_ORG_TYPE","code":"organization_type","name":"组织类型","status":"ENABLED","version":1,"createdAt":"2026-09-16T00:00:00.000Z","sortOrder":3,"updatedAt":"2026-09-17T23:00:00.000Z","description":"门户组织索引类型","systemLocked":false},{"id":"MOCK_DICT_TYPE_ENABLE","code":"enable_status","name":"启用状态","status":"ENABLED","version":1,"createdAt":"2026-09-16T00:00:00.000Z","sortOrder":90,"updatedAt":"2026-09-17T23:00:00.000Z","description":"系统受控状态字典","systemLocked":true},{"id":"MOCK_DICT_TYPE_RUNTIME","code":"runtime_status","name":"运行状态","status":"ENABLED","version":1,"createdAt":"2026-09-16T00:00:00.000Z","sortOrder":91,"updatedAt":"2026-09-17T23:00:00.000Z","description":"系统受控运行状态","systemLocked":true},{"id":"MOCK_DICT_TYPE_PROTOCOL","code":"integration_protocol","name":"接入协议","status":"ENABLED","version":1,"createdAt":"2026-09-16T00:00:00.000Z","sortOrder":92,"updatedAt":"2026-09-17T23:00:00.000Z","description":"代码已支持的接入协议","systemLocked":true}],"platforms":[{"id":"MOCK_PLATFORM_1","name":"福建省全民健康信息平台","sourceNo":1},{"id":"MOCK_PLATFORM_2","name":"福建省全员人口计划生育服务与管理平台","sourceNo":2},{"id":"MOCK_PLATFORM_3","name":"福建省卫健委综合监管平台","sourceNo":3},{"id":"MOCK_PLATFORM_4","name":"福建省保健对象医疗管理信息系统","sourceNo":4},{"id":"MOCK_PLATFORM_5","name":"省职控制中心门户网站","sourceNo":5},{"id":"MOCK_PLATFORM_6","name":"省卫监所综合管理系统","sourceNo":6},{"id":"MOCK_PLATFORM_7","name":"省疾控中心综合管理系统","sourceNo":7}],"categories":[{"id":"MOCK_CAT_1","code":"PUBLIC","name":"公众服务","status":"ENABLED","version":1,"createdAt":"2026-09-18T00:00:00+00:00","sortOrder":0,"updatedAt":"2026-09-17T23:00:00+00:00","remark":"P4 fixture"},{"id":"MOCK_CAT_2","code":"GOV","name":"政务协同","status":"ENABLED","version":1,"createdAt":"2026-09-18T00:00:00+00:00","sortOrder":1,"updatedAt":"2026-09-17T23:00:00+00:00","remark":"P4 fixture"},{"id":"MOCK_CAT_3","code":"REGULATION","name":"行业监管","status":"ENABLED","version":1,"createdAt":"2026-09-18T00:00:00+00:00","sortOrder":2,"updatedAt":"2026-09-17T23:00:00+00:00","remark":"P4 fixture"},{"id":"MOCK_CAT_4","code":"TRAINING","name":"培训考试","status":"ENABLED","version":1,"createdAt":"2026-09-18T00:00:00+00:00","sortOrder":3,"updatedAt":"2026-09-17T23:00:00+00:00","remark":"P4 fixture"},{"id":"MOCK_CAT_5","code":"SUPERVISION","name":"卫生监督","status":"ENABLED","version":1,"createdAt":"2026-09-18T00:00:00+00:00","sortOrder":4,"updatedAt":"2026-09-17T23:00:00+00:00","remark":"P4 fixture"},{"id":"MOCK_CAT_6","code":"PREVENTION","name":"疾病防控","status":"ENABLED","version":1,"createdAt":"2026-09-18T00:00:00+00:00","sortOrder":5,"updatedAt":"2026-09-17T23:00:00+00:00","remark":"P4 fixture"}],"integrations":[{"id":"MOCK_INT_MOCK_APP_1SSO","kind":"SSO","mode":"SSO","name":"福建省新生儿疾病筛查管理系统 · SSO","appId":"MOCK_APP_1","remark":"接入参数待业务系统确认","status":"UNCONFIGURED","appName":"福建省新生儿疾病筛查管理系统","enabled":"DISABLED","version":1,"createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","valueMapping":{},"lastCheckedAt":"2026-09-17T23:00:00.000Z","connectionStatus":"UNCONFIGURED"},{"id":"MOCK_INT_MOCK_APP_1TODO","kind":"TODO","mode":"PUSH","name":"福建省新生儿疾病筛查管理系统 · TODO","appId":"MOCK_APP_1","remark":"接入参数待业务系统确认","status":"DISABLED","appName":"福建省新生儿疾病筛查管理系统","enabled":"DISABLED","version":2,"clientId":"","protocol":"PUSH","tokenUrl":"","createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-18T14:50:14.759Z","callbackUrl":"","authorizeUrl":"","fieldMapping":{},"valueMapping":{},"credentialRef":"","lastCheckedAt":"2026-09-17T22:00:00.000Z","connectionStatus":"UNCONFIGURED"},{"id":"MOCK_INT_MOCK_APP_1MESSAGE","kind":"MESSAGE","mode":"PUSH","name":"福建省新生儿疾病筛查管理系统 · MESSAGE","appId":"MOCK_APP_1","remark":"接入参数待业务系统确认","status":"UNCONFIGURED","appName":"福建省新生儿疾病筛查管理系统","enabled":"DISABLED","version":1,"createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","valueMapping":{},"lastCheckedAt":"2026-09-17T21:00:00.000Z","connectionStatus":"UNCONFIGURED"},{"id":"MOCK_INT_MOCK_APP_2SSO","kind":"SSO","mode":"SSO","name":"福建省妇幼卫生信息系统 · SSO","appId":"MOCK_APP_2","remark":"接入参数待业务系统确认","status":"UNCONFIGURED","appName":"福建省妇幼卫生信息系统","enabled":"DISABLED","version":1,"createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","valueMapping":{},"lastCheckedAt":"2026-09-17T23:00:00.000Z","connectionStatus":"UNCONFIGURED"},{"id":"MOCK_INT_MOCK_APP_2TODO","kind":"TODO","mode":"PUSH","name":"福建省妇幼卫生信息系统 · TODO","appId":"MOCK_APP_2","remark":"接入参数待业务系统确认","status":"UNCONFIGURED","appName":"福建省妇幼卫生信息系统","enabled":"DISABLED","version":1,"createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","valueMapping":{},"lastCheckedAt":"2026-09-17T22:00:00.000Z","connectionStatus":"UNCONFIGURED"},{"id":"MOCK_INT_MOCK_APP_2MESSAGE","kind":"MESSAGE","mode":"PUSH","name":"福建省妇幼卫生信息系统 · MESSAGE","appId":"MOCK_APP_2","remark":"接入参数待业务系统确认","status":"DISABLED","appName":"福建省妇幼卫生信息系统","enabled":"DISABLED","version":1,"createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","valueMapping":{},"lastCheckedAt":"2026-09-17T21:00:00.000Z","connectionStatus":"UNCONFIGURED"},{"id":"MOCK_INT_MOCK_APP_3SSO","kind":"SSO","mode":"SSO","name":"福建省产前筛查与诊断管理系统 · SSO","appId":"MOCK_APP_3","remark":"接入参数待业务系统确认","status":"UNCONFIGURED","appName":"福建省产前筛查与诊断管理系统","enabled":"DISABLED","version":1,"createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","valueMapping":{},"lastCheckedAt":"2026-09-17T23:00:00.000Z","connectionStatus":"UNCONFIGURED"},{"id":"MOCK_INT_MOCK_APP_3TODO","kind":"TODO","mode":"PUSH","name":"福建省产前筛查与诊断管理系统 · TODO","appId":"MOCK_APP_3","remark":"接入参数待业务系统确认","status":"DISABLED","appName":"福建省产前筛查与诊断管理系统","enabled":"DISABLED","version":1,"createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","valueMapping":{},"lastCheckedAt":"2026-09-17T22:00:00.000Z","connectionStatus":"UNCONFIGURED"},{"id":"MOCK_INT_MOCK_APP_3MESSAGE","kind":"MESSAGE","mode":"PUSH","name":"福建省产前筛查与诊断管理系统 · MESSAGE","appId":"MOCK_APP_3","remark":"接入参数待业务系统确认","status":"UNCONFIGURED","appName":"福建省产前筛查与诊断管理系统","enabled":"DISABLED","version":1,"createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","valueMapping":{},"lastCheckedAt":"2026-09-17T21:00:00.000Z","connectionStatus":"UNCONFIGURED"},{"id":"MOCK_INT_MOCK_APP_4SSO","kind":"SSO","mode":"SSO","name":"福建省地中海贫血信息管理系统 · SSO","appId":"MOCK_APP_4","remark":"接入参数待业务系统确认","status":"DISABLED","appName":"福建省地中海贫血信息管理系统","enabled":"DISABLED","version":1,"createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","valueMapping":{},"lastCheckedAt":"2026-09-17T23:00:00.000Z","connectionStatus":"UNCONFIGURED"},{"id":"MOCK_INT_MOCK_APP_4TODO","kind":"TODO","mode":"PUSH","name":"福建省地中海贫血信息管理系统 · TODO","appId":"MOCK_APP_4","remark":"接入参数待业务系统确认","status":"UNCONFIGURED","appName":"福建省地中海贫血信息管理系统","enabled":"DISABLED","version":1,"createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","valueMapping":{},"lastCheckedAt":"2026-09-17T22:00:00.000Z","connectionStatus":"UNCONFIGURED"},{"id":"MOCK_INT_MOCK_APP_4MESSAGE","kind":"MESSAGE","mode":"PUSH","name":"福建省地中海贫血信息管理系统 · MESSAGE","appId":"MOCK_APP_4","remark":"接入参数待业务系统确认","status":"UNCONFIGURED","appName":"福建省地中海贫血信息管理系统","enabled":"DISABLED","version":1,"createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","valueMapping":{},"lastCheckedAt":"2026-09-17T21:00:00.000Z","connectionStatus":"UNCONFIGURED"},{"id":"MOCK_INT_MOCK_APP_5SSO","kind":"SSO","mode":"SSO","name":"福建省慢病报告与管理系统 · SSO","appId":"MOCK_APP_5","remark":"接入参数待业务系统确认","status":"UNCONFIGURED","appName":"福建省慢病报告与管理系统","enabled":"DISABLED","version":1,"createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","valueMapping":{},"lastCheckedAt":"2026-09-17T23:00:00.000Z","connectionStatus":"UNCONFIGURED"},{"id":"MOCK_INT_MOCK_APP_5TODO","kind":"TODO","mode":"PUSH","name":"福建省慢病报告与管理系统 · TODO","appId":"MOCK_APP_5","remark":"接入参数待业务系统确认","status":"UNCONFIGURED","appName":"福建省慢病报告与管理系统","enabled":"DISABLED","version":1,"createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","valueMapping":{},"lastCheckedAt":"2026-09-17T22:00:00.000Z","connectionStatus":"UNCONFIGURED"},{"id":"MOCK_INT_MOCK_APP_5MESSAGE","kind":"MESSAGE","mode":"PUSH","name":"福建省慢病报告与管理系统 · MESSAGE","appId":"MOCK_APP_5","remark":"接入参数待业务系统确认","status":"UNCONFIGURED","appName":"福建省慢病报告与管理系统","enabled":"DISABLED","version":1,"createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","valueMapping":{},"lastCheckedAt":"2026-09-17T21:00:00.000Z","connectionStatus":"UNCONFIGURED"},{"id":"MOCK_INT_MOCK_APP_6SSO","kind":"SSO","mode":"SSO","name":"福建省区域影像平台 · SSO","appId":"MOCK_APP_6","remark":"接入参数待业务系统确认","status":"UNCONFIGURED","appName":"福建省区域影像平台","enabled":"DISABLED","version":1,"createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","valueMapping":{},"lastCheckedAt":"2026-09-17T23:00:00.000Z","connectionStatus":"UNCONFIGURED"},{"id":"MOCK_INT_MOCK_APP_6TODO","kind":"TODO","mode":"PUSH","name":"福建省区域影像平台 · TODO","appId":"MOCK_APP_6","remark":"接入参数���业务系统确认","status":"UNCONFIGURED","appName":"福建省区域影像平台","enabled":"DISABLED","version":1,"createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","valueMapping":{},"lastCheckedAt":"2026-09-17T22:00:00.000Z","connectionStatus":"UNCONFIGURED"},{"id":"MOCK_INT_MOCK_APP_6MESSAGE","kind":"MESSAGE","mode":"PUSH","name":"福建省区域影像平台 · MESSAGE","appId":"MOCK_APP_6","remark":"接入参数待业务系统确认","status":"DISABLED","appName":"福建省区域影像平台","enabled":"DISABLED","version":1,"createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","valueMapping":{},"lastCheckedAt":"2026-09-17T21:00:00.000Z","connectionStatus":"UNCONFIGURED"},{"id":"MOCK_INT_MOCK_APP_7SSO","kind":"SSO","mode":"SSO","name":"质控评分系统 · SSO","appId":"MOCK_APP_7","remark":"接入参数待业务系统确认","status":"UNCONFIGURED","appName":"质控评分系统","enabled":"DISABLED","version":1,"createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","valueMapping":{},"lastCheckedAt":"2026-09-17T23:00:00.000Z","connectionStatus":"UNCONFIGURED"},{"id":"MOCK_INT_MOCK_APP_7TODO","kind":"TODO","mode":"PUSH","name":"质控评分系统 · TODO","appId":"MOCK_APP_7","remark":"接入参数待业务系统确认","status":"DISABLED","appName":"质控评分系统","enabled":"DISABLED","version":1,"createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","valueMapping":{},"lastCheckedAt":"2026-09-17T22:00:00.000Z","connectionStatus":"UNCONFIGURED"},{"id":"MOCK_INT_MOCK_APP_7MESSAGE","kind":"MESSAGE","mode":"PUSH","name":"质控评分系统 · MESSAGE","appId":"MOCK_APP_7","remark":"接入参数待业���系统确认","status":"UNCONFIGURED","appName":"质控评分系统","enabled":"DISABLED","version":1,"createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","valueMapping":{},"lastCheckedAt":"2026-09-17T21:00:00.000Z","connectionStatus":"UNCONFIGURED"},{"id":"MOCK_INT_MOCK_APP_8SSO","kind":"SSO","mode":"SSO","name":"省级平台决策支持展示系统 · SSO","appId":"MOCK_APP_8","remark":"接入参数待业务系统确认","status":"DISABLED","appName":"省级平台决���支���展���系���","enabled":"DISABLED","version":1,"createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","valueMapping":{},"lastCheckedAt":"2026-09-17T23:00:00.000Z","connectionStatus":"UNCONFIGURED"},{"id":"MOCK_INT_MOCK_APP_8TODO","kind":"TODO","mode":"PUSH","name":"省级平台决策支持展示系统 · TODO","appId":"MOCK_APP_8","remark":"接入参数待业务系统确认","status":"UNCONFIGURED","appName":"省级平台决策支持展示系统","enabled":"DISABLED","version":1,"createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","valueMapping":{},"lastCheckedAt":"2026-09-17T22:00:00.000Z","connectionStatus":"UNCONFIGURED"},{"id":"MOCK_INT_MOCK_APP_8MESSAGE","kind":"MESSAGE","mode":"PUSH","name":"省级平台决策支持展示系统 · MESSAGE","appId":"MOCK_APP_8","remark":"接入参数待业务系统确认","status":"UNCONFIGURED","appName":"省���平�����决���支���展�����系统","enabled":"DISABLED","version":1,"createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","valueMapping":{},"lastCheckedAt":"2026-09-17T21:00:00.000Z","connectionStatus":"UNCONFIGURED"},{"id":"MOCK_INT_MOCK_APP_9SSO","kind":"SSO","mode":"SSO","name":"单点登录系统 · SSO","appId":"MOCK_APP_9","remark":"接入参数待业务系统确认","status":"UNCONFIGURED","appName":"单点登录系统","enabled":"DISABLED","version":1,"createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","valueMapping":{},"lastCheckedAt":"2026-09-17T23:00:00.000Z","connectionStatus":"UNCONFIGURED"},{"id":"MOCK_INT_MOCK_APP_9TODO","kind":"TODO","mode":"PUSH","name":"单点登录系统 · TODO","appId":"MOCK_APP_9","remark":"接入参数待业务系统确认","status":"UNCONFIGURED","appName":"单点登录系统","enabled":"DISABLED","version":1,"createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","valueMapping":{},"lastCheckedAt":"2026-09-17T22:00:00.000Z","connectionStatus":"UNCONFIGURED"},{"id":"MOCK_INT_MOCK_APP_9MESSAGE","kind":"MESSAGE","mode":"PUSH","name":"单点登录系统 · MESSAGE","appId":"MOCK_APP_9","remark":"接入参数待业务系统确认","status":"UNCONFIGURED","appName":"单点登录系统","enabled":"DISABLED","version":1,"createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","valueMapping":{},"lastCheckedAt":"2026-09-17T21:00:00.000Z","connectionStatus":"UNCONFIGURED"},{"id":"MOCK_INT_MOCK_APP_10SSO","kind":"SSO","mode":"SSO","name":"福建省血液信息联网平台 · SSO","appId":"MOCK_APP_10","remark":"接入参数待业务系统确认","status":"UNCONFIGURED","appName":"福建省血液信息联网平台","enabled":"DISABLED","version":1,"createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","valueMapping":{},"lastCheckedAt":"2026-09-17T23:00:00.000Z","connectionStatus":"UNCONFIGURED"},{"id":"MOCK_INT_MOCK_APP_10TODO","kind":"TODO","mode":"PUSH","name":"福建省血液信息联网平台 · TODO","appId":"MOCK_APP_10","remark":"接入参数待业务系统确认","status":"UNCONFIGURED","appName":"福建省血液信息联网平台","enabled":"DISABLED","version":1,"createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","valueMapping":{},"lastCheckedAt":"2026-09-17T22:00:00.000Z","connectionStatus":"UNCONFIGURED"},{"id":"MOCK_INT_MOCK_APP_10MESSAGE","kind":"MESSAGE","mode":"PUSH","name":"福建省血液信息联网平台 · MESSAGE","appId":"MOCK_APP_10","remark":"接入参数待业务系统确认","status":"DISABLED","appName":"福建省血液信息联网平台","enabled":"DISABLED","version":1,"createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","valueMapping":{},"lastCheckedAt":"2026-09-17T21:00:00.000Z","connectionStatus":"UNCONFIGURED"},{"id":"MOCK_INT_MOCK_APP_11SSO","kind":"SSO","mode":"SSO","name":"福建省免疫规划管理信息系统 · SSO","appId":"MOCK_APP_11","remark":"接入参数待业务系统确认","status":"UNCONFIGURED","appName":"���建省免疫规划管理信息系统","enabled":"DISABLED","version":1,"createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","valueMapping":{},"lastCheckedAt":"2026-09-17T23:00:00.000Z","connectionStatus":"UNCONFIGURED"},{"id":"MOCK_INT_MOCK_APP_11TODO","kind":"TODO","mode":"PUSH","name":"福建省免疫规划管理信息系统 · TODO","appId":"MOCK_APP_11","remark":"接入参数待业务系统确认","status":"DISABLED","appName":"福建省免疫规���管理信息系统","enabled":"DISABLED","version":1,"createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","valueMapping":{},"lastCheckedAt":"2026-09-17T22:00:00.000Z","connectionStatus":"UNCONFIGURED"},{"id":"MOCK_INT_MOCK_APP_11MESSAGE","kind":"MESSAGE","mode":"PUSH","name":"福建省免疫规划管理信息系统 · MESSAGE","appId":"MOCK_APP_11","remark":"接入参数待业务系统确认","status":"UNCONFIGURED","appName":"福建省免疫规划管理信息系统","enabled":"DISABLED","version":1,"createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","valueMapping":{},"lastCheckedAt":"2026-09-17T21:00:00.000Z","connectionStatus":"UNCONFIGURED"},{"id":"MOCK_INT_MOCK_APP_12SSO","kind":"SSO","mode":"SSO","name":"中医馆健康信息系统 · SSO","appId":"MOCK_APP_12","remark":"接入参数待业务系统确认","status":"DISABLED","appName":"中医馆健康信息系统","enabled":"DISABLED","version":1,"createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","valueMapping":{},"lastCheckedAt":"2026-09-17T23:00:00.000Z","connectionStatus":"UNCONFIGURED"},{"id":"MOCK_INT_MOCK_APP_12TODO","kind":"TODO","mode":"PUSH","name":"中医馆健康信息�����统 · TODO","appId":"MOCK_APP_12","remark":"接入参数待业务系统确认","status":"UNCONFIGURED","appName":"中医馆健康信息系统","enabled":"DISABLED","version":1,"createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","valueMapping":{},"lastCheckedAt":"2026-09-17T22:00:00.000Z","connectionStatus":"UNCONFIGURED"},{"id":"MOCK_INT_MOCK_APP_12MESSAGE","kind":"MESSAGE","mode":"PUSH","name":"中医馆健康信息系统 · MESSAGE","appId":"MOCK_APP_12","remark":"接入参数待业��系统确认","status":"UNCONFIGURED","appName":"中医馆健康信息系统","enabled":"DISABLED","version":1,"createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","valueMapping":{},"lastCheckedAt":"2026-09-17T21:00:00.000Z","connectionStatus":"UNCONFIGURED"},{"id":"MOCK_INT_MOCK_APP_13SSO","kind":"SSO","mode":"SSO","name":"福建省肝炎筛查与规范化治疗管理系统 · SSO","appId":"MOCK_APP_13","remark":"接入参数待业务系统确认","status":"UNCONFIGURED","appName":"福建省肝炎筛查与规范化治疗管理系统","enabled":"DISABLED","version":1,"createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","valueMapping":{},"lastCheckedAt":"2026-09-17T23:00:00.000Z","connectionStatus":"UNCONFIGURED"},{"id":"MOCK_INT_MOCK_APP_13TODO","kind":"TODO","mode":"PUSH","name":"福建省肝炎筛查与规范化治疗管理系统 · TODO","appId":"MOCK_APP_13","remark":"接入参数待业务系统确认","status":"UNCONFIGURED","appName":"福建省肝炎筛查与规范化治疗管理系统","enabled":"DISABLED","version":1,"createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","valueMapping":{},"lastCheckedAt":"2026-09-17T22:00:00.000Z","connectionStatus":"UNCONFIGURED"},{"id":"MOCK_INT_MOCK_APP_13MESSAGE","kind":"MESSAGE","mode":"PUSH","name":"福建省肝炎筛查与规范�������治疗管理系统 · MESSAGE","appId":"MOCK_APP_13","remark":"接入参数待业务系统确认","status":"UNCONFIGURED","appName":"福建省肝炎筛查与规范化治疗管理系统","enabled":"DISABLED","version":1,"createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","valueMapping":{},"lastCheckedAt":"2026-09-17T21:00:00.000Z","connectionStatus":"UNCONFIGURED"},{"id":"MOCK_INT_MOCK_APP_14SSO","kind":"SSO","mode":"SSO","name":"福建省全员人口计划生育服务与管理系统 · SSO","appId":"MOCK_APP_14","remark":"接入参数待业务系统确认","status":"UNCONFIGURED","appName":"福建省全员人口计划生育服务与管理系统","enabled":"DISABLED","version":1,"createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","valueMapping":{},"lastCheckedAt":"2026-09-17T23:00:00.000Z","connectionStatus":"UNCONFIGURED"},{"id":"MOCK_INT_MOCK_APP_14TODO","kind":"TODO","mode":"PUSH","name":"福建省全员人口计划生育服务与管理系统 · TODO","appId":"MOCK_APP_14","remark":"接入参数待业务系统确认","status":"UNCONFIGURED","appName":"福建省全����人��计划生育服务与管理系统","enabled":"DISABLED","version":1,"createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","valueMapping":{},"lastCheckedAt":"2026-09-17T22:00:00.000Z","connectionStatus":"UNCONFIGURED"},{"id":"MOCK_INT_MOCK_APP_14MESSAGE","kind":"MESSAGE","mode":"PUSH","name":"福建省全员人口计划生育服务与管理系统 · MESSAGE","appId":"MOCK_APP_14","remark":"接入参数待业务系统确认","status":"DISABLED","appName":"福建省全员人口计划生育服务与管理系统","enabled":"DISABLED","version":1,"createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","valueMapping":{},"lastCheckedAt":"2026-09-17T21:00:00.000Z","connectionStatus":"UNCONFIGURED"},{"id":"MOCK_INT_MOCK_APP_15SSO","kind":"SSO","mode":"SSO","name":"福建省流动人口服务与管理信息系统 · SSO","appId":"MOCK_APP_15","remark":"接入参数待业务系统确认","status":"UNCONFIGURED","appName":"福建省流动人口服务与管理信息系统","enabled":"DISABLED","version":1,"createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","valueMapping":{},"lastCheckedAt":"2026-09-17T23:00:00.000Z","connectionStatus":"UNCONFIGURED"},{"id":"MOCK_INT_MOCK_APP_15TODO","kind":"TODO","mode":"PUSH","name":"福建省流动人口服务与管理信息系统 · TODO","appId":"MOCK_APP_15","remark":"接入参数待业务系统确认","status":"DISABLED","appName":"福建省流动人口服务与管理信息系统","enabled":"DISABLED","version":1,"createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","valueMapping":{},"lastCheckedAt":"2026-09-17T22:00:00.000Z","connectionStatus":"UNCONFIGURED"},{"id":"MOCK_INT_MOCK_APP_15MESSAGE","kind":"MESSAGE","mode":"PUSH","name":"福建省流动人口服务与管理信息系统 · MESSAGE","appId":"MOCK_APP_15","remark":"接入参数待业务系统确认","status":"UNCONFIGURED","appName":"福建省流动人口服务与管理信息系统","enabled":"DISABLED","version":1,"createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","valueMapping":{},"lastCheckedAt":"2026-09-17T21:00:00.000Z","connectionStatus":"UNCONFIGURED"},{"id":"MOCK_INT_MOCK_APP_16SSO","kind":"SSO","mode":"SSO","name":"福建省人口计生综合服务信息平台 · SSO","appId":"MOCK_APP_16","remark":"接入参数待业务系统确认","status":"DISABLED","appName":"福建省人口计生综合服务信息平台","enabled":"DISABLED","version":1,"createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","valueMapping":{},"lastCheckedAt":"2026-09-17T23:00:00.000Z","connectionStatus":"UNCONFIGURED"},{"id":"MOCK_INT_MOCK_APP_16TODO","kind":"TODO","mode":"PUSH","name":"福建省人口计生综合服务信息平台 · TODO","appId":"MOCK_APP_16","remark":"接入参数待业务系统确认","status":"UNCONFIGURED","appName":"福建省人口计生综合服务信息平台","enabled":"DISABLED","version":1,"createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","valueMapping":{},"lastCheckedAt":"2026-09-17T22:00:00.000Z","connectionStatus":"UNCONFIGURED"},{"id":"MOCK_INT_MOCK_APP_16MESSAGE","kind":"MESSAGE","mode":"PUSH","name":"福建省人口计生综合服务信息平台 · MESSAGE","appId":"MOCK_APP_16","remark":"接入参数待业务系统确认","status":"UNCONFIGURED","appName":"福建省人口计生综合服务信息平台","enabled":"DISABLED","version":1,"createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","valueMapping":{},"lastCheckedAt":"2026-09-17T21:00:00.000Z","connectionStatus":"UNCONFIGURED"},{"id":"MOCK_INT_MOCK_APP_17SSO","kind":"SSO","mode":"SSO","name":"全员人口数据库药具发放服务管理 · SSO","appId":"MOCK_APP_17","remark":"接入参数待业务系统确认","status":"UNCONFIGURED","appName":"全员人口数据库药具发放服务管理","enabled":"DISABLED","version":1,"createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","valueMapping":{},"lastCheckedAt":"2026-09-17T23:00:00.000Z","connectionStatus":"UNCONFIGURED"},{"id":"MOCK_INT_MOCK_APP_17TODO","kind":"TODO","mode":"PUSH","name":"全员人口数据库药具发放服务管理 · TODO","appId":"MOCK_APP_17","remark":"接入参数待业务系统确认","status":"UNCONFIGURED","appName":"全员人口数据库药具发放服务管理","enabled":"DISABLED","version":1,"createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","valueMapping":{},"lastCheckedAt":"2026-09-17T22:00:00.000Z","connectionStatus":"UNCONFIGURED"},{"id":"MOCK_INT_MOCK_APP_17MESSAGE","kind":"MESSAGE","mode":"PUSH","name":"全员人口数据库药具发放服务管理 · MESSAGE","appId":"MOCK_APP_17","remark":"接入参数待业务系统确认","status":"UNCONFIGURED","appName":"全员人口数据库药具发放服务管理","enabled":"DISABLED","version":1,"createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","valueMapping":{},"lastCheckedAt":"2026-09-17T21:00:00.000Z","connectionStatus":"UNCONFIGURED"},{"id":"MOCK_INT_MOCK_APP_18SSO","kind":"SSO","mode":"SSO","name":"福建省互联网医院监管平台 · SSO","appId":"MOCK_APP_18","remark":"接入参数待业务系统确认","status":"UNCONFIGURED","appName":"福建省互联网医院监管平台","enabled":"DISABLED","version":1,"createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","valueMapping":{},"lastCheckedAt":"2026-09-17T23:00:00.000Z","connectionStatus":"UNCONFIGURED"},{"id":"MOCK_INT_MOCK_APP_18TODO","kind":"TODO","mode":"PUSH","name":"福建省互联网医院监管平台 · TODO","appId":"MOCK_APP_18","remark":"接入参数待业务系统确认","status":"UNCONFIGURED","appName":"福建省互联网医院监管平台","enabled":"DISABLED","version":1,"createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","valueMapping":{},"lastCheckedAt":"2026-09-17T22:00:00.000Z","connectionStatus":"UNCONFIGURED"},{"id":"MOCK_INT_MOCK_APP_18MESSAGE","kind":"MESSAGE","mode":"PUSH","name":"福建省互联网医院监管平台 · MESSAGE","appId":"MOCK_APP_18","remark":"接入参数待业务系统确认","status":"DISABLED","appName":"福建省互联网医院监管平台","enabled":"DISABLED","version":1,"createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","valueMapping":{},"lastCheckedAt":"2026-09-17T21:00:00.000Z","connectionStatus":"UNCONFIGURED"},{"id":"MOCK_INT_MOCK_APP_19SSO","kind":"SSO","mode":"SSO","name":"省医改效果监测管理系统 · SSO","appId":"MOCK_APP_19","remark":"接入参数待业务系统确认","status":"UNCONFIGURED","appName":"省医改效果监测管理系统","enabled":"DISABLED","version":1,"createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","valueMapping":{},"lastCheckedAt":"2026-09-17T23:00:00.000Z","connectionStatus":"UNCONFIGURED"},{"id":"MOCK_INT_MOCK_APP_19TODO","kind":"TODO","mode":"PUSH","name":"省医改效果监测管理系统 · TODO","appId":"MOCK_APP_19","remark":"接入参数待业务系统确认","status":"DISABLED","appName":"省医改效果监测管理系统","enabled":"DISABLED","version":1,"createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","valueMapping":{},"lastCheckedAt":"2026-09-17T22:00:00.000Z","connectionStatus":"UNCONFIGURED"},{"id":"MOCK_INT_MOCK_APP_19MESSAGE","kind":"MESSAGE","mode":"PUSH","name":"省医改效果监测管理系统 · MESSAGE","appId":"MOCK_APP_19","remark":"接入参数待业务系统确认","status":"UNCONFIGURED","appName":"省医改效果监测管理系统","enabled":"DISABLED","version":1,"createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","valueMapping":{},"lastCheckedAt":"2026-09-17T21:00:00.000Z","connectionStatus":"UNCONFIGURED"},{"id":"MOCK_INT_MOCK_APP_20SSO","kind":"SSO","mode":"SSO","name":"省属公立医院运营监管系统 · SSO","appId":"MOCK_APP_20","remark":"接入参数待业务系统确认","status":"DISABLED","appName":"省属公立医院运营监管系统","enabled":"DISABLED","version":1,"createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","valueMapping":{},"lastCheckedAt":"2026-09-17T23:00:00.000Z","connectionStatus":"UNCONFIGURED"},{"id":"MOCK_INT_MOCK_APP_20TODO","kind":"TODO","mode":"PUSH","name":"省属公立医院运营监管系统 · TODO","appId":"MOCK_APP_20","remark":"接入参数待业务系统确认","status":"UNCONFIGURED","appName":"省属公立医院运营监管系统","enabled":"DISABLED","version":1,"createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","valueMapping":{},"lastCheckedAt":"2026-09-17T22:00:00.000Z","connectionStatus":"UNCONFIGURED"},{"id":"MOCK_INT_MOCK_APP_20MESSAGE","kind":"MESSAGE","mode":"PUSH","name":"省属公立医院运营监管系统 · MESSAGE","appId":"MOCK_APP_20","remark":"接入参数待业务系统确认","status":"UNCONFIGURED","appName":"省属公立医院运营监管系统","enabled":"DISABLED","version":1,"createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","valueMapping":{},"lastCheckedAt":"2026-09-17T21:00:00.000Z","connectionStatus":"UNCONFIGURED"},{"id":"MOCK_INT_MOCK_APP_21SSO","kind":"SSO","mode":"SSO","name":"福建省公立医院绩效考核系统 · SSO","appId":"MOCK_APP_21","remark":"接入参数待业务系统确认","status":"UNCONFIGURED","appName":"福建省公立医院绩效考核系统","enabled":"DISABLED","version":1,"createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","valueMapping":{},"lastCheckedAt":"2026-09-17T23:00:00.000Z","connectionStatus":"UNCONFIGURED"},{"id":"MOCK_INT_MOCK_APP_21TODO","kind":"TODO","mode":"PUSH","name":"福建省公立医院绩效考核系统 · TODO","appId":"MOCK_APP_21","remark":"接入参数待业务系统确认","status":"UNCONFIGURED","appName":"福建省公立医院绩效考核系统","enabled":"DISABLED","version":1,"createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","valueMapping":{},"lastCheckedAt":"2026-09-17T22:00:00.000Z","connectionStatus":"UNCONFIGURED"},{"id":"MOCK_INT_MOCK_APP_21MESSAGE","kind":"MESSAGE","mode":"PUSH","name":"福建省公立医院绩效考核系统 · MESSAGE","appId":"MOCK_APP_21","remark":"接入参数待业务系统确认","status":"UNCONFIGURED","appName":"福建省公立医院绩效考核系统","enabled":"DISABLED","version":1,"createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","valueMapping":{},"lastCheckedAt":"2026-09-17T21:00:00.000Z","connectionStatus":"UNCONFIGURED"},{"id":"MOCK_INT_MOCK_APP_22SSO","kind":"SSO","mode":"SSO","name":"财务管理系统 · SSO","appId":"MOCK_APP_22","remark":"接入参数待业务系统确认","status":"UNCONFIGURED","appName":"财务管理系统","enabled":"DISABLED","version":1,"createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","valueMapping":{},"lastCheckedAt":"2026-09-17T23:00:00.000Z","connectionStatus":"UNCONFIGURED"},{"id":"MOCK_INT_MOCK_APP_22TODO","kind":"TODO","mode":"PUSH","name":"财务管理系统 · TODO","appId":"MOCK_APP_22","remark":"接入参数待业务系统确认","status":"UNCONFIGURED","appName":"财务管理系统","enabled":"DISABLED","version":1,"createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","valueMapping":{},"lastCheckedAt":"2026-09-17T22:00:00.000Z","connectionStatus":"UNCONFIGURED"},{"id":"MOCK_INT_MOCK_APP_22MESSAGE","kind":"MESSAGE","mode":"PUSH","name":"财务管理系统 · MESSAGE","appId":"MOCK_APP_22","remark":"接入参数待业务系统确认","status":"DISABLED","appName":"财务管理系统","enabled":"DISABLED","version":1,"createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","valueMapping":{},"lastCheckedAt":"2026-09-17T21:00:00.000Z","connectionStatus":"UNCONFIGURED"},{"id":"MOCK_INT_MOCK_APP_23SSO","kind":"SSO","mode":"SSO","name":"医疗技术临床应用管理信息系统 · SSO","appId":"MOCK_APP_23","remark":"接入参数待业务系统确认","status":"UNCONFIGURED","appName":"医疗技术临床应用管理信息系统","enabled":"DISABLED","version":1,"createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","valueMapping":{},"lastCheckedAt":"2026-09-17T23:00:00.000Z","connectionStatus":"UNCONFIGURED"},{"id":"MOCK_INT_MOCK_APP_23TODO","kind":"TODO","mode":"PUSH","name":"医疗技术临床应用管理信息系统 · TODO","appId":"MOCK_APP_23","remark":"接入参数待业务系统确认","status":"DISABLED","appName":"医疗技术临床应用管理信息系统","enabled":"DISABLED","version":1,"createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","valueMapping":{},"lastCheckedAt":"2026-09-17T22:00:00.000Z","connectionStatus":"UNCONFIGURED"},{"id":"MOCK_INT_MOCK_APP_23MESSAGE","kind":"MESSAGE","mode":"PUSH","name":"医疗技术临床应用管理信息系统 · MESSAGE","appId":"MOCK_APP_23","remark":"接入参数待业务系统确认","status":"UNCONFIGURED","appName":"医疗技术临床应用管理信息系统","enabled":"DISABLED","version":1,"createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","valueMapping":{},"lastCheckedAt":"2026-09-17T21:00:00.000Z","connectionStatus":"UNCONFIGURED"},{"id":"MOCK_INT_MOCK_APP_24SSO","kind":"SSO","mode":"SSO","name":"住院医师专科医师培训及一体化系统 · SSO","appId":"MOCK_APP_24","remark":"接入参数待业务系统确认","status":"DISABLED","appName":"住院医师专科医师培训及一体化系统","enabled":"DISABLED","version":1,"createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","valueMapping":{},"lastCheckedAt":"2026-09-17T23:00:00.000Z","connectionStatus":"UNCONFIGURED"},{"id":"MOCK_INT_MOCK_APP_24TODO","kind":"TODO","mode":"PUSH","name":"住院医师专科医师培训及一体化系统 · TODO","appId":"MOCK_APP_24","remark":"接入参数待业务系统确认","status":"UNCONFIGURED","appName":"住院医师专科医师培训及一体化系统","enabled":"DISABLED","version":1,"createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","valueMapping":{},"lastCheckedAt":"2026-09-17T22:00:00.000Z","connectionStatus":"UNCONFIGURED"},{"id":"MOCK_INT_MOCK_APP_24MESSAGE","kind":"MESSAGE","mode":"PUSH","name":"住院医师专科医师培训及一体化系统 · MESSAGE","appId":"MOCK_APP_24","remark":"接入参数待业务系统确认","status":"UNCONFIGURED","appName":"住院医师专科医师培训及一体化系统","enabled":"DISABLED","version":1,"createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","valueMapping":{},"lastCheckedAt":"2026-09-17T21:00:00.000Z","connectionStatus":"UNCONFIGURED"},{"id":"MOCK_INT_MOCK_APP_25SSO","kind":"SSO","mode":"SSO","name":"福建省中医医师规范化培训管理平台 · SSO","appId":"MOCK_APP_25","remark":"接入参数待业务系统确认","status":"UNCONFIGURED","appName":"福建省中医医师规范化培训管理平台","enabled":"DISABLED","version":1,"createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","valueMapping":{},"lastCheckedAt":"2026-09-17T23:00:00.000Z","connectionStatus":"UNCONFIGURED"},{"id":"MOCK_INT_MOCK_APP_25TODO","kind":"TODO","mode":"PUSH","name":"福建省中医医师规范化培训管理平台 · TODO","appId":"MOCK_APP_25","remark":"接入参数待业务系统确认","status":"UNCONFIGURED","appName":"福建省中医医师规范化培训管理平台","enabled":"DISABLED","version":1,"createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","valueMapping":{},"lastCheckedAt":"2026-09-17T22:00:00.000Z","connectionStatus":"UNCONFIGURED"},{"id":"MOCK_INT_MOCK_APP_25MESSAGE","kind":"MESSAGE","mode":"PUSH","name":"福建省中医医师规范化培训管理平台 · MESSAGE","appId":"MOCK_APP_25","remark":"接入参数待业务系统确认","status":"UNCONFIGURED","appName":"福建省中医医师规范化培训管理平台","enabled":"DISABLED","version":1,"createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","valueMapping":{},"lastCheckedAt":"2026-09-17T21:00:00.000Z","connectionStatus":"UNCONFIGURED"},{"id":"MOCK_INT_MOCK_APP_26SSO","kind":"SSO","mode":"SSO","name":"福建省中医医术确有专长人员医师资格考核报名系统 · SSO","appId":"MOCK_APP_26","remark":"接入参数待业务系统确认","status":"UNCONFIGURED","appName":"福建省中医医术确有专长人员医师资格考核报名系统","enabled":"DISABLED","version":1,"createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","valueMapping":{},"lastCheckedAt":"2026-09-17T23:00:00.000Z","connectionStatus":"UNCONFIGURED"},{"id":"MOCK_INT_MOCK_APP_26TODO","kind":"TODO","mode":"PUSH","name":"福建省中医医术确有专长人员医师资格考核报名系统 · TODO","appId":"MOCK_APP_26","remark":"接入参数待业务系统确认","status":"UNCONFIGURED","appName":"福建省中医医术确有专长人员医师资格考核报名系统","enabled":"DISABLED","version":1,"createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","valueMapping":{},"lastCheckedAt":"2026-09-17T22:00:00.000Z","connectionStatus":"UNCONFIGURED"},{"id":"MOCK_INT_MOCK_APP_26MESSAGE","kind":"MESSAGE","mode":"PUSH","name":"福建省中医医术确有专长人员医师资格考核报名系统 · MESSAGE","appId":"MOCK_APP_26","remark":"接入参数待业务系统确认","status":"DISABLED","appName":"福建省中医医术确有专长人员医师资格考核报名系统","enabled":"DISABLED","version":1,"createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","valueMapping":{},"lastCheckedAt":"2026-09-17T21:00:00.000Z","connectionStatus":"UNCONFIGURED"},{"id":"MOCK_INT_MOCK_APP_27SSO","kind":"SSO","mode":"SSO","name":"福建省卫生健康科技计划项目管理信息系统 · SSO","appId":"MOCK_APP_27","remark":"接入参数待业务系统确认","status":"UNCONFIGURED","appName":"福建省卫生健康科技计划项目管理信息系统","enabled":"DISABLED","version":1,"createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","valueMapping":{},"lastCheckedAt":"2026-09-17T23:00:00.000Z","connectionStatus":"UNCONFIGURED"},{"id":"MOCK_INT_MOCK_APP_27TODO","kind":"TODO","mode":"PUSH","name":"福建省卫生健康科技计划项目管理信息系统 · TODO","appId":"MOCK_APP_27","remark":"接入参数待业务系统确认","status":"DISABLED","appName":"福建省卫生健康科技计划项目管理信息系统","enabled":"DISABLED","version":1,"createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","valueMapping":{},"lastCheckedAt":"2026-09-17T22:00:00.000Z","connectionStatus":"UNCONFIGURED"},{"id":"MOCK_INT_MOCK_APP_27MESSAGE","kind":"MESSAGE","mode":"PUSH","name":"福建省卫生健康科技计划项目管理信息系统 · MESSAGE","appId":"MOCK_APP_27","remark":"接入参数待业务系统确认","status":"UNCONFIGURED","appName":"福建省卫生健康科技计划项目管理信息系统","enabled":"DISABLED","version":1,"createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","valueMapping":{},"lastCheckedAt":"2026-09-17T21:00:00.000Z","connectionStatus":"UNCONFIGURED"},{"id":"MOCK_INT_MOCK_APP_28SSO","kind":"SSO","mode":"SSO","name":"福建省卫生专业技术资格考试报名系统 · SSO","appId":"MOCK_APP_28","remark":"接入参数待业务系统确认","status":"DISABLED","appName":"福建省卫生专业技术资格考试报名系统","enabled":"DISABLED","version":1,"createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","valueMapping":{},"lastCheckedAt":"2026-09-17T23:00:00.000Z","connectionStatus":"UNCONFIGURED"},{"id":"MOCK_INT_MOCK_APP_28TODO","kind":"TODO","mode":"PUSH","name":"福建省卫生专业技术资格考试报名系统 · TODO","appId":"MOCK_APP_28","remark":"接入参数待业务系统确认","status":"UNCONFIGURED","appName":"福建省卫生专业技术资格考试报名系统","enabled":"DISABLED","version":1,"createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","valueMapping":{},"lastCheckedAt":"2026-09-17T22:00:00.000Z","connectionStatus":"UNCONFIGURED"},{"id":"MOCK_INT_MOCK_APP_28MESSAGE","kind":"MESSAGE","mode":"PUSH","name":"福建省卫生专业技术资格考试报名系统 · MESSAGE","appId":"MOCK_APP_28","remark":"接入参数待业务系统确认","status":"UNCONFIGURED","appName":"福建省卫生专业技术资格考试报名系统","enabled":"DISABLED","version":1,"createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","valueMapping":{},"lastCheckedAt":"2026-09-17T21:00:00.000Z","connectionStatus":"UNCONFIGURED"},{"id":"MOCK_INT_MOCK_APP_29SSO","kind":"SSO","mode":"SSO","name":"国家卫生健康信息统计直报系统 · SSO","appId":"MOCK_APP_29","remark":"接入参数待业务系统确认","status":"UNCONFIGURED","appName":"国家卫生健康信息统计直报系统","enabled":"DISABLED","version":1,"createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","valueMapping":{},"lastCheckedAt":"2026-09-17T23:00:00.000Z","connectionStatus":"UNCONFIGURED"},{"id":"MOCK_INT_MOCK_APP_29TODO","kind":"TODO","mode":"PUSH","name":"国家卫生健康信息统计直报系统 · TODO","appId":"MOCK_APP_29","remark":"接入参数待业务系统确认","status":"UNCONFIGURED","appName":"国家卫生健康信息统计直报系统","enabled":"DISABLED","version":1,"createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","valueMapping":{},"lastCheckedAt":"2026-09-17T22:00:00.000Z","connectionStatus":"UNCONFIGURED"},{"id":"MOCK_INT_MOCK_APP_29MESSAGE","kind":"MESSAGE","mode":"PUSH","name":"国家卫生健康信息统计直报系统 · MESSAGE","appId":"MOCK_APP_29","remark":"接入参数待业务系统确认","status":"UNCONFIGURED","appName":"国家卫生健康信息统计直报系统","enabled":"DISABLED","version":1,"createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","valueMapping":{},"lastCheckedAt":"2026-09-17T21:00:00.000Z","connectionStatus":"UNCONFIGURED"},{"id":"MOCK_INT_MOCK_APP_30SSO","kind":"SSO","mode":"SSO","name":"福建省集中消毒餐具追溯系统 · SSO","appId":"MOCK_APP_30","remark":"接入参数待业务系���确认","status":"UNCONFIGURED","appName":"福建省集中消毒餐具追溯系统","enabled":"DISABLED","version":1,"createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","valueMapping":{},"lastCheckedAt":"2026-09-17T23:00:00.000Z","connectionStatus":"UNCONFIGURED"},{"id":"MOCK_INT_MOCK_APP_30TODO","kind":"TODO","mode":"PUSH","name":"福建省集中消毒餐具追溯系统 · TODO","appId":"MOCK_APP_30","remark":"接入参数待业务系统确认","status":"UNCONFIGURED","appName":"福建省集中消毒餐具追溯系统","enabled":"DISABLED","version":1,"createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","valueMapping":{},"lastCheckedAt":"2026-09-17T22:00:00.000Z","connectionStatus":"UNCONFIGURED"},{"id":"MOCK_INT_MOCK_APP_30MESSAGE","kind":"MESSAGE","mode":"PUSH","name":"福建省集中消毒餐具追溯系统 · MESSAGE","appId":"MOCK_APP_30","remark":"���入���数待业务系统确认","status":"DISABLED","appName":"福建省集中消毒餐具追溯系统","enabled":"DISABLED","version":1,"createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","valueMapping":{},"lastCheckedAt":"2026-09-17T21:00:00.000Z","connectionStatus":"UNCONFIGURED"},{"id":"MOCK_INT_MOCK_APP_31SSO","kind":"SSO","mode":"SSO","name":"福建省职业病防治综合管理系统 · SSO","appId":"MOCK_APP_31","remark":"接入参数待业务系统确认","status":"UNCONFIGURED","appName":"福建省职业病防治综合管理系统","enabled":"DISABLED","version":1,"createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","valueMapping":{},"lastCheckedAt":"2026-09-17T23:00:00.000Z","connectionStatus":"UNCONFIGURED"},{"id":"MOCK_INT_MOCK_APP_31TODO","kind":"TODO","mode":"PUSH","name":"福建省职业病防治综合管理系统 · TODO","appId":"MOCK_APP_31","remark":"接入参数待业务系统确认","status":"DISABLED","appName":"福建省职业病防治综合管理系统","enabled":"DISABLED","version":1,"createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","valueMapping":{},"lastCheckedAt":"2026-09-17T22:00:00.000Z","connectionStatus":"UNCONFIGURED"},{"id":"MOCK_INT_MOCK_APP_31MESSAGE","kind":"MESSAGE","mode":"PUSH","name":"福建省职业病防治综合管理系统 · MESSAGE","appId":"MOCK_APP_31","remark":"接入参数待业务系统确认","status":"UNCONFIGURED","appName":"福建省职业病防治综合管理系统","enabled":"DISABLED","version":1,"createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","valueMapping":{},"lastCheckedAt":"2026-09-17T21:00:00.000Z","connectionStatus":"UNCONFIGURED"},{"id":"MOCK_INT_MOCK_APP_32SSO","kind":"SSO","mode":"SSO","name":"福建省保健对象医疗管理信息系统 · SSO","appId":"MOCK_APP_32","remark":"接入参数待业务系统确认","status":"DISABLED","appName":"福建省保健对象医疗管理信息系统","enabled":"DISABLED","version":1,"createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","valueMapping":{},"lastCheckedAt":"2026-09-17T23:00:00.000Z","connectionStatus":"UNCONFIGURED"},{"id":"MOCK_INT_MOCK_APP_32TODO","kind":"TODO","mode":"PUSH","name":"福建省保健对象医疗管理信息系统 · TODO","appId":"MOCK_APP_32","remark":"接入参数待业务系统确认","status":"UNCONFIGURED","appName":"福建省保健对象医疗管理信息系统","enabled":"DISABLED","version":1,"createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","valueMapping":{},"lastCheckedAt":"2026-09-17T22:00:00.000Z","connectionStatus":"UNCONFIGURED"},{"id":"MOCK_INT_MOCK_APP_32MESSAGE","kind":"MESSAGE","mode":"PUSH","name":"福建省保健对象医疗管理信息系统 · MESSAGE","appId":"MOCK_APP_32","remark":"接入参数待业务系统确认","status":"UNCONFIGURED","appName":"福建省保健对象医疗管理信息系统","enabled":"DISABLED","version":1,"createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","valueMapping":{},"lastCheckedAt":"2026-09-17T21:00:00.000Z","connectionStatus":"UNCONFIGURED"},{"id":"MOCK_INT_MOCK_APP_33SSO","kind":"SSO","mode":"SSO","name":"福建省职业病与化学中毒预防控制中心门户网站 · SSO","appId":"MOCK_APP_33","remark":"接入参数待业务系统确认","status":"UNCONFIGURED","appName":"福建省职业病与化学中毒预防控制中心门户网站","enabled":"DISABLED","version":1,"createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","valueMapping":{},"lastCheckedAt":"2026-09-17T23:00:00.000Z","connectionStatus":"UNCONFIGURED"},{"id":"MOCK_INT_MOCK_APP_33TODO","kind":"TODO","mode":"PUSH","name":"福建省职业病与化学中毒预防控制中心门户网站 · TODO","appId":"MOCK_APP_33","remark":"接入参数待业务系统确认","status":"UNCONFIGURED","appName":"福建省职业病与化学中毒预防控制中心门户网站","enabled":"DISABLED","version":1,"createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","valueMapping":{},"lastCheckedAt":"2026-09-17T22:00:00.000Z","connectionStatus":"UNCONFIGURED"},{"id":"MOCK_INT_MOCK_APP_33MESSAGE","kind":"MESSAGE","mode":"PUSH","name":"福建省职业病与化学中毒预防控制中心门户网站 · MESSAGE","appId":"MOCK_APP_33","remark":"接入参数待业务系统确认","status":"UNCONFIGURED","appName":"福建省�����业病与化学中毒预防控制中心门户网站","enabled":"DISABLED","version":1,"createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","valueMapping":{},"lastCheckedAt":"2026-09-17T21:00:00.000Z","connectionStatus":"UNCONFIGURED"},{"id":"MOCK_INT_MOCK_APP_34SSO","kind":"SSO","mode":"SSO","name":"福建省卫生监督电子执法全过程记录系统 · SSO","appId":"MOCK_APP_34","remark":"接入参数待业务系统确认","status":"UNCONFIGURED","appName":"福建省卫生���督���子执法全过程记录系统","enabled":"DISABLED","version":1,"createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","valueMapping":{},"lastCheckedAt":"2026-09-17T23:00:00.000Z","connectionStatus":"UNCONFIGURED"},{"id":"MOCK_INT_MOCK_APP_34TODO","kind":"TODO","mode":"PUSH","name":"福建省卫生监督电子执法全过程记录系统 · TODO","appId":"MOCK_APP_34","remark":"接入参数待业务系统确认","status":"UNCONFIGURED","appName":"福建省卫生监督电子执法全过程记录系统","enabled":"DISABLED","version":1,"createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","valueMapping":{},"lastCheckedAt":"2026-09-17T22:00:00.000Z","connectionStatus":"UNCONFIGURED"},{"id":"MOCK_INT_MOCK_APP_34MESSAGE","kind":"MESSAGE","mode":"PUSH","name":"福建省卫生监督电子执法全过程记录系统 · MESSAGE","appId":"MOCK_APP_34","remark":"接入参数待业务系统确认","status":"DISABLED","appName":"福建省卫生监督电子执法全过程记录系统","enabled":"DISABLED","version":1,"createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","valueMapping":{},"lastCheckedAt":"2026-09-17T21:00:00.000Z","connectionStatus":"UNCONFIGURED"},{"id":"MOCK_INT_MOCK_APP_35SSO","kind":"SSO","mode":"SSO","name":"福建省医疗卫生信用信息归集系统 · SSO","appId":"MOCK_APP_35","remark":"接入参数待业务系统确认","status":"UNCONFIGURED","appName":"福建省医疗卫生信用信息归集系统","enabled":"DISABLED","version":1,"createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","valueMapping":{},"lastCheckedAt":"2026-09-17T23:00:00.000Z","connectionStatus":"UNCONFIGURED"},{"id":"MOCK_INT_MOCK_APP_35TODO","kind":"TODO","mode":"PUSH","name":"福建省医疗卫生信用信息归集系统 · TODO","appId":"MOCK_APP_35","remark":"接入参数待业务系统确认","status":"DISABLED","appName":"福建���医疗卫生信用信息归集系统","enabled":"DISABLED","version":1,"createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","valueMapping":{},"lastCheckedAt":"2026-09-17T22:00:00.000Z","connectionStatus":"UNCONFIGURED"},{"id":"MOCK_INT_MOCK_APP_35MESSAGE","kind":"MESSAGE","mode":"PUSH","name":"福建省医疗卫生信用信息归集系统 · MESSAGE","appId":"MOCK_APP_35","remark":"接入参数待业务系统确认","status":"UNCONFIGURED","appName":"福建省医疗卫生信用信息归集系统","enabled":"DISABLED","version":1,"createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","valueMapping":{},"lastCheckedAt":"2026-09-17T21:00:00.000Z","connectionStatus":"UNCONFIGURED"},{"id":"MOCK_INT_MOCK_APP_36SSO","kind":"SSO","mode":"SSO","name":"福建�����医疗卫生不良执业记分系统 · SSO","appId":"MOCK_APP_36","remark":"接入参数待业务系统确认","status":"DISABLED","appName":"福建省医疗卫生不良执业记分系统","enabled":"DISABLED","version":1,"createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","valueMapping":{},"lastCheckedAt":"2026-09-17T23:00:00.000Z","connectionStatus":"UNCONFIGURED"},{"id":"MOCK_INT_MOCK_APP_36TODO","kind":"TODO","mode":"PUSH","name":"福建省医疗卫生不良执业记分系统 · TODO","appId":"MOCK_APP_36","remark":"接入参数待业务系统确认","status":"UNCONFIGURED","appName":"福建省医疗卫生不良执业记分系统","enabled":"DISABLED","version":1,"createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","valueMapping":{},"lastCheckedAt":"2026-09-17T22:00:00.000Z","connectionStatus":"UNCONFIGURED"},{"id":"MOCK_INT_MOCK_APP_36MESSAGE","kind":"MESSAGE","mode":"PUSH","name":"福建省医疗卫生不良执业记分系统 · MESSAGE","appId":"MOCK_APP_36","remark":"接入参数待业务系统确认","status":"UNCONFIGURED","appName":"福建省医疗卫生不良执业记分系统","enabled":"DISABLED","version":1,"createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","valueMapping":{},"lastCheckedAt":"2026-09-17T21:00:00.000Z","connectionStatus":"UNCONFIGURED"},{"id":"MOCK_INT_MOCK_APP_37SSO","kind":"SSO","mode":"SSO","name":"福建省诊所诊疗监督系统 · SSO","appId":"MOCK_APP_37","remark":"接入参数待业务系统确认","status":"UNCONFIGURED","appName":"福建省���所诊疗监督系统","enabled":"DISABLED","version":1,"createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","valueMapping":{},"lastCheckedAt":"2026-09-17T23:00:00.000Z","connectionStatus":"UNCONFIGURED"},{"id":"MOCK_INT_MOCK_APP_37TODO","kind":"TODO","mode":"PUSH","name":"福建省诊所诊疗监督系统 · TODO","appId":"MOCK_APP_37","remark":"接入参数待业务系统确认","status":"UNCONFIGURED","appName":"福建省诊所诊���监督系统","enabled":"DISABLED","version":1,"createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","valueMapping":{},"lastCheckedAt":"2026-09-17T22:00:00.000Z","connectionStatus":"UNCONFIGURED"},{"id":"MOCK_INT_MOCK_APP_37MESSAGE","kind":"MESSAGE","mode":"PUSH","name":"福建省诊所诊疗监督系统 · MESSAGE","appId":"MOCK_APP_37","remark":"接入参数待业务系统确认","status":"UNCONFIGURED","appName":"福建省诊所��疗监督系统","enabled":"DISABLED","version":1,"createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","valueMapping":{},"lastCheckedAt":"2026-09-17T21:00:00.000Z","connectionStatus":"UNCONFIGURED"},{"id":"MOCK_INT_MOCK_APP_38SSO","kind":"SSO","mode":"SSO","name":"福建省医疗服务资质检测系统 · SSO","appId":"MOCK_APP_38","remark":"接入参数待业务系统确认","status":"UNCONFIGURED","appName":"福建省医疗服务资质检测系统","enabled":"DISABLED","version":1,"createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","valueMapping":{},"lastCheckedAt":"2026-09-17T23:00:00.000Z","connectionStatus":"UNCONFIGURED"},{"id":"MOCK_INT_MOCK_APP_38TODO","kind":"TODO","mode":"PUSH","name":"福建省医疗服务资质检测系统 · TODO","appId":"MOCK_APP_38","remark":"接入参数待业务系统确认","status":"UNCONFIGURED","appName":"福建省医疗服务资质检测系统","enabled":"DISABLED","version":1,"createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","valueMapping":{},"lastCheckedAt":"2026-09-17T22:00:00.000Z","connectionStatus":"UNCONFIGURED"},{"id":"MOCK_INT_MOCK_APP_38MESSAGE","kind":"MESSAGE","mode":"PUSH","name":"福建省医疗服务资质检测系统 · MESSAGE","appId":"MOCK_APP_38","remark":"接入参数待业务系统确认","status":"DISABLED","appName":"福建省医疗服务资质检测系统","enabled":"DISABLED","version":1,"createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","valueMapping":{},"lastCheckedAt":"2026-09-17T21:00:00.000Z","connectionStatus":"UNCONFIGURED"},{"id":"MOCK_INT_MOCK_APP_39SSO","kind":"SSO","mode":"SSO","name":"福建省食源性疾病省级平台系统 · SSO","appId":"MOCK_APP_39","remark":"接入参数待业务系统确认","status":"UNCONFIGURED","appName":"福建省食源性疾病省级平台系统","enabled":"DISABLED","version":1,"createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","valueMapping":{},"lastCheckedAt":"2026-09-17T23:00:00.000Z","connectionStatus":"UNCONFIGURED"},{"id":"MOCK_INT_MOCK_APP_39TODO","kind":"TODO","mode":"PUSH","name":"福建省食源性疾病省级平台系统 · TODO","appId":"MOCK_APP_39","remark":"接入参数待业务系统确认","status":"DISABLED","appName":"福建省食源性疾病省级平台系统","enabled":"DISABLED","version":1,"createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","valueMapping":{},"lastCheckedAt":"2026-09-17T22:00:00.000Z","connectionStatus":"UNCONFIGURED"},{"id":"MOCK_INT_MOCK_APP_39MESSAGE","kind":"MESSAGE","mode":"PUSH","name":"福建省食源性疾病省级平台系统 · MESSAGE","appId":"MOCK_APP_39","remark":"接入参数待业务系统确认","status":"UNCONFIGURED","appName":"福建省食源性疾病省级平台系统","enabled":"DISABLED","version":1,"createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","valueMapping":{},"lastCheckedAt":"2026-09-17T21:00:00.000Z","connectionStatus":"UNCONFIGURED"},{"id":"MOCK_INT_MOCK_APP_40SSO","kind":"SSO","mode":"SSO","name":"福建省疾病预防控制中心信息门户系统 · SSO","appId":"MOCK_APP_40","remark":"接入参数待业务系统确认","status":"DISABLED","appName":"福建省疾病预防控制中心信息门户系统","enabled":"DISABLED","version":1,"createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","valueMapping":{},"lastCheckedAt":"2026-09-17T23:00:00.000Z","connectionStatus":"UNCONFIGURED"},{"id":"MOCK_INT_MOCK_APP_40TODO","kind":"TODO","mode":"PUSH","name":"福建省疾病预防控制中心信息门户系统 · TODO","appId":"MOCK_APP_40","remark":"接入参数待业务系统确认","status":"UNCONFIGURED","appName":"福建省疾病预防控制中心信息门户系统","enabled":"DISABLED","version":1,"createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","valueMapping":{},"lastCheckedAt":"2026-09-17T22:00:00.000Z","connectionStatus":"UNCONFIGURED"},{"id":"MOCK_INT_MOCK_APP_40MESSAGE","kind":"MESSAGE","mode":"PUSH","name":"福建省疾病预防控制中心信息门户系统 · MESSAGE","appId":"MOCK_APP_40","remark":"接入参数待业务系统确认","status":"UNCONFIGURED","appName":"福建省疾病预防控制中心信息门户系统","enabled":"DISABLED","version":1,"createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","valueMapping":{},"lastCheckedAt":"2026-09-17T21:00:00.000Z","connectionStatus":"UNCONFIGURED"},{"id":"MOCK_INT_MOCK_APP_41SSO","kind":"SSO","mode":"SSO","name":"福建省慢性病防控指标系统 · SSO","appId":"MOCK_APP_41","remark":"接入参数待业务系统确认","status":"UNCONFIGURED","appName":"福建省慢性病防控指标系统","enabled":"DISABLED","version":1,"createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","valueMapping":{},"lastCheckedAt":"2026-09-17T23:00:00.000Z","connectionStatus":"UNCONFIGURED"},{"id":"MOCK_INT_MOCK_APP_41TODO","kind":"TODO","mode":"PUSH","name":"福建省慢性病防控指标系统 · TODO","appId":"MOCK_APP_41","remark":"接入参数待业务系统确认","status":"UNCONFIGURED","appName":"福建省慢性病防控指标系统","enabled":"DISABLED","version":1,"createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","valueMapping":{},"lastCheckedAt":"2026-09-17T22:00:00.000Z","connectionStatus":"UNCONFIGURED"},{"id":"MOCK_INT_MOCK_APP_41MESSAGE","kind":"MESSAGE","mode":"PUSH","name":"福建省慢性病防控指标系统 · MESSAGE","appId":"MOCK_APP_41","remark":"接入参数待业务系统确认","status":"UNCONFIGURED","appName":"福建省慢性病防控指标系统","enabled":"DISABLED","version":1,"createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","valueMapping":{},"lastCheckedAt":"2026-09-17T21:00:00.000Z","connectionStatus":"UNCONFIGURED"},{"id":"MOCK_INT_MOCK_APP_43SSO","kind":"SSO","mode":"SSO","name":"福建省疫苗冷链监测系统 · SSO","appId":"MOCK_APP_43","remark":"接入参数待业务系统确认","status":"DISABLED","appName":"福建省疫苗冷链监测系统","enabled":"DISABLED","version":1,"createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","valueMapping":{},"lastCheckedAt":"2026-09-17T23:00:00.000Z","connectionStatus":"UNCONFIGURED"},{"id":"MOCK_INT_MOCK_APP_43TODO","kind":"TODO","mode":"PUSH","name":"福建省疫苗冷链监测系统 · TODO","appId":"MOCK_APP_43","remark":"接入参数待业务系统确认","status":"DISABLED","appName":"福建省疫苗冷链监测系统","enabled":"DISABLED","version":1,"createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","valueMapping":{},"lastCheckedAt":"2026-09-17T22:00:00.000Z","connectionStatus":"UNCONFIGURED"},{"id":"MOCK_INT_MOCK_APP_43MESSAGE","kind":"MESSAGE","mode":"PUSH","name":"福建省疫苗冷链监测系统 · MESSAGE","appId":"MOCK_APP_43","remark":"接入参数待业务系统确认","status":"DISABLED","appName":"福建省疫苗冷链监测系统","enabled":"DISABLED","version":1,"createdAt":"2026-09-16T00:00:00.000Z","updatedAt":"2026-09-17T23:00:00.000Z","valueMapping":{},"lastCheckedAt":"2026-09-17T21:00:00.000Z","connectionStatus":"UNCONFIGURED"}],"announcements":[{"id":"MOCK_ANN_1","createdAt":"2026-09-18T00:00:00+00:00","updatedAt":"2026-09-18T00:00:00+00:00","version":1,"title":"关于门户服务使用安排的通知","type":"通知","content":"请通过应用中心查看服务入口，业务办理要求以来源系统说明为准。","scope":"ALL","status":"PUBLISHED","effectiveStart":"2026-09-17T00:00:00+00:00","effectiveEnd":null,"publisherId":"MOCK_EDITOR","publishedAt":"2026-09-17T00:00:00+00:00","publishMode":null,"scheduledPublishAt":null,"submittedAt":null,"submittedBy":null,"withdrawnAt":null,"withdrawnBy":null,"withdrawReason":"","lastEditedAt":null,"lastEditedBy":null,"attachments":[]},{"id":"MOCK_ANN_2","createdAt":"2026-09-18T00:00:00+00:00","updatedAt":"2026-09-18T00:00:00+00:00","version":1,"title":"关于完善应用接入资料的通知","type":"通知","content":"请整理应用目录、责任分工与接口字段，提交接入资料核验。","scope":"GOV","status":"DRAFT","effectiveStart":null,"effectiveEnd":null,"publisherId":null,"publishedAt":null,"publishMode":null,"scheduledPublishAt":null,"submittedAt":null,"submittedBy":null,"withdrawnAt":null,"withdrawnBy":null,"withdrawReason":"","lastEditedAt":null,"lastEditedBy":null,"attachments":[]},{"id":"MOCK_ANN_3","createdAt":"2026-09-18T00:00:00+00:00","updatedAt":"2026-09-18T00:00:00+00:00","version":1,"title":"公众服务事项办理指引","type":"通知","content":"请在办事前核对材料清单，关注待办与消息中的办理要求。","scope":"CITIZEN","status":"PUBLISHED","effectiveStart":"2026-09-16T22:00:00+00:00","effectiveEnd":null,"publisherId":"MOCK_EDITOR","publishedAt":"2026-09-16T22:00:00+00:00","publishMode":null,"scheduledPublishAt":null,"submittedAt":null,"submittedBy":null,"withdrawnAt":null,"withdrawnBy":null,"withdrawReason":"","lastEditedAt":null,"lastEditedBy":null,"attachments":[]},{"id":"MOCK_ANN_4","createdAt":"2026-09-18T00:00:00+00:00","updatedAt":"2026-09-18T00:00:00+00:00","version":1,"title":"卫生健康统计报送安排","type":"通知","content":"请核对本期统计报表，并在规定期限内完成报送。","scope":"GOV","status":"PUBLISHED","effectiveStart":"2026-09-16T21:00:00+00:00","effectiveEnd":null,"publisherId":"MOCK_EDITOR","publishedAt":"2026-09-16T21:00:00+00:00","publishMode":null,"scheduledPublishAt":null,"submittedAt":null,"submittedBy":null,"withdrawnAt":null,"withdrawnBy":null,"withdrawReason":"","lastEditedAt":null,"lastEditedBy":null,"attachments":[]},{"id":"MOCK_ANN_5","createdAt":"2026-09-18T00:00:00+00:00","updatedAt":"2026-09-18T00:00:00+00:00","version":1,"title":"运行保障值班安排","type":"通知","content":"请核对值班分工，及时记录运行问题与处理情况。","scope":"ORG","status":"DRAFT","effectiveStart":null,"effectiveEnd":null,"publisherId":null,"publishedAt":null,"publishMode":null,"scheduledPublishAt":null,"submittedAt":null,"submittedBy":null,"withdrawnAt":null,"withdrawnBy":null,"withdrawReason":"","lastEditedAt":null,"lastEditedBy":null,"attachments":[]},{"id":"MOCK_ANN_6","createdAt":"2026-09-18T00:00:00+00:00","updatedAt":"2026-09-18T00:00:00+00:00","version":1,"title":"信息发布审核工作安排","type":"通知","content":"发布前须核对内容、发布范围与有效期。","scope":"ORG","status":"DRAFT","effectiveStart":null,"effectiveEnd":null,"publisherId":null,"publishedAt":null,"publishMode":null,"scheduledPublishAt":null,"submittedAt":null,"submittedBy":null,"withdrawnAt":null,"withdrawnBy":null,"withdrawReason":"","lastEditedAt":null,"lastEditedBy":null,"attachments":[]},{"id":"MOCK_ANN_7","createdAt":"2026-09-18T00:00:00+00:00","updatedAt":"2026-09-18T00:00:00+00:00","version":1,"title":"原维护时段安排撤回通知","type":"通知","content":"原维护时段安排已撤回，后续安排另行通知。","scope":"ALL","status":"WITHDRAWN","effectiveStart":"2026-09-16T18:00:00+00:00","effectiveEnd":null,"publisherId":"MOCK_EDITOR","publishedAt":"2026-09-16T18:00:00+00:00","publishMode":null,"scheduledPublishAt":null,"submittedAt":null,"submittedBy":null,"withdrawnAt":null,"withdrawnBy":null,"withdrawReason":"","lastEditedAt":null,"lastEditedBy":null,"attachments":[]},{"id":"MOCK_ANN_8","createdAt":"2026-09-18T00:00:00+00:00","updatedAt":"2026-09-18T00:00:00+00:00","version":1,"title":"个人信息保护提示","type":"提示","content":"请妥善保管账号，勿向他人提供验证码或身份核验资料。","scope":"ALL","status":"PUBLISHED","effectiveStart":"2026-09-16T17:00:00+00:00","effectiveEnd":null,"publisherId":"MOCK_EDITOR","publishedAt":"2026-09-16T17:00:00+00:00","publishMode":null,"scheduledPublishAt":null,"submittedAt":null,"submittedBy":null,"withdrawnAt":null,"withdrawnBy":null,"withdrawReason":"","lastEditedAt":null,"lastEditedBy":null,"attachments":[]}],"organizations":[{"id":"MOCK_ORG_PORTAL","code":"ORG_PORTAL","name":"门户运行保障中心","path":"门户运行保障中心","type":"PORTAL_UNIT","remark":"门户本地维护组织","source":"PORTAL_LOCAL","status":"ENABLED","version":1,"parentId":null,"createdAt":"2026-09-16T00:00:00.000Z","sortOrder":1,"updatedAt":"2026-09-17T23:00:00.000Z","parentName":null},{"id":"MOCK_ORG_HEALTH","code":"ORG_HEALTH","name":"卫生健康业务处","path":"卫生健康业务处","type":"GOV_DEPARTMENT","remark":"政务组织索引","source":"MINZHENGWU","status":"ENABLED","version":1,"parentId":null,"createdAt":"2026-09-16T00:00:00.000Z","sortOrder":2,"updatedAt":"2026-09-17T23:00:00.000Z","parentName":null},{"id":"MOCK_ORG_PUBLISH","code":"ORG_PUBLISH","name":"信息发布科","path":"门户运行保障中心 / 信息发布科","type":"GOV_DEPARTMENT","remark":"公告与信息发布维护","source":"PORTAL_LOCAL","status":"ENABLED","version":1,"parentId":"MOCK_ORG_PORTAL","createdAt":"2026-09-16T00:00:00.000Z","sortOrder":3,"updatedAt":"2026-09-17T23:00:00.000Z","parentName":"门户运行保障中心"}],"schemaVersion":3,"monitorSamples":[{"id":"MONITOR_0","kind":"SSO","appId":"MOCK_APP_1","status":"UNCONFIGURED","version":1,"dataSource":"FIXTURE","lastCheckedAt":"2026-09-19T01:00:00.000Z","responseTimeMs":null},{"id":"SCENARIO_MONITOR_MOCK_APP_1_TODO","kind":"TODO","appId":"MOCK_APP_1","status":"NORMAL","version":1,"dataSource":"FIXTURE","lastCheckedAt":"2026-09-19T01:00:00.000Z","responseTimeMs":126},{"id":"SCENARIO_MONITOR_MOCK_APP_1_MESSAGE","kind":"MESSAGE","appId":"MOCK_APP_1","status":"ABNORMAL","version":1,"dataSource":"FIXTURE","lastCheckedAt":"2026-09-19T01:00:00.000Z","responseTimeMs":null},{"id":"SCENARIO_MONITOR_MOCK_APP_2_SSO","kind":"SSO","appId":"MOCK_APP_2","status":"NORMAL","version":1,"dataSource":"FIXTURE","lastCheckedAt":"2026-09-19T01:00:00.000Z","responseTimeMs":126},{"id":"MONITOR_1","kind":"TODO","appId":"MOCK_APP_2","status":"ABNORMAL","version":1,"dataSource":"FIXTURE","lastCheckedAt":"2026-09-19T01:00:00.000Z","responseTimeMs":null},{"id":"SCENARIO_MONITOR_MOCK_APP_2_MESSAGE","kind":"MESSAGE","appId":"MOCK_APP_2","status":"DISABLED","version":1,"dataSource":"FIXTURE","lastCheckedAt":"2026-09-19T01:00:00.000Z","responseTimeMs":null},{"id":"SCENARIO_MONITOR_MOCK_APP_3_SSO","kind":"SSO","appId":"MOCK_APP_3","status":"ABNORMAL","version":1,"dataSource":"FIXTURE","lastCheckedAt":"2026-09-19T01:00:00.000Z","responseTimeMs":null},{"id":"SCENARIO_MONITOR_MOCK_APP_3_TODO","kind":"TODO","appId":"MOCK_APP_3","status":"DISABLED","version":1,"dataSource":"FIXTURE","lastCheckedAt":"2026-09-19T01:00:00.000Z","responseTimeMs":null},{"id":"MONITOR_2","kind":"MESSAGE","appId":"MOCK_APP_3","status":"UNCONFIGURED","version":1,"dataSource":"FIXTURE","lastCheckedAt":"2026-09-19T01:00:00.000Z","responseTimeMs":null},{"id":"SCENARIO_MONITOR_MOCK_APP_4_SSO","kind":"SSO","appId":"MOCK_APP_4","status":"DISABLED","version":1,"dataSource":"FIXTURE","lastCheckedAt":"2026-09-19T01:00:00.000Z","responseTimeMs":null},{"id":"SCENARIO_MONITOR_MOCK_APP_4_TODO","kind":"TODO","appId":"MOCK_APP_4","status":"UNCONFIGURED","version":1,"dataSource":"FIXTURE","lastCheckedAt":"2026-09-19T01:00:00.000Z","responseTimeMs":null},{"id":"SCENARIO_MONITOR_MOCK_APP_4_MESSAGE","kind":"MESSAGE","appId":"MOCK_APP_4","status":"NORMAL","version":1,"dataSource":"FIXTURE","lastCheckedAt":"2026-09-19T01:00:00.000Z","responseTimeMs":126}],"announcementReads":[{"announcementId":"MOCK_ANN_1","userId":"MOCK_USER_1","readAt":"2026-09-18T14:49:12.945+00:00"},{"announcementId":"MOCK_ANN_3","userId":"MOCK_USER_1","readAt":"2026-09-18T14:49:28.247+00:00"},{"announcementId":"MOCK_ANN_1","userId":"MOCK_ADMIN","readAt":"2026-09-18T16:13:46.074+00:00"},{"announcementId":"MOCK_ANN_8","userId":"MOCK_ADMIN","readAt":"2026-09-19T11:16:53.826+00:00"},{"announcementId":"MOCK_ANN_4","userId":"MOCK_ADMIN","readAt":"2026-09-19T12:56:57.465+00:00"},{"announcementId":"MOCK_ANN_1","userId":"MOCK_EDITOR","readAt":"2026-09-20T06:58:39.092+00:00"}],"announcementTrash":[{"id":"MOCK_e734e220-0e95-4b44-b923-8e1b3cc8cb51","createdAt":"2026-09-18T14:50:12.746+00:00","updatedAt":"2026-09-18T14:50:12.746+00:00","version":1,"title":"P4验收草稿删除","type":"通知","content":"仅用于本次新增删除验收","scope":"ALL","status":"DRAFT","effectiveStart":null,"effectiveEnd":null,"publisherId":null,"publishedAt":null,"publishMode":null,"scheduledPublishAt":null,"submittedAt":null,"submittedBy":null,"withdrawnAt":null,"withdrawnBy":null,"withdrawReason":"","lastEditedAt":null,"lastEditedBy":null,"attachments":[],"deletedAt":"2026-09-18T14:50:13.407+00:00","deletedBy":"MOCK_ADMIN","deleteReason":"DRAFT_DELETE"}],"applicationGrants":[{"id":"MOCK_GRANT_CITIZEN_APP13","createdAt":"2026-09-16T00:00:00+00:00","updatedAt":"2026-09-17T23:00:00+00:00","version":1,"userId":"MOCK_USER_1","appId":"MOCK_APP_13","status":"ACTIVE","grantedBy":"MOCK_ADMIN","grantedAt":"2026-09-17T08:00:00+00:00","expiresAt":null},{"id":"MOCK_GRANT_GOV_APP17","createdAt":"2026-09-16T00:00:00+00:00","updatedAt":"2026-09-17T23:00:00+00:00","version":1,"userId":"MOCK_USER_2","appId":"MOCK_APP_17","status":"ACTIVE","grantedBy":"MOCK_ADMIN","grantedAt":"2026-09-17T12:00:00+00:00","expiresAt":null}],"applicationRequests":[{"id":"MOCK_REQ_CITIZEN_EXPIRED","createdAt":"2026-09-15T22:00:00+00:00","updatedAt":"2026-09-16T04:00:00+00:00","version":1,"userId":"MOCK_USER_1","appId":"MOCK_APP_13","requestNo":"REQ-20260915-00001","reason":"历史申请：未在有效期内完成后续处理","contact":"","remark":"","status":"EXPIRED","submittedAt":"2026-09-15T22:00:00+00:00","reviewedBy":null,"reviewedAt":null,"reviewNote":"申请已失效，可重新发起申请","withdrawnAt":null,"expiredAt":"2026-09-16T04:00:00+00:00","userName":"林晓","appName":"福建省肝炎筛查与规范化治疗管理系统"},{"id":"MOCK_REQ_CITIZEN_WITHDRAWN","createdAt":"2026-09-16T10:00:00+00:00","updatedAt":"2026-09-16T13:00:00+00:00","version":1,"userId":"MOCK_USER_1","appId":"MOCK_APP_13","requestNo":"REQ-20260916-00001","reason":"历史申请：业务使用需要","contact":"","remark":"","status":"WITHDRAWN","submittedAt":"2026-09-16T10:00:00+00:00","reviewedBy":null,"reviewedAt":null,"reviewNote":"用户主动撤回","withdrawnAt":"2026-09-16T13:00:00+00:00","expiredAt":null,"userName":"林晓","appName":"福建省肝炎筛查与规范化治疗管理系统"},{"id":"MOCK_REQ_CITIZEN_REJECTED","createdAt":"2026-09-16T18:00:00+00:00","updatedAt":"2026-09-16T21:00:00+00:00","version":1,"userId":"MOCK_USER_1","appId":"MOCK_APP_13","requestNo":"REQ-20260916-00002","reason":"历史申请：业务使用需要","contact":"","remark":"","status":"REJECTED","submittedAt":"2026-09-16T18:00:00+00:00","reviewedBy":"MOCK_ADMIN","reviewedAt":"2026-09-16T21:00:00+00:00","reviewNote":"资料不完整，请补充后重新申请","withdrawnAt":null,"expiredAt":null,"userName":"林晓","appName":"福建省肝炎筛查与规范化治疗管理系统"},{"id":"MOCK_REQ_CITIZEN_APPROVED","createdAt":"2026-09-17T06:00:00+00:00","updatedAt":"2026-09-17T08:00:00+00:00","version":1,"userId":"MOCK_USER_1","appId":"MOCK_APP_13","requestNo":"REQ-20260917-00001","reason":"申请访问公众业务应用","contact":"","remark":"","status":"APPROVED","submittedAt":"2026-09-17T06:00:00+00:00","reviewedBy":"MOCK_ADMIN","reviewedAt":"2026-09-17T08:00:00+00:00","reviewNote":"审核通过，可直接进入应用","withdrawnAt":null,"expiredAt":null,"userName":"林晓","appName":"福建省肝炎筛查与规范化治疗管理系统"},{"id":"MOCK_REQ_GOV_APPROVED_BIND","createdAt":"2026-09-17T10:00:00+00:00","updatedAt":"2026-09-17T12:00:00+00:00","version":1,"userId":"MOCK_USER_2","appId":"MOCK_APP_17","requestNo":"REQ-20260917-00002","reason":"申请业务使用权限并确认历史账号","contact":"","remark":"","status":"APPROVED","submittedAt":"2026-09-17T10:00:00+00:00","reviewedBy":"MOCK_ADMIN","reviewedAt":"2026-09-17T12:00:00+00:00","reviewNote":"审核通过，请继续完成账号确认","withdrawnAt":null,"expiredAt":null,"userName":"陈宁","appName":"全员人口数据库药具发放服务管理"},{"id":"MOCK_REQ_CITIZEN_PENDING","createdAt":"2026-09-17T16:00:00+00:00","updatedAt":"2026-09-17T16:00:00+00:00","version":1,"userId":"MOCK_USER_1","appId":"MOCK_APP_17","requestNo":"REQ-20260918-00001","reason":"申请访问需要账号确认的业务应用","contact":"","remark":"","status":"PENDING","submittedAt":"2026-09-17T16:00:00+00:00","reviewedBy":null,"reviewedAt":null,"reviewNote":null,"withdrawnAt":null,"expiredAt":null,"userName":"林晓","appName":"全员人口数据库药具发放服务管理"},{"id":"MOCK_REQ_GOV_REJECTED","createdAt":"2026-09-17T17:00:00+00:00","updatedAt":"2026-09-17T18:00:00+00:00","version":1,"userId":"MOCK_USER_2","appId":"MOCK_APP_13","requestNo":"REQ-20260918-00002","reason":"申请业务使用权限","contact":"","remark":"","status":"REJECTED","submittedAt":"2026-09-17T17:00:00+00:00","reviewedBy":"MOCK_ADMIN","reviewedAt":"2026-09-17T18:00:00+00:00","reviewNote":"资料不完整，可查看原因后重新申请","withdrawnAt":null,"expiredAt":null,"userName":"陈宁","appName":"福建省肝炎筛查与规范化治疗管理系统"}],"accountOpeningRequests":[{"id":"MOCK_OPEN_COMPLETED","createdAt":"2026-09-16T10:00:00+00:00","updatedAt":"2026-09-17T20:00:00+00:00","version":1,"userId":"MOCK_EDITOR","appId":"MOCK_APP_6","requestNo":"OPEN-20260916-00001","reason":"信息发布工作需要使用目标系统","contact":"门户运行保障中心","remark":"","status":"COMPLETED","submittedAt":"2026-09-16T10:00:00+00:00","handledBy":"MOCK_ADMIN","handledAt":"2026-09-17T20:00:00+00:00","handleNote":"子系统账号已开通，可返回应用中心完成账号关联","userName":"郑颖","appName":"福建省区域影像平台"},{"id":"MOCK_OPEN_PROCESSING","createdAt":"2026-09-17T02:00:00+00:00","updatedAt":"2026-09-17T16:00:00+00:00","version":1,"userId":"MOCK_USER_2","appId":"MOCK_APP_6","requestNo":"OPEN-20260917-00002","reason":"业务经办需要使用该系统，申请开通账号","contact":"卫生健康业务处","remark":"已有政务身份，请核对后开通","status":"PROCESSING","submittedAt":"2026-09-17T02:00:00+00:00","handledBy":"MOCK_ADMIN","handledAt":null,"handleNote":"已转目标子系统管理员处理","userName":"陈宁","appName":"福建省区域影像平台"},{"id":"MOCK_OPEN_PENDING","createdAt":"2026-09-17T12:00:00+00:00","updatedAt":"2026-09-17T12:00:00+00:00","version":1,"userId":"MOCK_USER_1","appId":"MOCK_APP_6","requestNo":"OPEN-20260917-00001","reason":"首次使用该业务系统，申请开通子系统账号","contact":"门户内联系","remark":"请按统一身份信息创建账号","status":"PENDING","submittedAt":"2026-09-17T12:00:00+00:00","handledBy":null,"handledAt":null,"handleNote":null,"userName":"林晓","appName":"福建省区域影像平台"}],"mappingVerificationEvents":[]}	json	CONFIGURED	P4 runtime isolated snapshot; not production identity
20	\N	\N	\N	\N	\N	P4FIX_CONFIG_7	2026-09-18 00:00:00+00	2026-09-18 17:28:40.527+00	3	P4FIX_portal.page_size	15	count	CONFIGURED	列表每页条数
30	\N	\N	\N	\N	\N	P4FIX_RULE_retention.announcement_expired_days	2026-09-18 14:50:12.068+00	2026-09-18 17:28:40.527+00	3	P4FIX_retention.announcement_expired_days	0	天	CONFIGURED	公告过期后自动删除
\.


--
-- Data for Name: todo_item; Type: TABLE DATA; Schema: pb3gir75kkooyea; Owner: admin
--

COPY pb3gir75kkooyea.todo_item (nc_id, created_at1, updated_at1, created_by, updated_by, nc_order, id, created_at, updated_at, version, application_id, source_todo_id, target_user_id, title, business_type, summary, status, priority, source_created_at, source_updated_at, source_revision, due_at, terminal_at, business_url, runtime_id, received_at, archived_at) FROM stdin;
2	\N	\N	\N	\N	\N	P4FIX_TODO_0_0	2026-09-18 00:00:00+00	2026-09-18 00:00:00+00	1	P4FIX_APP_1	P4FIX_P4_TODO_0_0	P4FIX_USER_1	核对服务申请资料	服务事项	福建省新生儿疾病筛查管理系统：核对服务申请资料。请在来源系统查看业务详情。	PENDING	HIGH	2026-09-17 22:00:00+00	2026-09-17 23:00:00+00	1	2026-09-17 23:00:00+00	\N	https://p4.invalid/app/1	MOCK_TODO_0_0	2026-09-18 00:00:00+00	\N
3	\N	\N	\N	\N	\N	P4FIX_TODO_0_1	2026-09-18 00:00:00+00	2026-09-18 00:00:00+00	1	P4FIX_APP_2	P4FIX_P4_TODO_0_1	P4FIX_USER_1	补充业务登记信息	服务事项	福建省妇幼卫生信息系统：补充业务登记信息。请在来源系统查看业务详情。	PENDING	MEDIUM	2026-09-17 21:00:00+00	2026-09-17 23:00:00+00	1	2026-09-17 22:00:00+00	\N	https://p4.invalid/app/2	MOCK_TODO_0_1	2026-09-18 00:00:00+00	\N
4	\N	\N	\N	\N	\N	P4FIX_TODO_0_2	2026-09-18 00:00:00+00	2026-09-18 00:00:00+00	1	P4FIX_APP_3	P4FIX_P4_TODO_0_2	P4FIX_USER_1	确认服务安排	服务事项	福建省产前筛查与诊断管理系统：确认服务安排。请在来源系统查看业务详情。	PENDING	LOW	2026-09-17 20:00:00+00	2026-09-17 23:00:00+00	1	2026-09-17 21:00:00+00	\N	https://p4.invalid/app/3	MOCK_TODO_0_2	2026-09-18 00:00:00+00	\N
5	\N	\N	\N	\N	\N	P4FIX_TODO_0_3	2026-09-18 00:00:00+00	2026-09-18 00:00:00+00	1	P4FIX_APP_4	P4FIX_P4_TODO_0_3	P4FIX_USER_1	查看材料核验意见	服务事项	福建省地中海贫血信息管理系统：查看材料核验意见。请在来源系统查看业务详情。	PENDING	HIGH	2026-09-17 19:00:00+00	2026-09-17 23:00:00+00	1	2026-09-18 12:00:00+00	\N	https://p4.invalid/app/4	MOCK_TODO_0_3	2026-09-18 00:00:00+00	\N
6	\N	\N	\N	\N	\N	P4FIX_TODO_0_4	2026-09-18 00:00:00+00	2026-09-18 00:00:00+00	1	P4FIX_APP_5	P4FIX_P4_TODO_0_4	P4FIX_USER_1	核对信息更新内容	服务事项	福建省慢病报告与管理系统：核对信息更新内容。请在来源系统查看业务详情。	PENDING	MEDIUM	2026-09-17 18:00:00+00	2026-09-17 23:00:00+00	1	2026-09-18 16:00:00+00	\N	https://p4.invalid/app/5	MOCK_TODO_0_4	2026-09-18 00:00:00+00	\N
7	\N	\N	\N	\N	\N	P4FIX_TODO_0_5	2026-09-18 00:00:00+00	2026-09-18 00:00:00+00	1	P4FIX_APP_6	P4FIX_P4_TODO_0_5	P4FIX_USER_1	确认事项办理进度	服务事项	福建省区域影像平台：确认事项办理进度。请在来源系统查看业务详情。	PENDING	LOW	2026-09-17 17:00:00+00	2026-09-17 23:00:00+00	1	2026-09-18 20:00:00+00	\N	https://p4.invalid/app/6	MOCK_TODO_0_5	2026-09-18 00:00:00+00	\N
8	\N	\N	\N	\N	\N	P4FIX_TODO_0_6	2026-09-18 00:00:00+00	2026-09-18 00:00:00+00	1	P4FIX_APP_11	P4FIX_P4_TODO_0_6	P4FIX_USER_1	完善服务联系说明	服务事项	福建省免疫规划管理信息系统：完善服务联系说明。请在来源系统查看业务详情。	PENDING	HIGH	2026-09-17 16:00:00+00	2026-09-17 23:00:00+00	1	2026-09-19 00:00:00+00	\N	https://p4.invalid/app/11	MOCK_TODO_0_6	2026-09-18 00:00:00+00	\N
9	\N	\N	\N	\N	\N	P4FIX_TODO_0_7	2026-09-18 00:00:00+00	2026-09-18 00:00:00+00	1	P4FIX_APP_12	P4FIX_P4_TODO_0_7	P4FIX_USER_1	查看后续办理要求	服务事项	中医馆健康信息系统：查看后续办理要求。请在来源系统查看业务详情。	PENDING	MEDIUM	2026-09-17 15:00:00+00	2026-09-17 23:00:00+00	1	2026-09-19 04:00:00+00	\N	https://p4.invalid/app/12	MOCK_TODO_0_7	2026-09-18 00:00:00+00	\N
10	\N	\N	\N	\N	\N	P4FIX_TODO_0_8	2026-09-18 00:00:00+00	2026-09-18 00:00:00+00	1	P4FIX_APP_1	P4FIX_P4_TODO_0_8	P4FIX_USER_1	资料核验已完成	服务事项	福建省新生儿疾病筛查管理系统：资料核验已完成。请在来源系统查看业务详情。	COMPLETED	LOW	2026-09-17 14:00:00+00	2026-09-17 23:00:00+00	2	2026-09-19 08:00:00+00	2026-09-17 23:00:00+00	https://p4.invalid/app/1	MOCK_TODO_0_8	2026-09-18 00:00:00+00	\N
11	\N	\N	\N	\N	\N	P4FIX_TODO_0_9	2026-09-18 00:00:00+00	2026-09-18 00:00:00+00	1	P4FIX_APP_2	P4FIX_P4_TODO_0_9	P4FIX_USER_1	业务申请已撤回	服务事项	福建省妇幼卫生信息系统：业务申请已撤回。请在来源系统查看业务详情。	WITHDRAWN	HIGH	2026-09-17 13:00:00+00	2026-09-17 23:00:00+00	2	2026-09-19 12:00:00+00	2026-09-17 23:00:00+00	https://p4.invalid/app/2	MOCK_TODO_0_9	2026-09-18 00:00:00+00	\N
12	\N	\N	\N	\N	\N	P4FIX_TODO_0_10	2026-09-18 00:00:00+00	2026-09-18 00:00:00+00	1	P4FIX_APP_3	P4FIX_P4_TODO_0_10	P4FIX_USER_1	办理期限已结束	服务事项	福建省产前筛查与诊断管理系统：办理期限已结束。请在来源系统查看业务详情。	EXPIRED	MEDIUM	2026-09-17 12:00:00+00	2026-09-17 23:00:00+00	2	2026-09-19 16:00:00+00	2026-09-17 23:00:00+00	https://p4.invalid/app/3	MOCK_TODO_0_10	2026-09-18 00:00:00+00	\N
13	\N	\N	\N	\N	\N	P4FIX_TODO_1_0	2026-09-18 00:00:00+00	2026-09-18 00:00:00+00	1	P4FIX_APP_1	P4FIX_P4_TODO_1_0	P4FIX_USER_2	核对服务申请资料	服务事项	福建省新生儿疾病筛查管理系统：核对服务申请资料。请在来源系统查看业务详情。	PENDING	HIGH	2026-09-17 22:00:00+00	2026-09-17 23:00:00+00	1	2026-09-17 23:00:00+00	\N	https://p4.invalid/app/1	MOCK_TODO_1_0	2026-09-18 00:00:00+00	\N
14	\N	\N	\N	\N	\N	P4FIX_TODO_1_1	2026-09-18 00:00:00+00	2026-09-18 00:00:00+00	1	P4FIX_APP_2	P4FIX_P4_TODO_1_1	P4FIX_USER_2	补充业务登记信息	服务事项	福建省妇幼卫生信息系统：补充业务登记信息。请在来源系统查看业务详情。	PENDING	MEDIUM	2026-09-17 21:00:00+00	2026-09-17 23:00:00+00	1	2026-09-17 22:00:00+00	\N	https://p4.invalid/app/2	MOCK_TODO_1_1	2026-09-18 00:00:00+00	\N
15	\N	\N	\N	\N	\N	P4FIX_TODO_1_2	2026-09-18 00:00:00+00	2026-09-18 00:00:00+00	1	P4FIX_APP_3	P4FIX_P4_TODO_1_2	P4FIX_USER_2	确认服务安排	服务事项	福建省产前筛查与诊断管理系统：确认服务安排。请在来源系统查看业务详情。	PENDING	LOW	2026-09-17 20:00:00+00	2026-09-17 23:00:00+00	1	2026-09-17 21:00:00+00	\N	https://p4.invalid/app/3	MOCK_TODO_1_2	2026-09-18 00:00:00+00	\N
16	\N	\N	\N	\N	\N	P4FIX_TODO_1_3	2026-09-18 00:00:00+00	2026-09-18 00:00:00+00	1	P4FIX_APP_4	P4FIX_P4_TODO_1_3	P4FIX_USER_2	查看材料核验意见	服务事项	福建省地中海贫血信息管理系统：查看材料核验意见。请在来源系统查看业务详情。	PENDING	HIGH	2026-09-17 19:00:00+00	2026-09-17 23:00:00+00	1	2026-09-18 12:00:00+00	\N	https://p4.invalid/app/4	MOCK_TODO_1_3	2026-09-18 00:00:00+00	\N
17	\N	\N	\N	\N	\N	P4FIX_TODO_1_4	2026-09-18 00:00:00+00	2026-09-18 00:00:00+00	1	P4FIX_APP_5	P4FIX_P4_TODO_1_4	P4FIX_USER_2	核对信息更新内容	服务事项	福建省慢病报告与管理系统：核对信息更新内容。请在来源系统查看业务详情。	PENDING	MEDIUM	2026-09-17 18:00:00+00	2026-09-17 23:00:00+00	1	2026-09-18 16:00:00+00	\N	https://p4.invalid/app/5	MOCK_TODO_1_4	2026-09-18 00:00:00+00	\N
18	\N	\N	\N	\N	\N	P4FIX_TODO_1_5	2026-09-18 00:00:00+00	2026-09-18 00:00:00+00	1	P4FIX_APP_6	P4FIX_P4_TODO_1_5	P4FIX_USER_2	确认事项办理进度	服务事项	福建省区域影像平台：确认事项办理进度。请在来源系统查看业务详情。	PENDING	LOW	2026-09-17 17:00:00+00	2026-09-17 23:00:00+00	1	2026-09-18 20:00:00+00	\N	https://p4.invalid/app/6	MOCK_TODO_1_5	2026-09-18 00:00:00+00	\N
19	\N	\N	\N	\N	\N	P4FIX_TODO_1_6	2026-09-18 00:00:00+00	2026-09-18 00:00:00+00	1	P4FIX_APP_7	P4FIX_P4_TODO_1_6	P4FIX_USER_2	完善服务联系说明	服务事项	质控评分系统：完善服务联系说明。请在来源系统查看业务详情。	PENDING	HIGH	2026-09-17 16:00:00+00	2026-09-17 23:00:00+00	1	2026-09-19 00:00:00+00	\N	https://p4.invalid/app/7	MOCK_TODO_1_6	2026-09-18 00:00:00+00	\N
20	\N	\N	\N	\N	\N	P4FIX_TODO_1_7	2026-09-18 00:00:00+00	2026-09-18 00:00:00+00	1	P4FIX_APP_8	P4FIX_P4_TODO_1_7	P4FIX_USER_2	查看后续办理要求	服务事项	省级平台决策支持展示系统：查看后续办理要求。请在来源系统查看业务详情。	PENDING	MEDIUM	2026-09-17 15:00:00+00	2026-09-17 23:00:00+00	1	2026-09-19 04:00:00+00	\N	https://p4.invalid/app/8	MOCK_TODO_1_7	2026-09-18 00:00:00+00	\N
21	\N	\N	\N	\N	\N	P4FIX_TODO_1_8	2026-09-18 00:00:00+00	2026-09-18 00:00:00+00	1	P4FIX_APP_1	P4FIX_P4_TODO_1_8	P4FIX_USER_2	资料核验已完成	服务事项	福建省新生儿疾病筛查管理系统：资料核验已完成。请在来源系统查看业务详情。	COMPLETED	LOW	2026-09-17 14:00:00+00	2026-09-17 23:00:00+00	2	2026-09-19 08:00:00+00	2026-09-17 23:00:00+00	https://p4.invalid/app/1	MOCK_TODO_1_8	2026-09-18 00:00:00+00	\N
22	\N	\N	\N	\N	\N	P4FIX_TODO_1_9	2026-09-18 00:00:00+00	2026-09-18 00:00:00+00	1	P4FIX_APP_2	P4FIX_P4_TODO_1_9	P4FIX_USER_2	业务申请已撤回	服务事项	福建省妇幼卫生信息系统：业务申请已撤回。请在来源系统查看业务详情。	WITHDRAWN	HIGH	2026-09-17 13:00:00+00	2026-09-17 23:00:00+00	2	2026-09-19 12:00:00+00	2026-09-17 23:00:00+00	https://p4.invalid/app/2	MOCK_TODO_1_9	2026-09-18 00:00:00+00	\N
23	\N	\N	\N	\N	\N	P4FIX_TODO_1_10	2026-09-18 00:00:00+00	2026-09-18 00:00:00+00	1	P4FIX_APP_3	P4FIX_P4_TODO_1_10	P4FIX_USER_2	办理期限已结束	服务事项	福建省产前筛查与诊断管理系统：办理期限已结束。请在来源系统查看业务详情。	EXPIRED	MEDIUM	2026-09-17 12:00:00+00	2026-09-17 23:00:00+00	2	2026-09-19 16:00:00+00	2026-09-17 23:00:00+00	https://p4.invalid/app/3	MOCK_TODO_1_10	2026-09-18 00:00:00+00	\N
24	\N	\N	\N	\N	\N	P4FIX_TODO_2_0	2026-09-18 00:00:00+00	2026-09-18 00:00:00+00	1	P4FIX_APP_1	P4FIX_P4_TODO_2_0	P4FIX_ADMIN	核对服务申请资料	服务事项	福建省新生儿疾病筛查管理系统：核对服务申请资料。请在来源系统查看业务详情。	PENDING	HIGH	2026-09-17 22:00:00+00	2026-09-17 23:00:00+00	1	2026-09-17 23:00:00+00	\N	https://p4.invalid/app/1	MOCK_TODO_2_0	2026-09-18 00:00:00+00	\N
25	\N	\N	\N	\N	\N	P4FIX_TODO_2_1	2026-09-18 00:00:00+00	2026-09-18 00:00:00+00	1	P4FIX_APP_2	P4FIX_P4_TODO_2_1	P4FIX_ADMIN	补充业务登记信息	服务事项	福建省妇幼卫生信息系统：补充业务登记信息。请在来源系统查看业务详情。	PENDING	MEDIUM	2026-09-17 21:00:00+00	2026-09-17 23:00:00+00	1	2026-09-17 22:00:00+00	\N	https://p4.invalid/app/2	MOCK_TODO_2_1	2026-09-18 00:00:00+00	\N
26	\N	\N	\N	\N	\N	P4FIX_TODO_2_2	2026-09-18 00:00:00+00	2026-09-18 00:00:00+00	1	P4FIX_APP_3	P4FIX_P4_TODO_2_2	P4FIX_ADMIN	确认服务安排	服务事项	福建省产前筛查与诊断管理系统：确认服务安排。请在来源系统查看业务详情。	PENDING	LOW	2026-09-17 20:00:00+00	2026-09-17 23:00:00+00	1	2026-09-17 21:00:00+00	\N	https://p4.invalid/app/3	MOCK_TODO_2_2	2026-09-18 00:00:00+00	\N
27	\N	\N	\N	\N	\N	P4FIX_TODO_2_3	2026-09-18 00:00:00+00	2026-09-18 00:00:00+00	1	P4FIX_APP_4	P4FIX_P4_TODO_2_3	P4FIX_ADMIN	查看材料核验意见	服务事项	福建省地中海贫血信息管理系统：查看材料核验意见。请在来源系统查看业务详情。	PENDING	HIGH	2026-09-17 19:00:00+00	2026-09-17 23:00:00+00	1	2026-09-18 12:00:00+00	\N	https://p4.invalid/app/4	MOCK_TODO_2_3	2026-09-18 00:00:00+00	\N
28	\N	\N	\N	\N	\N	P4FIX_TODO_2_4	2026-09-18 00:00:00+00	2026-09-18 00:00:00+00	1	P4FIX_APP_5	P4FIX_P4_TODO_2_4	P4FIX_ADMIN	核对信息更新内容	服务事项	福建省慢病报告与管理系统：核对信息更新内容。请在来源系统查看业务详情。	PENDING	MEDIUM	2026-09-17 18:00:00+00	2026-09-17 23:00:00+00	1	2026-09-18 16:00:00+00	\N	https://p4.invalid/app/5	MOCK_TODO_2_4	2026-09-18 00:00:00+00	\N
29	\N	\N	\N	\N	\N	P4FIX_TODO_2_5	2026-09-18 00:00:00+00	2026-09-18 00:00:00+00	1	P4FIX_APP_6	P4FIX_P4_TODO_2_5	P4FIX_ADMIN	确认事项办理进度	服务事项	福建省区域影像平台：确认事项办理进度。请在来源系统查看业务详情。	PENDING	LOW	2026-09-17 17:00:00+00	2026-09-17 23:00:00+00	1	2026-09-18 20:00:00+00	\N	https://p4.invalid/app/6	MOCK_TODO_2_5	2026-09-18 00:00:00+00	\N
30	\N	\N	\N	\N	\N	P4FIX_TODO_2_6	2026-09-18 00:00:00+00	2026-09-18 00:00:00+00	1	P4FIX_APP_7	P4FIX_P4_TODO_2_6	P4FIX_ADMIN	完善服务联系说明	服务事项	质控评分系统：完善服务联系说明。请在来源系统查看业务详情。	PENDING	HIGH	2026-09-17 16:00:00+00	2026-09-17 23:00:00+00	1	2026-09-19 00:00:00+00	\N	https://p4.invalid/app/7	MOCK_TODO_2_6	2026-09-18 00:00:00+00	\N
31	\N	\N	\N	\N	\N	P4FIX_TODO_2_7	2026-09-18 00:00:00+00	2026-09-18 00:00:00+00	1	P4FIX_APP_8	P4FIX_P4_TODO_2_7	P4FIX_ADMIN	查看后续办理要求	服务事项	省级平台决策支持展示系统：查看后续办理要求。请在来源系统查看业务详情。	PENDING	MEDIUM	2026-09-17 15:00:00+00	2026-09-17 23:00:00+00	1	2026-09-19 04:00:00+00	\N	https://p4.invalid/app/8	MOCK_TODO_2_7	2026-09-18 00:00:00+00	\N
32	\N	\N	\N	\N	\N	P4FIX_TODO_2_8	2026-09-18 00:00:00+00	2026-09-18 00:00:00+00	1	P4FIX_APP_1	P4FIX_P4_TODO_2_8	P4FIX_ADMIN	资料核验已完成	服务事项	福建省新生儿疾病筛查管理系统：资料核验已完成。请在来源系统查看业务详情。	COMPLETED	LOW	2026-09-17 14:00:00+00	2026-09-17 23:00:00+00	2	2026-09-19 08:00:00+00	2026-09-17 23:00:00+00	https://p4.invalid/app/1	MOCK_TODO_2_8	2026-09-18 00:00:00+00	\N
33	\N	\N	\N	\N	\N	P4FIX_TODO_2_9	2026-09-18 00:00:00+00	2026-09-18 00:00:00+00	1	P4FIX_APP_2	P4FIX_P4_TODO_2_9	P4FIX_ADMIN	业务申请已撤回	服务事项	福建省妇幼卫生信息系统：业务申请已撤回。请在来源系统查看业务详情。	WITHDRAWN	HIGH	2026-09-17 13:00:00+00	2026-09-17 23:00:00+00	2	2026-09-19 12:00:00+00	2026-09-17 23:00:00+00	https://p4.invalid/app/2	MOCK_TODO_2_9	2026-09-18 00:00:00+00	\N
34	\N	\N	\N	\N	\N	P4FIX_TODO_2_10	2026-09-18 00:00:00+00	2026-09-18 00:00:00+00	1	P4FIX_APP_3	P4FIX_P4_TODO_2_10	P4FIX_ADMIN	办理期限已结束	服务事项	福建省产前筛查与诊断管理系统：办理期限已结束。请在来源系统查看业务详情。	EXPIRED	MEDIUM	2026-09-17 12:00:00+00	2026-09-17 23:00:00+00	2	2026-09-19 16:00:00+00	2026-09-17 23:00:00+00	https://p4.invalid/app/3	MOCK_TODO_2_10	2026-09-18 00:00:00+00	\N
35	\N	\N	\N	\N	\N	P4FIX_TODO_3_0	2026-09-18 00:00:00+00	2026-09-18 00:00:00+00	1	P4FIX_APP_1	P4FIX_P4_TODO_3_0	P4FIX_EDITOR	核对服务申请资料	服务事项	福建省新生儿疾病筛查管理系统：核对服务申请资料。请在来源系统查看业务详情。	PENDING	HIGH	2026-09-17 22:00:00+00	2026-09-17 23:00:00+00	1	2026-09-17 23:00:00+00	\N	https://p4.invalid/app/1	MOCK_TODO_3_0	2026-09-18 00:00:00+00	\N
36	\N	\N	\N	\N	\N	P4FIX_TODO_3_1	2026-09-18 00:00:00+00	2026-09-18 00:00:00+00	1	P4FIX_APP_2	P4FIX_P4_TODO_3_1	P4FIX_EDITOR	补充业务登记信息	服务事项	福建省妇幼卫生信息系统：补充业务登记信息。请在来源系统查看业务详情。	PENDING	MEDIUM	2026-09-17 21:00:00+00	2026-09-17 23:00:00+00	1	2026-09-17 22:00:00+00	\N	https://p4.invalid/app/2	MOCK_TODO_3_1	2026-09-18 00:00:00+00	\N
37	\N	\N	\N	\N	\N	P4FIX_TODO_3_2	2026-09-18 00:00:00+00	2026-09-18 00:00:00+00	1	P4FIX_APP_3	P4FIX_P4_TODO_3_2	P4FIX_EDITOR	确认服务安排	服务事项	福建省产前筛查与诊断管理系统：确认服务安排。请在来源系统查看业务详情。	PENDING	LOW	2026-09-17 20:00:00+00	2026-09-17 23:00:00+00	1	2026-09-17 21:00:00+00	\N	https://p4.invalid/app/3	MOCK_TODO_3_2	2026-09-18 00:00:00+00	\N
38	\N	\N	\N	\N	\N	P4FIX_TODO_3_3	2026-09-18 00:00:00+00	2026-09-18 00:00:00+00	1	P4FIX_APP_4	P4FIX_P4_TODO_3_3	P4FIX_EDITOR	查看材料核验意见	服务事项	福建省地中海贫血信息管理系统：查看材料核验意见。请在来源系统查看业务详情。	PENDING	HIGH	2026-09-17 19:00:00+00	2026-09-17 23:00:00+00	1	2026-09-18 12:00:00+00	\N	https://p4.invalid/app/4	MOCK_TODO_3_3	2026-09-18 00:00:00+00	\N
39	\N	\N	\N	\N	\N	P4FIX_TODO_3_4	2026-09-18 00:00:00+00	2026-09-18 00:00:00+00	1	P4FIX_APP_5	P4FIX_P4_TODO_3_4	P4FIX_EDITOR	核对信息更新内容	服务事项	福建省慢病报告与管理系统：核对信息更新内容。请在来源系统查看业务详情。	PENDING	MEDIUM	2026-09-17 18:00:00+00	2026-09-17 23:00:00+00	1	2026-09-18 16:00:00+00	\N	https://p4.invalid/app/5	MOCK_TODO_3_4	2026-09-18 00:00:00+00	\N
40	\N	\N	\N	\N	\N	P4FIX_TODO_3_5	2026-09-18 00:00:00+00	2026-09-18 00:00:00+00	1	P4FIX_APP_6	P4FIX_P4_TODO_3_5	P4FIX_EDITOR	确认事项办理进度	服务事项	福建省区域影像平台：确认事项办理进度。请在来源系统查看业务详情。	PENDING	LOW	2026-09-17 17:00:00+00	2026-09-17 23:00:00+00	1	2026-09-18 20:00:00+00	\N	https://p4.invalid/app/6	MOCK_TODO_3_5	2026-09-18 00:00:00+00	\N
41	\N	\N	\N	\N	\N	P4FIX_TODO_3_6	2026-09-18 00:00:00+00	2026-09-18 00:00:00+00	1	P4FIX_APP_7	P4FIX_P4_TODO_3_6	P4FIX_EDITOR	完善服务联系说明	服务事项	质控评分系统：完善服务联系说明。请在来源系统查看业务详情。	PENDING	HIGH	2026-09-17 16:00:00+00	2026-09-17 23:00:00+00	1	2026-09-19 00:00:00+00	\N	https://p4.invalid/app/7	MOCK_TODO_3_6	2026-09-18 00:00:00+00	\N
42	\N	\N	\N	\N	\N	P4FIX_TODO_3_7	2026-09-18 00:00:00+00	2026-09-18 00:00:00+00	1	P4FIX_APP_8	P4FIX_P4_TODO_3_7	P4FIX_EDITOR	查看后续办理要求	服务事项	省级平台决策支持展示系统：查看后续办理要求。请在来源系统查看业务详情。	PENDING	MEDIUM	2026-09-17 15:00:00+00	2026-09-17 23:00:00+00	1	2026-09-19 04:00:00+00	\N	https://p4.invalid/app/8	MOCK_TODO_3_7	2026-09-18 00:00:00+00	\N
43	\N	\N	\N	\N	\N	P4FIX_TODO_3_8	2026-09-18 00:00:00+00	2026-09-18 00:00:00+00	1	P4FIX_APP_1	P4FIX_P4_TODO_3_8	P4FIX_EDITOR	资料核验已完成	服务事项	福建省新生儿疾病筛查管理系统：资料核验已完成。请在来源系统查看业务详情。	COMPLETED	LOW	2026-09-17 14:00:00+00	2026-09-17 23:00:00+00	2	2026-09-19 08:00:00+00	2026-09-17 23:00:00+00	https://p4.invalid/app/1	MOCK_TODO_3_8	2026-09-18 00:00:00+00	\N
44	\N	\N	\N	\N	\N	P4FIX_TODO_3_9	2026-09-18 00:00:00+00	2026-09-18 00:00:00+00	1	P4FIX_APP_2	P4FIX_P4_TODO_3_9	P4FIX_EDITOR	业务申请已撤回	服务事项	福建省妇幼卫生信息系统：业务申请已撤回。请在来源系统查看业务详情。	WITHDRAWN	HIGH	2026-09-17 13:00:00+00	2026-09-17 23:00:00+00	2	2026-09-19 12:00:00+00	2026-09-17 23:00:00+00	https://p4.invalid/app/2	MOCK_TODO_3_9	2026-09-18 00:00:00+00	\N
45	\N	\N	\N	\N	\N	P4FIX_TODO_3_10	2026-09-18 00:00:00+00	2026-09-18 00:00:00+00	1	P4FIX_APP_3	P4FIX_P4_TODO_3_10	P4FIX_EDITOR	办理期限已结束	服务事项	福建省产前筛查与诊断管理系统：办理期限已结束。请在来源系统查看业务详情。	EXPIRED	MEDIUM	2026-09-17 12:00:00+00	2026-09-17 23:00:00+00	2	2026-09-19 16:00:00+00	2026-09-17 23:00:00+00	https://p4.invalid/app/3	MOCK_TODO_3_10	2026-09-18 00:00:00+00	\N
\.


--
-- Data for Name: unified_user; Type: TABLE DATA; Schema: pb3gir75kkooyea; Owner: admin
--

COPY pb3gir75kkooyea.unified_user (nc_id, created_at1, updated_at1, created_by, updated_by, nc_order, id, created_at, updated_at, version, display_name, org_key, org_name, status, first_login_at, last_login_at) FROM stdin;
4	\N	\N	\N	\N	\N	P4FIX_USER_1	2026-09-18 00:00:00+00	2026-09-18 00:00:00+00	1	林晓	P4FIX_PUBLIC	公众服务	NORMAL	\N	\N
5	\N	\N	\N	\N	\N	P4FIX_USER_2	2026-09-18 00:00:00+00	2026-09-18 00:00:00+00	1	陈宁	P4FIX_HEALTH	卫生健康业务处	NORMAL	\N	\N
6	\N	\N	\N	\N	\N	P4FIX_ADMIN	2026-09-18 00:00:00+00	2026-09-18 00:00:00+00	1	周明	P4FIX_PORTAL	门户运行保障中心	NORMAL	\N	\N
7	\N	\N	\N	\N	\N	P4FIX_EDITOR	2026-09-18 00:00:00+00	2026-09-18 00:00:00+00	1	郑颖	P4FIX_PORTAL	门户运行保障中心	NORMAL	\N	\N
8	\N	\N	\N	\N	\N	P4FIX_LOCAL_ADMIN	2026-09-16 00:00:00+00	2026-09-17 23:00:00+00	1	门户管理员	P4FIX_PORTAL	门户运行保障中心	NORMAL	\N	\N
\.


--
-- Name: announcement_attachment_nc_id_seq; Type: SEQUENCE SET; Schema: pb3gir75kkooyea; Owner: admin
--

SELECT pg_catalog.setval('pb3gir75kkooyea.announcement_attachment_nc_id_seq', 1, false);


--
-- Name: announcement_nc_id_seq; Type: SEQUENCE SET; Schema: pb3gir75kkooyea; Owner: admin
--

SELECT pg_catalog.setval('pb3gir75kkooyea.announcement_nc_id_seq', 520, true);


--
-- Name: announcement_org_scope_nc_id_seq; Type: SEQUENCE SET; Schema: pb3gir75kkooyea; Owner: admin
--

SELECT pg_catalog.setval('pb3gir75kkooyea.announcement_org_scope_nc_id_seq', 2, true);


--
-- Name: application_category_nc_id_seq; Type: SEQUENCE SET; Schema: pb3gir75kkooyea; Owner: admin
--

SELECT pg_catalog.setval('pb3gir75kkooyea.application_category_nc_id_seq', 19, true);


--
-- Name: application_nc_id_seq; Type: SEQUENCE SET; Schema: pb3gir75kkooyea; Owner: admin
--

SELECT pg_catalog.setval('pb3gir75kkooyea.application_nc_id_seq', 132, true);


--
-- Name: application_user_mapping_nc_id_seq; Type: SEQUENCE SET; Schema: pb3gir75kkooyea; Owner: admin
--

SELECT pg_catalog.setval('pb3gir75kkooyea.application_user_mapping_nc_id_seq', 122, true);


--
-- Name: audit_event_nc_id_seq; Type: SEQUENCE SET; Schema: pb3gir75kkooyea; Owner: admin
--

SELECT pg_catalog.setval('pb3gir75kkooyea.audit_event_nc_id_seq', 265, true);


--
-- Name: identity_mapping_nc_id_seq; Type: SEQUENCE SET; Schema: pb3gir75kkooyea; Owner: admin
--

SELECT pg_catalog.setval('pb3gir75kkooyea.identity_mapping_nc_id_seq', 6, true);


--
-- Name: identity_source_nc_id_seq; Type: SEQUENCE SET; Schema: pb3gir75kkooyea; Owner: admin
--

SELECT pg_catalog.setval('pb3gir75kkooyea.identity_source_nc_id_seq', 3, true);


--
-- Name: ingest_receipt_nc_id_seq; Type: SEQUENCE SET; Schema: pb3gir75kkooyea; Owner: admin
--

SELECT pg_catalog.setval('pb3gir75kkooyea.ingest_receipt_nc_id_seq', 3, true);


--
-- Name: login_request_nc_id_seq; Type: SEQUENCE SET; Schema: pb3gir75kkooyea; Owner: admin
--

SELECT pg_catalog.setval('pb3gir75kkooyea.login_request_nc_id_seq', 1, false);


--
-- Name: mapping_exception_nc_id_seq; Type: SEQUENCE SET; Schema: pb3gir75kkooyea; Owner: admin
--

SELECT pg_catalog.setval('pb3gir75kkooyea.mapping_exception_nc_id_seq', 8, true);


--
-- Name: message_nc_id_seq; Type: SEQUENCE SET; Schema: pb3gir75kkooyea; Owner: admin
--

SELECT pg_catalog.setval('pb3gir75kkooyea.message_nc_id_seq', 66, true);


--
-- Name: message_recipient_nc_id_seq; Type: SEQUENCE SET; Schema: pb3gir75kkooyea; Owner: admin
--

SELECT pg_catalog.setval('pb3gir75kkooyea.message_recipient_nc_id_seq', 69, true);


--
-- Name: monitor_status_nc_id_seq; Type: SEQUENCE SET; Schema: pb3gir75kkooyea; Owner: admin
--

SELECT pg_catalog.setval('pb3gir75kkooyea.monitor_status_nc_id_seq', 17, true);


--
-- Name: portal_permission_nc_id_seq; Type: SEQUENCE SET; Schema: pb3gir75kkooyea; Owner: admin
--

SELECT pg_catalog.setval('pb3gir75kkooyea.portal_permission_nc_id_seq', 6, true);


--
-- Name: portal_role_nc_id_seq; Type: SEQUENCE SET; Schema: pb3gir75kkooyea; Owner: admin
--

SELECT pg_catalog.setval('pb3gir75kkooyea.portal_role_nc_id_seq', 3, true);


--
-- Name: portal_role_permission_nc_id_seq; Type: SEQUENCE SET; Schema: pb3gir75kkooyea; Owner: admin
--

SELECT pg_catalog.setval('pb3gir75kkooyea.portal_role_permission_nc_id_seq', 7, true);


--
-- Name: portal_session_nc_id_seq; Type: SEQUENCE SET; Schema: pb3gir75kkooyea; Owner: admin
--

SELECT pg_catalog.setval('pb3gir75kkooyea.portal_session_nc_id_seq', 1, false);


--
-- Name: portal_user_application_scope_nc_id_seq; Type: SEQUENCE SET; Schema: pb3gir75kkooyea; Owner: admin
--

SELECT pg_catalog.setval('pb3gir75kkooyea.portal_user_application_scope_nc_id_seq', 32, true);


--
-- Name: portal_user_role_nc_id_seq; Type: SEQUENCE SET; Schema: pb3gir75kkooyea; Owner: admin
--

SELECT pg_catalog.setval('pb3gir75kkooyea.portal_user_role_nc_id_seq', 5, true);


--
-- Name: push_integration_config_nc_id_seq; Type: SEQUENCE SET; Schema: pb3gir75kkooyea; Owner: admin
--

SELECT pg_catalog.setval('pb3gir75kkooyea.push_integration_config_nc_id_seq', 169, true);


--
-- Name: sms_application_nc_id_seq; Type: SEQUENCE SET; Schema: pb3gir75kkooyea; Owner: admin
--

SELECT pg_catalog.setval('pb3gir75kkooyea.sms_application_nc_id_seq', 1, false);


--
-- Name: sms_application_template_nc_id_seq; Type: SEQUENCE SET; Schema: pb3gir75kkooyea; Owner: admin
--

SELECT pg_catalog.setval('pb3gir75kkooyea.sms_application_template_nc_id_seq', 1, false);


--
-- Name: sms_channel_nc_id_seq; Type: SEQUENCE SET; Schema: pb3gir75kkooyea; Owner: admin
--

SELECT pg_catalog.setval('pb3gir75kkooyea.sms_channel_nc_id_seq', 1, false);


--
-- Name: sms_send_attempt_nc_id_seq; Type: SEQUENCE SET; Schema: pb3gir75kkooyea; Owner: admin
--

SELECT pg_catalog.setval('pb3gir75kkooyea.sms_send_attempt_nc_id_seq', 1, false);


--
-- Name: sms_send_record_nc_id_seq; Type: SEQUENCE SET; Schema: pb3gir75kkooyea; Owner: admin
--

SELECT pg_catalog.setval('pb3gir75kkooyea.sms_send_record_nc_id_seq', 1, false);


--
-- Name: sms_template_nc_id_seq; Type: SEQUENCE SET; Schema: pb3gir75kkooyea; Owner: admin
--

SELECT pg_catalog.setval('pb3gir75kkooyea.sms_template_nc_id_seq', 1, false);


--
-- Name: sso_config_nc_id_seq; Type: SEQUENCE SET; Schema: pb3gir75kkooyea; Owner: admin
--

SELECT pg_catalog.setval('pb3gir75kkooyea.sso_config_nc_id_seq', 84, true);


--
-- Name: system_config_nc_id_seq; Type: SEQUENCE SET; Schema: pb3gir75kkooyea; Owner: admin
--

SELECT pg_catalog.setval('pb3gir75kkooyea.system_config_nc_id_seq', 41, true);


--
-- Name: todo_item_nc_id_seq; Type: SEQUENCE SET; Schema: pb3gir75kkooyea; Owner: admin
--

SELECT pg_catalog.setval('pb3gir75kkooyea.todo_item_nc_id_seq', 47, true);


--
-- Name: unified_user_nc_id_seq; Type: SEQUENCE SET; Schema: pb3gir75kkooyea; Owner: admin
--

SELECT pg_catalog.setval('pb3gir75kkooyea.unified_user_nc_id_seq', 8, true);


--
-- Name: account_opening_request account_opening_request_pkey; Type: CONSTRAINT; Schema: pb3gir75kkooyea; Owner: admin
--

ALTER TABLE ONLY pb3gir75kkooyea.account_opening_request
    ADD CONSTRAINT account_opening_request_pkey PRIMARY KEY (id);


--
-- Name: account_opening_request account_opening_request_request_no_key; Type: CONSTRAINT; Schema: pb3gir75kkooyea; Owner: admin
--

ALTER TABLE ONLY pb3gir75kkooyea.account_opening_request
    ADD CONSTRAINT account_opening_request_request_no_key UNIQUE (request_no);


--
-- Name: account_opening_request account_opening_request_runtime_id_key; Type: CONSTRAINT; Schema: pb3gir75kkooyea; Owner: admin
--

ALTER TABLE ONLY pb3gir75kkooyea.account_opening_request
    ADD CONSTRAINT account_opening_request_runtime_id_key UNIQUE (runtime_id);


--
-- Name: announcement_attachment announcement_attachment_pkey; Type: CONSTRAINT; Schema: pb3gir75kkooyea; Owner: admin
--

ALTER TABLE ONLY pb3gir75kkooyea.announcement_attachment
    ADD CONSTRAINT announcement_attachment_pkey PRIMARY KEY (nc_id);


--
-- Name: announcement_org_scope announcement_org_scope_pkey; Type: CONSTRAINT; Schema: pb3gir75kkooyea; Owner: admin
--

ALTER TABLE ONLY pb3gir75kkooyea.announcement_org_scope
    ADD CONSTRAINT announcement_org_scope_pkey PRIMARY KEY (nc_id);


--
-- Name: announcement announcement_pkey; Type: CONSTRAINT; Schema: pb3gir75kkooyea; Owner: admin
--

ALTER TABLE ONLY pb3gir75kkooyea.announcement
    ADD CONSTRAINT announcement_pkey PRIMARY KEY (nc_id);


--
-- Name: announcement_read_receipt announcement_read_receipt_announcement_id_user_id_key; Type: CONSTRAINT; Schema: pb3gir75kkooyea; Owner: admin
--

ALTER TABLE ONLY pb3gir75kkooyea.announcement_read_receipt
    ADD CONSTRAINT announcement_read_receipt_announcement_id_user_id_key UNIQUE (announcement_id, user_id);


--
-- Name: announcement_read_receipt announcement_read_receipt_pkey; Type: CONSTRAINT; Schema: pb3gir75kkooyea; Owner: admin
--

ALTER TABLE ONLY pb3gir75kkooyea.announcement_read_receipt
    ADD CONSTRAINT announcement_read_receipt_pkey PRIMARY KEY (id);


--
-- Name: application_access_grant application_access_grant_pkey; Type: CONSTRAINT; Schema: pb3gir75kkooyea; Owner: admin
--

ALTER TABLE ONLY pb3gir75kkooyea.application_access_grant
    ADD CONSTRAINT application_access_grant_pkey PRIMARY KEY (id);


--
-- Name: application_access_grant application_access_grant_runtime_id_key; Type: CONSTRAINT; Schema: pb3gir75kkooyea; Owner: admin
--

ALTER TABLE ONLY pb3gir75kkooyea.application_access_grant
    ADD CONSTRAINT application_access_grant_runtime_id_key UNIQUE (runtime_id);


--
-- Name: application_access_request application_access_request_pkey; Type: CONSTRAINT; Schema: pb3gir75kkooyea; Owner: admin
--

ALTER TABLE ONLY pb3gir75kkooyea.application_access_request
    ADD CONSTRAINT application_access_request_pkey PRIMARY KEY (id);


--
-- Name: application_access_request application_access_request_request_no_key; Type: CONSTRAINT; Schema: pb3gir75kkooyea; Owner: admin
--

ALTER TABLE ONLY pb3gir75kkooyea.application_access_request
    ADD CONSTRAINT application_access_request_request_no_key UNIQUE (request_no);


--
-- Name: application_access_request application_access_request_runtime_id_key; Type: CONSTRAINT; Schema: pb3gir75kkooyea; Owner: admin
--

ALTER TABLE ONLY pb3gir75kkooyea.application_access_request
    ADD CONSTRAINT application_access_request_runtime_id_key UNIQUE (runtime_id);


--
-- Name: application_category application_category_pkey; Type: CONSTRAINT; Schema: pb3gir75kkooyea; Owner: admin
--

ALTER TABLE ONLY pb3gir75kkooyea.application_category
    ADD CONSTRAINT application_category_pkey PRIMARY KEY (nc_id);


--
-- Name: application application_pkey; Type: CONSTRAINT; Schema: pb3gir75kkooyea; Owner: admin
--

ALTER TABLE ONLY pb3gir75kkooyea.application
    ADD CONSTRAINT application_pkey PRIMARY KEY (nc_id);


--
-- Name: application_user_mapping application_user_mapping_pkey; Type: CONSTRAINT; Schema: pb3gir75kkooyea; Owner: admin
--

ALTER TABLE ONLY pb3gir75kkooyea.application_user_mapping
    ADD CONSTRAINT application_user_mapping_pkey PRIMARY KEY (nc_id);


--
-- Name: audit_event audit_event_pkey; Type: CONSTRAINT; Schema: pb3gir75kkooyea; Owner: admin
--

ALTER TABLE ONLY pb3gir75kkooyea.audit_event
    ADD CONSTRAINT audit_event_pkey PRIMARY KEY (nc_id);


--
-- Name: identity_mapping identity_mapping_pkey; Type: CONSTRAINT; Schema: pb3gir75kkooyea; Owner: admin
--

ALTER TABLE ONLY pb3gir75kkooyea.identity_mapping
    ADD CONSTRAINT identity_mapping_pkey PRIMARY KEY (nc_id);


--
-- Name: identity_source identity_source_pkey; Type: CONSTRAINT; Schema: pb3gir75kkooyea; Owner: admin
--

ALTER TABLE ONLY pb3gir75kkooyea.identity_source
    ADD CONSTRAINT identity_source_pkey PRIMARY KEY (nc_id);


--
-- Name: ingest_receipt ingest_receipt_pkey; Type: CONSTRAINT; Schema: pb3gir75kkooyea; Owner: admin
--

ALTER TABLE ONLY pb3gir75kkooyea.ingest_receipt
    ADD CONSTRAINT ingest_receipt_pkey PRIMARY KEY (nc_id);


--
-- Name: login_request login_request_pkey; Type: CONSTRAINT; Schema: pb3gir75kkooyea; Owner: admin
--

ALTER TABLE ONLY pb3gir75kkooyea.login_request
    ADD CONSTRAINT login_request_pkey PRIMARY KEY (nc_id);


--
-- Name: mapping_exception mapping_exception_pkey; Type: CONSTRAINT; Schema: pb3gir75kkooyea; Owner: admin
--

ALTER TABLE ONLY pb3gir75kkooyea.mapping_exception
    ADD CONSTRAINT mapping_exception_pkey PRIMARY KEY (nc_id);


--
-- Name: message message_pkey; Type: CONSTRAINT; Schema: pb3gir75kkooyea; Owner: admin
--

ALTER TABLE ONLY pb3gir75kkooyea.message
    ADD CONSTRAINT message_pkey PRIMARY KEY (nc_id);


--
-- Name: message_recipient message_recipient_pkey; Type: CONSTRAINT; Schema: pb3gir75kkooyea; Owner: admin
--

ALTER TABLE ONLY pb3gir75kkooyea.message_recipient
    ADD CONSTRAINT message_recipient_pkey PRIMARY KEY (nc_id);


--
-- Name: monitor_status monitor_status_pkey; Type: CONSTRAINT; Schema: pb3gir75kkooyea; Owner: admin
--

ALTER TABLE ONLY pb3gir75kkooyea.monitor_status
    ADD CONSTRAINT monitor_status_pkey PRIMARY KEY (nc_id);


--
-- Name: announcement p3_announcement_a250906e4337; Type: CONSTRAINT; Schema: pb3gir75kkooyea; Owner: admin
--

ALTER TABLE ONLY pb3gir75kkooyea.announcement
    ADD CONSTRAINT p3_announcement_a250906e4337 UNIQUE (id);


--
-- Name: CONSTRAINT p3_announcement_a250906e4337 ON announcement; Type: COMMENT; Schema: pb3gir75kkooyea; Owner: admin
--

COMMENT ON CONSTRAINT p3_announcement_a250906e4337 ON pb3gir75kkooyea.announcement IS 'P3|a250906e4337abf4df558954285b1200c76114257155a6dab0109fb59164f683|UNIQUE (id)';


--
-- Name: announcement_attachment p3_announcement_attachment_a663f3d9f066; Type: CONSTRAINT; Schema: pb3gir75kkooyea; Owner: admin
--

ALTER TABLE ONLY pb3gir75kkooyea.announcement_attachment
    ADD CONSTRAINT p3_announcement_attachment_a663f3d9f066 UNIQUE (id);


--
-- Name: CONSTRAINT p3_announcement_attachment_a663f3d9f066 ON announcement_attachment; Type: COMMENT; Schema: pb3gir75kkooyea; Owner: admin
--

COMMENT ON CONSTRAINT p3_announcement_attachment_a663f3d9f066 ON pb3gir75kkooyea.announcement_attachment IS 'P3|a663f3d9f0667d84cbee201bbdf6fc4f83f57563e673e178f72bb189c6a2205d|UNIQUE (id)';


--
-- Name: announcement_org_scope p3_announcement_org_scope_307d02cc271d; Type: CONSTRAINT; Schema: pb3gir75kkooyea; Owner: admin
--

ALTER TABLE ONLY pb3gir75kkooyea.announcement_org_scope
    ADD CONSTRAINT p3_announcement_org_scope_307d02cc271d UNIQUE (id);


--
-- Name: CONSTRAINT p3_announcement_org_scope_307d02cc271d ON announcement_org_scope; Type: COMMENT; Schema: pb3gir75kkooyea; Owner: admin
--

COMMENT ON CONSTRAINT p3_announcement_org_scope_307d02cc271d ON pb3gir75kkooyea.announcement_org_scope IS 'P3|307d02cc271d359ea4f9260199d66a9572e3a2f6b7e2a092d3672390eebe425f|UNIQUE (id)';


--
-- Name: announcement_org_scope p3_announcement_org_scope_3e1139d22213; Type: CONSTRAINT; Schema: pb3gir75kkooyea; Owner: admin
--

ALTER TABLE ONLY pb3gir75kkooyea.announcement_org_scope
    ADD CONSTRAINT p3_announcement_org_scope_3e1139d22213 UNIQUE (announcement_id, identity_source_code, org_key);


--
-- Name: CONSTRAINT p3_announcement_org_scope_3e1139d22213 ON announcement_org_scope; Type: COMMENT; Schema: pb3gir75kkooyea; Owner: admin
--

COMMENT ON CONSTRAINT p3_announcement_org_scope_3e1139d22213 ON pb3gir75kkooyea.announcement_org_scope IS 'P3|3e1139d22213805c44d9dbe76258696d9523cbf2d1c782cc1ec909f01dc82f05|UNIQUE (announcement_id, identity_source_code, org_key)';


--
-- Name: application p3_application_4fde16c08d4f; Type: CONSTRAINT; Schema: pb3gir75kkooyea; Owner: admin
--

ALTER TABLE ONLY pb3gir75kkooyea.application
    ADD CONSTRAINT p3_application_4fde16c08d4f UNIQUE (id);


--
-- Name: CONSTRAINT p3_application_4fde16c08d4f ON application; Type: COMMENT; Schema: pb3gir75kkooyea; Owner: admin
--

COMMENT ON CONSTRAINT p3_application_4fde16c08d4f ON pb3gir75kkooyea.application IS 'P3|4fde16c08d4f9eb3cbaf24907474660b48021a4a2bffc60ab29349388f191fa3|UNIQUE (id)';


--
-- Name: application_category p3_application_category_3cf1121643dc; Type: CONSTRAINT; Schema: pb3gir75kkooyea; Owner: admin
--

ALTER TABLE ONLY pb3gir75kkooyea.application_category
    ADD CONSTRAINT p3_application_category_3cf1121643dc UNIQUE (id);


--
-- Name: CONSTRAINT p3_application_category_3cf1121643dc ON application_category; Type: COMMENT; Schema: pb3gir75kkooyea; Owner: admin
--

COMMENT ON CONSTRAINT p3_application_category_3cf1121643dc ON pb3gir75kkooyea.application_category IS 'P3|3cf1121643dc1a05652f8d4babfb65d23616ca140fc88e3f4c34ae7d2b3419cc|UNIQUE (id)';


--
-- Name: application_category p3_application_category_da6cb970b128; Type: CONSTRAINT; Schema: pb3gir75kkooyea; Owner: admin
--

ALTER TABLE ONLY pb3gir75kkooyea.application_category
    ADD CONSTRAINT p3_application_category_da6cb970b128 UNIQUE (code);


--
-- Name: CONSTRAINT p3_application_category_da6cb970b128 ON application_category; Type: COMMENT; Schema: pb3gir75kkooyea; Owner: admin
--

COMMENT ON CONSTRAINT p3_application_category_da6cb970b128 ON pb3gir75kkooyea.application_category IS 'P3|da6cb970b1281f30cf23e4d3d2bed8b02e7a96a1c82aaf5f81c93dfc2e6f04ad|UNIQUE (code)';


--
-- Name: application p3_application_cfb451ab6703; Type: CONSTRAINT; Schema: pb3gir75kkooyea; Owner: admin
--

ALTER TABLE ONLY pb3gir75kkooyea.application
    ADD CONSTRAINT p3_application_cfb451ab6703 UNIQUE (code);


--
-- Name: CONSTRAINT p3_application_cfb451ab6703 ON application; Type: COMMENT; Schema: pb3gir75kkooyea; Owner: admin
--

COMMENT ON CONSTRAINT p3_application_cfb451ab6703 ON pb3gir75kkooyea.application IS 'P3|cfb451ab67031f777c583c74000a3145d7c0bb6a5b7e355d9431ebb6b56c2d9e|UNIQUE (code)';


--
-- Name: application_user_mapping p3_application_user_mapping_35c1daeac504; Type: CONSTRAINT; Schema: pb3gir75kkooyea; Owner: admin
--

ALTER TABLE ONLY pb3gir75kkooyea.application_user_mapping
    ADD CONSTRAINT p3_application_user_mapping_35c1daeac504 UNIQUE (id);


--
-- Name: CONSTRAINT p3_application_user_mapping_35c1daeac504 ON application_user_mapping; Type: COMMENT; Schema: pb3gir75kkooyea; Owner: admin
--

COMMENT ON CONSTRAINT p3_application_user_mapping_35c1daeac504 ON pb3gir75kkooyea.application_user_mapping IS 'P3|35c1daeac504cf5532058567db95b8d4dc0ccafd6cd9c7703a2e972151ce1bd5|UNIQUE (id)';


--
-- Name: application_user_mapping p3_application_user_mapping_831b242929dc; Type: CONSTRAINT; Schema: pb3gir75kkooyea; Owner: admin
--

ALTER TABLE ONLY pb3gir75kkooyea.application_user_mapping
    ADD CONSTRAINT p3_application_user_mapping_831b242929dc UNIQUE (user_id, application_id);


--
-- Name: CONSTRAINT p3_application_user_mapping_831b242929dc ON application_user_mapping; Type: COMMENT; Schema: pb3gir75kkooyea; Owner: admin
--

COMMENT ON CONSTRAINT p3_application_user_mapping_831b242929dc ON pb3gir75kkooyea.application_user_mapping IS 'P3|831b242929dc2fbca7faf401d96f3a4a657444e4613d533e9a2858ccd132c2d3|UNIQUE (user_id, application_id)';


--
-- Name: application_user_mapping p3_application_user_mapping_d8bb35ef9764; Type: CONSTRAINT; Schema: pb3gir75kkooyea; Owner: admin
--

ALTER TABLE ONLY pb3gir75kkooyea.application_user_mapping
    ADD CONSTRAINT p3_application_user_mapping_d8bb35ef9764 UNIQUE (active_account_key);


--
-- Name: CONSTRAINT p3_application_user_mapping_d8bb35ef9764 ON application_user_mapping; Type: COMMENT; Schema: pb3gir75kkooyea; Owner: admin
--

COMMENT ON CONSTRAINT p3_application_user_mapping_d8bb35ef9764 ON pb3gir75kkooyea.application_user_mapping IS 'P3|d8bb35ef976420cd37422fc91248bd637d3a1be9226917936a7299872536e85c|UNIQUE (active_account_key)';


--
-- Name: audit_event p3_audit_event_2acaa08eee72; Type: CONSTRAINT; Schema: pb3gir75kkooyea; Owner: admin
--

ALTER TABLE ONLY pb3gir75kkooyea.audit_event
    ADD CONSTRAINT p3_audit_event_2acaa08eee72 UNIQUE (id);


--
-- Name: CONSTRAINT p3_audit_event_2acaa08eee72 ON audit_event; Type: COMMENT; Schema: pb3gir75kkooyea; Owner: admin
--

COMMENT ON CONSTRAINT p3_audit_event_2acaa08eee72 ON pb3gir75kkooyea.audit_event IS 'P3|2acaa08eee72439ec3f51805c4c9815134df2095aae9a2c7a0d895173b6b3e07|UNIQUE (id)';


--
-- Name: identity_mapping p3_identity_mapping_18a8dd026e70; Type: CONSTRAINT; Schema: pb3gir75kkooyea; Owner: admin
--

ALTER TABLE ONLY pb3gir75kkooyea.identity_mapping
    ADD CONSTRAINT p3_identity_mapping_18a8dd026e70 UNIQUE (id);


--
-- Name: CONSTRAINT p3_identity_mapping_18a8dd026e70 ON identity_mapping; Type: COMMENT; Schema: pb3gir75kkooyea; Owner: admin
--

COMMENT ON CONSTRAINT p3_identity_mapping_18a8dd026e70 ON pb3gir75kkooyea.identity_mapping IS 'P3|18a8dd026e70c674855145a7ac2c29a757f1fd46d5a416858362832a8d0293d6|UNIQUE (id)';


--
-- Name: identity_mapping p3_identity_mapping_f67d97f97d43; Type: CONSTRAINT; Schema: pb3gir75kkooyea; Owner: admin
--

ALTER TABLE ONLY pb3gir75kkooyea.identity_mapping
    ADD CONSTRAINT p3_identity_mapping_f67d97f97d43 UNIQUE (source_id, external_subject_id);


--
-- Name: CONSTRAINT p3_identity_mapping_f67d97f97d43 ON identity_mapping; Type: COMMENT; Schema: pb3gir75kkooyea; Owner: admin
--

COMMENT ON CONSTRAINT p3_identity_mapping_f67d97f97d43 ON pb3gir75kkooyea.identity_mapping IS 'P3|f67d97f97d43cd9b3c0a5c8f7e31bb2566ee8dd7a89461b8397f997ddfa33fda|UNIQUE (source_id, external_subject_id)';


--
-- Name: identity_source p3_identity_source_0689a114a9d6; Type: CONSTRAINT; Schema: pb3gir75kkooyea; Owner: admin
--

ALTER TABLE ONLY pb3gir75kkooyea.identity_source
    ADD CONSTRAINT p3_identity_source_0689a114a9d6 UNIQUE (code);


--
-- Name: CONSTRAINT p3_identity_source_0689a114a9d6 ON identity_source; Type: COMMENT; Schema: pb3gir75kkooyea; Owner: admin
--

COMMENT ON CONSTRAINT p3_identity_source_0689a114a9d6 ON pb3gir75kkooyea.identity_source IS 'P3|0689a114a9d6b0685cc585b0edf48990f665522b00d69668642f35172dfbd830|UNIQUE (code)';


--
-- Name: identity_source p3_identity_source_e4df2443e152; Type: CONSTRAINT; Schema: pb3gir75kkooyea; Owner: admin
--

ALTER TABLE ONLY pb3gir75kkooyea.identity_source
    ADD CONSTRAINT p3_identity_source_e4df2443e152 UNIQUE (id);


--
-- Name: CONSTRAINT p3_identity_source_e4df2443e152 ON identity_source; Type: COMMENT; Schema: pb3gir75kkooyea; Owner: admin
--

COMMENT ON CONSTRAINT p3_identity_source_e4df2443e152 ON pb3gir75kkooyea.identity_source IS 'P3|e4df2443e1526b709e7a190b0baa8cc099868ec3799569f39b2d728497746297|UNIQUE (id)';


--
-- Name: ingest_receipt p3_ingest_receipt_93ebcd8ab9c9; Type: CONSTRAINT; Schema: pb3gir75kkooyea; Owner: admin
--

ALTER TABLE ONLY pb3gir75kkooyea.ingest_receipt
    ADD CONSTRAINT p3_ingest_receipt_93ebcd8ab9c9 UNIQUE (id);


--
-- Name: CONSTRAINT p3_ingest_receipt_93ebcd8ab9c9 ON ingest_receipt; Type: COMMENT; Schema: pb3gir75kkooyea; Owner: admin
--

COMMENT ON CONSTRAINT p3_ingest_receipt_93ebcd8ab9c9 ON pb3gir75kkooyea.ingest_receipt IS 'P3|93ebcd8ab9c946fb6bd9406c86c59748aa8658401d1ef94386fdf9cf64cdafbe|UNIQUE (id)';


--
-- Name: ingest_receipt p3_ingest_receipt_e57c61d00ca9; Type: CONSTRAINT; Schema: pb3gir75kkooyea; Owner: admin
--

ALTER TABLE ONLY pb3gir75kkooyea.ingest_receipt
    ADD CONSTRAINT p3_ingest_receipt_e57c61d00ca9 UNIQUE (application_id, kind, event_id);


--
-- Name: CONSTRAINT p3_ingest_receipt_e57c61d00ca9 ON ingest_receipt; Type: COMMENT; Schema: pb3gir75kkooyea; Owner: admin
--

COMMENT ON CONSTRAINT p3_ingest_receipt_e57c61d00ca9 ON pb3gir75kkooyea.ingest_receipt IS 'P3|e57c61d00ca9dfdad0a121137d207ad7f83e98f13b4f57e8d15fb8664c9d20e5|UNIQUE (application_id, kind, event_id)';


--
-- Name: login_request p3_login_request_46f37df1c326; Type: CONSTRAINT; Schema: pb3gir75kkooyea; Owner: admin
--

ALTER TABLE ONLY pb3gir75kkooyea.login_request
    ADD CONSTRAINT p3_login_request_46f37df1c326 UNIQUE (state_hash);


--
-- Name: CONSTRAINT p3_login_request_46f37df1c326 ON login_request; Type: COMMENT; Schema: pb3gir75kkooyea; Owner: admin
--

COMMENT ON CONSTRAINT p3_login_request_46f37df1c326 ON pb3gir75kkooyea.login_request IS 'P3|46f37df1c326241bed4ac98d7c8b7813fca3ed1bba3bfd0ea32b04e6dceacec3|UNIQUE (state_hash)';


--
-- Name: login_request p3_login_request_a33555e7fbee; Type: CONSTRAINT; Schema: pb3gir75kkooyea; Owner: admin
--

ALTER TABLE ONLY pb3gir75kkooyea.login_request
    ADD CONSTRAINT p3_login_request_a33555e7fbee UNIQUE (id);


--
-- Name: CONSTRAINT p3_login_request_a33555e7fbee ON login_request; Type: COMMENT; Schema: pb3gir75kkooyea; Owner: admin
--

COMMENT ON CONSTRAINT p3_login_request_a33555e7fbee ON pb3gir75kkooyea.login_request IS 'P3|a33555e7fbeefbbc8ccb27ef4aaec612f70c11ee3bd6a8a783fbc2887bd7e179|UNIQUE (id)';


--
-- Name: mapping_exception p3_mapping_exception_c716c437b289; Type: CONSTRAINT; Schema: pb3gir75kkooyea; Owner: admin
--

ALTER TABLE ONLY pb3gir75kkooyea.mapping_exception
    ADD CONSTRAINT p3_mapping_exception_c716c437b289 UNIQUE (id);


--
-- Name: CONSTRAINT p3_mapping_exception_c716c437b289 ON mapping_exception; Type: COMMENT; Schema: pb3gir75kkooyea; Owner: admin
--

COMMENT ON CONSTRAINT p3_mapping_exception_c716c437b289 ON pb3gir75kkooyea.mapping_exception IS 'P3|c716c437b289c77b9ec73a7fd42265a66d58a5886208626eadc2582854c4279e|UNIQUE (id)';


--
-- Name: message p3_message_22411100a0d2; Type: CONSTRAINT; Schema: pb3gir75kkooyea; Owner: admin
--

ALTER TABLE ONLY pb3gir75kkooyea.message
    ADD CONSTRAINT p3_message_22411100a0d2 UNIQUE (id);


--
-- Name: CONSTRAINT p3_message_22411100a0d2 ON message; Type: COMMENT; Schema: pb3gir75kkooyea; Owner: admin
--

COMMENT ON CONSTRAINT p3_message_22411100a0d2 ON pb3gir75kkooyea.message IS 'P3|22411100a0d222cdeaa6dc14478e8fa4385c247c3b0f5eaad001ab9bb3931910|UNIQUE (id)';


--
-- Name: message p3_message_2b2e7968b4af; Type: CONSTRAINT; Schema: pb3gir75kkooyea; Owner: admin
--

ALTER TABLE ONLY pb3gir75kkooyea.message
    ADD CONSTRAINT p3_message_2b2e7968b4af UNIQUE (source_key, source_message_id);


--
-- Name: CONSTRAINT p3_message_2b2e7968b4af ON message; Type: COMMENT; Schema: pb3gir75kkooyea; Owner: admin
--

COMMENT ON CONSTRAINT p3_message_2b2e7968b4af ON pb3gir75kkooyea.message IS 'P3|2b2e7968b4afc51ca18d359b7c84893d6ab8f9efc052c678984e98daa9c45d33|UNIQUE (source_key, source_message_id)';


--
-- Name: message_recipient p3_message_recipient_22cd1ed65436; Type: CONSTRAINT; Schema: pb3gir75kkooyea; Owner: admin
--

ALTER TABLE ONLY pb3gir75kkooyea.message_recipient
    ADD CONSTRAINT p3_message_recipient_22cd1ed65436 UNIQUE (id);


--
-- Name: CONSTRAINT p3_message_recipient_22cd1ed65436 ON message_recipient; Type: COMMENT; Schema: pb3gir75kkooyea; Owner: admin
--

COMMENT ON CONSTRAINT p3_message_recipient_22cd1ed65436 ON pb3gir75kkooyea.message_recipient IS 'P3|22cd1ed65436d05782198bd6838f66bbce88171acd9593f997ca8d1b6e518bb6|UNIQUE (id)';


--
-- Name: message_recipient p3_message_recipient_d26b5196cbee; Type: CONSTRAINT; Schema: pb3gir75kkooyea; Owner: admin
--

ALTER TABLE ONLY pb3gir75kkooyea.message_recipient
    ADD CONSTRAINT p3_message_recipient_d26b5196cbee UNIQUE (message_id, user_id);


--
-- Name: CONSTRAINT p3_message_recipient_d26b5196cbee ON message_recipient; Type: COMMENT; Schema: pb3gir75kkooyea; Owner: admin
--

COMMENT ON CONSTRAINT p3_message_recipient_d26b5196cbee ON pb3gir75kkooyea.message_recipient IS 'P3|d26b5196cbee567c478be14f424d0dfc12598ce8591fd706713030884da6d602|UNIQUE (message_id, user_id)';


--
-- Name: monitor_status p3_monitor_status_09165ceff9be; Type: CONSTRAINT; Schema: pb3gir75kkooyea; Owner: admin
--

ALTER TABLE ONLY pb3gir75kkooyea.monitor_status
    ADD CONSTRAINT p3_monitor_status_09165ceff9be UNIQUE (id);


--
-- Name: CONSTRAINT p3_monitor_status_09165ceff9be ON monitor_status; Type: COMMENT; Schema: pb3gir75kkooyea; Owner: admin
--

COMMENT ON CONSTRAINT p3_monitor_status_09165ceff9be ON pb3gir75kkooyea.monitor_status IS 'P3|09165ceff9be9a9bef130b55bc439f29e36f6a940dfeceb71d2349b39e16378f|UNIQUE (id)';


--
-- Name: monitor_status p3_monitor_status_37a180db4a90; Type: CONSTRAINT; Schema: pb3gir75kkooyea; Owner: admin
--

ALTER TABLE ONLY pb3gir75kkooyea.monitor_status
    ADD CONSTRAINT p3_monitor_status_37a180db4a90 UNIQUE (target_key, service_type);


--
-- Name: CONSTRAINT p3_monitor_status_37a180db4a90 ON monitor_status; Type: COMMENT; Schema: pb3gir75kkooyea; Owner: admin
--

COMMENT ON CONSTRAINT p3_monitor_status_37a180db4a90 ON pb3gir75kkooyea.monitor_status IS 'P3|37a180db4a90cd155c6e4919487902775d5f3e90e66c6305dd150996d2da3066|UNIQUE (target_key, service_type)';


--
-- Name: portal_permission p3_portal_permission_2a594cad779c; Type: CONSTRAINT; Schema: pb3gir75kkooyea; Owner: admin
--

ALTER TABLE ONLY pb3gir75kkooyea.portal_permission
    ADD CONSTRAINT p3_portal_permission_2a594cad779c UNIQUE (id);


--
-- Name: CONSTRAINT p3_portal_permission_2a594cad779c ON portal_permission; Type: COMMENT; Schema: pb3gir75kkooyea; Owner: admin
--

COMMENT ON CONSTRAINT p3_portal_permission_2a594cad779c ON pb3gir75kkooyea.portal_permission IS 'P3|2a594cad779c5aea2bd691f50582f222ed96e8ced1b642c9be685700c2d33886|UNIQUE (id)';


--
-- Name: portal_permission p3_portal_permission_6dc8d2abeefd; Type: CONSTRAINT; Schema: pb3gir75kkooyea; Owner: admin
--

ALTER TABLE ONLY pb3gir75kkooyea.portal_permission
    ADD CONSTRAINT p3_portal_permission_6dc8d2abeefd UNIQUE (code);


--
-- Name: CONSTRAINT p3_portal_permission_6dc8d2abeefd ON portal_permission; Type: COMMENT; Schema: pb3gir75kkooyea; Owner: admin
--

COMMENT ON CONSTRAINT p3_portal_permission_6dc8d2abeefd ON pb3gir75kkooyea.portal_permission IS 'P3|6dc8d2abeefd6d53a6ca09724bc7cbe479d9caa616c1c28acc2c5bb8b2d924dc|UNIQUE (code)';


--
-- Name: portal_role p3_portal_role_4aabf4421a0b; Type: CONSTRAINT; Schema: pb3gir75kkooyea; Owner: admin
--

ALTER TABLE ONLY pb3gir75kkooyea.portal_role
    ADD CONSTRAINT p3_portal_role_4aabf4421a0b UNIQUE (id);


--
-- Name: CONSTRAINT p3_portal_role_4aabf4421a0b ON portal_role; Type: COMMENT; Schema: pb3gir75kkooyea; Owner: admin
--

COMMENT ON CONSTRAINT p3_portal_role_4aabf4421a0b ON pb3gir75kkooyea.portal_role IS 'P3|4aabf4421a0bebe1e8e524df6eb3be0b7a9571c7485d73507b99e388b6b210ce|UNIQUE (id)';


--
-- Name: portal_role p3_portal_role_da9dde266d41; Type: CONSTRAINT; Schema: pb3gir75kkooyea; Owner: admin
--

ALTER TABLE ONLY pb3gir75kkooyea.portal_role
    ADD CONSTRAINT p3_portal_role_da9dde266d41 UNIQUE (code);


--
-- Name: CONSTRAINT p3_portal_role_da9dde266d41 ON portal_role; Type: COMMENT; Schema: pb3gir75kkooyea; Owner: admin
--

COMMENT ON CONSTRAINT p3_portal_role_da9dde266d41 ON pb3gir75kkooyea.portal_role IS 'P3|da9dde266d41e1ad64358b3bfc27f471131bdabb824f7b1a57b98db283da5bea|UNIQUE (code)';


--
-- Name: portal_role_permission p3_portal_role_permission_474fa22bd913; Type: CONSTRAINT; Schema: pb3gir75kkooyea; Owner: admin
--

ALTER TABLE ONLY pb3gir75kkooyea.portal_role_permission
    ADD CONSTRAINT p3_portal_role_permission_474fa22bd913 UNIQUE (role_id, permission_id);


--
-- Name: CONSTRAINT p3_portal_role_permission_474fa22bd913 ON portal_role_permission; Type: COMMENT; Schema: pb3gir75kkooyea; Owner: admin
--

COMMENT ON CONSTRAINT p3_portal_role_permission_474fa22bd913 ON pb3gir75kkooyea.portal_role_permission IS 'P3|474fa22bd913aefa4863cbfe7fe9da171c90927def403c2873d53a75365ca325|UNIQUE (role_id, permission_id)';


--
-- Name: portal_role_permission p3_portal_role_permission_49169e28ed77; Type: CONSTRAINT; Schema: pb3gir75kkooyea; Owner: admin
--

ALTER TABLE ONLY pb3gir75kkooyea.portal_role_permission
    ADD CONSTRAINT p3_portal_role_permission_49169e28ed77 UNIQUE (id);


--
-- Name: CONSTRAINT p3_portal_role_permission_49169e28ed77 ON portal_role_permission; Type: COMMENT; Schema: pb3gir75kkooyea; Owner: admin
--

COMMENT ON CONSTRAINT p3_portal_role_permission_49169e28ed77 ON pb3gir75kkooyea.portal_role_permission IS 'P3|49169e28ed77ca8a6cb7c12491ee9f92d82769458b1da7149565f5a85e0595e1|UNIQUE (id)';


--
-- Name: portal_session p3_portal_session_92e3b4512417; Type: CONSTRAINT; Schema: pb3gir75kkooyea; Owner: admin
--

ALTER TABLE ONLY pb3gir75kkooyea.portal_session
    ADD CONSTRAINT p3_portal_session_92e3b4512417 UNIQUE (token_hash);


--
-- Name: CONSTRAINT p3_portal_session_92e3b4512417 ON portal_session; Type: COMMENT; Schema: pb3gir75kkooyea; Owner: admin
--

COMMENT ON CONSTRAINT p3_portal_session_92e3b4512417 ON pb3gir75kkooyea.portal_session IS 'P3|92e3b4512417ec00726a339f657894376385bd253b8cd38a57f7e02018b6e5bf|UNIQUE (token_hash)';


--
-- Name: portal_session p3_portal_session_cba190749d74; Type: CONSTRAINT; Schema: pb3gir75kkooyea; Owner: admin
--

ALTER TABLE ONLY pb3gir75kkooyea.portal_session
    ADD CONSTRAINT p3_portal_session_cba190749d74 UNIQUE (id);


--
-- Name: CONSTRAINT p3_portal_session_cba190749d74 ON portal_session; Type: COMMENT; Schema: pb3gir75kkooyea; Owner: admin
--

COMMENT ON CONSTRAINT p3_portal_session_cba190749d74 ON pb3gir75kkooyea.portal_session IS 'P3|cba190749d747021c69bbf29f61ccc57db1c94b3865eff1cfae0b76da5b95e0c|UNIQUE (id)';


--
-- Name: portal_user_application_scope p3_portal_user_application_scop_22bc7933b010; Type: CONSTRAINT; Schema: pb3gir75kkooyea; Owner: admin
--

ALTER TABLE ONLY pb3gir75kkooyea.portal_user_application_scope
    ADD CONSTRAINT p3_portal_user_application_scop_22bc7933b010 UNIQUE (id);


--
-- Name: CONSTRAINT p3_portal_user_application_scop_22bc7933b010 ON portal_user_application_scope; Type: COMMENT; Schema: pb3gir75kkooyea; Owner: admin
--

COMMENT ON CONSTRAINT p3_portal_user_application_scop_22bc7933b010 ON pb3gir75kkooyea.portal_user_application_scope IS 'P3|22bc7933b010072b3d832a242fa013a04db3f7c9582a6d0bbf998b1474a9138d|UNIQUE (id)';


--
-- Name: portal_user_application_scope p3_portal_user_application_scop_4bc9026941f0; Type: CONSTRAINT; Schema: pb3gir75kkooyea; Owner: admin
--

ALTER TABLE ONLY pb3gir75kkooyea.portal_user_application_scope
    ADD CONSTRAINT p3_portal_user_application_scop_4bc9026941f0 UNIQUE (user_id, application_id);


--
-- Name: CONSTRAINT p3_portal_user_application_scop_4bc9026941f0 ON portal_user_application_scope; Type: COMMENT; Schema: pb3gir75kkooyea; Owner: admin
--

COMMENT ON CONSTRAINT p3_portal_user_application_scop_4bc9026941f0 ON pb3gir75kkooyea.portal_user_application_scope IS 'P3|4bc9026941f068fe192a37a1a9142b89f6f35c09267011b5e8e491ea5a1da8bb|UNIQUE (user_id, application_id)';


--
-- Name: portal_user_role p3_portal_user_role_305fe4923b3d; Type: CONSTRAINT; Schema: pb3gir75kkooyea; Owner: admin
--

ALTER TABLE ONLY pb3gir75kkooyea.portal_user_role
    ADD CONSTRAINT p3_portal_user_role_305fe4923b3d UNIQUE (id);


--
-- Name: CONSTRAINT p3_portal_user_role_305fe4923b3d ON portal_user_role; Type: COMMENT; Schema: pb3gir75kkooyea; Owner: admin
--

COMMENT ON CONSTRAINT p3_portal_user_role_305fe4923b3d ON pb3gir75kkooyea.portal_user_role IS 'P3|305fe4923b3d1feb4297aea110766d9a7a0021cb6d26e49c7f7506c50b65b7b7|UNIQUE (id)';


--
-- Name: portal_user_role p3_portal_user_role_5001293f8b94; Type: CONSTRAINT; Schema: pb3gir75kkooyea; Owner: admin
--

ALTER TABLE ONLY pb3gir75kkooyea.portal_user_role
    ADD CONSTRAINT p3_portal_user_role_5001293f8b94 UNIQUE (user_id, role_id);


--
-- Name: CONSTRAINT p3_portal_user_role_5001293f8b94 ON portal_user_role; Type: COMMENT; Schema: pb3gir75kkooyea; Owner: admin
--

COMMENT ON CONSTRAINT p3_portal_user_role_5001293f8b94 ON pb3gir75kkooyea.portal_user_role IS 'P3|5001293f8b94aa61ea3596bad4b478e3bfc4551b28e20a22207fd05f70352dcb|UNIQUE (user_id, role_id)';


--
-- Name: push_integration_config p3_push_integration_config_a4fff4f61105; Type: CONSTRAINT; Schema: pb3gir75kkooyea; Owner: admin
--

ALTER TABLE ONLY pb3gir75kkooyea.push_integration_config
    ADD CONSTRAINT p3_push_integration_config_a4fff4f61105 UNIQUE (id);


--
-- Name: CONSTRAINT p3_push_integration_config_a4fff4f61105 ON push_integration_config; Type: COMMENT; Schema: pb3gir75kkooyea; Owner: admin
--

COMMENT ON CONSTRAINT p3_push_integration_config_a4fff4f61105 ON pb3gir75kkooyea.push_integration_config IS 'P3|a4fff4f61105001cee4f95735e6ce80e6643af8be65324a49308843ea9fb6d7d|UNIQUE (id)';


--
-- Name: push_integration_config p3_push_integration_config_f0dd808cdefb; Type: CONSTRAINT; Schema: pb3gir75kkooyea; Owner: admin
--

ALTER TABLE ONLY pb3gir75kkooyea.push_integration_config
    ADD CONSTRAINT p3_push_integration_config_f0dd808cdefb UNIQUE (application_id, kind);


--
-- Name: CONSTRAINT p3_push_integration_config_f0dd808cdefb ON push_integration_config; Type: COMMENT; Schema: pb3gir75kkooyea; Owner: admin
--

COMMENT ON CONSTRAINT p3_push_integration_config_f0dd808cdefb ON pb3gir75kkooyea.push_integration_config IS 'P3|f0dd808cdefb35d01e55287817f31fe53877f28f9666b93c20765eb45f740fee|UNIQUE (application_id, kind)';


--
-- Name: sms_application p3_sms_application_5dec0cff8db2; Type: CONSTRAINT; Schema: pb3gir75kkooyea; Owner: admin
--

ALTER TABLE ONLY pb3gir75kkooyea.sms_application
    ADD CONSTRAINT p3_sms_application_5dec0cff8db2 UNIQUE (application_id);


--
-- Name: CONSTRAINT p3_sms_application_5dec0cff8db2 ON sms_application; Type: COMMENT; Schema: pb3gir75kkooyea; Owner: admin
--

COMMENT ON CONSTRAINT p3_sms_application_5dec0cff8db2 ON pb3gir75kkooyea.sms_application IS 'P3|5dec0cff8db2d40f84fcb11c576c4ebaa2e6dc9fb52f1692edfdc32e4942bcbd|UNIQUE (application_id)';


--
-- Name: sms_application p3_sms_application_746ded36f494; Type: CONSTRAINT; Schema: pb3gir75kkooyea; Owner: admin
--

ALTER TABLE ONLY pb3gir75kkooyea.sms_application
    ADD CONSTRAINT p3_sms_application_746ded36f494 UNIQUE (id);


--
-- Name: CONSTRAINT p3_sms_application_746ded36f494 ON sms_application; Type: COMMENT; Schema: pb3gir75kkooyea; Owner: admin
--

COMMENT ON CONSTRAINT p3_sms_application_746ded36f494 ON pb3gir75kkooyea.sms_application IS 'P3|746ded36f494e150e1440e494fe7a5deec64382be922f03400fc16a51f33edc4|UNIQUE (id)';


--
-- Name: sms_application p3_sms_application_ea678e9a5c1a; Type: CONSTRAINT; Schema: pb3gir75kkooyea; Owner: admin
--

ALTER TABLE ONLY pb3gir75kkooyea.sms_application
    ADD CONSTRAINT p3_sms_application_ea678e9a5c1a UNIQUE (sms_app_id);


--
-- Name: CONSTRAINT p3_sms_application_ea678e9a5c1a ON sms_application; Type: COMMENT; Schema: pb3gir75kkooyea; Owner: admin
--

COMMENT ON CONSTRAINT p3_sms_application_ea678e9a5c1a ON pb3gir75kkooyea.sms_application IS 'P3|ea678e9a5c1a7b161936e2dd9ad2a85c9d25c4e32eeb94dfc2846e84cc1cb299|UNIQUE (sms_app_id)';


--
-- Name: sms_application_template p3_sms_application_template_1189e50f22a1; Type: CONSTRAINT; Schema: pb3gir75kkooyea; Owner: admin
--

ALTER TABLE ONLY pb3gir75kkooyea.sms_application_template
    ADD CONSTRAINT p3_sms_application_template_1189e50f22a1 UNIQUE (sms_application_id, template_id);


--
-- Name: CONSTRAINT p3_sms_application_template_1189e50f22a1 ON sms_application_template; Type: COMMENT; Schema: pb3gir75kkooyea; Owner: admin
--

COMMENT ON CONSTRAINT p3_sms_application_template_1189e50f22a1 ON pb3gir75kkooyea.sms_application_template IS 'P3|1189e50f22a1210db8164db547cd4171a6d6d120bd0746877de5ff421df5ffc3|UNIQUE (sms_application_id, template_id)';


--
-- Name: sms_application_template p3_sms_application_template_f4335c9ab8f5; Type: CONSTRAINT; Schema: pb3gir75kkooyea; Owner: admin
--

ALTER TABLE ONLY pb3gir75kkooyea.sms_application_template
    ADD CONSTRAINT p3_sms_application_template_f4335c9ab8f5 UNIQUE (id);


--
-- Name: CONSTRAINT p3_sms_application_template_f4335c9ab8f5 ON sms_application_template; Type: COMMENT; Schema: pb3gir75kkooyea; Owner: admin
--

COMMENT ON CONSTRAINT p3_sms_application_template_f4335c9ab8f5 ON pb3gir75kkooyea.sms_application_template IS 'P3|f4335c9ab8f5ff89ea6ded972fd510801054e574d3cea954ef94c052d77f1f65|UNIQUE (id)';


--
-- Name: sms_channel p3_sms_channel_061b93d0d163; Type: CONSTRAINT; Schema: pb3gir75kkooyea; Owner: admin
--

ALTER TABLE ONLY pb3gir75kkooyea.sms_channel
    ADD CONSTRAINT p3_sms_channel_061b93d0d163 UNIQUE (id);


--
-- Name: CONSTRAINT p3_sms_channel_061b93d0d163 ON sms_channel; Type: COMMENT; Schema: pb3gir75kkooyea; Owner: admin
--

COMMENT ON CONSTRAINT p3_sms_channel_061b93d0d163 ON pb3gir75kkooyea.sms_channel IS 'P3|061b93d0d1634ff5374b09b23c52328c111dbfad3eb0bd7265cdf1901fc910c2|UNIQUE (id)';


--
-- Name: sms_channel p3_sms_channel_e53f43913078; Type: CONSTRAINT; Schema: pb3gir75kkooyea; Owner: admin
--

ALTER TABLE ONLY pb3gir75kkooyea.sms_channel
    ADD CONSTRAINT p3_sms_channel_e53f43913078 UNIQUE (code);


--
-- Name: CONSTRAINT p3_sms_channel_e53f43913078 ON sms_channel; Type: COMMENT; Schema: pb3gir75kkooyea; Owner: admin
--

COMMENT ON CONSTRAINT p3_sms_channel_e53f43913078 ON pb3gir75kkooyea.sms_channel IS 'P3|e53f4391307898d8ea268ec354b36dc536d1ad8766330d2b0ad35af3663049ab|UNIQUE (code)';


--
-- Name: sms_send_attempt p3_sms_send_attempt_5261baf0a57f; Type: CONSTRAINT; Schema: pb3gir75kkooyea; Owner: admin
--

ALTER TABLE ONLY pb3gir75kkooyea.sms_send_attempt
    ADD CONSTRAINT p3_sms_send_attempt_5261baf0a57f UNIQUE (id);


--
-- Name: CONSTRAINT p3_sms_send_attempt_5261baf0a57f ON sms_send_attempt; Type: COMMENT; Schema: pb3gir75kkooyea; Owner: admin
--

COMMENT ON CONSTRAINT p3_sms_send_attempt_5261baf0a57f ON pb3gir75kkooyea.sms_send_attempt IS 'P3|5261baf0a57fc610d4ae888b4847646265102cd472891a365879a37791564dfa|UNIQUE (id)';


--
-- Name: sms_send_attempt p3_sms_send_attempt_c8bf0a8b0842; Type: CONSTRAINT; Schema: pb3gir75kkooyea; Owner: admin
--

ALTER TABLE ONLY pb3gir75kkooyea.sms_send_attempt
    ADD CONSTRAINT p3_sms_send_attempt_c8bf0a8b0842 UNIQUE (send_id, attempt_no);


--
-- Name: CONSTRAINT p3_sms_send_attempt_c8bf0a8b0842 ON sms_send_attempt; Type: COMMENT; Schema: pb3gir75kkooyea; Owner: admin
--

COMMENT ON CONSTRAINT p3_sms_send_attempt_c8bf0a8b0842 ON pb3gir75kkooyea.sms_send_attempt IS 'P3|c8bf0a8b0842123afbc2070ae3e20cccbf908af3284bad9cd385ce0e923faeec|UNIQUE (send_id, attempt_no)';


--
-- Name: sms_send_record p3_sms_send_record_4e7d96a6f47d; Type: CONSTRAINT; Schema: pb3gir75kkooyea; Owner: admin
--

ALTER TABLE ONLY pb3gir75kkooyea.sms_send_record
    ADD CONSTRAINT p3_sms_send_record_4e7d96a6f47d UNIQUE (application_id, request_key);


--
-- Name: CONSTRAINT p3_sms_send_record_4e7d96a6f47d ON sms_send_record; Type: COMMENT; Schema: pb3gir75kkooyea; Owner: admin
--

COMMENT ON CONSTRAINT p3_sms_send_record_4e7d96a6f47d ON pb3gir75kkooyea.sms_send_record IS 'P3|4e7d96a6f47dad868badd02d6a3730bf4eea3abac8db010865dd247fcca43e5b|UNIQUE (application_id, request_key)';


--
-- Name: sms_send_record p3_sms_send_record_76be89e4ce48; Type: CONSTRAINT; Schema: pb3gir75kkooyea; Owner: admin
--

ALTER TABLE ONLY pb3gir75kkooyea.sms_send_record
    ADD CONSTRAINT p3_sms_send_record_76be89e4ce48 UNIQUE (id);


--
-- Name: CONSTRAINT p3_sms_send_record_76be89e4ce48 ON sms_send_record; Type: COMMENT; Schema: pb3gir75kkooyea; Owner: admin
--

COMMENT ON CONSTRAINT p3_sms_send_record_76be89e4ce48 ON pb3gir75kkooyea.sms_send_record IS 'P3|76be89e4ce48ca835c4f60fa91504149fdf115c5921242318d02ee384c48d91f|UNIQUE (id)';


--
-- Name: sms_template p3_sms_template_4d06d257f2eb; Type: CONSTRAINT; Schema: pb3gir75kkooyea; Owner: admin
--

ALTER TABLE ONLY pb3gir75kkooyea.sms_template
    ADD CONSTRAINT p3_sms_template_4d06d257f2eb UNIQUE (code);


--
-- Name: CONSTRAINT p3_sms_template_4d06d257f2eb ON sms_template; Type: COMMENT; Schema: pb3gir75kkooyea; Owner: admin
--

COMMENT ON CONSTRAINT p3_sms_template_4d06d257f2eb ON pb3gir75kkooyea.sms_template IS 'P3|4d06d257f2eb16ac1f5fdca5d632cc1186bb8b1f117879ecee2b869f9542feae|UNIQUE (code)';


--
-- Name: sms_template p3_sms_template_66f6de79e9f2; Type: CONSTRAINT; Schema: pb3gir75kkooyea; Owner: admin
--

ALTER TABLE ONLY pb3gir75kkooyea.sms_template
    ADD CONSTRAINT p3_sms_template_66f6de79e9f2 UNIQUE (id);


--
-- Name: CONSTRAINT p3_sms_template_66f6de79e9f2 ON sms_template; Type: COMMENT; Schema: pb3gir75kkooyea; Owner: admin
--

COMMENT ON CONSTRAINT p3_sms_template_66f6de79e9f2 ON pb3gir75kkooyea.sms_template IS 'P3|66f6de79e9f2cf5e2f36eafb641f21a99fb66d1480ea81f4f351b2d09ba99984|UNIQUE (id)';


--
-- Name: sso_config p3_sso_config_9e910b143668; Type: CONSTRAINT; Schema: pb3gir75kkooyea; Owner: admin
--

ALTER TABLE ONLY pb3gir75kkooyea.sso_config
    ADD CONSTRAINT p3_sso_config_9e910b143668 UNIQUE (id);


--
-- Name: CONSTRAINT p3_sso_config_9e910b143668 ON sso_config; Type: COMMENT; Schema: pb3gir75kkooyea; Owner: admin
--

COMMENT ON CONSTRAINT p3_sso_config_9e910b143668 ON pb3gir75kkooyea.sso_config IS 'P3|9e910b1436684b7798e2f81cd8486b66db3fb260314271160129660bfea8a0b6|UNIQUE (id)';


--
-- Name: sso_config p3_sso_config_fb8138402fb2; Type: CONSTRAINT; Schema: pb3gir75kkooyea; Owner: admin
--

ALTER TABLE ONLY pb3gir75kkooyea.sso_config
    ADD CONSTRAINT p3_sso_config_fb8138402fb2 UNIQUE (application_id);


--
-- Name: CONSTRAINT p3_sso_config_fb8138402fb2 ON sso_config; Type: COMMENT; Schema: pb3gir75kkooyea; Owner: admin
--

COMMENT ON CONSTRAINT p3_sso_config_fb8138402fb2 ON pb3gir75kkooyea.sso_config IS 'P3|fb8138402fb2544f025422afd9eeafd9ff088071bfa9090b260cbe53d03165aa|UNIQUE (application_id)';


--
-- Name: system_config p3_system_config_1c9fec41fbd0; Type: CONSTRAINT; Schema: pb3gir75kkooyea; Owner: admin
--

ALTER TABLE ONLY pb3gir75kkooyea.system_config
    ADD CONSTRAINT p3_system_config_1c9fec41fbd0 UNIQUE (id);


--
-- Name: CONSTRAINT p3_system_config_1c9fec41fbd0 ON system_config; Type: COMMENT; Schema: pb3gir75kkooyea; Owner: admin
--

COMMENT ON CONSTRAINT p3_system_config_1c9fec41fbd0 ON pb3gir75kkooyea.system_config IS 'P3|1c9fec41fbd0e044e64cdccd67ebde6f8b64f9eab4f53b2477c31d5322adf48d|UNIQUE (id)';


--
-- Name: system_config p3_system_config_47034a5d9af6; Type: CONSTRAINT; Schema: pb3gir75kkooyea; Owner: admin
--

ALTER TABLE ONLY pb3gir75kkooyea.system_config
    ADD CONSTRAINT p3_system_config_47034a5d9af6 UNIQUE (code);


--
-- Name: CONSTRAINT p3_system_config_47034a5d9af6 ON system_config; Type: COMMENT; Schema: pb3gir75kkooyea; Owner: admin
--

COMMENT ON CONSTRAINT p3_system_config_47034a5d9af6 ON pb3gir75kkooyea.system_config IS 'P3|47034a5d9af601f1c0dc5e5fd990fbd6e12663b8d3b252dbb18148df69f44e40|UNIQUE (code)';


--
-- Name: todo_item p3_todo_item_4d3365304d1d; Type: CONSTRAINT; Schema: pb3gir75kkooyea; Owner: admin
--

ALTER TABLE ONLY pb3gir75kkooyea.todo_item
    ADD CONSTRAINT p3_todo_item_4d3365304d1d UNIQUE (id);


--
-- Name: CONSTRAINT p3_todo_item_4d3365304d1d ON todo_item; Type: COMMENT; Schema: pb3gir75kkooyea; Owner: admin
--

COMMENT ON CONSTRAINT p3_todo_item_4d3365304d1d ON pb3gir75kkooyea.todo_item IS 'P3|4d3365304d1df92a6fff72db830be57d607695acd0865a8bb48ba9a5b819db21|UNIQUE (id)';


--
-- Name: todo_item p3_todo_item_ddea7627131f; Type: CONSTRAINT; Schema: pb3gir75kkooyea; Owner: admin
--

ALTER TABLE ONLY pb3gir75kkooyea.todo_item
    ADD CONSTRAINT p3_todo_item_ddea7627131f UNIQUE (application_id, source_todo_id);


--
-- Name: CONSTRAINT p3_todo_item_ddea7627131f ON todo_item; Type: COMMENT; Schema: pb3gir75kkooyea; Owner: admin
--

COMMENT ON CONSTRAINT p3_todo_item_ddea7627131f ON pb3gir75kkooyea.todo_item IS 'P3|ddea7627131fcb3f4a0066e21104edffdb5c6a91fc4b9ab292a304e355f5d428|UNIQUE (application_id, source_todo_id)';


--
-- Name: unified_user p3_unified_user_0149343b4a66; Type: CONSTRAINT; Schema: pb3gir75kkooyea; Owner: admin
--

ALTER TABLE ONLY pb3gir75kkooyea.unified_user
    ADD CONSTRAINT p3_unified_user_0149343b4a66 UNIQUE (id);


--
-- Name: CONSTRAINT p3_unified_user_0149343b4a66 ON unified_user; Type: COMMENT; Schema: pb3gir75kkooyea; Owner: admin
--

COMMENT ON CONSTRAINT p3_unified_user_0149343b4a66 ON pb3gir75kkooyea.unified_user IS 'P3|0149343b4a66db34bec2c35c0de86b57f3da933e2b5ad439ac93579c968fe007|UNIQUE (id)';


--
-- Name: portal_demo_restore_archive portal_demo_restore_archive_pkey; Type: CONSTRAINT; Schema: pb3gir75kkooyea; Owner: admin
--

ALTER TABLE ONLY pb3gir75kkooyea.portal_demo_restore_archive
    ADD CONSTRAINT portal_demo_restore_archive_pkey PRIMARY KEY (archive_key);


--
-- Name: portal_permission portal_permission_pkey; Type: CONSTRAINT; Schema: pb3gir75kkooyea; Owner: admin
--

ALTER TABLE ONLY pb3gir75kkooyea.portal_permission
    ADD CONSTRAINT portal_permission_pkey PRIMARY KEY (nc_id);


--
-- Name: portal_role_permission portal_role_permission_pkey; Type: CONSTRAINT; Schema: pb3gir75kkooyea; Owner: admin
--

ALTER TABLE ONLY pb3gir75kkooyea.portal_role_permission
    ADD CONSTRAINT portal_role_permission_pkey PRIMARY KEY (nc_id);


--
-- Name: portal_role portal_role_pkey; Type: CONSTRAINT; Schema: pb3gir75kkooyea; Owner: admin
--

ALTER TABLE ONLY pb3gir75kkooyea.portal_role
    ADD CONSTRAINT portal_role_pkey PRIMARY KEY (nc_id);


--
-- Name: portal_runtime_entity_domain portal_runtime_entity_domain_pkey; Type: CONSTRAINT; Schema: pb3gir75kkooyea; Owner: admin
--

ALTER TABLE ONLY pb3gir75kkooyea.portal_runtime_entity_domain
    ADD CONSTRAINT portal_runtime_entity_domain_pkey PRIMARY KEY (resource);


--
-- Name: portal_runtime_entity portal_runtime_entity_pkey; Type: CONSTRAINT; Schema: pb3gir75kkooyea; Owner: admin
--

ALTER TABLE ONLY pb3gir75kkooyea.portal_runtime_entity
    ADD CONSTRAINT portal_runtime_entity_pkey PRIMARY KEY (resource, runtime_id);


--
-- Name: portal_session portal_session_pkey; Type: CONSTRAINT; Schema: pb3gir75kkooyea; Owner: admin
--

ALTER TABLE ONLY pb3gir75kkooyea.portal_session
    ADD CONSTRAINT portal_session_pkey PRIMARY KEY (nc_id);


--
-- Name: portal_user_application_scope portal_user_application_scope_pkey; Type: CONSTRAINT; Schema: pb3gir75kkooyea; Owner: admin
--

ALTER TABLE ONLY pb3gir75kkooyea.portal_user_application_scope
    ADD CONSTRAINT portal_user_application_scope_pkey PRIMARY KEY (nc_id);


--
-- Name: portal_user_role portal_user_role_pkey; Type: CONSTRAINT; Schema: pb3gir75kkooyea; Owner: admin
--

ALTER TABLE ONLY pb3gir75kkooyea.portal_user_role
    ADD CONSTRAINT portal_user_role_pkey PRIMARY KEY (nc_id);


--
-- Name: push_integration_config push_integration_config_pkey; Type: CONSTRAINT; Schema: pb3gir75kkooyea; Owner: admin
--

ALTER TABLE ONLY pb3gir75kkooyea.push_integration_config
    ADD CONSTRAINT push_integration_config_pkey PRIMARY KEY (nc_id);


--
-- Name: sms_application sms_application_pkey; Type: CONSTRAINT; Schema: pb3gir75kkooyea; Owner: admin
--

ALTER TABLE ONLY pb3gir75kkooyea.sms_application
    ADD CONSTRAINT sms_application_pkey PRIMARY KEY (nc_id);


--
-- Name: sms_application_template sms_application_template_pkey; Type: CONSTRAINT; Schema: pb3gir75kkooyea; Owner: admin
--

ALTER TABLE ONLY pb3gir75kkooyea.sms_application_template
    ADD CONSTRAINT sms_application_template_pkey PRIMARY KEY (nc_id);


--
-- Name: sms_channel sms_channel_pkey; Type: CONSTRAINT; Schema: pb3gir75kkooyea; Owner: admin
--

ALTER TABLE ONLY pb3gir75kkooyea.sms_channel
    ADD CONSTRAINT sms_channel_pkey PRIMARY KEY (nc_id);


--
-- Name: sms_send_attempt sms_send_attempt_pkey; Type: CONSTRAINT; Schema: pb3gir75kkooyea; Owner: admin
--

ALTER TABLE ONLY pb3gir75kkooyea.sms_send_attempt
    ADD CONSTRAINT sms_send_attempt_pkey PRIMARY KEY (nc_id);


--
-- Name: sms_send_record sms_send_record_pkey; Type: CONSTRAINT; Schema: pb3gir75kkooyea; Owner: admin
--

ALTER TABLE ONLY pb3gir75kkooyea.sms_send_record
    ADD CONSTRAINT sms_send_record_pkey PRIMARY KEY (nc_id);


--
-- Name: sms_template sms_template_pkey; Type: CONSTRAINT; Schema: pb3gir75kkooyea; Owner: admin
--

ALTER TABLE ONLY pb3gir75kkooyea.sms_template
    ADD CONSTRAINT sms_template_pkey PRIMARY KEY (nc_id);


--
-- Name: sso_config sso_config_pkey; Type: CONSTRAINT; Schema: pb3gir75kkooyea; Owner: admin
--

ALTER TABLE ONLY pb3gir75kkooyea.sso_config
    ADD CONSTRAINT sso_config_pkey PRIMARY KEY (nc_id);


--
-- Name: system_config system_config_pkey; Type: CONSTRAINT; Schema: pb3gir75kkooyea; Owner: admin
--

ALTER TABLE ONLY pb3gir75kkooyea.system_config
    ADD CONSTRAINT system_config_pkey PRIMARY KEY (nc_id);


--
-- Name: todo_item todo_item_pkey; Type: CONSTRAINT; Schema: pb3gir75kkooyea; Owner: admin
--

ALTER TABLE ONLY pb3gir75kkooyea.todo_item
    ADD CONSTRAINT todo_item_pkey PRIMARY KEY (nc_id);


--
-- Name: unified_user unified_user_pkey; Type: CONSTRAINT; Schema: pb3gir75kkooyea; Owner: admin
--

ALTER TABLE ONLY pb3gir75kkooyea.unified_user
    ADD CONSTRAINT unified_user_pkey PRIMARY KEY (nc_id);


--
-- Name: announcement_attachment_order_idx; Type: INDEX; Schema: pb3gir75kkooyea; Owner: admin
--

CREATE INDEX announcement_attachment_order_idx ON pb3gir75kkooyea.announcement_attachment USING btree (nc_order);


--
-- Name: announcement_order_idx; Type: INDEX; Schema: pb3gir75kkooyea; Owner: admin
--

CREATE INDEX announcement_order_idx ON pb3gir75kkooyea.announcement USING btree (nc_order);


--
-- Name: announcement_org_scope_order_idx; Type: INDEX; Schema: pb3gir75kkooyea; Owner: admin
--

CREATE INDEX announcement_org_scope_order_idx ON pb3gir75kkooyea.announcement_org_scope USING btree (nc_order);


--
-- Name: application_category_order_idx; Type: INDEX; Schema: pb3gir75kkooyea; Owner: admin
--

CREATE INDEX application_category_order_idx ON pb3gir75kkooyea.application_category USING btree (nc_order);


--
-- Name: application_order_idx; Type: INDEX; Schema: pb3gir75kkooyea; Owner: admin
--

CREATE INDEX application_order_idx ON pb3gir75kkooyea.application USING btree (nc_order);


--
-- Name: application_user_mapping_order_idx; Type: INDEX; Schema: pb3gir75kkooyea; Owner: admin
--

CREATE INDEX application_user_mapping_order_idx ON pb3gir75kkooyea.application_user_mapping USING btree (nc_order);


--
-- Name: audit_event_order_idx; Type: INDEX; Schema: pb3gir75kkooyea; Owner: admin
--

CREATE INDEX audit_event_order_idx ON pb3gir75kkooyea.audit_event USING btree (nc_order);


--
-- Name: identity_mapping_order_idx; Type: INDEX; Schema: pb3gir75kkooyea; Owner: admin
--

CREATE INDEX identity_mapping_order_idx ON pb3gir75kkooyea.identity_mapping USING btree (nc_order);


--
-- Name: identity_source_order_idx; Type: INDEX; Schema: pb3gir75kkooyea; Owner: admin
--

CREATE INDEX identity_source_order_idx ON pb3gir75kkooyea.identity_source USING btree (nc_order);


--
-- Name: ingest_receipt_order_idx; Type: INDEX; Schema: pb3gir75kkooyea; Owner: admin
--

CREATE INDEX ingest_receipt_order_idx ON pb3gir75kkooyea.ingest_receipt USING btree (nc_order);


--
-- Name: ix_access_request_user_app; Type: INDEX; Schema: pb3gir75kkooyea; Owner: admin
--

CREATE INDEX ix_access_request_user_app ON pb3gir75kkooyea.application_access_request USING btree (user_id, application_id, submitted_at DESC);


--
-- Name: ix_announcement_active_status; Type: INDEX; Schema: pb3gir75kkooyea; Owner: admin
--

CREATE INDEX ix_announcement_active_status ON pb3gir75kkooyea.announcement USING btree (status, published_at) WHERE (deleted_at IS NULL);


--
-- Name: ix_announcement_read_receipt_user; Type: INDEX; Schema: pb3gir75kkooyea; Owner: admin
--

CREATE INDEX ix_announcement_read_receipt_user ON pb3gir75kkooyea.announcement_read_receipt USING btree (user_id, read_at);


--
-- Name: ix_announcement_schedule; Type: INDEX; Schema: pb3gir75kkooyea; Owner: admin
--

CREATE INDEX ix_announcement_schedule ON pb3gir75kkooyea.announcement USING btree (scheduled_publish_at) WHERE ((publish_mode = 'SCHEDULED'::text) AND (deleted_at IS NULL));


--
-- Name: ix_application_catalog_active; Type: INDEX; Schema: pb3gir75kkooyea; Owner: admin
--

CREATE INDEX ix_application_catalog_active ON pb3gir75kkooyea.application USING btree (sort_order, id) WHERE (deleted_at IS NULL);


--
-- Name: ix_opening_request_user_app; Type: INDEX; Schema: pb3gir75kkooyea; Owner: admin
--

CREATE INDEX ix_opening_request_user_app ON pb3gir75kkooyea.account_opening_request USING btree (user_id, application_id, submitted_at DESC);


--
-- Name: ix_p4_message_runtime_id; Type: INDEX; Schema: pb3gir75kkooyea; Owner: admin
--

CREATE UNIQUE INDEX ix_p4_message_runtime_id ON pb3gir75kkooyea.message USING btree (runtime_id);


--
-- Name: ix_p4_todo_runtime_id; Type: INDEX; Schema: pb3gir75kkooyea; Owner: admin
--

CREATE UNIQUE INDEX ix_p4_todo_runtime_id ON pb3gir75kkooyea.todo_item USING btree (runtime_id);


--
-- Name: login_request_order_idx; Type: INDEX; Schema: pb3gir75kkooyea; Owner: admin
--

CREATE INDEX login_request_order_idx ON pb3gir75kkooyea.login_request USING btree (nc_order);


--
-- Name: mapping_exception_order_idx; Type: INDEX; Schema: pb3gir75kkooyea; Owner: admin
--

CREATE INDEX mapping_exception_order_idx ON pb3gir75kkooyea.mapping_exception USING btree (nc_order);


--
-- Name: message_order_idx; Type: INDEX; Schema: pb3gir75kkooyea; Owner: admin
--

CREATE INDEX message_order_idx ON pb3gir75kkooyea.message USING btree (nc_order);


--
-- Name: message_recipient_order_idx; Type: INDEX; Schema: pb3gir75kkooyea; Owner: admin
--

CREATE INDEX message_recipient_order_idx ON pb3gir75kkooyea.message_recipient USING btree (nc_order);


--
-- Name: monitor_status_order_idx; Type: INDEX; Schema: pb3gir75kkooyea; Owner: admin
--

CREATE INDEX monitor_status_order_idx ON pb3gir75kkooyea.monitor_status USING btree (nc_order);


--
-- Name: p3i_application_user_mapping_fab186218987; Type: INDEX; Schema: pb3gir75kkooyea; Owner: admin
--

CREATE UNIQUE INDEX p3i_application_user_mapping_fab186218987 ON pb3gir75kkooyea.application_user_mapping USING btree (application_id, external_user_id) WHERE (status = 'BOUND'::text);


--
-- Name: INDEX p3i_application_user_mapping_fab186218987; Type: COMMENT; Schema: pb3gir75kkooyea; Owner: admin
--

COMMENT ON INDEX pb3gir75kkooyea.p3i_application_user_mapping_fab186218987 IS 'P3|fab186218987db3e8fbab9d9138c5fab8a144b536457e3df0302f647604d19cc|CREATE UNIQUE INDEX p3i_application_user_mapping_fab186218987 ON pb3gir75kkooyea.application_user_mapping USING btree (application_id, external_user_id) WHERE (status = ''BOUND''::text)';


--
-- Name: p3i_audit_event_27ecf0f2c27e; Type: INDEX; Schema: pb3gir75kkooyea; Owner: admin
--

CREATE INDEX p3i_audit_event_27ecf0f2c27e ON pb3gir75kkooyea.audit_event USING btree (kind, created_at);


--
-- Name: INDEX p3i_audit_event_27ecf0f2c27e; Type: COMMENT; Schema: pb3gir75kkooyea; Owner: admin
--

COMMENT ON INDEX pb3gir75kkooyea.p3i_audit_event_27ecf0f2c27e IS 'P3|27ecf0f2c27e953b5bbf1e83f1e70c29fecc04d6f83d8bcb20c0d9ca66438e33|CREATE INDEX p3i_audit_event_27ecf0f2c27e ON pb3gir75kkooyea.audit_event USING btree (kind, created_at)';


--
-- Name: p3i_audit_event_6658617c0757; Type: INDEX; Schema: pb3gir75kkooyea; Owner: admin
--

CREATE INDEX p3i_audit_event_6658617c0757 ON pb3gir75kkooyea.audit_event USING btree (request_id);


--
-- Name: INDEX p3i_audit_event_6658617c0757; Type: COMMENT; Schema: pb3gir75kkooyea; Owner: admin
--

COMMENT ON INDEX pb3gir75kkooyea.p3i_audit_event_6658617c0757 IS 'P3|6658617c0757989122c23bbe11269113a3cb1342a9100564cdf25f1689e9130e|CREATE INDEX p3i_audit_event_6658617c0757 ON pb3gir75kkooyea.audit_event USING btree (request_id)';


--
-- Name: p3i_message_recipient_4c7efcc5c800; Type: INDEX; Schema: pb3gir75kkooyea; Owner: admin
--

CREATE INDEX p3i_message_recipient_4c7efcc5c800 ON pb3gir75kkooyea.message_recipient USING btree (user_id, read_status);


--
-- Name: INDEX p3i_message_recipient_4c7efcc5c800; Type: COMMENT; Schema: pb3gir75kkooyea; Owner: admin
--

COMMENT ON INDEX pb3gir75kkooyea.p3i_message_recipient_4c7efcc5c800 IS 'P3|4c7efcc5c80093b3597ea8b8e57e5ec757d57539abf65d12751f4cac9b705cf0|CREATE INDEX p3i_message_recipient_4c7efcc5c800 ON pb3gir75kkooyea.message_recipient USING btree (user_id, read_status)';


--
-- Name: p3i_todo_item_cb41b63f8bb2; Type: INDEX; Schema: pb3gir75kkooyea; Owner: admin
--

CREATE INDEX p3i_todo_item_cb41b63f8bb2 ON pb3gir75kkooyea.todo_item USING btree (target_user_id, status, source_created_at);


--
-- Name: INDEX p3i_todo_item_cb41b63f8bb2; Type: COMMENT; Schema: pb3gir75kkooyea; Owner: admin
--

COMMENT ON INDEX pb3gir75kkooyea.p3i_todo_item_cb41b63f8bb2 IS 'P3|cb41b63f8bb21b0850e737d85e75af0e831ce1faa4b2a625c4cabe310c41edb8|CREATE INDEX p3i_todo_item_cb41b63f8bb2 ON pb3gir75kkooyea.todo_item USING btree (target_user_id, status, source_created_at)';


--
-- Name: portal_permission_order_idx; Type: INDEX; Schema: pb3gir75kkooyea; Owner: admin
--

CREATE INDEX portal_permission_order_idx ON pb3gir75kkooyea.portal_permission USING btree (nc_order);


--
-- Name: portal_role_order_idx; Type: INDEX; Schema: pb3gir75kkooyea; Owner: admin
--

CREATE INDEX portal_role_order_idx ON pb3gir75kkooyea.portal_role USING btree (nc_order);


--
-- Name: portal_role_permission_order_idx; Type: INDEX; Schema: pb3gir75kkooyea; Owner: admin
--

CREATE INDEX portal_role_permission_order_idx ON pb3gir75kkooyea.portal_role_permission USING btree (nc_order);


--
-- Name: portal_session_order_idx; Type: INDEX; Schema: pb3gir75kkooyea; Owner: admin
--

CREATE INDEX portal_session_order_idx ON pb3gir75kkooyea.portal_session USING btree (nc_order);


--
-- Name: portal_user_application_scope_order_idx; Type: INDEX; Schema: pb3gir75kkooyea; Owner: admin
--

CREATE INDEX portal_user_application_scope_order_idx ON pb3gir75kkooyea.portal_user_application_scope USING btree (nc_order);


--
-- Name: portal_user_role_order_idx; Type: INDEX; Schema: pb3gir75kkooyea; Owner: admin
--

CREATE INDEX portal_user_role_order_idx ON pb3gir75kkooyea.portal_user_role USING btree (nc_order);


--
-- Name: push_integration_config_order_idx; Type: INDEX; Schema: pb3gir75kkooyea; Owner: admin
--

CREATE INDEX push_integration_config_order_idx ON pb3gir75kkooyea.push_integration_config USING btree (nc_order);


--
-- Name: sms_application_order_idx; Type: INDEX; Schema: pb3gir75kkooyea; Owner: admin
--

CREATE INDEX sms_application_order_idx ON pb3gir75kkooyea.sms_application USING btree (nc_order);


--
-- Name: sms_application_template_order_idx; Type: INDEX; Schema: pb3gir75kkooyea; Owner: admin
--

CREATE INDEX sms_application_template_order_idx ON pb3gir75kkooyea.sms_application_template USING btree (nc_order);


--
-- Name: sms_channel_order_idx; Type: INDEX; Schema: pb3gir75kkooyea; Owner: admin
--

CREATE INDEX sms_channel_order_idx ON pb3gir75kkooyea.sms_channel USING btree (nc_order);


--
-- Name: sms_send_attempt_order_idx; Type: INDEX; Schema: pb3gir75kkooyea; Owner: admin
--

CREATE INDEX sms_send_attempt_order_idx ON pb3gir75kkooyea.sms_send_attempt USING btree (nc_order);


--
-- Name: sms_send_record_order_idx; Type: INDEX; Schema: pb3gir75kkooyea; Owner: admin
--

CREATE INDEX sms_send_record_order_idx ON pb3gir75kkooyea.sms_send_record USING btree (nc_order);


--
-- Name: sms_template_order_idx; Type: INDEX; Schema: pb3gir75kkooyea; Owner: admin
--

CREATE INDEX sms_template_order_idx ON pb3gir75kkooyea.sms_template USING btree (nc_order);


--
-- Name: sso_config_order_idx; Type: INDEX; Schema: pb3gir75kkooyea; Owner: admin
--

CREATE INDEX sso_config_order_idx ON pb3gir75kkooyea.sso_config USING btree (nc_order);


--
-- Name: system_config_order_idx; Type: INDEX; Schema: pb3gir75kkooyea; Owner: admin
--

CREATE INDEX system_config_order_idx ON pb3gir75kkooyea.system_config USING btree (nc_order);


--
-- Name: todo_item_order_idx; Type: INDEX; Schema: pb3gir75kkooyea; Owner: admin
--

CREATE INDEX todo_item_order_idx ON pb3gir75kkooyea.todo_item USING btree (nc_order);


--
-- Name: unified_user_order_idx; Type: INDEX; Schema: pb3gir75kkooyea; Owner: admin
--

CREATE INDEX unified_user_order_idx ON pb3gir75kkooyea.unified_user USING btree (nc_order);


--
-- Name: uq_access_grant_active; Type: INDEX; Schema: pb3gir75kkooyea; Owner: admin
--

CREATE UNIQUE INDEX uq_access_grant_active ON pb3gir75kkooyea.application_access_grant USING btree (user_id, application_id) WHERE (status = 'ACTIVE'::text);


--
-- Name: uq_access_request_pending; Type: INDEX; Schema: pb3gir75kkooyea; Owner: admin
--

CREATE UNIQUE INDEX uq_access_request_pending ON pb3gir75kkooyea.application_access_request USING btree (user_id, application_id) WHERE (status = 'PENDING'::text);


--
-- Name: uq_announcement_attachment_runtime_id; Type: INDEX; Schema: pb3gir75kkooyea; Owner: admin
--

CREATE UNIQUE INDEX uq_announcement_attachment_runtime_id ON pb3gir75kkooyea.announcement_attachment USING btree (runtime_id) WHERE (runtime_id IS NOT NULL);


--
-- Name: uq_announcement_runtime_id; Type: INDEX; Schema: pb3gir75kkooyea; Owner: admin
--

CREATE UNIQUE INDEX uq_announcement_runtime_id ON pb3gir75kkooyea.announcement USING btree (runtime_id) WHERE (runtime_id IS NOT NULL);


--
-- Name: uq_application_category_runtime_id; Type: INDEX; Schema: pb3gir75kkooyea; Owner: admin
--

CREATE UNIQUE INDEX uq_application_category_runtime_id ON pb3gir75kkooyea.application_category USING btree (runtime_id) WHERE (runtime_id IS NOT NULL);


--
-- Name: uq_application_runtime_id; Type: INDEX; Schema: pb3gir75kkooyea; Owner: admin
--

CREATE UNIQUE INDEX uq_application_runtime_id ON pb3gir75kkooyea.application USING btree (runtime_id) WHERE (runtime_id IS NOT NULL);


--
-- Name: uq_opening_request_open; Type: INDEX; Schema: pb3gir75kkooyea; Owner: admin
--

CREATE UNIQUE INDEX uq_opening_request_open ON pb3gir75kkooyea.account_opening_request USING btree (user_id, application_id) WHERE (status = ANY (ARRAY['PENDING'::text, 'PROCESSING'::text]));


--
-- Name: account_opening_request account_opening_request_application_id_fkey; Type: FK CONSTRAINT; Schema: pb3gir75kkooyea; Owner: admin
--

ALTER TABLE ONLY pb3gir75kkooyea.account_opening_request
    ADD CONSTRAINT account_opening_request_application_id_fkey FOREIGN KEY (application_id) REFERENCES pb3gir75kkooyea.application(id) ON DELETE RESTRICT;


--
-- Name: account_opening_request account_opening_request_handled_by_fkey; Type: FK CONSTRAINT; Schema: pb3gir75kkooyea; Owner: admin
--

ALTER TABLE ONLY pb3gir75kkooyea.account_opening_request
    ADD CONSTRAINT account_opening_request_handled_by_fkey FOREIGN KEY (handled_by) REFERENCES pb3gir75kkooyea.unified_user(id) ON DELETE RESTRICT;


--
-- Name: account_opening_request account_opening_request_user_id_fkey; Type: FK CONSTRAINT; Schema: pb3gir75kkooyea; Owner: admin
--

ALTER TABLE ONLY pb3gir75kkooyea.account_opening_request
    ADD CONSTRAINT account_opening_request_user_id_fkey FOREIGN KEY (user_id) REFERENCES pb3gir75kkooyea.unified_user(id) ON DELETE RESTRICT;


--
-- Name: announcement announcement_last_edited_by_fkey; Type: FK CONSTRAINT; Schema: pb3gir75kkooyea; Owner: admin
--

ALTER TABLE ONLY pb3gir75kkooyea.announcement
    ADD CONSTRAINT announcement_last_edited_by_fkey FOREIGN KEY (last_edited_by) REFERENCES pb3gir75kkooyea.unified_user(id) ON DELETE RESTRICT;


--
-- Name: announcement_read_receipt announcement_read_receipt_announcement_id_fkey; Type: FK CONSTRAINT; Schema: pb3gir75kkooyea; Owner: admin
--

ALTER TABLE ONLY pb3gir75kkooyea.announcement_read_receipt
    ADD CONSTRAINT announcement_read_receipt_announcement_id_fkey FOREIGN KEY (announcement_id) REFERENCES pb3gir75kkooyea.announcement(id) ON DELETE CASCADE;


--
-- Name: announcement_read_receipt announcement_read_receipt_user_id_fkey; Type: FK CONSTRAINT; Schema: pb3gir75kkooyea; Owner: admin
--

ALTER TABLE ONLY pb3gir75kkooyea.announcement_read_receipt
    ADD CONSTRAINT announcement_read_receipt_user_id_fkey FOREIGN KEY (user_id) REFERENCES pb3gir75kkooyea.unified_user(id) ON DELETE CASCADE;


--
-- Name: announcement announcement_submitted_by_fkey; Type: FK CONSTRAINT; Schema: pb3gir75kkooyea; Owner: admin
--

ALTER TABLE ONLY pb3gir75kkooyea.announcement
    ADD CONSTRAINT announcement_submitted_by_fkey FOREIGN KEY (submitted_by) REFERENCES pb3gir75kkooyea.unified_user(id) ON DELETE RESTRICT;


--
-- Name: announcement announcement_withdrawn_by_fkey; Type: FK CONSTRAINT; Schema: pb3gir75kkooyea; Owner: admin
--

ALTER TABLE ONLY pb3gir75kkooyea.announcement
    ADD CONSTRAINT announcement_withdrawn_by_fkey FOREIGN KEY (withdrawn_by) REFERENCES pb3gir75kkooyea.unified_user(id) ON DELETE RESTRICT;


--
-- Name: application_access_grant application_access_grant_application_id_fkey; Type: FK CONSTRAINT; Schema: pb3gir75kkooyea; Owner: admin
--

ALTER TABLE ONLY pb3gir75kkooyea.application_access_grant
    ADD CONSTRAINT application_access_grant_application_id_fkey FOREIGN KEY (application_id) REFERENCES pb3gir75kkooyea.application(id) ON DELETE RESTRICT;


--
-- Name: application_access_grant application_access_grant_granted_by_fkey; Type: FK CONSTRAINT; Schema: pb3gir75kkooyea; Owner: admin
--

ALTER TABLE ONLY pb3gir75kkooyea.application_access_grant
    ADD CONSTRAINT application_access_grant_granted_by_fkey FOREIGN KEY (granted_by) REFERENCES pb3gir75kkooyea.unified_user(id) ON DELETE RESTRICT;


--
-- Name: application_access_grant application_access_grant_user_id_fkey; Type: FK CONSTRAINT; Schema: pb3gir75kkooyea; Owner: admin
--

ALTER TABLE ONLY pb3gir75kkooyea.application_access_grant
    ADD CONSTRAINT application_access_grant_user_id_fkey FOREIGN KEY (user_id) REFERENCES pb3gir75kkooyea.unified_user(id) ON DELETE RESTRICT;


--
-- Name: application_access_request application_access_request_application_id_fkey; Type: FK CONSTRAINT; Schema: pb3gir75kkooyea; Owner: admin
--

ALTER TABLE ONLY pb3gir75kkooyea.application_access_request
    ADD CONSTRAINT application_access_request_application_id_fkey FOREIGN KEY (application_id) REFERENCES pb3gir75kkooyea.application(id) ON DELETE RESTRICT;


--
-- Name: application_access_request application_access_request_reviewed_by_fkey; Type: FK CONSTRAINT; Schema: pb3gir75kkooyea; Owner: admin
--

ALTER TABLE ONLY pb3gir75kkooyea.application_access_request
    ADD CONSTRAINT application_access_request_reviewed_by_fkey FOREIGN KEY (reviewed_by) REFERENCES pb3gir75kkooyea.unified_user(id) ON DELETE RESTRICT;


--
-- Name: application_access_request application_access_request_user_id_fkey; Type: FK CONSTRAINT; Schema: pb3gir75kkooyea; Owner: admin
--

ALTER TABLE ONLY pb3gir75kkooyea.application_access_request
    ADD CONSTRAINT application_access_request_user_id_fkey FOREIGN KEY (user_id) REFERENCES pb3gir75kkooyea.unified_user(id) ON DELETE RESTRICT;


--
-- Name: announcement p3_announcement_45ede45af2c6; Type: FK CONSTRAINT; Schema: pb3gir75kkooyea; Owner: admin
--

ALTER TABLE ONLY pb3gir75kkooyea.announcement
    ADD CONSTRAINT p3_announcement_45ede45af2c6 FOREIGN KEY (publisher_id) REFERENCES pb3gir75kkooyea.unified_user(id) ON DELETE RESTRICT;


--
-- Name: CONSTRAINT p3_announcement_45ede45af2c6 ON announcement; Type: COMMENT; Schema: pb3gir75kkooyea; Owner: admin
--

COMMENT ON CONSTRAINT p3_announcement_45ede45af2c6 ON pb3gir75kkooyea.announcement IS 'P3|45ede45af2c61f0e37b65b6cbf540e9364882954228bc21a66ff8e24d6ab4bdb|FOREIGN KEY (publisher_id) REFERENCES unified_user(id) ON DELETE RESTRICT';


--
-- Name: announcement_attachment p3_announcement_attachment_d63316230bc4; Type: FK CONSTRAINT; Schema: pb3gir75kkooyea; Owner: admin
--

ALTER TABLE ONLY pb3gir75kkooyea.announcement_attachment
    ADD CONSTRAINT p3_announcement_attachment_d63316230bc4 FOREIGN KEY (uploaded_by) REFERENCES pb3gir75kkooyea.unified_user(id) ON DELETE RESTRICT;


--
-- Name: CONSTRAINT p3_announcement_attachment_d63316230bc4 ON announcement_attachment; Type: COMMENT; Schema: pb3gir75kkooyea; Owner: admin
--

COMMENT ON CONSTRAINT p3_announcement_attachment_d63316230bc4 ON pb3gir75kkooyea.announcement_attachment IS 'P3|d63316230bc4c84582693e3a7b5cbfeb9bac88521c2e383b8706aaad11325109|FOREIGN KEY (uploaded_by) REFERENCES unified_user(id) ON DELETE RESTRICT';


--
-- Name: announcement_attachment p3_announcement_attachment_f7419e9cc11f; Type: FK CONSTRAINT; Schema: pb3gir75kkooyea; Owner: admin
--

ALTER TABLE ONLY pb3gir75kkooyea.announcement_attachment
    ADD CONSTRAINT p3_announcement_attachment_f7419e9cc11f FOREIGN KEY (announcement_id) REFERENCES pb3gir75kkooyea.announcement(id) ON DELETE RESTRICT;


--
-- Name: CONSTRAINT p3_announcement_attachment_f7419e9cc11f ON announcement_attachment; Type: COMMENT; Schema: pb3gir75kkooyea; Owner: admin
--

COMMENT ON CONSTRAINT p3_announcement_attachment_f7419e9cc11f ON pb3gir75kkooyea.announcement_attachment IS 'P3|f7419e9cc11ff2bddf2116219e9f6cfcb0157c3270670a5caa24178033027c88|FOREIGN KEY (announcement_id) REFERENCES announcement(id) ON DELETE RESTRICT';


--
-- Name: announcement_org_scope p3_announcement_org_scope_3374fcb769fc; Type: FK CONSTRAINT; Schema: pb3gir75kkooyea; Owner: admin
--

ALTER TABLE ONLY pb3gir75kkooyea.announcement_org_scope
    ADD CONSTRAINT p3_announcement_org_scope_3374fcb769fc FOREIGN KEY (announcement_id) REFERENCES pb3gir75kkooyea.announcement(id) ON DELETE RESTRICT;


--
-- Name: CONSTRAINT p3_announcement_org_scope_3374fcb769fc ON announcement_org_scope; Type: COMMENT; Schema: pb3gir75kkooyea; Owner: admin
--

COMMENT ON CONSTRAINT p3_announcement_org_scope_3374fcb769fc ON pb3gir75kkooyea.announcement_org_scope IS 'P3|3374fcb769fcbb75ae24780cbd6d8cda4a4fd53a027db5592134a4c5565c1813|FOREIGN KEY (announcement_id) REFERENCES announcement(id) ON DELETE RESTRICT';


--
-- Name: application p3_application_33c9766c683f; Type: FK CONSTRAINT; Schema: pb3gir75kkooyea; Owner: admin
--

ALTER TABLE ONLY pb3gir75kkooyea.application
    ADD CONSTRAINT p3_application_33c9766c683f FOREIGN KEY (category_id) REFERENCES pb3gir75kkooyea.application_category(id) ON DELETE RESTRICT;


--
-- Name: CONSTRAINT p3_application_33c9766c683f ON application; Type: COMMENT; Schema: pb3gir75kkooyea; Owner: admin
--

COMMENT ON CONSTRAINT p3_application_33c9766c683f ON pb3gir75kkooyea.application IS 'P3|33c9766c683f67462c395283d8d27848eb24795f1c38c39f2fdc5c9ef33fc1bc|FOREIGN KEY (category_id) REFERENCES application_category(id) ON DELETE RESTRICT';


--
-- Name: application_user_mapping p3_application_user_mapping_1b8fad9e766c; Type: FK CONSTRAINT; Schema: pb3gir75kkooyea; Owner: admin
--

ALTER TABLE ONLY pb3gir75kkooyea.application_user_mapping
    ADD CONSTRAINT p3_application_user_mapping_1b8fad9e766c FOREIGN KEY (application_id) REFERENCES pb3gir75kkooyea.application(id) ON DELETE RESTRICT;


--
-- Name: CONSTRAINT p3_application_user_mapping_1b8fad9e766c ON application_user_mapping; Type: COMMENT; Schema: pb3gir75kkooyea; Owner: admin
--

COMMENT ON CONSTRAINT p3_application_user_mapping_1b8fad9e766c ON pb3gir75kkooyea.application_user_mapping IS 'P3|1b8fad9e766cd7bd2e35c17116fe2c5736c3eb778c95f71745225a4db275b7f4|FOREIGN KEY (application_id) REFERENCES application(id) ON DELETE RESTRICT';


--
-- Name: application_user_mapping p3_application_user_mapping_dd5a228cabbe; Type: FK CONSTRAINT; Schema: pb3gir75kkooyea; Owner: admin
--

ALTER TABLE ONLY pb3gir75kkooyea.application_user_mapping
    ADD CONSTRAINT p3_application_user_mapping_dd5a228cabbe FOREIGN KEY (user_id) REFERENCES pb3gir75kkooyea.unified_user(id) ON DELETE RESTRICT;


--
-- Name: CONSTRAINT p3_application_user_mapping_dd5a228cabbe ON application_user_mapping; Type: COMMENT; Schema: pb3gir75kkooyea; Owner: admin
--

COMMENT ON CONSTRAINT p3_application_user_mapping_dd5a228cabbe ON pb3gir75kkooyea.application_user_mapping IS 'P3|dd5a228cabbef88bac552d8cb7d3d824b57f79c2d919709b886c6984bccbc9bc|FOREIGN KEY (user_id) REFERENCES unified_user(id) ON DELETE RESTRICT';


--
-- Name: audit_event p3_audit_event_778fb9880d5c; Type: FK CONSTRAINT; Schema: pb3gir75kkooyea; Owner: admin
--

ALTER TABLE ONLY pb3gir75kkooyea.audit_event
    ADD CONSTRAINT p3_audit_event_778fb9880d5c FOREIGN KEY (application_id) REFERENCES pb3gir75kkooyea.application(id) ON DELETE RESTRICT;


--
-- Name: CONSTRAINT p3_audit_event_778fb9880d5c ON audit_event; Type: COMMENT; Schema: pb3gir75kkooyea; Owner: admin
--

COMMENT ON CONSTRAINT p3_audit_event_778fb9880d5c ON pb3gir75kkooyea.audit_event IS 'P3|778fb9880d5ce105037c82f8da30f1763ff5bdd00a1e931c0dfc5603b99a2d88|FOREIGN KEY (application_id) REFERENCES application(id) ON DELETE RESTRICT';


--
-- Name: audit_event p3_audit_event_8a2cbf4cf844; Type: FK CONSTRAINT; Schema: pb3gir75kkooyea; Owner: admin
--

ALTER TABLE ONLY pb3gir75kkooyea.audit_event
    ADD CONSTRAINT p3_audit_event_8a2cbf4cf844 FOREIGN KEY (actor_user_id) REFERENCES pb3gir75kkooyea.unified_user(id) ON DELETE RESTRICT;


--
-- Name: CONSTRAINT p3_audit_event_8a2cbf4cf844 ON audit_event; Type: COMMENT; Schema: pb3gir75kkooyea; Owner: admin
--

COMMENT ON CONSTRAINT p3_audit_event_8a2cbf4cf844 ON pb3gir75kkooyea.audit_event IS 'P3|8a2cbf4cf8449a473c9f48529e3af567b1e9b6d7018fce266152dad603ed4ba6|FOREIGN KEY (actor_user_id) REFERENCES unified_user(id) ON DELETE RESTRICT';


--
-- Name: identity_mapping p3_identity_mapping_62833e617dfb; Type: FK CONSTRAINT; Schema: pb3gir75kkooyea; Owner: admin
--

ALTER TABLE ONLY pb3gir75kkooyea.identity_mapping
    ADD CONSTRAINT p3_identity_mapping_62833e617dfb FOREIGN KEY (user_id) REFERENCES pb3gir75kkooyea.unified_user(id) ON DELETE RESTRICT;


--
-- Name: CONSTRAINT p3_identity_mapping_62833e617dfb ON identity_mapping; Type: COMMENT; Schema: pb3gir75kkooyea; Owner: admin
--

COMMENT ON CONSTRAINT p3_identity_mapping_62833e617dfb ON pb3gir75kkooyea.identity_mapping IS 'P3|62833e617dfb800a0d05b6346c549e081ecdabce3d8b5be3c2e9be658fdfdfaf|FOREIGN KEY (user_id) REFERENCES unified_user(id) ON DELETE RESTRICT';


--
-- Name: identity_mapping p3_identity_mapping_af7ec9fe6121; Type: FK CONSTRAINT; Schema: pb3gir75kkooyea; Owner: admin
--

ALTER TABLE ONLY pb3gir75kkooyea.identity_mapping
    ADD CONSTRAINT p3_identity_mapping_af7ec9fe6121 FOREIGN KEY (source_id) REFERENCES pb3gir75kkooyea.identity_source(id) ON DELETE RESTRICT;


--
-- Name: CONSTRAINT p3_identity_mapping_af7ec9fe6121 ON identity_mapping; Type: COMMENT; Schema: pb3gir75kkooyea; Owner: admin
--

COMMENT ON CONSTRAINT p3_identity_mapping_af7ec9fe6121 ON pb3gir75kkooyea.identity_mapping IS 'P3|af7ec9fe61211187e0f6fe4413a1c153e95e05513d6de58519f29774855cab4c|FOREIGN KEY (source_id) REFERENCES identity_source(id) ON DELETE RESTRICT';


--
-- Name: ingest_receipt p3_ingest_receipt_1e4b7e88ec4e; Type: FK CONSTRAINT; Schema: pb3gir75kkooyea; Owner: admin
--

ALTER TABLE ONLY pb3gir75kkooyea.ingest_receipt
    ADD CONSTRAINT p3_ingest_receipt_1e4b7e88ec4e FOREIGN KEY (application_id) REFERENCES pb3gir75kkooyea.application(id) ON DELETE RESTRICT;


--
-- Name: CONSTRAINT p3_ingest_receipt_1e4b7e88ec4e ON ingest_receipt; Type: COMMENT; Schema: pb3gir75kkooyea; Owner: admin
--

COMMENT ON CONSTRAINT p3_ingest_receipt_1e4b7e88ec4e ON pb3gir75kkooyea.ingest_receipt IS 'P3|1e4b7e88ec4e5180c2fa83ba076850e23130357f338cb9d0450c726e2ab56910|FOREIGN KEY (application_id) REFERENCES application(id) ON DELETE RESTRICT';


--
-- Name: login_request p3_login_request_994ccde8224b; Type: FK CONSTRAINT; Schema: pb3gir75kkooyea; Owner: admin
--

ALTER TABLE ONLY pb3gir75kkooyea.login_request
    ADD CONSTRAINT p3_login_request_994ccde8224b FOREIGN KEY (source_id) REFERENCES pb3gir75kkooyea.identity_source(id) ON DELETE RESTRICT;


--
-- Name: CONSTRAINT p3_login_request_994ccde8224b ON login_request; Type: COMMENT; Schema: pb3gir75kkooyea; Owner: admin
--

COMMENT ON CONSTRAINT p3_login_request_994ccde8224b ON pb3gir75kkooyea.login_request IS 'P3|994ccde8224b4f9fdcce43258187bbba2de00ba1087caa95a62be19bb4108f95|FOREIGN KEY (source_id) REFERENCES identity_source(id) ON DELETE RESTRICT';


--
-- Name: mapping_exception p3_mapping_exception_09aba357a39e; Type: FK CONSTRAINT; Schema: pb3gir75kkooyea; Owner: admin
--

ALTER TABLE ONLY pb3gir75kkooyea.mapping_exception
    ADD CONSTRAINT p3_mapping_exception_09aba357a39e FOREIGN KEY (mapping_id) REFERENCES pb3gir75kkooyea.application_user_mapping(id) ON DELETE RESTRICT;


--
-- Name: CONSTRAINT p3_mapping_exception_09aba357a39e ON mapping_exception; Type: COMMENT; Schema: pb3gir75kkooyea; Owner: admin
--

COMMENT ON CONSTRAINT p3_mapping_exception_09aba357a39e ON pb3gir75kkooyea.mapping_exception IS 'P3|09aba357a39ecbd7f3fd542a81126a5f6a37a6ecc20a73289fd7622ad567a79b|FOREIGN KEY (mapping_id) REFERENCES application_user_mapping(id) ON DELETE RESTRICT';


--
-- Name: mapping_exception p3_mapping_exception_17b097b399c0; Type: FK CONSTRAINT; Schema: pb3gir75kkooyea; Owner: admin
--

ALTER TABLE ONLY pb3gir75kkooyea.mapping_exception
    ADD CONSTRAINT p3_mapping_exception_17b097b399c0 FOREIGN KEY (identity_mapping_id) REFERENCES pb3gir75kkooyea.identity_mapping(id) ON DELETE RESTRICT;


--
-- Name: CONSTRAINT p3_mapping_exception_17b097b399c0 ON mapping_exception; Type: COMMENT; Schema: pb3gir75kkooyea; Owner: admin
--

COMMENT ON CONSTRAINT p3_mapping_exception_17b097b399c0 ON pb3gir75kkooyea.mapping_exception IS 'P3|17b097b399c0b804356a6152dc0016a3bf052a9e6a46ec77da42349367f1ccce|FOREIGN KEY (identity_mapping_id) REFERENCES identity_mapping(id) ON DELETE RESTRICT';


--
-- Name: mapping_exception p3_mapping_exception_7e1c3c279f94; Type: FK CONSTRAINT; Schema: pb3gir75kkooyea; Owner: admin
--

ALTER TABLE ONLY pb3gir75kkooyea.mapping_exception
    ADD CONSTRAINT p3_mapping_exception_7e1c3c279f94 FOREIGN KEY (resolved_by) REFERENCES pb3gir75kkooyea.unified_user(id) ON DELETE RESTRICT;


--
-- Name: CONSTRAINT p3_mapping_exception_7e1c3c279f94 ON mapping_exception; Type: COMMENT; Schema: pb3gir75kkooyea; Owner: admin
--

COMMENT ON CONSTRAINT p3_mapping_exception_7e1c3c279f94 ON pb3gir75kkooyea.mapping_exception IS 'P3|7e1c3c279f940bf29ab36e534b44aede702f307b06b8294c25ea20ceb9fcd54e|FOREIGN KEY (resolved_by) REFERENCES unified_user(id) ON DELETE RESTRICT';


--
-- Name: message p3_message_b7fba7ec9e24; Type: FK CONSTRAINT; Schema: pb3gir75kkooyea; Owner: admin
--

ALTER TABLE ONLY pb3gir75kkooyea.message
    ADD CONSTRAINT p3_message_b7fba7ec9e24 FOREIGN KEY (application_id) REFERENCES pb3gir75kkooyea.application(id) ON DELETE RESTRICT;


--
-- Name: CONSTRAINT p3_message_b7fba7ec9e24 ON message; Type: COMMENT; Schema: pb3gir75kkooyea; Owner: admin
--

COMMENT ON CONSTRAINT p3_message_b7fba7ec9e24 ON pb3gir75kkooyea.message IS 'P3|b7fba7ec9e244715f5b28451930ab4b7d76a9361c7c03e02e22d9d7032c1359d|FOREIGN KEY (application_id) REFERENCES application(id) ON DELETE RESTRICT';


--
-- Name: message_recipient p3_message_recipient_c8c032554f6a; Type: FK CONSTRAINT; Schema: pb3gir75kkooyea; Owner: admin
--

ALTER TABLE ONLY pb3gir75kkooyea.message_recipient
    ADD CONSTRAINT p3_message_recipient_c8c032554f6a FOREIGN KEY (user_id) REFERENCES pb3gir75kkooyea.unified_user(id) ON DELETE RESTRICT;


--
-- Name: CONSTRAINT p3_message_recipient_c8c032554f6a ON message_recipient; Type: COMMENT; Schema: pb3gir75kkooyea; Owner: admin
--

COMMENT ON CONSTRAINT p3_message_recipient_c8c032554f6a ON pb3gir75kkooyea.message_recipient IS 'P3|c8c032554f6afb46927aabe0b26b1663a5163ca52611eac5932dbfea5ce6f927|FOREIGN KEY (user_id) REFERENCES unified_user(id) ON DELETE RESTRICT';


--
-- Name: message_recipient p3_message_recipient_d1f48d95068a; Type: FK CONSTRAINT; Schema: pb3gir75kkooyea; Owner: admin
--

ALTER TABLE ONLY pb3gir75kkooyea.message_recipient
    ADD CONSTRAINT p3_message_recipient_d1f48d95068a FOREIGN KEY (message_id) REFERENCES pb3gir75kkooyea.message(id) ON DELETE RESTRICT;


--
-- Name: CONSTRAINT p3_message_recipient_d1f48d95068a ON message_recipient; Type: COMMENT; Schema: pb3gir75kkooyea; Owner: admin
--

COMMENT ON CONSTRAINT p3_message_recipient_d1f48d95068a ON pb3gir75kkooyea.message_recipient IS 'P3|d1f48d95068a9fe29787f96bcb5efbc8fe005e9f9f2465d12afb76bb54fae6ef|FOREIGN KEY (message_id) REFERENCES message(id) ON DELETE RESTRICT';


--
-- Name: portal_role_permission p3_portal_role_permission_9ec3c8569c7e; Type: FK CONSTRAINT; Schema: pb3gir75kkooyea; Owner: admin
--

ALTER TABLE ONLY pb3gir75kkooyea.portal_role_permission
    ADD CONSTRAINT p3_portal_role_permission_9ec3c8569c7e FOREIGN KEY (permission_id) REFERENCES pb3gir75kkooyea.portal_permission(id) ON DELETE RESTRICT;


--
-- Name: CONSTRAINT p3_portal_role_permission_9ec3c8569c7e ON portal_role_permission; Type: COMMENT; Schema: pb3gir75kkooyea; Owner: admin
--

COMMENT ON CONSTRAINT p3_portal_role_permission_9ec3c8569c7e ON pb3gir75kkooyea.portal_role_permission IS 'P3|9ec3c8569c7e84fbb17d6f88b0fe6b7b035e792eb282205242b9c63280146366|FOREIGN KEY (permission_id) REFERENCES portal_permission(id) ON DELETE RESTRICT';


--
-- Name: portal_role_permission p3_portal_role_permission_b6485f91b766; Type: FK CONSTRAINT; Schema: pb3gir75kkooyea; Owner: admin
--

ALTER TABLE ONLY pb3gir75kkooyea.portal_role_permission
    ADD CONSTRAINT p3_portal_role_permission_b6485f91b766 FOREIGN KEY (role_id) REFERENCES pb3gir75kkooyea.portal_role(id) ON DELETE RESTRICT;


--
-- Name: CONSTRAINT p3_portal_role_permission_b6485f91b766 ON portal_role_permission; Type: COMMENT; Schema: pb3gir75kkooyea; Owner: admin
--

COMMENT ON CONSTRAINT p3_portal_role_permission_b6485f91b766 ON pb3gir75kkooyea.portal_role_permission IS 'P3|b6485f91b76617f81c423c371171ce1ba930a3d08e9566cbb3f0481a73d1acce|FOREIGN KEY (role_id) REFERENCES portal_role(id) ON DELETE RESTRICT';


--
-- Name: portal_session p3_portal_session_49acbe904dcf; Type: FK CONSTRAINT; Schema: pb3gir75kkooyea; Owner: admin
--

ALTER TABLE ONLY pb3gir75kkooyea.portal_session
    ADD CONSTRAINT p3_portal_session_49acbe904dcf FOREIGN KEY (identity_mapping_id) REFERENCES pb3gir75kkooyea.identity_mapping(id) ON DELETE RESTRICT;


--
-- Name: CONSTRAINT p3_portal_session_49acbe904dcf ON portal_session; Type: COMMENT; Schema: pb3gir75kkooyea; Owner: admin
--

COMMENT ON CONSTRAINT p3_portal_session_49acbe904dcf ON pb3gir75kkooyea.portal_session IS 'P3|49acbe904dcfd93b8bf0dcd10e3b28db531993b2cd74dd2c867185a1bce886b4|FOREIGN KEY (identity_mapping_id) REFERENCES identity_mapping(id) ON DELETE RESTRICT';


--
-- Name: portal_session p3_portal_session_4dbb242dbc46; Type: FK CONSTRAINT; Schema: pb3gir75kkooyea; Owner: admin
--

ALTER TABLE ONLY pb3gir75kkooyea.portal_session
    ADD CONSTRAINT p3_portal_session_4dbb242dbc46 FOREIGN KEY (user_id) REFERENCES pb3gir75kkooyea.unified_user(id) ON DELETE RESTRICT;


--
-- Name: CONSTRAINT p3_portal_session_4dbb242dbc46 ON portal_session; Type: COMMENT; Schema: pb3gir75kkooyea; Owner: admin
--

COMMENT ON CONSTRAINT p3_portal_session_4dbb242dbc46 ON pb3gir75kkooyea.portal_session IS 'P3|4dbb242dbc46b9abdee1d8096e1a5bf658c67ca12b7fe03d8b5f02b435a8ed9a|FOREIGN KEY (user_id) REFERENCES unified_user(id) ON DELETE RESTRICT';


--
-- Name: portal_user_application_scope p3_portal_user_application_scop_7710f6116ca9; Type: FK CONSTRAINT; Schema: pb3gir75kkooyea; Owner: admin
--

ALTER TABLE ONLY pb3gir75kkooyea.portal_user_application_scope
    ADD CONSTRAINT p3_portal_user_application_scop_7710f6116ca9 FOREIGN KEY (application_id) REFERENCES pb3gir75kkooyea.application(id) ON DELETE RESTRICT;


--
-- Name: CONSTRAINT p3_portal_user_application_scop_7710f6116ca9 ON portal_user_application_scope; Type: COMMENT; Schema: pb3gir75kkooyea; Owner: admin
--

COMMENT ON CONSTRAINT p3_portal_user_application_scop_7710f6116ca9 ON pb3gir75kkooyea.portal_user_application_scope IS 'P3|7710f6116ca9318c6d9403567a916da6215623436d7b1be51899c4aaa47cf918|FOREIGN KEY (application_id) REFERENCES application(id) ON DELETE RESTRICT';


--
-- Name: portal_user_application_scope p3_portal_user_application_scop_9a096a6549a3; Type: FK CONSTRAINT; Schema: pb3gir75kkooyea; Owner: admin
--

ALTER TABLE ONLY pb3gir75kkooyea.portal_user_application_scope
    ADD CONSTRAINT p3_portal_user_application_scop_9a096a6549a3 FOREIGN KEY (user_id) REFERENCES pb3gir75kkooyea.unified_user(id) ON DELETE RESTRICT;


--
-- Name: CONSTRAINT p3_portal_user_application_scop_9a096a6549a3 ON portal_user_application_scope; Type: COMMENT; Schema: pb3gir75kkooyea; Owner: admin
--

COMMENT ON CONSTRAINT p3_portal_user_application_scop_9a096a6549a3 ON pb3gir75kkooyea.portal_user_application_scope IS 'P3|9a096a6549a39d915c5e4a3237b1311549af150192ea183ea285df8d3e7fcb17|FOREIGN KEY (user_id) REFERENCES unified_user(id) ON DELETE RESTRICT';


--
-- Name: portal_user_role p3_portal_user_role_0849fd7a7a80; Type: FK CONSTRAINT; Schema: pb3gir75kkooyea; Owner: admin
--

ALTER TABLE ONLY pb3gir75kkooyea.portal_user_role
    ADD CONSTRAINT p3_portal_user_role_0849fd7a7a80 FOREIGN KEY (user_id) REFERENCES pb3gir75kkooyea.unified_user(id) ON DELETE RESTRICT;


--
-- Name: CONSTRAINT p3_portal_user_role_0849fd7a7a80 ON portal_user_role; Type: COMMENT; Schema: pb3gir75kkooyea; Owner: admin
--

COMMENT ON CONSTRAINT p3_portal_user_role_0849fd7a7a80 ON pb3gir75kkooyea.portal_user_role IS 'P3|0849fd7a7a800df4ab1e5f8474c164f30e4c8233fb3d341b5c44ca2664b40c66|FOREIGN KEY (user_id) REFERENCES unified_user(id) ON DELETE RESTRICT';


--
-- Name: portal_user_role p3_portal_user_role_4a380d95e225; Type: FK CONSTRAINT; Schema: pb3gir75kkooyea; Owner: admin
--

ALTER TABLE ONLY pb3gir75kkooyea.portal_user_role
    ADD CONSTRAINT p3_portal_user_role_4a380d95e225 FOREIGN KEY (granted_by) REFERENCES pb3gir75kkooyea.unified_user(id) ON DELETE RESTRICT;


--
-- Name: CONSTRAINT p3_portal_user_role_4a380d95e225 ON portal_user_role; Type: COMMENT; Schema: pb3gir75kkooyea; Owner: admin
--

COMMENT ON CONSTRAINT p3_portal_user_role_4a380d95e225 ON pb3gir75kkooyea.portal_user_role IS 'P3|4a380d95e2256b550504a2bd84fc8128cb0b70a881f369cbbb8b535aa7930fd5|FOREIGN KEY (granted_by) REFERENCES unified_user(id) ON DELETE RESTRICT';


--
-- Name: portal_user_role p3_portal_user_role_d4208346bab7; Type: FK CONSTRAINT; Schema: pb3gir75kkooyea; Owner: admin
--

ALTER TABLE ONLY pb3gir75kkooyea.portal_user_role
    ADD CONSTRAINT p3_portal_user_role_d4208346bab7 FOREIGN KEY (role_id) REFERENCES pb3gir75kkooyea.portal_role(id) ON DELETE RESTRICT;


--
-- Name: CONSTRAINT p3_portal_user_role_d4208346bab7 ON portal_user_role; Type: COMMENT; Schema: pb3gir75kkooyea; Owner: admin
--

COMMENT ON CONSTRAINT p3_portal_user_role_d4208346bab7 ON pb3gir75kkooyea.portal_user_role IS 'P3|d4208346bab7cfa641a35a17d4d6f7be7a1354ff9053060c5f7610e05d1d9252|FOREIGN KEY (role_id) REFERENCES portal_role(id) ON DELETE RESTRICT';


--
-- Name: push_integration_config p3_push_integration_config_f8d97e1e817f; Type: FK CONSTRAINT; Schema: pb3gir75kkooyea; Owner: admin
--

ALTER TABLE ONLY pb3gir75kkooyea.push_integration_config
    ADD CONSTRAINT p3_push_integration_config_f8d97e1e817f FOREIGN KEY (application_id) REFERENCES pb3gir75kkooyea.application(id) ON DELETE RESTRICT;


--
-- Name: CONSTRAINT p3_push_integration_config_f8d97e1e817f ON push_integration_config; Type: COMMENT; Schema: pb3gir75kkooyea; Owner: admin
--

COMMENT ON CONSTRAINT p3_push_integration_config_f8d97e1e817f ON pb3gir75kkooyea.push_integration_config IS 'P3|f8d97e1e817fb5f5bfd5a87c467852b0d7d02f1185fd4fc1df1562ed920fce71|FOREIGN KEY (application_id) REFERENCES application(id) ON DELETE RESTRICT';


--
-- Name: sms_application p3_sms_application_0b07c14c86d6; Type: FK CONSTRAINT; Schema: pb3gir75kkooyea; Owner: admin
--

ALTER TABLE ONLY pb3gir75kkooyea.sms_application
    ADD CONSTRAINT p3_sms_application_0b07c14c86d6 FOREIGN KEY (application_id) REFERENCES pb3gir75kkooyea.application(id) ON DELETE RESTRICT;


--
-- Name: CONSTRAINT p3_sms_application_0b07c14c86d6 ON sms_application; Type: COMMENT; Schema: pb3gir75kkooyea; Owner: admin
--

COMMENT ON CONSTRAINT p3_sms_application_0b07c14c86d6 ON pb3gir75kkooyea.sms_application IS 'P3|0b07c14c86d672ecd0884df1f0a14e6f50f8ee04469ccf01647d7827002b722f|FOREIGN KEY (application_id) REFERENCES application(id) ON DELETE RESTRICT';


--
-- Name: sms_application_template p3_sms_application_template_7ee65161eb07; Type: FK CONSTRAINT; Schema: pb3gir75kkooyea; Owner: admin
--

ALTER TABLE ONLY pb3gir75kkooyea.sms_application_template
    ADD CONSTRAINT p3_sms_application_template_7ee65161eb07 FOREIGN KEY (sms_application_id) REFERENCES pb3gir75kkooyea.sms_application(id) ON DELETE RESTRICT;


--
-- Name: CONSTRAINT p3_sms_application_template_7ee65161eb07 ON sms_application_template; Type: COMMENT; Schema: pb3gir75kkooyea; Owner: admin
--

COMMENT ON CONSTRAINT p3_sms_application_template_7ee65161eb07 ON pb3gir75kkooyea.sms_application_template IS 'P3|7ee65161eb07607d15970ee345577c06aa56537d6b6463a6a3ca2b2883bc3540|FOREIGN KEY (sms_application_id) REFERENCES sms_application(id) ON DELETE RESTRICT';


--
-- Name: sms_application_template p3_sms_application_template_c9b65db9da01; Type: FK CONSTRAINT; Schema: pb3gir75kkooyea; Owner: admin
--

ALTER TABLE ONLY pb3gir75kkooyea.sms_application_template
    ADD CONSTRAINT p3_sms_application_template_c9b65db9da01 FOREIGN KEY (template_id) REFERENCES pb3gir75kkooyea.sms_template(id) ON DELETE RESTRICT;


--
-- Name: CONSTRAINT p3_sms_application_template_c9b65db9da01 ON sms_application_template; Type: COMMENT; Schema: pb3gir75kkooyea; Owner: admin
--

COMMENT ON CONSTRAINT p3_sms_application_template_c9b65db9da01 ON pb3gir75kkooyea.sms_application_template IS 'P3|c9b65db9da01201a40d443dcba6cd5a6c908495c02260a627affff912623b41f|FOREIGN KEY (template_id) REFERENCES sms_template(id) ON DELETE RESTRICT';


--
-- Name: sms_send_attempt p3_sms_send_attempt_8e3dd1153a6e; Type: FK CONSTRAINT; Schema: pb3gir75kkooyea; Owner: admin
--

ALTER TABLE ONLY pb3gir75kkooyea.sms_send_attempt
    ADD CONSTRAINT p3_sms_send_attempt_8e3dd1153a6e FOREIGN KEY (send_id) REFERENCES pb3gir75kkooyea.sms_send_record(id) ON DELETE RESTRICT;


--
-- Name: CONSTRAINT p3_sms_send_attempt_8e3dd1153a6e ON sms_send_attempt; Type: COMMENT; Schema: pb3gir75kkooyea; Owner: admin
--

COMMENT ON CONSTRAINT p3_sms_send_attempt_8e3dd1153a6e ON pb3gir75kkooyea.sms_send_attempt IS 'P3|8e3dd1153a6ecb7538c2e29e4ebd19606bb56f6cf1ee60db6981efc0b37b9d43|FOREIGN KEY (send_id) REFERENCES sms_send_record(id) ON DELETE RESTRICT';


--
-- Name: sms_send_record p3_sms_send_record_cc2c1a767f4b; Type: FK CONSTRAINT; Schema: pb3gir75kkooyea; Owner: admin
--

ALTER TABLE ONLY pb3gir75kkooyea.sms_send_record
    ADD CONSTRAINT p3_sms_send_record_cc2c1a767f4b FOREIGN KEY (channel_id) REFERENCES pb3gir75kkooyea.sms_channel(id) ON DELETE RESTRICT;


--
-- Name: CONSTRAINT p3_sms_send_record_cc2c1a767f4b ON sms_send_record; Type: COMMENT; Schema: pb3gir75kkooyea; Owner: admin
--

COMMENT ON CONSTRAINT p3_sms_send_record_cc2c1a767f4b ON pb3gir75kkooyea.sms_send_record IS 'P3|cc2c1a767f4b9c5ea77536382f7778b20f23272150430f203aebc7a14f78aae3|FOREIGN KEY (channel_id) REFERENCES sms_channel(id) ON DELETE RESTRICT';


--
-- Name: sms_send_record p3_sms_send_record_f56a0ea99557; Type: FK CONSTRAINT; Schema: pb3gir75kkooyea; Owner: admin
--

ALTER TABLE ONLY pb3gir75kkooyea.sms_send_record
    ADD CONSTRAINT p3_sms_send_record_f56a0ea99557 FOREIGN KEY (application_id) REFERENCES pb3gir75kkooyea.application(id) ON DELETE RESTRICT;


--
-- Name: CONSTRAINT p3_sms_send_record_f56a0ea99557 ON sms_send_record; Type: COMMENT; Schema: pb3gir75kkooyea; Owner: admin
--

COMMENT ON CONSTRAINT p3_sms_send_record_f56a0ea99557 ON pb3gir75kkooyea.sms_send_record IS 'P3|f56a0ea995576ba265b2c8b1de429b34173d87931ea8fac2795fcc612e3e827c|FOREIGN KEY (application_id) REFERENCES application(id) ON DELETE RESTRICT';


--
-- Name: sms_send_record p3_sms_send_record_f6f5f9a1e8be; Type: FK CONSTRAINT; Schema: pb3gir75kkooyea; Owner: admin
--

ALTER TABLE ONLY pb3gir75kkooyea.sms_send_record
    ADD CONSTRAINT p3_sms_send_record_f6f5f9a1e8be FOREIGN KEY (template_id) REFERENCES pb3gir75kkooyea.sms_template(id) ON DELETE RESTRICT;


--
-- Name: CONSTRAINT p3_sms_send_record_f6f5f9a1e8be ON sms_send_record; Type: COMMENT; Schema: pb3gir75kkooyea; Owner: admin
--

COMMENT ON CONSTRAINT p3_sms_send_record_f6f5f9a1e8be ON pb3gir75kkooyea.sms_send_record IS 'P3|f6f5f9a1e8be934f11485dd5fc0623d172784adc67d6b0f826d920fd3401a16d|FOREIGN KEY (template_id) REFERENCES sms_template(id) ON DELETE RESTRICT';


--
-- Name: sso_config p3_sso_config_cd9ef0de6fe5; Type: FK CONSTRAINT; Schema: pb3gir75kkooyea; Owner: admin
--

ALTER TABLE ONLY pb3gir75kkooyea.sso_config
    ADD CONSTRAINT p3_sso_config_cd9ef0de6fe5 FOREIGN KEY (application_id) REFERENCES pb3gir75kkooyea.application(id) ON DELETE RESTRICT;


--
-- Name: CONSTRAINT p3_sso_config_cd9ef0de6fe5 ON sso_config; Type: COMMENT; Schema: pb3gir75kkooyea; Owner: admin
--

COMMENT ON CONSTRAINT p3_sso_config_cd9ef0de6fe5 ON pb3gir75kkooyea.sso_config IS 'P3|cd9ef0de6fe5a43f653d1a7d7cc7dba66e66197d51afb72958ff2ff6079b6b74|FOREIGN KEY (application_id) REFERENCES application(id) ON DELETE RESTRICT';


--
-- Name: todo_item p3_todo_item_0f11dacd5396; Type: FK CONSTRAINT; Schema: pb3gir75kkooyea; Owner: admin
--

ALTER TABLE ONLY pb3gir75kkooyea.todo_item
    ADD CONSTRAINT p3_todo_item_0f11dacd5396 FOREIGN KEY (target_user_id) REFERENCES pb3gir75kkooyea.unified_user(id) ON DELETE RESTRICT;


--
-- Name: CONSTRAINT p3_todo_item_0f11dacd5396 ON todo_item; Type: COMMENT; Schema: pb3gir75kkooyea; Owner: admin
--

COMMENT ON CONSTRAINT p3_todo_item_0f11dacd5396 ON pb3gir75kkooyea.todo_item IS 'P3|0f11dacd5396fc0b63511b8de79788d21c4c5f384adabffa0451ff2efcc08fa9|FOREIGN KEY (target_user_id) REFERENCES unified_user(id) ON DELETE RESTRICT';


--
-- Name: todo_item p3_todo_item_2f904279c84d; Type: FK CONSTRAINT; Schema: pb3gir75kkooyea; Owner: admin
--

ALTER TABLE ONLY pb3gir75kkooyea.todo_item
    ADD CONSTRAINT p3_todo_item_2f904279c84d FOREIGN KEY (application_id) REFERENCES pb3gir75kkooyea.application(id) ON DELETE RESTRICT;


--
-- Name: CONSTRAINT p3_todo_item_2f904279c84d ON todo_item; Type: COMMENT; Schema: pb3gir75kkooyea; Owner: admin
--

COMMENT ON CONSTRAINT p3_todo_item_2f904279c84d ON pb3gir75kkooyea.todo_item IS 'P3|2f904279c84d4a9e59c4d65e6a2e527fbf05cc46f9ebe102ab2cfc80cf572183|FOREIGN KEY (application_id) REFERENCES application(id) ON DELETE RESTRICT';


--
-- Name: portal_runtime_entity portal_runtime_entity_resource_fkey; Type: FK CONSTRAINT; Schema: pb3gir75kkooyea; Owner: admin
--

ALTER TABLE ONLY pb3gir75kkooyea.portal_runtime_entity
    ADD CONSTRAINT portal_runtime_entity_resource_fkey FOREIGN KEY (resource) REFERENCES pb3gir75kkooyea.portal_runtime_entity_domain(resource) ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

\unrestrict RoghM5lRQwEp6tBS79a7qvFKzcS0zRMetaGzZPfTYRB0mqHg86b0tucKFwVhQc4

