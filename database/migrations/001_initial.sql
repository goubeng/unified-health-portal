-- P3 v0.1.0: PostgreSQL 14 TARGET; live base engine/version NOT verified.
-- Executable in a dedicated empty PostgreSQL database/schema.
-- Not a NocoDB metadata import. Never attach an external source to the target base.
BEGIN;

-- 身份源配置
CREATE TABLE "identity_source" (
  "id" text PRIMARY KEY NOT NULL,
  "created_at" timestamptz NOT NULL,
  "updated_at" timestamptz NOT NULL,
  "version" bigint NOT NULL DEFAULT 1 CHECK ("version" >= 1),
  "code" text NOT NULL,
  "name" text NOT NULL,
  "kind" text NOT NULL CHECK ("kind" IN ('CITIZEN', 'GOV')),
  "protocol" text,
  "config_secret_ref" text,
  "register_url" text,
  "status" text NOT NULL DEFAULT 'DISABLED' CHECK ("status" IN ('ENABLED', 'DISABLED')),
  UNIQUE ("code")
);

-- 最小身份索引
CREATE TABLE "unified_user" (
  "id" text PRIMARY KEY NOT NULL,
  "created_at" timestamptz NOT NULL,
  "updated_at" timestamptz NOT NULL,
  "version" bigint NOT NULL DEFAULT 1 CHECK ("version" >= 1),
  "display_name" text,
  "org_key" text,
  "org_name" text,
  "status" text NOT NULL DEFAULT 'NORMAL' CHECK ("status" IN ('NORMAL', 'ABNORMAL', 'DISABLED')),
  "first_login_at" timestamptz,
  "last_login_at" timestamptz
);

-- 一人多身份；不按手机号合并
CREATE TABLE "identity_mapping" (
  "id" text PRIMARY KEY NOT NULL,
  "created_at" timestamptz NOT NULL,
  "updated_at" timestamptz NOT NULL,
  "version" bigint NOT NULL DEFAULT 1 CHECK ("version" >= 1),
  "user_id" text NOT NULL REFERENCES "unified_user"("id") ON DELETE RESTRICT,
  "source_id" text NOT NULL REFERENCES "identity_source"("id") ON DELETE RESTRICT,
  "external_subject_id" text NOT NULL,
  "external_account" text,
  "status" text NOT NULL DEFAULT 'PENDING' CHECK ("status" IN ('PENDING', 'BOUND', 'CONFLICT', 'UNBOUND')),
  "verified_at" timestamptz,
  UNIQUE ("source_id", "external_subject_id")
);

-- 一次性登录请求
CREATE TABLE "login_request" (
  "id" text PRIMARY KEY NOT NULL,
  "created_at" timestamptz NOT NULL,
  "updated_at" timestamptz NOT NULL,
  "version" bigint NOT NULL DEFAULT 1 CHECK ("version" >= 1),
  "source_id" text NOT NULL REFERENCES "identity_source"("id") ON DELETE RESTRICT,
  "state_hash" text NOT NULL,
  "method" text NOT NULL,
  "status" text NOT NULL DEFAULT 'WAITING' CHECK ("status" IN ('WAITING', 'SCANNED', 'AUTHENTICATING', 'SUCCESS', 'FAILED', 'EXPIRED', 'CANCELLED')),
  "expires_at" timestamptz NOT NULL,
  "consumed_at" timestamptz,
  "failure_code" text,
  UNIQUE ("state_hash")
);

-- 会话，不保存明文Token
CREATE TABLE "portal_session" (
  "id" text PRIMARY KEY NOT NULL,
  "created_at" timestamptz NOT NULL,
  "updated_at" timestamptz NOT NULL,
  "version" bigint NOT NULL DEFAULT 1 CHECK ("version" >= 1),
  "user_id" text NOT NULL REFERENCES "unified_user"("id") ON DELETE RESTRICT,
  "identity_mapping_id" text NOT NULL REFERENCES "identity_mapping"("id") ON DELETE RESTRICT,
  "token_hash" text NOT NULL,
  "expires_at" timestamptz NOT NULL,
  "revoked_at" timestamptz,
  UNIQUE ("token_hash")
);

