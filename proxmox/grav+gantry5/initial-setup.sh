#!/bin/bash

# Grav + Gantry5 Setup Script for a Blank Debian LXC
# Installs all dependencies, configures web server, and makes site accessible on local IP

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
echo -e "    - Configure Nginx, PHP, and Grav CMS"
echo -e "    - Set up the site for local IP access"
echo -e "${YW}──────────────────────────────────────────────${CL}"
sleep 2

# **Ensure the script is run as root**
if [[ "$(id -u)" -ne 0 ]]; then
    echo -e "${CROSS} ${RD}Please run this script as root.${CL}"
    exit 1
fi

# **User Input**
read -p "Enter Site Domain (Example: site.example.com) [Press Enter for Local Access]: " DOMAIN
DOMAIN=${DOMAIN:-"localhost"}

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
apt install -y php php-fpm php-cli php-gd php-curl php-zip php-mbstring php-xml unzip rsync git wget curl nginx

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

# **Configure Nginx**
echo -e "${YW}Configuring Nginx for Grav...${CL}"
cat <<EOF > /etc/nginx/sites-available/grav
server {
    listen 80;
    server_name $DOMAIN $LXC_IP;

    root /var/www/grav;
    index index.php index.html;

    location / {
        try_files \$uri \$uri/ /index.php?\$query_string;
    }

    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/run/php/php-fpm.sock;
        fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
        include fastcgi_params;
    }

    location ~* /\. {
        deny all;
    }
}
EOF

ln -s /etc/nginx/sites-available/grav /etc/nginx/sites-enabled/
systemctl restart nginx

# **Display Final Info**
echo -e "${YW}──────────────────────────────────────────────${CL}"
echo -e " 🎉 Setup Complete!"
echo -e " 📌 Grav + Gantry5 is now available at:"
echo -e "    ➤ Local Access: ${GN}http://$LXC_IP/admin${CL}"
if [[ "$DOMAIN" != "localhost" ]]; then
    echo -e "    ➤ Domain Access: ${GN}http://$DOMAIN/admin${CL}"
fi
echo -e "${YW}──────────────────────────────────────────────${CL}"
