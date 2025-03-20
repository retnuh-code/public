#!/bin/bash
# 🚀 Grav + Gantry5 Automated Setup (Initial Setup Only, No Plugins)
set -e  # Exit on error

LOGFILE="/var/log/grav-setup.log"
echo "🚀 Starting Grav + Gantry5 Initial Setup" | tee -a $LOGFILE

# Ensure the script is run as root
if [ "$(id -u)" -ne 0 ]; then
    echo "❌ This script must be run as root." | tee -a $LOGFILE
    exit 1
fi

# Ensure system is updated
echo "🔹 Updating system packages..." | tee -a $LOGFILE
apt update && apt upgrade -y

# Install required dependencies
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

# Ensure Grav directories exist
mkdir -p /var/www/grav/user/config
mkdir -p /var/www/grav/user/pages

# ✅ Initialize Grav
echo "🔹 Running Grav initialization..." | tee -a $LOGFILE
cd /var/www/grav
sudo -u www-data bin/grav install  # Ensures Grav is fully set up

# ✅ Optimize PHP-FPM for performance
echo "🔹 Optimizing PHP-FPM settings..." | tee -a $LOGFILE
PHP_VERSION=$(php -r "echo PHP_MAJOR_VERSION.'.'.PHP_MINOR_VERSION;")
PHP_FPM_CONF="/etc/php/${PHP_VERSION}/fpm/pool.d/www.conf"
sed -i "s/^pm.max_children =.*/pm.max_children = 50/" $PHP_FPM_CONF
sed -i "s/^pm.start_servers =.*/pm.start_servers = 10/" $PHP_FPM_CONF
sed -i "s/^pm.min_spare_servers =.*/pm.min_spare_servers = 5/" $PHP_FPM_CONF
sed -i "s/^pm.max_spare_servers =.*/pm.max_spare_servers = 20/" $PHP_FPM_CONF
sed -i "s/^pm.process_idle_timeout =.*/pm.process_idle_timeout = 10s/" $PHP_FPM_CONF

# Restart PHP-FPM to apply optimizations
echo "🔹 Restarting PHP-FPM..." | tee -a $LOGFILE
systemctl restart php-fpm

# ✅ Get the IP address of the server
LXC_IP=$(hostname -I | awk '{print $1}')
echo "✅ Setup complete! Grav is installed and ready." | tee -a $LOGFILE
echo "🎯 Access the Grav Admin Panel at: http://$LXC_IP/admin" | tee -a $LOGFILE
