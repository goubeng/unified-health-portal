-- Only the existing native project schema; no external source or platform metadata changes.
BEGIN;
SET LOCAL lock_timeout='5s';
SET LOCAL search_path="pb3gir75kkooyea",pg_catalog;
ALTER TABLE "pb3gir75kkooyea"."identity_source" ALTER COLUMN "id" SET NOT NULL;
ALTER TABLE "pb3gir75kkooyea"."identity_source" ALTER COLUMN "created_at" SET NOT NULL;
ALTER TABLE "pb3gir75kkooyea"."identity_source" ALTER COLUMN "updated_at" SET NOT NULL;
ALTER TABLE "pb3gir75kkooyea"."identity_source" ALTER COLUMN "version" SET NOT NULL;
ALTER TABLE "pb3gir75kkooyea"."identity_source" ALTER COLUMN "code" SET NOT NULL;
ALTER TABLE "pb3gir75kkooyea"."identity_source" ALTER COLUMN "name" SET NOT NULL;
ALTER TABLE "pb3gir75kkooyea"."identity_source" ALTER COLUMN "kind" SET NOT NULL;
ALTER TABLE "pb3gir75kkooyea"."identity_source" ALTER COLUMN "status" SET NOT NULL;
DO $p3$ DECLARE found_oid oid; actual text; BEGIN
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."identity_source"'::regclass AND c.conname='p3_identity_source_e4df2443e152';
 IF found_oid IS NULL THEN
 ALTER TABLE "pb3gir75kkooyea"."identity_source" ADD CONSTRAINT "p3_identity_source_e4df2443e152" UNIQUE ("id");
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."identity_source"'::regclass AND c.conname='p3_identity_source_e4df2443e152';
 EXECUTE format('COMMENT ON CONSTRAINT %I ON "pb3gir75kkooyea"."identity_source" IS %L','p3_identity_source_e4df2443e152','P3|e4df2443e1526b709e7a190b0baa8cc099868ec3799569f39b2d728497746297|'||pg_get_constraintdef(found_oid));
 ELSE
 actual:=obj_description(found_oid,'pg_constraint');
 IF actual IS DISTINCT FROM 'P3|e4df2443e1526b709e7a190b0baa8cc099868ec3799569f39b2d728497746297|'||pg_get_constraintdef(found_oid) THEN RAISE EXCEPTION 'Constraint drift: p3_identity_source_e4df2443e152'; END IF;
 END IF; END $p3$;
DO $p3$ DECLARE found_oid oid; actual text; BEGIN
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."identity_source"'::regclass AND c.conname='p3_identity_source_0689a114a9d6';
 IF found_oid IS NULL THEN
 ALTER TABLE "pb3gir75kkooyea"."identity_source" ADD CONSTRAINT "p3_identity_source_0689a114a9d6" UNIQUE ("code");
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."identity_source"'::regclass AND c.conname='p3_identity_source_0689a114a9d6';
 EXECUTE format('COMMENT ON CONSTRAINT %I ON "pb3gir75kkooyea"."identity_source" IS %L','p3_identity_source_0689a114a9d6','P3|0689a114a9d6b0685cc585b0edf48990f665522b00d69668642f35172dfbd830|'||pg_get_constraintdef(found_oid));
 ELSE
 actual:=obj_description(found_oid,'pg_constraint');
 IF actual IS DISTINCT FROM 'P3|0689a114a9d6b0685cc585b0edf48990f665522b00d69668642f35172dfbd830|'||pg_get_constraintdef(found_oid) THEN RAISE EXCEPTION 'Constraint drift: p3_identity_source_0689a114a9d6'; END IF;
 END IF; END $p3$;
ALTER TABLE "pb3gir75kkooyea"."unified_user" ALTER COLUMN "id" SET NOT NULL;
ALTER TABLE "pb3gir75kkooyea"."unified_user" ALTER COLUMN "created_at" SET NOT NULL;
ALTER TABLE "pb3gir75kkooyea"."unified_user" ALTER COLUMN "updated_at" SET NOT NULL;
ALTER TABLE "pb3gir75kkooyea"."unified_user" ALTER COLUMN "version" SET NOT NULL;
ALTER TABLE "pb3gir75kkooyea"."unified_user" ALTER COLUMN "status" SET NOT NULL;
DO $p3$ DECLARE found_oid oid; actual text; BEGIN
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."unified_user"'::regclass AND c.conname='p3_unified_user_0149343b4a66';
 IF found_oid IS NULL THEN
 ALTER TABLE "pb3gir75kkooyea"."unified_user" ADD CONSTRAINT "p3_unified_user_0149343b4a66" UNIQUE ("id");
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."unified_user"'::regclass AND c.conname='p3_unified_user_0149343b4a66';
 EXECUTE format('COMMENT ON CONSTRAINT %I ON "pb3gir75kkooyea"."unified_user" IS %L','p3_unified_user_0149343b4a66','P3|0149343b4a66db34bec2c35c0de86b57f3da933e2b5ad439ac93579c968fe007|'||pg_get_constraintdef(found_oid));
 ELSE
 actual:=obj_description(found_oid,'pg_constraint');
 IF actual IS DISTINCT FROM 'P3|0149343b4a66db34bec2c35c0de86b57f3da933e2b5ad439ac93579c968fe007|'||pg_get_constraintdef(found_oid) THEN RAISE EXCEPTION 'Constraint drift: p3_unified_user_0149343b4a66'; END IF;
 END IF; END $p3$;
ALTER TABLE "pb3gir75kkooyea"."identity_mapping" ALTER COLUMN "id" SET NOT NULL;
ALTER TABLE "pb3gir75kkooyea"."identity_mapping" ALTER COLUMN "created_at" SET NOT NULL;
ALTER TABLE "pb3gir75kkooyea"."identity_mapping" ALTER COLUMN "updated_at" SET NOT NULL;
ALTER TABLE "pb3gir75kkooyea"."identity_mapping" ALTER COLUMN "version" SET NOT NULL;
ALTER TABLE "pb3gir75kkooyea"."identity_mapping" ALTER COLUMN "user_id" SET NOT NULL;
ALTER TABLE "pb3gir75kkooyea"."identity_mapping" ALTER COLUMN "source_id" SET NOT NULL;
ALTER TABLE "pb3gir75kkooyea"."identity_mapping" ALTER COLUMN "external_subject_id" SET NOT NULL;
ALTER TABLE "pb3gir75kkooyea"."identity_mapping" ALTER COLUMN "status" SET NOT NULL;
DO $p3$ DECLARE found_oid oid; actual text; BEGIN
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."identity_mapping"'::regclass AND c.conname='p3_identity_mapping_18a8dd026e70';
 IF found_oid IS NULL THEN
 ALTER TABLE "pb3gir75kkooyea"."identity_mapping" ADD CONSTRAINT "p3_identity_mapping_18a8dd026e70" UNIQUE ("id");
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."identity_mapping"'::regclass AND c.conname='p3_identity_mapping_18a8dd026e70';
 EXECUTE format('COMMENT ON CONSTRAINT %I ON "pb3gir75kkooyea"."identity_mapping" IS %L','p3_identity_mapping_18a8dd026e70','P3|18a8dd026e70c674855145a7ac2c29a757f1fd46d5a416858362832a8d0293d6|'||pg_get_constraintdef(found_oid));
 ELSE
 actual:=obj_description(found_oid,'pg_constraint');
 IF actual IS DISTINCT FROM 'P3|18a8dd026e70c674855145a7ac2c29a757f1fd46d5a416858362832a8d0293d6|'||pg_get_constraintdef(found_oid) THEN RAISE EXCEPTION 'Constraint drift: p3_identity_mapping_18a8dd026e70'; END IF;
 END IF; END $p3$;
DO $p3$ DECLARE found_oid oid; actual text; BEGIN
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."identity_mapping"'::regclass AND c.conname='p3_identity_mapping_f67d97f97d43';
 IF found_oid IS NULL THEN
 ALTER TABLE "pb3gir75kkooyea"."identity_mapping" ADD CONSTRAINT "p3_identity_mapping_f67d97f97d43" UNIQUE ("source_id","external_subject_id");
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."identity_mapping"'::regclass AND c.conname='p3_identity_mapping_f67d97f97d43';
 EXECUTE format('COMMENT ON CONSTRAINT %I ON "pb3gir75kkooyea"."identity_mapping" IS %L','p3_identity_mapping_f67d97f97d43','P3|f67d97f97d43cd9b3c0a5c8f7e31bb2566ee8dd7a89461b8397f997ddfa33fda|'||pg_get_constraintdef(found_oid));
 ELSE
 actual:=obj_description(found_oid,'pg_constraint');
 IF actual IS DISTINCT FROM 'P3|f67d97f97d43cd9b3c0a5c8f7e31bb2566ee8dd7a89461b8397f997ddfa33fda|'||pg_get_constraintdef(found_oid) THEN RAISE EXCEPTION 'Constraint drift: p3_identity_mapping_f67d97f97d43'; END IF;
 END IF; END $p3$;
ALTER TABLE "pb3gir75kkooyea"."login_request" ALTER COLUMN "id" SET NOT NULL;
ALTER TABLE "pb3gir75kkooyea"."login_request" ALTER COLUMN "created_at" SET NOT NULL;
ALTER TABLE "pb3gir75kkooyea"."login_request" ALTER COLUMN "updated_at" SET NOT NULL;
ALTER TABLE "pb3gir75kkooyea"."login_request" ALTER COLUMN "version" SET NOT NULL;
ALTER TABLE "pb3gir75kkooyea"."login_request" ALTER COLUMN "source_id" SET NOT NULL;
ALTER TABLE "pb3gir75kkooyea"."login_request" ALTER COLUMN "state_hash" SET NOT NULL;
ALTER TABLE "pb3gir75kkooyea"."login_request" ALTER COLUMN "method" SET NOT NULL;
ALTER TABLE "pb3gir75kkooyea"."login_request" ALTER COLUMN "status" SET NOT NULL;
ALTER TABLE "pb3gir75kkooyea"."login_request" ALTER COLUMN "expires_at" SET NOT NULL;
DO $p3$ DECLARE found_oid oid; actual text; BEGIN
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."login_request"'::regclass AND c.conname='p3_login_request_a33555e7fbee';
 IF found_oid IS NULL THEN
 ALTER TABLE "pb3gir75kkooyea"."login_request" ADD CONSTRAINT "p3_login_request_a33555e7fbee" UNIQUE ("id");
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."login_request"'::regclass AND c.conname='p3_login_request_a33555e7fbee';
 EXECUTE format('COMMENT ON CONSTRAINT %I ON "pb3gir75kkooyea"."login_request" IS %L','p3_login_request_a33555e7fbee','P3|a33555e7fbeefbbc8ccb27ef4aaec612f70c11ee3bd6a8a783fbc2887bd7e179|'||pg_get_constraintdef(found_oid));
 ELSE
 actual:=obj_description(found_oid,'pg_constraint');
 IF actual IS DISTINCT FROM 'P3|a33555e7fbeefbbc8ccb27ef4aaec612f70c11ee3bd6a8a783fbc2887bd7e179|'||pg_get_constraintdef(found_oid) THEN RAISE EXCEPTION 'Constraint drift: p3_login_request_a33555e7fbee'; END IF;
 END IF; END $p3$;
DO $p3$ DECLARE found_oid oid; actual text; BEGIN
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."login_request"'::regclass AND c.conname='p3_login_request_46f37df1c326';
 IF found_oid IS NULL THEN
 ALTER TABLE "pb3gir75kkooyea"."login_request" ADD CONSTRAINT "p3_login_request_46f37df1c326" UNIQUE ("state_hash");
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."login_request"'::regclass AND c.conname='p3_login_request_46f37df1c326';
 EXECUTE format('COMMENT ON CONSTRAINT %I ON "pb3gir75kkooyea"."login_request" IS %L','p3_login_request_46f37df1c326','P3|46f37df1c326241bed4ac98d7c8b7813fca3ed1bba3bfd0ea32b04e6dceacec3|'||pg_get_constraintdef(found_oid));
 ELSE
 actual:=obj_description(found_oid,'pg_constraint');
 IF actual IS DISTINCT FROM 'P3|46f37df1c326241bed4ac98d7c8b7813fca3ed1bba3bfd0ea32b04e6dceacec3|'||pg_get_constraintdef(found_oid) THEN RAISE EXCEPTION 'Constraint drift: p3_login_request_46f37df1c326'; END IF;
 END IF; END $p3$;
ALTER TABLE "pb3gir75kkooyea"."portal_session" ALTER COLUMN "id" SET NOT NULL;
ALTER TABLE "pb3gir75kkooyea"."portal_session" ALTER COLUMN "created_at" SET NOT NULL;
ALTER TABLE "pb3gir75kkooyea"."portal_session" ALTER COLUMN "updated_at" SET NOT NULL;
ALTER TABLE "pb3gir75kkooyea"."portal_session" ALTER COLUMN "version" SET NOT NULL;
ALTER TABLE "pb3gir75kkooyea"."portal_session" ALTER COLUMN "user_id" SET NOT NULL;
ALTER TABLE "pb3gir75kkooyea"."portal_session" ALTER COLUMN "identity_mapping_id" SET NOT NULL;
ALTER TABLE "pb3gir75kkooyea"."portal_session" ALTER COLUMN "token_hash" SET NOT NULL;
ALTER TABLE "pb3gir75kkooyea"."portal_session" ALTER COLUMN "expires_at" SET NOT NULL;
DO $p3$ DECLARE found_oid oid; actual text; BEGIN
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."portal_session"'::regclass AND c.conname='p3_portal_session_cba190749d74';
 IF found_oid IS NULL THEN
 ALTER TABLE "pb3gir75kkooyea"."portal_session" ADD CONSTRAINT "p3_portal_session_cba190749d74" UNIQUE ("id");
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."portal_session"'::regclass AND c.conname='p3_portal_session_cba190749d74';
 EXECUTE format('COMMENT ON CONSTRAINT %I ON "pb3gir75kkooyea"."portal_session" IS %L','p3_portal_session_cba190749d74','P3|cba190749d747021c69bbf29f61ccc57db1c94b3865eff1cfae0b76da5b95e0c|'||pg_get_constraintdef(found_oid));
 ELSE
 actual:=obj_description(found_oid,'pg_constraint');
 IF actual IS DISTINCT FROM 'P3|cba190749d747021c69bbf29f61ccc57db1c94b3865eff1cfae0b76da5b95e0c|'||pg_get_constraintdef(found_oid) THEN RAISE EXCEPTION 'Constraint drift: p3_portal_session_cba190749d74'; END IF;
 END IF; END $p3$;
DO $p3$ DECLARE found_oid oid; actual text; BEGIN
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."portal_session"'::regclass AND c.conname='p3_portal_session_92e3b4512417';
 IF found_oid IS NULL THEN
 ALTER TABLE "pb3gir75kkooyea"."portal_session" ADD CONSTRAINT "p3_portal_session_92e3b4512417" UNIQUE ("token_hash");
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."portal_session"'::regclass AND c.conname='p3_portal_session_92e3b4512417';
 EXECUTE format('COMMENT ON CONSTRAINT %I ON "pb3gir75kkooyea"."portal_session" IS %L','p3_portal_session_92e3b4512417','P3|92e3b4512417ec00726a339f657894376385bd253b8cd38a57f7e02018b6e5bf|'||pg_get_constraintdef(found_oid));
 ELSE
 actual:=obj_description(found_oid,'pg_constraint');
 IF actual IS DISTINCT FROM 'P3|92e3b4512417ec00726a339f657894376385bd253b8cd38a57f7e02018b6e5bf|'||pg_get_constraintdef(found_oid) THEN RAISE EXCEPTION 'Constraint drift: p3_portal_session_92e3b4512417'; END IF;
 END IF; END $p3$;
ALTER TABLE "pb3gir75kkooyea"."application_category" ALTER COLUMN "id" SET NOT NULL;
ALTER TABLE "pb3gir75kkooyea"."application_category" ALTER COLUMN "created_at" SET NOT NULL;
ALTER TABLE "pb3gir75kkooyea"."application_category" ALTER COLUMN "updated_at" SET NOT NULL;
ALTER TABLE "pb3gir75kkooyea"."application_category" ALTER COLUMN "version" SET NOT NULL;
ALTER TABLE "pb3gir75kkooyea"."application_category" ALTER COLUMN "code" SET NOT NULL;
ALTER TABLE "pb3gir75kkooyea"."application_category" ALTER COLUMN "name" SET NOT NULL;
ALTER TABLE "pb3gir75kkooyea"."application_category" ALTER COLUMN "sort_order" SET NOT NULL;
ALTER TABLE "pb3gir75kkooyea"."application_category" ALTER COLUMN "status" SET NOT NULL;
DO $p3$ DECLARE found_oid oid; actual text; BEGIN
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."application_category"'::regclass AND c.conname='p3_application_category_3cf1121643dc';
 IF found_oid IS NULL THEN
 ALTER TABLE "pb3gir75kkooyea"."application_category" ADD CONSTRAINT "p3_application_category_3cf1121643dc" UNIQUE ("id");
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."application_category"'::regclass AND c.conname='p3_application_category_3cf1121643dc';
 EXECUTE format('COMMENT ON CONSTRAINT %I ON "pb3gir75kkooyea"."application_category" IS %L','p3_application_category_3cf1121643dc','P3|3cf1121643dc1a05652f8d4babfb65d23616ca140fc88e3f4c34ae7d2b3419cc|'||pg_get_constraintdef(found_oid));
 ELSE
 actual:=obj_description(found_oid,'pg_constraint');
 IF actual IS DISTINCT FROM 'P3|3cf1121643dc1a05652f8d4babfb65d23616ca140fc88e3f4c34ae7d2b3419cc|'||pg_get_constraintdef(found_oid) THEN RAISE EXCEPTION 'Constraint drift: p3_application_category_3cf1121643dc'; END IF;
 END IF; END $p3$;
DO $p3$ DECLARE found_oid oid; actual text; BEGIN
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."application_category"'::regclass AND c.conname='p3_application_category_da6cb970b128';
 IF found_oid IS NULL THEN
 ALTER TABLE "pb3gir75kkooyea"."application_category" ADD CONSTRAINT "p3_application_category_da6cb970b128" UNIQUE ("code");
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."application_category"'::regclass AND c.conname='p3_application_category_da6cb970b128';
 EXECUTE format('COMMENT ON CONSTRAINT %I ON "pb3gir75kkooyea"."application_category" IS %L','p3_application_category_da6cb970b128','P3|da6cb970b1281f30cf23e4d3d2bed8b02e7a96a1c82aaf5f81c93dfc2e6f04ad|'||pg_get_constraintdef(found_oid));
 ELSE
 actual:=obj_description(found_oid,'pg_constraint');
 IF actual IS DISTINCT FROM 'P3|da6cb970b1281f30cf23e4d3d2bed8b02e7a96a1c82aaf5f81c93dfc2e6f04ad|'||pg_get_constraintdef(found_oid) THEN RAISE EXCEPTION 'Constraint drift: p3_application_category_da6cb970b128'; END IF;
 END IF; END $p3$;
ALTER TABLE "pb3gir75kkooyea"."application" ALTER COLUMN "id" SET NOT NULL;
ALTER TABLE "pb3gir75kkooyea"."application" ALTER COLUMN "created_at" SET NOT NULL;
ALTER TABLE "pb3gir75kkooyea"."application" ALTER COLUMN "updated_at" SET NOT NULL;
ALTER TABLE "pb3gir75kkooyea"."application" ALTER COLUMN "version" SET NOT NULL;
ALTER TABLE "pb3gir75kkooyea"."application" ALTER COLUMN "code" SET NOT NULL;
ALTER TABLE "pb3gir75kkooyea"."application" ALTER COLUMN "name" SET NOT NULL;
ALTER TABLE "pb3gir75kkooyea"."application" ALTER COLUMN "user_type" SET NOT NULL;
ALTER TABLE "pb3gir75kkooyea"."application" ALTER COLUMN "application_url" SET NOT NULL;
ALTER TABLE "pb3gir75kkooyea"."application" ALTER COLUMN "sort_order" SET NOT NULL;
ALTER TABLE "pb3gir75kkooyea"."application" ALTER COLUMN "status" SET NOT NULL;
ALTER TABLE "pb3gir75kkooyea"."application" ALTER COLUMN "runtime_status" SET NOT NULL;
ALTER TABLE "pb3gir75kkooyea"."application" ALTER COLUMN "allowed_origins" SET NOT NULL;
ALTER TABLE "pb3gir75kkooyea"."application" ALTER COLUMN "binding_methods" SET NOT NULL;
DO $p3$ DECLARE found_oid oid; actual text; BEGIN
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."application"'::regclass AND c.conname='p3_application_4fde16c08d4f';
 IF found_oid IS NULL THEN
 ALTER TABLE "pb3gir75kkooyea"."application" ADD CONSTRAINT "p3_application_4fde16c08d4f" UNIQUE ("id");
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."application"'::regclass AND c.conname='p3_application_4fde16c08d4f';
 EXECUTE format('COMMENT ON CONSTRAINT %I ON "pb3gir75kkooyea"."application" IS %L','p3_application_4fde16c08d4f','P3|4fde16c08d4f9eb3cbaf24907474660b48021a4a2bffc60ab29349388f191fa3|'||pg_get_constraintdef(found_oid));
 ELSE
 actual:=obj_description(found_oid,'pg_constraint');
 IF actual IS DISTINCT FROM 'P3|4fde16c08d4f9eb3cbaf24907474660b48021a4a2bffc60ab29349388f191fa3|'||pg_get_constraintdef(found_oid) THEN RAISE EXCEPTION 'Constraint drift: p3_application_4fde16c08d4f'; END IF;
 END IF; END $p3$;
DO $p3$ DECLARE found_oid oid; actual text; BEGIN
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."application"'::regclass AND c.conname='p3_application_cfb451ab6703';
 IF found_oid IS NULL THEN
 ALTER TABLE "pb3gir75kkooyea"."application" ADD CONSTRAINT "p3_application_cfb451ab6703" UNIQUE ("code");
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."application"'::regclass AND c.conname='p3_application_cfb451ab6703';
 EXECUTE format('COMMENT ON CONSTRAINT %I ON "pb3gir75kkooyea"."application" IS %L','p3_application_cfb451ab6703','P3|cfb451ab67031f777c583c74000a3145d7c0bb6a5b7e355d9431ebb6b56c2d9e|'||pg_get_constraintdef(found_oid));
 ELSE
 actual:=obj_description(found_oid,'pg_constraint');
 IF actual IS DISTINCT FROM 'P3|cfb451ab67031f777c583c74000a3145d7c0bb6a5b7e355d9431ebb6b56c2d9e|'||pg_get_constraintdef(found_oid) THEN RAISE EXCEPTION 'Constraint drift: p3_application_cfb451ab6703'; END IF;
 END IF; END $p3$;
ALTER TABLE "pb3gir75kkooyea"."application_user_mapping" ALTER COLUMN "id" SET NOT NULL;
ALTER TABLE "pb3gir75kkooyea"."application_user_mapping" ALTER COLUMN "created_at" SET NOT NULL;
ALTER TABLE "pb3gir75kkooyea"."application_user_mapping" ALTER COLUMN "updated_at" SET NOT NULL;
ALTER TABLE "pb3gir75kkooyea"."application_user_mapping" ALTER COLUMN "version" SET NOT NULL;
ALTER TABLE "pb3gir75kkooyea"."application_user_mapping" ALTER COLUMN "user_id" SET NOT NULL;
ALTER TABLE "pb3gir75kkooyea"."application_user_mapping" ALTER COLUMN "application_id" SET NOT NULL;
ALTER TABLE "pb3gir75kkooyea"."application_user_mapping" ALTER COLUMN "status" SET NOT NULL;
DO $p3$ DECLARE found_oid oid; actual text; BEGIN
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."application_user_mapping"'::regclass AND c.conname='p3_application_user_mapping_35c1daeac504';
 IF found_oid IS NULL THEN
 ALTER TABLE "pb3gir75kkooyea"."application_user_mapping" ADD CONSTRAINT "p3_application_user_mapping_35c1daeac504" UNIQUE ("id");
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."application_user_mapping"'::regclass AND c.conname='p3_application_user_mapping_35c1daeac504';
 EXECUTE format('COMMENT ON CONSTRAINT %I ON "pb3gir75kkooyea"."application_user_mapping" IS %L','p3_application_user_mapping_35c1daeac504','P3|35c1daeac504cf5532058567db95b8d4dc0ccafd6cd9c7703a2e972151ce1bd5|'||pg_get_constraintdef(found_oid));
 ELSE
 actual:=obj_description(found_oid,'pg_constraint');
 IF actual IS DISTINCT FROM 'P3|35c1daeac504cf5532058567db95b8d4dc0ccafd6cd9c7703a2e972151ce1bd5|'||pg_get_constraintdef(found_oid) THEN RAISE EXCEPTION 'Constraint drift: p3_application_user_mapping_35c1daeac504'; END IF;
 END IF; END $p3$;
DO $p3$ DECLARE found_oid oid; actual text; BEGIN
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."application_user_mapping"'::regclass AND c.conname='p3_application_user_mapping_831b242929dc';
 IF found_oid IS NULL THEN
 ALTER TABLE "pb3gir75kkooyea"."application_user_mapping" ADD CONSTRAINT "p3_application_user_mapping_831b242929dc" UNIQUE ("user_id","application_id");
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."application_user_mapping"'::regclass AND c.conname='p3_application_user_mapping_831b242929dc';
 EXECUTE format('COMMENT ON CONSTRAINT %I ON "pb3gir75kkooyea"."application_user_mapping" IS %L','p3_application_user_mapping_831b242929dc','P3|831b242929dc2fbca7faf401d96f3a4a657444e4613d533e9a2858ccd132c2d3|'||pg_get_constraintdef(found_oid));
 ELSE
 actual:=obj_description(found_oid,'pg_constraint');
 IF actual IS DISTINCT FROM 'P3|831b242929dc2fbca7faf401d96f3a4a657444e4613d533e9a2858ccd132c2d3|'||pg_get_constraintdef(found_oid) THEN RAISE EXCEPTION 'Constraint drift: p3_application_user_mapping_831b242929dc'; END IF;
 END IF; END $p3$;
DO $p3$ DECLARE found_oid oid; actual text; BEGIN
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."application_user_mapping"'::regclass AND c.conname='p3_application_user_mapping_d8bb35ef9764';
 IF found_oid IS NULL THEN
 ALTER TABLE "pb3gir75kkooyea"."application_user_mapping" ADD CONSTRAINT "p3_application_user_mapping_d8bb35ef9764" UNIQUE ("active_account_key");
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."application_user_mapping"'::regclass AND c.conname='p3_application_user_mapping_d8bb35ef9764';
 EXECUTE format('COMMENT ON CONSTRAINT %I ON "pb3gir75kkooyea"."application_user_mapping" IS %L','p3_application_user_mapping_d8bb35ef9764','P3|d8bb35ef976420cd37422fc91248bd637d3a1be9226917936a7299872536e85c|'||pg_get_constraintdef(found_oid));
 ELSE
 actual:=obj_description(found_oid,'pg_constraint');
 IF actual IS DISTINCT FROM 'P3|d8bb35ef976420cd37422fc91248bd637d3a1be9226917936a7299872536e85c|'||pg_get_constraintdef(found_oid) THEN RAISE EXCEPTION 'Constraint drift: p3_application_user_mapping_d8bb35ef9764'; END IF;
 END IF; END $p3$;
ALTER TABLE "pb3gir75kkooyea"."mapping_exception" ALTER COLUMN "id" SET NOT NULL;
ALTER TABLE "pb3gir75kkooyea"."mapping_exception" ALTER COLUMN "created_at" SET NOT NULL;
ALTER TABLE "pb3gir75kkooyea"."mapping_exception" ALTER COLUMN "updated_at" SET NOT NULL;
ALTER TABLE "pb3gir75kkooyea"."mapping_exception" ALTER COLUMN "version" SET NOT NULL;
ALTER TABLE "pb3gir75kkooyea"."mapping_exception" ALTER COLUMN "exception_type" SET NOT NULL;
ALTER TABLE "pb3gir75kkooyea"."mapping_exception" ALTER COLUMN "summary" SET NOT NULL;
ALTER TABLE "pb3gir75kkooyea"."mapping_exception" ALTER COLUMN "resolution_status" SET NOT NULL;
DO $p3$ DECLARE found_oid oid; actual text; BEGIN
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."mapping_exception"'::regclass AND c.conname='p3_mapping_exception_c716c437b289';
 IF found_oid IS NULL THEN
 ALTER TABLE "pb3gir75kkooyea"."mapping_exception" ADD CONSTRAINT "p3_mapping_exception_c716c437b289" UNIQUE ("id");
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."mapping_exception"'::regclass AND c.conname='p3_mapping_exception_c716c437b289';
 EXECUTE format('COMMENT ON CONSTRAINT %I ON "pb3gir75kkooyea"."mapping_exception" IS %L','p3_mapping_exception_c716c437b289','P3|c716c437b289c77b9ec73a7fd42265a66d58a5886208626eadc2582854c4279e|'||pg_get_constraintdef(found_oid));
 ELSE
 actual:=obj_description(found_oid,'pg_constraint');
 IF actual IS DISTINCT FROM 'P3|c716c437b289c77b9ec73a7fd42265a66d58a5886208626eadc2582854c4279e|'||pg_get_constraintdef(found_oid) THEN RAISE EXCEPTION 'Constraint drift: p3_mapping_exception_c716c437b289'; END IF;
 END IF; END $p3$;
ALTER TABLE "pb3gir75kkooyea"."portal_role" ALTER COLUMN "id" SET NOT NULL;
ALTER TABLE "pb3gir75kkooyea"."portal_role" ALTER COLUMN "created_at" SET NOT NULL;
ALTER TABLE "pb3gir75kkooyea"."portal_role" ALTER COLUMN "updated_at" SET NOT NULL;
ALTER TABLE "pb3gir75kkooyea"."portal_role" ALTER COLUMN "version" SET NOT NULL;
ALTER TABLE "pb3gir75kkooyea"."portal_role" ALTER COLUMN "code" SET NOT NULL;
ALTER TABLE "pb3gir75kkooyea"."portal_role" ALTER COLUMN "name" SET NOT NULL;
ALTER TABLE "pb3gir75kkooyea"."portal_role" ALTER COLUMN "status" SET NOT NULL;
DO $p3$ DECLARE found_oid oid; actual text; BEGIN
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."portal_role"'::regclass AND c.conname='p3_portal_role_4aabf4421a0b';
 IF found_oid IS NULL THEN
 ALTER TABLE "pb3gir75kkooyea"."portal_role" ADD CONSTRAINT "p3_portal_role_4aabf4421a0b" UNIQUE ("id");
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."portal_role"'::regclass AND c.conname='p3_portal_role_4aabf4421a0b';
 EXECUTE format('COMMENT ON CONSTRAINT %I ON "pb3gir75kkooyea"."portal_role" IS %L','p3_portal_role_4aabf4421a0b','P3|4aabf4421a0bebe1e8e524df6eb3be0b7a9571c7485d73507b99e388b6b210ce|'||pg_get_constraintdef(found_oid));
 ELSE
 actual:=obj_description(found_oid,'pg_constraint');
 IF actual IS DISTINCT FROM 'P3|4aabf4421a0bebe1e8e524df6eb3be0b7a9571c7485d73507b99e388b6b210ce|'||pg_get_constraintdef(found_oid) THEN RAISE EXCEPTION 'Constraint drift: p3_portal_role_4aabf4421a0b'; END IF;
 END IF; END $p3$;
DO $p3$ DECLARE found_oid oid; actual text; BEGIN
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."portal_role"'::regclass AND c.conname='p3_portal_role_da9dde266d41';
 IF found_oid IS NULL THEN
 ALTER TABLE "pb3gir75kkooyea"."portal_role" ADD CONSTRAINT "p3_portal_role_da9dde266d41" UNIQUE ("code");
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."portal_role"'::regclass AND c.conname='p3_portal_role_da9dde266d41';
 EXECUTE format('COMMENT ON CONSTRAINT %I ON "pb3gir75kkooyea"."portal_role" IS %L','p3_portal_role_da9dde266d41','P3|da9dde266d41e1ad64358b3bfc27f471131bdabb824f7b1a57b98db283da5bea|'||pg_get_constraintdef(found_oid));
 ELSE
 actual:=obj_description(found_oid,'pg_constraint');
 IF actual IS DISTINCT FROM 'P3|da9dde266d41e1ad64358b3bfc27f471131bdabb824f7b1a57b98db283da5bea|'||pg_get_constraintdef(found_oid) THEN RAISE EXCEPTION 'Constraint drift: p3_portal_role_da9dde266d41'; END IF;
 END IF; END $p3$;
ALTER TABLE "pb3gir75kkooyea"."portal_permission" ALTER COLUMN "id" SET NOT NULL;
ALTER TABLE "pb3gir75kkooyea"."portal_permission" ALTER COLUMN "created_at" SET NOT NULL;
ALTER TABLE "pb3gir75kkooyea"."portal_permission" ALTER COLUMN "updated_at" SET NOT NULL;
ALTER TABLE "pb3gir75kkooyea"."portal_permission" ALTER COLUMN "version" SET NOT NULL;
ALTER TABLE "pb3gir75kkooyea"."portal_permission" ALTER COLUMN "code" SET NOT NULL;
ALTER TABLE "pb3gir75kkooyea"."portal_permission" ALTER COLUMN "name" SET NOT NULL;
ALTER TABLE "pb3gir75kkooyea"."portal_permission" ALTER COLUMN "kind" SET NOT NULL;
DO $p3$ DECLARE found_oid oid; actual text; BEGIN
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."portal_permission"'::regclass AND c.conname='p3_portal_permission_2a594cad779c';
 IF found_oid IS NULL THEN
 ALTER TABLE "pb3gir75kkooyea"."portal_permission" ADD CONSTRAINT "p3_portal_permission_2a594cad779c" UNIQUE ("id");
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."portal_permission"'::regclass AND c.conname='p3_portal_permission_2a594cad779c';
 EXECUTE format('COMMENT ON CONSTRAINT %I ON "pb3gir75kkooyea"."portal_permission" IS %L','p3_portal_permission_2a594cad779c','P3|2a594cad779c5aea2bd691f50582f222ed96e8ced1b642c9be685700c2d33886|'||pg_get_constraintdef(found_oid));
 ELSE
 actual:=obj_description(found_oid,'pg_constraint');
 IF actual IS DISTINCT FROM 'P3|2a594cad779c5aea2bd691f50582f222ed96e8ced1b642c9be685700c2d33886|'||pg_get_constraintdef(found_oid) THEN RAISE EXCEPTION 'Constraint drift: p3_portal_permission_2a594cad779c'; END IF;
 END IF; END $p3$;
DO $p3$ DECLARE found_oid oid; actual text; BEGIN
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."portal_permission"'::regclass AND c.conname='p3_portal_permission_6dc8d2abeefd';
 IF found_oid IS NULL THEN
 ALTER TABLE "pb3gir75kkooyea"."portal_permission" ADD CONSTRAINT "p3_portal_permission_6dc8d2abeefd" UNIQUE ("code");
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."portal_permission"'::regclass AND c.conname='p3_portal_permission_6dc8d2abeefd';
 EXECUTE format('COMMENT ON CONSTRAINT %I ON "pb3gir75kkooyea"."portal_permission" IS %L','p3_portal_permission_6dc8d2abeefd','P3|6dc8d2abeefd6d53a6ca09724bc7cbe479d9caa616c1c28acc2c5bb8b2d924dc|'||pg_get_constraintdef(found_oid));
 ELSE
 actual:=obj_description(found_oid,'pg_constraint');
 IF actual IS DISTINCT FROM 'P3|6dc8d2abeefd6d53a6ca09724bc7cbe479d9caa616c1c28acc2c5bb8b2d924dc|'||pg_get_constraintdef(found_oid) THEN RAISE EXCEPTION 'Constraint drift: p3_portal_permission_6dc8d2abeefd'; END IF;
 END IF; END $p3$;
