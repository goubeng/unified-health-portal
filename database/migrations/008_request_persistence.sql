-- Portal application access and account opening workflow; safe to rerun.
BEGIN;

CREATE TABLE IF NOT EXISTS "pb3gir75kkooyea"."application_access_request" (
  "id" text PRIMARY KEY,
  "runtime_id" text NOT NULL UNIQUE,
  "created_at" timestamptz NOT NULL,
  "updated_at" timestamptz NOT NULL,
  "version" bigint NOT NULL CHECK ("version" >= 1),
  "request_no" text NOT NULL UNIQUE,
  "user_id" text NOT NULL REFERENCES "pb3gir75kkooyea"."unified_user"("id") ON DELETE RESTRICT,
  "application_id" text NOT NULL REFERENCES "pb3gir75kkooyea"."application"("id") ON DELETE RESTRICT,
  "reason" text NOT NULL,
  "contact" text NOT NULL DEFAULT '',
  "remark" text NOT NULL DEFAULT '',
  "status" text NOT NULL CHECK ("status" IN ('PENDING','APPROVED','REJECTED','WITHDRAWN','EXPIRED')),
  "submitted_at" timestamptz NOT NULL,
  "reviewed_by" text REFERENCES "pb3gir75kkooyea"."unified_user"("id") ON DELETE RESTRICT,
  "reviewed_at" timestamptz,
  "review_note" text,
  "withdrawn_at" timestamptz,
  "expired_at" timestamptz
);
CREATE INDEX IF NOT EXISTS "ix_access_request_user_app" ON "pb3gir75kkooyea"."application_access_request" ("user_id","application_id","submitted_at" DESC);
CREATE UNIQUE INDEX IF NOT EXISTS "uq_access_request_pending" ON "pb3gir75kkooyea"."application_access_request" ("user_id","application_id") WHERE "status"='PENDING';

CREATE TABLE IF NOT EXISTS "pb3gir75kkooyea"."application_access_grant" (
  "id" text PRIMARY KEY,
  "runtime_id" text NOT NULL UNIQUE,
  "created_at" timestamptz NOT NULL,
  "updated_at" timestamptz NOT NULL,
  "version" bigint NOT NULL CHECK ("version" >= 1),
  "user_id" text NOT NULL REFERENCES "pb3gir75kkooyea"."unified_user"("id") ON DELETE RESTRICT,
  "application_id" text NOT NULL REFERENCES "pb3gir75kkooyea"."application"("id") ON DELETE RESTRICT,
  "status" text NOT NULL CHECK ("status" IN ('ACTIVE','REVOKED','EXPIRED')),
  "granted_by" text REFERENCES "pb3gir75kkooyea"."unified_user"("id") ON DELETE RESTRICT,
  "granted_at" timestamptz,
  "expires_at" timestamptz
);
CREATE UNIQUE INDEX IF NOT EXISTS "uq_access_grant_active" ON "pb3gir75kkooyea"."application_access_grant" ("user_id","application_id") WHERE "status"='ACTIVE';

CREATE TABLE IF NOT EXISTS "pb3gir75kkooyea"."account_opening_request" (
  "id" text PRIMARY KEY,
  "runtime_id" text NOT NULL UNIQUE,
  "created_at" timestamptz NOT NULL,
  "updated_at" timestamptz NOT NULL,
  "version" bigint NOT NULL CHECK ("version" >= 1),
  "request_no" text NOT NULL UNIQUE,
  "user_id" text NOT NULL REFERENCES "pb3gir75kkooyea"."unified_user"("id") ON DELETE RESTRICT,
  "application_id" text NOT NULL REFERENCES "pb3gir75kkooyea"."application"("id") ON DELETE RESTRICT,
  "reason" text NOT NULL,
  "contact" text NOT NULL DEFAULT '',
  "remark" text NOT NULL DEFAULT '',
  "status" text NOT NULL CHECK ("status" IN ('PENDING','PROCESSING','COMPLETED','REJECTED','CANCELLED')),
  "submitted_at" timestamptz NOT NULL,
  "handled_by" text REFERENCES "pb3gir75kkooyea"."unified_user"("id") ON DELETE RESTRICT,
  "handled_at" timestamptz,
  "handle_note" text
);
CREATE INDEX IF NOT EXISTS "ix_opening_request_user_app" ON "pb3gir75kkooyea"."account_opening_request" ("user_id","application_id","submitted_at" DESC);
CREATE UNIQUE INDEX IF NOT EXISTS "uq_opening_request_open" ON "pb3gir75kkooyea"."account_opening_request" ("user_id","application_id") WHERE "status" IN ('PENDING','PROCESSING');

-- Import only rows backed by known local users and applications. Never overwrite a
-- newer normalized record with an old P4RUN_STATE snapshot on a repeated run.
WITH snapshot AS (
 SELECT item FROM "pb3gir75kkooyea"."system_config" c
 CROSS JOIN LATERAL jsonb_array_elements(coalesce(c."value"::jsonb->'applicationRequests','[]'::jsonb)) item
 WHERE c."id"='P4RUN_STATE'
)
INSERT INTO "pb3gir75kkooyea"."application_access_request"
 ("id","runtime_id","created_at","updated_at","version","request_no","user_id","application_id","reason","contact","remark","status","submitted_at","reviewed_by","reviewed_at","review_note","withdrawn_at","expired_at")
