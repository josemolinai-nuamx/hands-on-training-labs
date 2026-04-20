const { randomUUID } = require("crypto");
const { ethers } = require("ethers");
const db = require("../db/client");
const { getSignerAddress, sendTransfer } = require("./blockchain");

function validateTransferPayload(payload) {
  const errors = [];
  const assetId = typeof payload.assetId === "string" ? payload.assetId.trim() : "";
  const to = typeof payload.to === "string" ? payload.to.trim() : "";

  if (!assetId) {
    errors.push("assetId is required");
  }

  if (!to) {
    errors.push("to is required");
  } else if (!ethers.isAddress(to)) {
    errors.push("to must be a valid Ethereum address");
  }

  return {
    errors,
    value: { assetId, to }
  };
}

async function createPendingTransfer(assetId, to, fromAddress) {
  const transferId = randomUUID();
  await db.query(
    `
      INSERT INTO transfers (id, asset_id, from_address, to_address, status)
      VALUES ($1, $2, $3, $4, 'PENDING')
    `,
    [transferId, assetId, fromAddress, to]
  );
  return transferId;
}

async function markTransferSent(transferId, txHash) {
  await db.query(
    `
      UPDATE transfers
      SET tx_hash = $2, error_message = NULL
      WHERE id = $1
    `,
    [transferId, txHash]
  );
}

async function markTransferFailed(transferId, message) {
  await db.query(
    `
      UPDATE transfers
      SET status = 'FAILED', error_message = $2
      WHERE id = $1
    `,
    [transferId, message]
  );
}

async function createTransfer(payload) {
  const { errors, value } = validateTransferPayload(payload);
  if (errors.length > 0) {
    const error = new Error("Validation failed");
    error.statusCode = 400;
    error.details = errors;
    throw error;
  }

  const fromAddress = await getSignerAddress();
  const transferId = await createPendingTransfer(value.assetId, value.to, fromAddress);

  try {
    const txHash = await sendTransfer(value.assetId, value.to);
    await markTransferSent(transferId, txHash);

    return {
      transferId,
      txHash,
      status: "PENDING"
    };
  } catch (error) {
    await markTransferFailed(transferId, error.message);
    error.statusCode = 502;
    throw error;
  }
}

async function listTransfers() {
  const result = await db.query(
    `
      SELECT id, asset_id, from_address, to_address, tx_hash, status, error_message,
             block_number, created_at, confirmed_at
      FROM transfers
      ORDER BY created_at DESC
    `
  );
  return result.rows;
}

async function getTransferById(transferId) {
  const result = await db.query(
    `
      SELECT id, asset_id, from_address, to_address, tx_hash, status, error_message,
             block_number, created_at, confirmed_at
      FROM transfers
      WHERE id = $1
    `,
    [transferId]
  );

  return result.rows[0] || null;
}

module.exports = {
  createTransfer,
  listTransfers,
  getTransferById,
  validateTransferPayload
};
