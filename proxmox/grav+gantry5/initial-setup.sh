#!/bin/bash
# 🚀 Grav + Gantry5 Automated Setup (Fully Optimized for Speed)
set -e  # Exit on error

LOGFILE="/var/log/grav-setup.log"
echo "🚀 Starting Grav + Gantry5 Optimized Setup" | tee -a $LOGFILE

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

# ✅ Enable Grav Caching
echo "🔹 Enabling Grav caching..." | tee -a $LOGFILE
cat <<EOF > /var/www/grav/user/config/system.yaml
cache:
  enabled: true
  check:
    method: file
  driver: auto
  prefix: 'g'

assets:
  css_pipeline: true
  js_pipeline: true
  enable_asset_timestamp: true
EOF

# ✅ Install and Configure Grav Cache Plugin
echo "🔹 Installing Grav Cache Plugin..." | tee -a $LOGFILE
cd /var/www/grav
bin/gpm install cache
cat <<EOF > /var/www/grav/user/config/plugins/cache.yaml
enabled: true
lifetime: 604800
gzip: true
clear_images_by_default: false
cache_enabled: true
EOF

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

echo "✅ Setup complete! Grav is installed and fully optimized for performance." | tee -a $LOGFILE
echo "🎯 Cloudflared will handle all traffic routing." | tee -a $LOGFILE