-- 应用分类
CREATE TABLE "application_category" (
  "id" text PRIMARY KEY NOT NULL,
  "created_at" timestamptz NOT NULL,
  "updated_at" timestamptz NOT NULL,
  "version" bigint NOT NULL DEFAULT 1 CHECK ("version" >= 1),
  "code" text NOT NULL,
  "name" text NOT NULL,
  "icon" text,
  "sort_order" bigint NOT NULL DEFAULT 0,
  "status" text NOT NULL DEFAULT 'ENABLED' CHECK ("status" IN ('ENABLED', 'DISABLED')),
  "remark" text,
  UNIQUE ("code")
);

-- 目录，不代表应用内部授权
CREATE TABLE "application" (
  "id" text PRIMARY KEY NOT NULL,
  "created_at" timestamptz NOT NULL,
  "updated_at" timestamptz NOT NULL,
  "version" bigint NOT NULL DEFAULT 1 CHECK ("version" >= 1),
  "code" text NOT NULL,
  "name" text NOT NULL,
  "category_id" text REFERENCES "application_category"("id") ON DELETE RESTRICT,
  "network_zone" text,
  "user_type" text NOT NULL CHECK ("user_type" IN ('CITIZEN', 'GOV', 'BOTH')),
  "application_url" text NOT NULL,
  "logo_url" text,
  "description" text,
  "contact_name" text,
  "technical_contact" text,
  "sort_order" bigint NOT NULL DEFAULT 0,
  "status" text NOT NULL DEFAULT 'DISABLED' CHECK ("status" IN ('ENABLED', 'DISABLED')),
  "runtime_status" text NOT NULL DEFAULT 'UNCONFIGURED' CHECK ("runtime_status" IN ('NORMAL', 'ABNORMAL', 'UNCONFIGURED', 'DISABLED')),
  "allowed_origins" jsonb NOT NULL DEFAULT '[]'::jsonb,
  "binding_methods" jsonb NOT NULL DEFAULT '[]'::jsonb,
  UNIQUE ("code")
);

-- 每人每应用一个当前映射槽位
CREATE TABLE "application_user_mapping" (
  "id" text PRIMARY KEY NOT NULL,
  "created_at" timestamptz NOT NULL,
  "updated_at" timestamptz NOT NULL,
  "version" bigint NOT NULL DEFAULT 1 CHECK ("version" >= 1),
  "user_id" text NOT NULL REFERENCES "unified_user"("id") ON DELETE RESTRICT,
  "application_id" text NOT NULL REFERENCES "application"("id") ON DELETE RESTRICT,
  "external_user_id" text,
  "external_account" text,
  "binding_method" text CHECK ("binding_method" IN ('AUTO', 'SELF', 'ADMIN')),
  "status" text NOT NULL DEFAULT 'UNBOUND' CHECK ("status" IN ('UNBOUND', 'VERIFYING', 'BOUND', 'FAILED', 'CONFLICT')),
  "active_account_key" text,
  "verified_method" text,
  "verified_at" timestamptz,
  "bound_at" timestamptz,
  "unbound_at" timestamptz,
  "conflict_reason" text,
  UNIQUE ("user_id", "application_id"),
  UNIQUE ("active_account_key"),
  CHECK ((status = 'BOUND' AND external_user_id IS NOT NULL AND active_account_key IS NOT NULL) OR (status <> 'BOUND' AND active_account_key IS NULL)),
  CHECK (active_account_key IS NULL OR active_account_key::jsonb = jsonb_build_array(application_id, external_user_id))
);
CREATE UNIQUE INDEX "uq_mapping_bound_account" ON "application_user_mapping" ("application_id", "external_user_id") WHERE status = 'BOUND';

-- 异常处理记录
CREATE TABLE "mapping_exception" (
  "id" text PRIMARY KEY NOT NULL,
  "created_at" timestamptz NOT NULL,
  "updated_at" timestamptz NOT NULL,
  "version" bigint NOT NULL DEFAULT 1 CHECK ("version" >= 1),
  "mapping_id" text REFERENCES "application_user_mapping"("id") ON DELETE RESTRICT,
  "identity_mapping_id" text REFERENCES "identity_mapping"("id") ON DELETE RESTRICT,
  "exception_type" text NOT NULL,
  "summary" text NOT NULL,
  "resolution_status" text NOT NULL DEFAULT 'OPEN' CHECK ("resolution_status" IN ('OPEN', 'RESOLVED')),
  "resolved_by" text REFERENCES "unified_user"("id") ON DELETE RESTRICT,
  "resolved_at" timestamptz,
  "resolution_note" text,
  CHECK (mapping_id IS NOT NULL OR identity_mapping_id IS NOT NULL)
);

