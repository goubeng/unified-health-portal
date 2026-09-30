-- Append-only changes in effective per-application integration status.
-- Existing snapshots are deliberately not backfilled as invented transitions.
BEGIN;

CREATE TABLE IF NOT EXISTS "pb3gir75kkooyea"."monitor_status_history" (
  id text PRIMARY KEY,
  application_id text NOT NULL,
  service_type text NOT NULL CHECK (service_type IN ('SSO','TODO','MESSAGE')),
  from_status text NOT NULL CHECK (from_status IN ('NORMAL','ABNORMAL','UNCONFIGURED','DISABLED')),
  to_status text NOT NULL CHECK (to_status IN ('NORMAL','ABNORMAL','UNCONFIGURED','DISABLED')),
  occurred_at timestamptz NOT NULL,
  reason text NOT NULL,
  source text NOT NULL CHECK (source IN ('MONITOR_OBSERVATION','CONFIGURATION','APPLICATION')),
  CHECK (from_status <> to_status)
);

CREATE INDEX IF NOT EXISTS monitor_status_history_app_time_idx
  ON "pb3gir75kkooyea"."monitor_status_history" (application_id,occurred_at DESC,id);

COMMIT;