ALTER TABLE "pb3gir75kkooyea"."portal_role_permission" ALTER COLUMN "id" SET NOT NULL;
ALTER TABLE "pb3gir75kkooyea"."portal_role_permission" ALTER COLUMN "created_at" SET NOT NULL;
ALTER TABLE "pb3gir75kkooyea"."portal_role_permission" ALTER COLUMN "updated_at" SET NOT NULL;
ALTER TABLE "pb3gir75kkooyea"."portal_role_permission" ALTER COLUMN "version" SET NOT NULL;
ALTER TABLE "pb3gir75kkooyea"."portal_role_permission" ALTER COLUMN "role_id" SET NOT NULL;
ALTER TABLE "pb3gir75kkooyea"."portal_role_permission" ALTER COLUMN "permission_id" SET NOT NULL;
ALTER TABLE "pb3gir75kkooyea"."portal_role_permission" ALTER COLUMN "data_scope" SET NOT NULL;
DO $p3$ DECLARE found_oid oid; actual text; BEGIN
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."portal_role_permission"'::regclass AND c.conname='p3_portal_role_permission_49169e28ed77';
 IF found_oid IS NULL THEN
 ALTER TABLE "pb3gir75kkooyea"."portal_role_permission" ADD CONSTRAINT "p3_portal_role_permission_49169e28ed77" UNIQUE ("id");
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."portal_role_permission"'::regclass AND c.conname='p3_portal_role_permission_49169e28ed77';
 EXECUTE format('COMMENT ON CONSTRAINT %I ON "pb3gir75kkooyea"."portal_role_permission" IS %L','p3_portal_role_permission_49169e28ed77','P3|49169e28ed77ca8a6cb7c12491ee9f92d82769458b1da7149565f5a85e0595e1|'||pg_get_constraintdef(found_oid));
 ELSE
 actual:=obj_description(found_oid,'pg_constraint');
 IF actual IS DISTINCT FROM 'P3|49169e28ed77ca8a6cb7c12491ee9f92d82769458b1da7149565f5a85e0595e1|'||pg_get_constraintdef(found_oid) THEN RAISE EXCEPTION 'Constraint drift: p3_portal_role_permission_49169e28ed77'; END IF;
 END IF; END $p3$;
DO $p3$ DECLARE found_oid oid; actual text; BEGIN
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."portal_role_permission"'::regclass AND c.conname='p3_portal_role_permission_474fa22bd913';
 IF found_oid IS NULL THEN
 ALTER TABLE "pb3gir75kkooyea"."portal_role_permission" ADD CONSTRAINT "p3_portal_role_permission_474fa22bd913" UNIQUE ("role_id","permission_id");
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."portal_role_permission"'::regclass AND c.conname='p3_portal_role_permission_474fa22bd913';
 EXECUTE format('COMMENT ON CONSTRAINT %I ON "pb3gir75kkooyea"."portal_role_permission" IS %L','p3_portal_role_permission_474fa22bd913','P3|474fa22bd913aefa4863cbfe7fe9da171c90927def403c2873d53a75365ca325|'||pg_get_constraintdef(found_oid));
 ELSE
 actual:=obj_description(found_oid,'pg_constraint');
 IF actual IS DISTINCT FROM 'P3|474fa22bd913aefa4863cbfe7fe9da171c90927def403c2873d53a75365ca325|'||pg_get_constraintdef(found_oid) THEN RAISE EXCEPTION 'Constraint drift: p3_portal_role_permission_474fa22bd913'; END IF;
 END IF; END $p3$;
ALTER TABLE "pb3gir75kkooyea"."portal_user_role" ALTER COLUMN "id" SET NOT NULL;
ALTER TABLE "pb3gir75kkooyea"."portal_user_role" ALTER COLUMN "created_at" SET NOT NULL;
ALTER TABLE "pb3gir75kkooyea"."portal_user_role" ALTER COLUMN "updated_at" SET NOT NULL;
ALTER TABLE "pb3gir75kkooyea"."portal_user_role" ALTER COLUMN "version" SET NOT NULL;
ALTER TABLE "pb3gir75kkooyea"."portal_user_role" ALTER COLUMN "user_id" SET NOT NULL;
ALTER TABLE "pb3gir75kkooyea"."portal_user_role" ALTER COLUMN "role_id" SET NOT NULL;
ALTER TABLE "pb3gir75kkooyea"."portal_user_role" ALTER COLUMN "granted_by" SET NOT NULL;
DO $p3$ DECLARE found_oid oid; actual text; BEGIN
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."portal_user_role"'::regclass AND c.conname='p3_portal_user_role_305fe4923b3d';
 IF found_oid IS NULL THEN
 ALTER TABLE "pb3gir75kkooyea"."portal_user_role" ADD CONSTRAINT "p3_portal_user_role_305fe4923b3d" UNIQUE ("id");
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."portal_user_role"'::regclass AND c.conname='p3_portal_user_role_305fe4923b3d';
 EXECUTE format('COMMENT ON CONSTRAINT %I ON "pb3gir75kkooyea"."portal_user_role" IS %L','p3_portal_user_role_305fe4923b3d','P3|305fe4923b3d1feb4297aea110766d9a7a0021cb6d26e49c7f7506c50b65b7b7|'||pg_get_constraintdef(found_oid));
 ELSE
 actual:=obj_description(found_oid,'pg_constraint');
 IF actual IS DISTINCT FROM 'P3|305fe4923b3d1feb4297aea110766d9a7a0021cb6d26e49c7f7506c50b65b7b7|'||pg_get_constraintdef(found_oid) THEN RAISE EXCEPTION 'Constraint drift: p3_portal_user_role_305fe4923b3d'; END IF;
 END IF; END $p3$;
DO $p3$ DECLARE found_oid oid; actual text; BEGIN
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."portal_user_role"'::regclass AND c.conname='p3_portal_user_role_5001293f8b94';
 IF found_oid IS NULL THEN
 ALTER TABLE "pb3gir75kkooyea"."portal_user_role" ADD CONSTRAINT "p3_portal_user_role_5001293f8b94" UNIQUE ("user_id","role_id");
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."portal_user_role"'::regclass AND c.conname='p3_portal_user_role_5001293f8b94';
 EXECUTE format('COMMENT ON CONSTRAINT %I ON "pb3gir75kkooyea"."portal_user_role" IS %L','p3_portal_user_role_5001293f8b94','P3|5001293f8b94aa61ea3596bad4b478e3bfc4551b28e20a22207fd05f70352dcb|'||pg_get_constraintdef(found_oid));
 ELSE
 actual:=obj_description(found_oid,'pg_constraint');
 IF actual IS DISTINCT FROM 'P3|5001293f8b94aa61ea3596bad4b478e3bfc4551b28e20a22207fd05f70352dcb|'||pg_get_constraintdef(found_oid) THEN RAISE EXCEPTION 'Constraint drift: p3_portal_user_role_5001293f8b94'; END IF;
 END IF; END $p3$;
ALTER TABLE "pb3gir75kkooyea"."portal_user_application_scope" ALTER COLUMN "id" SET NOT NULL;
ALTER TABLE "pb3gir75kkooyea"."portal_user_application_scope" ALTER COLUMN "created_at" SET NOT NULL;
ALTER TABLE "pb3gir75kkooyea"."portal_user_application_scope" ALTER COLUMN "updated_at" SET NOT NULL;
ALTER TABLE "pb3gir75kkooyea"."portal_user_application_scope" ALTER COLUMN "version" SET NOT NULL;
ALTER TABLE "pb3gir75kkooyea"."portal_user_application_scope" ALTER COLUMN "user_id" SET NOT NULL;
ALTER TABLE "pb3gir75kkooyea"."portal_user_application_scope" ALTER COLUMN "application_id" SET NOT NULL;
DO $p3$ DECLARE found_oid oid; actual text; BEGIN
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."portal_user_application_scope"'::regclass AND c.conname='p3_portal_user_application_scop_22bc7933b010';
 IF found_oid IS NULL THEN
 ALTER TABLE "pb3gir75kkooyea"."portal_user_application_scope" ADD CONSTRAINT "p3_portal_user_application_scop_22bc7933b010" UNIQUE ("id");
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."portal_user_application_scope"'::regclass AND c.conname='p3_portal_user_application_scop_22bc7933b010';
 EXECUTE format('COMMENT ON CONSTRAINT %I ON "pb3gir75kkooyea"."portal_user_application_scope" IS %L','p3_portal_user_application_scop_22bc7933b010','P3|22bc7933b010072b3d832a242fa013a04db3f7c9582a6d0bbf998b1474a9138d|'||pg_get_constraintdef(found_oid));
 ELSE
 actual:=obj_description(found_oid,'pg_constraint');
 IF actual IS DISTINCT FROM 'P3|22bc7933b010072b3d832a242fa013a04db3f7c9582a6d0bbf998b1474a9138d|'||pg_get_constraintdef(found_oid) THEN RAISE EXCEPTION 'Constraint drift: p3_portal_user_application_scop_22bc7933b010'; END IF;
 END IF; END $p3$;
DO $p3$ DECLARE found_oid oid; actual text; BEGIN
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."portal_user_application_scope"'::regclass AND c.conname='p3_portal_user_application_scop_4bc9026941f0';
 IF found_oid IS NULL THEN
 ALTER TABLE "pb3gir75kkooyea"."portal_user_application_scope" ADD CONSTRAINT "p3_portal_user_application_scop_4bc9026941f0" UNIQUE ("user_id","application_id");
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."portal_user_application_scope"'::regclass AND c.conname='p3_portal_user_application_scop_4bc9026941f0';
 EXECUTE format('COMMENT ON CONSTRAINT %I ON "pb3gir75kkooyea"."portal_user_application_scope" IS %L','p3_portal_user_application_scop_4bc9026941f0','P3|4bc9026941f068fe192a37a1a9142b89f6f35c09267011b5e8e491ea5a1da8bb|'||pg_get_constraintdef(found_oid));
 ELSE
 actual:=obj_description(found_oid,'pg_constraint');
 IF actual IS DISTINCT FROM 'P3|4bc9026941f068fe192a37a1a9142b89f6f35c09267011b5e8e491ea5a1da8bb|'||pg_get_constraintdef(found_oid) THEN RAISE EXCEPTION 'Constraint drift: p3_portal_user_application_scop_4bc9026941f0'; END IF;
 END IF; END $p3$;
ALTER TABLE "pb3gir75kkooyea"."sso_config" ALTER COLUMN "id" SET NOT NULL;
ALTER TABLE "pb3gir75kkooyea"."sso_config" ALTER COLUMN "created_at" SET NOT NULL;
ALTER TABLE "pb3gir75kkooyea"."sso_config" ALTER COLUMN "updated_at" SET NOT NULL;
ALTER TABLE "pb3gir75kkooyea"."sso_config" ALTER COLUMN "version" SET NOT NULL;
ALTER TABLE "pb3gir75kkooyea"."sso_config" ALTER COLUMN "application_id" SET NOT NULL;
ALTER TABLE "pb3gir75kkooyea"."sso_config" ALTER COLUMN "protocol" SET NOT NULL;
ALTER TABLE "pb3gir75kkooyea"."sso_config" ALTER COLUMN "endpoints" SET NOT NULL;
ALTER TABLE "pb3gir75kkooyea"."sso_config" ALTER COLUMN "status" SET NOT NULL;
DO $p3$ DECLARE found_oid oid; actual text; BEGIN
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."sso_config"'::regclass AND c.conname='p3_sso_config_9e910b143668';
 IF found_oid IS NULL THEN
 ALTER TABLE "pb3gir75kkooyea"."sso_config" ADD CONSTRAINT "p3_sso_config_9e910b143668" UNIQUE ("id");
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."sso_config"'::regclass AND c.conname='p3_sso_config_9e910b143668';
 EXECUTE format('COMMENT ON CONSTRAINT %I ON "pb3gir75kkooyea"."sso_config" IS %L','p3_sso_config_9e910b143668','P3|9e910b1436684b7798e2f81cd8486b66db3fb260314271160129660bfea8a0b6|'||pg_get_constraintdef(found_oid));
 ELSE
 actual:=obj_description(found_oid,'pg_constraint');
 IF actual IS DISTINCT FROM 'P3|9e910b1436684b7798e2f81cd8486b66db3fb260314271160129660bfea8a0b6|'||pg_get_constraintdef(found_oid) THEN RAISE EXCEPTION 'Constraint drift: p3_sso_config_9e910b143668'; END IF;
 END IF; END $p3$;
DO $p3$ DECLARE found_oid oid; actual text; BEGIN
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."sso_config"'::regclass AND c.conname='p3_sso_config_fb8138402fb2';
 IF found_oid IS NULL THEN
 ALTER TABLE "pb3gir75kkooyea"."sso_config" ADD CONSTRAINT "p3_sso_config_fb8138402fb2" UNIQUE ("application_id");
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."sso_config"'::regclass AND c.conname='p3_sso_config_fb8138402fb2';
 EXECUTE format('COMMENT ON CONSTRAINT %I ON "pb3gir75kkooyea"."sso_config" IS %L','p3_sso_config_fb8138402fb2','P3|fb8138402fb2544f025422afd9eeafd9ff088071bfa9090b260cbe53d03165aa|'||pg_get_constraintdef(found_oid));
 ELSE
 actual:=obj_description(found_oid,'pg_constraint');
 IF actual IS DISTINCT FROM 'P3|fb8138402fb2544f025422afd9eeafd9ff088071bfa9090b260cbe53d03165aa|'||pg_get_constraintdef(found_oid) THEN RAISE EXCEPTION 'Constraint drift: p3_sso_config_fb8138402fb2'; END IF;
 END IF; END $p3$;
ALTER TABLE "pb3gir75kkooyea"."push_integration_config" ALTER COLUMN "id" SET NOT NULL;
ALTER TABLE "pb3gir75kkooyea"."push_integration_config" ALTER COLUMN "created_at" SET NOT NULL;
ALTER TABLE "pb3gir75kkooyea"."push_integration_config" ALTER COLUMN "updated_at" SET NOT NULL;
ALTER TABLE "pb3gir75kkooyea"."push_integration_config" ALTER COLUMN "version" SET NOT NULL;
ALTER TABLE "pb3gir75kkooyea"."push_integration_config" ALTER COLUMN "application_id" SET NOT NULL;
ALTER TABLE "pb3gir75kkooyea"."push_integration_config" ALTER COLUMN "kind" SET NOT NULL;
ALTER TABLE "pb3gir75kkooyea"."push_integration_config" ALTER COLUMN "mode" SET NOT NULL;
ALTER TABLE "pb3gir75kkooyea"."push_integration_config" ALTER COLUMN "field_mapping" SET NOT NULL;
ALTER TABLE "pb3gir75kkooyea"."push_integration_config" ALTER COLUMN "value_mapping" SET NOT NULL;
ALTER TABLE "pb3gir75kkooyea"."push_integration_config" ALTER COLUMN "target_key_kind" SET NOT NULL;
ALTER TABLE "pb3gir75kkooyea"."push_integration_config" ALTER COLUMN "status" SET NOT NULL;
DO $p3$ DECLARE found_oid oid; actual text; BEGIN
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."push_integration_config"'::regclass AND c.conname='p3_push_integration_config_a4fff4f61105';
 IF found_oid IS NULL THEN
 ALTER TABLE "pb3gir75kkooyea"."push_integration_config" ADD CONSTRAINT "p3_push_integration_config_a4fff4f61105" UNIQUE ("id");
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."push_integration_config"'::regclass AND c.conname='p3_push_integration_config_a4fff4f61105';
 EXECUTE format('COMMENT ON CONSTRAINT %I ON "pb3gir75kkooyea"."push_integration_config" IS %L','p3_push_integration_config_a4fff4f61105','P3|a4fff4f61105001cee4f95735e6ce80e6643af8be65324a49308843ea9fb6d7d|'||pg_get_constraintdef(found_oid));
 ELSE
 actual:=obj_description(found_oid,'pg_constraint');
 IF actual IS DISTINCT FROM 'P3|a4fff4f61105001cee4f95735e6ce80e6643af8be65324a49308843ea9fb6d7d|'||pg_get_constraintdef(found_oid) THEN RAISE EXCEPTION 'Constraint drift: p3_push_integration_config_a4fff4f61105'; END IF;
 END IF; END $p3$;
DO $p3$ DECLARE found_oid oid; actual text; BEGIN
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."push_integration_config"'::regclass AND c.conname='p3_push_integration_config_f0dd808cdefb';
 IF found_oid IS NULL THEN
 ALTER TABLE "pb3gir75kkooyea"."push_integration_config" ADD CONSTRAINT "p3_push_integration_config_f0dd808cdefb" UNIQUE ("application_id","kind");
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."push_integration_config"'::regclass AND c.conname='p3_push_integration_config_f0dd808cdefb';
 EXECUTE format('COMMENT ON CONSTRAINT %I ON "pb3gir75kkooyea"."push_integration_config" IS %L','p3_push_integration_config_f0dd808cdefb','P3|f0dd808cdefb35d01e55287817f31fe53877f28f9666b93c20765eb45f740fee|'||pg_get_constraintdef(found_oid));
 ELSE
 actual:=obj_description(found_oid,'pg_constraint');
 IF actual IS DISTINCT FROM 'P3|f0dd808cdefb35d01e55287817f31fe53877f28f9666b93c20765eb45f740fee|'||pg_get_constraintdef(found_oid) THEN RAISE EXCEPTION 'Constraint drift: p3_push_integration_config_f0dd808cdefb'; END IF;
 END IF; END $p3$;
ALTER TABLE "pb3gir75kkooyea"."ingest_receipt" ALTER COLUMN "id" SET NOT NULL;
ALTER TABLE "pb3gir75kkooyea"."ingest_receipt" ALTER COLUMN "created_at" SET NOT NULL;
ALTER TABLE "pb3gir75kkooyea"."ingest_receipt" ALTER COLUMN "updated_at" SET NOT NULL;
ALTER TABLE "pb3gir75kkooyea"."ingest_receipt" ALTER COLUMN "version" SET NOT NULL;
ALTER TABLE "pb3gir75kkooyea"."ingest_receipt" ALTER COLUMN "application_id" SET NOT NULL;
ALTER TABLE "pb3gir75kkooyea"."ingest_receipt" ALTER COLUMN "kind" SET NOT NULL;
ALTER TABLE "pb3gir75kkooyea"."ingest_receipt" ALTER COLUMN "event_id" SET NOT NULL;
ALTER TABLE "pb3gir75kkooyea"."ingest_receipt" ALTER COLUMN "payload_hash" SET NOT NULL;
ALTER TABLE "pb3gir75kkooyea"."ingest_receipt" ALTER COLUMN "status" SET NOT NULL;
DO $p3$ DECLARE found_oid oid; actual text; BEGIN
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."ingest_receipt"'::regclass AND c.conname='p3_ingest_receipt_93ebcd8ab9c9';
 IF found_oid IS NULL THEN
 ALTER TABLE "pb3gir75kkooyea"."ingest_receipt" ADD CONSTRAINT "p3_ingest_receipt_93ebcd8ab9c9" UNIQUE ("id");
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."ingest_receipt"'::regclass AND c.conname='p3_ingest_receipt_93ebcd8ab9c9';
 EXECUTE format('COMMENT ON CONSTRAINT %I ON "pb3gir75kkooyea"."ingest_receipt" IS %L','p3_ingest_receipt_93ebcd8ab9c9','P3|93ebcd8ab9c946fb6bd9406c86c59748aa8658401d1ef94386fdf9cf64cdafbe|'||pg_get_constraintdef(found_oid));
 ELSE
 actual:=obj_description(found_oid,'pg_constraint');
 IF actual IS DISTINCT FROM 'P3|93ebcd8ab9c946fb6bd9406c86c59748aa8658401d1ef94386fdf9cf64cdafbe|'||pg_get_constraintdef(found_oid) THEN RAISE EXCEPTION 'Constraint drift: p3_ingest_receipt_93ebcd8ab9c9'; END IF;
 END IF; END $p3$;
DO $p3$ DECLARE found_oid oid; actual text; BEGIN
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."ingest_receipt"'::regclass AND c.conname='p3_ingest_receipt_e57c61d00ca9';
 IF found_oid IS NULL THEN
 ALTER TABLE "pb3gir75kkooyea"."ingest_receipt" ADD CONSTRAINT "p3_ingest_receipt_e57c61d00ca9" UNIQUE ("application_id","kind","event_id");
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."ingest_receipt"'::regclass AND c.conname='p3_ingest_receipt_e57c61d00ca9';
 EXECUTE format('COMMENT ON CONSTRAINT %I ON "pb3gir75kkooyea"."ingest_receipt" IS %L','p3_ingest_receipt_e57c61d00ca9','P3|e57c61d00ca9dfdad0a121137d207ad7f83e98f13b4f57e8d15fb8664c9d20e5|'||pg_get_constraintdef(found_oid));
 ELSE
 actual:=obj_description(found_oid,'pg_constraint');
 IF actual IS DISTINCT FROM 'P3|e57c61d00ca9dfdad0a121137d207ad7f83e98f13b4f57e8d15fb8664c9d20e5|'||pg_get_constraintdef(found_oid) THEN RAISE EXCEPTION 'Constraint drift: p3_ingest_receipt_e57c61d00ca9'; END IF;
 END IF; END $p3$;
ALTER TABLE "pb3gir75kkooyea"."todo_item" ALTER COLUMN "id" SET NOT NULL;
ALTER TABLE "pb3gir75kkooyea"."todo_item" ALTER COLUMN "created_at" SET NOT NULL;
ALTER TABLE "pb3gir75kkooyea"."todo_item" ALTER COLUMN "updated_at" SET NOT NULL;
ALTER TABLE "pb3gir75kkooyea"."todo_item" ALTER COLUMN "version" SET NOT NULL;
ALTER TABLE "pb3gir75kkooyea"."todo_item" ALTER COLUMN "application_id" SET NOT NULL;
ALTER TABLE "pb3gir75kkooyea"."todo_item" ALTER COLUMN "source_todo_id" SET NOT NULL;
ALTER TABLE "pb3gir75kkooyea"."todo_item" ALTER COLUMN "target_user_id" SET NOT NULL;
ALTER TABLE "pb3gir75kkooyea"."todo_item" ALTER COLUMN "title" SET NOT NULL;
ALTER TABLE "pb3gir75kkooyea"."todo_item" ALTER COLUMN "status" SET NOT NULL;
ALTER TABLE "pb3gir75kkooyea"."todo_item" ALTER COLUMN "priority" SET NOT NULL;
ALTER TABLE "pb3gir75kkooyea"."todo_item" ALTER COLUMN "source_created_at" SET NOT NULL;
ALTER TABLE "pb3gir75kkooyea"."todo_item" ALTER COLUMN "source_updated_at" SET NOT NULL;
ALTER TABLE "pb3gir75kkooyea"."todo_item" ALTER COLUMN "source_revision" SET NOT NULL;
ALTER TABLE "pb3gir75kkooyea"."todo_item" ALTER COLUMN "business_url" SET NOT NULL;
DO $p3$ DECLARE found_oid oid; actual text; BEGIN
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."todo_item"'::regclass AND c.conname='p3_todo_item_4d3365304d1d';
 IF found_oid IS NULL THEN
 ALTER TABLE "pb3gir75kkooyea"."todo_item" ADD CONSTRAINT "p3_todo_item_4d3365304d1d" UNIQUE ("id");
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."todo_item"'::regclass AND c.conname='p3_todo_item_4d3365304d1d';
 EXECUTE format('COMMENT ON CONSTRAINT %I ON "pb3gir75kkooyea"."todo_item" IS %L','p3_todo_item_4d3365304d1d','P3|4d3365304d1df92a6fff72db830be57d607695acd0865a8bb48ba9a5b819db21|'||pg_get_constraintdef(found_oid));
 ELSE
 actual:=obj_description(found_oid,'pg_constraint');
 IF actual IS DISTINCT FROM 'P3|4d3365304d1df92a6fff72db830be57d607695acd0865a8bb48ba9a5b819db21|'||pg_get_constraintdef(found_oid) THEN RAISE EXCEPTION 'Constraint drift: p3_todo_item_4d3365304d1d'; END IF;
 END IF; END $p3$;
DO $p3$ DECLARE found_oid oid; actual text; BEGIN
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."todo_item"'::regclass AND c.conname='p3_todo_item_ddea7627131f';
 IF found_oid IS NULL THEN
 ALTER TABLE "pb3gir75kkooyea"."todo_item" ADD CONSTRAINT "p3_todo_item_ddea7627131f" UNIQUE ("application_id","source_todo_id");
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."todo_item"'::regclass AND c.conname='p3_todo_item_ddea7627131f';
 EXECUTE format('COMMENT ON CONSTRAINT %I ON "pb3gir75kkooyea"."todo_item" IS %L','p3_todo_item_ddea7627131f','P3|ddea7627131fcb3f4a0066e21104edffdb5c6a91fc4b9ab292a304e355f5d428|'||pg_get_constraintdef(found_oid));
 ELSE
 actual:=obj_description(found_oid,'pg_constraint');
 IF actual IS DISTINCT FROM 'P3|ddea7627131fcb3f4a0066e21104edffdb5c6a91fc4b9ab292a304e355f5d428|'||pg_get_constraintdef(found_oid) THEN RAISE EXCEPTION 'Constraint drift: p3_todo_item_ddea7627131f'; END IF;
 END IF; END $p3$;
ALTER TABLE "pb3gir75kkooyea"."message" ALTER COLUMN "id" SET NOT NULL;
ALTER TABLE "pb3gir75kkooyea"."message" ALTER COLUMN "created_at" SET NOT NULL;
ALTER TABLE "pb3gir75kkooyea"."message" ALTER COLUMN "updated_at" SET NOT NULL;
ALTER TABLE "pb3gir75kkooyea"."message" ALTER COLUMN "version" SET NOT NULL;
ALTER TABLE "pb3gir75kkooyea"."message" ALTER COLUMN "source_kind" SET NOT NULL;
ALTER TABLE "pb3gir75kkooyea"."message" ALTER COLUMN "source_key" SET NOT NULL;
ALTER TABLE "pb3gir75kkooyea"."message" ALTER COLUMN "source_message_id" SET NOT NULL;
ALTER TABLE "pb3gir75kkooyea"."message" ALTER COLUMN "message_type" SET NOT NULL;
ALTER TABLE "pb3gir75kkooyea"."message" ALTER COLUMN "title" SET NOT NULL;
ALTER TABLE "pb3gir75kkooyea"."message" ALTER COLUMN "content" SET NOT NULL;
ALTER TABLE "pb3gir75kkooyea"."message" ALTER COLUMN "source_created_at" SET NOT NULL;
DO $p3$ DECLARE found_oid oid; actual text; BEGIN
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."message"'::regclass AND c.conname='p3_message_22411100a0d2';
 IF found_oid IS NULL THEN
 ALTER TABLE "pb3gir75kkooyea"."message" ADD CONSTRAINT "p3_message_22411100a0d2" UNIQUE ("id");
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."message"'::regclass AND c.conname='p3_message_22411100a0d2';
 EXECUTE format('COMMENT ON CONSTRAINT %I ON "pb3gir75kkooyea"."message" IS %L','p3_message_22411100a0d2','P3|22411100a0d222cdeaa6dc14478e8fa4385c247c3b0f5eaad001ab9bb3931910|'||pg_get_constraintdef(found_oid));
 ELSE
 actual:=obj_description(found_oid,'pg_constraint');
 IF actual IS DISTINCT FROM 'P3|22411100a0d222cdeaa6dc14478e8fa4385c247c3b0f5eaad001ab9bb3931910|'||pg_get_constraintdef(found_oid) THEN RAISE EXCEPTION 'Constraint drift: p3_message_22411100a0d2'; END IF;
 END IF; END $p3$;
DO $p3$ DECLARE found_oid oid; actual text; BEGIN
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."message"'::regclass AND c.conname='p3_message_2b2e7968b4af';
 IF found_oid IS NULL THEN
 ALTER TABLE "pb3gir75kkooyea"."message" ADD CONSTRAINT "p3_message_2b2e7968b4af" UNIQUE ("source_key","source_message_id");
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."message"'::regclass AND c.conname='p3_message_2b2e7968b4af';
 EXECUTE format('COMMENT ON CONSTRAINT %I ON "pb3gir75kkooyea"."message" IS %L','p3_message_2b2e7968b4af','P3|2b2e7968b4afc51ca18d359b7c84893d6ab8f9efc052c678984e98daa9c45d33|'||pg_get_constraintdef(found_oid));
 ELSE
 actual:=obj_description(found_oid,'pg_constraint');
 IF actual IS DISTINCT FROM 'P3|2b2e7968b4afc51ca18d359b7c84893d6ab8f9efc052c678984e98daa9c45d33|'||pg_get_constraintdef(found_oid) THEN RAISE EXCEPTION 'Constraint drift: p3_message_2b2e7968b4af'; END IF;
 END IF; END $p3$;
ALTER TABLE "pb3gir75kkooyea"."message_recipient" ALTER COLUMN "id" SET NOT NULL;
ALTER TABLE "pb3gir75kkooyea"."message_recipient" ALTER COLUMN "created_at" SET NOT NULL;
ALTER TABLE "pb3gir75kkooyea"."message_recipient" ALTER COLUMN "updated_at" SET NOT NULL;
ALTER TABLE "pb3gir75kkooyea"."message_recipient" ALTER COLUMN "version" SET NOT NULL;
ALTER TABLE "pb3gir75kkooyea"."message_recipient" ALTER COLUMN "message_id" SET NOT NULL;
ALTER TABLE "pb3gir75kkooyea"."message_recipient" ALTER COLUMN "user_id" SET NOT NULL;
ALTER TABLE "pb3gir75kkooyea"."message_recipient" ALTER COLUMN "read_status" SET NOT NULL;
DO $p3$ DECLARE found_oid oid; actual text; BEGIN
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."message_recipient"'::regclass AND c.conname='p3_message_recipient_22cd1ed65436';
 IF found_oid IS NULL THEN
 ALTER TABLE "pb3gir75kkooyea"."message_recipient" ADD CONSTRAINT "p3_message_recipient_22cd1ed65436" UNIQUE ("id");
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."message_recipient"'::regclass AND c.conname='p3_message_recipient_22cd1ed65436';
 EXECUTE format('COMMENT ON CONSTRAINT %I ON "pb3gir75kkooyea"."message_recipient" IS %L','p3_message_recipient_22cd1ed65436','P3|22cd1ed65436d05782198bd6838f66bbce88171acd9593f997ca8d1b6e518bb6|'||pg_get_constraintdef(found_oid));
 ELSE
 actual:=obj_description(found_oid,'pg_constraint');
 IF actual IS DISTINCT FROM 'P3|22cd1ed65436d05782198bd6838f66bbce88171acd9593f997ca8d1b6e518bb6|'||pg_get_constraintdef(found_oid) THEN RAISE EXCEPTION 'Constraint drift: p3_message_recipient_22cd1ed65436'; END IF;
 END IF; END $p3$;
DO $p3$ DECLARE found_oid oid; actual text; BEGIN
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."message_recipient"'::regclass AND c.conname='p3_message_recipient_d26b5196cbee';
 IF found_oid IS NULL THEN
 ALTER TABLE "pb3gir75kkooyea"."message_recipient" ADD CONSTRAINT "p3_message_recipient_d26b5196cbee" UNIQUE ("message_id","user_id");
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."message_recipient"'::regclass AND c.conname='p3_message_recipient_d26b5196cbee';
 EXECUTE format('COMMENT ON CONSTRAINT %I ON "pb3gir75kkooyea"."message_recipient" IS %L','p3_message_recipient_d26b5196cbee','P3|d26b5196cbee567c478be14f424d0dfc12598ce8591fd706713030884da6d602|'||pg_get_constraintdef(found_oid));
 ELSE
 actual:=obj_description(found_oid,'pg_constraint');
 IF actual IS DISTINCT FROM 'P3|d26b5196cbee567c478be14f424d0dfc12598ce8591fd706713030884da6d602|'||pg_get_constraintdef(found_oid) THEN RAISE EXCEPTION 'Constraint drift: p3_message_recipient_d26b5196cbee'; END IF;
 END IF; END $p3$;
ALTER TABLE "pb3gir75kkooyea"."announcement" ALTER COLUMN "id" SET NOT NULL;
ALTER TABLE "pb3gir75kkooyea"."announcement" ALTER COLUMN "created_at" SET NOT NULL;
ALTER TABLE "pb3gir75kkooyea"."announcement" ALTER COLUMN "updated_at" SET NOT NULL;
ALTER TABLE "pb3gir75kkooyea"."announcement" ALTER COLUMN "version" SET NOT NULL;
ALTER TABLE "pb3gir75kkooyea"."announcement" ALTER COLUMN "title" SET NOT NULL;
ALTER TABLE "pb3gir75kkooyea"."announcement" ALTER COLUMN "announcement_type" SET NOT NULL;
ALTER TABLE "pb3gir75kkooyea"."announcement" ALTER COLUMN "content" SET NOT NULL;
ALTER TABLE "pb3gir75kkooyea"."announcement" ALTER COLUMN "scope" SET NOT NULL;
ALTER TABLE "pb3gir75kkooyea"."announcement" ALTER COLUMN "status" SET NOT NULL;
DO $p3$ DECLARE found_oid oid; actual text; BEGIN
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."announcement"'::regclass AND c.conname='p3_announcement_a250906e4337';
 IF found_oid IS NULL THEN
 ALTER TABLE "pb3gir75kkooyea"."announcement" ADD CONSTRAINT "p3_announcement_a250906e4337" UNIQUE ("id");
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."announcement"'::regclass AND c.conname='p3_announcement_a250906e4337';
 EXECUTE format('COMMENT ON CONSTRAINT %I ON "pb3gir75kkooyea"."announcement" IS %L','p3_announcement_a250906e4337','P3|a250906e4337abf4df558954285b1200c76114257155a6dab0109fb59164f683|'||pg_get_constraintdef(found_oid));
 ELSE
 actual:=obj_description(found_oid,'pg_constraint');
 IF actual IS DISTINCT FROM 'P3|a250906e4337abf4df558954285b1200c76114257155a6dab0109fb59164f683|'||pg_get_constraintdef(found_oid) THEN RAISE EXCEPTION 'Constraint drift: p3_announcement_a250906e4337'; END IF;
 END IF; END $p3$;
ALTER TABLE "pb3gir75kkooyea"."announcement_org_scope" ALTER COLUMN "id" SET NOT NULL;
ALTER TABLE "pb3gir75kkooyea"."announcement_org_scope" ALTER COLUMN "created_at" SET NOT NULL;
ALTER TABLE "pb3gir75kkooyea"."announcement_org_scope" ALTER COLUMN "updated_at" SET NOT NULL;
ALTER TABLE "pb3gir75kkooyea"."announcement_org_scope" ALTER COLUMN "version" SET NOT NULL;
ALTER TABLE "pb3gir75kkooyea"."announcement_org_scope" ALTER COLUMN "announcement_id" SET NOT NULL;
ALTER TABLE "pb3gir75kkooyea"."announcement_org_scope" ALTER COLUMN "identity_source_code" SET NOT NULL;
ALTER TABLE "pb3gir75kkooyea"."announcement_org_scope" ALTER COLUMN "org_key" SET NOT NULL;
DO $p3$ DECLARE found_oid oid; actual text; BEGIN
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."announcement_org_scope"'::regclass AND c.conname='p3_announcement_org_scope_307d02cc271d';
 IF found_oid IS NULL THEN
 ALTER TABLE "pb3gir75kkooyea"."announcement_org_scope" ADD CONSTRAINT "p3_announcement_org_scope_307d02cc271d" UNIQUE ("id");
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."announcement_org_scope"'::regclass AND c.conname='p3_announcement_org_scope_307d02cc271d';
 EXECUTE format('COMMENT ON CONSTRAINT %I ON "pb3gir75kkooyea"."announcement_org_scope" IS %L','p3_announcement_org_scope_307d02cc271d','P3|307d02cc271d359ea4f9260199d66a9572e3a2f6b7e2a092d3672390eebe425f|'||pg_get_constraintdef(found_oid));
 ELSE
 actual:=obj_description(found_oid,'pg_constraint');
 IF actual IS DISTINCT FROM 'P3|307d02cc271d359ea4f9260199d66a9572e3a2f6b7e2a092d3672390eebe425f|'||pg_get_constraintdef(found_oid) THEN RAISE EXCEPTION 'Constraint drift: p3_announcement_org_scope_307d02cc271d'; END IF;
 END IF; END $p3$;
