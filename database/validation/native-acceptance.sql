\set ON_ERROR_STOP on
BEGIN;
SET LOCAL search_path=pb3gir75kkooyea,pg_catalog;
CREATE FUNCTION pg_temp.rejects(stmt text, expected text) RETURNS void LANGUAGE plpgsql AS $$
BEGIN
 BEGIN
 EXECUTE stmt;
 EXCEPTION WHEN OTHERS THEN
 IF SQLSTATE = expected THEN RAISE NOTICE 'PASS expected %',expected; RETURN; END IF;
 RAISE;
 END;
 RAISE EXCEPTION 'Expected % but write succeeded: %',expected,stmt;
END $$;
INSERT INTO unified_user(id,created_at,updated_at,version,status) VALUES
 ('P3_TEST_U1',now(),now(),1,'NORMAL'),('P3_TEST_U2',now(),now(),1,'NORMAL');
INSERT INTO application(id,created_at,updated_at,version,code,name,user_type,application_url,sort_order,status,runtime_status,allowed_origins,binding_methods)
 VALUES ('P3_TEST_APP',now(),now(),1,'P3_TEST_APP','验收事务临时应用','BOTH','https://example.invalid',0,'DISABLED','UNCONFIGURED','[]','[]');
INSERT INTO identity_source(id,created_at,updated_at,version,code,name,kind,status) VALUES ('P3_TEST_SRC',now(),now(),1,'P3_TEST_SRC','测试','CITIZEN','DISABLED');
INSERT INTO identity_mapping(id,created_at,updated_at,version,user_id,source_id,external_subject_id,status) VALUES ('P3_TEST_IM1',now(),now(),1,'P3_TEST_U1','P3_TEST_SRC','SUBJECT','BOUND');
SELECT pg_temp.rejects($q$INSERT INTO identity_mapping(id,created_at,updated_at,version,user_id,source_id,external_subject_id,status) VALUES ('P3_TEST_IM2',now(),now(),1,'P3_TEST_U2','P3_TEST_SRC','SUBJECT','BOUND')$q$,'23505');
SELECT pg_temp.rejects($q$INSERT INTO unified_user(id,created_at,updated_at,version,status) VALUES ('P3_TEST_U1',now(),now(),1,'NORMAL')$q$,'23505');
SELECT pg_temp.rejects($q$UPDATE unified_user SET version=0 WHERE id='P3_TEST_U1'$q$,'23514');
SELECT pg_temp.rejects($q$UPDATE unified_user SET status='INVALID' WHERE id='P3_TEST_U1'$q$,'23514');
SELECT pg_temp.rejects($q$UPDATE unified_user SET id=NULL WHERE id='P3_TEST_U2'$q$,'23502');
INSERT INTO application_user_mapping(id,created_at,updated_at,version,user_id,application_id,external_user_id,status,active_account_key) VALUES ('P3_TEST_MAP1',now(),now(),1,'P3_TEST_U1','P3_TEST_APP','ACCOUNT','BOUND','["P3_TEST_APP","ACCOUNT"]');
SELECT pg_temp.rejects($q$INSERT INTO application_user_mapping(id,created_at,updated_at,version,user_id,application_id,external_user_id,status,active_account_key) VALUES ('P3_TEST_MAP2',now(),now(),1,'P3_TEST_U2','P3_TEST_APP','ACCOUNT','BOUND','["P3_TEST_APP", "ACCOUNT"]')$q$,'23505');
SELECT pg_temp.rejects($q$UPDATE application_user_mapping SET user_id='P3_TEST_MISSING' WHERE id='P3_TEST_MAP1'$q$,'23503');
SELECT pg_temp.rejects($q$UPDATE application SET allowed_origins='invalid-json' WHERE id='P3_TEST_APP'$q$,'22P02');
INSERT INTO todo_item(id,created_at,updated_at,version,application_id,source_todo_id,target_user_id,title,status,priority,source_created_at,source_updated_at,source_revision,business_url)
 VALUES ('P3_TEST_TODO',now(),now(),1,'P3_TEST_APP','TODO_1','P3_TEST_U1','验收', 'PENDING','MEDIUM',now(),now(),1,'https://example.invalid');
SELECT pg_temp.rejects($q$UPDATE todo_item SET status='COMPLETED' WHERE id='P3_TEST_TODO'$q$,'23514');
UPDATE todo_item SET status='COMPLETED',terminal_at=now(),version=2 WHERE id='P3_TEST_TODO';
INSERT INTO message(id,created_at,updated_at,version,source_kind,source_key,source_message_id,message_type,title,content,source_created_at)
 VALUES ('P3_TEST_MSG',now(),now(),1,'PORTAL','PORTAL','P3_TEST_MSG','SYSTEM','验收','测试',now());
INSERT INTO message_recipient(id,created_at,updated_at,version,message_id,user_id,read_status) VALUES ('P3_TEST_MR',now(),now(),1,'P3_TEST_MSG','P3_TEST_U1','UNREAD');
SELECT pg_temp.rejects($q$UPDATE message_recipient SET read_status='READ' WHERE id='P3_TEST_MR'$q$,'23514');
SELECT pg_temp.rejects($q$INSERT INTO message_recipient(id,created_at,updated_at,version,message_id,user_id,read_status) VALUES ('P3_TEST_MR2',now(),now(),1,'P3_TEST_MSG','P3_TEST_U1','UNREAD')$q$,'23505');
UPDATE message_recipient SET read_status='READ',read_at=now(),version=2 WHERE id='P3_TEST_MR';
SELECT pg_temp.rejects($q$DELETE FROM unified_user WHERE id='P3_TEST_U1'$q$,'23503');
SELECT pg_temp.rejects($q$UPDATE system_config SET status='CONFIGURED' WHERE code='retention.message_days'$q$,'23514');
DO $$ BEGIN
 IF (SELECT count(*) FROM system_config) <> 12 THEN RAISE EXCEPTION 'Seed count mismatch'; END IF;
 RAISE NOTICE 'PASS valid writes and 13 rejected invalid mutations';
END $$;
ROLLBACK;
DO $$ DECLARE r record; n bigint; BEGIN
 FOR r IN SELECT table_name FROM information_schema.columns WHERE table_schema='pb3gir75kkooyea' AND column_name='id' LOOP
 EXECUTE format('SELECT count(*) FROM %I.%I WHERE id LIKE %L','pb3gir75kkooyea',r.table_name,'P3_TEST_%') INTO n;
 IF n<>0 THEN RAISE EXCEPTION 'Residual test rows in %',r.table_name; END IF;
 END LOOP;
 RAISE NOTICE 'PASS transaction rolled back; zero test records in all project tables';
END $$;
SELECT contype,count(*) FROM pg_constraint WHERE connamespace='pb3gir75kkooyea'::regnamespace AND conname LIKE 'p3_%' GROUP BY contype ORDER BY contype;
