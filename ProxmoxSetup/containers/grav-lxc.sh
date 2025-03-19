#!/bin/bash

# Load shared functions
source ../misc/build.func

# Run system checks
root_check
shell_check
pve_check

# Default configuration
CTID=$(pvesh get /cluster/nextid)
HOSTNAME="grav"
DISK_SIZE="8G"
MEMORY="1024"
CORES="2"
BRIDGE="vmbr0"
IP="dhcp"

# Splash Screen
clear
echo "──────────────────────────────────────────"
echo "    🚀 Proxmox LXC Deployment Script"
echo "      Installing Grav CMS on Debian"
echo "──────────────────────────────────────────"
sleep 2

# Get Storage Selection
STORAGE=$(select_storage)

# Confirm settings
dialog --clear --title "Confirm Settings" --yesno "Proceed with:\n\n\
Container ID: $CTID\n\
Hostname: $HOSTNAME\n\
Disk Size: $DISK_SIZE\n\
Memory: $MEMORY MB\n\
Cores: $CORES\n\
Storage: $STORAGE\n\
Bridge: $BRIDGE\n\
IP Address: $IP\n\n\
Continue?" 20 50
response=$?

if [[ $response -ne 0 ]]; then
    msg_error "Installation aborted by user."
    exit 1
fi

# Create LXC container
msg_info "Creating LXC container with ID $CTID"
pct create $CTID local:vztmpl/debian-12-standard_12.2-1_amd64.tar.zst \
    --hostname $HOSTNAME \
    --storage $STORAGE \
    --rootfs ${DISK_SIZE}G \
    --memory $MEMORY \
    --cores $CORES \
    --net0 name=eth0,bridge=$BRIDGE,ip=$IP \
    --unprivileged 1 \
    --features nesting=1
msg_ok "LXC container $CTID created."

# Start LXC container
msg_info "Starting LXC container $CTID"
pct start $CTID
msg_ok "LXC container $CTID started."

# Install Grav CMS
msg_info "Installing Grav CMS in container $CTID"
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
"
msg_ok "Grav CMS installed."

echo "✅ Grav CMS now available at: http://$LXC_IP/admin"
