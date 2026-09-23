-- Additive and repeatable announcement runtime persistence migration.
-- Existing announcement rows stay visible; runtime ids are backfilled for P4 fixtures.
BEGIN;

ALTER TABLE "pb3gir75kkooyea"."announcement"
 ADD COLUMN IF NOT EXISTS "runtime_id" text,
 ADD COLUMN IF NOT EXISTS "publish_mode" text CHECK ("publish_mode" IS NULL OR "publish_mode" IN ('IMMEDIATE','SCHEDULED')),
 ADD COLUMN IF NOT EXISTS "scheduled_publish_at" timestamptz,
 ADD COLUMN IF NOT EXISTS "submitted_at" timestamptz,
 ADD COLUMN IF NOT EXISTS "submitted_by" text REFERENCES "pb3gir75kkooyea"."unified_user"("id") ON DELETE RESTRICT,
 ADD COLUMN IF NOT EXISTS "withdrawn_at" timestamptz,
 ADD COLUMN IF NOT EXISTS "withdrawn_by" text REFERENCES "pb3gir75kkooyea"."unified_user"("id") ON DELETE RESTRICT,
 ADD COLUMN IF NOT EXISTS "withdrawn_reason" text,
 ADD COLUMN IF NOT EXISTS "last_edited_at" timestamptz,
 ADD COLUMN IF NOT EXISTS "last_edited_by" text REFERENCES "pb3gir75kkooyea"."unified_user"("id") ON DELETE RESTRICT,
 ADD COLUMN IF NOT EXISTS "deleted_at" timestamptz,
 ADD COLUMN IF NOT EXISTS "deleted_by" text,
 ADD COLUMN IF NOT EXISTS "delete_reason" text;

UPDATE "pb3gir75kkooyea"."announcement"
 SET "runtime_id"=CASE WHEN left("id",6)='P4FIX_' THEN 'MOCK_'||substring("id" from 7) ELSE "id" END
 WHERE "runtime_id" IS NULL;

CREATE UNIQUE INDEX IF NOT EXISTS "uq_announcement_runtime_id"
 ON "pb3gir75kkooyea"."announcement" ("runtime_id") WHERE "runtime_id" IS NOT NULL;
CREATE INDEX IF NOT EXISTS "ix_announcement_active_status"
 ON "pb3gir75kkooyea"."announcement" ("status", "published_at") WHERE "deleted_at" IS NULL;
CREATE INDEX IF NOT EXISTS "ix_announcement_schedule"
 ON "pb3gir75kkooyea"."announcement" ("scheduled_publish_at") WHERE "publish_mode"='SCHEDULED' AND "deleted_at" IS NULL;

-- Import fields that the legacy mirror kept only in P4RUN_STATE.  The joins make
-- missing/retired users resolve to NULL instead of breaking the migration.
WITH snapshot AS (
 SELECT item
 FROM "pb3gir75kkooyea"."system_config" c
 CROSS JOIN LATERAL jsonb_array_elements(coalesce(c."value"::jsonb->'announcements','[]'::jsonb)) item
 WHERE c."id"='P4RUN_STATE'
), mapped AS (
 SELECT item,'P4FIX_'||regexp_replace(item->>'id','^MOCK_','') AS physical_id,
        'P4FIX_'||regexp_replace(item->>'submittedBy','^MOCK_','') AS submitted_by_id,
        'P4FIX_'||regexp_replace(item->>'withdrawnBy','^MOCK_','') AS withdrawn_by_id,
        'P4FIX_'||regexp_replace(item->>'lastEditedBy','^MOCK_','') AS last_edited_by_id
 FROM snapshot
)
UPDATE "pb3gir75kkooyea"."announcement" a
 SET "runtime_id"=coalesce(m.item->>'id',a."runtime_id"),
     "publish_mode"=nullif(m.item->>'publishMode',''),
     "scheduled_publish_at"=nullif(m.item->>'scheduledPublishAt','')::timestamptz,
     "submitted_at"=nullif(m.item->>'submittedAt','')::timestamptz,
     "submitted_by"=su."id",
     "withdrawn_at"=nullif(m.item->>'withdrawnAt','')::timestamptz,
     "withdrawn_by"=wu."id",
     "withdrawn_reason"=nullif(m.item->>'withdrawReason',''),
     "last_edited_at"=nullif(m.item->>'lastEditedAt','')::timestamptz,
     "last_edited_by"=lu."id"
 FROM mapped m
 LEFT JOIN "pb3gir75kkooyea"."unified_user" su ON su."id"=m.submitted_by_id
 LEFT JOIN "pb3gir75kkooyea"."unified_user" wu ON wu."id"=m.withdrawn_by_id
 LEFT JOIN "pb3gir75kkooyea"."unified_user" lu ON lu."id"=m.last_edited_by_id
 WHERE a."id"=m.physical_id;

