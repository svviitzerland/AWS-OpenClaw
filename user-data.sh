#!/bin/bash
set -x

# Log function
log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $*"
}

log "Starting OpenClaw installation (direct)..."

# Update system
log "Updating system..."
apt-get update
apt-get upgrade -y

# Install Node.js 24 (recommended by OpenClaw)
log "Installing Node.js 24..."
curl -fsSL https://deb.nodesource.com/setup_24.x | bash -
apt-get install -y nodejs

# Verify Node installation
node -v
npm -v

# Install OpenClaw globally
log "Installing OpenClaw..."
npm install -g openclaw@latest

# Verify openclaw is installed
which openclaw
openclaw --version

# Create OpenClaw directory
log "Creating OpenClaw directory..."
mkdir -p /home/ubuntu/.openclaw
chown -R ubuntu:ubuntu /home/ubuntu/.openclaw

# Initialize OpenClaw as ubuntu user
log "Initializing OpenClaw..."
su - ubuntu -c "openclaw onboard --install-daemon --non-interactive --accept-risk"

# Wait for daemon to start
sleep 10

# Configure OpenRouter
log "Configuring OpenRouter API key and model..."
su - ubuntu -c "openclaw config set env.OPENROUTER_API_KEY '${openrouter_api_key}'"
su - ubuntu -c "openclaw config set agents.defaults.model.primary 'openrouter/${openrouter_model}'"

# Configure gateway to bind to all interfaces
log "Configuring gateway bind..."
su - ubuntu -c "openclaw config set gateway.bind lan"

# Configure Telegram if provided
if [ -n "${telegram_bot_token}" ] && [ "${telegram_bot_token}" != "" ]; then
  log "Configuring Telegram bot..."
  su - ubuntu -c "openclaw config set channels.telegram.enabled true"
  su - ubuntu -c "openclaw config set channels.telegram.botToken '${telegram_bot_token}'"
  su - ubuntu -c "openclaw config set channels.telegram.dmPolicy pairing"
  su - ubuntu -c "openclaw config set channels.telegram.groupPolicy open"
  log "Telegram configured"
else
  log "Skipping Telegram configuration (no token provided)"
fi

# Restart gateway to apply config
log "Restarting OpenClaw gateway..."
su - ubuntu -c "openclaw gateway restart"

# Wait for restart
sleep 5

# Check status
log "Checking OpenClaw status..."
su - ubuntu -c "openclaw gateway status"

log "OpenClaw installation completed!"
log "Access OpenClaw at http://$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4):${openclaw_port}"
log "Check logs with: su - ubuntu -c 'openclaw logs --follow'"
