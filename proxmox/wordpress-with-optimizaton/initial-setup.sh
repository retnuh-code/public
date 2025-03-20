#!/bin/bash

# 🚀 WordPress Auto-Installer for Debian LXC
# Automates WordPress setup, performance tuning, security, and SEO

set -e  # Stop script on errors

# 🔹 Get LXC IP Address
LXC_IP=$(hostname -I | awk '{print $1}')

# 🟢 Step 1: Install Required Software
echo "Updating system and installing dependencies..."
apt update && apt upgrade -y
apt install -y nginx mariadb-server php php-fpm php-cli php-mysql php-curl php-xml php-mbstring unzip wget curl redis-server

# 🟢 Step 2: Configure Database
DB_NAME="wordpress"
DB_USER="wp_user"
DB_PASS="StrongRandomPassword"

echo "Setting up MariaDB database for WordPress..."
mysql -e "CREATE DATABASE ${DB_NAME};"
mysql -e "CREATE USER '${DB_USER}'@'localhost' IDENTIFIED BY '${DB_PASS}';"
mysql -e "GRANT ALL PRIVILEGES ON ${DB_NAME}.* TO '${DB_USER}'@'localhost';"
mysql -e "FLUSH PRIVILEGES;"

# 🟢 Step 3: Install WordPress
echo "Downloading and configuring WordPress..."
wget https://wordpress.org/latest.tar.gz
tar -xvzf latest.tar.gz
mv wordpress /var/www/html
chown -R www-data:www-data /var/www/html
chmod -R 755 /var/www/html

# Create WordPress config file
cat <<EOF > /var/www/html/wp-config.php
<?php
define( 'DB_NAME', '${DB_NAME}' );
define( 'DB_USER', '${DB_USER}' );
define( 'DB_PASSWORD', '${DB_PASS}' );
define( 'DB_HOST', 'localhost' );
define( 'FS_METHOD', 'direct' ); 
define( 'WP_REDIS_HOST', '127.0.0.1' );
define( 'WP_REDIS_PORT', 6379 );
define( 'WP_CACHE', true );
EOF

# 🟢 Step 4: Configure NGINX for WordPress
echo "Configuring NGINX..."
cat <<EOF > /etc/nginx/sites-available/wordpress
server {
    listen 80;
    server_name _;
    root /var/www/html;
    index index.php index.html;

    location / {
        try_files \$uri \$uri/ /index.php?\$args;
    }

    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/run/php/php8.2-fpm.sock;
        fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
        include fastcgi_params;
    }

    location ~* \.(js|css|png|jpg|jpeg|gif|ico|woff|woff2|ttf|svg|eot)$ {
        expires max;
        log_not_found off;
    }
}
EOF

ln -s /etc/nginx/sites-available/wordpress /etc/nginx/sites-enabled/
systemctl restart nginx php8.2-fpm

# 🟢 Step 5: Optimize WordPress Performance
echo "Optimizing WordPress Performance..."
wp_cli="/usr/local/bin/wp"
wget https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar -O $wp_cli
chmod +x $wp_cli

# Install & activate essential plugins
sudo -u www-data $wp_cli plugin install elementor wp-rocket shortpixel-image-optimizer redis-cache rank-math-seo --activate
sudo -u www-data $wp_cli option update permalink_structure "/%postname%/"
sudo -u www-data $wp_cli option update blogdescription "Coastal Tech Pros - IT Solutions"
sudo -u www-data $wp_cli rewrite flush

# 🟢 Step 6: Install & Configure AI SEO Automation
echo "Installing AI-powered SEO tools..."
sudo -u www-data $wp_cli plugin install aioseo --activate
sudo -u www-data $wp_cli plugin install link-whisper --activate

# 🟢 Step 7: Google Analytics Integration
echo "Setting up Google Analytics..."
GA_TRACKING_ID="UA-XXXXXXXXX-X"
sudo -u www-data $wp_cli option update rank_math_google_analytics "${GA_TRACKING_ID}"

# 🟢 Step 8: Force Elementor for Editing (Disable Default Editor)
echo "Disabling Gutenberg and forcing Elementor..."
sudo -u www-data $wp_cli plugin install disable-gutenberg --activate
sudo -u www-data $wp_cli option update classic-editor-replace "block"

# 🟢 Step 9: Secure WordPress
echo "Securing WordPress..."
sudo -u www-data $wp_cli plugin install wordfence --activate
sudo -u www-data $wp_cli option update users_can_register 0
sudo -u www-data $wp_cli option update comment_registration 1
sudo -u www-data $wp_cli option update uploads_use_yearmonth_folders 0

# Configure Fail2Ban for brute-force protection
cat <<EOF > /etc/fail2ban/jail.local
[wordpress]
enabled = true
filter = wordpress
logpath = /var/log/nginx/access.log
maxretry = 5
bantime = 3600
EOF
systemctl restart fail2ban

# 🟢 Step 10: Set Up Automatic Backups & Database Optimization
echo "Setting up automatic backups and database optimizations..."
mkdir -p /var/backups/wordpress
crontab -l > mycron
echo "0 3 * * * tar -czf /var/backups/wordpress/backup_\$(date +\%F).tar.gz /var/www/html" >> mycron
echo "0 4 * * * mysqlcheck --optimize --all-databases" >> mycron
crontab mycron
rm mycron

# 🟢 Final Steps
echo "✅ WordPress installation complete!"
echo "Your site is available at: http://${LXC_IP}/wp-admin"
echo "Configure Cloudflare Tunnel & Load Balancer manually."