-- 门户角色，不含子系统角色
CREATE TABLE "portal_role" (
  "id" text PRIMARY KEY NOT NULL,
  "created_at" timestamptz NOT NULL,
  "updated_at" timestamptz NOT NULL,
  "version" bigint NOT NULL DEFAULT 1 CHECK ("version" >= 1),
  "code" text NOT NULL,
  "name" text NOT NULL,
  "description" text,
  "status" text NOT NULL DEFAULT 'DISABLED' CHECK ("status" IN ('ENABLED', 'DISABLED')),
  UNIQUE ("code")
);

-- 门户权限注册项
CREATE TABLE "portal_permission" (
  "id" text PRIMARY KEY NOT NULL,
  "created_at" timestamptz NOT NULL,
  "updated_at" timestamptz NOT NULL,
  "version" bigint NOT NULL DEFAULT 1 CHECK ("version" >= 1),
  "code" text NOT NULL,
  "name" text NOT NULL,
  "kind" text NOT NULL CHECK ("kind" IN ('MENU', 'PAGE', 'ACTION')),
  "route" text,
  UNIQUE ("code")
);

-- 角色权限关联
CREATE TABLE "portal_role_permission" (
  "id" text PRIMARY KEY NOT NULL,
  "created_at" timestamptz NOT NULL,
  "updated_at" timestamptz NOT NULL,
  "version" bigint NOT NULL DEFAULT 1 CHECK ("version" >= 1),
  "role_id" text NOT NULL REFERENCES "portal_role"("id") ON DELETE RESTRICT,
  "permission_id" text NOT NULL REFERENCES "portal_permission"("id") ON DELETE RESTRICT,
  "data_scope" text NOT NULL DEFAULT 'SELF' CHECK ("data_scope" IN ('SELF', 'ASSIGNED_APPS', 'ALL_PORTAL')),
  UNIQUE ("role_id", "permission_id")
);

-- 身份角色授权，不管理身份资料
CREATE TABLE "portal_user_role" (
  "id" text PRIMARY KEY NOT NULL,
  "created_at" timestamptz NOT NULL,
  "updated_at" timestamptz NOT NULL,
  "version" bigint NOT NULL DEFAULT 1 CHECK ("version" >= 1),
  "user_id" text NOT NULL REFERENCES "unified_user"("id") ON DELETE RESTRICT,
  "role_id" text NOT NULL REFERENCES "portal_role"("id") ON DELETE RESTRICT,
  "granted_by" text NOT NULL REFERENCES "unified_user"("id") ON DELETE RESTRICT,
  "expires_at" timestamptz,
  UNIQUE ("user_id", "role_id")
);

-- 指定应用的数据管理范围
CREATE TABLE "portal_user_application_scope" (
  "id" text PRIMARY KEY NOT NULL,
  "created_at" timestamptz NOT NULL,
  "updated_at" timestamptz NOT NULL,
  "version" bigint NOT NULL DEFAULT 1 CHECK ("version" >= 1),
  "user_id" text NOT NULL REFERENCES "unified_user"("id") ON DELETE RESTRICT,
  "application_id" text NOT NULL REFERENCES "application"("id") ON DELETE RESTRICT,
  UNIQUE ("user_id", "application_id")
);

-- 协议参数占位，不预设真实端点
CREATE TABLE "sso_config" (
  "id" text PRIMARY KEY NOT NULL,
  "created_at" timestamptz NOT NULL,
  "updated_at" timestamptz NOT NULL,
  "version" bigint NOT NULL DEFAULT 1 CHECK ("version" >= 1),
  "application_id" text NOT NULL REFERENCES "application"("id") ON DELETE RESTRICT,
  "protocol" text NOT NULL,
  "client_id" text,
  "secret_ref" text,
  "endpoints" jsonb NOT NULL DEFAULT '{}'::jsonb,
  "user_key_field" text,
  "token_expire_seconds" bigint,
  "status" text NOT NULL DEFAULT 'UNCONFIGURED' CHECK ("status" IN ('NORMAL', 'ABNORMAL', 'UNCONFIGURED', 'DISABLED')),
  UNIQUE ("application_id")
);

