#!/bin/bash

set -e

### === CONFIGURATION ===
DB_ROOT_PASS="StrongRootPass123!"
DB_NAME="wordpress"
DB_USER="wpuser"
DB_PASS="StrongWPUserPass123!"
DOMAIN="www.test.com"
PHP_VERSION="8.2"
WP_DIR="/var/www/html/wordpress"

### === UPDATE SYSTEM AND INSTALL DEPENDENCIES ===
apt update && apt upgrade -y
apt install -y nginx mariadb-server php${PHP_VERSION}-fpm php${PHP_VERSION}-mysql \
php${PHP_VERSION}-cli php${PHP_VERSION}-xml php${PHP_VERSION}-mbstring \
php${PHP_VERSION}-curl php${PHP_VERSION}-zip php${PHP_VERSION}-gd php-common \
wget unzip curl

### === TUNE PHP CONFIGURATION ===
PHP_INI="/etc/php/${PHP_VERSION}/fpm/php.ini"
sed -i "s/^max_execution_time = .*/max_execution_time = 300/" "$PHP_INI"
sed -i "s/^memory_limit = .*/memory_limit = 2048M/" "$PHP_INI"
sed -i "s/^post_max_size = .*/post_max_size = 256M/" "$PHP_INI"
sed -i "s/^upload_max_filesize = .*/upload_max_filesize = 2048M/" "$PHP_INI"
systemctl restart php${PHP_VERSION}-fpm

### === SECURE MARIADB INSTALLATION ===
mysql --user=root <<EOF
ALTER USER 'root'@'localhost' IDENTIFIED BY '${DB_ROOT_PASS}';
DELETE FROM mysql.user WHERE User='';
DROP DATABASE IF EXISTS test;
DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';
FLUSH PRIVILEGES;
EOF

### === CREATE WORDPRESS DATABASE AND USER ===
mysql -u root -p"${DB_ROOT_PASS}" <<EOF
CREATE DATABASE ${DB_NAME} CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER '${DB_USER}'@'localhost' IDENTIFIED BY '${DB_PASS}';
GRANT ALL PRIVILEGES ON ${DB_NAME}.* TO '${DB_USER}'@'localhost';
FLUSH PRIVILEGES;
EOF

### === DOWNLOAD AND EXTRACT WORDPRESS ===
wget https://wordpress.org/latest.tar.gz -O /tmp/wordpress.tar.gz
rm -rf "$WP_DIR"
tar -xzf /tmp/wordpress.tar.gz -C /var/www/html/
chown -R www-data:www-data "$WP_DIR"
chmod -R 755 "$WP_DIR"

### === CONFIGURE NGINX ===
cat > /etc/nginx/sites-available/wordpress <<EOF
server {
    listen 80;
    server_name ${DOMAIN};

    root ${WP_DIR};
    index index.php index.html;

    location / {
        try_files \$uri \$uri/ /index.php?\$args;
    }

    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/run/php/php${PHP_VERSION}-fpm.sock;
    }

    location ~ /\.ht {
        deny all;
    }
}
EOF

ln -sf /etc/nginx/sites-available/wordpress /etc/nginx/sites-enabled/wordpress
rm -f /etc/nginx/sites-enabled/default
nginx -t && systemctl reload nginx

### === COMPLETE ===
echo -e "\n\033[1;32mWordPress installation complete!\033[0m"
echo "----------------------------------------------"
echo "Site URL:      http://${DOMAIN}/wordpress"
echo "DB Name:       ${DB_NAME}"
echo "DB User:       ${DB_USER}"
echo "DB Password:   ${DB_PASS}"
echo "PHP Version:   ${PHP_VERSION}"
echo "Web Root:      ${WP_DIR}"
echo "----------------------------------------------"