DO $p3$ DECLARE found_oid oid; actual text; BEGIN
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."announcement_org_scope"'::regclass AND c.conname='p3_announcement_org_scope_3e1139d22213';
 IF found_oid IS NULL THEN
 ALTER TABLE "pb3gir75kkooyea"."announcement_org_scope" ADD CONSTRAINT "p3_announcement_org_scope_3e1139d22213" UNIQUE ("announcement_id","identity_source_code","org_key");
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."announcement_org_scope"'::regclass AND c.conname='p3_announcement_org_scope_3e1139d22213';
 EXECUTE format('COMMENT ON CONSTRAINT %I ON "pb3gir75kkooyea"."announcement_org_scope" IS %L','p3_announcement_org_scope_3e1139d22213','P3|3e1139d22213805c44d9dbe76258696d9523cbf2d1c782cc1ec909f01dc82f05|'||pg_get_constraintdef(found_oid));
 ELSE
 actual:=obj_description(found_oid,'pg_constraint');
 IF actual IS DISTINCT FROM 'P3|3e1139d22213805c44d9dbe76258696d9523cbf2d1c782cc1ec909f01dc82f05|'||pg_get_constraintdef(found_oid) THEN RAISE EXCEPTION 'Constraint drift: p3_announcement_org_scope_3e1139d22213'; END IF;
 END IF; END $p3$;
ALTER TABLE "pb3gir75kkooyea"."announcement_attachment" ALTER COLUMN "id" SET NOT NULL;
ALTER TABLE "pb3gir75kkooyea"."announcement_attachment" ALTER COLUMN "created_at" SET NOT NULL;
ALTER TABLE "pb3gir75kkooyea"."announcement_attachment" ALTER COLUMN "updated_at" SET NOT NULL;
ALTER TABLE "pb3gir75kkooyea"."announcement_attachment" ALTER COLUMN "version" SET NOT NULL;
ALTER TABLE "pb3gir75kkooyea"."announcement_attachment" ALTER COLUMN "announcement_id" SET NOT NULL;
ALTER TABLE "pb3gir75kkooyea"."announcement_attachment" ALTER COLUMN "file_name" SET NOT NULL;
ALTER TABLE "pb3gir75kkooyea"."announcement_attachment" ALTER COLUMN "size_bytes" SET NOT NULL;
ALTER TABLE "pb3gir75kkooyea"."announcement_attachment" ALTER COLUMN "mime_type" SET NOT NULL;
ALTER TABLE "pb3gir75kkooyea"."announcement_attachment" ALTER COLUMN "attachment" SET NOT NULL;
ALTER TABLE "pb3gir75kkooyea"."announcement_attachment" ALTER COLUMN "uploaded_by" SET NOT NULL;
ALTER TABLE "pb3gir75kkooyea"."announcement_attachment" ALTER COLUMN "sort_order" SET NOT NULL;
DO $p3$ DECLARE found_oid oid; actual text; BEGIN
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."announcement_attachment"'::regclass AND c.conname='p3_announcement_attachment_a663f3d9f066';
 IF found_oid IS NULL THEN
 ALTER TABLE "pb3gir75kkooyea"."announcement_attachment" ADD CONSTRAINT "p3_announcement_attachment_a663f3d9f066" UNIQUE ("id");
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."announcement_attachment"'::regclass AND c.conname='p3_announcement_attachment_a663f3d9f066';
 EXECUTE format('COMMENT ON CONSTRAINT %I ON "pb3gir75kkooyea"."announcement_attachment" IS %L','p3_announcement_attachment_a663f3d9f066','P3|a663f3d9f0667d84cbee201bbdf6fc4f83f57563e673e178f72bb189c6a2205d|'||pg_get_constraintdef(found_oid));
 ELSE
 actual:=obj_description(found_oid,'pg_constraint');
 IF actual IS DISTINCT FROM 'P3|a663f3d9f0667d84cbee201bbdf6fc4f83f57563e673e178f72bb189c6a2205d|'||pg_get_constraintdef(found_oid) THEN RAISE EXCEPTION 'Constraint drift: p3_announcement_attachment_a663f3d9f066'; END IF;
 END IF; END $p3$;
ALTER TABLE "pb3gir75kkooyea"."sms_channel" ALTER COLUMN "id" SET NOT NULL;
ALTER TABLE "pb3gir75kkooyea"."sms_channel" ALTER COLUMN "created_at" SET NOT NULL;
ALTER TABLE "pb3gir75kkooyea"."sms_channel" ALTER COLUMN "updated_at" SET NOT NULL;
ALTER TABLE "pb3gir75kkooyea"."sms_channel" ALTER COLUMN "version" SET NOT NULL;
ALTER TABLE "pb3gir75kkooyea"."sms_channel" ALTER COLUMN "code" SET NOT NULL;
ALTER TABLE "pb3gir75kkooyea"."sms_channel" ALTER COLUMN "name" SET NOT NULL;
ALTER TABLE "pb3gir75kkooyea"."sms_channel" ALTER COLUMN "provider" SET NOT NULL;
ALTER TABLE "pb3gir75kkooyea"."sms_channel" ALTER COLUMN "api_url" SET NOT NULL;
ALTER TABLE "pb3gir75kkooyea"."sms_channel" ALTER COLUMN "secret_ref" SET NOT NULL;
ALTER TABLE "pb3gir75kkooyea"."sms_channel" ALTER COLUMN "sign_name" SET NOT NULL;
ALTER TABLE "pb3gir75kkooyea"."sms_channel" ALTER COLUMN "status" SET NOT NULL;
ALTER TABLE "pb3gir75kkooyea"."sms_channel" ALTER COLUMN "runtime_status" SET NOT NULL;
DO $p3$ DECLARE found_oid oid; actual text; BEGIN
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."sms_channel"'::regclass AND c.conname='p3_sms_channel_061b93d0d163';
 IF found_oid IS NULL THEN
 ALTER TABLE "pb3gir75kkooyea"."sms_channel" ADD CONSTRAINT "p3_sms_channel_061b93d0d163" UNIQUE ("id");
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."sms_channel"'::regclass AND c.conname='p3_sms_channel_061b93d0d163';
 EXECUTE format('COMMENT ON CONSTRAINT %I ON "pb3gir75kkooyea"."sms_channel" IS %L','p3_sms_channel_061b93d0d163','P3|061b93d0d1634ff5374b09b23c52328c111dbfad3eb0bd7265cdf1901fc910c2|'||pg_get_constraintdef(found_oid));
 ELSE
 actual:=obj_description(found_oid,'pg_constraint');
 IF actual IS DISTINCT FROM 'P3|061b93d0d1634ff5374b09b23c52328c111dbfad3eb0bd7265cdf1901fc910c2|'||pg_get_constraintdef(found_oid) THEN RAISE EXCEPTION 'Constraint drift: p3_sms_channel_061b93d0d163'; END IF;
 END IF; END $p3$;
DO $p3$ DECLARE found_oid oid; actual text; BEGIN
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."sms_channel"'::regclass AND c.conname='p3_sms_channel_e53f43913078';
 IF found_oid IS NULL THEN
 ALTER TABLE "pb3gir75kkooyea"."sms_channel" ADD CONSTRAINT "p3_sms_channel_e53f43913078" UNIQUE ("code");
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."sms_channel"'::regclass AND c.conname='p3_sms_channel_e53f43913078';
 EXECUTE format('COMMENT ON CONSTRAINT %I ON "pb3gir75kkooyea"."sms_channel" IS %L','p3_sms_channel_e53f43913078','P3|e53f4391307898d8ea268ec354b36dc536d1ad8766330d2b0ad35af3663049ab|'||pg_get_constraintdef(found_oid));
 ELSE
 actual:=obj_description(found_oid,'pg_constraint');
 IF actual IS DISTINCT FROM 'P3|e53f4391307898d8ea268ec354b36dc536d1ad8766330d2b0ad35af3663049ab|'||pg_get_constraintdef(found_oid) THEN RAISE EXCEPTION 'Constraint drift: p3_sms_channel_e53f43913078'; END IF;
 END IF; END $p3$;
ALTER TABLE "pb3gir75kkooyea"."sms_template" ALTER COLUMN "id" SET NOT NULL;
ALTER TABLE "pb3gir75kkooyea"."sms_template" ALTER COLUMN "created_at" SET NOT NULL;
ALTER TABLE "pb3gir75kkooyea"."sms_template" ALTER COLUMN "updated_at" SET NOT NULL;
ALTER TABLE "pb3gir75kkooyea"."sms_template" ALTER COLUMN "version" SET NOT NULL;
ALTER TABLE "pb3gir75kkooyea"."sms_template" ALTER COLUMN "code" SET NOT NULL;
ALTER TABLE "pb3gir75kkooyea"."sms_template" ALTER COLUMN "name" SET NOT NULL;
ALTER TABLE "pb3gir75kkooyea"."sms_template" ALTER COLUMN "scene_type" SET NOT NULL;
ALTER TABLE "pb3gir75kkooyea"."sms_template" ALTER COLUMN "content" SET NOT NULL;
ALTER TABLE "pb3gir75kkooyea"."sms_template" ALTER COLUMN "variables" SET NOT NULL;
ALTER TABLE "pb3gir75kkooyea"."sms_template" ALTER COLUMN "sign_name" SET NOT NULL;
ALTER TABLE "pb3gir75kkooyea"."sms_template" ALTER COLUMN "status" SET NOT NULL;
DO $p3$ DECLARE found_oid oid; actual text; BEGIN
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."sms_template"'::regclass AND c.conname='p3_sms_template_66f6de79e9f2';
 IF found_oid IS NULL THEN
 ALTER TABLE "pb3gir75kkooyea"."sms_template" ADD CONSTRAINT "p3_sms_template_66f6de79e9f2" UNIQUE ("id");
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."sms_template"'::regclass AND c.conname='p3_sms_template_66f6de79e9f2';
 EXECUTE format('COMMENT ON CONSTRAINT %I ON "pb3gir75kkooyea"."sms_template" IS %L','p3_sms_template_66f6de79e9f2','P3|66f6de79e9f2cf5e2f36eafb641f21a99fb66d1480ea81f4f351b2d09ba99984|'||pg_get_constraintdef(found_oid));
 ELSE
 actual:=obj_description(found_oid,'pg_constraint');
 IF actual IS DISTINCT FROM 'P3|66f6de79e9f2cf5e2f36eafb641f21a99fb66d1480ea81f4f351b2d09ba99984|'||pg_get_constraintdef(found_oid) THEN RAISE EXCEPTION 'Constraint drift: p3_sms_template_66f6de79e9f2'; END IF;
 END IF; END $p3$;
DO $p3$ DECLARE found_oid oid; actual text; BEGIN
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."sms_template"'::regclass AND c.conname='p3_sms_template_4d06d257f2eb';
 IF found_oid IS NULL THEN
 ALTER TABLE "pb3gir75kkooyea"."sms_template" ADD CONSTRAINT "p3_sms_template_4d06d257f2eb" UNIQUE ("code");
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."sms_template"'::regclass AND c.conname='p3_sms_template_4d06d257f2eb';
 EXECUTE format('COMMENT ON CONSTRAINT %I ON "pb3gir75kkooyea"."sms_template" IS %L','p3_sms_template_4d06d257f2eb','P3|4d06d257f2eb16ac1f5fdca5d632cc1186bb8b1f117879ecee2b869f9542feae|'||pg_get_constraintdef(found_oid));
 ELSE
 actual:=obj_description(found_oid,'pg_constraint');
 IF actual IS DISTINCT FROM 'P3|4d06d257f2eb16ac1f5fdca5d632cc1186bb8b1f117879ecee2b869f9542feae|'||pg_get_constraintdef(found_oid) THEN RAISE EXCEPTION 'Constraint drift: p3_sms_template_4d06d257f2eb'; END IF;
 END IF; END $p3$;
ALTER TABLE "pb3gir75kkooyea"."sms_application" ALTER COLUMN "id" SET NOT NULL;
ALTER TABLE "pb3gir75kkooyea"."sms_application" ALTER COLUMN "created_at" SET NOT NULL;
ALTER TABLE "pb3gir75kkooyea"."sms_application" ALTER COLUMN "updated_at" SET NOT NULL;
ALTER TABLE "pb3gir75kkooyea"."sms_application" ALTER COLUMN "version" SET NOT NULL;
ALTER TABLE "pb3gir75kkooyea"."sms_application" ALTER COLUMN "application_id" SET NOT NULL;
ALTER TABLE "pb3gir75kkooyea"."sms_application" ALTER COLUMN "sms_app_id" SET NOT NULL;
ALTER TABLE "pb3gir75kkooyea"."sms_application" ALTER COLUMN "status" SET NOT NULL;
DO $p3$ DECLARE found_oid oid; actual text; BEGIN
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."sms_application"'::regclass AND c.conname='p3_sms_application_746ded36f494';
 IF found_oid IS NULL THEN
 ALTER TABLE "pb3gir75kkooyea"."sms_application" ADD CONSTRAINT "p3_sms_application_746ded36f494" UNIQUE ("id");
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."sms_application"'::regclass AND c.conname='p3_sms_application_746ded36f494';
 EXECUTE format('COMMENT ON CONSTRAINT %I ON "pb3gir75kkooyea"."sms_application" IS %L','p3_sms_application_746ded36f494','P3|746ded36f494e150e1440e494fe7a5deec64382be922f03400fc16a51f33edc4|'||pg_get_constraintdef(found_oid));
 ELSE
 actual:=obj_description(found_oid,'pg_constraint');
 IF actual IS DISTINCT FROM 'P3|746ded36f494e150e1440e494fe7a5deec64382be922f03400fc16a51f33edc4|'||pg_get_constraintdef(found_oid) THEN RAISE EXCEPTION 'Constraint drift: p3_sms_application_746ded36f494'; END IF;
 END IF; END $p3$;
DO $p3$ DECLARE found_oid oid; actual text; BEGIN
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."sms_application"'::regclass AND c.conname='p3_sms_application_5dec0cff8db2';
 IF found_oid IS NULL THEN
 ALTER TABLE "pb3gir75kkooyea"."sms_application" ADD CONSTRAINT "p3_sms_application_5dec0cff8db2" UNIQUE ("application_id");
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."sms_application"'::regclass AND c.conname='p3_sms_application_5dec0cff8db2';
 EXECUTE format('COMMENT ON CONSTRAINT %I ON "pb3gir75kkooyea"."sms_application" IS %L','p3_sms_application_5dec0cff8db2','P3|5dec0cff8db2d40f84fcb11c576c4ebaa2e6dc9fb52f1692edfdc32e4942bcbd|'||pg_get_constraintdef(found_oid));
 ELSE
 actual:=obj_description(found_oid,'pg_constraint');
 IF actual IS DISTINCT FROM 'P3|5dec0cff8db2d40f84fcb11c576c4ebaa2e6dc9fb52f1692edfdc32e4942bcbd|'||pg_get_constraintdef(found_oid) THEN RAISE EXCEPTION 'Constraint drift: p3_sms_application_5dec0cff8db2'; END IF;
 END IF; END $p3$;
DO $p3$ DECLARE found_oid oid; actual text; BEGIN
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."sms_application"'::regclass AND c.conname='p3_sms_application_ea678e9a5c1a';
 IF found_oid IS NULL THEN
 ALTER TABLE "pb3gir75kkooyea"."sms_application" ADD CONSTRAINT "p3_sms_application_ea678e9a5c1a" UNIQUE ("sms_app_id");
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."sms_application"'::regclass AND c.conname='p3_sms_application_ea678e9a5c1a';
 EXECUTE format('COMMENT ON CONSTRAINT %I ON "pb3gir75kkooyea"."sms_application" IS %L','p3_sms_application_ea678e9a5c1a','P3|ea678e9a5c1a7b161936e2dd9ad2a85c9d25c4e32eeb94dfc2846e84cc1cb299|'||pg_get_constraintdef(found_oid));
 ELSE
 actual:=obj_description(found_oid,'pg_constraint');
 IF actual IS DISTINCT FROM 'P3|ea678e9a5c1a7b161936e2dd9ad2a85c9d25c4e32eeb94dfc2846e84cc1cb299|'||pg_get_constraintdef(found_oid) THEN RAISE EXCEPTION 'Constraint drift: p3_sms_application_ea678e9a5c1a'; END IF;
 END IF; END $p3$;
ALTER TABLE "pb3gir75kkooyea"."sms_application_template" ALTER COLUMN "id" SET NOT NULL;
ALTER TABLE "pb3gir75kkooyea"."sms_application_template" ALTER COLUMN "created_at" SET NOT NULL;
ALTER TABLE "pb3gir75kkooyea"."sms_application_template" ALTER COLUMN "updated_at" SET NOT NULL;
ALTER TABLE "pb3gir75kkooyea"."sms_application_template" ALTER COLUMN "version" SET NOT NULL;
ALTER TABLE "pb3gir75kkooyea"."sms_application_template" ALTER COLUMN "sms_application_id" SET NOT NULL;
ALTER TABLE "pb3gir75kkooyea"."sms_application_template" ALTER COLUMN "template_id" SET NOT NULL;
DO $p3$ DECLARE found_oid oid; actual text; BEGIN
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."sms_application_template"'::regclass AND c.conname='p3_sms_application_template_f4335c9ab8f5';
 IF found_oid IS NULL THEN
 ALTER TABLE "pb3gir75kkooyea"."sms_application_template" ADD CONSTRAINT "p3_sms_application_template_f4335c9ab8f5" UNIQUE ("id");
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."sms_application_template"'::regclass AND c.conname='p3_sms_application_template_f4335c9ab8f5';
 EXECUTE format('COMMENT ON CONSTRAINT %I ON "pb3gir75kkooyea"."sms_application_template" IS %L','p3_sms_application_template_f4335c9ab8f5','P3|f4335c9ab8f5ff89ea6ded972fd510801054e574d3cea954ef94c052d77f1f65|'||pg_get_constraintdef(found_oid));
 ELSE
 actual:=obj_description(found_oid,'pg_constraint');
 IF actual IS DISTINCT FROM 'P3|f4335c9ab8f5ff89ea6ded972fd510801054e574d3cea954ef94c052d77f1f65|'||pg_get_constraintdef(found_oid) THEN RAISE EXCEPTION 'Constraint drift: p3_sms_application_template_f4335c9ab8f5'; END IF;
 END IF; END $p3$;
DO $p3$ DECLARE found_oid oid; actual text; BEGIN
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."sms_application_template"'::regclass AND c.conname='p3_sms_application_template_1189e50f22a1';
 IF found_oid IS NULL THEN
 ALTER TABLE "pb3gir75kkooyea"."sms_application_template" ADD CONSTRAINT "p3_sms_application_template_1189e50f22a1" UNIQUE ("sms_application_id","template_id");
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."sms_application_template"'::regclass AND c.conname='p3_sms_application_template_1189e50f22a1';
 EXECUTE format('COMMENT ON CONSTRAINT %I ON "pb3gir75kkooyea"."sms_application_template" IS %L','p3_sms_application_template_1189e50f22a1','P3|1189e50f22a1210db8164db547cd4171a6d6d120bd0746877de5ff421df5ffc3|'||pg_get_constraintdef(found_oid));
 ELSE
 actual:=obj_description(found_oid,'pg_constraint');
 IF actual IS DISTINCT FROM 'P3|1189e50f22a1210db8164db547cd4171a6d6d120bd0746877de5ff421df5ffc3|'||pg_get_constraintdef(found_oid) THEN RAISE EXCEPTION 'Constraint drift: p3_sms_application_template_1189e50f22a1'; END IF;
 END IF; END $p3$;
ALTER TABLE "pb3gir75kkooyea"."sms_send_record" ALTER COLUMN "id" SET NOT NULL;
ALTER TABLE "pb3gir75kkooyea"."sms_send_record" ALTER COLUMN "created_at" SET NOT NULL;
ALTER TABLE "pb3gir75kkooyea"."sms_send_record" ALTER COLUMN "updated_at" SET NOT NULL;
ALTER TABLE "pb3gir75kkooyea"."sms_send_record" ALTER COLUMN "version" SET NOT NULL;
ALTER TABLE "pb3gir75kkooyea"."sms_send_record" ALTER COLUMN "application_id" SET NOT NULL;
ALTER TABLE "pb3gir75kkooyea"."sms_send_record" ALTER COLUMN "template_id" SET NOT NULL;
ALTER TABLE "pb3gir75kkooyea"."sms_send_record" ALTER COLUMN "channel_id" SET NOT NULL;
ALTER TABLE "pb3gir75kkooyea"."sms_send_record" ALTER COLUMN "request_key" SET NOT NULL;
ALTER TABLE "pb3gir75kkooyea"."sms_send_record" ALTER COLUMN "payload_hash" SET NOT NULL;
ALTER TABLE "pb3gir75kkooyea"."sms_send_record" ALTER COLUMN "mobile_masked" SET NOT NULL;
ALTER TABLE "pb3gir75kkooyea"."sms_send_record" ALTER COLUMN "recipient_secret_ref" SET NOT NULL;
ALTER TABLE "pb3gir75kkooyea"."sms_send_record" ALTER COLUMN "variables_secret_ref" SET NOT NULL;
ALTER TABLE "pb3gir75kkooyea"."sms_send_record" ALTER COLUMN "status" SET NOT NULL;
ALTER TABLE "pb3gir75kkooyea"."sms_send_record" ALTER COLUMN "retry_count" SET NOT NULL;
DO $p3$ DECLARE found_oid oid; actual text; BEGIN
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."sms_send_record"'::regclass AND c.conname='p3_sms_send_record_76be89e4ce48';
 IF found_oid IS NULL THEN
 ALTER TABLE "pb3gir75kkooyea"."sms_send_record" ADD CONSTRAINT "p3_sms_send_record_76be89e4ce48" UNIQUE ("id");
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."sms_send_record"'::regclass AND c.conname='p3_sms_send_record_76be89e4ce48';
 EXECUTE format('COMMENT ON CONSTRAINT %I ON "pb3gir75kkooyea"."sms_send_record" IS %L','p3_sms_send_record_76be89e4ce48','P3|76be89e4ce48ca835c4f60fa91504149fdf115c5921242318d02ee384c48d91f|'||pg_get_constraintdef(found_oid));
 ELSE
 actual:=obj_description(found_oid,'pg_constraint');
 IF actual IS DISTINCT FROM 'P3|76be89e4ce48ca835c4f60fa91504149fdf115c5921242318d02ee384c48d91f|'||pg_get_constraintdef(found_oid) THEN RAISE EXCEPTION 'Constraint drift: p3_sms_send_record_76be89e4ce48'; END IF;
 END IF; END $p3$;
DO $p3$ DECLARE found_oid oid; actual text; BEGIN
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."sms_send_record"'::regclass AND c.conname='p3_sms_send_record_4e7d96a6f47d';
 IF found_oid IS NULL THEN
 ALTER TABLE "pb3gir75kkooyea"."sms_send_record" ADD CONSTRAINT "p3_sms_send_record_4e7d96a6f47d" UNIQUE ("application_id","request_key");
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."sms_send_record"'::regclass AND c.conname='p3_sms_send_record_4e7d96a6f47d';
 EXECUTE format('COMMENT ON CONSTRAINT %I ON "pb3gir75kkooyea"."sms_send_record" IS %L','p3_sms_send_record_4e7d96a6f47d','P3|4e7d96a6f47dad868badd02d6a3730bf4eea3abac8db010865dd247fcca43e5b|'||pg_get_constraintdef(found_oid));
 ELSE
 actual:=obj_description(found_oid,'pg_constraint');
 IF actual IS DISTINCT FROM 'P3|4e7d96a6f47dad868badd02d6a3730bf4eea3abac8db010865dd247fcca43e5b|'||pg_get_constraintdef(found_oid) THEN RAISE EXCEPTION 'Constraint drift: p3_sms_send_record_4e7d96a6f47d'; END IF;
 END IF; END $p3$;
ALTER TABLE "pb3gir75kkooyea"."sms_send_attempt" ALTER COLUMN "id" SET NOT NULL;
ALTER TABLE "pb3gir75kkooyea"."sms_send_attempt" ALTER COLUMN "created_at" SET NOT NULL;
ALTER TABLE "pb3gir75kkooyea"."sms_send_attempt" ALTER COLUMN "updated_at" SET NOT NULL;
ALTER TABLE "pb3gir75kkooyea"."sms_send_attempt" ALTER COLUMN "version" SET NOT NULL;
ALTER TABLE "pb3gir75kkooyea"."sms_send_attempt" ALTER COLUMN "send_id" SET NOT NULL;
ALTER TABLE "pb3gir75kkooyea"."sms_send_attempt" ALTER COLUMN "attempt_no" SET NOT NULL;
ALTER TABLE "pb3gir75kkooyea"."sms_send_attempt" ALTER COLUMN "status" SET NOT NULL;
ALTER TABLE "pb3gir75kkooyea"."sms_send_attempt" ALTER COLUMN "delivery_certainty" SET NOT NULL;
DO $p3$ DECLARE found_oid oid; actual text; BEGIN
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."sms_send_attempt"'::regclass AND c.conname='p3_sms_send_attempt_5261baf0a57f';
 IF found_oid IS NULL THEN
 ALTER TABLE "pb3gir75kkooyea"."sms_send_attempt" ADD CONSTRAINT "p3_sms_send_attempt_5261baf0a57f" UNIQUE ("id");
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."sms_send_attempt"'::regclass AND c.conname='p3_sms_send_attempt_5261baf0a57f';
 EXECUTE format('COMMENT ON CONSTRAINT %I ON "pb3gir75kkooyea"."sms_send_attempt" IS %L','p3_sms_send_attempt_5261baf0a57f','P3|5261baf0a57fc610d4ae888b4847646265102cd472891a365879a37791564dfa|'||pg_get_constraintdef(found_oid));
 ELSE
 actual:=obj_description(found_oid,'pg_constraint');
 IF actual IS DISTINCT FROM 'P3|5261baf0a57fc610d4ae888b4847646265102cd472891a365879a37791564dfa|'||pg_get_constraintdef(found_oid) THEN RAISE EXCEPTION 'Constraint drift: p3_sms_send_attempt_5261baf0a57f'; END IF;
 END IF; END $p3$;
DO $p3$ DECLARE found_oid oid; actual text; BEGIN
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."sms_send_attempt"'::regclass AND c.conname='p3_sms_send_attempt_c8bf0a8b0842';
 IF found_oid IS NULL THEN
 ALTER TABLE "pb3gir75kkooyea"."sms_send_attempt" ADD CONSTRAINT "p3_sms_send_attempt_c8bf0a8b0842" UNIQUE ("send_id","attempt_no");
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."sms_send_attempt"'::regclass AND c.conname='p3_sms_send_attempt_c8bf0a8b0842';
 EXECUTE format('COMMENT ON CONSTRAINT %I ON "pb3gir75kkooyea"."sms_send_attempt" IS %L','p3_sms_send_attempt_c8bf0a8b0842','P3|c8bf0a8b0842123afbc2070ae3e20cccbf908af3284bad9cd385ce0e923faeec|'||pg_get_constraintdef(found_oid));
 ELSE
 actual:=obj_description(found_oid,'pg_constraint');
 IF actual IS DISTINCT FROM 'P3|c8bf0a8b0842123afbc2070ae3e20cccbf908af3284bad9cd385ce0e923faeec|'||pg_get_constraintdef(found_oid) THEN RAISE EXCEPTION 'Constraint drift: p3_sms_send_attempt_c8bf0a8b0842'; END IF;
 END IF; END $p3$;
ALTER TABLE "pb3gir75kkooyea"."system_config" ALTER COLUMN "id" SET NOT NULL;
ALTER TABLE "pb3gir75kkooyea"."system_config" ALTER COLUMN "created_at" SET NOT NULL;
ALTER TABLE "pb3gir75kkooyea"."system_config" ALTER COLUMN "updated_at" SET NOT NULL;
ALTER TABLE "pb3gir75kkooyea"."system_config" ALTER COLUMN "version" SET NOT NULL;
ALTER TABLE "pb3gir75kkooyea"."system_config" ALTER COLUMN "code" SET NOT NULL;
ALTER TABLE "pb3gir75kkooyea"."system_config" ALTER COLUMN "unit" SET NOT NULL;
ALTER TABLE "pb3gir75kkooyea"."system_config" ALTER COLUMN "status" SET NOT NULL;
ALTER TABLE "pb3gir75kkooyea"."system_config" ALTER COLUMN "description" SET NOT NULL;
DO $p3$ DECLARE found_oid oid; actual text; BEGIN
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."system_config"'::regclass AND c.conname='p3_system_config_1c9fec41fbd0';
 IF found_oid IS NULL THEN
 ALTER TABLE "pb3gir75kkooyea"."system_config" ADD CONSTRAINT "p3_system_config_1c9fec41fbd0" UNIQUE ("id");
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."system_config"'::regclass AND c.conname='p3_system_config_1c9fec41fbd0';
 EXECUTE format('COMMENT ON CONSTRAINT %I ON "pb3gir75kkooyea"."system_config" IS %L','p3_system_config_1c9fec41fbd0','P3|1c9fec41fbd0e044e64cdccd67ebde6f8b64f9eab4f53b2477c31d5322adf48d|'||pg_get_constraintdef(found_oid));
 ELSE
 actual:=obj_description(found_oid,'pg_constraint');
 IF actual IS DISTINCT FROM 'P3|1c9fec41fbd0e044e64cdccd67ebde6f8b64f9eab4f53b2477c31d5322adf48d|'||pg_get_constraintdef(found_oid) THEN RAISE EXCEPTION 'Constraint drift: p3_system_config_1c9fec41fbd0'; END IF;
 END IF; END $p3$;
DO $p3$ DECLARE found_oid oid; actual text; BEGIN
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."system_config"'::regclass AND c.conname='p3_system_config_47034a5d9af6';
 IF found_oid IS NULL THEN
 ALTER TABLE "pb3gir75kkooyea"."system_config" ADD CONSTRAINT "p3_system_config_47034a5d9af6" UNIQUE ("code");
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."system_config"'::regclass AND c.conname='p3_system_config_47034a5d9af6';
 EXECUTE format('COMMENT ON CONSTRAINT %I ON "pb3gir75kkooyea"."system_config" IS %L','p3_system_config_47034a5d9af6','P3|47034a5d9af601f1c0dc5e5fd990fbd6e12663b8d3b252dbb18148df69f44e40|'||pg_get_constraintdef(found_oid));
 ELSE
 actual:=obj_description(found_oid,'pg_constraint');
 IF actual IS DISTINCT FROM 'P3|47034a5d9af601f1c0dc5e5fd990fbd6e12663b8d3b252dbb18148df69f44e40|'||pg_get_constraintdef(found_oid) THEN RAISE EXCEPTION 'Constraint drift: p3_system_config_47034a5d9af6'; END IF;
 END IF; END $p3$;
ALTER TABLE "pb3gir75kkooyea"."monitor_status" ALTER COLUMN "id" SET NOT NULL;
ALTER TABLE "pb3gir75kkooyea"."monitor_status" ALTER COLUMN "created_at" SET NOT NULL;
ALTER TABLE "pb3gir75kkooyea"."monitor_status" ALTER COLUMN "updated_at" SET NOT NULL;
ALTER TABLE "pb3gir75kkooyea"."monitor_status" ALTER COLUMN "version" SET NOT NULL;
ALTER TABLE "pb3gir75kkooyea"."monitor_status" ALTER COLUMN "target_key" SET NOT NULL;
ALTER TABLE "pb3gir75kkooyea"."monitor_status" ALTER COLUMN "service_type" SET NOT NULL;
ALTER TABLE "pb3gir75kkooyea"."monitor_status" ALTER COLUMN "status" SET NOT NULL;
ALTER TABLE "pb3gir75kkooyea"."monitor_status" ALTER COLUMN "failure_count" SET NOT NULL;
DO $p3$ DECLARE found_oid oid; actual text; BEGIN
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."monitor_status"'::regclass AND c.conname='p3_monitor_status_09165ceff9be';
 IF found_oid IS NULL THEN
 ALTER TABLE "pb3gir75kkooyea"."monitor_status" ADD CONSTRAINT "p3_monitor_status_09165ceff9be" UNIQUE ("id");
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."monitor_status"'::regclass AND c.conname='p3_monitor_status_09165ceff9be';
 EXECUTE format('COMMENT ON CONSTRAINT %I ON "pb3gir75kkooyea"."monitor_status" IS %L','p3_monitor_status_09165ceff9be','P3|09165ceff9be9a9bef130b55bc439f29e36f6a940dfeceb71d2349b39e16378f|'||pg_get_constraintdef(found_oid));
 ELSE
 actual:=obj_description(found_oid,'pg_constraint');
 IF actual IS DISTINCT FROM 'P3|09165ceff9be9a9bef130b55bc439f29e36f6a940dfeceb71d2349b39e16378f|'||pg_get_constraintdef(found_oid) THEN RAISE EXCEPTION 'Constraint drift: p3_monitor_status_09165ceff9be'; END IF;
 END IF; END $p3$;
DO $p3$ DECLARE found_oid oid; actual text; BEGIN
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."monitor_status"'::regclass AND c.conname='p3_monitor_status_37a180db4a90';
 IF found_oid IS NULL THEN
 ALTER TABLE "pb3gir75kkooyea"."monitor_status" ADD CONSTRAINT "p3_monitor_status_37a180db4a90" UNIQUE ("target_key","service_type");
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."monitor_status"'::regclass AND c.conname='p3_monitor_status_37a180db4a90';
 EXECUTE format('COMMENT ON CONSTRAINT %I ON "pb3gir75kkooyea"."monitor_status" IS %L','p3_monitor_status_37a180db4a90','P3|37a180db4a90cd155c6e4919487902775d5f3e90e66c6305dd150996d2da3066|'||pg_get_constraintdef(found_oid));
 ELSE
 actual:=obj_description(found_oid,'pg_constraint');
 IF actual IS DISTINCT FROM 'P3|37a180db4a90cd155c6e4919487902775d5f3e90e66c6305dd150996d2da3066|'||pg_get_constraintdef(found_oid) THEN RAISE EXCEPTION 'Constraint drift: p3_monitor_status_37a180db4a90'; END IF;
 END IF; END $p3$;
ALTER TABLE "pb3gir75kkooyea"."audit_event" ALTER COLUMN "id" SET NOT NULL;
ALTER TABLE "pb3gir75kkooyea"."audit_event" ALTER COLUMN "created_at" SET NOT NULL;
ALTER TABLE "pb3gir75kkooyea"."audit_event" ALTER COLUMN "updated_at" SET NOT NULL;
ALTER TABLE "pb3gir75kkooyea"."audit_event" ALTER COLUMN "version" SET NOT NULL;
ALTER TABLE "pb3gir75kkooyea"."audit_event" ALTER COLUMN "kind" SET NOT NULL;
ALTER TABLE "pb3gir75kkooyea"."audit_event" ALTER COLUMN "event_code" SET NOT NULL;
ALTER TABLE "pb3gir75kkooyea"."audit_event" ALTER COLUMN "request_id" SET NOT NULL;
ALTER TABLE "pb3gir75kkooyea"."audit_event" ALTER COLUMN "actor_kind" SET NOT NULL;
ALTER TABLE "pb3gir75kkooyea"."audit_event" ALTER COLUMN "result" SET NOT NULL;
ALTER TABLE "pb3gir75kkooyea"."audit_event" ALTER COLUMN "summary" SET NOT NULL;
ALTER TABLE "pb3gir75kkooyea"."audit_event" ALTER COLUMN "details" SET NOT NULL;
DO $p3$ DECLARE found_oid oid; actual text; BEGIN
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."audit_event"'::regclass AND c.conname='p3_audit_event_2acaa08eee72';
 IF found_oid IS NULL THEN
 ALTER TABLE "pb3gir75kkooyea"."audit_event" ADD CONSTRAINT "p3_audit_event_2acaa08eee72" UNIQUE ("id");
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."audit_event"'::regclass AND c.conname='p3_audit_event_2acaa08eee72';
 EXECUTE format('COMMENT ON CONSTRAINT %I ON "pb3gir75kkooyea"."audit_event" IS %L','p3_audit_event_2acaa08eee72','P3|2acaa08eee72439ec3f51805c4c9815134df2095aae9a2c7a0d895173b6b3e07|'||pg_get_constraintdef(found_oid));
 ELSE
 actual:=obj_description(found_oid,'pg_constraint');
 IF actual IS DISTINCT FROM 'P3|2acaa08eee72439ec3f51805c4c9815134df2095aae9a2c7a0d895173b6b3e07|'||pg_get_constraintdef(found_oid) THEN RAISE EXCEPTION 'Constraint drift: p3_audit_event_2acaa08eee72'; END IF;
 END IF; END $p3$;
