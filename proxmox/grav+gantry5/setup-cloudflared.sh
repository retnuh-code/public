#!/bin/bash

# Cloudflared SD-WAN Setup for Grav + Gantry5 LXC
# Installs Cloudflared, configures SD-WAN in Cloudflare, and assigns private IP.

set -e  # Exit on error

# **Color Formatting**
YW=$(echo "\033[33m")
GN=$(echo "\033[1;92m")
RD=$(echo "\033[01;31m")
CL=$(echo "\033[m")
CM="${GN}✓${CL}"
CROSS="${RD}✗${CL}"

# **Splash Screen**
clear
echo -e "${YW}──────────────────────────────────────────────${CL}"
echo -e "    🚀 Cloudflared SD-WAN Setup"
echo -e "       Configuring Private Network in Cloudflare"
echo -e "${YW}──────────────────────────────────────────────${CL}"
echo -e " 📌 This script will:"
echo -e "    - Install Cloudflared"
echo -e "    - Configure SD-WAN in Cloudflare"
echo -e "    - Assign a Private IP from Cloudflare"
echo -e "${YW}──────────────────────────────────────────────${CL}"
sleep 2

# **Ensure the script is run as root**
if [[ "$(id -u)" -ne 0 ]]; then
    echo -e "${CROSS} ${RD}Please run this script as root.${CL}"
    exit 1
fi

# **User Input**
read -p "Enter Cloudflare Tunnel Name (must exist): " TUNNEL_NAME
read -p "Enter Private Network IP to Assign (e.g., 172.16.1.10/32): " PRIVATE_IP

# **Install Cloudflared**
echo -e "${YW}Installing Cloudflared...${CL}"
wget -q https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64 -O /usr/local/bin/cloudflared
chmod +x /usr/local/bin/cloudflared

# **Authenticate Cloudflared**
echo -e "${YW}Authenticating Cloudflared...${CL}"

cloudflared tunnel login

# **Check if Tunnel Exists**
echo -e "${YW}Checking if Tunnel '$TUNNEL_NAME' exists...${CL}"
TUNNEL_ID=$(cloudflared tunnel list | grep -i "$TUNNEL_NAME" | awk '{print $1}')

if [[ -z "$TUNNEL_ID" ]]; then
    echo -e "${CROSS} ${RD}Tunnel '$TUNNEL_NAME' not found in Cloudflare.${CL}"
    exit 1
fi
echo -e "${CM} Tunnel '$TUNNEL_NAME' found. ID: $TUNNEL_ID"

# **Add Private IP Route to Cloudflare SD-WAN**
echo -e "${YW}Adding Private Network Route: $PRIVATE_IP...${CL}"
cloudflared tunnel route ip add $PRIVATE_IP $TUNNEL_NAME

# **Enable Cloudflared Service**
echo -e "${YW}Configuring Cloudflared system service...${CL}"
mkdir -p /etc/cloudflared

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

systemctl daemon-reload
systemctl enable cloudflared
systemctl start cloudflared

# **Final Confirmation**
echo -e "${YW}──────────────────────────────────────────────${CL}"
echo -e " 🎉 Setup Complete!"
echo -e " 📌 Cloudflared is now running and connected."
echo -e "    ➤ Private IP Assigned: ${GN}$PRIVATE_IP${CL}"
echo -e "    ➤ Cloudflare Tunnel: ${GN}$TUNNEL_NAME${CL}"
echo -e "${YW}──────────────────────────────────────────────${CL}"