-- Older runtime versions physically removed deleted announcements and retained
-- the recoverable record only in P4RUN_STATE.announcementTrash.  Import only
-- missing rows so this compatibility step never overwrites a newer DB version.
WITH trash AS (
 SELECT item
 FROM "pb3gir75kkooyea"."system_config" c
 CROSS JOIN LATERAL jsonb_array_elements(coalesce(c."value"::jsonb->'announcementTrash','[]'::jsonb)) item
 WHERE c."id"='P4RUN_STATE'
), mapped AS (
 SELECT item,
        'P4FIX_'||regexp_replace(item->>'id','^MOCK_','') AS physical_id,
        'P4FIX_'||regexp_replace(item->>'publisherId','^MOCK_','') AS publisher_id,
        'P4FIX_'||regexp_replace(item->>'submittedBy','^MOCK_','') AS submitted_by_id,
        'P4FIX_'||regexp_replace(item->>'withdrawnBy','^MOCK_','') AS withdrawn_by_id,
        'P4FIX_'||regexp_replace(item->>'lastEditedBy','^MOCK_','') AS last_edited_by_id,
        'P4FIX_'||regexp_replace(item->>'deletedBy','^MOCK_','') AS deleted_by_id
 FROM trash
 WHERE nullif(item->>'id','') IS NOT NULL
)
INSERT INTO "pb3gir75kkooyea"."announcement"
 ("id","created_at","updated_at","version","runtime_id","title","announcement_type","content","scope","status",
  "effective_start","effective_end","publisher_id","published_at","publish_mode","scheduled_publish_at","submitted_at","submitted_by",
  "withdrawn_at","withdrawn_by","withdrawn_reason","last_edited_at","last_edited_by","deleted_at","deleted_by","delete_reason")
SELECT m.physical_id,
       coalesce(nullif(m.item->>'createdAt','')::timestamptz,now()),
       coalesce(nullif(m.item->>'updatedAt','')::timestamptz,nullif(m.item->>'deletedAt','')::timestamptz,now()),
       CASE WHEN coalesce(m.item->>'version','')~'^\d+$' AND (m.item->>'version')::bigint>=1 THEN (m.item->>'version')::bigint ELSE 1 END,
       m.item->>'id',coalesce(nullif(m.item->>'title',''),'历史公告'),coalesce(nullif(m.item->>'type',''),'通知'),coalesce(m.item->>'content',''),
       CASE WHEN m.item->>'scope' IN ('ALL','CITIZEN','GOV','ORG') THEN m.item->>'scope' ELSE 'ALL' END,
       CASE WHEN m.item->>'status' IN ('DRAFT','PUBLISHED','WITHDRAWN','EXPIRED') THEN m.item->>'status' ELSE 'WITHDRAWN' END,
       nullif(m.item->>'effectiveStart','')::timestamptz,nullif(m.item->>'effectiveEnd','')::timestamptz,pu."id",nullif(m.item->>'publishedAt','')::timestamptz,
       CASE WHEN m.item->>'publishMode' IN ('IMMEDIATE','SCHEDULED') THEN m.item->>'publishMode' ELSE NULL END,
       nullif(m.item->>'scheduledPublishAt','')::timestamptz,nullif(m.item->>'submittedAt','')::timestamptz,su."id",
       nullif(m.item->>'withdrawnAt','')::timestamptz,wu."id",nullif(m.item->>'withdrawReason',''),
       nullif(m.item->>'lastEditedAt','')::timestamptz,lu."id",
       coalesce(nullif(m.item->>'deletedAt','')::timestamptz,nullif(m.item->>'updatedAt','')::timestamptz,now()),
       CASE WHEN m.item->>'deletedBy'='SYSTEM' THEN 'SYSTEM' ELSE du."id" END,nullif(m.item->>'deleteReason','')
FROM mapped m
LEFT JOIN "pb3gir75kkooyea"."unified_user" pu ON pu."id"=m.publisher_id
LEFT JOIN "pb3gir75kkooyea"."unified_user" su ON su."id"=m.submitted_by_id
LEFT JOIN "pb3gir75kkooyea"."unified_user" wu ON wu."id"=m.withdrawn_by_id
LEFT JOIN "pb3gir75kkooyea"."unified_user" lu ON lu."id"=m.last_edited_by_id
LEFT JOIN "pb3gir75kkooyea"."unified_user" du ON du."id"=m.deleted_by_id
WHERE NOT EXISTS (
 SELECT 1 FROM "pb3gir75kkooyea"."announcement" existing
 WHERE existing."id"=m.physical_id OR existing."runtime_id"=m.item->>'id'
)
ON CONFLICT DO NOTHING;

ALTER TABLE "pb3gir75kkooyea"."announcement_attachment"
 ADD COLUMN IF NOT EXISTS "runtime_id" text;

-- Draft attachments can be saved before an announcement has a publisher.
ALTER TABLE "pb3gir75kkooyea"."announcement_attachment"
 ALTER COLUMN "uploaded_by" DROP NOT NULL;

UPDATE "pb3gir75kkooyea"."announcement_attachment"
 SET "runtime_id"=CASE WHEN left("id",6)='P4FIX_' THEN 'MOCK_'||substring("id" from 7) ELSE "id" END
 WHERE "runtime_id" IS NULL;

