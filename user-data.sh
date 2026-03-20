#!/bin/bash
set -x  # Debug mode instead of set -e

# Log function
log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $*"
}

log "Starting OpenClaw installation..."

# Update and install Docker
log "Installing Docker..."
apt-get update
apt-get upgrade -y
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh
usermod -aG docker ubuntu
apt-get install -y docker-compose-plugin

# Create OpenClaw directory
log "Creating OpenClaw directory..."
mkdir -p /opt/openclaw
cd /opt/openclaw

# Create docker-compose.yml with proper environment variables
log "Creating docker-compose.yml..."
cat > docker-compose.yml <<EOF
services:
  openclaw:
    image: ghcr.io/openclaw/openclaw:${openclaw_version}
    container_name: openclaw
    restart: unless-stopped
    ports:
      - "${openclaw_port}:8080"
    volumes:
      - openclaw-data:/home/node/.openclaw
      - openclaw-logs:/tmp/openclaw
    environment:
      - OPENROUTER_API_KEY=${openrouter_api_key}
      - OPENCLAW_AGENT_MODEL=openrouter/${openrouter_model}
      - OPENCLAW_DEFAULT_MODEL=openrouter/${openrouter_model}
$([ -n "${telegram_bot_token}" ] && [ "${telegram_bot_token}" != "" ] && echo "      - TELEGRAM_BOT_TOKEN=${telegram_bot_token}")
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8080/health"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 60s

volumes:
  openclaw-data:
  openclaw-logs:
EOF

# Start container
log "Starting OpenClaw container..."
docker compose up -d

# Wait for container to be running
log "Waiting for container to start..."
sleep 10

# Fix volume permissions
log "Fixing permissions..."
docker exec --user root openclaw chown -R node:node /home/node/.openclaw || true
docker exec --user root openclaw chown -R node:node /tmp/openclaw || true

# Wait for OpenClaw to be fully ready
log "Waiting for OpenClaw to initialize..."
for i in {1..30}; do
  if docker exec openclaw openclaw --version >/dev/null 2>&1; then
    log "OpenClaw is ready!"
    break
  fi
  log "Waiting... ($i/30)"
  sleep 2
done

# Configure model explicitly
log "Configuring model: openrouter/${openrouter_model}"
docker exec openclaw openclaw config set agents.defaults.model.primary "openrouter/${openrouter_model}"
docker exec openclaw openclaw config set env.OPENROUTER_API_KEY "${openrouter_api_key}"

# Configure Telegram if provided
if [ -n "${telegram_bot_token}" ] && [ "${telegram_bot_token}" != "" ]; then
  log "Configuring Telegram bot..."
  docker exec openclaw openclaw config set channels.telegram.enabled true
  docker exec openclaw openclaw config set channels.telegram.botToken "${telegram_bot_token}"
  docker exec openclaw openclaw config set channels.telegram.dmPolicy pairing
  docker exec openclaw openclaw config set channels.telegram.groupPolicy open
  log "Telegram configured. Users need to pair with: openclaw pairing approve telegram <CODE>"
else
  log "Skipping Telegram configuration (no token provided)"
fi

# Restart to apply all config changes
log "Restarting OpenClaw to apply configuration..."
docker compose restart

# Wait for final startup
log "Waiting for final startup..."
sleep 15

# Setup systemd service
log "Setting up systemd service..."
cat > /etc/systemd/system/openclaw.service <<'SERVICE'
[Unit]
Description=OpenClaw Service
Requires=docker.service
After=docker.service

[Service]
Type=oneshot
RemainAfterExit=yes
WorkingDirectory=/opt/openclaw
ExecStart=/usr/bin/docker compose up -d
ExecStop=/usr/bin/docker compose down
TimeoutStartSec=0

[Install]
WantedBy=multi-user.target
SERVICE

systemctl daemon-reload
systemctl enable openclaw.service

log "OpenClaw installation completed successfully!"
log "Access OpenClaw at http://$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4):${openclaw_port}"
