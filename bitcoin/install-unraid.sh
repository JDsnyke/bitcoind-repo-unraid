#!/bin/bash

# Umbrel Bitcoin Installation Script for Unraid
# This script helps install the Umbrel Bitcoin container on Unraid manually

set -e

echo "=== Umbrel Bitcoin Installation Script for Unraid ==="
echo ""

# Check if running on Unraid
if [ ! -f "/proc/version" ] || ! grep -q "unraid" /proc/version; then
    echo "Warning: This script is designed for Unraid systems."
    echo "Continue anyway? (y/N)"
    read -r response
    if [[ ! "$response" =~ ^[Yy]$ ]]; then
        echo "Installation cancelled."
        exit 1
    fi
fi

# Check if running as root (required for Unraid)
if [ "$EUID" -ne 0 ]; then
    echo "Error: This script must be run as root on Unraid systems."
    echo "Please run with: sudo $0"
    exit 1
fi

# Check if Docker is available
if ! command -v docker &> /dev/null; then
    echo "Error: Docker is not installed or not available."
    echo "Please install Docker first through the Unraid WebGUI."
    exit 1
fi

# Check if Community Applications is available
if [ -d "/boot/config/plugins/dockerMan" ]; then
    echo "Community Applications detected. It's recommended to install through the Apps tab instead."
    echo "Continue with manual installation? (y/N)"
    read -r response
    if [[ ! "$response" =~ ^[Yy]$ ]]; then
        echo "Please install through Community Applications instead."
        exit 1
    fi
fi

# Configuration
APP_NAME="umbrel-bitcoin"
DATA_DIR="/mnt/user/appdata/${APP_NAME}"
CONTAINER_NAME="${APP_NAME}"
IMAGE_NAME="getumbrel/bitcoin:latest"

echo "Configuration:"
echo "  App Name: ${APP_NAME}"
echo "  Data Directory: ${DATA_DIR}"
echo "  Container Name: ${CONTAINER_NAME}"
echo "  Image: ${IMAGE_NAME}"
echo ""

# Check if appdata share exists
if [ ! -d "/mnt/user/appdata" ]; then
    echo "Error: /mnt/user/appdata share does not exist."
    echo "Please create the appdata share in Unraid first."
    exit 1
fi

# Create data directory with proper permissions
echo "Creating data directory..."
mkdir -p "${DATA_DIR}"
chown -R nobody:users "${DATA_DIR}"
chmod -R 755 "${DATA_DIR}"

# Create bitcoin.conf if it doesn't exist
if [ ! -f "${DATA_DIR}/bitcoin.conf" ]; then
    echo "Creating bitcoin.conf template..."
    cat > "${DATA_DIR}/bitcoin.conf" << 'EOF'
# Bitcoin Core Configuration
network=mainnet
rpcuser=umbrel
rpcpassword=changeme
rpcbind=0.0.0.0
rpcallowip=0.0.0.0/0
rpcport=8332
port=8333
listen=1
disablewallet=1
txindex=1
blockfilterindex=1
prune=0
dbcache=450
maxmempool=300
EOF
    chown nobody:users "${DATA_DIR}/bitcoin.conf"
    chmod 644 "${DATA_DIR}/bitcoin.conf"
    echo "Created ${DATA_DIR}/bitcoin.conf"
    echo "IMPORTANT: Change the rpcpassword in bitcoin.conf!"
fi

# Pull the Docker image
echo "Pulling Docker image..."
docker pull "${IMAGE_NAME}"

# Stop and remove existing container if it exists
if docker ps -a --format "table {{.Names}}" | grep -q "^${CONTAINER_NAME}$"; then
    echo "Stopping existing container..."
    docker stop "${CONTAINER_NAME}" || true
    echo "Removing existing container..."
    docker rm "${CONTAINER_NAME}" || true
fi

# Create and start the container
echo "Creating and starting container..."
docker run -d \
    --name "${CONTAINER_NAME}" \
    --restart unless-stopped \
    -p 8332:8332 \
    -p 8333:8333 \
    -p 18332:18332 \
    -p 18333:18333 \
    -v "${DATA_DIR}:/home/umbrel/.bitcoin" \
    -e BITCOIN_NETWORK=mainnet \
    -e BITCOIN_RPC_USER=umbrel \
    -e BITCOIN_RPC_PASSWORD=changeme \
    -e BITCOIN_RPC_BIND=0.0.0.0 \
    -e BITCOIN_RPC_ALLOW_IP=0.0.0.0/0 \
    -e BITCOIN_DISABLE_WALLET=1 \
    -e BITCOIN_TXINDEX=1 \
    -e BITCOIN_BLOCKFILTERINDEX=1 \
    -e BITCOIN_PRUNING=0 \
    "${IMAGE_NAME}"

# Wait for container to start
echo "Waiting for container to start..."
sleep 5

# Check container status
if docker ps --format "table {{.Names}}" | grep -q "^${CONTAINER_NAME}$"; then
    echo ""
    echo "=== Installation Complete! ==="
    echo ""
    echo "Container Status:"
    docker ps --filter "name=${CONTAINER_NAME}"
    echo ""
    echo "Container Logs:"
    docker logs "${CONTAINER_NAME}" --tail 20
    echo ""
    echo "Next Steps:"
    echo "1. Change the RPC password in ${DATA_DIR}/bitcoin.conf"
    echo "2. Restart the container: docker restart ${CONTAINER_NAME}"
    echo "3. Monitor logs: docker logs -f ${CONTAINER_NAME}"
    echo "4. Access RPC at: http://YOUR_SERVER_IP:8332"
    echo ""
    echo "For Community Applications integration, copy umbrel-bitcoin.xml to:"
    echo "/boot/config/plugins/dockerMan/templates-user/"
    echo ""
    echo "Note: This Bitcoin node is required before installing Umbrel Electrs."
    echo "Wait for full blockchain sync before proceeding with Electrs installation."
    echo ""
else
    echo "Error: Container failed to start. Check logs:"
    docker logs "${CONTAINER_NAME}"
    exit 1
fi