CREATE UNIQUE INDEX IF NOT EXISTS "uq_announcement_attachment_runtime_id"
 ON "pb3gir75kkooyea"."announcement_attachment" ("runtime_id") WHERE "runtime_id" IS NOT NULL;

WITH snapshot AS (
 SELECT announcement,file,attachment_index
 FROM "pb3gir75kkooyea"."system_config" c
 CROSS JOIN LATERAL jsonb_array_elements(
  coalesce(c."value"::jsonb->'announcements','[]'::jsonb)||coalesce(c."value"::jsonb->'announcementTrash','[]'::jsonb)
 ) announcement
 CROSS JOIN LATERAL jsonb_array_elements(coalesce(announcement->'attachments','[]'::jsonb)) WITH ORDINALITY files(file,attachment_index)
 WHERE c."id"='P4RUN_STATE'
)
INSERT INTO "pb3gir75kkooyea"."announcement_attachment"
 ("id","created_at","updated_at","version","runtime_id","announcement_id","file_name","size_bytes","mime_type","attachment","uploaded_by","sort_order")
SELECT 'P4FIX_'||regexp_replace(file->>'id','^MOCK_',''),
       coalesce(nullif(file->>'uploadedAt','')::timestamptz,a."created_at"),a."updated_at",1,file->>'id',a."id",
       coalesce(nullif(file->>'name',''),'附件'),
       CASE WHEN coalesce(file->>'size','')~'^\d+$' THEN (file->>'size')::bigint ELSE 0 END,
       coalesce(nullif(file->>'type',''),'application/octet-stream'),file,NULL,attachment_index-1
FROM snapshot s
JOIN "pb3gir75kkooyea"."announcement" a ON a."runtime_id"=s.announcement->>'id'
WHERE nullif(file->>'id','') IS NOT NULL
ON CONFLICT ("id") DO UPDATE SET
 "runtime_id"=excluded."runtime_id","announcement_id"=excluded."announcement_id","file_name"=excluded."file_name",
 "size_bytes"=excluded."size_bytes","mime_type"=excluded."mime_type","attachment"=excluded."attachment","sort_order"=excluded."sort_order","updated_at"=excluded."updated_at";

CREATE TABLE IF NOT EXISTS "pb3gir75kkooyea"."announcement_read_receipt" (
  "id" text PRIMARY KEY NOT NULL,
  "created_at" timestamptz NOT NULL,
  "updated_at" timestamptz NOT NULL,
  "version" bigint NOT NULL DEFAULT 1 CHECK ("version" >= 1),
  "announcement_id" text NOT NULL REFERENCES "pb3gir75kkooyea"."announcement"("id") ON DELETE CASCADE,
  "user_id" text NOT NULL REFERENCES "pb3gir75kkooyea"."unified_user"("id") ON DELETE CASCADE,
  "read_at" timestamptz NOT NULL,
  UNIQUE ("announcement_id", "user_id")
);

CREATE INDEX IF NOT EXISTS "ix_announcement_read_receipt_user"
 ON "pb3gir75kkooyea"."announcement_read_receipt" ("user_id", "read_at");

WITH snapshot AS (
 SELECT receipt
 FROM "pb3gir75kkooyea"."system_config" c
 CROSS JOIN LATERAL jsonb_array_elements(coalesce(c."value"::jsonb->'announcementReads','[]'::jsonb)) receipt
 WHERE c."id"='P4RUN_STATE'
)
INSERT INTO "pb3gir75kkooyea"."announcement_read_receipt"
 ("id","created_at","updated_at","version","announcement_id","user_id","read_at")
SELECT 'P4FIX_ANN_READ_'||md5((receipt->>'announcementId')||'|'||(receipt->>'userId')),
       (receipt->>'readAt')::timestamptz,(receipt->>'readAt')::timestamptz,1,a."id",u."id",(receipt->>'readAt')::timestamptz
FROM snapshot s
JOIN "pb3gir75kkooyea"."announcement" a ON a."runtime_id"=s.receipt->>'announcementId'
JOIN "pb3gir75kkooyea"."unified_user" u ON u."id"='P4FIX_'||regexp_replace(s.receipt->>'userId','^MOCK_','')
WHERE nullif(receipt->>'readAt','') IS NOT NULL
ON CONFLICT ("announcement_id","user_id") DO UPDATE SET "read_at"=excluded."read_at","updated_at"=excluded."updated_at";

COMMENT ON COLUMN "pb3gir75kkooyea"."announcement"."runtime_id" IS 'Stable portal DTO id; physical ids may retain the P4FIX prefix.';
COMMENT ON COLUMN "pb3gir75kkooyea"."announcement"."deleted_at" IS 'Soft-delete/archive timestamp; archived announcements are excluded from normal reads.';
COMMENT ON TABLE "pb3gir75kkooyea"."announcement_read_receipt" IS 'Per-user idempotent announcement read receipt.';

COMMIT;