SELECT 'P4FIX_'||regexp_replace(s.item->>'id','^MOCK_',''),s.item->>'id',
 nullif(s.item->>'createdAt','')::timestamptz,nullif(s.item->>'updatedAt','')::timestamptz,
 coalesce(nullif(s.item->>'version','')::bigint,1),s.item->>'requestNo',u.id,a.id,
 coalesce(s.item->>'reason',''),coalesce(s.item->>'contact',''),coalesce(s.item->>'remark',''),s.item->>'status',
 coalesce(nullif(s.item->>'submittedAt','')::timestamptz,nullif(s.item->>'createdAt','')::timestamptz),
 reviewer.id,nullif(s.item->>'reviewedAt','')::timestamptz,s.item->>'reviewNote',
 nullif(s.item->>'withdrawnAt','')::timestamptz,nullif(s.item->>'expiredAt','')::timestamptz
FROM snapshot s
JOIN "pb3gir75kkooyea"."unified_user" u ON u.id='P4FIX_'||regexp_replace(s.item->>'userId','^MOCK_','')
JOIN "pb3gir75kkooyea"."application" a ON a.id='P4FIX_'||regexp_replace(s.item->>'appId','^MOCK_','')
LEFT JOIN "pb3gir75kkooyea"."unified_user" reviewer ON reviewer.id='P4FIX_'||regexp_replace(s.item->>'reviewedBy','^MOCK_','')
WHERE s.item->>'id' IS NOT NULL AND s.item->>'requestNo' IS NOT NULL
ON CONFLICT DO NOTHING;

WITH snapshot AS (
 SELECT item FROM "pb3gir75kkooyea"."system_config" c
 CROSS JOIN LATERAL jsonb_array_elements(coalesce(c."value"::jsonb->'applicationGrants','[]'::jsonb)) item
 WHERE c."id"='P4RUN_STATE'
)
INSERT INTO "pb3gir75kkooyea"."application_access_grant"
 ("id","runtime_id","created_at","updated_at","version","user_id","application_id","status","granted_by","granted_at","expires_at")
SELECT 'P4FIX_'||regexp_replace(s.item->>'id','^MOCK_',''),s.item->>'id',
 nullif(s.item->>'createdAt','')::timestamptz,nullif(s.item->>'updatedAt','')::timestamptz,
 coalesce(nullif(s.item->>'version','')::bigint,1),u.id,a.id,s.item->>'status',grantor.id,
 nullif(s.item->>'grantedAt','')::timestamptz,nullif(s.item->>'expiresAt','')::timestamptz
FROM snapshot s
JOIN "pb3gir75kkooyea"."unified_user" u ON u.id='P4FIX_'||regexp_replace(s.item->>'userId','^MOCK_','')
JOIN "pb3gir75kkooyea"."application" a ON a.id='P4FIX_'||regexp_replace(s.item->>'appId','^MOCK_','')
LEFT JOIN "pb3gir75kkooyea"."unified_user" grantor ON grantor.id='P4FIX_'||regexp_replace(s.item->>'grantedBy','^MOCK_','')
WHERE s.item->>'id' IS NOT NULL
ON CONFLICT DO NOTHING;

WITH snapshot AS (
 SELECT item FROM "pb3gir75kkooyea"."system_config" c
 CROSS JOIN LATERAL jsonb_array_elements(coalesce(c."value"::jsonb->'accountOpeningRequests','[]'::jsonb)) item
 WHERE c."id"='P4RUN_STATE'
)
INSERT INTO "pb3gir75kkooyea"."account_opening_request"
 ("id","runtime_id","created_at","updated_at","version","request_no","user_id","application_id","reason","contact","remark","status","submitted_at","handled_by","handled_at","handle_note")
SELECT 'P4FIX_'||regexp_replace(s.item->>'id','^MOCK_',''),s.item->>'id',
 nullif(s.item->>'createdAt','')::timestamptz,nullif(s.item->>'updatedAt','')::timestamptz,
 coalesce(nullif(s.item->>'version','')::bigint,1),s.item->>'requestNo',u.id,a.id,
 coalesce(s.item->>'reason',''),coalesce(s.item->>'contact',''),coalesce(s.item->>'remark',''),s.item->>'status',
 coalesce(nullif(s.item->>'submittedAt','')::timestamptz,nullif(s.item->>'createdAt','')::timestamptz),
 handler.id,nullif(s.item->>'handledAt','')::timestamptz,s.item->>'handleNote'
FROM snapshot s
JOIN "pb3gir75kkooyea"."unified_user" u ON u.id='P4FIX_'||regexp_replace(s.item->>'userId','^MOCK_','')
JOIN "pb3gir75kkooyea"."application" a ON a.id='P4FIX_'||regexp_replace(s.item->>'appId','^MOCK_','')
LEFT JOIN "pb3gir75kkooyea"."unified_user" handler ON handler.id='P4FIX_'||regexp_replace(s.item->>'handledBy','^MOCK_','')
WHERE s.item->>'id' IS NOT NULL AND s.item->>'requestNo' IS NOT NULL
ON CONFLICT DO NOTHING;

COMMIT;