-- 待办、消息分别配置；同表不同kind
CREATE TABLE "push_integration_config" (
  "id" text PRIMARY KEY NOT NULL,
  "created_at" timestamptz NOT NULL,
  "updated_at" timestamptz NOT NULL,
  "version" bigint NOT NULL DEFAULT 1 CHECK ("version" >= 1),
  "application_id" text NOT NULL REFERENCES "application"("id") ON DELETE RESTRICT,
  "kind" text NOT NULL CHECK ("kind" IN ('TODO', 'MESSAGE')),
  "mode" text NOT NULL DEFAULT 'PUSH' CHECK ("mode" IN ('PUSH')),
  "credential_ref" text,
  "field_mapping" jsonb NOT NULL DEFAULT '{}'::jsonb,
  "value_mapping" jsonb NOT NULL DEFAULT '{}'::jsonb,
  "target_key_kind" text NOT NULL CHECK ("target_key_kind" IN ('UNIFIED_USER_ID', 'EXTERNAL_USER_ID')),
  "status" text NOT NULL DEFAULT 'UNCONFIGURED' CHECK ("status" IN ('NORMAL', 'ABNORMAL', 'UNCONFIGURED', 'DISABLED')),
  "last_received_at" timestamptz,
  UNIQUE ("application_id", "kind")
);

-- 接收幂等与处理恢复
CREATE TABLE "ingest_receipt" (
  "id" text PRIMARY KEY NOT NULL,
  "created_at" timestamptz NOT NULL,
  "updated_at" timestamptz NOT NULL,
  "version" bigint NOT NULL DEFAULT 1 CHECK ("version" >= 1),
  "application_id" text NOT NULL REFERENCES "application"("id") ON DELETE RESTRICT,
  "kind" text NOT NULL CHECK ("kind" IN ('TODO', 'MESSAGE', 'SMS')),
  "event_id" text NOT NULL,
  "payload_hash" text NOT NULL,
  "status" text NOT NULL DEFAULT 'RECEIVED' CHECK ("status" IN ('RECEIVED', 'APPLIED', 'REJECTED')),
  "result" jsonb,
  "applied_at" timestamptz,
  UNIQUE ("application_id", "kind", "event_id")
);

-- 一个源待办对应一个目标用户
CREATE TABLE "todo_item" (
  "id" text PRIMARY KEY NOT NULL,
  "created_at" timestamptz NOT NULL,
  "updated_at" timestamptz NOT NULL,
  "version" bigint NOT NULL DEFAULT 1 CHECK ("version" >= 1),
  "application_id" text NOT NULL REFERENCES "application"("id") ON DELETE RESTRICT,
  "source_todo_id" text NOT NULL,
  "target_user_id" text NOT NULL REFERENCES "unified_user"("id") ON DELETE RESTRICT,
  "title" text NOT NULL,
  "business_type" text,
  "summary" text,
  "status" text NOT NULL DEFAULT 'PENDING' CHECK ("status" IN ('PENDING', 'COMPLETED', 'WITHDRAWN', 'EXPIRED')),
  "priority" text NOT NULL DEFAULT 'MEDIUM' CHECK ("priority" IN ('HIGH', 'MEDIUM', 'LOW')),
  "source_created_at" timestamptz NOT NULL,
  "source_updated_at" timestamptz NOT NULL,
  "source_revision" bigint NOT NULL CHECK ("source_revision" >= 1),
  "due_at" timestamptz,
  "terminal_at" timestamptz,
  "business_url" text NOT NULL,
  UNIQUE ("application_id", "source_todo_id"),
  CHECK ((status = 'PENDING' AND terminal_at IS NULL) OR (status <> 'PENDING' AND terminal_at IS NOT NULL))
);
CREATE INDEX "ix_todo_item_1" ON "todo_item" ("target_user_id", "status", "source_created_at");

