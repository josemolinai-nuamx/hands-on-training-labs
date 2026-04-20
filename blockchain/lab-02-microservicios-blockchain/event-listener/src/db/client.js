const { Pool } = require("pg");

const pool = new Pool({
  connectionString: process.env.DB_URL,
  max: 10,
  idleTimeoutMillis: 30000
});

async function confirmTransfer(txHash, blockNumber) {
  return pool.query(
    `
      UPDATE transfers
      SET status = 'CONFIRMED', block_number = $2, confirmed_at = NOW(), error_message = NULL
      WHERE tx_hash = $1
    `,
    [txHash, blockNumber]
  );
}

async function getHealth() {
  await pool.query("SELECT 1");
}

async function close() {
  await pool.end();
}

module.exports = {
  confirmTransfer,
  getHealth,
  close
};
