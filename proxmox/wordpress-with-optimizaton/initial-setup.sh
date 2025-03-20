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
if [[ ! -d "/var/www/html/wp-admin" ]]; then
    echo "WordPress not found in /var/www/html/. Downloading..."
    wget https://wordpress.org/latest.tar.gz
    tar -xvzf latest.tar.gz
    mv wordpress/* /var/www/html/
    rm -rf latest.tar.gz wordpress
fi

chown -R www-data:www-data /var/www/html
chmod -R 755 /var/www/html

# Ensure `wp-cli` is installed
wp_cli="/usr/local/bin/wp"
wget https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar -O $wp_cli
chmod +x $wp_cli

# 🟢 Step 4: Run WordPress Core Installation
echo "Running WordPress core installation..."
sudo -u www-data $wp_cli --path=/var/www/html core install --url="http://${LXC_IP}" --title="Coastal Tech Pros" --admin_user="admin" --admin_password="StrongPassword123" --admin_email="admin@example.com"

# 🟢 Step 5: Configure WordPress
echo "Configuring WordPress settings..."
sudo -u www-data $wp_cli --path=/var/www/html option update permalink_structure "/%postname%/"
sudo -u www-data $wp_cli --path=/var/www/html option update blogdescription "Coastal Tech Pros - IT Solutions"
sudo -u www-data $wp_cli --path=/var/www/html rewrite flush

# 🟢 Step 6: Configure NGINX for WordPress
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

# 🟢 Step 7: Install Essential Plugins
echo "Installing essential WordPress plugins..."
sudo -u www-data $wp_cli --path=/var/www/html plugin install elementor wp-rocket shortpixel-image-optimizer redis-cache rank-math-seo --activate

# 🟢 Step 8: Install & Configure AI SEO Automation
echo "Installing AI-powered SEO tools..."
sudo -u www-data $wp_cli --path=/var/www/html plugin install aioseo --activate
sudo -u www-data $wp_cli --path=/var/www/html plugin install link-whisper --activate

# 🟢 Step 9: Google Analytics Integration
echo "Setting up Google Analytics..."
GA_TRACKING_ID="UA-XXXXXXXXX-X"
sudo -u www-data $wp_cli --path=/var/www/html option update rank_math_google_analytics "${GA_TRACKING_ID}"

# 🟢 Step 10: Force Elementor for Editing (Disable Default Editor)
echo "Disabling Gutenberg and forcing Elementor..."
sudo -u www-data $wp_cli --path=/var/www/html plugin install disable-gutenberg --activate
sudo -u www-data $wp_cli --path=/var/www/html option update classic-editor-replace "block"

# 🟢 Step 11: Secure WordPress
echo "Securing WordPress..."
sudo -u www-data $wp_cli --path=/var/www/html plugin install wordfence --activate
sudo -u www-data $wp_cli --path=/var/www/html option update users_can_register 0
sudo -u www-data $wp_cli --path=/var/www/html option update comment_registration 1
sudo -u www-data $wp_cli --path=/var/www/html option update uploads_use_yearmonth_folders 0

# 🟢 Step 12: Set Up Automatic Backups & Database Optimization
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
