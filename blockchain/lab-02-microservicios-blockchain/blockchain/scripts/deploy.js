const hre = require("hardhat");
const fs = require("fs");
const path = require("path");

async function deploy() {
  const { ethers } = hre;
  const [deployer, ...rest] = await ethers.getSigners();

  console.log("[DEPLOY] Deploying AssetRegistry with account:", deployer.address);

  const factory = await ethers.getContractFactory("AssetRegistry");
  const contract = await factory.deploy();
  await contract.waitForDeployment();

  const address = await contract.getAddress();
  const artifactPath = path.join(
    __dirname,
    "..",
    "artifacts",
    "contracts",
    "AssetRegistry.sol",
    "AssetRegistry.json"
  );
  const deploymentPath = path.join(__dirname, "..", "deployments", "contract-address.json");
  const deploymentTmpPath = `${deploymentPath}.tmp`;
  const artifact = JSON.parse(fs.readFileSync(artifactPath, "utf8"));
  const accounts = [deployer, ...rest].slice(0, 5).map((signer) => signer.address);

  fs.mkdirSync(path.dirname(deploymentPath), { recursive: true });
  fs.writeFileSync(
    deploymentTmpPath,
    JSON.stringify(
      {
        address,
        abi: artifact.abi,
        deployerAddress: deployer.address,
        accounts
      },
      null,
      2
    )
  );
  fs.renameSync(deploymentTmpPath, deploymentPath);

  console.log("[DEPLOY] AssetRegistry deployed at:", address);
  console.log("[DEPLOY] Contract info written to deployments/contract-address.json");
}

deploy().catch((error) => {
  console.error("[DEPLOY] Failed to deploy AssetRegistry", error);
  process.exitCode = 1;
});
