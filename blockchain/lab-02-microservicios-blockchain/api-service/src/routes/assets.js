const express = require("express");
const db = require("../db/client");
const { logger } = require("../logger");
const { createTransfer, listTransfers, getTransferById } = require("../services/transfer");

const router = express.Router();

router.post("/transfer", async (req, res, next) => {
  try {
    const result = await createTransfer(req.body || {});
    logger.info("Transfer created", result);
    res.status(202).json(result);
  } catch (error) {
    next(error);
  }
});

router.get("/transfers", async (_req, res, next) => {
  try {
    const rows = await listTransfers();
    res.json(rows);
  } catch (error) {
    next(error);
  }
});

router.get("/transfers/:id", async (req, res, next) => {
  try {
    const row = await getTransferById(req.params.id);
    if (!row) {
      res.status(404).json({ error: "Transfer not found" });
      return;
    }

    res.json(row);
  } catch (error) {
    next(error);
  }
});

router.get("/health", async (_req, res, next) => {
  try {
    await db.getHealth();
    res.json({ status: "ok" });
  } catch (error) {
    next(error);
  }
});

module.exports = router;