DO $p3$ DECLARE found_oid oid; actual text; BEGIN
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."identity_source"'::regclass AND c.conname='p3_identity_source_722fe076aec2';
 IF found_oid IS NULL THEN
 ALTER TABLE "pb3gir75kkooyea"."identity_source" ADD CONSTRAINT "p3_identity_source_722fe076aec2" CHECK ("version" >= 1);
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."identity_source"'::regclass AND c.conname='p3_identity_source_722fe076aec2';
 EXECUTE format('COMMENT ON CONSTRAINT %I ON "pb3gir75kkooyea"."identity_source" IS %L','p3_identity_source_722fe076aec2','P3|722fe076aec2effea8a00402d7a856c333512ccee5496e3d45c9eb52b867d2cc|'||pg_get_constraintdef(found_oid));
 ELSE
 actual:=obj_description(found_oid,'pg_constraint');
 IF actual IS DISTINCT FROM 'P3|722fe076aec2effea8a00402d7a856c333512ccee5496e3d45c9eb52b867d2cc|'||pg_get_constraintdef(found_oid) THEN RAISE EXCEPTION 'Constraint drift: p3_identity_source_722fe076aec2'; END IF;
 END IF; END $p3$;
DO $p3$ DECLARE found_oid oid; actual text; BEGIN
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."identity_source"'::regclass AND c.conname='p3_identity_source_4e364815e78d';
 IF found_oid IS NULL THEN
 ALTER TABLE "pb3gir75kkooyea"."identity_source" ADD CONSTRAINT "p3_identity_source_4e364815e78d" CHECK ("kind" IN ('CITIZEN','GOV'));
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."identity_source"'::regclass AND c.conname='p3_identity_source_4e364815e78d';
 EXECUTE format('COMMENT ON CONSTRAINT %I ON "pb3gir75kkooyea"."identity_source" IS %L','p3_identity_source_4e364815e78d','P3|4e364815e78d3e592d9f7faff3c8bc136b51fb20388d56b2a0d47e5824e3bc6f|'||pg_get_constraintdef(found_oid));
 ELSE
 actual:=obj_description(found_oid,'pg_constraint');
 IF actual IS DISTINCT FROM 'P3|4e364815e78d3e592d9f7faff3c8bc136b51fb20388d56b2a0d47e5824e3bc6f|'||pg_get_constraintdef(found_oid) THEN RAISE EXCEPTION 'Constraint drift: p3_identity_source_4e364815e78d'; END IF;
 END IF; END $p3$;
DO $p3$ DECLARE found_oid oid; actual text; BEGIN
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."identity_source"'::regclass AND c.conname='p3_identity_source_df153a1313b8';
 IF found_oid IS NULL THEN
 ALTER TABLE "pb3gir75kkooyea"."identity_source" ADD CONSTRAINT "p3_identity_source_df153a1313b8" CHECK ("status" IN ('ENABLED','DISABLED'));
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."identity_source"'::regclass AND c.conname='p3_identity_source_df153a1313b8';
 EXECUTE format('COMMENT ON CONSTRAINT %I ON "pb3gir75kkooyea"."identity_source" IS %L','p3_identity_source_df153a1313b8','P3|df153a1313b802860599e16d5331416623e48178b1de2ea8d223f2b0484f5617|'||pg_get_constraintdef(found_oid));
 ELSE
 actual:=obj_description(found_oid,'pg_constraint');
 IF actual IS DISTINCT FROM 'P3|df153a1313b802860599e16d5331416623e48178b1de2ea8d223f2b0484f5617|'||pg_get_constraintdef(found_oid) THEN RAISE EXCEPTION 'Constraint drift: p3_identity_source_df153a1313b8'; END IF;
 END IF; END $p3$;
DO $p3$ DECLARE found_oid oid; actual text; BEGIN
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."unified_user"'::regclass AND c.conname='p3_unified_user_739b419ca5e8';
 IF found_oid IS NULL THEN
 ALTER TABLE "pb3gir75kkooyea"."unified_user" ADD CONSTRAINT "p3_unified_user_739b419ca5e8" CHECK ("version" >= 1);
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."unified_user"'::regclass AND c.conname='p3_unified_user_739b419ca5e8';
 EXECUTE format('COMMENT ON CONSTRAINT %I ON "pb3gir75kkooyea"."unified_user" IS %L','p3_unified_user_739b419ca5e8','P3|739b419ca5e81fd189fbae9b05b4aab5e22d4e62fe8f8cd3ddae01fae2c33880|'||pg_get_constraintdef(found_oid));
 ELSE
 actual:=obj_description(found_oid,'pg_constraint');
 IF actual IS DISTINCT FROM 'P3|739b419ca5e81fd189fbae9b05b4aab5e22d4e62fe8f8cd3ddae01fae2c33880|'||pg_get_constraintdef(found_oid) THEN RAISE EXCEPTION 'Constraint drift: p3_unified_user_739b419ca5e8'; END IF;
 END IF; END $p3$;
DO $p3$ DECLARE found_oid oid; actual text; BEGIN
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."unified_user"'::regclass AND c.conname='p3_unified_user_a3fa466b5bf1';
 IF found_oid IS NULL THEN
 ALTER TABLE "pb3gir75kkooyea"."unified_user" ADD CONSTRAINT "p3_unified_user_a3fa466b5bf1" CHECK ("status" IN ('NORMAL','ABNORMAL','DISABLED'));
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."unified_user"'::regclass AND c.conname='p3_unified_user_a3fa466b5bf1';
 EXECUTE format('COMMENT ON CONSTRAINT %I ON "pb3gir75kkooyea"."unified_user" IS %L','p3_unified_user_a3fa466b5bf1','P3|a3fa466b5bf1305531c13423e6f7589219e145d08762c532eceba47e38019b57|'||pg_get_constraintdef(found_oid));
 ELSE
 actual:=obj_description(found_oid,'pg_constraint');
 IF actual IS DISTINCT FROM 'P3|a3fa466b5bf1305531c13423e6f7589219e145d08762c532eceba47e38019b57|'||pg_get_constraintdef(found_oid) THEN RAISE EXCEPTION 'Constraint drift: p3_unified_user_a3fa466b5bf1'; END IF;
 END IF; END $p3$;
DO $p3$ DECLARE found_oid oid; actual text; BEGIN
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."identity_mapping"'::regclass AND c.conname='p3_identity_mapping_e2bf3479a23a';
 IF found_oid IS NULL THEN
 ALTER TABLE "pb3gir75kkooyea"."identity_mapping" ADD CONSTRAINT "p3_identity_mapping_e2bf3479a23a" CHECK ("version" >= 1);
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."identity_mapping"'::regclass AND c.conname='p3_identity_mapping_e2bf3479a23a';
 EXECUTE format('COMMENT ON CONSTRAINT %I ON "pb3gir75kkooyea"."identity_mapping" IS %L','p3_identity_mapping_e2bf3479a23a','P3|e2bf3479a23a0d677195dab79be88c0fca32410a308af7bec07178e4807d4d68|'||pg_get_constraintdef(found_oid));
 ELSE
 actual:=obj_description(found_oid,'pg_constraint');
 IF actual IS DISTINCT FROM 'P3|e2bf3479a23a0d677195dab79be88c0fca32410a308af7bec07178e4807d4d68|'||pg_get_constraintdef(found_oid) THEN RAISE EXCEPTION 'Constraint drift: p3_identity_mapping_e2bf3479a23a'; END IF;
 END IF; END $p3$;
DO $p3$ DECLARE found_oid oid; actual text; BEGIN
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."identity_mapping"'::regclass AND c.conname='p3_identity_mapping_62833e617dfb';
 IF found_oid IS NULL THEN
 ALTER TABLE "pb3gir75kkooyea"."identity_mapping" ADD CONSTRAINT "p3_identity_mapping_62833e617dfb" FOREIGN KEY ("user_id") REFERENCES "pb3gir75kkooyea"."unified_user" ("id") ON DELETE RESTRICT;
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."identity_mapping"'::regclass AND c.conname='p3_identity_mapping_62833e617dfb';
 EXECUTE format('COMMENT ON CONSTRAINT %I ON "pb3gir75kkooyea"."identity_mapping" IS %L','p3_identity_mapping_62833e617dfb','P3|62833e617dfb800a0d05b6346c549e081ecdabce3d8b5be3c2e9be658fdfdfaf|'||pg_get_constraintdef(found_oid));
 ELSE
 actual:=obj_description(found_oid,'pg_constraint');
 IF actual IS DISTINCT FROM 'P3|62833e617dfb800a0d05b6346c549e081ecdabce3d8b5be3c2e9be658fdfdfaf|'||pg_get_constraintdef(found_oid) THEN RAISE EXCEPTION 'Constraint drift: p3_identity_mapping_62833e617dfb'; END IF;
 END IF; END $p3$;
DO $p3$ DECLARE found_oid oid; actual text; BEGIN
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."identity_mapping"'::regclass AND c.conname='p3_identity_mapping_af7ec9fe6121';
 IF found_oid IS NULL THEN
 ALTER TABLE "pb3gir75kkooyea"."identity_mapping" ADD CONSTRAINT "p3_identity_mapping_af7ec9fe6121" FOREIGN KEY ("source_id") REFERENCES "pb3gir75kkooyea"."identity_source" ("id") ON DELETE RESTRICT;
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."identity_mapping"'::regclass AND c.conname='p3_identity_mapping_af7ec9fe6121';
 EXECUTE format('COMMENT ON CONSTRAINT %I ON "pb3gir75kkooyea"."identity_mapping" IS %L','p3_identity_mapping_af7ec9fe6121','P3|af7ec9fe61211187e0f6fe4413a1c153e95e05513d6de58519f29774855cab4c|'||pg_get_constraintdef(found_oid));
 ELSE
 actual:=obj_description(found_oid,'pg_constraint');
 IF actual IS DISTINCT FROM 'P3|af7ec9fe61211187e0f6fe4413a1c153e95e05513d6de58519f29774855cab4c|'||pg_get_constraintdef(found_oid) THEN RAISE EXCEPTION 'Constraint drift: p3_identity_mapping_af7ec9fe6121'; END IF;
 END IF; END $p3$;
DO $p3$ DECLARE found_oid oid; actual text; BEGIN
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."identity_mapping"'::regclass AND c.conname='p3_identity_mapping_37d207dea3f8';
 IF found_oid IS NULL THEN
 ALTER TABLE "pb3gir75kkooyea"."identity_mapping" ADD CONSTRAINT "p3_identity_mapping_37d207dea3f8" CHECK ("status" IN ('PENDING','BOUND','CONFLICT','UNBOUND'));
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."identity_mapping"'::regclass AND c.conname='p3_identity_mapping_37d207dea3f8';
 EXECUTE format('COMMENT ON CONSTRAINT %I ON "pb3gir75kkooyea"."identity_mapping" IS %L','p3_identity_mapping_37d207dea3f8','P3|37d207dea3f89f44a8cfcaefcfe4d07e83341dce6cae41f47cabe2d00e089fb9|'||pg_get_constraintdef(found_oid));
 ELSE
 actual:=obj_description(found_oid,'pg_constraint');
 IF actual IS DISTINCT FROM 'P3|37d207dea3f89f44a8cfcaefcfe4d07e83341dce6cae41f47cabe2d00e089fb9|'||pg_get_constraintdef(found_oid) THEN RAISE EXCEPTION 'Constraint drift: p3_identity_mapping_37d207dea3f8'; END IF;
 END IF; END $p3$;
DO $p3$ DECLARE found_oid oid; actual text; BEGIN
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."login_request"'::regclass AND c.conname='p3_login_request_d0785f9a6986';
 IF found_oid IS NULL THEN
 ALTER TABLE "pb3gir75kkooyea"."login_request" ADD CONSTRAINT "p3_login_request_d0785f9a6986" CHECK ("version" >= 1);
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."login_request"'::regclass AND c.conname='p3_login_request_d0785f9a6986';
 EXECUTE format('COMMENT ON CONSTRAINT %I ON "pb3gir75kkooyea"."login_request" IS %L','p3_login_request_d0785f9a6986','P3|d0785f9a6986a94693134fa56311aad98472231d96ea6d64fe03f6ff0295a714|'||pg_get_constraintdef(found_oid));
 ELSE
 actual:=obj_description(found_oid,'pg_constraint');
 IF actual IS DISTINCT FROM 'P3|d0785f9a6986a94693134fa56311aad98472231d96ea6d64fe03f6ff0295a714|'||pg_get_constraintdef(found_oid) THEN RAISE EXCEPTION 'Constraint drift: p3_login_request_d0785f9a6986'; END IF;
 END IF; END $p3$;
DO $p3$ DECLARE found_oid oid; actual text; BEGIN
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."login_request"'::regclass AND c.conname='p3_login_request_994ccde8224b';
 IF found_oid IS NULL THEN
 ALTER TABLE "pb3gir75kkooyea"."login_request" ADD CONSTRAINT "p3_login_request_994ccde8224b" FOREIGN KEY ("source_id") REFERENCES "pb3gir75kkooyea"."identity_source" ("id") ON DELETE RESTRICT;
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."login_request"'::regclass AND c.conname='p3_login_request_994ccde8224b';
 EXECUTE format('COMMENT ON CONSTRAINT %I ON "pb3gir75kkooyea"."login_request" IS %L','p3_login_request_994ccde8224b','P3|994ccde8224b4f9fdcce43258187bbba2de00ba1087caa95a62be19bb4108f95|'||pg_get_constraintdef(found_oid));
 ELSE
 actual:=obj_description(found_oid,'pg_constraint');
 IF actual IS DISTINCT FROM 'P3|994ccde8224b4f9fdcce43258187bbba2de00ba1087caa95a62be19bb4108f95|'||pg_get_constraintdef(found_oid) THEN RAISE EXCEPTION 'Constraint drift: p3_login_request_994ccde8224b'; END IF;
 END IF; END $p3$;
DO $p3$ DECLARE found_oid oid; actual text; BEGIN
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."login_request"'::regclass AND c.conname='p3_login_request_63ae1bd58c34';
 IF found_oid IS NULL THEN
 ALTER TABLE "pb3gir75kkooyea"."login_request" ADD CONSTRAINT "p3_login_request_63ae1bd58c34" CHECK ("status" IN ('WAITING','SCANNED','AUTHENTICATING','SUCCESS','FAILED','EXPIRED','CANCELLED'));
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."login_request"'::regclass AND c.conname='p3_login_request_63ae1bd58c34';
 EXECUTE format('COMMENT ON CONSTRAINT %I ON "pb3gir75kkooyea"."login_request" IS %L','p3_login_request_63ae1bd58c34','P3|63ae1bd58c342c588daeb81db637603b30285623c67e6740ffafae7966fa8582|'||pg_get_constraintdef(found_oid));
 ELSE
 actual:=obj_description(found_oid,'pg_constraint');
 IF actual IS DISTINCT FROM 'P3|63ae1bd58c342c588daeb81db637603b30285623c67e6740ffafae7966fa8582|'||pg_get_constraintdef(found_oid) THEN RAISE EXCEPTION 'Constraint drift: p3_login_request_63ae1bd58c34'; END IF;
 END IF; END $p3$;
DO $p3$ DECLARE found_oid oid; actual text; BEGIN
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."portal_session"'::regclass AND c.conname='p3_portal_session_485e575a2257';
 IF found_oid IS NULL THEN
 ALTER TABLE "pb3gir75kkooyea"."portal_session" ADD CONSTRAINT "p3_portal_session_485e575a2257" CHECK ("version" >= 1);
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."portal_session"'::regclass AND c.conname='p3_portal_session_485e575a2257';
 EXECUTE format('COMMENT ON CONSTRAINT %I ON "pb3gir75kkooyea"."portal_session" IS %L','p3_portal_session_485e575a2257','P3|485e575a225724b188d681a0a854149306b8fc49637a393b8893d9ab93a571d9|'||pg_get_constraintdef(found_oid));
 ELSE
 actual:=obj_description(found_oid,'pg_constraint');
 IF actual IS DISTINCT FROM 'P3|485e575a225724b188d681a0a854149306b8fc49637a393b8893d9ab93a571d9|'||pg_get_constraintdef(found_oid) THEN RAISE EXCEPTION 'Constraint drift: p3_portal_session_485e575a2257'; END IF;
 END IF; END $p3$;
DO $p3$ DECLARE found_oid oid; actual text; BEGIN
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."portal_session"'::regclass AND c.conname='p3_portal_session_4dbb242dbc46';
 IF found_oid IS NULL THEN
 ALTER TABLE "pb3gir75kkooyea"."portal_session" ADD CONSTRAINT "p3_portal_session_4dbb242dbc46" FOREIGN KEY ("user_id") REFERENCES "pb3gir75kkooyea"."unified_user" ("id") ON DELETE RESTRICT;
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."portal_session"'::regclass AND c.conname='p3_portal_session_4dbb242dbc46';
 EXECUTE format('COMMENT ON CONSTRAINT %I ON "pb3gir75kkooyea"."portal_session" IS %L','p3_portal_session_4dbb242dbc46','P3|4dbb242dbc46b9abdee1d8096e1a5bf658c67ca12b7fe03d8b5f02b435a8ed9a|'||pg_get_constraintdef(found_oid));
 ELSE
 actual:=obj_description(found_oid,'pg_constraint');
 IF actual IS DISTINCT FROM 'P3|4dbb242dbc46b9abdee1d8096e1a5bf658c67ca12b7fe03d8b5f02b435a8ed9a|'||pg_get_constraintdef(found_oid) THEN RAISE EXCEPTION 'Constraint drift: p3_portal_session_4dbb242dbc46'; END IF;
 END IF; END $p3$;
DO $p3$ DECLARE found_oid oid; actual text; BEGIN
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."portal_session"'::regclass AND c.conname='p3_portal_session_49acbe904dcf';
 IF found_oid IS NULL THEN
 ALTER TABLE "pb3gir75kkooyea"."portal_session" ADD CONSTRAINT "p3_portal_session_49acbe904dcf" FOREIGN KEY ("identity_mapping_id") REFERENCES "pb3gir75kkooyea"."identity_mapping" ("id") ON DELETE RESTRICT;
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."portal_session"'::regclass AND c.conname='p3_portal_session_49acbe904dcf';
 EXECUTE format('COMMENT ON CONSTRAINT %I ON "pb3gir75kkooyea"."portal_session" IS %L','p3_portal_session_49acbe904dcf','P3|49acbe904dcfd93b8bf0dcd10e3b28db531993b2cd74dd2c867185a1bce886b4|'||pg_get_constraintdef(found_oid));
 ELSE
 actual:=obj_description(found_oid,'pg_constraint');
 IF actual IS DISTINCT FROM 'P3|49acbe904dcfd93b8bf0dcd10e3b28db531993b2cd74dd2c867185a1bce886b4|'||pg_get_constraintdef(found_oid) THEN RAISE EXCEPTION 'Constraint drift: p3_portal_session_49acbe904dcf'; END IF;
 END IF; END $p3$;
DO $p3$ DECLARE found_oid oid; actual text; BEGIN
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."application_category"'::regclass AND c.conname='p3_application_category_37ee9d58131b';
 IF found_oid IS NULL THEN
 ALTER TABLE "pb3gir75kkooyea"."application_category" ADD CONSTRAINT "p3_application_category_37ee9d58131b" CHECK ("version" >= 1);
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."application_category"'::regclass AND c.conname='p3_application_category_37ee9d58131b';
 EXECUTE format('COMMENT ON CONSTRAINT %I ON "pb3gir75kkooyea"."application_category" IS %L','p3_application_category_37ee9d58131b','P3|37ee9d58131b32980288488d2cc3b9adb8d29ad8f52adcdcdea7f8e721c7db62|'||pg_get_constraintdef(found_oid));
 ELSE
 actual:=obj_description(found_oid,'pg_constraint');
 IF actual IS DISTINCT FROM 'P3|37ee9d58131b32980288488d2cc3b9adb8d29ad8f52adcdcdea7f8e721c7db62|'||pg_get_constraintdef(found_oid) THEN RAISE EXCEPTION 'Constraint drift: p3_application_category_37ee9d58131b'; END IF;
 END IF; END $p3$;
DO $p3$ DECLARE found_oid oid; actual text; BEGIN
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."application_category"'::regclass AND c.conname='p3_application_category_bbf6c38cdc58';
 IF found_oid IS NULL THEN
 ALTER TABLE "pb3gir75kkooyea"."application_category" ADD CONSTRAINT "p3_application_category_bbf6c38cdc58" CHECK ("status" IN ('ENABLED','DISABLED'));
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."application_category"'::regclass AND c.conname='p3_application_category_bbf6c38cdc58';
 EXECUTE format('COMMENT ON CONSTRAINT %I ON "pb3gir75kkooyea"."application_category" IS %L','p3_application_category_bbf6c38cdc58','P3|bbf6c38cdc5864b310fbe40be6701633edef2be86ca37124526e09d14a283370|'||pg_get_constraintdef(found_oid));
 ELSE
 actual:=obj_description(found_oid,'pg_constraint');
 IF actual IS DISTINCT FROM 'P3|bbf6c38cdc5864b310fbe40be6701633edef2be86ca37124526e09d14a283370|'||pg_get_constraintdef(found_oid) THEN RAISE EXCEPTION 'Constraint drift: p3_application_category_bbf6c38cdc58'; END IF;
 END IF; END $p3$;
DO $p3$ DECLARE found_oid oid; actual text; BEGIN
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."application"'::regclass AND c.conname='p3_application_bc9eb911168e';
 IF found_oid IS NULL THEN
 ALTER TABLE "pb3gir75kkooyea"."application" ADD CONSTRAINT "p3_application_bc9eb911168e" CHECK ("version" >= 1);
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."application"'::regclass AND c.conname='p3_application_bc9eb911168e';
 EXECUTE format('COMMENT ON CONSTRAINT %I ON "pb3gir75kkooyea"."application" IS %L','p3_application_bc9eb911168e','P3|bc9eb911168e3ec888a53c167285b479254e49c49a231e84f0e0802b47061e5a|'||pg_get_constraintdef(found_oid));
 ELSE
 actual:=obj_description(found_oid,'pg_constraint');
 IF actual IS DISTINCT FROM 'P3|bc9eb911168e3ec888a53c167285b479254e49c49a231e84f0e0802b47061e5a|'||pg_get_constraintdef(found_oid) THEN RAISE EXCEPTION 'Constraint drift: p3_application_bc9eb911168e'; END IF;
 END IF; END $p3$;
DO $p3$ DECLARE found_oid oid; actual text; BEGIN
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."application"'::regclass AND c.conname='p3_application_33c9766c683f';
 IF found_oid IS NULL THEN
 ALTER TABLE "pb3gir75kkooyea"."application" ADD CONSTRAINT "p3_application_33c9766c683f" FOREIGN KEY ("category_id") REFERENCES "pb3gir75kkooyea"."application_category" ("id") ON DELETE RESTRICT;
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."application"'::regclass AND c.conname='p3_application_33c9766c683f';
 EXECUTE format('COMMENT ON CONSTRAINT %I ON "pb3gir75kkooyea"."application" IS %L','p3_application_33c9766c683f','P3|33c9766c683f67462c395283d8d27848eb24795f1c38c39f2fdc5c9ef33fc1bc|'||pg_get_constraintdef(found_oid));
 ELSE
 actual:=obj_description(found_oid,'pg_constraint');
 IF actual IS DISTINCT FROM 'P3|33c9766c683f67462c395283d8d27848eb24795f1c38c39f2fdc5c9ef33fc1bc|'||pg_get_constraintdef(found_oid) THEN RAISE EXCEPTION 'Constraint drift: p3_application_33c9766c683f'; END IF;
 END IF; END $p3$;
DO $p3$ DECLARE found_oid oid; actual text; BEGIN
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."application"'::regclass AND c.conname='p3_application_48a78c19e880';
 IF found_oid IS NULL THEN
 ALTER TABLE "pb3gir75kkooyea"."application" ADD CONSTRAINT "p3_application_48a78c19e880" CHECK ("user_type" IN ('CITIZEN','GOV','BOTH'));
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."application"'::regclass AND c.conname='p3_application_48a78c19e880';
 EXECUTE format('COMMENT ON CONSTRAINT %I ON "pb3gir75kkooyea"."application" IS %L','p3_application_48a78c19e880','P3|48a78c19e880fc8de0ebb94a1514d39380f766e6e12b78da2139b59576e1a949|'||pg_get_constraintdef(found_oid));
 ELSE
 actual:=obj_description(found_oid,'pg_constraint');
 IF actual IS DISTINCT FROM 'P3|48a78c19e880fc8de0ebb94a1514d39380f766e6e12b78da2139b59576e1a949|'||pg_get_constraintdef(found_oid) THEN RAISE EXCEPTION 'Constraint drift: p3_application_48a78c19e880'; END IF;
 END IF; END $p3$;
DO $p3$ DECLARE found_oid oid; actual text; BEGIN
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."application"'::regclass AND c.conname='p3_application_b448172ab694';
 IF found_oid IS NULL THEN
 ALTER TABLE "pb3gir75kkooyea"."application" ADD CONSTRAINT "p3_application_b448172ab694" CHECK ("status" IN ('ENABLED','DISABLED'));
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."application"'::regclass AND c.conname='p3_application_b448172ab694';
 EXECUTE format('COMMENT ON CONSTRAINT %I ON "pb3gir75kkooyea"."application" IS %L','p3_application_b448172ab694','P3|b448172ab694bfa8a8d9568c79fa83abe0dff679425ca468092044e281945784|'||pg_get_constraintdef(found_oid));
 ELSE
 actual:=obj_description(found_oid,'pg_constraint');
 IF actual IS DISTINCT FROM 'P3|b448172ab694bfa8a8d9568c79fa83abe0dff679425ca468092044e281945784|'||pg_get_constraintdef(found_oid) THEN RAISE EXCEPTION 'Constraint drift: p3_application_b448172ab694'; END IF;
 END IF; END $p3$;
DO $p3$ DECLARE found_oid oid; actual text; BEGIN
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."application"'::regclass AND c.conname='p3_application_e3b618e81a7c';
 IF found_oid IS NULL THEN
 ALTER TABLE "pb3gir75kkooyea"."application" ADD CONSTRAINT "p3_application_e3b618e81a7c" CHECK ("runtime_status" IN ('NORMAL','ABNORMAL','UNCONFIGURED','DISABLED'));
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."application"'::regclass AND c.conname='p3_application_e3b618e81a7c';
 EXECUTE format('COMMENT ON CONSTRAINT %I ON "pb3gir75kkooyea"."application" IS %L','p3_application_e3b618e81a7c','P3|e3b618e81a7c5991b94a372c774fde1e1ba6b02a5aac2a36e4c8109835d3c814|'||pg_get_constraintdef(found_oid));
 ELSE
 actual:=obj_description(found_oid,'pg_constraint');
 IF actual IS DISTINCT FROM 'P3|e3b618e81a7c5991b94a372c774fde1e1ba6b02a5aac2a36e4c8109835d3c814|'||pg_get_constraintdef(found_oid) THEN RAISE EXCEPTION 'Constraint drift: p3_application_e3b618e81a7c'; END IF;
 END IF; END $p3$;
DO $p3$ DECLARE found_oid oid; actual text; BEGIN
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."application"'::regclass AND c.conname='p3_application_784d16254804';
 IF found_oid IS NULL THEN
 ALTER TABLE "pb3gir75kkooyea"."application" ADD CONSTRAINT "p3_application_784d16254804" CHECK ("allowed_origins" IS NULL OR jsonb_typeof("allowed_origins"::jsonb) IS NOT NULL);
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."application"'::regclass AND c.conname='p3_application_784d16254804';
 EXECUTE format('COMMENT ON CONSTRAINT %I ON "pb3gir75kkooyea"."application" IS %L','p3_application_784d16254804','P3|784d162548049c231cf491f0c50e8199bf5100a41bdf64dd60537a31dadf7ab0|'||pg_get_constraintdef(found_oid));
 ELSE
 actual:=obj_description(found_oid,'pg_constraint');
 IF actual IS DISTINCT FROM 'P3|784d162548049c231cf491f0c50e8199bf5100a41bdf64dd60537a31dadf7ab0|'||pg_get_constraintdef(found_oid) THEN RAISE EXCEPTION 'Constraint drift: p3_application_784d16254804'; END IF;
 END IF; END $p3$;
DO $p3$ DECLARE found_oid oid; actual text; BEGIN
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."application"'::regclass AND c.conname='p3_application_02964c7c74be';
 IF found_oid IS NULL THEN
 ALTER TABLE "pb3gir75kkooyea"."application" ADD CONSTRAINT "p3_application_02964c7c74be" CHECK ("binding_methods" IS NULL OR jsonb_typeof("binding_methods"::jsonb) IS NOT NULL);
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."application"'::regclass AND c.conname='p3_application_02964c7c74be';
 EXECUTE format('COMMENT ON CONSTRAINT %I ON "pb3gir75kkooyea"."application" IS %L','p3_application_02964c7c74be','P3|02964c7c74be55ed39412dd35df15cf412f1c3f824427370028817634cb23b82|'||pg_get_constraintdef(found_oid));
 ELSE
 actual:=obj_description(found_oid,'pg_constraint');
 IF actual IS DISTINCT FROM 'P3|02964c7c74be55ed39412dd35df15cf412f1c3f824427370028817634cb23b82|'||pg_get_constraintdef(found_oid) THEN RAISE EXCEPTION 'Constraint drift: p3_application_02964c7c74be'; END IF;
 END IF; END $p3$;
DO $p3$ DECLARE found_oid oid; actual text; BEGIN
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."application_user_mapping"'::regclass AND c.conname='p3_application_user_mapping_54bd74ca0798';
 IF found_oid IS NULL THEN
 ALTER TABLE "pb3gir75kkooyea"."application_user_mapping" ADD CONSTRAINT "p3_application_user_mapping_54bd74ca0798" CHECK ("version" >= 1);
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."application_user_mapping"'::regclass AND c.conname='p3_application_user_mapping_54bd74ca0798';
 EXECUTE format('COMMENT ON CONSTRAINT %I ON "pb3gir75kkooyea"."application_user_mapping" IS %L','p3_application_user_mapping_54bd74ca0798','P3|54bd74ca0798a435ece1d5eb4b6985c98042502ce3fd5c70fd52d789e401f20a|'||pg_get_constraintdef(found_oid));
 ELSE
 actual:=obj_description(found_oid,'pg_constraint');
 IF actual IS DISTINCT FROM 'P3|54bd74ca0798a435ece1d5eb4b6985c98042502ce3fd5c70fd52d789e401f20a|'||pg_get_constraintdef(found_oid) THEN RAISE EXCEPTION 'Constraint drift: p3_application_user_mapping_54bd74ca0798'; END IF;
 END IF; END $p3$;
DO $p3$ DECLARE found_oid oid; actual text; BEGIN
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."application_user_mapping"'::regclass AND c.conname='p3_application_user_mapping_dd5a228cabbe';
 IF found_oid IS NULL THEN
 ALTER TABLE "pb3gir75kkooyea"."application_user_mapping" ADD CONSTRAINT "p3_application_user_mapping_dd5a228cabbe" FOREIGN KEY ("user_id") REFERENCES "pb3gir75kkooyea"."unified_user" ("id") ON DELETE RESTRICT;
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."application_user_mapping"'::regclass AND c.conname='p3_application_user_mapping_dd5a228cabbe';
 EXECUTE format('COMMENT ON CONSTRAINT %I ON "pb3gir75kkooyea"."application_user_mapping" IS %L','p3_application_user_mapping_dd5a228cabbe','P3|dd5a228cabbef88bac552d8cb7d3d824b57f79c2d919709b886c6984bccbc9bc|'||pg_get_constraintdef(found_oid));
 ELSE
 actual:=obj_description(found_oid,'pg_constraint');
 IF actual IS DISTINCT FROM 'P3|dd5a228cabbef88bac552d8cb7d3d824b57f79c2d919709b886c6984bccbc9bc|'||pg_get_constraintdef(found_oid) THEN RAISE EXCEPTION 'Constraint drift: p3_application_user_mapping_dd5a228cabbe'; END IF;
 END IF; END $p3$;
DO $p3$ DECLARE found_oid oid; actual text; BEGIN
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."application_user_mapping"'::regclass AND c.conname='p3_application_user_mapping_1b8fad9e766c';
 IF found_oid IS NULL THEN
 ALTER TABLE "pb3gir75kkooyea"."application_user_mapping" ADD CONSTRAINT "p3_application_user_mapping_1b8fad9e766c" FOREIGN KEY ("application_id") REFERENCES "pb3gir75kkooyea"."application" ("id") ON DELETE RESTRICT;
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."application_user_mapping"'::regclass AND c.conname='p3_application_user_mapping_1b8fad9e766c';
 EXECUTE format('COMMENT ON CONSTRAINT %I ON "pb3gir75kkooyea"."application_user_mapping" IS %L','p3_application_user_mapping_1b8fad9e766c','P3|1b8fad9e766cd7bd2e35c17116fe2c5736c3eb778c95f71745225a4db275b7f4|'||pg_get_constraintdef(found_oid));
 ELSE
 actual:=obj_description(found_oid,'pg_constraint');
 IF actual IS DISTINCT FROM 'P3|1b8fad9e766cd7bd2e35c17116fe2c5736c3eb778c95f71745225a4db275b7f4|'||pg_get_constraintdef(found_oid) THEN RAISE EXCEPTION 'Constraint drift: p3_application_user_mapping_1b8fad9e766c'; END IF;
 END IF; END $p3$;
DO $p3$ DECLARE found_oid oid; actual text; BEGIN
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."application_user_mapping"'::regclass AND c.conname='p3_application_user_mapping_5648aeaafcaa';
 IF found_oid IS NULL THEN
 ALTER TABLE "pb3gir75kkooyea"."application_user_mapping" ADD CONSTRAINT "p3_application_user_mapping_5648aeaafcaa" CHECK ("binding_method" IN ('AUTO','SELF','ADMIN'));
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."application_user_mapping"'::regclass AND c.conname='p3_application_user_mapping_5648aeaafcaa';
 EXECUTE format('COMMENT ON CONSTRAINT %I ON "pb3gir75kkooyea"."application_user_mapping" IS %L','p3_application_user_mapping_5648aeaafcaa','P3|5648aeaafcaa3fc16840a70bfad8c731408b6cad0a390d57803a0c02b52869fe|'||pg_get_constraintdef(found_oid));
 ELSE
 actual:=obj_description(found_oid,'pg_constraint');
 IF actual IS DISTINCT FROM 'P3|5648aeaafcaa3fc16840a70bfad8c731408b6cad0a390d57803a0c02b52869fe|'||pg_get_constraintdef(found_oid) THEN RAISE EXCEPTION 'Constraint drift: p3_application_user_mapping_5648aeaafcaa'; END IF;
 END IF; END $p3$;
DO $p3$ DECLARE found_oid oid; actual text; BEGIN
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."application_user_mapping"'::regclass AND c.conname='p3_application_user_mapping_d93a1bc6dd1d';
 IF found_oid IS NULL THEN
 ALTER TABLE "pb3gir75kkooyea"."application_user_mapping" ADD CONSTRAINT "p3_application_user_mapping_d93a1bc6dd1d" CHECK ("status" IN ('UNBOUND','VERIFYING','BOUND','FAILED','CONFLICT'));
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."application_user_mapping"'::regclass AND c.conname='p3_application_user_mapping_d93a1bc6dd1d';
 EXECUTE format('COMMENT ON CONSTRAINT %I ON "pb3gir75kkooyea"."application_user_mapping" IS %L','p3_application_user_mapping_d93a1bc6dd1d','P3|d93a1bc6dd1d15abe1c5c26fa82b22d234f23d6362efe2347264ec12428709e8|'||pg_get_constraintdef(found_oid));
 ELSE
 actual:=obj_description(found_oid,'pg_constraint');
 IF actual IS DISTINCT FROM 'P3|d93a1bc6dd1d15abe1c5c26fa82b22d234f23d6362efe2347264ec12428709e8|'||pg_get_constraintdef(found_oid) THEN RAISE EXCEPTION 'Constraint drift: p3_application_user_mapping_d93a1bc6dd1d'; END IF;
 END IF; END $p3$;
