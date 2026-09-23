-- Reversible local demonstration reconciliation; no rows are archived by this migration.
BEGIN;
ALTER TABLE "pb3gir75kkooyea"."todo_item" ADD COLUMN IF NOT EXISTS archived_at timestamptz;
CREATE TABLE IF NOT EXISTS "pb3gir75kkooyea"."portal_demo_restore_archive" (
 archive_key text PRIMARY KEY,
 resource text NOT NULL,
 runtime_id text NOT NULL,
 original_payload jsonb NOT NULL,
 archived_at timestamptz NOT NULL DEFAULT now(),
 reason text NOT NULL,
 CHECK (jsonb_typeof(original_payload)='object')
);
COMMIT;
