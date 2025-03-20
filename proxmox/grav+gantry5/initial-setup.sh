#!/bin/bash
# 🚀 Grav + Gantry5 Automated Setup (No Nginx, Cloudflared Only)
set -e  # Exit on error

LOGFILE="/var/log/grav-setup.log"
echo "🚀 Starting Grav + Gantry5 Setup" | tee -a $LOGFILE

# Ensure the script is run as root
if [ "$(id -u)" -ne 0 ]; then
    echo "❌ This script must be run as root." | tee -a $LOGFILE
    exit 1
fi

# Ensure system is updated
echo "🔹 Updating system packages..." | tee -a $LOGFILE
apt update && apt upgrade -y

# Install required dependencies (No Nginx)
echo "🔹 Installing required packages..." | tee -a $LOGFILE
apt install -y php php-fpm php-cli php-gd php-curl php-zip php-mbstring php-xml unzip rsync git wget curl lsb-release apt-transport-https ca-certificates sudo

# Set up Grav CMS
echo "🔹 Installing Grav CMS..." | tee -a $LOGFILE
mkdir -p /var/www
cd /var/www
wget https://getgrav.org/download/core/grav-admin/latest -O grav-admin.zip
unzip grav-admin.zip
mv grav-admin grav
chown -R www-data:www-data /var/www/grav
chmod -R 775 /var/www/grav

# Ensure PHP-FPM is running
echo "🔹 Restarting PHP-FPM..." | tee -a $LOGFILE
systemctl restart php-fpm

echo "✅ Setup complete! Grav is installed and ready for Cloudflared." | tee -a $LOGFILE
echo "🎯 Cloudflared will handle all traffic routing." | tee -a $LOGFILE