DO $p3$ DECLARE found_oid oid; actual text; BEGIN
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."application_user_mapping"'::regclass AND c.conname='p3_application_user_mapping_0f52ff390c6c';
 IF found_oid IS NULL THEN
 ALTER TABLE "pb3gir75kkooyea"."application_user_mapping" ADD CONSTRAINT "p3_application_user_mapping_0f52ff390c6c" CHECK ((status = 'BOUND' AND external_user_id IS NOT NULL AND active_account_key IS NOT NULL) OR (status <> 'BOUND' AND active_account_key IS NULL));
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."application_user_mapping"'::regclass AND c.conname='p3_application_user_mapping_0f52ff390c6c';
 EXECUTE format('COMMENT ON CONSTRAINT %I ON "pb3gir75kkooyea"."application_user_mapping" IS %L','p3_application_user_mapping_0f52ff390c6c','P3|0f52ff390c6c0a843cd8b4649b783e700d4c73a3f47f805e4b7045f35bf174a2|'||pg_get_constraintdef(found_oid));
 ELSE
 actual:=obj_description(found_oid,'pg_constraint');
 IF actual IS DISTINCT FROM 'P3|0f52ff390c6c0a843cd8b4649b783e700d4c73a3f47f805e4b7045f35bf174a2|'||pg_get_constraintdef(found_oid) THEN RAISE EXCEPTION 'Constraint drift: p3_application_user_mapping_0f52ff390c6c'; END IF;
 END IF; END $p3$;
DO $p3$ DECLARE found_oid oid; actual text; BEGIN
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."application_user_mapping"'::regclass AND c.conname='p3_application_user_mapping_4301624b1176';
 IF found_oid IS NULL THEN
 ALTER TABLE "pb3gir75kkooyea"."application_user_mapping" ADD CONSTRAINT "p3_application_user_mapping_4301624b1176" CHECK (active_account_key IS NULL OR active_account_key::jsonb = jsonb_build_array(application_id, external_user_id));
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."application_user_mapping"'::regclass AND c.conname='p3_application_user_mapping_4301624b1176';
 EXECUTE format('COMMENT ON CONSTRAINT %I ON "pb3gir75kkooyea"."application_user_mapping" IS %L','p3_application_user_mapping_4301624b1176','P3|4301624b1176d494f009a018043b12b191e89cee91b85a915e939aca829feffa|'||pg_get_constraintdef(found_oid));
 ELSE
 actual:=obj_description(found_oid,'pg_constraint');
 IF actual IS DISTINCT FROM 'P3|4301624b1176d494f009a018043b12b191e89cee91b85a915e939aca829feffa|'||pg_get_constraintdef(found_oid) THEN RAISE EXCEPTION 'Constraint drift: p3_application_user_mapping_4301624b1176'; END IF;
 END IF; END $p3$;
DO $p3$ DECLARE found_oid oid; BEGIN
 found_oid:=to_regclass('pb3gir75kkooyea.p3i_application_user_mapping_fab186218987');
 IF found_oid IS NULL THEN
 CREATE UNIQUE INDEX "p3i_application_user_mapping_fab186218987" ON "pb3gir75kkooyea"."application_user_mapping" ("application_id","external_user_id") WHERE status = 'BOUND';
 found_oid:=to_regclass('pb3gir75kkooyea.p3i_application_user_mapping_fab186218987');
 EXECUTE format('COMMENT ON INDEX "pb3gir75kkooyea".%I IS %L','p3i_application_user_mapping_fab186218987','P3|fab186218987db3e8fbab9d9138c5fab8a144b536457e3df0302f647604d19cc|'||pg_get_indexdef(found_oid));
 ELSIF obj_description(found_oid,'pg_class') IS DISTINCT FROM 'P3|fab186218987db3e8fbab9d9138c5fab8a144b536457e3df0302f647604d19cc|'||pg_get_indexdef(found_oid) THEN RAISE EXCEPTION 'Index drift: p3i_application_user_mapping_fab186218987';
 END IF; END $p3$;
DO $p3$ DECLARE found_oid oid; actual text; BEGIN
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."mapping_exception"'::regclass AND c.conname='p3_mapping_exception_bc50abcb628d';
 IF found_oid IS NULL THEN
 ALTER TABLE "pb3gir75kkooyea"."mapping_exception" ADD CONSTRAINT "p3_mapping_exception_bc50abcb628d" CHECK ("version" >= 1);
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."mapping_exception"'::regclass AND c.conname='p3_mapping_exception_bc50abcb628d';
 EXECUTE format('COMMENT ON CONSTRAINT %I ON "pb3gir75kkooyea"."mapping_exception" IS %L','p3_mapping_exception_bc50abcb628d','P3|bc50abcb628d2c16feb017b1ce0379f409d2462de728601d72b4eee5f3e0ca27|'||pg_get_constraintdef(found_oid));
 ELSE
 actual:=obj_description(found_oid,'pg_constraint');
 IF actual IS DISTINCT FROM 'P3|bc50abcb628d2c16feb017b1ce0379f409d2462de728601d72b4eee5f3e0ca27|'||pg_get_constraintdef(found_oid) THEN RAISE EXCEPTION 'Constraint drift: p3_mapping_exception_bc50abcb628d'; END IF;
 END IF; END $p3$;
DO $p3$ DECLARE found_oid oid; actual text; BEGIN
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."mapping_exception"'::regclass AND c.conname='p3_mapping_exception_09aba357a39e';
 IF found_oid IS NULL THEN
 ALTER TABLE "pb3gir75kkooyea"."mapping_exception" ADD CONSTRAINT "p3_mapping_exception_09aba357a39e" FOREIGN KEY ("mapping_id") REFERENCES "pb3gir75kkooyea"."application_user_mapping" ("id") ON DELETE RESTRICT;
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."mapping_exception"'::regclass AND c.conname='p3_mapping_exception_09aba357a39e';
 EXECUTE format('COMMENT ON CONSTRAINT %I ON "pb3gir75kkooyea"."mapping_exception" IS %L','p3_mapping_exception_09aba357a39e','P3|09aba357a39ecbd7f3fd542a81126a5f6a37a6ecc20a73289fd7622ad567a79b|'||pg_get_constraintdef(found_oid));
 ELSE
 actual:=obj_description(found_oid,'pg_constraint');
 IF actual IS DISTINCT FROM 'P3|09aba357a39ecbd7f3fd542a81126a5f6a37a6ecc20a73289fd7622ad567a79b|'||pg_get_constraintdef(found_oid) THEN RAISE EXCEPTION 'Constraint drift: p3_mapping_exception_09aba357a39e'; END IF;
 END IF; END $p3$;
DO $p3$ DECLARE found_oid oid; actual text; BEGIN
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."mapping_exception"'::regclass AND c.conname='p3_mapping_exception_17b097b399c0';
 IF found_oid IS NULL THEN
 ALTER TABLE "pb3gir75kkooyea"."mapping_exception" ADD CONSTRAINT "p3_mapping_exception_17b097b399c0" FOREIGN KEY ("identity_mapping_id") REFERENCES "pb3gir75kkooyea"."identity_mapping" ("id") ON DELETE RESTRICT;
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."mapping_exception"'::regclass AND c.conname='p3_mapping_exception_17b097b399c0';
 EXECUTE format('COMMENT ON CONSTRAINT %I ON "pb3gir75kkooyea"."mapping_exception" IS %L','p3_mapping_exception_17b097b399c0','P3|17b097b399c0b804356a6152dc0016a3bf052a9e6a46ec77da42349367f1ccce|'||pg_get_constraintdef(found_oid));
 ELSE
 actual:=obj_description(found_oid,'pg_constraint');
 IF actual IS DISTINCT FROM 'P3|17b097b399c0b804356a6152dc0016a3bf052a9e6a46ec77da42349367f1ccce|'||pg_get_constraintdef(found_oid) THEN RAISE EXCEPTION 'Constraint drift: p3_mapping_exception_17b097b399c0'; END IF;
 END IF; END $p3$;
DO $p3$ DECLARE found_oid oid; actual text; BEGIN
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."mapping_exception"'::regclass AND c.conname='p3_mapping_exception_b976b27a5623';
 IF found_oid IS NULL THEN
 ALTER TABLE "pb3gir75kkooyea"."mapping_exception" ADD CONSTRAINT "p3_mapping_exception_b976b27a5623" CHECK ("resolution_status" IN ('OPEN','RESOLVED'));
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."mapping_exception"'::regclass AND c.conname='p3_mapping_exception_b976b27a5623';
 EXECUTE format('COMMENT ON CONSTRAINT %I ON "pb3gir75kkooyea"."mapping_exception" IS %L','p3_mapping_exception_b976b27a5623','P3|b976b27a56236a134b350425465689440e1c9f9c029a119d490fc14c77ee4bea|'||pg_get_constraintdef(found_oid));
 ELSE
 actual:=obj_description(found_oid,'pg_constraint');
 IF actual IS DISTINCT FROM 'P3|b976b27a56236a134b350425465689440e1c9f9c029a119d490fc14c77ee4bea|'||pg_get_constraintdef(found_oid) THEN RAISE EXCEPTION 'Constraint drift: p3_mapping_exception_b976b27a5623'; END IF;
 END IF; END $p3$;
DO $p3$ DECLARE found_oid oid; actual text; BEGIN
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."mapping_exception"'::regclass AND c.conname='p3_mapping_exception_7e1c3c279f94';
 IF found_oid IS NULL THEN
 ALTER TABLE "pb3gir75kkooyea"."mapping_exception" ADD CONSTRAINT "p3_mapping_exception_7e1c3c279f94" FOREIGN KEY ("resolved_by") REFERENCES "pb3gir75kkooyea"."unified_user" ("id") ON DELETE RESTRICT;
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."mapping_exception"'::regclass AND c.conname='p3_mapping_exception_7e1c3c279f94';
 EXECUTE format('COMMENT ON CONSTRAINT %I ON "pb3gir75kkooyea"."mapping_exception" IS %L','p3_mapping_exception_7e1c3c279f94','P3|7e1c3c279f940bf29ab36e534b44aede702f307b06b8294c25ea20ceb9fcd54e|'||pg_get_constraintdef(found_oid));
 ELSE
 actual:=obj_description(found_oid,'pg_constraint');
 IF actual IS DISTINCT FROM 'P3|7e1c3c279f940bf29ab36e534b44aede702f307b06b8294c25ea20ceb9fcd54e|'||pg_get_constraintdef(found_oid) THEN RAISE EXCEPTION 'Constraint drift: p3_mapping_exception_7e1c3c279f94'; END IF;
 END IF; END $p3$;
DO $p3$ DECLARE found_oid oid; actual text; BEGIN
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."mapping_exception"'::regclass AND c.conname='p3_mapping_exception_8a626dcbe6e8';
 IF found_oid IS NULL THEN
 ALTER TABLE "pb3gir75kkooyea"."mapping_exception" ADD CONSTRAINT "p3_mapping_exception_8a626dcbe6e8" CHECK (mapping_id IS NOT NULL OR identity_mapping_id IS NOT NULL);
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."mapping_exception"'::regclass AND c.conname='p3_mapping_exception_8a626dcbe6e8';
 EXECUTE format('COMMENT ON CONSTRAINT %I ON "pb3gir75kkooyea"."mapping_exception" IS %L','p3_mapping_exception_8a626dcbe6e8','P3|8a626dcbe6e81ccc054379121748f20e4d68320081602b27eb40be3157619627|'||pg_get_constraintdef(found_oid));
 ELSE
 actual:=obj_description(found_oid,'pg_constraint');
 IF actual IS DISTINCT FROM 'P3|8a626dcbe6e81ccc054379121748f20e4d68320081602b27eb40be3157619627|'||pg_get_constraintdef(found_oid) THEN RAISE EXCEPTION 'Constraint drift: p3_mapping_exception_8a626dcbe6e8'; END IF;
 END IF; END $p3$;
DO $p3$ DECLARE found_oid oid; actual text; BEGIN
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."portal_role"'::regclass AND c.conname='p3_portal_role_123fb4975c95';
 IF found_oid IS NULL THEN
 ALTER TABLE "pb3gir75kkooyea"."portal_role" ADD CONSTRAINT "p3_portal_role_123fb4975c95" CHECK ("version" >= 1);
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."portal_role"'::regclass AND c.conname='p3_portal_role_123fb4975c95';
 EXECUTE format('COMMENT ON CONSTRAINT %I ON "pb3gir75kkooyea"."portal_role" IS %L','p3_portal_role_123fb4975c95','P3|123fb4975c958c114e8f7be536b51c9922ca2f3ef8b609664742dff470a7d11f|'||pg_get_constraintdef(found_oid));
 ELSE
 actual:=obj_description(found_oid,'pg_constraint');
 IF actual IS DISTINCT FROM 'P3|123fb4975c958c114e8f7be536b51c9922ca2f3ef8b609664742dff470a7d11f|'||pg_get_constraintdef(found_oid) THEN RAISE EXCEPTION 'Constraint drift: p3_portal_role_123fb4975c95'; END IF;
 END IF; END $p3$;
DO $p3$ DECLARE found_oid oid; actual text; BEGIN
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."portal_role"'::regclass AND c.conname='p3_portal_role_f444ada05f76';
 IF found_oid IS NULL THEN
 ALTER TABLE "pb3gir75kkooyea"."portal_role" ADD CONSTRAINT "p3_portal_role_f444ada05f76" CHECK ("status" IN ('ENABLED','DISABLED'));
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."portal_role"'::regclass AND c.conname='p3_portal_role_f444ada05f76';
 EXECUTE format('COMMENT ON CONSTRAINT %I ON "pb3gir75kkooyea"."portal_role" IS %L','p3_portal_role_f444ada05f76','P3|f444ada05f76b10b6a54142e6809a9aace863325969a165468209c289374bbd7|'||pg_get_constraintdef(found_oid));
 ELSE
 actual:=obj_description(found_oid,'pg_constraint');
 IF actual IS DISTINCT FROM 'P3|f444ada05f76b10b6a54142e6809a9aace863325969a165468209c289374bbd7|'||pg_get_constraintdef(found_oid) THEN RAISE EXCEPTION 'Constraint drift: p3_portal_role_f444ada05f76'; END IF;
 END IF; END $p3$;
DO $p3$ DECLARE found_oid oid; actual text; BEGIN
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."portal_permission"'::regclass AND c.conname='p3_portal_permission_8be33f8f42ab';
 IF found_oid IS NULL THEN
 ALTER TABLE "pb3gir75kkooyea"."portal_permission" ADD CONSTRAINT "p3_portal_permission_8be33f8f42ab" CHECK ("version" >= 1);
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."portal_permission"'::regclass AND c.conname='p3_portal_permission_8be33f8f42ab';
 EXECUTE format('COMMENT ON CONSTRAINT %I ON "pb3gir75kkooyea"."portal_permission" IS %L','p3_portal_permission_8be33f8f42ab','P3|8be33f8f42ab2d2d63bfe75f344c30ecd1767dc589b0e5e724b707972024ee42|'||pg_get_constraintdef(found_oid));
 ELSE
 actual:=obj_description(found_oid,'pg_constraint');
 IF actual IS DISTINCT FROM 'P3|8be33f8f42ab2d2d63bfe75f344c30ecd1767dc589b0e5e724b707972024ee42|'||pg_get_constraintdef(found_oid) THEN RAISE EXCEPTION 'Constraint drift: p3_portal_permission_8be33f8f42ab'; END IF;
 END IF; END $p3$;
DO $p3$ DECLARE found_oid oid; actual text; BEGIN
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."portal_permission"'::regclass AND c.conname='p3_portal_permission_e2f136b55d47';
 IF found_oid IS NULL THEN
 ALTER TABLE "pb3gir75kkooyea"."portal_permission" ADD CONSTRAINT "p3_portal_permission_e2f136b55d47" CHECK ("kind" IN ('MENU','PAGE','ACTION'));
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."portal_permission"'::regclass AND c.conname='p3_portal_permission_e2f136b55d47';
 EXECUTE format('COMMENT ON CONSTRAINT %I ON "pb3gir75kkooyea"."portal_permission" IS %L','p3_portal_permission_e2f136b55d47','P3|e2f136b55d47a1413a200c95f007f78d1057cf520ebfcba77f90f38fa86b5a53|'||pg_get_constraintdef(found_oid));
 ELSE
 actual:=obj_description(found_oid,'pg_constraint');
 IF actual IS DISTINCT FROM 'P3|e2f136b55d47a1413a200c95f007f78d1057cf520ebfcba77f90f38fa86b5a53|'||pg_get_constraintdef(found_oid) THEN RAISE EXCEPTION 'Constraint drift: p3_portal_permission_e2f136b55d47'; END IF;
 END IF; END $p3$;
DO $p3$ DECLARE found_oid oid; actual text; BEGIN
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."portal_role_permission"'::regclass AND c.conname='p3_portal_role_permission_eca0dd2173be';
 IF found_oid IS NULL THEN
 ALTER TABLE "pb3gir75kkooyea"."portal_role_permission" ADD CONSTRAINT "p3_portal_role_permission_eca0dd2173be" CHECK ("version" >= 1);
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."portal_role_permission"'::regclass AND c.conname='p3_portal_role_permission_eca0dd2173be';
 EXECUTE format('COMMENT ON CONSTRAINT %I ON "pb3gir75kkooyea"."portal_role_permission" IS %L','p3_portal_role_permission_eca0dd2173be','P3|eca0dd2173beec1347010f10cd4087b9afe1fb81be69beb7dc673eb4ed027104|'||pg_get_constraintdef(found_oid));
 ELSE
 actual:=obj_description(found_oid,'pg_constraint');
 IF actual IS DISTINCT FROM 'P3|eca0dd2173beec1347010f10cd4087b9afe1fb81be69beb7dc673eb4ed027104|'||pg_get_constraintdef(found_oid) THEN RAISE EXCEPTION 'Constraint drift: p3_portal_role_permission_eca0dd2173be'; END IF;
 END IF; END $p3$;
DO $p3$ DECLARE found_oid oid; actual text; BEGIN
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."portal_role_permission"'::regclass AND c.conname='p3_portal_role_permission_b6485f91b766';
 IF found_oid IS NULL THEN
 ALTER TABLE "pb3gir75kkooyea"."portal_role_permission" ADD CONSTRAINT "p3_portal_role_permission_b6485f91b766" FOREIGN KEY ("role_id") REFERENCES "pb3gir75kkooyea"."portal_role" ("id") ON DELETE RESTRICT;
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."portal_role_permission"'::regclass AND c.conname='p3_portal_role_permission_b6485f91b766';
 EXECUTE format('COMMENT ON CONSTRAINT %I ON "pb3gir75kkooyea"."portal_role_permission" IS %L','p3_portal_role_permission_b6485f91b766','P3|b6485f91b76617f81c423c371171ce1ba930a3d08e9566cbb3f0481a73d1acce|'||pg_get_constraintdef(found_oid));
 ELSE
 actual:=obj_description(found_oid,'pg_constraint');
 IF actual IS DISTINCT FROM 'P3|b6485f91b76617f81c423c371171ce1ba930a3d08e9566cbb3f0481a73d1acce|'||pg_get_constraintdef(found_oid) THEN RAISE EXCEPTION 'Constraint drift: p3_portal_role_permission_b6485f91b766'; END IF;
 END IF; END $p3$;
DO $p3$ DECLARE found_oid oid; actual text; BEGIN
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."portal_role_permission"'::regclass AND c.conname='p3_portal_role_permission_9ec3c8569c7e';
 IF found_oid IS NULL THEN
 ALTER TABLE "pb3gir75kkooyea"."portal_role_permission" ADD CONSTRAINT "p3_portal_role_permission_9ec3c8569c7e" FOREIGN KEY ("permission_id") REFERENCES "pb3gir75kkooyea"."portal_permission" ("id") ON DELETE RESTRICT;
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."portal_role_permission"'::regclass AND c.conname='p3_portal_role_permission_9ec3c8569c7e';
 EXECUTE format('COMMENT ON CONSTRAINT %I ON "pb3gir75kkooyea"."portal_role_permission" IS %L','p3_portal_role_permission_9ec3c8569c7e','P3|9ec3c8569c7e84fbb17d6f88b0fe6b7b035e792eb282205242b9c63280146366|'||pg_get_constraintdef(found_oid));
 ELSE
 actual:=obj_description(found_oid,'pg_constraint');
 IF actual IS DISTINCT FROM 'P3|9ec3c8569c7e84fbb17d6f88b0fe6b7b035e792eb282205242b9c63280146366|'||pg_get_constraintdef(found_oid) THEN RAISE EXCEPTION 'Constraint drift: p3_portal_role_permission_9ec3c8569c7e'; END IF;
 END IF; END $p3$;
DO $p3$ DECLARE found_oid oid; actual text; BEGIN
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."portal_role_permission"'::regclass AND c.conname='p3_portal_role_permission_1d907ab4e6b3';
 IF found_oid IS NULL THEN
 ALTER TABLE "pb3gir75kkooyea"."portal_role_permission" ADD CONSTRAINT "p3_portal_role_permission_1d907ab4e6b3" CHECK ("data_scope" IN ('SELF','ASSIGNED_APPS','ALL_PORTAL'));
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."portal_role_permission"'::regclass AND c.conname='p3_portal_role_permission_1d907ab4e6b3';
 EXECUTE format('COMMENT ON CONSTRAINT %I ON "pb3gir75kkooyea"."portal_role_permission" IS %L','p3_portal_role_permission_1d907ab4e6b3','P3|1d907ab4e6b377bdcb16ae4245d3adfffd1736542c59f3f816063944d96517e2|'||pg_get_constraintdef(found_oid));
 ELSE
 actual:=obj_description(found_oid,'pg_constraint');
 IF actual IS DISTINCT FROM 'P3|1d907ab4e6b377bdcb16ae4245d3adfffd1736542c59f3f816063944d96517e2|'||pg_get_constraintdef(found_oid) THEN RAISE EXCEPTION 'Constraint drift: p3_portal_role_permission_1d907ab4e6b3'; END IF;
 END IF; END $p3$;
DO $p3$ DECLARE found_oid oid; actual text; BEGIN
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."portal_user_role"'::regclass AND c.conname='p3_portal_user_role_12b81bc0c5f8';
 IF found_oid IS NULL THEN
 ALTER TABLE "pb3gir75kkooyea"."portal_user_role" ADD CONSTRAINT "p3_portal_user_role_12b81bc0c5f8" CHECK ("version" >= 1);
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."portal_user_role"'::regclass AND c.conname='p3_portal_user_role_12b81bc0c5f8';
 EXECUTE format('COMMENT ON CONSTRAINT %I ON "pb3gir75kkooyea"."portal_user_role" IS %L','p3_portal_user_role_12b81bc0c5f8','P3|12b81bc0c5f80bc4dfe99b4d27457f0720bef1303a119c6e5fcff127c8eb3234|'||pg_get_constraintdef(found_oid));
 ELSE
 actual:=obj_description(found_oid,'pg_constraint');
 IF actual IS DISTINCT FROM 'P3|12b81bc0c5f80bc4dfe99b4d27457f0720bef1303a119c6e5fcff127c8eb3234|'||pg_get_constraintdef(found_oid) THEN RAISE EXCEPTION 'Constraint drift: p3_portal_user_role_12b81bc0c5f8'; END IF;
 END IF; END $p3$;
DO $p3$ DECLARE found_oid oid; actual text; BEGIN
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."portal_user_role"'::regclass AND c.conname='p3_portal_user_role_0849fd7a7a80';
 IF found_oid IS NULL THEN
 ALTER TABLE "pb3gir75kkooyea"."portal_user_role" ADD CONSTRAINT "p3_portal_user_role_0849fd7a7a80" FOREIGN KEY ("user_id") REFERENCES "pb3gir75kkooyea"."unified_user" ("id") ON DELETE RESTRICT;
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."portal_user_role"'::regclass AND c.conname='p3_portal_user_role_0849fd7a7a80';
 EXECUTE format('COMMENT ON CONSTRAINT %I ON "pb3gir75kkooyea"."portal_user_role" IS %L','p3_portal_user_role_0849fd7a7a80','P3|0849fd7a7a800df4ab1e5f8474c164f30e4c8233fb3d341b5c44ca2664b40c66|'||pg_get_constraintdef(found_oid));
 ELSE
 actual:=obj_description(found_oid,'pg_constraint');
 IF actual IS DISTINCT FROM 'P3|0849fd7a7a800df4ab1e5f8474c164f30e4c8233fb3d341b5c44ca2664b40c66|'||pg_get_constraintdef(found_oid) THEN RAISE EXCEPTION 'Constraint drift: p3_portal_user_role_0849fd7a7a80'; END IF;
 END IF; END $p3$;
DO $p3$ DECLARE found_oid oid; actual text; BEGIN
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."portal_user_role"'::regclass AND c.conname='p3_portal_user_role_d4208346bab7';
 IF found_oid IS NULL THEN
 ALTER TABLE "pb3gir75kkooyea"."portal_user_role" ADD CONSTRAINT "p3_portal_user_role_d4208346bab7" FOREIGN KEY ("role_id") REFERENCES "pb3gir75kkooyea"."portal_role" ("id") ON DELETE RESTRICT;
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."portal_user_role"'::regclass AND c.conname='p3_portal_user_role_d4208346bab7';
 EXECUTE format('COMMENT ON CONSTRAINT %I ON "pb3gir75kkooyea"."portal_user_role" IS %L','p3_portal_user_role_d4208346bab7','P3|d4208346bab7cfa641a35a17d4d6f7be7a1354ff9053060c5f7610e05d1d9252|'||pg_get_constraintdef(found_oid));
 ELSE
 actual:=obj_description(found_oid,'pg_constraint');
 IF actual IS DISTINCT FROM 'P3|d4208346bab7cfa641a35a17d4d6f7be7a1354ff9053060c5f7610e05d1d9252|'||pg_get_constraintdef(found_oid) THEN RAISE EXCEPTION 'Constraint drift: p3_portal_user_role_d4208346bab7'; END IF;
 END IF; END $p3$;
DO $p3$ DECLARE found_oid oid; actual text; BEGIN
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."portal_user_role"'::regclass AND c.conname='p3_portal_user_role_4a380d95e225';
 IF found_oid IS NULL THEN
 ALTER TABLE "pb3gir75kkooyea"."portal_user_role" ADD CONSTRAINT "p3_portal_user_role_4a380d95e225" FOREIGN KEY ("granted_by") REFERENCES "pb3gir75kkooyea"."unified_user" ("id") ON DELETE RESTRICT;
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."portal_user_role"'::regclass AND c.conname='p3_portal_user_role_4a380d95e225';
 EXECUTE format('COMMENT ON CONSTRAINT %I ON "pb3gir75kkooyea"."portal_user_role" IS %L','p3_portal_user_role_4a380d95e225','P3|4a380d95e2256b550504a2bd84fc8128cb0b70a881f369cbbb8b535aa7930fd5|'||pg_get_constraintdef(found_oid));
 ELSE
 actual:=obj_description(found_oid,'pg_constraint');
 IF actual IS DISTINCT FROM 'P3|4a380d95e2256b550504a2bd84fc8128cb0b70a881f369cbbb8b535aa7930fd5|'||pg_get_constraintdef(found_oid) THEN RAISE EXCEPTION 'Constraint drift: p3_portal_user_role_4a380d95e225'; END IF;
 END IF; END $p3$;
DO $p3$ DECLARE found_oid oid; actual text; BEGIN
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."portal_user_application_scope"'::regclass AND c.conname='p3_portal_user_application_scop_f04211de0815';
 IF found_oid IS NULL THEN
 ALTER TABLE "pb3gir75kkooyea"."portal_user_application_scope" ADD CONSTRAINT "p3_portal_user_application_scop_f04211de0815" CHECK ("version" >= 1);
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."portal_user_application_scope"'::regclass AND c.conname='p3_portal_user_application_scop_f04211de0815';
 EXECUTE format('COMMENT ON CONSTRAINT %I ON "pb3gir75kkooyea"."portal_user_application_scope" IS %L','p3_portal_user_application_scop_f04211de0815','P3|f04211de0815614d68c98b5b11c34ebe80e1746dc237cbdba0ebf27910c49202|'||pg_get_constraintdef(found_oid));
 ELSE
 actual:=obj_description(found_oid,'pg_constraint');
 IF actual IS DISTINCT FROM 'P3|f04211de0815614d68c98b5b11c34ebe80e1746dc237cbdba0ebf27910c49202|'||pg_get_constraintdef(found_oid) THEN RAISE EXCEPTION 'Constraint drift: p3_portal_user_application_scop_f04211de0815'; END IF;
 END IF; END $p3$;
DO $p3$ DECLARE found_oid oid; actual text; BEGIN
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."portal_user_application_scope"'::regclass AND c.conname='p3_portal_user_application_scop_9a096a6549a3';
 IF found_oid IS NULL THEN
 ALTER TABLE "pb3gir75kkooyea"."portal_user_application_scope" ADD CONSTRAINT "p3_portal_user_application_scop_9a096a6549a3" FOREIGN KEY ("user_id") REFERENCES "pb3gir75kkooyea"."unified_user" ("id") ON DELETE RESTRICT;
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."portal_user_application_scope"'::regclass AND c.conname='p3_portal_user_application_scop_9a096a6549a3';
 EXECUTE format('COMMENT ON CONSTRAINT %I ON "pb3gir75kkooyea"."portal_user_application_scope" IS %L','p3_portal_user_application_scop_9a096a6549a3','P3|9a096a6549a39d915c5e4a3237b1311549af150192ea183ea285df8d3e7fcb17|'||pg_get_constraintdef(found_oid));
 ELSE
 actual:=obj_description(found_oid,'pg_constraint');
 IF actual IS DISTINCT FROM 'P3|9a096a6549a39d915c5e4a3237b1311549af150192ea183ea285df8d3e7fcb17|'||pg_get_constraintdef(found_oid) THEN RAISE EXCEPTION 'Constraint drift: p3_portal_user_application_scop_9a096a6549a3'; END IF;
 END IF; END $p3$;
DO $p3$ DECLARE found_oid oid; actual text; BEGIN
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."portal_user_application_scope"'::regclass AND c.conname='p3_portal_user_application_scop_7710f6116ca9';
 IF found_oid IS NULL THEN
 ALTER TABLE "pb3gir75kkooyea"."portal_user_application_scope" ADD CONSTRAINT "p3_portal_user_application_scop_7710f6116ca9" FOREIGN KEY ("application_id") REFERENCES "pb3gir75kkooyea"."application" ("id") ON DELETE RESTRICT;
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."portal_user_application_scope"'::regclass AND c.conname='p3_portal_user_application_scop_7710f6116ca9';
 EXECUTE format('COMMENT ON CONSTRAINT %I ON "pb3gir75kkooyea"."portal_user_application_scope" IS %L','p3_portal_user_application_scop_7710f6116ca9','P3|7710f6116ca9318c6d9403567a916da6215623436d7b1be51899c4aaa47cf918|'||pg_get_constraintdef(found_oid));
 ELSE
 actual:=obj_description(found_oid,'pg_constraint');
 IF actual IS DISTINCT FROM 'P3|7710f6116ca9318c6d9403567a916da6215623436d7b1be51899c4aaa47cf918|'||pg_get_constraintdef(found_oid) THEN RAISE EXCEPTION 'Constraint drift: p3_portal_user_application_scop_7710f6116ca9'; END IF;
 END IF; END $p3$;
DO $p3$ DECLARE found_oid oid; actual text; BEGIN
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."sso_config"'::regclass AND c.conname='p3_sso_config_9980d02cf243';
 IF found_oid IS NULL THEN
 ALTER TABLE "pb3gir75kkooyea"."sso_config" ADD CONSTRAINT "p3_sso_config_9980d02cf243" CHECK ("version" >= 1);
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."sso_config"'::regclass AND c.conname='p3_sso_config_9980d02cf243';
 EXECUTE format('COMMENT ON CONSTRAINT %I ON "pb3gir75kkooyea"."sso_config" IS %L','p3_sso_config_9980d02cf243','P3|9980d02cf2431b8d300fbd4c97dfac35be82f8be761da120e920b25076ee9854|'||pg_get_constraintdef(found_oid));
 ELSE
 actual:=obj_description(found_oid,'pg_constraint');
 IF actual IS DISTINCT FROM 'P3|9980d02cf2431b8d300fbd4c97dfac35be82f8be761da120e920b25076ee9854|'||pg_get_constraintdef(found_oid) THEN RAISE EXCEPTION 'Constraint drift: p3_sso_config_9980d02cf243'; END IF;
 END IF; END $p3$;
DO $p3$ DECLARE found_oid oid; actual text; BEGIN
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."sso_config"'::regclass AND c.conname='p3_sso_config_cd9ef0de6fe5';
 IF found_oid IS NULL THEN
 ALTER TABLE "pb3gir75kkooyea"."sso_config" ADD CONSTRAINT "p3_sso_config_cd9ef0de6fe5" FOREIGN KEY ("application_id") REFERENCES "pb3gir75kkooyea"."application" ("id") ON DELETE RESTRICT;
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."sso_config"'::regclass AND c.conname='p3_sso_config_cd9ef0de6fe5';
 EXECUTE format('COMMENT ON CONSTRAINT %I ON "pb3gir75kkooyea"."sso_config" IS %L','p3_sso_config_cd9ef0de6fe5','P3|cd9ef0de6fe5a43f653d1a7d7cc7dba66e66197d51afb72958ff2ff6079b6b74|'||pg_get_constraintdef(found_oid));
 ELSE
 actual:=obj_description(found_oid,'pg_constraint');
 IF actual IS DISTINCT FROM 'P3|cd9ef0de6fe5a43f653d1a7d7cc7dba66e66197d51afb72958ff2ff6079b6b74|'||pg_get_constraintdef(found_oid) THEN RAISE EXCEPTION 'Constraint drift: p3_sso_config_cd9ef0de6fe5'; END IF;
 END IF; END $p3$;
DO $p3$ DECLARE found_oid oid; actual text; BEGIN
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."sso_config"'::regclass AND c.conname='p3_sso_config_061254b8193d';
 IF found_oid IS NULL THEN
 ALTER TABLE "pb3gir75kkooyea"."sso_config" ADD CONSTRAINT "p3_sso_config_061254b8193d" CHECK ("endpoints" IS NULL OR jsonb_typeof("endpoints"::jsonb) IS NOT NULL);
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."sso_config"'::regclass AND c.conname='p3_sso_config_061254b8193d';
 EXECUTE format('COMMENT ON CONSTRAINT %I ON "pb3gir75kkooyea"."sso_config" IS %L','p3_sso_config_061254b8193d','P3|061254b8193d7ade1e7b80e70bedd1801c2deb5cecbc73b19705af35b37bb815|'||pg_get_constraintdef(found_oid));
 ELSE
 actual:=obj_description(found_oid,'pg_constraint');
 IF actual IS DISTINCT FROM 'P3|061254b8193d7ade1e7b80e70bedd1801c2deb5cecbc73b19705af35b37bb815|'||pg_get_constraintdef(found_oid) THEN RAISE EXCEPTION 'Constraint drift: p3_sso_config_061254b8193d'; END IF;
 END IF; END $p3$;
DO $p3$ DECLARE found_oid oid; actual text; BEGIN
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."sso_config"'::regclass AND c.conname='p3_sso_config_eace3eddbdc3';
 IF found_oid IS NULL THEN
 ALTER TABLE "pb3gir75kkooyea"."sso_config" ADD CONSTRAINT "p3_sso_config_eace3eddbdc3" CHECK ("status" IN ('NORMAL','ABNORMAL','UNCONFIGURED','DISABLED'));
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."sso_config"'::regclass AND c.conname='p3_sso_config_eace3eddbdc3';
 EXECUTE format('COMMENT ON CONSTRAINT %I ON "pb3gir75kkooyea"."sso_config" IS %L','p3_sso_config_eace3eddbdc3','P3|eace3eddbdc31df43c253c631f88a5f92969c1671a25a4ba070d24fdd20aa642|'||pg_get_constraintdef(found_oid));
 ELSE
 actual:=obj_description(found_oid,'pg_constraint');
 IF actual IS DISTINCT FROM 'P3|eace3eddbdc31df43c253c631f88a5f92969c1671a25a4ba070d24fdd20aa642|'||pg_get_constraintdef(found_oid) THEN RAISE EXCEPTION 'Constraint drift: p3_sso_config_eace3eddbdc3'; END IF;
 END IF; END $p3$;
