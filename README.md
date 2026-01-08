# 🏓 PingPong CCIP

A simple yet powerful cross-chain messaging project built with **Chainlink CCIP**, enabling automated "Ping-Pong" communication between **Ethereum Sepolia** and **Arbitrum Sepolia**.

---

## 🚀 Features

* **Cross-Chain Ping:** Users can trigger the `ping` function on the source chain, which sends a secure data message to the destination chain via CCIP.
* **Automated Pong Response:** Once the message arrives, the destination contract's internal logic (`_ccipReceive`) automatically triggers a "pong" response back to the source chain.
* **Reliable Testing:** Fully verified using Foundry's multi-fork testing environment to ensure robust cross-chain logic.

---

## 🛠 Setup

### 1. Environment Variables
Create a `.env` file in your root directory and fill in the following details.

> [!WARNING]
> **DO NOT USE YOUR MAIN WALLET.** Always use a dedicated testnet wallet for development.

```env
# RPC URLs (Alchemy, Infura, etc.)
SEPOLIA_RPC_URL=your_sepolia_rpc_url
ARB_SEPOLIA_RPC_URL=your_arb_sepolia_rpc_url

# Wallet Access
SEPOLIA_PRIVATE_KEY=your_private_key
ARB_SEPOLIA_PRIVATE_KEY=your_private_key

# Contract Addresses (Update after deployment)
SEPOLIA_PINGPONG_ADDRESS=0x...
ARB_SEPOLIA_PINGPONG_ADDRESS=0x...

# Explorer API Keys (for verification)
ETHERSCAN_API_KEY=your_etherscan_key
```

### 2.installation

```
forge install
```

## 📦 Deployment & Interaction

### Step 1: Deploy Contracts
Deploy the `PingPong` contract to both networks. After deployment, make sure to update the addresses in your `.env`file.

```
# Deploy to Ethereum Sepolia
forge script script/DeployPingPong.s.sol --rpc-url $SEPOLIA_RPC_URL --broadcast

# Deploy to Arbitrum Sepolia
forge script script/DeployPingPong.s.sol --rpc-url $ARB_SEPOLIA_RPC_URL --broadcast
```

### Step 2: Send Ping
Execute the interaction script to start the cross-chain message journey.

```
forge script script/SendPing.s.sol --rpc-url $SEPOLIA_RPC_URL --broadcast
```

## ✅ Verification
You can monitor the message status in real-time using the [Chainlink CCIP Explorer](https://ccip.chain.link/).

### Execution Screenshots (etherscan)
* Ethereum Sepolia (Source)
  
<p allgn="left">
  <img src="./screenshot/sepolia%20etherscan.png", height="100x", width="100px">
</p>

* Arbitrum Sepolia (Destination)

<p allgn="left">
  <img src="./screenshot/arbSepolia%20etherscan.png", height="100x", width="100px">
</p>
