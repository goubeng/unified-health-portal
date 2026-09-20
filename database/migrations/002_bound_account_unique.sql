-- PostgreSQL 14; existing installations only. No table or field changes.
-- Fresh installs already receive this index through schema.sql OR 001_initial.sql.
-- Run once against the verified native storage table. Resolve physical names first.
-- Duplicate BOUND accounts abort this transaction; never delete or unbind automatically.
-- Do not use IF NOT EXISTS: an existing same-name index must be verified, not silently accepted.
BEGIN;
CREATE UNIQUE INDEX "uq_mapping_bound_account" ON "application_user_mapping" ("application_id", "external_user_id") WHERE status = 'BOUND';
COMMIT;
