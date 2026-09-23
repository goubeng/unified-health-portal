-- 007: message/todo runtime fields. Run only after a scoped backup and before enabling normalized reads.
BEGIN;
ALTER TABLE "pb3gir75kkooyea"."todo_item" ADD COLUMN IF NOT EXISTS "runtime_id" text;
ALTER TABLE "pb3gir75kkooyea"."todo_item" ADD COLUMN IF NOT EXISTS "received_at" timestamptz;
ALTER TABLE "pb3gir75kkooyea"."message" ADD COLUMN IF NOT EXISTS "runtime_id" text;
ALTER TABLE "pb3gir75kkooyea"."message" ADD COLUMN IF NOT EXISTS "received_at" timestamptz;
ALTER TABLE "pb3gir75kkooyea"."message_recipient" ADD COLUMN IF NOT EXISTS "received_at" timestamptz;
ALTER TABLE "pb3gir75kkooyea"."message_recipient" ADD COLUMN IF NOT EXISTS "deleted_at" timestamptz;

-- Existing mirrored rows already have stable P4FIX physical IDs. Import only missing DTO metadata.
WITH snapshot AS (
 SELECT value::jsonb AS state FROM "pb3gir75kkooyea"."system_config" WHERE id='P4RUN_STATE'
), items AS (
 SELECT x FROM snapshot, LATERAL jsonb_array_elements(coalesce(state->'todos','[]'::jsonb)) AS x
)
UPDATE "pb3gir75kkooyea"."todo_item" t
SET runtime_id=coalesce(t.runtime_id,items.x->>'id'),
    received_at=coalesce(t.received_at,nullif(items.x->>'receivedAt','')::timestamptz,t.created_at)
FROM items WHERE t.id='P4FIX_'||regexp_replace(items.x->>'id','^(MOCK_|P4FIX_)','');

WITH snapshot AS (
 SELECT value::jsonb AS state FROM "pb3gir75kkooyea"."system_config" WHERE id='P4RUN_STATE'
), items AS (
 SELECT x FROM snapshot, LATERAL jsonb_array_elements(coalesce(state->'messages','[]'::jsonb)) AS x
)
UPDATE "pb3gir75kkooyea"."message" m
SET runtime_id=coalesce(m.runtime_id,items.x->>'id'),
    received_at=coalesce(m.received_at,nullif(items.x->>'receivedAt','')::timestamptz,m.created_at)
FROM items WHERE m.id='P4FIX_'||regexp_replace(items.x->>'id','^(MOCK_|P4FIX_)','');

WITH snapshot AS (
 SELECT value::jsonb AS state FROM "pb3gir75kkooyea"."system_config" WHERE id='P4RUN_STATE'
), items AS (
 SELECT x FROM snapshot, LATERAL jsonb_array_elements(coalesce(state->'messages','[]'::jsonb)) AS x
)
UPDATE "pb3gir75kkooyea"."message_recipient" r
SET received_at=coalesce(r.received_at,nullif(items.x->>'receivedAt','')::timestamptz,r.created_at),
    deleted_at=coalesce(r.deleted_at,CASE WHEN items.x->>'deleted'='true' THEN nullif(items.x->>'deletedAt','')::timestamptz END)
FROM items
WHERE r.message_id='P4FIX_'||regexp_replace(items.x->>'id','^(MOCK_|P4FIX_)','')
  AND r.user_id='P4FIX_'||regexp_replace(items.x->>'userId','^(MOCK_|P4FIX_)','');

UPDATE "pb3gir75kkooyea"."todo_item" SET runtime_id='MOCK_'||substr(id,7),received_at=coalesce(received_at,created_at) WHERE runtime_id IS NULL OR received_at IS NULL;
UPDATE "pb3gir75kkooyea"."message" SET runtime_id='MOCK_'||substr(id,7),received_at=coalesce(received_at,created_at) WHERE runtime_id IS NULL OR received_at IS NULL;
UPDATE "pb3gir75kkooyea"."message_recipient" SET received_at=coalesce(received_at,created_at) WHERE received_at IS NULL;

CREATE UNIQUE INDEX IF NOT EXISTS "ix_p4_todo_runtime_id" ON "pb3gir75kkooyea"."todo_item"("runtime_id");
CREATE UNIQUE INDEX IF NOT EXISTS "ix_p4_message_runtime_id" ON "pb3gir75kkooyea"."message"("runtime_id");
COMMIT;
