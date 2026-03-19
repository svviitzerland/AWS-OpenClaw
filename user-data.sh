#!/bin/bash
set -e

# Update system
apt-get update
apt-get upgrade -y

# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh
usermod -aG docker ubuntu

# Install Docker Compose
apt-get install -y docker-compose-plugin

# Create OpenClaw directory
mkdir -p /opt/openclaw
cd /opt/openclaw

# Create docker-compose.yml
cat > docker-compose.yml <<'EOF'
version: '3.8'

services:
  openclaw:
    image: ghcr.io/openclaw/openclaw:${openclaw_version}
    container_name: openclaw
    restart: unless-stopped
    ports:
      - "${openclaw_port}:8080"
    environment:
      # OpenRouter configuration
      - LLM_PROVIDER=openrouter
      - OPENROUTER_API_KEY=${openrouter_api_key}
      - OPENROUTER_MODEL=anthropic/claude-3.5-sonnet

      # Alternative models (uncomment untuk ganti model)
      # - OPENROUTER_MODEL=anthropic/claude-3-haiku  # Lebih murah
      # - OPENROUTER_MODEL=google/gemini-pro         # Alternatif lain
      # - OPENROUTER_MODEL=meta-llama/llama-3-70b    # Open source

      # OpenClaw settings
      - PORT=8080
      - NODE_ENV=production

    volumes:
      - openclaw-data:/app/data
      - openclaw-logs:/app/logs
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8080/health"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 40s

volumes:
  openclaw-data:
  openclaw-logs:
EOF

# Start OpenClaw
docker compose up -d

# Setup log rotation
cat > /etc/logrotate.d/openclaw <<'LOGROTATE'
/opt/openclaw/logs/*.log {
    daily
    rotate 7
    compress
    delaycompress
    missingok
    notifempty
}
LOGROTATE

# Create systemd service untuk auto-start
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

# Setup CloudWatch agent (optional, untuk monitoring)
# wget https://s3.amazonaws.com/amazoncloudwatch-agent/ubuntu/arm64/latest/amazon-cloudwatch-agent.deb
# dpkg -i -E ./amazon-cloudwatch-agent.deb

echo "OpenClaw installation completed!"
