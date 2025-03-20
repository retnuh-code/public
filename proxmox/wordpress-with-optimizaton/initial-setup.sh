#!/bin/bash
set -e  # Exit on error

# Colors for output
YW=$(echo "\033[33m")
GN=$(echo "\033[1;92m")
RD=$(echo "\033[01;31m")
CL=$(echo "\033[m")
CM="${GN}✓${CL}"
CROSS="${RD}✗${CL}"

# Splash Screen
clear
echo -e "${YW}──────────────────────────────────────${CL}"
echo -e "    🚀 WordPress LXC Setup Script"
echo -e "    Installing & Configuring WordPress"
echo -e "${YW}──────────────────────────────────────${CL}"

# Ensure script is running as root
if [[ "$(id -u)" -ne 0 ]]; then
    echo -e "${CROSS} ${RD}Please run this script as root.${CL}"
    exit 1
fi

# Prompt for WordPress admin details
echo -e "${YW}Please enter your WordPress admin credentials:${CL}"
read -p "👤 Admin Username: " WP_ADMIN_USER
read -sp "🔑 Admin Password: " WP_ADMIN_PASS
echo ""
read -p "📧 Admin Email: " WP_ADMIN_EMAIL

# System update & install dependencies
echo -e "${YW}Updating system and installing dependencies...${CL}"
apt update && apt upgrade -y
apt install -y nginx mariadb-server php php-fpm php-cli php-mysql php-curl php-xml php-mbstring unzip wget curl redis-server

# MariaDB Setup
DB_NAME="wordpress"
DB_USER="wp_user"
DB_PASS="StrongRandomPassword"

echo -e "${YW}Setting up MariaDB database for WordPress...${CL}"
mysql -e "CREATE DATABASE ${DB_NAME};"
mysql -e "CREATE USER '${DB_USER}'@'localhost' IDENTIFIED BY '${DB_PASS}';"
mysql -e "GRANT ALL PRIVILEGES ON ${DB_NAME}.* TO '${DB_USER}'@'localhost';"
mysql -e "FLUSH PRIVILEGES;"

# Download & Extract WordPress
echo -e "${YW}Downloading and setting up WordPress...${CL}"
wget https://wordpress.org/latest.tar.gz
tar -xvzf latest.tar.gz
mv wordpress/* /var/www/html/
rm -rf latest.tar.gz wordpress

# Set proper permissions
echo -e "${YW}Setting correct file permissions...${CL}"
chown -R www-data:www-data /var/www/html
chmod -R 755 /var/www/html

# Fix WP-CLI permission issue
echo -e "${YW}Fixing WP-CLI permissions...${CL}"
mkdir -p /var/www/.wp-cli/cache/
chown -R www-data:www-data /var/www/.wp-cli
chmod -R 755 /var/www/.wp-cli

# Install & Verify WP-CLI
echo -e "${YW}Installing WP-CLI...${CL}"
wp_cli="/usr/local/bin/wp"
wget https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar -O $wp_cli
chmod +x $wp_cli
sudo -u www-data $wp_cli --version

# Generate wp-config.php
echo -e "${YW}Generating wp-config.php...${CL}"
sudo -u www-data bash -c "cd /var/www/html && $wp_cli config create --dbname='${DB_NAME}' --dbuser='${DB_USER}' --dbpass='${DB_PASS}' --dbhost='localhost' --skip-check"

# Install WordPress Core with User Input
echo -e "${YW}Running WordPress core installation...${CL}"
sudo -u www-data /usr/local/bin/wp --path=/var/www/html core install \
    --url="http://$(hostname -I | awk '{print $1}')" \
    --title="Coastal Tech Pros" \
    --admin_user="$WP_ADMIN_USER" \
    --admin_password="$WP_ADMIN_PASS" \
    --admin_email="$WP_ADMIN_EMAIL"

# Configure WordPress Settings
echo -e "${YW}Configuring WordPress settings...${CL}"
sudo -u www-data /usr/local/bin/wp --path=/var/www/html option update permalink_structure "/%postname%/"
sudo -u www-data /usr/local/bin/wp --path=/var/www/html option update blogdescription "Coastal Tech Pros - IT Solutions"
sudo -u www-data /usr/local/bin/wp --path=/var/www/html rewrite flush

# Configure NGINX
echo -e "${YW}Configuring NGINX for WordPress...${CL}"
cat <<EOF > /etc/nginx/sites-available/wordpress
server {
    listen 80;
    server_name localhost $(hostname -I | awk '{print $1}');
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
rm -f /etc/nginx/sites-enabled/default
systemctl restart nginx php8.2-fpm

# Install Essential Plugins (with fixed permissions)
echo -e "${YW}Installing essential WordPress plugins...${CL}"
sudo -u www-data /usr/local/bin/wp --path=/var/www/html plugin install elementor --activate
sudo -u www-data /usr/local/bin/wp --path=/var/www/html plugin install shortpixel-image-optimiser --activate
sudo -u www-data /usr/local/bin/wp --path=/var/www/html plugin install redis-cache --activate
sudo -u www-data /usr/local/bin/wp --path=/var/www/html plugin install seo-by-rank-math --activate

# Secure WordPress
echo -e "${YW}Securing WordPress...${CL}"
sudo -u www-data /usr/local/bin/wp --path=/var/www/html plugin install wordfence --activate
sudo -u www-data /usr/local/bin/wp --path=/var/www/html option update users_can_register 0
sudo -u www-data /usr/local/bin/wp --path=/var/www/html option update comment_registration 1

# Display Final Info
echo -e "${YW}──────────────────────────────────────${CL}"
echo -e " 🎉 Setup Complete!"
echo -e " 📌 WordPress is now available at:"
echo -e "    ➤ Local Access: ${GN}http://$(hostname -I | awk '{print $1}')/wp-admin${CL}"
echo -e " 🛠️ Admin Username: ${GN}$WP_ADMIN_USER${CL}"
echo -e " 🛠️ Admin Email: ${GN}$WP_ADMIN_EMAIL${CL}"
echo -e "${YW}──────────────────────────────────────${CL}"
