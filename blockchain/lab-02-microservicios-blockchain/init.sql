CREATE EXTENSION IF NOT EXISTS pgcrypto;

CREATE TABLE IF NOT EXISTS transfers (
  id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  asset_id      VARCHAR(100) NOT NULL,
  from_address  VARCHAR(42) NOT NULL,
  to_address    VARCHAR(42) NOT NULL,
  tx_hash       VARCHAR(66),
  status        VARCHAR(20) NOT NULL DEFAULT 'PENDING',
  error_message TEXT,
  block_number  INTEGER,
  created_at    TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  confirmed_at  TIMESTAMPTZ,
  CONSTRAINT transfers_status_check CHECK (status IN ('PENDING', 'CONFIRMED', 'FAILED'))
);

CREATE INDEX IF NOT EXISTS idx_transfers_status ON transfers(status);
CREATE INDEX IF NOT EXISTS idx_transfers_tx_hash ON transfers(tx_hash);
CREATE INDEX IF NOT EXISTS idx_transfers_asset_id ON transfers(asset_id);
