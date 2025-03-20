#!/bin/bash
# 🚀 Cloudflared Tunnel Setup (No IP Routing)
set -e  # Exit on error

LOGFILE="/var/log/cloudflared-setup.log"
echo "🚀 Starting Cloudflared Tunnel Setup..." | tee -a $LOGFILE

# Ensure the script is run as root
if [ "$(id -u)" -ne 0 ]; then
    echo "❌ This script must be run as root." | tee -a $LOGFILE
    exit 1
fi

# Prompt for Cloudflare Tunnel Name
read -p "Enter Cloudflare Tunnel Name (must exist): " TUNNEL_NAME

# Install Cloudflared
echo "🔹 Installing Cloudflared..." | tee -a $LOGFILE
curl -L --output cloudflared.deb https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64.deb
dpkg -i cloudflared.deb

# Authenticate Cloudflared
echo "🔹 Authenticating Cloudflared..."
cloudflared tunnel login
echo "✅ Cloudflared authenticated!"

# Check if Tunnel exists
echo "🔹 Checking if Tunnel '$TUNNEL_NAME' exists..."
TUNNEL_ID=$(cloudflared tunnel list | grep "$TUNNEL_NAME" | awk '{print $1}')

if [[ -z "$TUNNEL_ID" ]]; then
    echo "❌ Tunnel '$TUNNEL_NAME' not found. Please create it manually in Cloudflare."
    exit 1
else
    echo "✅ Tunnel '$TUNNEL_NAME' found. ID: $TUNNEL_ID"
fi

# Configure Cloudflared service
echo "🔹 Configuring Cloudflared system service..."
mkdir -p /etc/cloudflared
cloudflared tunnel token $TUNNEL_ID > /etc/cloudflared/$TUNNEL_NAME.json

cat <<EOF > /etc/cloudflared/config.yml
tunnel: $TUNNEL_ID
credentials-file: /etc/cloudflared/$TUNNEL_NAME.json

ingress:
  - hostname: YOUR_DOMAIN_HERE
    service: http://127.0.0.1:8000  # Change port if needed
  - service: http_status:404
EOF

# Create Systemd Service
echo "🔹 Creating Cloudflared systemd service..."
cat <<EOF > /etc/systemd/system/cloudflared.service
[Unit]
Description=Cloudflare Tunnel
After=network.target

[Service]
ExecStart=/usr/local/bin/cloudflared tunnel run --config /etc/cloudflared/config.yml
Restart=always
User=root

[Install]
WantedBy=multi-user.target
EOF

# Enable and restart service
systemctl daemon-reload
systemctl enable cloudflared
systemctl restart cloudflared

echo "✅ Cloudflared is now running and linked to the Cloudflare Tunnel." | tee -a $LOGFILE