-- 门户及外部消息本体
CREATE TABLE "message" (
  "id" text PRIMARY KEY NOT NULL,
  "created_at" timestamptz NOT NULL,
  "updated_at" timestamptz NOT NULL,
  "version" bigint NOT NULL DEFAULT 1 CHECK ("version" >= 1),
  "application_id" text REFERENCES "application"("id") ON DELETE RESTRICT,
  "source_kind" text NOT NULL CHECK ("source_kind" IN ('PORTAL', 'APPLICATION')),
  "source_key" text NOT NULL,
  "source_message_id" text NOT NULL,
  "message_type" text NOT NULL CHECK ("message_type" IN ('BUSINESS', 'SYSTEM', 'ACCOUNT', 'SECURITY', 'TODO_REMINDER', 'OTHER')),
  "title" text NOT NULL,
  "content" text NOT NULL,
  "business_url" text,
  "source_created_at" timestamptz NOT NULL,
  UNIQUE ("source_key", "source_message_id"),
  CHECK ((source_kind = 'PORTAL' AND application_id IS NULL AND source_key = 'PORTAL') OR (source_kind = 'APPLICATION' AND application_id IS NOT NULL AND source_key = application_id))
);

-- 每个收件人独立已读状态
CREATE TABLE "message_recipient" (
  "id" text PRIMARY KEY NOT NULL,
  "created_at" timestamptz NOT NULL,
  "updated_at" timestamptz NOT NULL,
  "version" bigint NOT NULL DEFAULT 1 CHECK ("version" >= 1),
  "message_id" text NOT NULL REFERENCES "message"("id") ON DELETE RESTRICT,
  "user_id" text NOT NULL REFERENCES "unified_user"("id") ON DELETE RESTRICT,
  "read_status" text NOT NULL DEFAULT 'UNREAD' CHECK ("read_status" IN ('UNREAD', 'READ')),
  "read_at" timestamptz,
  UNIQUE ("message_id", "user_id"),
  CHECK ((read_status = 'UNREAD' AND read_at IS NULL) OR (read_status = 'READ' AND read_at IS NOT NULL))
);
CREATE INDEX "ix_message_recipient_1" ON "message_recipient" ("user_id", "read_status");

-- 仅门户自产公告
CREATE TABLE "announcement" (
  "id" text PRIMARY KEY NOT NULL,
  "created_at" timestamptz NOT NULL,
  "updated_at" timestamptz NOT NULL,
  "version" bigint NOT NULL DEFAULT 1 CHECK ("version" >= 1),
  "title" text NOT NULL,
  "announcement_type" text NOT NULL,
  "content" text NOT NULL,
  "scope" text NOT NULL DEFAULT 'ALL' CHECK ("scope" IN ('ALL', 'CITIZEN', 'GOV', 'ORG')),
  "status" text NOT NULL DEFAULT 'DRAFT' CHECK ("status" IN ('DRAFT', 'PUBLISHED', 'WITHDRAWN', 'EXPIRED')),
  "effective_start" timestamptz,
  "effective_end" timestamptz,
  "publisher_id" text REFERENCES "unified_user"("id") ON DELETE RESTRICT,
  "published_at" timestamptz,
  CHECK (effective_end IS NULL OR effective_start IS NULL OR effective_end > effective_start),
  CHECK (status <> 'PUBLISHED' OR (publisher_id IS NOT NULL AND published_at IS NOT NULL))
);

-- 组织标识引用上层，不建组织主数据
CREATE TABLE "announcement_org_scope" (
  "id" text PRIMARY KEY NOT NULL,
  "created_at" timestamptz NOT NULL,
  "updated_at" timestamptz NOT NULL,
  "version" bigint NOT NULL DEFAULT 1 CHECK ("version" >= 1),
  "announcement_id" text NOT NULL REFERENCES "announcement"("id") ON DELETE RESTRICT,
  "identity_source_code" text NOT NULL,
  "org_key" text NOT NULL,
  UNIQUE ("announcement_id", "identity_source_code", "org_key")
);

-- NocoDB上传完成后的附件对象
CREATE TABLE "announcement_attachment" (
  "id" text PRIMARY KEY NOT NULL,
  "created_at" timestamptz NOT NULL,
  "updated_at" timestamptz NOT NULL,
  "version" bigint NOT NULL DEFAULT 1 CHECK ("version" >= 1),
  "announcement_id" text NOT NULL REFERENCES "announcement"("id") ON DELETE RESTRICT,
  "file_name" text NOT NULL,
  "size_bytes" bigint NOT NULL CHECK ("size_bytes" >= 0),
  "mime_type" text NOT NULL,
  "attachment" jsonb NOT NULL,
  "uploaded_by" text NOT NULL REFERENCES "unified_user"("id") ON DELETE RESTRICT,
  "sort_order" bigint NOT NULL DEFAULT 0
);

