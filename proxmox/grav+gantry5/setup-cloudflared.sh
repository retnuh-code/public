#!/bin/bash

# Cloudflared Installation & Private Network IP Setup for LXC
# Uses Cloudflare's official install method and assigns an IP to the LXC.

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
echo -e "    🚀 Cloudflared Setup for LXC"
echo -e "       Using Cloudflare's Official Method"
echo -e "${YW}──────────────────────────────────────────────${CL}"
echo -e " 📌 This script will:"
echo -e "    - Install Cloudflared via Cloudflare's official method"
echo -e "    - Register the tunnel using the provided token"
echo -e "    - Assign a Private IP from the Cloudflare network"
echo -e "${YW}──────────────────────────────────────────────${CL}"
sleep 2

# **Ensure the script is run as root**
if [[ "$(id -u)" -ne 0 ]]; then
    echo -e "${CROSS} ${RD}Please run this script as root.${CL}"
    exit 1
fi

# **User Input**
read -p "Enter Cloudflare Tunnel Token: " TUNNEL_TOKEN
read -p "Enter Private IP to Assign (must be within 172.16.1.10/29): " PRIVATE_IP

# **Install Cloudflared Using Cloudflare's Official Method**
echo -e "${YW}Installing Cloudflared...${CL}"
curl -L --output cloudflared.deb https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64.deb
dpkg -i cloudflared.deb

# **Register Tunnel with Cloudflare**
echo -e "${YW}Registering Cloudflared Tunnel...${CL}"
cloudflared service install "$TUNNEL_TOKEN"

# **Ensure Cloudflared Service is Running**
systemctl enable cloudflared
systemctl restart cloudflared

# **Assign Private IP**
echo -e "${YW}Assigning Private IP: $PRIVATE_IP...${CL}"
ip addr add $PRIVATE_IP dev eth0

# **Final Confirmation**
echo -e "${YW}──────────────────────────────────────────────${CL}"
echo -e " 🎉 Setup Complete!"
echo -e " 📌 Cloudflared is now running and registered."
echo -e "    ➤ Private IP Assigned: ${GN}$PRIVATE_IP${CL}"
echo -e "${YW}──────────────────────────────────────────────${CL}"
