#!/bin/bash

# Jiva Pro Installation Script
# This script sets up the Jiva Subscription Dashboard as a global command.

set -e

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

printf "${BLUE}Starting Jiva Pro Installation...${NC}\n"

# 1. Check Prerequisites
printf "Checking for Node.js...\n"
if ! command -v node &> /dev/null; then
    printf "${YELLOW}Error: Node.js is not installed.${NC} Please install it from https://nodejs.org/\n"
    exit 1
fi

# 2. Install Dependencies
printf "Installing project dependencies...\n"
npm install --silent

# 3. Environment Check
if [ ! -f .env ]; then
    printf "${YELLOW}Warning: .env file not found.${NC}\n"
    printf "Creating a template .env file...\n"
    cat > .env <<EOL
PORT=3000
JIVA_API_KEY=YOUR_API_KEY_HERE
JIVA_API_URL=https://us-central1-jiva-flutter.cloudfunctions.net/assignUserPlan
EOL
    printf "Please edit the .env file with your JIVA_API_KEY.\n"
fi

# 4. Setup Global Command
INSTALL_DIR=$(pwd)
BIN_DIR="$HOME/.local/bin"
COMMAND_NAME="jiva"

printf "Setting up global command '${COMMAND_NAME}' in ${BIN_DIR}...\n"

# Ensure ~/.local/bin exists
mkdir -p "$BIN_DIR"

# Create the wrapper script
mkdir -p "$INSTALL_DIR/bin"
cat > "$INSTALL_DIR/bin/jiva" <<EOL
#!/bin/bash
cd "$INSTALL_DIR" && node index.js
EOL

chmod +x "$INSTALL_DIR/bin/jiva"

# Symlink to ~/.local/bin
ln -sf "$INSTALL_DIR/bin/jiva" "$BIN_DIR/$COMMAND_NAME"

# 5. Final Output
printf -- "\n${GREEN}Installation Complete!${NC}\n"
printf -- "--------------------------------------------------\n"
printf -- "You can now run the app from any shell using:\n"
printf -- "  ${BLUE}${COMMAND_NAME}${NC}\n"
printf -- "--------------------------------------------------\n"
printf -- "Dashboard will be available at: ${BLUE}http://localhost:3000${NC}\n"

# Check if PATH contains bin dir
if [[ ":$PATH:" != *":$BIN_DIR:"* ]]; then
    printf "\n${YELLOW}IMPORTANT:${NC} $BIN_DIR is not in your PATH.\n"
    if [[ "$SHELL" == *"zsh"* ]]; then
        printf "Add this to your ${BLUE}~/.zshrc${NC}:\n"
        printf "  ${YELLOW}export PATH=\"\$HOME/.local/bin:\$PATH\"${NC}\n"
    else
        printf "Add this to your ${BLUE}~/.bashrc${NC} or profile:\n"
        printf "  ${YELLOW}export PATH=\"\$HOME/.local/bin:\$PATH\"${NC}\n"
    fi
    printf "Then run: ${BLUE}source ~/.zshrc${NC} (or restart your terminal)\n"
fi