-- 短信渠道配置
CREATE TABLE "sms_channel" (
  "id" text PRIMARY KEY NOT NULL,
  "created_at" timestamptz NOT NULL,
  "updated_at" timestamptz NOT NULL,
  "version" bigint NOT NULL DEFAULT 1 CHECK ("version" >= 1),
  "code" text NOT NULL,
  "name" text NOT NULL,
  "provider" text NOT NULL,
  "api_url" text NOT NULL,
  "secret_ref" text NOT NULL,
  "sign_name" text NOT NULL,
  "status" text NOT NULL DEFAULT 'DISABLED' CHECK ("status" IN ('ENABLED', 'DISABLED')),
  "runtime_status" text NOT NULL DEFAULT 'UNCONFIGURED' CHECK ("runtime_status" IN ('NORMAL', 'ABNORMAL', 'UNCONFIGURED', 'DISABLED')),
  UNIQUE ("code")
);

-- 短信模板定义
CREATE TABLE "sms_template" (
  "id" text PRIMARY KEY NOT NULL,
  "created_at" timestamptz NOT NULL,
  "updated_at" timestamptz NOT NULL,
  "version" bigint NOT NULL DEFAULT 1 CHECK ("version" >= 1),
  "code" text NOT NULL,
  "name" text NOT NULL,
  "scene_type" text NOT NULL,
  "content" text NOT NULL,
  "variables" jsonb NOT NULL DEFAULT '{}'::jsonb,
  "sign_name" text NOT NULL,
  "provider_template_id" text,
  "status" text NOT NULL DEFAULT 'DISABLED' CHECK ("status" IN ('ENABLED', 'DISABLED')),
  UNIQUE ("code")
);

-- 短信调用授权，不代表业务授权
CREATE TABLE "sms_application" (
  "id" text PRIMARY KEY NOT NULL,
  "created_at" timestamptz NOT NULL,
  "updated_at" timestamptz NOT NULL,
  "version" bigint NOT NULL DEFAULT 1 CHECK ("version" >= 1),
  "application_id" text NOT NULL REFERENCES "application"("id") ON DELETE RESTRICT,
  "sms_app_id" text NOT NULL,
  "secret_ref" text,
  "daily_limit" bigint,
  "status" text NOT NULL DEFAULT 'DISABLED' CHECK ("status" IN ('ENABLED', 'DISABLED')),
  UNIQUE ("application_id"),
  UNIQUE ("sms_app_id")
);

-- 允许模板白名单
CREATE TABLE "sms_application_template" (
  "id" text PRIMARY KEY NOT NULL,
  "created_at" timestamptz NOT NULL,
  "updated_at" timestamptz NOT NULL,
  "version" bigint NOT NULL DEFAULT 1 CHECK ("version" >= 1),
  "sms_application_id" text NOT NULL REFERENCES "sms_application"("id") ON DELETE RESTRICT,
  "template_id" text NOT NULL REFERENCES "sms_template"("id") ON DELETE RESTRICT,
  UNIQUE ("sms_application_id", "template_id")
);

-- 逻辑短信请求；重试保留同一个记录
CREATE TABLE "sms_send_record" (
  "id" text PRIMARY KEY NOT NULL,
  "created_at" timestamptz NOT NULL,
  "updated_at" timestamptz NOT NULL,
  "version" bigint NOT NULL DEFAULT 1 CHECK ("version" >= 1),
  "application_id" text NOT NULL REFERENCES "application"("id") ON DELETE RESTRICT,
  "template_id" text NOT NULL REFERENCES "sms_template"("id") ON DELETE RESTRICT,
  "channel_id" text NOT NULL REFERENCES "sms_channel"("id") ON DELETE RESTRICT,
  "request_key" text NOT NULL,
  "payload_hash" text NOT NULL,
  "mobile_masked" text NOT NULL,
  "recipient_secret_ref" text NOT NULL,
  "variables_secret_ref" text NOT NULL,
  "content_summary" text,
  "status" text NOT NULL DEFAULT 'PENDING' CHECK ("status" IN ('PENDING', 'SENDING', 'SUCCESS', 'FAILED')),
  "retry_count" bigint NOT NULL DEFAULT 0 CHECK ("retry_count" >= 0),
  "failure_reason" text,
  UNIQUE ("application_id", "request_key")
);

