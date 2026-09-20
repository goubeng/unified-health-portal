-- Additive migration; never remove the previous business fields or data.
BEGIN;
ALTER TABLE "pb3gir75kkooyea"."sso_config"
 ADD COLUMN IF NOT EXISTS "enabled" text NOT NULL DEFAULT 'DISABLED' CHECK ("enabled" IN ('ENABLED','DISABLED')),
 ADD COLUMN IF NOT EXISTS "remark" text;
ALTER TABLE "pb3gir75kkooyea"."push_integration_config"
 ADD COLUMN IF NOT EXISTS "enabled" text NOT NULL DEFAULT 'DISABLED' CHECK ("enabled" IN ('ENABLED','DISABLED')),
 ADD COLUMN IF NOT EXISTS "remark" text;
COMMENT ON COLUMN "pb3gir75kkooyea"."todo_item"."priority" IS 'Legacy compatibility field; hidden from portal UI and public PUSH contract; not used for cross-application ranking.';
COMMIT;
