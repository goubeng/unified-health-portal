-- Keep the remaining local portal entities in individually addressable rows.
-- This is a compatibility store for DTOs without dedicated physical tables yet.
BEGIN;

CREATE TABLE IF NOT EXISTS "pb3gir75kkooyea"."portal_runtime_entity_domain" (
  resource text PRIMARY KEY,
  initialized_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS "pb3gir75kkooyea"."portal_runtime_entity" (
  resource text NOT NULL REFERENCES "pb3gir75kkooyea"."portal_runtime_entity_domain"(resource) ON DELETE CASCADE,
  runtime_id text NOT NULL,
  position integer NOT NULL DEFAULT 0,
  payload jsonb NOT NULL CHECK (jsonb_typeof(payload) = 'object'),
  updated_at timestamptz NOT NULL DEFAULT now(),
  PRIMARY KEY (resource, runtime_id)
);

WITH source AS (
  SELECT c.value::jsonb AS state
  FROM "pb3gir75kkooyea"."system_config" c
  WHERE c.id = 'P4RUN_STATE'
), resources(resource) AS (
  VALUES ('users'),('roles'),('organizations'),('dictTypes'),('dictItems'),
         ('mappings'),('settings'),('integrations'),('monitorSamples'),
         ('mappingVerificationEvents'),('visits'),('receipts')
)
INSERT INTO "pb3gir75kkooyea"."portal_runtime_entity_domain"(resource)
SELECT r.resource FROM source CROSS JOIN resources r
WHERE source.state ? r.resource
ON CONFLICT (resource) DO NOTHING;

WITH source AS (
  SELECT c.value::jsonb AS state
  FROM "pb3gir75kkooyea"."system_config" c
  WHERE c.id = 'P4RUN_STATE'
), resources(resource) AS (
  VALUES ('users'),('roles'),('organizations'),('dictTypes'),('dictItems'),
         ('mappings'),('settings'),('integrations'),('monitorSamples'),
         ('mappingVerificationEvents'),('visits'),('receipts')
)
INSERT INTO "pb3gir75kkooyea"."portal_runtime_entity"(resource,runtime_id,position,payload)
SELECT r.resource,
       CASE r.resource
         WHEN 'visits' THEN md5(coalesce(item->>'userId','')||'|'||coalesce(item->>'appId','')||'|'||coalesce(item->>'at',''))
         WHEN 'receipts' THEN md5(coalesce(item->>'appId','')||'|'||coalesce(item->>'kind','MESSAGE')||'|'||coalesce(item->>'eventId',''))
         ELSE item->>'id'
       END,
       ordinal-1,item
FROM source CROSS JOIN resources r
CROSS JOIN LATERAL jsonb_array_elements(coalesce(source.state->r.resource,'[]'::jsonb)) WITH ORDINALITY entries(item,ordinal)
WHERE r.resource IN ('visits','receipts') OR nullif(item->>'id','') IS NOT NULL
ON CONFLICT (resource,runtime_id) DO NOTHING;

COMMIT;
