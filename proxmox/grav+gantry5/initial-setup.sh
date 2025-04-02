#!/bin/bash

set -e  # Exit on error

echo "🔄 Updating system..."
sudo apt update && sudo apt upgrade -y

sudo apt update && sudo apt install -y \
    php-intl \
    php-yaml \
    php-apcu \
    php-memcache \
    php-memcached \
    php-redis


# Get LXC IP dynamically
LXC_IP=$(hostname -I | awk '{print $1}')
echo "🌐 Current LXC IP: $LXC_IP"

echo "🔍 Checking for existing services on port 80..."
EXISTING_SERVICE=$(sudo lsof -i :80 | awk 'NR==2{print $1}')
if [[ -n "$EXISTING_SERVICE" ]]; then
    echo "⚠️ Detected $EXISTING_SERVICE running on port 80. Stopping service..."
    sudo systemctl stop "$EXISTING_SERVICE"
    sudo systemctl disable "$EXISTING_SERVICE"
    sudo apt remove --purge "$EXISTING_SERVICE" -y || true
    sudo apt autoremove -y
    echo "✅ $EXISTING_SERVICE has been stopped and removed."
else
    echo "✅ No conflicting service found on port 80."
fi

echo "📦 Installing Nginx..."
sudo apt install -y nginx
sudo systemctl enable --now nginx
sudo systemctl restart nginx
sudo systemctl status nginx --no-pager

echo "🔍 Detecting latest available PHP version..."
PHP_VERSION=$(sudo apt-cache search '^php[0-9]\.[0-9]-fpm$' | awk '{print $1}' | sort -V | tail -n 1 | sed 's/-fpm//')
echo "✅ Detected PHP version: $PHP_VERSION"

if [[ -z "$PHP_VERSION" ]]; then
    echo "⚠️ No PHP version detected, installing PHP 8.2..."
    PHP_VERSION="php8.2"
    sudo apt install -y php8.2 php8.2-fpm php8.2-cli php8.2-gd php8.2-curl php8.2-zip php8.2-mbstring php8.2-xml
else
    echo "📦 Installing required PHP extensions for $PHP_VERSION..."
    sudo apt install -y "$PHP_VERSION" "$PHP_VERSION-fpm" "$PHP_VERSION-cli" "$PHP_VERSION-gd" "$PHP_VERSION-curl" "$PHP_VERSION-zip" "$PHP_VERSION-mbstring" "$PHP_VERSION-xml"
fi

echo "🚀 Enabling and starting PHP-FPM..."
PHP_FPM_SERVICE="$PHP_VERSION-fpm"
sudo systemctl enable --now "$PHP_FPM_SERVICE"
sudo systemctl restart "$PHP_FPM_SERVICE"
sudo systemctl status "$PHP_FPM_SERVICE" --no-pager

echo "⬇️ Installing Grav CMS..."
cd /var/www/
sudo rm -rf grav  # Ensure no old Grav installation is present
sudo mkdir -p /var/www/grav
sudo wget -O grav-admin.zip https://getgrav.org/download/core/grav-admin/latest
sudo unzip grav-admin.zip -d /var/www/
sudo mv /var/www/grav-admin/* /var/www/grav/
sudo mv /var/www/grav-admin/.* /var/www/grav/ 2>/dev/null || true
sudo rm -rf /var/www/grav-admin grav-admin.zip

echo "🔑 Setting file permissions for Grav..."
sudo chown -R www-data:www-data /var/www/grav
sudo chmod -R 775 /var/www/grav

echo "⚙️ Configuring Nginx for Grav..."
sudo tee /etc/nginx/sites-available/grav > /dev/null <<EOF
server {
    listen 80;
    server_name $LXC_IP;

    root /var/www/grav;
    index index.php index.html;

    location / {
        try_files \$uri \$uri/ /index.php?\$query_string;
    }

    location ~ \.php\$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/run/php/$PHP_VERSION-fpm.sock;
        fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
        include fastcgi_params;
    }

    location ~* /\. {
        deny all;
    }
}
EOF

echo "🔗 Enabling Grav site in Nginx..."
sudo ln -s /etc/nginx/sites-available/grav /etc/nginx/sites-enabled/ 2>/dev/null || true
sudo rm -f /etc/nginx/sites-enabled/default
sudo nginx -t && sudo systemctl restart nginx

echo "🛠️ Testing PHP processing..."
echo "<?php phpinfo(); ?>" | sudo tee /var/www/grav/phpinfo.php

echo "🧹 Clearing Grav cache..."
cd /var/www/grav
sudo -u www-data php bin/grav clearcache

echo "🎉 Grav CMS setup complete!"
echo "🌍 Access your site at: http://$LXC_IP/admin"