-- 每次外部调用与计费回执
CREATE TABLE "sms_send_attempt" (
  "id" text PRIMARY KEY NOT NULL,
  "created_at" timestamptz NOT NULL,
  "updated_at" timestamptz NOT NULL,
  "version" bigint NOT NULL DEFAULT 1 CHECK ("version" >= 1),
  "send_id" text NOT NULL REFERENCES "sms_send_record"("id") ON DELETE RESTRICT,
  "attempt_no" bigint NOT NULL CHECK ("attempt_no" >= 1),
  "provider_request_id" text,
  "status" text NOT NULL CHECK ("status" IN ('PENDING', 'SENDING', 'SUCCESS', 'FAILED')),
  "delivery_certainty" text NOT NULL DEFAULT 'UNKNOWN' CHECK ("delivery_certainty" IN ('UNKNOWN', 'CONFIRMED_SUCCESS', 'CONFIRMED_FAILURE')),
  "fee_minor_units" bigint,
  "currency" text,
  "finished_at" timestamptz,
  "provider_summary" text,
  UNIQUE ("send_id", "attempt_no")
);

-- 配置值不预设正式周期
CREATE TABLE "system_config" (
  "id" text PRIMARY KEY NOT NULL,
  "created_at" timestamptz NOT NULL,
  "updated_at" timestamptz NOT NULL,
  "version" bigint NOT NULL DEFAULT 1 CHECK ("version" >= 1),
  "code" text NOT NULL,
  "value" jsonb,
  "unit" text NOT NULL,
  "status" text NOT NULL DEFAULT 'UNCONFIGURED' CHECK ("status" IN ('UNCONFIGURED', 'CONFIGURED')),
  "description" text NOT NULL,
  UNIQUE ("code"),
  CHECK ((status = 'UNCONFIGURED' AND value IS NULL) OR (status = 'CONFIGURED' AND value IS NOT NULL))
);

-- 一服务一个观察快照
CREATE TABLE "monitor_status" (
  "id" text PRIMARY KEY NOT NULL,
  "created_at" timestamptz NOT NULL,
  "updated_at" timestamptz NOT NULL,
  "version" bigint NOT NULL DEFAULT 1 CHECK ("version" >= 1),
  "target_key" text NOT NULL,
  "service_type" text NOT NULL CHECK ("service_type" IN ('IDENTITY', 'SSO', 'TODO', 'MESSAGE', 'SMS')),
  "status" text NOT NULL DEFAULT 'UNCONFIGURED' CHECK ("status" IN ('NORMAL', 'ABNORMAL', 'UNCONFIGURED', 'DISABLED')),
  "last_success_at" timestamptz,
  "last_failure_at" timestamptz,
  "failure_count" bigint NOT NULL DEFAULT 0 CHECK ("failure_count" >= 0),
  "response_time_ms" bigint,
  "last_error" text,
  UNIQUE ("target_key", "service_type")
);

-- 统一物理日志；按kind提供各日志视图
CREATE TABLE "audit_event" (
  "id" text PRIMARY KEY NOT NULL,
  "created_at" timestamptz NOT NULL,
  "updated_at" timestamptz NOT NULL,
  "version" bigint NOT NULL DEFAULT 1 CHECK ("version" >= 1),
  "kind" text NOT NULL CHECK ("kind" IN ('LOGIN', 'AUTH', 'ACCESS', 'OPERATION', 'API', 'ERROR')),
  "event_code" text NOT NULL,
  "request_id" text NOT NULL,
  "actor_user_id" text REFERENCES "unified_user"("id") ON DELETE RESTRICT,
  "actor_kind" text NOT NULL CHECK ("actor_kind" IN ('USER', 'APPLICATION', 'SYSTEM', 'ANONYMOUS')),
  "application_id" text REFERENCES "application"("id") ON DELETE RESTRICT,
  "object_type" text,
  "object_id" text,
  "result" text NOT NULL CHECK ("result" IN ('SUCCESS', 'FAILURE', 'DENIED')),
  "summary" text NOT NULL,
  "details" jsonb NOT NULL DEFAULT '{}'::jsonb,
  "resolution_status" text CHECK ("resolution_status" IN ('OPEN', 'RESOLVED'))
);
CREATE INDEX "ix_audit_event_1" ON "audit_event" ("kind", "created_at");
CREATE INDEX "ix_audit_event_2" ON "audit_event" ("request_id");
COMMIT;
