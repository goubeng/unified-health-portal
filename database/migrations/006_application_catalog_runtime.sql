-- Application catalog persistence. Safe to run repeatedly after the P4 snapshot exists.
BEGIN;

ALTER TABLE "pb3gir75kkooyea"."application_category"
 ADD COLUMN IF NOT EXISTS "runtime_id" text,
 ADD COLUMN IF NOT EXISTS "runtime_payload" jsonb,
 ADD COLUMN IF NOT EXISTS "deleted_at" timestamptz;

ALTER TABLE "pb3gir75kkooyea"."application"
 ADD COLUMN IF NOT EXISTS "runtime_id" text,
 ADD COLUMN IF NOT EXISTS "runtime_payload" jsonb,
 ADD COLUMN IF NOT EXISTS "deleted_at" timestamptz;

UPDATE "pb3gir75kkooyea"."application_category"
 SET "runtime_id"='MOCK_'||substring("id" from 7)
 WHERE "runtime_id" IS NULL AND left("id",6)='P4FIX_';
UPDATE "pb3gir75kkooyea"."application"
 SET "runtime_id"='MOCK_'||substring("id" from 7)
 WHERE "runtime_id" IS NULL AND left("id",6)='P4FIX_';

WITH snapshot AS (
 SELECT item FROM "pb3gir75kkooyea"."system_config" c
 CROSS JOIN LATERAL jsonb_array_elements(coalesce(c."value"::jsonb->'categories','[]'::jsonb)) item
 WHERE c."id"='P4RUN_STATE'
)
UPDATE "pb3gir75kkooyea"."application_category" c
 SET "runtime_payload"=s.item
 FROM snapshot s
 WHERE c."runtime_id"=s.item->>'id' AND c."runtime_payload" IS NULL;

WITH snapshot AS (
 SELECT item FROM "pb3gir75kkooyea"."system_config" c
 CROSS JOIN LATERAL jsonb_array_elements(coalesce(c."value"::jsonb->'apps','[]'::jsonb)) item
 WHERE c."id"='P4RUN_STATE'
)
UPDATE "pb3gir75kkooyea"."application" a
 SET "runtime_payload"=s.item
 FROM snapshot s
 WHERE a."runtime_id"=s.item->>'id' AND a."runtime_payload" IS NULL;

CREATE UNIQUE INDEX IF NOT EXISTS "uq_application_category_runtime_id"
 ON "pb3gir75kkooyea"."application_category" ("runtime_id") WHERE "runtime_id" IS NOT NULL;
CREATE UNIQUE INDEX IF NOT EXISTS "uq_application_runtime_id"
 ON "pb3gir75kkooyea"."application" ("runtime_id") WHERE "runtime_id" IS NOT NULL;
CREATE INDEX IF NOT EXISTS "ix_application_catalog_active"
 ON "pb3gir75kkooyea"."application" ("sort_order","id") WHERE "deleted_at" IS NULL;

COMMENT ON COLUMN "pb3gir75kkooyea"."application"."runtime_payload" IS 'Portal catalog display and local demonstration fields; normalized columns remain authoritative.';
COMMENT ON COLUMN "pb3gir75kkooyea"."application"."deleted_at" IS 'Logical deletion retains application foreign-key history.';
COMMIT;
