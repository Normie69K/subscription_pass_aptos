# 🎫 Aptos Subscription Pass

A decentralized subscription management system built on the Aptos blockchain using Move language.

## 📋 Overview

This project allows users to purchase time-based subscription passes (7, 30, 90, or 365 days) using APT tokens. All subscription data is stored on-chain and can be verified cryptographically.

## 🏗️ Project Structure

```
aptos-sub-pass/
├── sources/
│   └── subscription.move    # Main smart contract
├── scripts/
│   └── deploy.sh           # Deployment automation script
├── frontend/
│   └── index.html          # Web interface
├── Move.toml               # Move package configuration
└── .aptos/                 # Aptos account configuration
```

## 💰 Subscription Tiers

| Tier | Duration | Price | Best For |
|------|----------|-------|----------|
| Weekly | 7 days | 0.05 APT | Testing |
| Monthly | 30 days | 0.15 APT | Regular users |
| Quarterly | 90 days | 0.40 APT | Power users |
| Yearly | 365 days | 1.50 APT | Maximum savings (59% off) |

## 🚀 Quick Start

### Prerequisites

1. **Install Aptos CLI**
   ```bash
   curl -fsSL "https://aptos.dev/scripts/install_cli.py" | python3
   ```

2. **Verify Installation**
   ```bash
   aptos --version
   ```

### Deployment

#### Option 1: Using Deploy Script (Recommended)

```bash
cd /home/karan/Projects/aptos-sub-pass
./scripts/deploy.sh
```

The script will:
- ✅ Clean previous builds
- ✅ Compile the contract
- ✅ Check/create account configuration
- ✅ Fund account from faucet (if needed)
- ✅ Deploy to Aptos Devnet
- ✅ Provide next steps

#### Option 2: Manual Deployment

```bash
# Navigate to project root
cd /home/karan/Projects/aptos-sub-pass

# Compile the contract
aptos move compile

# Initialize account (if not done)
aptos init --network devnet

# Fund account from faucet
aptos account fund-with-faucet --account default

# Deploy contract
aptos move publish --named-addresses subscription=default

# Initialize the contract
aptos move run --function-id <YOUR_ADDRESS>::pass::initialize
```

## 📝 Contract Functions

### Entry Functions

#### `initialize(account: &signer)`
Initialize the pass store. Must be called once after deployment.

```bash
aptos move run --function-id <CONTRACT_ADDRESS>::pass::initialize
```

#### `purchase_pass(buyer: &signer, store_owner: address, duration_days: u64)`
Purchase a subscription pass.

```bash
aptos move run \
  --function-id <CONTRACT_ADDRESS>::pass::purchase_pass \
  --args address:<STORE_OWNER> u64:<DURATION>
```

Example:
```bash
# Buy 30-day pass
aptos move run \
  --function-id <CONTRACT_ADDRESS>::pass::purchase_pass \
  --args address:0xe30f7fc58ecb3c59b2f43bad077b52a64a7b572d2dc7986914721ad808b175b5 u64:30
```

### View Functions

#### `has_active_pass(store_owner: address, user: address): bool`
Check if a user has an active pass.

```bash
aptos move view \
  --function-id <CONTRACT_ADDRESS>::pass::has_active_pass \
  --args address:<STORE_OWNER> address:<USER>
```

#### `get_pass_info(store_owner: address, user: address)`
Get detailed pass information.

Returns: `(is_active, pass_id, purchased_at, expires_at, duration_days, price_paid)`

#### `get_total_passes_sold(store_owner: address): u64`
Get total number of passes sold.

#### `get_total_revenue(store_owner: address): u64`
Get total revenue collected (in octas).

#### `get_tier_price(duration_days: u64): u64`
Get the price for a specific tier.

```bash
# Get price for 30-day pass
aptos move view \
  --function-id <CONTRACT_ADDRESS>::pass::get_tier_price \
  --args u64:30
```

## 🌐 Frontend Setup

1. **Update Contract Address**
   
   Open `frontend/index.html` and update:
   ```javascript
   const CONTRACT_ADDRESS = "0x123"; // Replace with your deployed contract address
   ```

2. **Install Petra Wallet**
   - Chrome: https://petra.app/
   - Make sure you're on Devnet network

3. **Open Frontend**
   ```bash
   # Using Python
   cd frontend
   python3 -m http.server 8000
   
   # Or using any other static file server
   ```

4. **Access the App**
   - Open browser to `http://localhost:8000`
   - Connect your Petra wallet
   - Purchase and manage subscriptions

## 🔧 Development

### Compile Contract
```bash
aptos move compile
```

### Run Tests
```bash
aptos move test
```

### Clean Build
```bash
rm -rf build/
```

## 📊 Contract Architecture

### Data Structures

**Pass**: Individual subscription record
```move
struct Pass {
    id: u64,                // Unique pass ID
    purchased_at: u64,      // Purchase timestamp
    expires_at: u64,        // Expiration timestamp
    duration_days: u64,     // Duration (7, 30, 90, or 365)
    price_paid: u64,        // Amount paid in octas
}
```

**PassStore**: Global state management
```move
struct PassStore {
    next_pass_id: u64,              // Counter for pass IDs
    passes: Table<address, Pass>,   // User passes mapping
    purchase_events: EventHandle,   // Event emission
    total_passes_sold: u64,         // Statistics
    total_revenue: u64,             // Total revenue
}
```

### Events

**PassPurchaseEvent**: Emitted on each purchase
```move
struct PassPurchaseEvent {
    buyer: address,
    pass_id: u64,
    purchased_at: u64,
    expires_at: u64,
    duration_days: u64,
    price_paid: u64,
}
```

## 🔒 Security Features

- ✅ On-chain verification of subscription status
- ✅ Timestamp-based expiration
- ✅ Balance checks before purchase
- ✅ Atomic transactions
- ✅ Event emission for transparency
- ✅ No admin backdoors

## 🌍 Network Information

- **Network**: Devnet
- **RPC**: https://fullnode.devnet.aptoslabs.com
- **Faucet**: https://faucet.devnet.aptoslabs.com
- **Explorer**: https://explorer.aptoslabs.com/?network=devnet

## 🐛 Troubleshooting

### Compilation Stuck?
```bash
rm -rf build/
aptos move compile --skip-fetch-latest-git-deps
```

### Can't Connect Wallet?
- Ensure Petra wallet is installed
- Switch to Devnet network in Petra
- Refresh the page

### Insufficient Balance?
```bash
aptos account fund-with-faucet --account default
```

### Contract Not Found?
- Verify contract address in frontend matches deployed address
- Check deployment transaction on Explorer

## 📚 Resources

- [Aptos Documentation](https://aptos.dev)
- [Move Language Book](https://move-language.github.io/move/)
- [Petra Wallet](https://petra.app)
- [Aptos Explorer](https://explorer.aptoslabs.com)

## 📄 License

MIT License - Feel free to use and modify

## 🤝 Contributing

Contributions welcome! Please open an issue or PR.

---

Built with ❤️ on Aptos Blockchain
