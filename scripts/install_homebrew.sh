#!/bin/bash

# Cliply Homebrew Tap Installation Script
# This script helps users install Cliply via Homebrew

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}🍺 Setting up Cliply Homebrew tap...${NC}"

# Check if Homebrew is installed
if ! command -v brew &> /dev/null; then
    echo -e "${YELLOW}⚠️  Homebrew is not installed.${NC}"
    echo -e "${YELLOW}📥 Installing Homebrew...${NC}"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# Add the tap
echo -e "${YELLOW}🔗 Adding Cliply tap...${NC}"
brew tap luisdergoat/cliply https://github.com/luisdergoat/cliply

# Install Cliply
echo -e "${YELLOW}📦 Installing Cliply...${NC}"
brew install --cask cliply

echo -e "${GREEN}✅ Cliply installed successfully!${NC}"
echo -e "${GREEN}🚀 Launch Cliply from your Applications folder or Spotlight${NC}"