DO $p3$ DECLARE found_oid oid; actual text; BEGIN
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."push_integration_config"'::regclass AND c.conname='p3_push_integration_config_01a340c66c84';
 IF found_oid IS NULL THEN
 ALTER TABLE "pb3gir75kkooyea"."push_integration_config" ADD CONSTRAINT "p3_push_integration_config_01a340c66c84" CHECK ("version" >= 1);
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."push_integration_config"'::regclass AND c.conname='p3_push_integration_config_01a340c66c84';
 EXECUTE format('COMMENT ON CONSTRAINT %I ON "pb3gir75kkooyea"."push_integration_config" IS %L','p3_push_integration_config_01a340c66c84','P3|01a340c66c84d0062c7897cb9728463fdf53679a2f892f3fc249d824c25d55a5|'||pg_get_constraintdef(found_oid));
 ELSE
 actual:=obj_description(found_oid,'pg_constraint');
 IF actual IS DISTINCT FROM 'P3|01a340c66c84d0062c7897cb9728463fdf53679a2f892f3fc249d824c25d55a5|'||pg_get_constraintdef(found_oid) THEN RAISE EXCEPTION 'Constraint drift: p3_push_integration_config_01a340c66c84'; END IF;
 END IF; END $p3$;
DO $p3$ DECLARE found_oid oid; actual text; BEGIN
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."push_integration_config"'::regclass AND c.conname='p3_push_integration_config_f8d97e1e817f';
 IF found_oid IS NULL THEN
 ALTER TABLE "pb3gir75kkooyea"."push_integration_config" ADD CONSTRAINT "p3_push_integration_config_f8d97e1e817f" FOREIGN KEY ("application_id") REFERENCES "pb3gir75kkooyea"."application" ("id") ON DELETE RESTRICT;
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."push_integration_config"'::regclass AND c.conname='p3_push_integration_config_f8d97e1e817f';
 EXECUTE format('COMMENT ON CONSTRAINT %I ON "pb3gir75kkooyea"."push_integration_config" IS %L','p3_push_integration_config_f8d97e1e817f','P3|f8d97e1e817fb5f5bfd5a87c467852b0d7d02f1185fd4fc1df1562ed920fce71|'||pg_get_constraintdef(found_oid));
 ELSE
 actual:=obj_description(found_oid,'pg_constraint');
 IF actual IS DISTINCT FROM 'P3|f8d97e1e817fb5f5bfd5a87c467852b0d7d02f1185fd4fc1df1562ed920fce71|'||pg_get_constraintdef(found_oid) THEN RAISE EXCEPTION 'Constraint drift: p3_push_integration_config_f8d97e1e817f'; END IF;
 END IF; END $p3$;
DO $p3$ DECLARE found_oid oid; actual text; BEGIN
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."push_integration_config"'::regclass AND c.conname='p3_push_integration_config_554dbdb7dd2c';
 IF found_oid IS NULL THEN
 ALTER TABLE "pb3gir75kkooyea"."push_integration_config" ADD CONSTRAINT "p3_push_integration_config_554dbdb7dd2c" CHECK ("kind" IN ('TODO','MESSAGE'));
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."push_integration_config"'::regclass AND c.conname='p3_push_integration_config_554dbdb7dd2c';
 EXECUTE format('COMMENT ON CONSTRAINT %I ON "pb3gir75kkooyea"."push_integration_config" IS %L','p3_push_integration_config_554dbdb7dd2c','P3|554dbdb7dd2c383086750f01f1f1a9a415b93ad6994f996fcb167e12c6b0c581|'||pg_get_constraintdef(found_oid));
 ELSE
 actual:=obj_description(found_oid,'pg_constraint');
 IF actual IS DISTINCT FROM 'P3|554dbdb7dd2c383086750f01f1f1a9a415b93ad6994f996fcb167e12c6b0c581|'||pg_get_constraintdef(found_oid) THEN RAISE EXCEPTION 'Constraint drift: p3_push_integration_config_554dbdb7dd2c'; END IF;
 END IF; END $p3$;
DO $p3$ DECLARE found_oid oid; actual text; BEGIN
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."push_integration_config"'::regclass AND c.conname='p3_push_integration_config_106561401841';
 IF found_oid IS NULL THEN
 ALTER TABLE "pb3gir75kkooyea"."push_integration_config" ADD CONSTRAINT "p3_push_integration_config_106561401841" CHECK ("mode" IN ('PUSH'));
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."push_integration_config"'::regclass AND c.conname='p3_push_integration_config_106561401841';
 EXECUTE format('COMMENT ON CONSTRAINT %I ON "pb3gir75kkooyea"."push_integration_config" IS %L','p3_push_integration_config_106561401841','P3|106561401841007aafd790386ab5a8a4add53feef61730eb30f57327a1822e00|'||pg_get_constraintdef(found_oid));
 ELSE
 actual:=obj_description(found_oid,'pg_constraint');
 IF actual IS DISTINCT FROM 'P3|106561401841007aafd790386ab5a8a4add53feef61730eb30f57327a1822e00|'||pg_get_constraintdef(found_oid) THEN RAISE EXCEPTION 'Constraint drift: p3_push_integration_config_106561401841'; END IF;
 END IF; END $p3$;
DO $p3$ DECLARE found_oid oid; actual text; BEGIN
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."push_integration_config"'::regclass AND c.conname='p3_push_integration_config_6fcd83f64002';
 IF found_oid IS NULL THEN
 ALTER TABLE "pb3gir75kkooyea"."push_integration_config" ADD CONSTRAINT "p3_push_integration_config_6fcd83f64002" CHECK ("field_mapping" IS NULL OR jsonb_typeof("field_mapping"::jsonb) IS NOT NULL);
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."push_integration_config"'::regclass AND c.conname='p3_push_integration_config_6fcd83f64002';
 EXECUTE format('COMMENT ON CONSTRAINT %I ON "pb3gir75kkooyea"."push_integration_config" IS %L','p3_push_integration_config_6fcd83f64002','P3|6fcd83f6400260a8c4a1932fc8fec4e9384a7e8086e5ef025ba3ec5bc114fe23|'||pg_get_constraintdef(found_oid));
 ELSE
 actual:=obj_description(found_oid,'pg_constraint');
 IF actual IS DISTINCT FROM 'P3|6fcd83f6400260a8c4a1932fc8fec4e9384a7e8086e5ef025ba3ec5bc114fe23|'||pg_get_constraintdef(found_oid) THEN RAISE EXCEPTION 'Constraint drift: p3_push_integration_config_6fcd83f64002'; END IF;
 END IF; END $p3$;
DO $p3$ DECLARE found_oid oid; actual text; BEGIN
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."push_integration_config"'::regclass AND c.conname='p3_push_integration_config_5279b4a53053';
 IF found_oid IS NULL THEN
 ALTER TABLE "pb3gir75kkooyea"."push_integration_config" ADD CONSTRAINT "p3_push_integration_config_5279b4a53053" CHECK ("value_mapping" IS NULL OR jsonb_typeof("value_mapping"::jsonb) IS NOT NULL);
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."push_integration_config"'::regclass AND c.conname='p3_push_integration_config_5279b4a53053';
 EXECUTE format('COMMENT ON CONSTRAINT %I ON "pb3gir75kkooyea"."push_integration_config" IS %L','p3_push_integration_config_5279b4a53053','P3|5279b4a530539d833f4b9e2fc918c89a95aa1060a2f74d227678ea0e391c49b8|'||pg_get_constraintdef(found_oid));
 ELSE
 actual:=obj_description(found_oid,'pg_constraint');
 IF actual IS DISTINCT FROM 'P3|5279b4a530539d833f4b9e2fc918c89a95aa1060a2f74d227678ea0e391c49b8|'||pg_get_constraintdef(found_oid) THEN RAISE EXCEPTION 'Constraint drift: p3_push_integration_config_5279b4a53053'; END IF;
 END IF; END $p3$;
DO $p3$ DECLARE found_oid oid; actual text; BEGIN
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."push_integration_config"'::regclass AND c.conname='p3_push_integration_config_707055140713';
 IF found_oid IS NULL THEN
 ALTER TABLE "pb3gir75kkooyea"."push_integration_config" ADD CONSTRAINT "p3_push_integration_config_707055140713" CHECK ("target_key_kind" IN ('UNIFIED_USER_ID','EXTERNAL_USER_ID'));
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."push_integration_config"'::regclass AND c.conname='p3_push_integration_config_707055140713';
 EXECUTE format('COMMENT ON CONSTRAINT %I ON "pb3gir75kkooyea"."push_integration_config" IS %L','p3_push_integration_config_707055140713','P3|707055140713ef685852941da79cb0dbf486092fff766a18784d531b972aae4c|'||pg_get_constraintdef(found_oid));
 ELSE
 actual:=obj_description(found_oid,'pg_constraint');
 IF actual IS DISTINCT FROM 'P3|707055140713ef685852941da79cb0dbf486092fff766a18784d531b972aae4c|'||pg_get_constraintdef(found_oid) THEN RAISE EXCEPTION 'Constraint drift: p3_push_integration_config_707055140713'; END IF;
 END IF; END $p3$;
DO $p3$ DECLARE found_oid oid; actual text; BEGIN
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."push_integration_config"'::regclass AND c.conname='p3_push_integration_config_dbd995363960';
 IF found_oid IS NULL THEN
 ALTER TABLE "pb3gir75kkooyea"."push_integration_config" ADD CONSTRAINT "p3_push_integration_config_dbd995363960" CHECK ("status" IN ('NORMAL','ABNORMAL','UNCONFIGURED','DISABLED'));
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."push_integration_config"'::regclass AND c.conname='p3_push_integration_config_dbd995363960';
 EXECUTE format('COMMENT ON CONSTRAINT %I ON "pb3gir75kkooyea"."push_integration_config" IS %L','p3_push_integration_config_dbd995363960','P3|dbd995363960ec54950ce2de5263efde55cd944a377b3004c75f629fe1beafbd|'||pg_get_constraintdef(found_oid));
 ELSE
 actual:=obj_description(found_oid,'pg_constraint');
 IF actual IS DISTINCT FROM 'P3|dbd995363960ec54950ce2de5263efde55cd944a377b3004c75f629fe1beafbd|'||pg_get_constraintdef(found_oid) THEN RAISE EXCEPTION 'Constraint drift: p3_push_integration_config_dbd995363960'; END IF;
 END IF; END $p3$;
DO $p3$ DECLARE found_oid oid; actual text; BEGIN
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."ingest_receipt"'::regclass AND c.conname='p3_ingest_receipt_f0f958e6a879';
 IF found_oid IS NULL THEN
 ALTER TABLE "pb3gir75kkooyea"."ingest_receipt" ADD CONSTRAINT "p3_ingest_receipt_f0f958e6a879" CHECK ("version" >= 1);
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."ingest_receipt"'::regclass AND c.conname='p3_ingest_receipt_f0f958e6a879';
 EXECUTE format('COMMENT ON CONSTRAINT %I ON "pb3gir75kkooyea"."ingest_receipt" IS %L','p3_ingest_receipt_f0f958e6a879','P3|f0f958e6a8791542a63ea644d2d3ec767d3e0072da52d2466f3a2a462d7d24b1|'||pg_get_constraintdef(found_oid));
 ELSE
 actual:=obj_description(found_oid,'pg_constraint');
 IF actual IS DISTINCT FROM 'P3|f0f958e6a8791542a63ea644d2d3ec767d3e0072da52d2466f3a2a462d7d24b1|'||pg_get_constraintdef(found_oid) THEN RAISE EXCEPTION 'Constraint drift: p3_ingest_receipt_f0f958e6a879'; END IF;
 END IF; END $p3$;
DO $p3$ DECLARE found_oid oid; actual text; BEGIN
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."ingest_receipt"'::regclass AND c.conname='p3_ingest_receipt_1e4b7e88ec4e';
 IF found_oid IS NULL THEN
 ALTER TABLE "pb3gir75kkooyea"."ingest_receipt" ADD CONSTRAINT "p3_ingest_receipt_1e4b7e88ec4e" FOREIGN KEY ("application_id") REFERENCES "pb3gir75kkooyea"."application" ("id") ON DELETE RESTRICT;
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."ingest_receipt"'::regclass AND c.conname='p3_ingest_receipt_1e4b7e88ec4e';
 EXECUTE format('COMMENT ON CONSTRAINT %I ON "pb3gir75kkooyea"."ingest_receipt" IS %L','p3_ingest_receipt_1e4b7e88ec4e','P3|1e4b7e88ec4e5180c2fa83ba076850e23130357f338cb9d0450c726e2ab56910|'||pg_get_constraintdef(found_oid));
 ELSE
 actual:=obj_description(found_oid,'pg_constraint');
 IF actual IS DISTINCT FROM 'P3|1e4b7e88ec4e5180c2fa83ba076850e23130357f338cb9d0450c726e2ab56910|'||pg_get_constraintdef(found_oid) THEN RAISE EXCEPTION 'Constraint drift: p3_ingest_receipt_1e4b7e88ec4e'; END IF;
 END IF; END $p3$;
DO $p3$ DECLARE found_oid oid; actual text; BEGIN
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."ingest_receipt"'::regclass AND c.conname='p3_ingest_receipt_3b16904262fc';
 IF found_oid IS NULL THEN
 ALTER TABLE "pb3gir75kkooyea"."ingest_receipt" ADD CONSTRAINT "p3_ingest_receipt_3b16904262fc" CHECK ("kind" IN ('TODO','MESSAGE','SMS'));
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."ingest_receipt"'::regclass AND c.conname='p3_ingest_receipt_3b16904262fc';
 EXECUTE format('COMMENT ON CONSTRAINT %I ON "pb3gir75kkooyea"."ingest_receipt" IS %L','p3_ingest_receipt_3b16904262fc','P3|3b16904262fcba4c8ef9af8e4e378e7eb4751935cbb11ef0641cd536d8a5b49b|'||pg_get_constraintdef(found_oid));
 ELSE
 actual:=obj_description(found_oid,'pg_constraint');
 IF actual IS DISTINCT FROM 'P3|3b16904262fcba4c8ef9af8e4e378e7eb4751935cbb11ef0641cd536d8a5b49b|'||pg_get_constraintdef(found_oid) THEN RAISE EXCEPTION 'Constraint drift: p3_ingest_receipt_3b16904262fc'; END IF;
 END IF; END $p3$;
DO $p3$ DECLARE found_oid oid; actual text; BEGIN
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."ingest_receipt"'::regclass AND c.conname='p3_ingest_receipt_73955776ef8a';
 IF found_oid IS NULL THEN
 ALTER TABLE "pb3gir75kkooyea"."ingest_receipt" ADD CONSTRAINT "p3_ingest_receipt_73955776ef8a" CHECK ("status" IN ('RECEIVED','APPLIED','REJECTED'));
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."ingest_receipt"'::regclass AND c.conname='p3_ingest_receipt_73955776ef8a';
 EXECUTE format('COMMENT ON CONSTRAINT %I ON "pb3gir75kkooyea"."ingest_receipt" IS %L','p3_ingest_receipt_73955776ef8a','P3|73955776ef8ab1b9efc56e15d4923c709dac6b3226115335c6462ba7daaf62a2|'||pg_get_constraintdef(found_oid));
 ELSE
 actual:=obj_description(found_oid,'pg_constraint');
 IF actual IS DISTINCT FROM 'P3|73955776ef8ab1b9efc56e15d4923c709dac6b3226115335c6462ba7daaf62a2|'||pg_get_constraintdef(found_oid) THEN RAISE EXCEPTION 'Constraint drift: p3_ingest_receipt_73955776ef8a'; END IF;
 END IF; END $p3$;
DO $p3$ DECLARE found_oid oid; actual text; BEGIN
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."ingest_receipt"'::regclass AND c.conname='p3_ingest_receipt_cb17784af306';
 IF found_oid IS NULL THEN
 ALTER TABLE "pb3gir75kkooyea"."ingest_receipt" ADD CONSTRAINT "p3_ingest_receipt_cb17784af306" CHECK ("result" IS NULL OR jsonb_typeof("result"::jsonb) IS NOT NULL);
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."ingest_receipt"'::regclass AND c.conname='p3_ingest_receipt_cb17784af306';
 EXECUTE format('COMMENT ON CONSTRAINT %I ON "pb3gir75kkooyea"."ingest_receipt" IS %L','p3_ingest_receipt_cb17784af306','P3|cb17784af3069f76585dee8c3ff1b04a7a61f1ca20a99af0e1262e2e6a3fb9a6|'||pg_get_constraintdef(found_oid));
 ELSE
 actual:=obj_description(found_oid,'pg_constraint');
 IF actual IS DISTINCT FROM 'P3|cb17784af3069f76585dee8c3ff1b04a7a61f1ca20a99af0e1262e2e6a3fb9a6|'||pg_get_constraintdef(found_oid) THEN RAISE EXCEPTION 'Constraint drift: p3_ingest_receipt_cb17784af306'; END IF;
 END IF; END $p3$;
DO $p3$ DECLARE found_oid oid; actual text; BEGIN
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."todo_item"'::regclass AND c.conname='p3_todo_item_42b2122efa6a';
 IF found_oid IS NULL THEN
 ALTER TABLE "pb3gir75kkooyea"."todo_item" ADD CONSTRAINT "p3_todo_item_42b2122efa6a" CHECK ("version" >= 1);
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."todo_item"'::regclass AND c.conname='p3_todo_item_42b2122efa6a';
 EXECUTE format('COMMENT ON CONSTRAINT %I ON "pb3gir75kkooyea"."todo_item" IS %L','p3_todo_item_42b2122efa6a','P3|42b2122efa6ac622c46ee465bee1f02111fa730cef99b9f1dc28e66f94f3d415|'||pg_get_constraintdef(found_oid));
 ELSE
 actual:=obj_description(found_oid,'pg_constraint');
 IF actual IS DISTINCT FROM 'P3|42b2122efa6ac622c46ee465bee1f02111fa730cef99b9f1dc28e66f94f3d415|'||pg_get_constraintdef(found_oid) THEN RAISE EXCEPTION 'Constraint drift: p3_todo_item_42b2122efa6a'; END IF;
 END IF; END $p3$;
DO $p3$ DECLARE found_oid oid; actual text; BEGIN
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."todo_item"'::regclass AND c.conname='p3_todo_item_2f904279c84d';
 IF found_oid IS NULL THEN
 ALTER TABLE "pb3gir75kkooyea"."todo_item" ADD CONSTRAINT "p3_todo_item_2f904279c84d" FOREIGN KEY ("application_id") REFERENCES "pb3gir75kkooyea"."application" ("id") ON DELETE RESTRICT;
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."todo_item"'::regclass AND c.conname='p3_todo_item_2f904279c84d';
 EXECUTE format('COMMENT ON CONSTRAINT %I ON "pb3gir75kkooyea"."todo_item" IS %L','p3_todo_item_2f904279c84d','P3|2f904279c84d4a9e59c4d65e6a2e527fbf05cc46f9ebe102ab2cfc80cf572183|'||pg_get_constraintdef(found_oid));
 ELSE
 actual:=obj_description(found_oid,'pg_constraint');
 IF actual IS DISTINCT FROM 'P3|2f904279c84d4a9e59c4d65e6a2e527fbf05cc46f9ebe102ab2cfc80cf572183|'||pg_get_constraintdef(found_oid) THEN RAISE EXCEPTION 'Constraint drift: p3_todo_item_2f904279c84d'; END IF;
 END IF; END $p3$;
DO $p3$ DECLARE found_oid oid; actual text; BEGIN
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."todo_item"'::regclass AND c.conname='p3_todo_item_0f11dacd5396';
 IF found_oid IS NULL THEN
 ALTER TABLE "pb3gir75kkooyea"."todo_item" ADD CONSTRAINT "p3_todo_item_0f11dacd5396" FOREIGN KEY ("target_user_id") REFERENCES "pb3gir75kkooyea"."unified_user" ("id") ON DELETE RESTRICT;
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."todo_item"'::regclass AND c.conname='p3_todo_item_0f11dacd5396';
 EXECUTE format('COMMENT ON CONSTRAINT %I ON "pb3gir75kkooyea"."todo_item" IS %L','p3_todo_item_0f11dacd5396','P3|0f11dacd5396fc0b63511b8de79788d21c4c5f384adabffa0451ff2efcc08fa9|'||pg_get_constraintdef(found_oid));
 ELSE
 actual:=obj_description(found_oid,'pg_constraint');
 IF actual IS DISTINCT FROM 'P3|0f11dacd5396fc0b63511b8de79788d21c4c5f384adabffa0451ff2efcc08fa9|'||pg_get_constraintdef(found_oid) THEN RAISE EXCEPTION 'Constraint drift: p3_todo_item_0f11dacd5396'; END IF;
 END IF; END $p3$;
DO $p3$ DECLARE found_oid oid; actual text; BEGIN
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."todo_item"'::regclass AND c.conname='p3_todo_item_e0177c24c192';
 IF found_oid IS NULL THEN
 ALTER TABLE "pb3gir75kkooyea"."todo_item" ADD CONSTRAINT "p3_todo_item_e0177c24c192" CHECK ("status" IN ('PENDING','COMPLETED','WITHDRAWN','EXPIRED'));
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."todo_item"'::regclass AND c.conname='p3_todo_item_e0177c24c192';
 EXECUTE format('COMMENT ON CONSTRAINT %I ON "pb3gir75kkooyea"."todo_item" IS %L','p3_todo_item_e0177c24c192','P3|e0177c24c192d936fe48a90f61c4752d123ad109de97155cedba712c4d10de33|'||pg_get_constraintdef(found_oid));
 ELSE
 actual:=obj_description(found_oid,'pg_constraint');
 IF actual IS DISTINCT FROM 'P3|e0177c24c192d936fe48a90f61c4752d123ad109de97155cedba712c4d10de33|'||pg_get_constraintdef(found_oid) THEN RAISE EXCEPTION 'Constraint drift: p3_todo_item_e0177c24c192'; END IF;
 END IF; END $p3$;
DO $p3$ DECLARE found_oid oid; actual text; BEGIN
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."todo_item"'::regclass AND c.conname='p3_todo_item_9aec774b552c';
 IF found_oid IS NULL THEN
 ALTER TABLE "pb3gir75kkooyea"."todo_item" ADD CONSTRAINT "p3_todo_item_9aec774b552c" CHECK ("priority" IN ('HIGH','MEDIUM','LOW'));
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."todo_item"'::regclass AND c.conname='p3_todo_item_9aec774b552c';
 EXECUTE format('COMMENT ON CONSTRAINT %I ON "pb3gir75kkooyea"."todo_item" IS %L','p3_todo_item_9aec774b552c','P3|9aec774b552ca0d3b25da6542719fa1a370734c4c6370b00886e10408502cdde|'||pg_get_constraintdef(found_oid));
 ELSE
 actual:=obj_description(found_oid,'pg_constraint');
 IF actual IS DISTINCT FROM 'P3|9aec774b552ca0d3b25da6542719fa1a370734c4c6370b00886e10408502cdde|'||pg_get_constraintdef(found_oid) THEN RAISE EXCEPTION 'Constraint drift: p3_todo_item_9aec774b552c'; END IF;
 END IF; END $p3$;
DO $p3$ DECLARE found_oid oid; actual text; BEGIN
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."todo_item"'::regclass AND c.conname='p3_todo_item_9c8d70bfa76f';
 IF found_oid IS NULL THEN
 ALTER TABLE "pb3gir75kkooyea"."todo_item" ADD CONSTRAINT "p3_todo_item_9c8d70bfa76f" CHECK ("source_revision" >= 1);
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."todo_item"'::regclass AND c.conname='p3_todo_item_9c8d70bfa76f';
 EXECUTE format('COMMENT ON CONSTRAINT %I ON "pb3gir75kkooyea"."todo_item" IS %L','p3_todo_item_9c8d70bfa76f','P3|9c8d70bfa76fcb67e5728687a9b5c621e0948e3f69304dc829cb25dc14bb074a|'||pg_get_constraintdef(found_oid));
 ELSE
 actual:=obj_description(found_oid,'pg_constraint');
 IF actual IS DISTINCT FROM 'P3|9c8d70bfa76fcb67e5728687a9b5c621e0948e3f69304dc829cb25dc14bb074a|'||pg_get_constraintdef(found_oid) THEN RAISE EXCEPTION 'Constraint drift: p3_todo_item_9c8d70bfa76f'; END IF;
 END IF; END $p3$;
DO $p3$ DECLARE found_oid oid; actual text; BEGIN
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."todo_item"'::regclass AND c.conname='p3_todo_item_17704daf8cc1';
 IF found_oid IS NULL THEN
 ALTER TABLE "pb3gir75kkooyea"."todo_item" ADD CONSTRAINT "p3_todo_item_17704daf8cc1" CHECK ((status = 'PENDING' AND terminal_at IS NULL) OR (status <> 'PENDING' AND terminal_at IS NOT NULL));
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."todo_item"'::regclass AND c.conname='p3_todo_item_17704daf8cc1';
 EXECUTE format('COMMENT ON CONSTRAINT %I ON "pb3gir75kkooyea"."todo_item" IS %L','p3_todo_item_17704daf8cc1','P3|17704daf8cc1a74cda97ab93f23f6c11104832ed6912d51f67c0904c4407fdde|'||pg_get_constraintdef(found_oid));
 ELSE
 actual:=obj_description(found_oid,'pg_constraint');
 IF actual IS DISTINCT FROM 'P3|17704daf8cc1a74cda97ab93f23f6c11104832ed6912d51f67c0904c4407fdde|'||pg_get_constraintdef(found_oid) THEN RAISE EXCEPTION 'Constraint drift: p3_todo_item_17704daf8cc1'; END IF;
 END IF; END $p3$;
DO $p3$ DECLARE found_oid oid; BEGIN
 found_oid:=to_regclass('pb3gir75kkooyea.p3i_todo_item_cb41b63f8bb2');
 IF found_oid IS NULL THEN
 CREATE INDEX "p3i_todo_item_cb41b63f8bb2" ON "pb3gir75kkooyea"."todo_item" ("target_user_id","status","source_created_at");
 found_oid:=to_regclass('pb3gir75kkooyea.p3i_todo_item_cb41b63f8bb2');
 EXECUTE format('COMMENT ON INDEX "pb3gir75kkooyea".%I IS %L','p3i_todo_item_cb41b63f8bb2','P3|cb41b63f8bb21b0850e737d85e75af0e831ce1faa4b2a625c4cabe310c41edb8|'||pg_get_indexdef(found_oid));
 ELSIF obj_description(found_oid,'pg_class') IS DISTINCT FROM 'P3|cb41b63f8bb21b0850e737d85e75af0e831ce1faa4b2a625c4cabe310c41edb8|'||pg_get_indexdef(found_oid) THEN RAISE EXCEPTION 'Index drift: p3i_todo_item_cb41b63f8bb2';
 END IF; END $p3$;
DO $p3$ DECLARE found_oid oid; actual text; BEGIN
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."message"'::regclass AND c.conname='p3_message_881bb19a57d9';
 IF found_oid IS NULL THEN
 ALTER TABLE "pb3gir75kkooyea"."message" ADD CONSTRAINT "p3_message_881bb19a57d9" CHECK ("version" >= 1);
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."message"'::regclass AND c.conname='p3_message_881bb19a57d9';
 EXECUTE format('COMMENT ON CONSTRAINT %I ON "pb3gir75kkooyea"."message" IS %L','p3_message_881bb19a57d9','P3|881bb19a57d97d31e6332c14c4e8183efa2d488f9cc43e067949bd9f03f81996|'||pg_get_constraintdef(found_oid));
 ELSE
 actual:=obj_description(found_oid,'pg_constraint');
 IF actual IS DISTINCT FROM 'P3|881bb19a57d97d31e6332c14c4e8183efa2d488f9cc43e067949bd9f03f81996|'||pg_get_constraintdef(found_oid) THEN RAISE EXCEPTION 'Constraint drift: p3_message_881bb19a57d9'; END IF;
 END IF; END $p3$;
DO $p3$ DECLARE found_oid oid; actual text; BEGIN
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."message"'::regclass AND c.conname='p3_message_b7fba7ec9e24';
 IF found_oid IS NULL THEN
 ALTER TABLE "pb3gir75kkooyea"."message" ADD CONSTRAINT "p3_message_b7fba7ec9e24" FOREIGN KEY ("application_id") REFERENCES "pb3gir75kkooyea"."application" ("id") ON DELETE RESTRICT;
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."message"'::regclass AND c.conname='p3_message_b7fba7ec9e24';
 EXECUTE format('COMMENT ON CONSTRAINT %I ON "pb3gir75kkooyea"."message" IS %L','p3_message_b7fba7ec9e24','P3|b7fba7ec9e244715f5b28451930ab4b7d76a9361c7c03e02e22d9d7032c1359d|'||pg_get_constraintdef(found_oid));
 ELSE
 actual:=obj_description(found_oid,'pg_constraint');
 IF actual IS DISTINCT FROM 'P3|b7fba7ec9e244715f5b28451930ab4b7d76a9361c7c03e02e22d9d7032c1359d|'||pg_get_constraintdef(found_oid) THEN RAISE EXCEPTION 'Constraint drift: p3_message_b7fba7ec9e24'; END IF;
 END IF; END $p3$;
DO $p3$ DECLARE found_oid oid; actual text; BEGIN
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."message"'::regclass AND c.conname='p3_message_04377c1af0cb';
 IF found_oid IS NULL THEN
 ALTER TABLE "pb3gir75kkooyea"."message" ADD CONSTRAINT "p3_message_04377c1af0cb" CHECK ("source_kind" IN ('PORTAL','APPLICATION'));
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."message"'::regclass AND c.conname='p3_message_04377c1af0cb';
 EXECUTE format('COMMENT ON CONSTRAINT %I ON "pb3gir75kkooyea"."message" IS %L','p3_message_04377c1af0cb','P3|04377c1af0cb724b29511497a144fc7fb90519ba06672f4319ed53d0a2ef414a|'||pg_get_constraintdef(found_oid));
 ELSE
 actual:=obj_description(found_oid,'pg_constraint');
 IF actual IS DISTINCT FROM 'P3|04377c1af0cb724b29511497a144fc7fb90519ba06672f4319ed53d0a2ef414a|'||pg_get_constraintdef(found_oid) THEN RAISE EXCEPTION 'Constraint drift: p3_message_04377c1af0cb'; END IF;
 END IF; END $p3$;
DO $p3$ DECLARE found_oid oid; actual text; BEGIN
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."message"'::regclass AND c.conname='p3_message_11f2cd81e668';
 IF found_oid IS NULL THEN
 ALTER TABLE "pb3gir75kkooyea"."message" ADD CONSTRAINT "p3_message_11f2cd81e668" CHECK ("message_type" IN ('BUSINESS','SYSTEM','ACCOUNT','SECURITY','TODO_REMINDER','OTHER'));
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."message"'::regclass AND c.conname='p3_message_11f2cd81e668';
 EXECUTE format('COMMENT ON CONSTRAINT %I ON "pb3gir75kkooyea"."message" IS %L','p3_message_11f2cd81e668','P3|11f2cd81e6685a9ac3e89906b57eedba5062f7dccc1097c0b4aef8eb007e6658|'||pg_get_constraintdef(found_oid));
 ELSE
 actual:=obj_description(found_oid,'pg_constraint');
 IF actual IS DISTINCT FROM 'P3|11f2cd81e6685a9ac3e89906b57eedba5062f7dccc1097c0b4aef8eb007e6658|'||pg_get_constraintdef(found_oid) THEN RAISE EXCEPTION 'Constraint drift: p3_message_11f2cd81e668'; END IF;
 END IF; END $p3$;
DO $p3$ DECLARE found_oid oid; actual text; BEGIN
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."message"'::regclass AND c.conname='p3_message_3b635aad4e93';
 IF found_oid IS NULL THEN
 ALTER TABLE "pb3gir75kkooyea"."message" ADD CONSTRAINT "p3_message_3b635aad4e93" CHECK ((source_kind = 'PORTAL' AND application_id IS NULL AND source_key = 'PORTAL') OR (source_kind = 'APPLICATION' AND application_id IS NOT NULL AND source_key = application_id));
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."message"'::regclass AND c.conname='p3_message_3b635aad4e93';
 EXECUTE format('COMMENT ON CONSTRAINT %I ON "pb3gir75kkooyea"."message" IS %L','p3_message_3b635aad4e93','P3|3b635aad4e932da97d397a9bd93670370228d547fdfe35cf5258ec7c2991c3a8|'||pg_get_constraintdef(found_oid));
 ELSE
 actual:=obj_description(found_oid,'pg_constraint');
 IF actual IS DISTINCT FROM 'P3|3b635aad4e932da97d397a9bd93670370228d547fdfe35cf5258ec7c2991c3a8|'||pg_get_constraintdef(found_oid) THEN RAISE EXCEPTION 'Constraint drift: p3_message_3b635aad4e93'; END IF;
 END IF; END $p3$;
DO $p3$ DECLARE found_oid oid; actual text; BEGIN
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."message_recipient"'::regclass AND c.conname='p3_message_recipient_0824eec79d95';
 IF found_oid IS NULL THEN
 ALTER TABLE "pb3gir75kkooyea"."message_recipient" ADD CONSTRAINT "p3_message_recipient_0824eec79d95" CHECK ("version" >= 1);
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."message_recipient"'::regclass AND c.conname='p3_message_recipient_0824eec79d95';
 EXECUTE format('COMMENT ON CONSTRAINT %I ON "pb3gir75kkooyea"."message_recipient" IS %L','p3_message_recipient_0824eec79d95','P3|0824eec79d95c2da63589f99874d8204e870f6fd61261631b59e031573a6a511|'||pg_get_constraintdef(found_oid));
 ELSE
 actual:=obj_description(found_oid,'pg_constraint');
 IF actual IS DISTINCT FROM 'P3|0824eec79d95c2da63589f99874d8204e870f6fd61261631b59e031573a6a511|'||pg_get_constraintdef(found_oid) THEN RAISE EXCEPTION 'Constraint drift: p3_message_recipient_0824eec79d95'; END IF;
 END IF; END $p3$;
DO $p3$ DECLARE found_oid oid; actual text; BEGIN
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."message_recipient"'::regclass AND c.conname='p3_message_recipient_d1f48d95068a';
 IF found_oid IS NULL THEN
 ALTER TABLE "pb3gir75kkooyea"."message_recipient" ADD CONSTRAINT "p3_message_recipient_d1f48d95068a" FOREIGN KEY ("message_id") REFERENCES "pb3gir75kkooyea"."message" ("id") ON DELETE RESTRICT;
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."message_recipient"'::regclass AND c.conname='p3_message_recipient_d1f48d95068a';
 EXECUTE format('COMMENT ON CONSTRAINT %I ON "pb3gir75kkooyea"."message_recipient" IS %L','p3_message_recipient_d1f48d95068a','P3|d1f48d95068a9fe29787f96bcb5efbc8fe005e9f9f2465d12afb76bb54fae6ef|'||pg_get_constraintdef(found_oid));
 ELSE
 actual:=obj_description(found_oid,'pg_constraint');
 IF actual IS DISTINCT FROM 'P3|d1f48d95068a9fe29787f96bcb5efbc8fe005e9f9f2465d12afb76bb54fae6ef|'||pg_get_constraintdef(found_oid) THEN RAISE EXCEPTION 'Constraint drift: p3_message_recipient_d1f48d95068a'; END IF;
 END IF; END $p3$;
DO $p3$ DECLARE found_oid oid; actual text; BEGIN
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."message_recipient"'::regclass AND c.conname='p3_message_recipient_c8c032554f6a';
 IF found_oid IS NULL THEN
 ALTER TABLE "pb3gir75kkooyea"."message_recipient" ADD CONSTRAINT "p3_message_recipient_c8c032554f6a" FOREIGN KEY ("user_id") REFERENCES "pb3gir75kkooyea"."unified_user" ("id") ON DELETE RESTRICT;
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."message_recipient"'::regclass AND c.conname='p3_message_recipient_c8c032554f6a';
 EXECUTE format('COMMENT ON CONSTRAINT %I ON "pb3gir75kkooyea"."message_recipient" IS %L','p3_message_recipient_c8c032554f6a','P3|c8c032554f6afb46927aabe0b26b1663a5163ca52611eac5932dbfea5ce6f927|'||pg_get_constraintdef(found_oid));
 ELSE
 actual:=obj_description(found_oid,'pg_constraint');
 IF actual IS DISTINCT FROM 'P3|c8c032554f6afb46927aabe0b26b1663a5163ca52611eac5932dbfea5ce6f927|'||pg_get_constraintdef(found_oid) THEN RAISE EXCEPTION 'Constraint drift: p3_message_recipient_c8c032554f6a'; END IF;
 END IF; END $p3$;
