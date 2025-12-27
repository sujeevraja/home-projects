#!/bin/bash

# ==========================================
# CONFIGURATION - Edit these values
# ==========================================
NAS_IP="192.168.0.230"
NAS_SHARE="Public/Archana/Arch_Suj/pics/latest display"  # The name of the folder shared on QNAP
NAS_USER="admin_archsuj"
NAS_PASS="Cantor889"

# Note: if you change this folder, you have to unmount the NAS folder manually with
# `sudo umount folder/name`.
MOUNT_POINT="/home/sujeev/Desktop/qnap_photos" # Where it will appear on your Pi
# ==========================================

# 1. Install cifs-utils if not present
if ! dpkg -s cifs-utils >/dev/null 2>&1; then
    echo "Installing cifs-utils..."
    sudo apt-get update && sudo apt-get install -y cifs-utils
fi

# 2. Create the mount point if it doesn't exist
if [ ! -d "$MOUNT_POINT" ]; then
    echo "Creating mount point at $MOUNT_POINT"
    sudo mkdir -p "$MOUNT_POINT"
    sudo chown pi:pi "$MOUNT_POINT"
fi

# 3. Check if already mounted
if mountpoint -q "$MOUNT_POINT"; then
    echo "Device is already mounted at $MOUNT_POINT. Unmounting first..."
    sudo umount "$MOUNT_POINT"
fi

# 4. Mount the drive
echo "Attempting to mount //$NAS_IP/$NAS_SHARE..."
sudo mount -t cifs "//$NAS_IP/$NAS_SHARE" "$MOUNT_POINT" \
    -o username="$NAS_USER",password="$NAS_PASS",uid=$(id -u),gid=$(id -g),vers=3.0

# 5. Verify success
if [ $? -eq 0 ]; then
    echo "Successfully mounted NAS to $MOUNT_POINT"
    ls -l "$MOUNT_POINT" | head -n 5
else
    echo "Error: Failed to mount NAS."
    exit 1
fi

