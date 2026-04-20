const { Pool } = require("pg");

const connectionString = process.env.DB_URL;

if (!connectionString) {
  throw new Error("DB_URL is required");
}

const pool = new Pool({
  connectionString,
  max: 10,
  idleTimeoutMillis: 30000
});

async function query(text, params) {
  return pool.query(text, params);
}

async function getHealth() {
  await pool.query("SELECT 1");
}

async function close() {
  await pool.end();
}

module.exports = {
  pool,
  query,
  getHealth,
  close
};
