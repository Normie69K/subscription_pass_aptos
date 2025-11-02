#!/usr/bin/env bash

# Aptos Subscription Pass - Deployment Script
# This script helps you compile and deploy your contract to Aptos

set -e

echo "🎫 Aptos Subscription Pass - Deployment Script"
echo "=============================================="
echo ""

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if aptos CLI is installed
if ! command -v aptos &> /dev/null; then
    echo -e "${RED}❌ Aptos CLI not found${NC}"
    echo ""
    echo "Please install Aptos CLI first:"
    echo "curl -fsSL \"https://aptos.dev/scripts/install_cli.py\" | python3"
    echo ""
    echo "Or download from: https://github.com/aptos-labs/aptos-core/releases"
    exit 1
fi

echo -e "${GREEN}✓ Aptos CLI found${NC}"
echo ""

# Step 1: Clean build
echo -e "${BLUE}Step 1: Cleaning previous build...${NC}"
rm -rf build/
echo -e "${GREEN}✓ Clean complete${NC}"
echo ""

# Step 2: Compile
echo -e "${BLUE}Step 2: Compiling contract...${NC}"
aptos move compile
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ Compilation successful${NC}"
else
    echo -e "${RED}❌ Compilation failed${NC}"
    exit 1
fi
echo ""

# Step 3: Check account
echo -e "${BLUE}Step 3: Checking account configuration...${NC}"
if [ ! -f ".aptos/config.yaml" ]; then
    echo -e "${YELLOW}⚠ No account configuration found${NC}"
    echo "Initializing new account..."
    aptos init --network devnet
else
    echo -e "${GREEN}✓ Account configuration found${NC}"
fi
echo ""

# Step 4: Get account info
echo -e "${BLUE}Step 4: Account Information${NC}"
ACCOUNT_ADDR=$(grep "account:" .aptos/config.yaml | awk '{print $2}')
echo -e "Account Address: ${GREEN}${ACCOUNT_ADDR}${NC}"
echo ""

# Step 5: Check balance
echo -e "${BLUE}Step 5: Checking account balance...${NC}"
aptos account list --account default
echo ""

# Ask to fund account if needed
echo -e "${YELLOW}Do you need to fund your account from faucet? (y/n)${NC}"
read -r FUND_ACCOUNT
if [ "$FUND_ACCOUNT" = "y" ] || [ "$FUND_ACCOUNT" = "Y" ]; then
    echo "Funding account from devnet faucet..."
    aptos account fund-with-faucet --account default
    echo -e "${GREEN}✓ Account funded${NC}"
    echo ""
fi

# Step 6: Deploy
echo -e "${BLUE}Step 6: Deploying contract...${NC}"
echo -e "${YELLOW}Ready to deploy. Continue? (y/n)${NC}"
read -r DEPLOY_CONFIRM
if [ "$DEPLOY_CONFIRM" = "y" ] || [ "$DEPLOY_CONFIRM" = "Y" ]; then
    aptos move publish --named-addresses subscription=default
    
    if [ $? -eq 0 ]; then
        echo ""
        echo -e "${GREEN}🎉 Deployment successful!${NC}"
        echo ""
        echo "=============================================="
        echo -e "${GREEN}Contract Details:${NC}"
        echo -e "Module: ${GREEN}${ACCOUNT_ADDR}::pass${NC}"
        echo -e "Network: ${BLUE}Devnet${NC}"
        echo ""
        echo -e "${YELLOW}Next Steps:${NC}"
        echo "1. Initialize the contract:"
        echo "   aptos move run --function-id ${ACCOUNT_ADDR}::pass::initialize"
        echo ""
        echo "2. Update frontend CONTRACT_ADDRESS in index.html:"
        echo "   Replace '0x123' with '${ACCOUNT_ADDR}'"
        echo ""
        echo "3. View on Explorer:"
        echo "   https://explorer.aptoslabs.com/account/${ACCOUNT_ADDR}/modules?network=devnet"
        echo ""
        echo "=============================================="
    else
        echo -e "${RED}❌ Deployment failed${NC}"
        exit 1
    fi
else
    echo "Deployment cancelled"
    exit 0
fi
