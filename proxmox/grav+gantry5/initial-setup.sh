#!/bin/bash

# 🚀 Grav + Gantry5 Setup Script for a Blank Debian LXC
# Installs all dependencies, configures PHP, and makes site accessible on local IP

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
echo -e "    🚀 Grav + Gantry5 Initial Setup"
echo -e "       Configuring a blank Debian LXC"
echo -e "${YW}──────────────────────────────────────────────${CL}"
echo -e " 📌 This script will:"
echo -e "    - Install all required dependencies"
echo -e "    - Set up PHP and Grav CMS"
echo -e "    - Make site accessible on local IP"
echo -e "${YW}──────────────────────────────────────────────${CL}"
sleep 2

# **Ensure the script is run as root**
if [[ "$(id -u)" -ne 0 ]]; then
    echo -e "${CROSS} ${RD}Please run this script as root.${CL}"
    exit 1
fi

# **Get Container's Local IP**
LXC_IP=$(hostname -I | awk '{print $1}')
if [[ -z "$LXC_IP" ]]; then
    echo -e "${CROSS} ${RD}Could not determine container IP. Please set a static IP.${CL}"
    exit 1
fi

echo -e "${CM} Using Local IP: $LXC_IP"

# **Install Dependencies**
echo -e "${YW}Installing system updates and dependencies...${CL}"
apt update && apt upgrade -y
apt install -y php php-fpm php-cli php-gd php-curl php-zip php-mbstring php-xml unzip rsync git wget curl lsb-release apt-transport-https ca-certificates sudo

# **Install Grav CMS**
echo -e "${YW}Installing Grav CMS and Gantry5 Framework...${CL}"
mkdir -p /var/www
cd /var/www
wget https://getgrav.org/download/core/grav-admin/latest -O grav-admin.zip
unzip grav-admin.zip
mv grav-admin grav
cd grav
bin/gpm install gantry5 -y
chown -R www-data:www-data /var/www/grav
chmod -R 775 /var/www/grav

# ✅ **Optimize PHP-FPM for performance**
echo -e "${YW}Optimizing PHP-FPM settings...${CL}"
PHP_VERSION=$(php -r "echo PHP_MAJOR_VERSION.'.'.PHP_MINOR_VERSION;")
PHP_FPM_CONF="/etc/php/${PHP_VERSION}/fpm/pool.d/www.conf"
sed -i "s/^pm.max_children =.*/pm.max_children = 50/" $PHP_FPM_CONF
sed -i "s/^pm.start_servers =.*/pm.start_servers = 10/" $PHP_FPM_CONF
sed -i "s/^pm.min_spare_servers =.*/pm.min_spare_servers = 5/" $PHP_FPM_CONF
sed -i "s/^pm.max_spare_servers =.*/pm.max_spare_servers = 20/" $PHP_FPM_CONF
sed -i "s/^pm.process_idle_timeout =.*/pm.process_idle_timeout = 10s/" $PHP_FPM_CONF

# ✅ Restart PHP-FPM
echo -e "${YW}Restarting PHP-FPM...${CL}"
systemctl restart php-fpm

# **Display Final Info**
echo -e "${YW}──────────────────────────────────────────────${CL}"
echo -e " 🎉 Setup Complete!"
echo -e " 📌 Grav + Gantry5 is now available at:"
echo -e "    ➤ Local Access: ${GN}http://$LXC_IP/admin${CL}"
echo -e "    ➤ You can now configure Cloudflared to expose this instance!"
echo -e "${YW}──────────────────────────────────────────────${CL}"
