const fs = require("fs/promises");
const { ethers } = require("ethers");

const RETRY_DELAY_MS = 2000;
const MAX_RETRIES = 10;

let contractStatePromise;

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
    await sleep(RETRY_DELAY_MS);
    return readDeploymentFile(filePath, retriesLeft - 1);
  }
}

async function buildState() {
  const rpcUrl = process.env.RPC_URL;
  const privateKey = process.env.SIGNER_PRIVATE_KEY;
  const deploymentFile = process.env.CONTRACT_ADDRESS_FILE;

  if (!rpcUrl || !privateKey || !deploymentFile) {
    throw new Error("RPC_URL, SIGNER_PRIVATE_KEY and CONTRACT_ADDRESS_FILE are required");
  }

  const deployment = await readDeploymentFile(deploymentFile);
  const provider = new ethers.JsonRpcProvider(rpcUrl);
  const wallet = new ethers.Wallet(privateKey, provider);
  const contract = new ethers.Contract(deployment.address, deployment.abi, wallet);

  return {
    provider,
    wallet,
    contract,
    deployment
  };
}

async function getBlockchainState() {
  if (!contractStatePromise) {
    contractStatePromise = buildState().catch((error) => {
      contractStatePromise = undefined;
      throw error;
    });
  }

  return contractStatePromise;
}

async function getSignerAddress() {
  const { wallet } = await getBlockchainState();
  return wallet.address;
}

async function sendTransfer(assetId, to) {
  const { contract } = await getBlockchainState();
  const transferMethod = contract.getFunction("transfer");
  const tx = await transferMethod(to, assetId);
  return tx.hash;
}

module.exports = {
  getBlockchainState,
  getSignerAddress,
  sendTransfer
};
