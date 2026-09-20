-- Read only: compare P4FIX_ rows with the reviewed manifest. No global counts assumed.
BEGIN READ ONLY;
SELECT 'identity_source' AS table_name, 2 AS expected_count, count(*) AS actual_count, count(*) = 2 AS matches FROM "pb3gir75kkooyea"."identity_source" WHERE left(id, 6) = 'P4FIX_'
UNION ALL
SELECT 'unified_user' AS table_name, 4 AS expected_count, count(*) AS actual_count, count(*) = 4 AS matches FROM "pb3gir75kkooyea"."unified_user" WHERE left(id, 6) = 'P4FIX_'
UNION ALL
SELECT 'identity_mapping' AS table_name, 4 AS expected_count, count(*) AS actual_count, count(*) = 4 AS matches FROM "pb3gir75kkooyea"."identity_mapping" WHERE left(id, 6) = 'P4FIX_'
UNION ALL
SELECT 'login_request' AS table_name, 0 AS expected_count, count(*) AS actual_count, count(*) = 0 AS matches FROM "pb3gir75kkooyea"."login_request" WHERE left(id, 6) = 'P4FIX_'
UNION ALL
SELECT 'portal_session' AS table_name, 0 AS expected_count, count(*) AS actual_count, count(*) = 0 AS matches FROM "pb3gir75kkooyea"."portal_session" WHERE left(id, 6) = 'P4FIX_'
UNION ALL
SELECT 'application_category' AS table_name, 6 AS expected_count, count(*) AS actual_count, count(*) = 6 AS matches FROM "pb3gir75kkooyea"."application_category" WHERE left(id, 6) = 'P4FIX_'
UNION ALL
SELECT 'application' AS table_name, 42 AS expected_count, count(*) AS actual_count, count(*) = 42 AS matches FROM "pb3gir75kkooyea"."application" WHERE left(id, 6) = 'P4FIX_'
UNION ALL
SELECT 'application_user_mapping' AS table_name, 40 AS expected_count, count(*) AS actual_count, count(*) = 40 AS matches FROM "pb3gir75kkooyea"."application_user_mapping" WHERE left(id, 6) = 'P4FIX_'
UNION ALL
SELECT 'mapping_exception' AS table_name, 8 AS expected_count, count(*) AS actual_count, count(*) = 8 AS matches FROM "pb3gir75kkooyea"."mapping_exception" WHERE left(id, 6) = 'P4FIX_'
UNION ALL
SELECT 'portal_role' AS table_name, 3 AS expected_count, count(*) AS actual_count, count(*) = 3 AS matches FROM "pb3gir75kkooyea"."portal_role" WHERE left(id, 6) = 'P4FIX_'
UNION ALL
SELECT 'portal_permission' AS table_name, 6 AS expected_count, count(*) AS actual_count, count(*) = 6 AS matches FROM "pb3gir75kkooyea"."portal_permission" WHERE left(id, 6) = 'P4FIX_'
UNION ALL
SELECT 'portal_role_permission' AS table_name, 7 AS expected_count, count(*) AS actual_count, count(*) = 7 AS matches FROM "pb3gir75kkooyea"."portal_role_permission" WHERE left(id, 6) = 'P4FIX_'
UNION ALL
SELECT 'portal_user_role' AS table_name, 4 AS expected_count, count(*) AS actual_count, count(*) = 4 AS matches FROM "pb3gir75kkooyea"."portal_user_role" WHERE left(id, 6) = 'P4FIX_'
UNION ALL
SELECT 'portal_user_application_scope' AS table_name, 32 AS expected_count, count(*) AS actual_count, count(*) = 32 AS matches FROM "pb3gir75kkooyea"."portal_user_application_scope" WHERE left(id, 6) = 'P4FIX_'
UNION ALL
SELECT 'sso_config' AS table_name, 42 AS expected_count, count(*) AS actual_count, count(*) = 42 AS matches FROM "pb3gir75kkooyea"."sso_config" WHERE left(id, 6) = 'P4FIX_'
UNION ALL
SELECT 'push_integration_config' AS table_name, 84 AS expected_count, count(*) AS actual_count, count(*) = 84 AS matches FROM "pb3gir75kkooyea"."push_integration_config" WHERE left(id, 6) = 'P4FIX_'
UNION ALL
SELECT 'ingest_receipt' AS table_name, 3 AS expected_count, count(*) AS actual_count, count(*) = 3 AS matches FROM "pb3gir75kkooyea"."ingest_receipt" WHERE left(id, 6) = 'P4FIX_'
UNION ALL
SELECT 'todo_item' AS table_name, 44 AS expected_count, count(*) AS actual_count, count(*) = 44 AS matches FROM "pb3gir75kkooyea"."todo_item" WHERE left(id, 6) = 'P4FIX_'
UNION ALL
SELECT 'message' AS table_name, 40 AS expected_count, count(*) AS actual_count, count(*) = 40 AS matches FROM "pb3gir75kkooyea"."message" WHERE left(id, 6) = 'P4FIX_'
UNION ALL
SELECT 'message_recipient' AS table_name, 40 AS expected_count, count(*) AS actual_count, count(*) = 40 AS matches FROM "pb3gir75kkooyea"."message_recipient" WHERE left(id, 6) = 'P4FIX_'
UNION ALL
SELECT 'announcement' AS table_name, 8 AS expected_count, count(*) AS actual_count, count(*) = 8 AS matches FROM "pb3gir75kkooyea"."announcement" WHERE left(id, 6) = 'P4FIX_'
UNION ALL
SELECT 'announcement_org_scope' AS table_name, 2 AS expected_count, count(*) AS actual_count, count(*) = 2 AS matches FROM "pb3gir75kkooyea"."announcement_org_scope" WHERE left(id, 6) = 'P4FIX_'
UNION ALL
SELECT 'announcement_attachment' AS table_name, 0 AS expected_count, count(*) AS actual_count, count(*) = 0 AS matches FROM "pb3gir75kkooyea"."announcement_attachment" WHERE left(id, 6) = 'P4FIX_'
UNION ALL
SELECT 'sms_channel' AS table_name, 0 AS expected_count, count(*) AS actual_count, count(*) = 0 AS matches FROM "pb3gir75kkooyea"."sms_channel" WHERE left(id, 6) = 'P4FIX_'
UNION ALL
SELECT 'sms_template' AS table_name, 0 AS expected_count, count(*) AS actual_count, count(*) = 0 AS matches FROM "pb3gir75kkooyea"."sms_template" WHERE left(id, 6) = 'P4FIX_'
UNION ALL
SELECT 'sms_application' AS table_name, 0 AS expected_count, count(*) AS actual_count, count(*) = 0 AS matches FROM "pb3gir75kkooyea"."sms_application" WHERE left(id, 6) = 'P4FIX_'
UNION ALL
SELECT 'sms_application_template' AS table_name, 0 AS expected_count, count(*) AS actual_count, count(*) = 0 AS matches FROM "pb3gir75kkooyea"."sms_application_template" WHERE left(id, 6) = 'P4FIX_'
UNION ALL
SELECT 'sms_send_record' AS table_name, 0 AS expected_count, count(*) AS actual_count, count(*) = 0 AS matches FROM "pb3gir75kkooyea"."sms_send_record" WHERE left(id, 6) = 'P4FIX_'
UNION ALL
SELECT 'sms_send_attempt' AS table_name, 0 AS expected_count, count(*) AS actual_count, count(*) = 0 AS matches FROM "pb3gir75kkooyea"."sms_send_attempt" WHERE left(id, 6) = 'P4FIX_'
UNION ALL
SELECT 'system_config' AS table_name, 8 AS expected_count, count(*) AS actual_count, count(*) = 8 AS matches FROM "pb3gir75kkooyea"."system_config" WHERE left(id, 6) = 'P4FIX_'
UNION ALL
SELECT 'monitor_status' AS table_name, 4 AS expected_count, count(*) AS actual_count, count(*) = 4 AS matches FROM "pb3gir75kkooyea"."monitor_status" WHERE left(id, 6) = 'P4FIX_'
UNION ALL
SELECT 'audit_event' AS table_name, 24 AS expected_count, count(*) AS actual_count, count(*) = 24 AS matches FROM "pb3gir75kkooyea"."audit_event" WHERE left(id, 6) = 'P4FIX_';
COMMIT;

