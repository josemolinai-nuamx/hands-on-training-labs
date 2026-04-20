require("dotenv").config();

const db = require("./db/client");
const { logger } = require("./logger");
const { startListener } = require("./listener");

const DB_RETRY_DELAY_MS = 2000;
const DB_MAX_RETRIES = 10;

let runtime;

function sleep(ms) {
  return new Promise((resolve) => setTimeout(resolve, ms));
}

async function waitForDatabase(retriesLeft = DB_MAX_RETRIES) {
  try {
    await db.getHealth();
  } catch (error) {
    if (retriesLeft <= 0) {
      throw new Error(`Database did not become ready: ${error.message}`);
    }

    logger.warn("Database not ready yet", {
      retriesLeft,
      error: error.message
    });
    await sleep(DB_RETRY_DELAY_MS);
    await waitForDatabase(retriesLeft - 1);
  }
}

async function main() {
  try {
    await waitForDatabase();
    runtime = await startListener();
  } catch (error) {
    logger.error("Listener startup failed", { error: error.message });
    process.exit(1);
  }
}

async function shutdown(signal) {
  logger.info("Shutting down event listener", { signal });
  if (runtime?.contract) {
    runtime.contract.removeAllListeners();
  }
  if (runtime?.provider) {
    await runtime.provider.destroy();
  }
  await db.close();
  process.exit(0);
}

process.on("SIGINT", () => shutdown("SIGINT"));
process.on("SIGTERM", () => shutdown("SIGTERM"));

main();
