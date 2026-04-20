const fs = require("fs/promises");
const { ethers } = require("ethers");
const db = require("./db/client");
const { logger } = require("./logger");

const RETRY_DELAY_MS = 2000;
const MAX_RETRIES = 10;

function sleep(ms) {
  return new Promise((resolve) => setTimeout(resolve, ms));
}

async function readDeploymentFile(filePath, retriesLeft = MAX_RETRIES) {
  try {
    const raw = await fs.readFile(filePath, "utf8");
    return JSON.parse(raw);
  } catch (error) {
    if (retriesLeft <= 0) {
      throw new Error(`Failed to read deployment file at ${filePath}: ${error.message}`);
    }

    logger.warn("Deployment file not ready yet", { filePath, retriesLeft, error: error.message });
    await sleep(RETRY_DELAY_MS);
    return readDeploymentFile(filePath, retriesLeft - 1);
  }
}

async function startListener() {
  const deployment = await readDeploymentFile(process.env.CONTRACT_ADDRESS_FILE);
  const provider = new ethers.JsonRpcProvider(process.env.RPC_URL, undefined, {
    polling: true,
    pollingInterval: Number(process.env.POLLING_INTERVAL_MS || 1000)
  });
  const contract = new ethers.Contract(deployment.address, deployment.abi, provider);

  contract.on("AssetTransferred", async (from, to, assetId, timestamp, payload) => {
    const txHash = payload.log.transactionHash;
    const blockNumber = payload.log.blockNumber;

    try {
      const result = await db.confirmTransfer(txHash, blockNumber);
      if (result.rowCount === 0) {
        logger.warn("Received event without matching transfer", {
          assetId,
          txHash,
          blockNumber,
          from,
          to,
          timestamp: timestamp.toString()
        });
        return;
      }

      logger.info("AssetTransferred event processed", {
        assetId,
        txHash,
        blockNumber,
        from,
        to,
        timestamp: timestamp.toString()
      });
    } catch (error) {
      logger.error("Failed to confirm transfer from event", {
        assetId,
        txHash,
        blockNumber,
        error: error.message
      });
    }
  });

  provider.on("error", (error) => {
    logger.error("Provider error", { error: error.message });
  });

  logger.info("Event listener subscribed", {
    contractAddress: deployment.address,
    rpcUrl: process.env.RPC_URL
  });

  return { provider, contract };
}

module.exports = { startListener };
