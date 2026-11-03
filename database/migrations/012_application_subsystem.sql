-- Seven integrated systems from the source catalog. Row 42 was struck through;
-- the retained row 43 belongs to subsystem 7.
BEGIN;

CREATE TABLE IF NOT EXISTS "pb3gir75kkooyea"."application_subsystem" (
  id text PRIMARY KEY,
  source_no integer NOT NULL UNIQUE CHECK (source_no BETWEEN 1 AND 7),
  name text NOT NULL
);

INSERT INTO "pb3gir75kkooyea"."application_subsystem" (id,source_no,name) VALUES
  ('MOCK_PLATFORM_1',1,'福建省全民健康信息平台'),
  ('MOCK_PLATFORM_2',2,'福建省全员人口计划生育服务与管理平台'),
  ('MOCK_PLATFORM_3',3,'福建省卫健委综合监管平台'),
  ('MOCK_PLATFORM_4',4,'福建省保健对象医疗管理信息系统'),
  ('MOCK_PLATFORM_5',5,'省职控制中心门户网站'),
  ('MOCK_PLATFORM_6',6,'省卫监所综合管理系统'),
  ('MOCK_PLATFORM_7',7,'省疾控中心综合管理系统')
ON CONFLICT (id) DO NOTHING;

ALTER TABLE "pb3gir75kkooyea"."application"
  ADD COLUMN IF NOT EXISTS platform_id text;

DO $$ BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint
    WHERE conname='application_platform_id_fk'
      AND conrelid='"pb3gir75kkooyea"."application"'::regclass
  ) THEN
    ALTER TABLE "pb3gir75kkooyea"."application"
      ADD CONSTRAINT application_platform_id_fk
      FOREIGN KEY (platform_id)
      REFERENCES "pb3gir75kkooyea"."application_subsystem"(id)
      ON DELETE RESTRICT;
  END IF;
END $$;

WITH source_map AS (
  SELECT n,
    CASE
      WHEN n <= 13 THEN 'MOCK_PLATFORM_1'
      WHEN n <= 17 THEN 'MOCK_PLATFORM_2'
      WHEN n <= 31 THEN 'MOCK_PLATFORM_3'
      WHEN n = 32 THEN 'MOCK_PLATFORM_4'
      WHEN n = 33 THEN 'MOCK_PLATFORM_5'
      WHEN n <= 38 THEN 'MOCK_PLATFORM_6'
      ELSE 'MOCK_PLATFORM_7'
    END AS platform_id
  FROM generate_series(1,43) AS n
  WHERE n <> 42
)
UPDATE "pb3gir75kkooyea"."application" a
SET platform_id=m.platform_id
FROM source_map m
WHERE a.code='P4FIX_WJ_APP_'||lpad(m.n::text,2,'0')
  AND a.platform_id IS NULL
  AND a.deleted_at IS NULL;

CREATE INDEX IF NOT EXISTS application_platform_id_idx
  ON "pb3gir75kkooyea"."application" (platform_id)
  WHERE deleted_at IS NULL;

COMMENT ON COLUMN "pb3gir75kkooyea"."application".platform_id IS
  'Integrated parent subsystem; separate from application category.';

COMMIT;