DO $p3$ DECLARE found_oid oid; actual text; BEGIN
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."message_recipient"'::regclass AND c.conname='p3_message_recipient_f36610ccd560';
 IF found_oid IS NULL THEN
 ALTER TABLE "pb3gir75kkooyea"."message_recipient" ADD CONSTRAINT "p3_message_recipient_f36610ccd560" CHECK ("read_status" IN ('UNREAD','READ'));
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."message_recipient"'::regclass AND c.conname='p3_message_recipient_f36610ccd560';
 EXECUTE format('COMMENT ON CONSTRAINT %I ON "pb3gir75kkooyea"."message_recipient" IS %L','p3_message_recipient_f36610ccd560','P3|f36610ccd560dddfbb2ca38133c480a23a21873b0de4451bfedea93ee7f36bba|'||pg_get_constraintdef(found_oid));
 ELSE
 actual:=obj_description(found_oid,'pg_constraint');
 IF actual IS DISTINCT FROM 'P3|f36610ccd560dddfbb2ca38133c480a23a21873b0de4451bfedea93ee7f36bba|'||pg_get_constraintdef(found_oid) THEN RAISE EXCEPTION 'Constraint drift: p3_message_recipient_f36610ccd560'; END IF;
 END IF; END $p3$;
DO $p3$ DECLARE found_oid oid; actual text; BEGIN
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."message_recipient"'::regclass AND c.conname='p3_message_recipient_ecdd56777ebe';
 IF found_oid IS NULL THEN
 ALTER TABLE "pb3gir75kkooyea"."message_recipient" ADD CONSTRAINT "p3_message_recipient_ecdd56777ebe" CHECK ((read_status = 'UNREAD' AND read_at IS NULL) OR (read_status = 'READ' AND read_at IS NOT NULL));
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."message_recipient"'::regclass AND c.conname='p3_message_recipient_ecdd56777ebe';
 EXECUTE format('COMMENT ON CONSTRAINT %I ON "pb3gir75kkooyea"."message_recipient" IS %L','p3_message_recipient_ecdd56777ebe','P3|ecdd56777ebe739026157d463fc7da91474929eed54b7a94e55954fd13322778|'||pg_get_constraintdef(found_oid));
 ELSE
 actual:=obj_description(found_oid,'pg_constraint');
 IF actual IS DISTINCT FROM 'P3|ecdd56777ebe739026157d463fc7da91474929eed54b7a94e55954fd13322778|'||pg_get_constraintdef(found_oid) THEN RAISE EXCEPTION 'Constraint drift: p3_message_recipient_ecdd56777ebe'; END IF;
 END IF; END $p3$;
DO $p3$ DECLARE found_oid oid; BEGIN
 found_oid:=to_regclass('pb3gir75kkooyea.p3i_message_recipient_4c7efcc5c800');
 IF found_oid IS NULL THEN
 CREATE INDEX "p3i_message_recipient_4c7efcc5c800" ON "pb3gir75kkooyea"."message_recipient" ("user_id","read_status");
 found_oid:=to_regclass('pb3gir75kkooyea.p3i_message_recipient_4c7efcc5c800');
 EXECUTE format('COMMENT ON INDEX "pb3gir75kkooyea".%I IS %L','p3i_message_recipient_4c7efcc5c800','P3|4c7efcc5c80093b3597ea8b8e57e5ec757d57539abf65d12751f4cac9b705cf0|'||pg_get_indexdef(found_oid));
 ELSIF obj_description(found_oid,'pg_class') IS DISTINCT FROM 'P3|4c7efcc5c80093b3597ea8b8e57e5ec757d57539abf65d12751f4cac9b705cf0|'||pg_get_indexdef(found_oid) THEN RAISE EXCEPTION 'Index drift: p3i_message_recipient_4c7efcc5c800';
 END IF; END $p3$;
DO $p3$ DECLARE found_oid oid; actual text; BEGIN
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."announcement"'::regclass AND c.conname='p3_announcement_96d5cd6fd37a';
 IF found_oid IS NULL THEN
 ALTER TABLE "pb3gir75kkooyea"."announcement" ADD CONSTRAINT "p3_announcement_96d5cd6fd37a" CHECK ("version" >= 1);
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."announcement"'::regclass AND c.conname='p3_announcement_96d5cd6fd37a';
 EXECUTE format('COMMENT ON CONSTRAINT %I ON "pb3gir75kkooyea"."announcement" IS %L','p3_announcement_96d5cd6fd37a','P3|96d5cd6fd37a65123060b0f30cbfda68046602a4e4960b638d65f1cd8c083024|'||pg_get_constraintdef(found_oid));
 ELSE
 actual:=obj_description(found_oid,'pg_constraint');
 IF actual IS DISTINCT FROM 'P3|96d5cd6fd37a65123060b0f30cbfda68046602a4e4960b638d65f1cd8c083024|'||pg_get_constraintdef(found_oid) THEN RAISE EXCEPTION 'Constraint drift: p3_announcement_96d5cd6fd37a'; END IF;
 END IF; END $p3$;
DO $p3$ DECLARE found_oid oid; actual text; BEGIN
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."announcement"'::regclass AND c.conname='p3_announcement_c017f9d8f3ae';
 IF found_oid IS NULL THEN
 ALTER TABLE "pb3gir75kkooyea"."announcement" ADD CONSTRAINT "p3_announcement_c017f9d8f3ae" CHECK ("scope" IN ('ALL','CITIZEN','GOV','ORG'));
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."announcement"'::regclass AND c.conname='p3_announcement_c017f9d8f3ae';
 EXECUTE format('COMMENT ON CONSTRAINT %I ON "pb3gir75kkooyea"."announcement" IS %L','p3_announcement_c017f9d8f3ae','P3|c017f9d8f3ae94fef9f665f5a1ab06e42396458f0e4b76c933db8a09f19aa966|'||pg_get_constraintdef(found_oid));
 ELSE
 actual:=obj_description(found_oid,'pg_constraint');
 IF actual IS DISTINCT FROM 'P3|c017f9d8f3ae94fef9f665f5a1ab06e42396458f0e4b76c933db8a09f19aa966|'||pg_get_constraintdef(found_oid) THEN RAISE EXCEPTION 'Constraint drift: p3_announcement_c017f9d8f3ae'; END IF;
 END IF; END $p3$;
DO $p3$ DECLARE found_oid oid; actual text; BEGIN
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."announcement"'::regclass AND c.conname='p3_announcement_db123e2570fc';
 IF found_oid IS NULL THEN
 ALTER TABLE "pb3gir75kkooyea"."announcement" ADD CONSTRAINT "p3_announcement_db123e2570fc" CHECK ("status" IN ('DRAFT','PUBLISHED','WITHDRAWN','EXPIRED'));
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."announcement"'::regclass AND c.conname='p3_announcement_db123e2570fc';
 EXECUTE format('COMMENT ON CONSTRAINT %I ON "pb3gir75kkooyea"."announcement" IS %L','p3_announcement_db123e2570fc','P3|db123e2570fc49006f5144f2ec798f3c7d087c5c41354d618ab6ba9f4278ea14|'||pg_get_constraintdef(found_oid));
 ELSE
 actual:=obj_description(found_oid,'pg_constraint');
 IF actual IS DISTINCT FROM 'P3|db123e2570fc49006f5144f2ec798f3c7d087c5c41354d618ab6ba9f4278ea14|'||pg_get_constraintdef(found_oid) THEN RAISE EXCEPTION 'Constraint drift: p3_announcement_db123e2570fc'; END IF;
 END IF; END $p3$;
DO $p3$ DECLARE found_oid oid; actual text; BEGIN
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."announcement"'::regclass AND c.conname='p3_announcement_45ede45af2c6';
 IF found_oid IS NULL THEN
 ALTER TABLE "pb3gir75kkooyea"."announcement" ADD CONSTRAINT "p3_announcement_45ede45af2c6" FOREIGN KEY ("publisher_id") REFERENCES "pb3gir75kkooyea"."unified_user" ("id") ON DELETE RESTRICT;
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."announcement"'::regclass AND c.conname='p3_announcement_45ede45af2c6';
 EXECUTE format('COMMENT ON CONSTRAINT %I ON "pb3gir75kkooyea"."announcement" IS %L','p3_announcement_45ede45af2c6','P3|45ede45af2c61f0e37b65b6cbf540e9364882954228bc21a66ff8e24d6ab4bdb|'||pg_get_constraintdef(found_oid));
 ELSE
 actual:=obj_description(found_oid,'pg_constraint');
 IF actual IS DISTINCT FROM 'P3|45ede45af2c61f0e37b65b6cbf540e9364882954228bc21a66ff8e24d6ab4bdb|'||pg_get_constraintdef(found_oid) THEN RAISE EXCEPTION 'Constraint drift: p3_announcement_45ede45af2c6'; END IF;
 END IF; END $p3$;
DO $p3$ DECLARE found_oid oid; actual text; BEGIN
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."announcement"'::regclass AND c.conname='p3_announcement_033c1c2718d0';
 IF found_oid IS NULL THEN
 ALTER TABLE "pb3gir75kkooyea"."announcement" ADD CONSTRAINT "p3_announcement_033c1c2718d0" CHECK (effective_end IS NULL OR effective_start IS NULL OR effective_end > effective_start);
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."announcement"'::regclass AND c.conname='p3_announcement_033c1c2718d0';
 EXECUTE format('COMMENT ON CONSTRAINT %I ON "pb3gir75kkooyea"."announcement" IS %L','p3_announcement_033c1c2718d0','P3|033c1c2718d0ac2b209af698ea6140b3bb9b468dbaaf67b02e92da2891dfbc7a|'||pg_get_constraintdef(found_oid));
 ELSE
 actual:=obj_description(found_oid,'pg_constraint');
 IF actual IS DISTINCT FROM 'P3|033c1c2718d0ac2b209af698ea6140b3bb9b468dbaaf67b02e92da2891dfbc7a|'||pg_get_constraintdef(found_oid) THEN RAISE EXCEPTION 'Constraint drift: p3_announcement_033c1c2718d0'; END IF;
 END IF; END $p3$;
DO $p3$ DECLARE found_oid oid; actual text; BEGIN
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."announcement"'::regclass AND c.conname='p3_announcement_6d735cfb827e';
 IF found_oid IS NULL THEN
 ALTER TABLE "pb3gir75kkooyea"."announcement" ADD CONSTRAINT "p3_announcement_6d735cfb827e" CHECK (status <> 'PUBLISHED' OR (publisher_id IS NOT NULL AND published_at IS NOT NULL));
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."announcement"'::regclass AND c.conname='p3_announcement_6d735cfb827e';
 EXECUTE format('COMMENT ON CONSTRAINT %I ON "pb3gir75kkooyea"."announcement" IS %L','p3_announcement_6d735cfb827e','P3|6d735cfb827ea37d90edb130aa8dcb57d010f2848fc74f5a124d6bd7aabb189d|'||pg_get_constraintdef(found_oid));
 ELSE
 actual:=obj_description(found_oid,'pg_constraint');
 IF actual IS DISTINCT FROM 'P3|6d735cfb827ea37d90edb130aa8dcb57d010f2848fc74f5a124d6bd7aabb189d|'||pg_get_constraintdef(found_oid) THEN RAISE EXCEPTION 'Constraint drift: p3_announcement_6d735cfb827e'; END IF;
 END IF; END $p3$;
DO $p3$ DECLARE found_oid oid; actual text; BEGIN
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."announcement_org_scope"'::regclass AND c.conname='p3_announcement_org_scope_f6873d76e7b8';
 IF found_oid IS NULL THEN
 ALTER TABLE "pb3gir75kkooyea"."announcement_org_scope" ADD CONSTRAINT "p3_announcement_org_scope_f6873d76e7b8" CHECK ("version" >= 1);
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."announcement_org_scope"'::regclass AND c.conname='p3_announcement_org_scope_f6873d76e7b8';
 EXECUTE format('COMMENT ON CONSTRAINT %I ON "pb3gir75kkooyea"."announcement_org_scope" IS %L','p3_announcement_org_scope_f6873d76e7b8','P3|f6873d76e7b82991183f6cec9177f3f0663a0e9e733dbf4103d388fed6552fa4|'||pg_get_constraintdef(found_oid));
 ELSE
 actual:=obj_description(found_oid,'pg_constraint');
 IF actual IS DISTINCT FROM 'P3|f6873d76e7b82991183f6cec9177f3f0663a0e9e733dbf4103d388fed6552fa4|'||pg_get_constraintdef(found_oid) THEN RAISE EXCEPTION 'Constraint drift: p3_announcement_org_scope_f6873d76e7b8'; END IF;
 END IF; END $p3$;
DO $p3$ DECLARE found_oid oid; actual text; BEGIN
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."announcement_org_scope"'::regclass AND c.conname='p3_announcement_org_scope_3374fcb769fc';
 IF found_oid IS NULL THEN
 ALTER TABLE "pb3gir75kkooyea"."announcement_org_scope" ADD CONSTRAINT "p3_announcement_org_scope_3374fcb769fc" FOREIGN KEY ("announcement_id") REFERENCES "pb3gir75kkooyea"."announcement" ("id") ON DELETE RESTRICT;
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."announcement_org_scope"'::regclass AND c.conname='p3_announcement_org_scope_3374fcb769fc';
 EXECUTE format('COMMENT ON CONSTRAINT %I ON "pb3gir75kkooyea"."announcement_org_scope" IS %L','p3_announcement_org_scope_3374fcb769fc','P3|3374fcb769fcbb75ae24780cbd6d8cda4a4fd53a027db5592134a4c5565c1813|'||pg_get_constraintdef(found_oid));
 ELSE
 actual:=obj_description(found_oid,'pg_constraint');
 IF actual IS DISTINCT FROM 'P3|3374fcb769fcbb75ae24780cbd6d8cda4a4fd53a027db5592134a4c5565c1813|'||pg_get_constraintdef(found_oid) THEN RAISE EXCEPTION 'Constraint drift: p3_announcement_org_scope_3374fcb769fc'; END IF;
 END IF; END $p3$;
DO $p3$ DECLARE found_oid oid; actual text; BEGIN
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."announcement_attachment"'::regclass AND c.conname='p3_announcement_attachment_b6332a8e883b';
 IF found_oid IS NULL THEN
 ALTER TABLE "pb3gir75kkooyea"."announcement_attachment" ADD CONSTRAINT "p3_announcement_attachment_b6332a8e883b" CHECK ("version" >= 1);
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."announcement_attachment"'::regclass AND c.conname='p3_announcement_attachment_b6332a8e883b';
 EXECUTE format('COMMENT ON CONSTRAINT %I ON "pb3gir75kkooyea"."announcement_attachment" IS %L','p3_announcement_attachment_b6332a8e883b','P3|b6332a8e883ba45176c7efcfeee6428beafa829e9f657ca7ca9e5b784c2f96ef|'||pg_get_constraintdef(found_oid));
 ELSE
 actual:=obj_description(found_oid,'pg_constraint');
 IF actual IS DISTINCT FROM 'P3|b6332a8e883ba45176c7efcfeee6428beafa829e9f657ca7ca9e5b784c2f96ef|'||pg_get_constraintdef(found_oid) THEN RAISE EXCEPTION 'Constraint drift: p3_announcement_attachment_b6332a8e883b'; END IF;
 END IF; END $p3$;
DO $p3$ DECLARE found_oid oid; actual text; BEGIN
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."announcement_attachment"'::regclass AND c.conname='p3_announcement_attachment_f7419e9cc11f';
 IF found_oid IS NULL THEN
 ALTER TABLE "pb3gir75kkooyea"."announcement_attachment" ADD CONSTRAINT "p3_announcement_attachment_f7419e9cc11f" FOREIGN KEY ("announcement_id") REFERENCES "pb3gir75kkooyea"."announcement" ("id") ON DELETE RESTRICT;
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."announcement_attachment"'::regclass AND c.conname='p3_announcement_attachment_f7419e9cc11f';
 EXECUTE format('COMMENT ON CONSTRAINT %I ON "pb3gir75kkooyea"."announcement_attachment" IS %L','p3_announcement_attachment_f7419e9cc11f','P3|f7419e9cc11ff2bddf2116219e9f6cfcb0157c3270670a5caa24178033027c88|'||pg_get_constraintdef(found_oid));
 ELSE
 actual:=obj_description(found_oid,'pg_constraint');
 IF actual IS DISTINCT FROM 'P3|f7419e9cc11ff2bddf2116219e9f6cfcb0157c3270670a5caa24178033027c88|'||pg_get_constraintdef(found_oid) THEN RAISE EXCEPTION 'Constraint drift: p3_announcement_attachment_f7419e9cc11f'; END IF;
 END IF; END $p3$;
DO $p3$ DECLARE found_oid oid; actual text; BEGIN
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."announcement_attachment"'::regclass AND c.conname='p3_announcement_attachment_7dac1f299fa6';
 IF found_oid IS NULL THEN
 ALTER TABLE "pb3gir75kkooyea"."announcement_attachment" ADD CONSTRAINT "p3_announcement_attachment_7dac1f299fa6" CHECK ("size_bytes" >= 0);
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."announcement_attachment"'::regclass AND c.conname='p3_announcement_attachment_7dac1f299fa6';
 EXECUTE format('COMMENT ON CONSTRAINT %I ON "pb3gir75kkooyea"."announcement_attachment" IS %L','p3_announcement_attachment_7dac1f299fa6','P3|7dac1f299fa60821170ec6287423cda49d3402cab74fb778738c65eddca6203f|'||pg_get_constraintdef(found_oid));
 ELSE
 actual:=obj_description(found_oid,'pg_constraint');
 IF actual IS DISTINCT FROM 'P3|7dac1f299fa60821170ec6287423cda49d3402cab74fb778738c65eddca6203f|'||pg_get_constraintdef(found_oid) THEN RAISE EXCEPTION 'Constraint drift: p3_announcement_attachment_7dac1f299fa6'; END IF;
 END IF; END $p3$;
DO $p3$ DECLARE found_oid oid; actual text; BEGIN
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."announcement_attachment"'::regclass AND c.conname='p3_announcement_attachment_8d1434e8dc58';
 IF found_oid IS NULL THEN
 ALTER TABLE "pb3gir75kkooyea"."announcement_attachment" ADD CONSTRAINT "p3_announcement_attachment_8d1434e8dc58" CHECK ("attachment" IS NULL OR jsonb_typeof("attachment"::jsonb) IS NOT NULL);
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."announcement_attachment"'::regclass AND c.conname='p3_announcement_attachment_8d1434e8dc58';
 EXECUTE format('COMMENT ON CONSTRAINT %I ON "pb3gir75kkooyea"."announcement_attachment" IS %L','p3_announcement_attachment_8d1434e8dc58','P3|8d1434e8dc5807acc4cb9537f14b695d18dca74274f026d873a2c4798d2fe18e|'||pg_get_constraintdef(found_oid));
 ELSE
 actual:=obj_description(found_oid,'pg_constraint');
 IF actual IS DISTINCT FROM 'P3|8d1434e8dc5807acc4cb9537f14b695d18dca74274f026d873a2c4798d2fe18e|'||pg_get_constraintdef(found_oid) THEN RAISE EXCEPTION 'Constraint drift: p3_announcement_attachment_8d1434e8dc58'; END IF;
 END IF; END $p3$;
DO $p3$ DECLARE found_oid oid; actual text; BEGIN
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."announcement_attachment"'::regclass AND c.conname='p3_announcement_attachment_d63316230bc4';
 IF found_oid IS NULL THEN
 ALTER TABLE "pb3gir75kkooyea"."announcement_attachment" ADD CONSTRAINT "p3_announcement_attachment_d63316230bc4" FOREIGN KEY ("uploaded_by") REFERENCES "pb3gir75kkooyea"."unified_user" ("id") ON DELETE RESTRICT;
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."announcement_attachment"'::regclass AND c.conname='p3_announcement_attachment_d63316230bc4';
 EXECUTE format('COMMENT ON CONSTRAINT %I ON "pb3gir75kkooyea"."announcement_attachment" IS %L','p3_announcement_attachment_d63316230bc4','P3|d63316230bc4c84582693e3a7b5cbfeb9bac88521c2e383b8706aaad11325109|'||pg_get_constraintdef(found_oid));
 ELSE
 actual:=obj_description(found_oid,'pg_constraint');
 IF actual IS DISTINCT FROM 'P3|d63316230bc4c84582693e3a7b5cbfeb9bac88521c2e383b8706aaad11325109|'||pg_get_constraintdef(found_oid) THEN RAISE EXCEPTION 'Constraint drift: p3_announcement_attachment_d63316230bc4'; END IF;
 END IF; END $p3$;
DO $p3$ DECLARE found_oid oid; actual text; BEGIN
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."sms_channel"'::regclass AND c.conname='p3_sms_channel_912f298682c7';
 IF found_oid IS NULL THEN
 ALTER TABLE "pb3gir75kkooyea"."sms_channel" ADD CONSTRAINT "p3_sms_channel_912f298682c7" CHECK ("version" >= 1);
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."sms_channel"'::regclass AND c.conname='p3_sms_channel_912f298682c7';
 EXECUTE format('COMMENT ON CONSTRAINT %I ON "pb3gir75kkooyea"."sms_channel" IS %L','p3_sms_channel_912f298682c7','P3|912f298682c75abaee869e3345224756419dc6c769218533325185fc7cffd4fd|'||pg_get_constraintdef(found_oid));
 ELSE
 actual:=obj_description(found_oid,'pg_constraint');
 IF actual IS DISTINCT FROM 'P3|912f298682c75abaee869e3345224756419dc6c769218533325185fc7cffd4fd|'||pg_get_constraintdef(found_oid) THEN RAISE EXCEPTION 'Constraint drift: p3_sms_channel_912f298682c7'; END IF;
 END IF; END $p3$;
DO $p3$ DECLARE found_oid oid; actual text; BEGIN
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."sms_channel"'::regclass AND c.conname='p3_sms_channel_e2f7985595a0';
 IF found_oid IS NULL THEN
 ALTER TABLE "pb3gir75kkooyea"."sms_channel" ADD CONSTRAINT "p3_sms_channel_e2f7985595a0" CHECK ("status" IN ('ENABLED','DISABLED'));
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."sms_channel"'::regclass AND c.conname='p3_sms_channel_e2f7985595a0';
 EXECUTE format('COMMENT ON CONSTRAINT %I ON "pb3gir75kkooyea"."sms_channel" IS %L','p3_sms_channel_e2f7985595a0','P3|e2f7985595a0ef5373b5e1a0cb5ddfd13238c77e9c64bffbb9a5daefd4c4a468|'||pg_get_constraintdef(found_oid));
 ELSE
 actual:=obj_description(found_oid,'pg_constraint');
 IF actual IS DISTINCT FROM 'P3|e2f7985595a0ef5373b5e1a0cb5ddfd13238c77e9c64bffbb9a5daefd4c4a468|'||pg_get_constraintdef(found_oid) THEN RAISE EXCEPTION 'Constraint drift: p3_sms_channel_e2f7985595a0'; END IF;
 END IF; END $p3$;
DO $p3$ DECLARE found_oid oid; actual text; BEGIN
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."sms_channel"'::regclass AND c.conname='p3_sms_channel_9e15f0eb37af';
 IF found_oid IS NULL THEN
 ALTER TABLE "pb3gir75kkooyea"."sms_channel" ADD CONSTRAINT "p3_sms_channel_9e15f0eb37af" CHECK ("runtime_status" IN ('NORMAL','ABNORMAL','UNCONFIGURED','DISABLED'));
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."sms_channel"'::regclass AND c.conname='p3_sms_channel_9e15f0eb37af';
 EXECUTE format('COMMENT ON CONSTRAINT %I ON "pb3gir75kkooyea"."sms_channel" IS %L','p3_sms_channel_9e15f0eb37af','P3|9e15f0eb37af80b5b914bae7333c611c7f09830e2aa7f4e9701676a71f503304|'||pg_get_constraintdef(found_oid));
 ELSE
 actual:=obj_description(found_oid,'pg_constraint');
 IF actual IS DISTINCT FROM 'P3|9e15f0eb37af80b5b914bae7333c611c7f09830e2aa7f4e9701676a71f503304|'||pg_get_constraintdef(found_oid) THEN RAISE EXCEPTION 'Constraint drift: p3_sms_channel_9e15f0eb37af'; END IF;
 END IF; END $p3$;
DO $p3$ DECLARE found_oid oid; actual text; BEGIN
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."sms_template"'::regclass AND c.conname='p3_sms_template_a336c511ae25';
 IF found_oid IS NULL THEN
 ALTER TABLE "pb3gir75kkooyea"."sms_template" ADD CONSTRAINT "p3_sms_template_a336c511ae25" CHECK ("version" >= 1);
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."sms_template"'::regclass AND c.conname='p3_sms_template_a336c511ae25';
 EXECUTE format('COMMENT ON CONSTRAINT %I ON "pb3gir75kkooyea"."sms_template" IS %L','p3_sms_template_a336c511ae25','P3|a336c511ae25ec078c30e23a09384806de1e6c3964ddc4156df65ca666cad748|'||pg_get_constraintdef(found_oid));
 ELSE
 actual:=obj_description(found_oid,'pg_constraint');
 IF actual IS DISTINCT FROM 'P3|a336c511ae25ec078c30e23a09384806de1e6c3964ddc4156df65ca666cad748|'||pg_get_constraintdef(found_oid) THEN RAISE EXCEPTION 'Constraint drift: p3_sms_template_a336c511ae25'; END IF;
 END IF; END $p3$;
DO $p3$ DECLARE found_oid oid; actual text; BEGIN
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."sms_template"'::regclass AND c.conname='p3_sms_template_0d0b15823b51';
 IF found_oid IS NULL THEN
 ALTER TABLE "pb3gir75kkooyea"."sms_template" ADD CONSTRAINT "p3_sms_template_0d0b15823b51" CHECK ("variables" IS NULL OR jsonb_typeof("variables"::jsonb) IS NOT NULL);
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."sms_template"'::regclass AND c.conname='p3_sms_template_0d0b15823b51';
 EXECUTE format('COMMENT ON CONSTRAINT %I ON "pb3gir75kkooyea"."sms_template" IS %L','p3_sms_template_0d0b15823b51','P3|0d0b15823b510f5e07b1998a7dfadbac5c59522d0b6d835dd9414fbd4847f97a|'||pg_get_constraintdef(found_oid));
 ELSE
 actual:=obj_description(found_oid,'pg_constraint');
 IF actual IS DISTINCT FROM 'P3|0d0b15823b510f5e07b1998a7dfadbac5c59522d0b6d835dd9414fbd4847f97a|'||pg_get_constraintdef(found_oid) THEN RAISE EXCEPTION 'Constraint drift: p3_sms_template_0d0b15823b51'; END IF;
 END IF; END $p3$;
DO $p3$ DECLARE found_oid oid; actual text; BEGIN
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."sms_template"'::regclass AND c.conname='p3_sms_template_7ecb536cd51c';
 IF found_oid IS NULL THEN
 ALTER TABLE "pb3gir75kkooyea"."sms_template" ADD CONSTRAINT "p3_sms_template_7ecb536cd51c" CHECK ("status" IN ('ENABLED','DISABLED'));
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."sms_template"'::regclass AND c.conname='p3_sms_template_7ecb536cd51c';
 EXECUTE format('COMMENT ON CONSTRAINT %I ON "pb3gir75kkooyea"."sms_template" IS %L','p3_sms_template_7ecb536cd51c','P3|7ecb536cd51c02d6f32ed07b9f995bda6f27981d31e9b9fd63aabce37a257bb4|'||pg_get_constraintdef(found_oid));
 ELSE
 actual:=obj_description(found_oid,'pg_constraint');
 IF actual IS DISTINCT FROM 'P3|7ecb536cd51c02d6f32ed07b9f995bda6f27981d31e9b9fd63aabce37a257bb4|'||pg_get_constraintdef(found_oid) THEN RAISE EXCEPTION 'Constraint drift: p3_sms_template_7ecb536cd51c'; END IF;
 END IF; END $p3$;
DO $p3$ DECLARE found_oid oid; actual text; BEGIN
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."sms_application"'::regclass AND c.conname='p3_sms_application_e27454d3e97e';
 IF found_oid IS NULL THEN
 ALTER TABLE "pb3gir75kkooyea"."sms_application" ADD CONSTRAINT "p3_sms_application_e27454d3e97e" CHECK ("version" >= 1);
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."sms_application"'::regclass AND c.conname='p3_sms_application_e27454d3e97e';
 EXECUTE format('COMMENT ON CONSTRAINT %I ON "pb3gir75kkooyea"."sms_application" IS %L','p3_sms_application_e27454d3e97e','P3|e27454d3e97e9a31a0956a469fd4dfa6dba3e0a2a7f4ab7877a98779cdcb22d5|'||pg_get_constraintdef(found_oid));
 ELSE
 actual:=obj_description(found_oid,'pg_constraint');
 IF actual IS DISTINCT FROM 'P3|e27454d3e97e9a31a0956a469fd4dfa6dba3e0a2a7f4ab7877a98779cdcb22d5|'||pg_get_constraintdef(found_oid) THEN RAISE EXCEPTION 'Constraint drift: p3_sms_application_e27454d3e97e'; END IF;
 END IF; END $p3$;
DO $p3$ DECLARE found_oid oid; actual text; BEGIN
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."sms_application"'::regclass AND c.conname='p3_sms_application_0b07c14c86d6';
 IF found_oid IS NULL THEN
 ALTER TABLE "pb3gir75kkooyea"."sms_application" ADD CONSTRAINT "p3_sms_application_0b07c14c86d6" FOREIGN KEY ("application_id") REFERENCES "pb3gir75kkooyea"."application" ("id") ON DELETE RESTRICT;
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."sms_application"'::regclass AND c.conname='p3_sms_application_0b07c14c86d6';
 EXECUTE format('COMMENT ON CONSTRAINT %I ON "pb3gir75kkooyea"."sms_application" IS %L','p3_sms_application_0b07c14c86d6','P3|0b07c14c86d672ecd0884df1f0a14e6f50f8ee04469ccf01647d7827002b722f|'||pg_get_constraintdef(found_oid));
 ELSE
 actual:=obj_description(found_oid,'pg_constraint');
 IF actual IS DISTINCT FROM 'P3|0b07c14c86d672ecd0884df1f0a14e6f50f8ee04469ccf01647d7827002b722f|'||pg_get_constraintdef(found_oid) THEN RAISE EXCEPTION 'Constraint drift: p3_sms_application_0b07c14c86d6'; END IF;
 END IF; END $p3$;
DO $p3$ DECLARE found_oid oid; actual text; BEGIN
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."sms_application"'::regclass AND c.conname='p3_sms_application_8185c4a9b499';
 IF found_oid IS NULL THEN
 ALTER TABLE "pb3gir75kkooyea"."sms_application" ADD CONSTRAINT "p3_sms_application_8185c4a9b499" CHECK ("status" IN ('ENABLED','DISABLED'));
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."sms_application"'::regclass AND c.conname='p3_sms_application_8185c4a9b499';
 EXECUTE format('COMMENT ON CONSTRAINT %I ON "pb3gir75kkooyea"."sms_application" IS %L','p3_sms_application_8185c4a9b499','P3|8185c4a9b499dcbebe494165d526cf0a4abfa11e23865709c3ac9d056fa31f26|'||pg_get_constraintdef(found_oid));
 ELSE
 actual:=obj_description(found_oid,'pg_constraint');
 IF actual IS DISTINCT FROM 'P3|8185c4a9b499dcbebe494165d526cf0a4abfa11e23865709c3ac9d056fa31f26|'||pg_get_constraintdef(found_oid) THEN RAISE EXCEPTION 'Constraint drift: p3_sms_application_8185c4a9b499'; END IF;
 END IF; END $p3$;
DO $p3$ DECLARE found_oid oid; actual text; BEGIN
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."sms_application_template"'::regclass AND c.conname='p3_sms_application_template_43ad448abd70';
 IF found_oid IS NULL THEN
 ALTER TABLE "pb3gir75kkooyea"."sms_application_template" ADD CONSTRAINT "p3_sms_application_template_43ad448abd70" CHECK ("version" >= 1);
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."sms_application_template"'::regclass AND c.conname='p3_sms_application_template_43ad448abd70';
 EXECUTE format('COMMENT ON CONSTRAINT %I ON "pb3gir75kkooyea"."sms_application_template" IS %L','p3_sms_application_template_43ad448abd70','P3|43ad448abd704386e41806e5365ae2fb6ebbb44c8ee56256dbaaa6c8e9b43b64|'||pg_get_constraintdef(found_oid));
 ELSE
 actual:=obj_description(found_oid,'pg_constraint');
 IF actual IS DISTINCT FROM 'P3|43ad448abd704386e41806e5365ae2fb6ebbb44c8ee56256dbaaa6c8e9b43b64|'||pg_get_constraintdef(found_oid) THEN RAISE EXCEPTION 'Constraint drift: p3_sms_application_template_43ad448abd70'; END IF;
 END IF; END $p3$;
DO $p3$ DECLARE found_oid oid; actual text; BEGIN
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."sms_application_template"'::regclass AND c.conname='p3_sms_application_template_7ee65161eb07';
 IF found_oid IS NULL THEN
 ALTER TABLE "pb3gir75kkooyea"."sms_application_template" ADD CONSTRAINT "p3_sms_application_template_7ee65161eb07" FOREIGN KEY ("sms_application_id") REFERENCES "pb3gir75kkooyea"."sms_application" ("id") ON DELETE RESTRICT;
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."sms_application_template"'::regclass AND c.conname='p3_sms_application_template_7ee65161eb07';
 EXECUTE format('COMMENT ON CONSTRAINT %I ON "pb3gir75kkooyea"."sms_application_template" IS %L','p3_sms_application_template_7ee65161eb07','P3|7ee65161eb07607d15970ee345577c06aa56537d6b6463a6a3ca2b2883bc3540|'||pg_get_constraintdef(found_oid));
 ELSE
 actual:=obj_description(found_oid,'pg_constraint');
 IF actual IS DISTINCT FROM 'P3|7ee65161eb07607d15970ee345577c06aa56537d6b6463a6a3ca2b2883bc3540|'||pg_get_constraintdef(found_oid) THEN RAISE EXCEPTION 'Constraint drift: p3_sms_application_template_7ee65161eb07'; END IF;
 END IF; END $p3$;
DO $p3$ DECLARE found_oid oid; actual text; BEGIN
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."sms_application_template"'::regclass AND c.conname='p3_sms_application_template_c9b65db9da01';
 IF found_oid IS NULL THEN
 ALTER TABLE "pb3gir75kkooyea"."sms_application_template" ADD CONSTRAINT "p3_sms_application_template_c9b65db9da01" FOREIGN KEY ("template_id") REFERENCES "pb3gir75kkooyea"."sms_template" ("id") ON DELETE RESTRICT;
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."sms_application_template"'::regclass AND c.conname='p3_sms_application_template_c9b65db9da01';
 EXECUTE format('COMMENT ON CONSTRAINT %I ON "pb3gir75kkooyea"."sms_application_template" IS %L','p3_sms_application_template_c9b65db9da01','P3|c9b65db9da01201a40d443dcba6cd5a6c908495c02260a627affff912623b41f|'||pg_get_constraintdef(found_oid));
 ELSE
 actual:=obj_description(found_oid,'pg_constraint');
 IF actual IS DISTINCT FROM 'P3|c9b65db9da01201a40d443dcba6cd5a6c908495c02260a627affff912623b41f|'||pg_get_constraintdef(found_oid) THEN RAISE EXCEPTION 'Constraint drift: p3_sms_application_template_c9b65db9da01'; END IF;
 END IF; END $p3$;
DO $p3$ DECLARE found_oid oid; actual text; BEGIN
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."sms_send_record"'::regclass AND c.conname='p3_sms_send_record_fa4f8ee1da7c';
 IF found_oid IS NULL THEN
 ALTER TABLE "pb3gir75kkooyea"."sms_send_record" ADD CONSTRAINT "p3_sms_send_record_fa4f8ee1da7c" CHECK ("version" >= 1);
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."sms_send_record"'::regclass AND c.conname='p3_sms_send_record_fa4f8ee1da7c';
 EXECUTE format('COMMENT ON CONSTRAINT %I ON "pb3gir75kkooyea"."sms_send_record" IS %L','p3_sms_send_record_fa4f8ee1da7c','P3|fa4f8ee1da7c6f5977e222cd0726c8b38e4519bb63a94150d1a68278f34c8272|'||pg_get_constraintdef(found_oid));
 ELSE
 actual:=obj_description(found_oid,'pg_constraint');
 IF actual IS DISTINCT FROM 'P3|fa4f8ee1da7c6f5977e222cd0726c8b38e4519bb63a94150d1a68278f34c8272|'||pg_get_constraintdef(found_oid) THEN RAISE EXCEPTION 'Constraint drift: p3_sms_send_record_fa4f8ee1da7c'; END IF;
 END IF; END $p3$;
