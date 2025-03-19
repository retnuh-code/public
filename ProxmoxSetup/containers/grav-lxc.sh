#!/bin/bash
# Proxmox LXC Deployment Script for Grav CMS
# Deploys a Debian LXC, installs Grav CMS, and makes it accessible via its local IP.

set -e  # Exit on error

# Default Settings
CTID=$(pvesh get /cluster/nextid)  # Get next available container ID
HOSTNAME="grav"
TEMPLATE="local:vztmpl/debian-12-standard_12.2-1_amd64.tar.zst"
DISK_SIZE="8G"
MEMORY="1024"
CORES="2"
STORAGE="local-lvm"
BRIDGE="vmbr0"
IP="dhcp"

# Splash Screen
clear
echo "──────────────────────────────────────────"
echo "    🚀 Proxmox LXC Deployment Script"
echo "      Installing Grav CMS on Debian"
echo "──────────────────────────────────────────"
sleep 2

# User Input Handling
read -p "Enter LXC Container ID (default: $CTID): " INPUT_CTID
CTID=${INPUT_CTID:-$CTID}

read -p "Enter LXC Hostname (default: $HOSTNAME): " INPUT_HOSTNAME
HOSTNAME=${INPUT_HOSTNAME:-$HOSTNAME}

read -p "Enter LXC Disk Size in GB (default: $DISK_SIZE) [Example: 10G]: " INPUT_DISK_SIZE
DISK_SIZE=${INPUT_DISK_SIZE:-$DISK_SIZE}

read -p "Enter LXC Memory in MB (default: $MEMORY) [Example: 2048]: " INPUT_MEMORY
MEMORY=${INPUT_MEMORY:-$MEMORY}

read -p "Enter LXC Cores (default: $CORES) [Example: 4]: " INPUT_CORES
CORES=${INPUT_CORES:-$CORES}

read -p "Enter Storage Location (default: $STORAGE) [Example: local, local-lvm]: " INPUT_STORAGE
STORAGE=${INPUT_STORAGE:-$STORAGE}

read -p "Enter Network Bridge (default: $BRIDGE) [Example: vmbr0]: " INPUT_BRIDGE
BRIDGE=${INPUT_BRIDGE:-$BRIDGE}

read -p "Enter IP Address (default: DHCP) [Example: 192.168.1.100/24]: " INPUT_IP
IP=${INPUT_IP:-$IP}

[[ "$IP" == "dhcp" ]] && IP="dhcp"

echo "──────────────────────────────────────────"
echo "🚀 Creating Debian LXC Container with ID $CTID and Hostname $HOSTNAME..."
echo "──────────────────────────────────────────"

pct create $CTID $TEMPLATE \
    --hostname $HOSTNAME \
    --storage $STORAGE \
    --rootfs $DISK_SIZE \
    --memory $MEMORY \
    --cores $CORES \
    --net0 name=eth0,bridge=$BRIDGE,ip=$IP \
    --unprivileged 1 \
    --features nesting=1

echo "🚀 Starting LXC Container..."
pct start $CTID
sleep 5

LXC_IP=$(pct exec $CTID -- ip -4 -o addr show eth0 | awk '{print $4}' | cut -d'/' -f1)
while [[ -z "$LXC_IP" ]]; do
    echo "⏳ Waiting for IP assignment..."
    sleep 5
    LXC_IP=$(pct exec $CTID -- ip -4 -o addr show eth0 | awk '{print $4}' | cut -d'/' -f1)
done

echo "✅ Container is running with IP: $LXC_IP"
echo "──────────────────────────────────────────"
echo "🚀 Installing Grav CMS inside container..."
echo "──────────────────────────────────────────"

pct exec $CTID -- bash -c "
    apt update && apt upgrade -y
    apt install -y php php-fpm php-cli php-gd php-curl php-zip php-mbstring php-xml unzip rsync git wget curl nginx

    mkdir -p /var/www
    cd /var/www
    wget https://getgrav.org/download/core/grav-admin/latest -O grav-admin.zip
    unzip grav-admin.zip
    mv grav-admin grav
    chown -R www-data:www-data /var/www/grav
    chmod -R 775 /var/www/grav

    PHP_VERSION=\$(php -r 'echo PHP_MAJOR_VERSION.\".\".PHP_MINOR_VERSION;')
    PHP_FPM_SOCK=\"/run/php/php\$PHP_VERSION-fpm.sock\"

    cat <<EOF > /etc/nginx/sites-available/grav
server {
    listen 80;
    server_name $LXC_IP;

    root /var/www/grav;
    index index.php index.html;

    location / {
        try_files \$uri \$uri/ /index.php?\$query_string;
    }

    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:\$PHP_FPM_SOCK;
        fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
        include fastcgi_params;
    }
}
EOF

    ln -s /etc/nginx/sites-available/grav /etc/nginx/sites-enabled/
    systemctl restart nginx
"

echo "✅ Grav CMS is now accessible at: http://$LXC_IP"
echo "──────────────────────────────────────────"
echo "🎉 Deployment Complete!"
echo "  Visit: http://$LXC_IP/admin to configure Grav CMS."
echo "──────────────────────────────────────────"
