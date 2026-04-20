require("dotenv").config();

const express = require("express");
const cors = require("cors");
const assetsRouter = require("./routes/assets");
const db = require("./db/client");
const { logger } = require("./logger");

const app = express();
const port = Number(process.env.PORT || 3000);

app.use(cors({ origin: ["http://localhost:8080", "http://127.0.0.1:8080"], credentials: false }));
app.use(express.json());
app.use("/api", assetsRouter);

app.use((error, _req, res, _next) => {
  const statusCode = error.statusCode || 500;
  logger.error("Request failed", {
    statusCode,
    error: error.message,
    details: error.details
  });
  res.status(statusCode).json({
    error: error.message,
    details: error.details || []
  });
});

const server = app.listen(port, async () => {
  try {
    await db.getHealth();
    logger.info("API service listening", { port });
  } catch (error) {
    logger.error("Database health check failed during startup", { error: error.message });
    process.exit(1);
  }
});

async function shutdown(signal) {
  logger.info("Shutting down API service", { signal });
  server.close(async () => {
    await db.close();
    process.exit(0);
  });
}

process.on("SIGINT", () => shutdown("SIGINT"));
process.on("SIGTERM", () => shutdown("SIGTERM"));