DO $p3$ DECLARE found_oid oid; actual text; BEGIN
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."sms_send_record"'::regclass AND c.conname='p3_sms_send_record_f56a0ea99557';
 IF found_oid IS NULL THEN
 ALTER TABLE "pb3gir75kkooyea"."sms_send_record" ADD CONSTRAINT "p3_sms_send_record_f56a0ea99557" FOREIGN KEY ("application_id") REFERENCES "pb3gir75kkooyea"."application" ("id") ON DELETE RESTRICT;
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."sms_send_record"'::regclass AND c.conname='p3_sms_send_record_f56a0ea99557';
 EXECUTE format('COMMENT ON CONSTRAINT %I ON "pb3gir75kkooyea"."sms_send_record" IS %L','p3_sms_send_record_f56a0ea99557','P3|f56a0ea995576ba265b2c8b1de429b34173d87931ea8fac2795fcc612e3e827c|'||pg_get_constraintdef(found_oid));
 ELSE
 actual:=obj_description(found_oid,'pg_constraint');
 IF actual IS DISTINCT FROM 'P3|f56a0ea995576ba265b2c8b1de429b34173d87931ea8fac2795fcc612e3e827c|'||pg_get_constraintdef(found_oid) THEN RAISE EXCEPTION 'Constraint drift: p3_sms_send_record_f56a0ea99557'; END IF;
 END IF; END $p3$;
DO $p3$ DECLARE found_oid oid; actual text; BEGIN
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."sms_send_record"'::regclass AND c.conname='p3_sms_send_record_f6f5f9a1e8be';
 IF found_oid IS NULL THEN
 ALTER TABLE "pb3gir75kkooyea"."sms_send_record" ADD CONSTRAINT "p3_sms_send_record_f6f5f9a1e8be" FOREIGN KEY ("template_id") REFERENCES "pb3gir75kkooyea"."sms_template" ("id") ON DELETE RESTRICT;
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."sms_send_record"'::regclass AND c.conname='p3_sms_send_record_f6f5f9a1e8be';
 EXECUTE format('COMMENT ON CONSTRAINT %I ON "pb3gir75kkooyea"."sms_send_record" IS %L','p3_sms_send_record_f6f5f9a1e8be','P3|f6f5f9a1e8be934f11485dd5fc0623d172784adc67d6b0f826d920fd3401a16d|'||pg_get_constraintdef(found_oid));
 ELSE
 actual:=obj_description(found_oid,'pg_constraint');
 IF actual IS DISTINCT FROM 'P3|f6f5f9a1e8be934f11485dd5fc0623d172784adc67d6b0f826d920fd3401a16d|'||pg_get_constraintdef(found_oid) THEN RAISE EXCEPTION 'Constraint drift: p3_sms_send_record_f6f5f9a1e8be'; END IF;
 END IF; END $p3$;
DO $p3$ DECLARE found_oid oid; actual text; BEGIN
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."sms_send_record"'::regclass AND c.conname='p3_sms_send_record_cc2c1a767f4b';
 IF found_oid IS NULL THEN
 ALTER TABLE "pb3gir75kkooyea"."sms_send_record" ADD CONSTRAINT "p3_sms_send_record_cc2c1a767f4b" FOREIGN KEY ("channel_id") REFERENCES "pb3gir75kkooyea"."sms_channel" ("id") ON DELETE RESTRICT;
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."sms_send_record"'::regclass AND c.conname='p3_sms_send_record_cc2c1a767f4b';
 EXECUTE format('COMMENT ON CONSTRAINT %I ON "pb3gir75kkooyea"."sms_send_record" IS %L','p3_sms_send_record_cc2c1a767f4b','P3|cc2c1a767f4b9c5ea77536382f7778b20f23272150430f203aebc7a14f78aae3|'||pg_get_constraintdef(found_oid));
 ELSE
 actual:=obj_description(found_oid,'pg_constraint');
 IF actual IS DISTINCT FROM 'P3|cc2c1a767f4b9c5ea77536382f7778b20f23272150430f203aebc7a14f78aae3|'||pg_get_constraintdef(found_oid) THEN RAISE EXCEPTION 'Constraint drift: p3_sms_send_record_cc2c1a767f4b'; END IF;
 END IF; END $p3$;
DO $p3$ DECLARE found_oid oid; actual text; BEGIN
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."sms_send_record"'::regclass AND c.conname='p3_sms_send_record_6098449abf5f';
 IF found_oid IS NULL THEN
 ALTER TABLE "pb3gir75kkooyea"."sms_send_record" ADD CONSTRAINT "p3_sms_send_record_6098449abf5f" CHECK ("status" IN ('PENDING','SENDING','SUCCESS','FAILED'));
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."sms_send_record"'::regclass AND c.conname='p3_sms_send_record_6098449abf5f';
 EXECUTE format('COMMENT ON CONSTRAINT %I ON "pb3gir75kkooyea"."sms_send_record" IS %L','p3_sms_send_record_6098449abf5f','P3|6098449abf5fc71af0bd98b9e68e030815d64f004c0bede6abf9a49640f9c8b2|'||pg_get_constraintdef(found_oid));
 ELSE
 actual:=obj_description(found_oid,'pg_constraint');
 IF actual IS DISTINCT FROM 'P3|6098449abf5fc71af0bd98b9e68e030815d64f004c0bede6abf9a49640f9c8b2|'||pg_get_constraintdef(found_oid) THEN RAISE EXCEPTION 'Constraint drift: p3_sms_send_record_6098449abf5f'; END IF;
 END IF; END $p3$;
DO $p3$ DECLARE found_oid oid; actual text; BEGIN
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."sms_send_record"'::regclass AND c.conname='p3_sms_send_record_b5ce0a95d239';
 IF found_oid IS NULL THEN
 ALTER TABLE "pb3gir75kkooyea"."sms_send_record" ADD CONSTRAINT "p3_sms_send_record_b5ce0a95d239" CHECK ("retry_count" >= 0);
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."sms_send_record"'::regclass AND c.conname='p3_sms_send_record_b5ce0a95d239';
 EXECUTE format('COMMENT ON CONSTRAINT %I ON "pb3gir75kkooyea"."sms_send_record" IS %L','p3_sms_send_record_b5ce0a95d239','P3|b5ce0a95d239796816f45544c209a84f2e6e3557a0dd41ff1d7de079e2568547|'||pg_get_constraintdef(found_oid));
 ELSE
 actual:=obj_description(found_oid,'pg_constraint');
 IF actual IS DISTINCT FROM 'P3|b5ce0a95d239796816f45544c209a84f2e6e3557a0dd41ff1d7de079e2568547|'||pg_get_constraintdef(found_oid) THEN RAISE EXCEPTION 'Constraint drift: p3_sms_send_record_b5ce0a95d239'; END IF;
 END IF; END $p3$;
DO $p3$ DECLARE found_oid oid; actual text; BEGIN
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."sms_send_attempt"'::regclass AND c.conname='p3_sms_send_attempt_b5bf19a14472';
 IF found_oid IS NULL THEN
 ALTER TABLE "pb3gir75kkooyea"."sms_send_attempt" ADD CONSTRAINT "p3_sms_send_attempt_b5bf19a14472" CHECK ("version" >= 1);
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."sms_send_attempt"'::regclass AND c.conname='p3_sms_send_attempt_b5bf19a14472';
 EXECUTE format('COMMENT ON CONSTRAINT %I ON "pb3gir75kkooyea"."sms_send_attempt" IS %L','p3_sms_send_attempt_b5bf19a14472','P3|b5bf19a14472908fdc2f983f5fc85c6e2215dc263bde700ce64596f21833dd98|'||pg_get_constraintdef(found_oid));
 ELSE
 actual:=obj_description(found_oid,'pg_constraint');
 IF actual IS DISTINCT FROM 'P3|b5bf19a14472908fdc2f983f5fc85c6e2215dc263bde700ce64596f21833dd98|'||pg_get_constraintdef(found_oid) THEN RAISE EXCEPTION 'Constraint drift: p3_sms_send_attempt_b5bf19a14472'; END IF;
 END IF; END $p3$;
DO $p3$ DECLARE found_oid oid; actual text; BEGIN
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."sms_send_attempt"'::regclass AND c.conname='p3_sms_send_attempt_8e3dd1153a6e';
 IF found_oid IS NULL THEN
 ALTER TABLE "pb3gir75kkooyea"."sms_send_attempt" ADD CONSTRAINT "p3_sms_send_attempt_8e3dd1153a6e" FOREIGN KEY ("send_id") REFERENCES "pb3gir75kkooyea"."sms_send_record" ("id") ON DELETE RESTRICT;
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."sms_send_attempt"'::regclass AND c.conname='p3_sms_send_attempt_8e3dd1153a6e';
 EXECUTE format('COMMENT ON CONSTRAINT %I ON "pb3gir75kkooyea"."sms_send_attempt" IS %L','p3_sms_send_attempt_8e3dd1153a6e','P3|8e3dd1153a6ecb7538c2e29e4ebd19606bb56f6cf1ee60db6981efc0b37b9d43|'||pg_get_constraintdef(found_oid));
 ELSE
 actual:=obj_description(found_oid,'pg_constraint');
 IF actual IS DISTINCT FROM 'P3|8e3dd1153a6ecb7538c2e29e4ebd19606bb56f6cf1ee60db6981efc0b37b9d43|'||pg_get_constraintdef(found_oid) THEN RAISE EXCEPTION 'Constraint drift: p3_sms_send_attempt_8e3dd1153a6e'; END IF;
 END IF; END $p3$;
DO $p3$ DECLARE found_oid oid; actual text; BEGIN
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."sms_send_attempt"'::regclass AND c.conname='p3_sms_send_attempt_84b82df41412';
 IF found_oid IS NULL THEN
 ALTER TABLE "pb3gir75kkooyea"."sms_send_attempt" ADD CONSTRAINT "p3_sms_send_attempt_84b82df41412" CHECK ("attempt_no" >= 1);
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."sms_send_attempt"'::regclass AND c.conname='p3_sms_send_attempt_84b82df41412';
 EXECUTE format('COMMENT ON CONSTRAINT %I ON "pb3gir75kkooyea"."sms_send_attempt" IS %L','p3_sms_send_attempt_84b82df41412','P3|84b82df4141263057587ba80788734bc8afe5834f6f2b4580279678582ab08d9|'||pg_get_constraintdef(found_oid));
 ELSE
 actual:=obj_description(found_oid,'pg_constraint');
 IF actual IS DISTINCT FROM 'P3|84b82df4141263057587ba80788734bc8afe5834f6f2b4580279678582ab08d9|'||pg_get_constraintdef(found_oid) THEN RAISE EXCEPTION 'Constraint drift: p3_sms_send_attempt_84b82df41412'; END IF;
 END IF; END $p3$;
DO $p3$ DECLARE found_oid oid; actual text; BEGIN
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."sms_send_attempt"'::regclass AND c.conname='p3_sms_send_attempt_a9951d0b969e';
 IF found_oid IS NULL THEN
 ALTER TABLE "pb3gir75kkooyea"."sms_send_attempt" ADD CONSTRAINT "p3_sms_send_attempt_a9951d0b969e" CHECK ("status" IN ('PENDING','SENDING','SUCCESS','FAILED'));
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."sms_send_attempt"'::regclass AND c.conname='p3_sms_send_attempt_a9951d0b969e';
 EXECUTE format('COMMENT ON CONSTRAINT %I ON "pb3gir75kkooyea"."sms_send_attempt" IS %L','p3_sms_send_attempt_a9951d0b969e','P3|a9951d0b969e912009eb736553d8e7a2551b3f9c8633d791c2cd8633eb606027|'||pg_get_constraintdef(found_oid));
 ELSE
 actual:=obj_description(found_oid,'pg_constraint');
 IF actual IS DISTINCT FROM 'P3|a9951d0b969e912009eb736553d8e7a2551b3f9c8633d791c2cd8633eb606027|'||pg_get_constraintdef(found_oid) THEN RAISE EXCEPTION 'Constraint drift: p3_sms_send_attempt_a9951d0b969e'; END IF;
 END IF; END $p3$;
DO $p3$ DECLARE found_oid oid; actual text; BEGIN
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."sms_send_attempt"'::regclass AND c.conname='p3_sms_send_attempt_3deb9e252a72';
 IF found_oid IS NULL THEN
 ALTER TABLE "pb3gir75kkooyea"."sms_send_attempt" ADD CONSTRAINT "p3_sms_send_attempt_3deb9e252a72" CHECK ("delivery_certainty" IN ('UNKNOWN','CONFIRMED_SUCCESS','CONFIRMED_FAILURE'));
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."sms_send_attempt"'::regclass AND c.conname='p3_sms_send_attempt_3deb9e252a72';
 EXECUTE format('COMMENT ON CONSTRAINT %I ON "pb3gir75kkooyea"."sms_send_attempt" IS %L','p3_sms_send_attempt_3deb9e252a72','P3|3deb9e252a723f3baf3c8329cebda0aa66326c81d1fc4d5de05c9f57f8bf3966|'||pg_get_constraintdef(found_oid));
 ELSE
 actual:=obj_description(found_oid,'pg_constraint');
 IF actual IS DISTINCT FROM 'P3|3deb9e252a723f3baf3c8329cebda0aa66326c81d1fc4d5de05c9f57f8bf3966|'||pg_get_constraintdef(found_oid) THEN RAISE EXCEPTION 'Constraint drift: p3_sms_send_attempt_3deb9e252a72'; END IF;
 END IF; END $p3$;
DO $p3$ DECLARE found_oid oid; actual text; BEGIN
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."system_config"'::regclass AND c.conname='p3_system_config_ade90e9096ea';
 IF found_oid IS NULL THEN
 ALTER TABLE "pb3gir75kkooyea"."system_config" ADD CONSTRAINT "p3_system_config_ade90e9096ea" CHECK ("version" >= 1);
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."system_config"'::regclass AND c.conname='p3_system_config_ade90e9096ea';
 EXECUTE format('COMMENT ON CONSTRAINT %I ON "pb3gir75kkooyea"."system_config" IS %L','p3_system_config_ade90e9096ea','P3|ade90e9096ea8657466dcd92989facd48310083e79195bae6a592b3f0ddfec5c|'||pg_get_constraintdef(found_oid));
 ELSE
 actual:=obj_description(found_oid,'pg_constraint');
 IF actual IS DISTINCT FROM 'P3|ade90e9096ea8657466dcd92989facd48310083e79195bae6a592b3f0ddfec5c|'||pg_get_constraintdef(found_oid) THEN RAISE EXCEPTION 'Constraint drift: p3_system_config_ade90e9096ea'; END IF;
 END IF; END $p3$;
DO $p3$ DECLARE found_oid oid; actual text; BEGIN
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."system_config"'::regclass AND c.conname='p3_system_config_c29ccc91b551';
 IF found_oid IS NULL THEN
 ALTER TABLE "pb3gir75kkooyea"."system_config" ADD CONSTRAINT "p3_system_config_c29ccc91b551" CHECK ("value" IS NULL OR jsonb_typeof("value"::jsonb) IS NOT NULL);
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."system_config"'::regclass AND c.conname='p3_system_config_c29ccc91b551';
 EXECUTE format('COMMENT ON CONSTRAINT %I ON "pb3gir75kkooyea"."system_config" IS %L','p3_system_config_c29ccc91b551','P3|c29ccc91b5519b22711d50e4a805211f52b6599188ef25ea578b66ce61dbd518|'||pg_get_constraintdef(found_oid));
 ELSE
 actual:=obj_description(found_oid,'pg_constraint');
 IF actual IS DISTINCT FROM 'P3|c29ccc91b5519b22711d50e4a805211f52b6599188ef25ea578b66ce61dbd518|'||pg_get_constraintdef(found_oid) THEN RAISE EXCEPTION 'Constraint drift: p3_system_config_c29ccc91b551'; END IF;
 END IF; END $p3$;
DO $p3$ DECLARE found_oid oid; actual text; BEGIN
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."system_config"'::regclass AND c.conname='p3_system_config_e8b959b2603c';
 IF found_oid IS NULL THEN
 ALTER TABLE "pb3gir75kkooyea"."system_config" ADD CONSTRAINT "p3_system_config_e8b959b2603c" CHECK ("status" IN ('UNCONFIGURED','CONFIGURED'));
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."system_config"'::regclass AND c.conname='p3_system_config_e8b959b2603c';
 EXECUTE format('COMMENT ON CONSTRAINT %I ON "pb3gir75kkooyea"."system_config" IS %L','p3_system_config_e8b959b2603c','P3|e8b959b2603c01f0c8cfd673c6f6900b7503deba3efa1d43f78ca848eb910dc6|'||pg_get_constraintdef(found_oid));
 ELSE
 actual:=obj_description(found_oid,'pg_constraint');
 IF actual IS DISTINCT FROM 'P3|e8b959b2603c01f0c8cfd673c6f6900b7503deba3efa1d43f78ca848eb910dc6|'||pg_get_constraintdef(found_oid) THEN RAISE EXCEPTION 'Constraint drift: p3_system_config_e8b959b2603c'; END IF;
 END IF; END $p3$;
DO $p3$ DECLARE found_oid oid; actual text; BEGIN
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."system_config"'::regclass AND c.conname='p3_system_config_c165b4c2d2e7';
 IF found_oid IS NULL THEN
 ALTER TABLE "pb3gir75kkooyea"."system_config" ADD CONSTRAINT "p3_system_config_c165b4c2d2e7" CHECK ((status = 'UNCONFIGURED' AND value::jsonb IS NULL) OR (status = 'CONFIGURED' AND value::jsonb IS NOT NULL));
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."system_config"'::regclass AND c.conname='p3_system_config_c165b4c2d2e7';
 EXECUTE format('COMMENT ON CONSTRAINT %I ON "pb3gir75kkooyea"."system_config" IS %L','p3_system_config_c165b4c2d2e7','P3|c165b4c2d2e7a3f6f342aec199b84c4c0b5bebf99c6c6d930aa41e7f0bea0566|'||pg_get_constraintdef(found_oid));
 ELSE
 actual:=obj_description(found_oid,'pg_constraint');
 IF actual IS DISTINCT FROM 'P3|c165b4c2d2e7a3f6f342aec199b84c4c0b5bebf99c6c6d930aa41e7f0bea0566|'||pg_get_constraintdef(found_oid) THEN RAISE EXCEPTION 'Constraint drift: p3_system_config_c165b4c2d2e7'; END IF;
 END IF; END $p3$;
DO $p3$ DECLARE found_oid oid; actual text; BEGIN
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."monitor_status"'::regclass AND c.conname='p3_monitor_status_91dbd6b139ca';
 IF found_oid IS NULL THEN
 ALTER TABLE "pb3gir75kkooyea"."monitor_status" ADD CONSTRAINT "p3_monitor_status_91dbd6b139ca" CHECK ("version" >= 1);
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."monitor_status"'::regclass AND c.conname='p3_monitor_status_91dbd6b139ca';
 EXECUTE format('COMMENT ON CONSTRAINT %I ON "pb3gir75kkooyea"."monitor_status" IS %L','p3_monitor_status_91dbd6b139ca','P3|91dbd6b139cab9fd90c274f8dce51922d7394a81f23a7ffa9416038f80711a32|'||pg_get_constraintdef(found_oid));
 ELSE
 actual:=obj_description(found_oid,'pg_constraint');
 IF actual IS DISTINCT FROM 'P3|91dbd6b139cab9fd90c274f8dce51922d7394a81f23a7ffa9416038f80711a32|'||pg_get_constraintdef(found_oid) THEN RAISE EXCEPTION 'Constraint drift: p3_monitor_status_91dbd6b139ca'; END IF;
 END IF; END $p3$;
DO $p3$ DECLARE found_oid oid; actual text; BEGIN
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."monitor_status"'::regclass AND c.conname='p3_monitor_status_6d099d57f99c';
 IF found_oid IS NULL THEN
 ALTER TABLE "pb3gir75kkooyea"."monitor_status" ADD CONSTRAINT "p3_monitor_status_6d099d57f99c" CHECK ("service_type" IN ('IDENTITY','SSO','TODO','MESSAGE','SMS'));
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."monitor_status"'::regclass AND c.conname='p3_monitor_status_6d099d57f99c';
 EXECUTE format('COMMENT ON CONSTRAINT %I ON "pb3gir75kkooyea"."monitor_status" IS %L','p3_monitor_status_6d099d57f99c','P3|6d099d57f99cb26ca28c2fc4ed5ef3e27ce0af3b4606bea8830bb0061bbd90b1|'||pg_get_constraintdef(found_oid));
 ELSE
 actual:=obj_description(found_oid,'pg_constraint');
 IF actual IS DISTINCT FROM 'P3|6d099d57f99cb26ca28c2fc4ed5ef3e27ce0af3b4606bea8830bb0061bbd90b1|'||pg_get_constraintdef(found_oid) THEN RAISE EXCEPTION 'Constraint drift: p3_monitor_status_6d099d57f99c'; END IF;
 END IF; END $p3$;
DO $p3$ DECLARE found_oid oid; actual text; BEGIN
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."monitor_status"'::regclass AND c.conname='p3_monitor_status_3b4e2d6e9015';
 IF found_oid IS NULL THEN
 ALTER TABLE "pb3gir75kkooyea"."monitor_status" ADD CONSTRAINT "p3_monitor_status_3b4e2d6e9015" CHECK ("status" IN ('NORMAL','ABNORMAL','UNCONFIGURED','DISABLED'));
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."monitor_status"'::regclass AND c.conname='p3_monitor_status_3b4e2d6e9015';
 EXECUTE format('COMMENT ON CONSTRAINT %I ON "pb3gir75kkooyea"."monitor_status" IS %L','p3_monitor_status_3b4e2d6e9015','P3|3b4e2d6e901586b2671ac491b1b17fb19170649a28b3494ea43f6128f5bbd133|'||pg_get_constraintdef(found_oid));
 ELSE
 actual:=obj_description(found_oid,'pg_constraint');
 IF actual IS DISTINCT FROM 'P3|3b4e2d6e901586b2671ac491b1b17fb19170649a28b3494ea43f6128f5bbd133|'||pg_get_constraintdef(found_oid) THEN RAISE EXCEPTION 'Constraint drift: p3_monitor_status_3b4e2d6e9015'; END IF;
 END IF; END $p3$;
DO $p3$ DECLARE found_oid oid; actual text; BEGIN
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."monitor_status"'::regclass AND c.conname='p3_monitor_status_4212c36d929b';
 IF found_oid IS NULL THEN
 ALTER TABLE "pb3gir75kkooyea"."monitor_status" ADD CONSTRAINT "p3_monitor_status_4212c36d929b" CHECK ("failure_count" >= 0);
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."monitor_status"'::regclass AND c.conname='p3_monitor_status_4212c36d929b';
 EXECUTE format('COMMENT ON CONSTRAINT %I ON "pb3gir75kkooyea"."monitor_status" IS %L','p3_monitor_status_4212c36d929b','P3|4212c36d929b5369b187e74e6c74a538876af8761a4e4a3d2a89bd037b40e519|'||pg_get_constraintdef(found_oid));
 ELSE
 actual:=obj_description(found_oid,'pg_constraint');
 IF actual IS DISTINCT FROM 'P3|4212c36d929b5369b187e74e6c74a538876af8761a4e4a3d2a89bd037b40e519|'||pg_get_constraintdef(found_oid) THEN RAISE EXCEPTION 'Constraint drift: p3_monitor_status_4212c36d929b'; END IF;
 END IF; END $p3$;
DO $p3$ DECLARE found_oid oid; actual text; BEGIN
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."audit_event"'::regclass AND c.conname='p3_audit_event_179d1ceba52f';
 IF found_oid IS NULL THEN
 ALTER TABLE "pb3gir75kkooyea"."audit_event" ADD CONSTRAINT "p3_audit_event_179d1ceba52f" CHECK ("version" >= 1);
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."audit_event"'::regclass AND c.conname='p3_audit_event_179d1ceba52f';
 EXECUTE format('COMMENT ON CONSTRAINT %I ON "pb3gir75kkooyea"."audit_event" IS %L','p3_audit_event_179d1ceba52f','P3|179d1ceba52ffdc74c419719993b34a216287a1876d189917d2b7c1df68e917e|'||pg_get_constraintdef(found_oid));
 ELSE
 actual:=obj_description(found_oid,'pg_constraint');
 IF actual IS DISTINCT FROM 'P3|179d1ceba52ffdc74c419719993b34a216287a1876d189917d2b7c1df68e917e|'||pg_get_constraintdef(found_oid) THEN RAISE EXCEPTION 'Constraint drift: p3_audit_event_179d1ceba52f'; END IF;
 END IF; END $p3$;
DO $p3$ DECLARE found_oid oid; actual text; BEGIN
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."audit_event"'::regclass AND c.conname='p3_audit_event_5a421ad7ab7b';
 IF found_oid IS NULL THEN
 ALTER TABLE "pb3gir75kkooyea"."audit_event" ADD CONSTRAINT "p3_audit_event_5a421ad7ab7b" CHECK ("kind" IN ('LOGIN','AUTH','ACCESS','OPERATION','API','ERROR'));
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."audit_event"'::regclass AND c.conname='p3_audit_event_5a421ad7ab7b';
 EXECUTE format('COMMENT ON CONSTRAINT %I ON "pb3gir75kkooyea"."audit_event" IS %L','p3_audit_event_5a421ad7ab7b','P3|5a421ad7ab7bb5678590b946992e617fe0f82d0148bcac0b95b3efe0f69730d6|'||pg_get_constraintdef(found_oid));
 ELSE
 actual:=obj_description(found_oid,'pg_constraint');
 IF actual IS DISTINCT FROM 'P3|5a421ad7ab7bb5678590b946992e617fe0f82d0148bcac0b95b3efe0f69730d6|'||pg_get_constraintdef(found_oid) THEN RAISE EXCEPTION 'Constraint drift: p3_audit_event_5a421ad7ab7b'; END IF;
 END IF; END $p3$;
DO $p3$ DECLARE found_oid oid; actual text; BEGIN
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."audit_event"'::regclass AND c.conname='p3_audit_event_8a2cbf4cf844';
 IF found_oid IS NULL THEN
 ALTER TABLE "pb3gir75kkooyea"."audit_event" ADD CONSTRAINT "p3_audit_event_8a2cbf4cf844" FOREIGN KEY ("actor_user_id") REFERENCES "pb3gir75kkooyea"."unified_user" ("id") ON DELETE RESTRICT;
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."audit_event"'::regclass AND c.conname='p3_audit_event_8a2cbf4cf844';
 EXECUTE format('COMMENT ON CONSTRAINT %I ON "pb3gir75kkooyea"."audit_event" IS %L','p3_audit_event_8a2cbf4cf844','P3|8a2cbf4cf8449a473c9f48529e3af567b1e9b6d7018fce266152dad603ed4ba6|'||pg_get_constraintdef(found_oid));
 ELSE
 actual:=obj_description(found_oid,'pg_constraint');
 IF actual IS DISTINCT FROM 'P3|8a2cbf4cf8449a473c9f48529e3af567b1e9b6d7018fce266152dad603ed4ba6|'||pg_get_constraintdef(found_oid) THEN RAISE EXCEPTION 'Constraint drift: p3_audit_event_8a2cbf4cf844'; END IF;
 END IF; END $p3$;
DO $p3$ DECLARE found_oid oid; actual text; BEGIN
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."audit_event"'::regclass AND c.conname='p3_audit_event_0b58d4fbed1c';
 IF found_oid IS NULL THEN
 ALTER TABLE "pb3gir75kkooyea"."audit_event" ADD CONSTRAINT "p3_audit_event_0b58d4fbed1c" CHECK ("actor_kind" IN ('USER','APPLICATION','SYSTEM','ANONYMOUS'));
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."audit_event"'::regclass AND c.conname='p3_audit_event_0b58d4fbed1c';
 EXECUTE format('COMMENT ON CONSTRAINT %I ON "pb3gir75kkooyea"."audit_event" IS %L','p3_audit_event_0b58d4fbed1c','P3|0b58d4fbed1c2f2d76bfd000ae4bada0adfe2832bf0739ad55f20551d11de612|'||pg_get_constraintdef(found_oid));
 ELSE
 actual:=obj_description(found_oid,'pg_constraint');
 IF actual IS DISTINCT FROM 'P3|0b58d4fbed1c2f2d76bfd000ae4bada0adfe2832bf0739ad55f20551d11de612|'||pg_get_constraintdef(found_oid) THEN RAISE EXCEPTION 'Constraint drift: p3_audit_event_0b58d4fbed1c'; END IF;
 END IF; END $p3$;
DO $p3$ DECLARE found_oid oid; actual text; BEGIN
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."audit_event"'::regclass AND c.conname='p3_audit_event_778fb9880d5c';
 IF found_oid IS NULL THEN
 ALTER TABLE "pb3gir75kkooyea"."audit_event" ADD CONSTRAINT "p3_audit_event_778fb9880d5c" FOREIGN KEY ("application_id") REFERENCES "pb3gir75kkooyea"."application" ("id") ON DELETE RESTRICT;
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."audit_event"'::regclass AND c.conname='p3_audit_event_778fb9880d5c';
 EXECUTE format('COMMENT ON CONSTRAINT %I ON "pb3gir75kkooyea"."audit_event" IS %L','p3_audit_event_778fb9880d5c','P3|778fb9880d5ce105037c82f8da30f1763ff5bdd00a1e931c0dfc5603b99a2d88|'||pg_get_constraintdef(found_oid));
 ELSE
 actual:=obj_description(found_oid,'pg_constraint');
 IF actual IS DISTINCT FROM 'P3|778fb9880d5ce105037c82f8da30f1763ff5bdd00a1e931c0dfc5603b99a2d88|'||pg_get_constraintdef(found_oid) THEN RAISE EXCEPTION 'Constraint drift: p3_audit_event_778fb9880d5c'; END IF;
 END IF; END $p3$;
DO $p3$ DECLARE found_oid oid; actual text; BEGIN
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."audit_event"'::regclass AND c.conname='p3_audit_event_24a22e04a028';
 IF found_oid IS NULL THEN
 ALTER TABLE "pb3gir75kkooyea"."audit_event" ADD CONSTRAINT "p3_audit_event_24a22e04a028" CHECK ("result" IN ('SUCCESS','FAILURE','DENIED'));
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."audit_event"'::regclass AND c.conname='p3_audit_event_24a22e04a028';
 EXECUTE format('COMMENT ON CONSTRAINT %I ON "pb3gir75kkooyea"."audit_event" IS %L','p3_audit_event_24a22e04a028','P3|24a22e04a028bbc79d6feac18eb9961ced38078fa7898594fd2bdaa1cead303c|'||pg_get_constraintdef(found_oid));
 ELSE
 actual:=obj_description(found_oid,'pg_constraint');
 IF actual IS DISTINCT FROM 'P3|24a22e04a028bbc79d6feac18eb9961ced38078fa7898594fd2bdaa1cead303c|'||pg_get_constraintdef(found_oid) THEN RAISE EXCEPTION 'Constraint drift: p3_audit_event_24a22e04a028'; END IF;
 END IF; END $p3$;
DO $p3$ DECLARE found_oid oid; actual text; BEGIN
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."audit_event"'::regclass AND c.conname='p3_audit_event_ed3f3b85e73e';
 IF found_oid IS NULL THEN
 ALTER TABLE "pb3gir75kkooyea"."audit_event" ADD CONSTRAINT "p3_audit_event_ed3f3b85e73e" CHECK ("details" IS NULL OR jsonb_typeof("details"::jsonb) IS NOT NULL);
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."audit_event"'::regclass AND c.conname='p3_audit_event_ed3f3b85e73e';
 EXECUTE format('COMMENT ON CONSTRAINT %I ON "pb3gir75kkooyea"."audit_event" IS %L','p3_audit_event_ed3f3b85e73e','P3|ed3f3b85e73ebb9e96f8dbaabc4e431ca66a3f92358b5de5c27405873f29a416|'||pg_get_constraintdef(found_oid));
 ELSE
 actual:=obj_description(found_oid,'pg_constraint');
 IF actual IS DISTINCT FROM 'P3|ed3f3b85e73ebb9e96f8dbaabc4e431ca66a3f92358b5de5c27405873f29a416|'||pg_get_constraintdef(found_oid) THEN RAISE EXCEPTION 'Constraint drift: p3_audit_event_ed3f3b85e73e'; END IF;
 END IF; END $p3$;
DO $p3$ DECLARE found_oid oid; actual text; BEGIN
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."audit_event"'::regclass AND c.conname='p3_audit_event_c922244128c0';
 IF found_oid IS NULL THEN
 ALTER TABLE "pb3gir75kkooyea"."audit_event" ADD CONSTRAINT "p3_audit_event_c922244128c0" CHECK ("resolution_status" IN ('OPEN','RESOLVED'));
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid='"pb3gir75kkooyea"."audit_event"'::regclass AND c.conname='p3_audit_event_c922244128c0';
 EXECUTE format('COMMENT ON CONSTRAINT %I ON "pb3gir75kkooyea"."audit_event" IS %L','p3_audit_event_c922244128c0','P3|c922244128c04fc8472e75927a0ba896da53aeeb61d55aa55814c4f7177b5a9b|'||pg_get_constraintdef(found_oid));
 ELSE
 actual:=obj_description(found_oid,'pg_constraint');
 IF actual IS DISTINCT FROM 'P3|c922244128c04fc8472e75927a0ba896da53aeeb61d55aa55814c4f7177b5a9b|'||pg_get_constraintdef(found_oid) THEN RAISE EXCEPTION 'Constraint drift: p3_audit_event_c922244128c0'; END IF;
 END IF; END $p3$;
DO $p3$ DECLARE found_oid oid; BEGIN
 found_oid:=to_regclass('pb3gir75kkooyea.p3i_audit_event_27ecf0f2c27e');
 IF found_oid IS NULL THEN
 CREATE INDEX "p3i_audit_event_27ecf0f2c27e" ON "pb3gir75kkooyea"."audit_event" ("kind","created_at");
 found_oid:=to_regclass('pb3gir75kkooyea.p3i_audit_event_27ecf0f2c27e');
 EXECUTE format('COMMENT ON INDEX "pb3gir75kkooyea".%I IS %L','p3i_audit_event_27ecf0f2c27e','P3|27ecf0f2c27e953b5bbf1e83f1e70c29fecc04d6f83d8bcb20c0d9ca66438e33|'||pg_get_indexdef(found_oid));
 ELSIF obj_description(found_oid,'pg_class') IS DISTINCT FROM 'P3|27ecf0f2c27e953b5bbf1e83f1e70c29fecc04d6f83d8bcb20c0d9ca66438e33|'||pg_get_indexdef(found_oid) THEN RAISE EXCEPTION 'Index drift: p3i_audit_event_27ecf0f2c27e';
 END IF; END $p3$;
DO $p3$ DECLARE found_oid oid; BEGIN
 found_oid:=to_regclass('pb3gir75kkooyea.p3i_audit_event_6658617c0757');
 IF found_oid IS NULL THEN
 CREATE INDEX "p3i_audit_event_6658617c0757" ON "pb3gir75kkooyea"."audit_event" ("request_id");
 found_oid:=to_regclass('pb3gir75kkooyea.p3i_audit_event_6658617c0757');
 EXECUTE format('COMMENT ON INDEX "pb3gir75kkooyea".%I IS %L','p3i_audit_event_6658617c0757','P3|6658617c0757989122c23bbe11269113a3cb1342a9100564cdf25f1689e9130e|'||pg_get_indexdef(found_oid));
 ELSIF obj_description(found_oid,'pg_class') IS DISTINCT FROM 'P3|6658617c0757989122c23bbe11269113a3cb1342a9100564cdf25f1689e9130e|'||pg_get_indexdef(found_oid) THEN RAISE EXCEPTION 'Index drift: p3i_audit_event_6658617c0757';
 END IF; END $p3$;
-- 199 constraints plus supporting indexes; repeated execution verifies definitions.
COMMIT;
