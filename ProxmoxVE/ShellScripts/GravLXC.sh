#!/bin/bash
# Proxmox LXC Deployment Script for Grav CMS
# This script creates a Debian LXC container, installs Grav CMS, and makes it accessible via its local IP.

set -e  # Exit on error

# Default Settings
CTID=$(pvesh get /cluster/nextid)  # Get next available container ID
HOSTNAME="grav"
TEMPLATE="local:vztmpl/debian-12-standard_12.2-1_amd64.tar.zst"
DISK_SIZE="8G"
MEMORY="1024"
CORES="2"
BRIDGE="vmbr0"
IP="dhcp"

# Get user input for configuration
read -p "Enter LXC Container ID (default: $CTID): " INPUT_CTID
CTID=${INPUT_CTID:-$CTID}

read -p "Enter LXC Hostname (default: $HOSTNAME): " INPUT_HOSTNAME
HOSTNAME=${INPUT_HOSTNAME:-$HOSTNAME}

read -p "Enter LXC Disk Size (default: $DISK_SIZE): " INPUT_DISK_SIZE
DISK_SIZE=${INPUT_DISK_SIZE:-$DISK_SIZE}

read -p "Enter LXC Memory (default: $MEMORY MB): " INPUT_MEMORY
MEMORY=${INPUT_MEMORY:-$MEMORY}

read -p "Enter LXC Cores (default: $CORES): " INPUT_CORES
CORES=${INPUT_CORES:-$CORES}

read -p "Enter Network Bridge (default: $BRIDGE): " INPUT_BRIDGE
BRIDGE=${INPUT_BRIDGE:-$BRIDGE}

read -p "Enter IP Address (default: DHCP): " INPUT_IP
IP=${INPUT_IP:-$IP}

echo "🚀 Creating Debian LXC Container with ID $CTID and Hostname $HOSTNAME..."

# Create the container
pct create $CTID $TEMPLATE \
    --hostname $HOSTNAME \
    --storage local-lvm \
    --rootfs $DISK_SIZE \
    --memory $MEMORY \
    --cores $CORES \
    --net0 name=eth0,bridge=$BRIDGE,ip=$IP \
    --unprivileged 1 \
    --features nesting=1

# Start the container
echo "🚀 Starting LXC Container..."
pct start $CTID
sleep 5

# Get the container's IP address
LXC_IP=$(pct exec $CTID -- ip -4 -o addr show eth0 | awk '{print $4}' | cut -d'/' -f1)

# Ensure networking is ready
while [[ -z "$LXC_IP" ]]; do
    echo "⏳ Waiting for IP assignment..."
    sleep 5
    LXC_IP=$(pct exec $CTID -- ip -4 -o addr show eth0 | awk '{print $4}' | cut -d'/' -f1)
done

echo "✅ Container is running with IP: $LXC_IP"

# Install Grav and Dependencies
echo "🚀 Installing Grav CMS inside container..."
pct exec $CTID -- bash -c "
    apt update && apt upgrade -y
    apt install -y php php-fpm php-cli php-gd php-curl php-zip php-mbstring php-xml unzip rsync git wget curl nginx

    # Set up web directory
    mkdir -p /var/www
    cd /var/www
    wget https://getgrav.org/download/core/grav-admin/latest -O grav-admin.zip
    unzip grav-admin.zip
    mv grav-admin grav
    chown -R www-data:www-data /var/www/grav
    chmod -R 775 /var/www/grav

    # Configure Nginx
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
        fastcgi_pass unix:/run/php/php-fpm.sock;
        fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
        include fastcgi_params;
    }
}
EOF

    ln -s /etc/nginx/sites-available/grav /etc/nginx/sites-enabled/
    systemctl restart nginx
"

echo "✅ Grav CMS is now accessible at http://$LXC_IP"

