#!/bin/bash

# Umbrel Electrs Installation Script for Unraid
# This script helps install the Umbrel Electrs container on Unraid manually

set -e

echo "=== Umbrel Electrs Installation Script for Unraid ==="
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
APP_NAME="umbrel-electrs"
DATA_DIR="/mnt/user/appdata/${APP_NAME}"
CONTAINER_NAME="${APP_NAME}"
IMAGE_NAME="getumbrel/electrs:latest"

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

# Check for Bitcoin node
echo "Checking for Bitcoin node..."
BITCOIN_CONTAINER=$(docker ps --filter "name=umbrel-bitcoin" --format "{{.Names}}" | head -1)
if [ -n "$BITCOIN_CONTAINER" ]; then
    echo "Found Bitcoin container: ${BITCOIN_CONTAINER}"
    BITCOIN_RPC_ADDR="umbrel-bitcoin:8332"
    BITCOIN_P2P_ADDR="umbrel-bitcoin:8333"
    echo "Using container networking: ${BITCOIN_RPC_ADDR}"
    
    # Check if Bitcoin node is synced
    echo "Checking Bitcoin node sync status..."
    if docker exec "${BITCOIN_CONTAINER}" bitcoin-cli -rpcuser=umbrel -rpcpassword=moneyprintergobrrr getblockchaininfo >/dev/null 2>&1; then
        echo "Bitcoin node is accessible and responding to RPC calls."
    else
        echo "Warning: Bitcoin node may not be fully synced or accessible."
        echo "Continue anyway? (y/N)"
        read -r response
        if [[ ! "$response" =~ ^[Yy]$ ]]; then
            echo "Please wait for Bitcoin node to fully sync before continuing."
            exit 1
        fi
    fi
else
    echo "No Bitcoin container found. You'll need to configure the connection manually."
    echo "Enter your Bitcoin node RPC address (e.g., 192.168.1.100:8332):"
    read -r BITCOIN_RPC_ADDR
    echo "Enter your Bitcoin node P2P address (e.g., 192.168.1.100:8333):"
    read -r BITCOIN_P2P_ADDR
fi

# Create data directory with proper permissions
echo "Creating data directory..."
mkdir -p "${DATA_DIR}"
chown -R nobody:users "${DATA_DIR}"
chmod -R 755 "${DATA_DIR}"

# Create electrs configuration if it doesn't exist
if [ ! -f "${DATA_DIR}/electrs.conf" ]; then
    echo "Creating electrs.conf template..."
    cat > "${DATA_DIR}/electrs.conf" << EOF
# Electrs Configuration
network = "bitcoin"
daemon_rpc_addr = "${BITCOIN_RPC_ADDR}"
daemon_rpc_user = "umbrel"
daemon_rpc_pass = "moneyprintergobrrr"
daemon_p2p_addr = "${BITCOIN_P2P_ADDR}"
electrum_rpc_addr = "0.0.0.0:50001"
electrum_rpc_addr_index = "0.0.0.0:50002"
http_addr = "0.0.0.0:3000"
verbosity = 4
monitoring_addr = "0.0.0.0:4224"
db_dir = "/home/electrs/.electrs/db"
index_batch_size = 10
index_limit = 1000
EOF
    chown nobody:users "${DATA_DIR}/electrs.conf"
    chmod 644 "${DATA_DIR}/electrs.conf"
    echo "Created ${DATA_DIR}/electrs.conf"
    echo "IMPORTANT: Change the daemon_rpc_pass in electrs.conf!"
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
    -p 3000:3000 \
    -p 50001:50001 \
    -p 50002:50002 \
    -p 4224:4224 \
    -v "${DATA_DIR}:/home/electrs/.electrs" \
    -e ELECTRS_NETWORK=bitcoin \
    -e ELECTRS_DAEMON_RPC_ADDR="${BITCOIN_RPC_ADDR}" \
    -e ELECTRS_DAEMON_RPC_USER=umbrel \
          -e ELECTRS_DAEMON_RPC_PASS=moneyprintergobrrr \
    -e ELECTRS_DAEMON_P2P_ADDR="${BITCOIN_P2P_ADDR}" \
    -e ELECTRS_ELECTRUM_RPC_ADDR=0.0.0.0:50001 \
    -e ELECTRS_ELECTRUM_RPC_ADDR_INDEX=0.0.0.0:50002 \
    -e ELECTRS_HTTP_ADDR=0.0.0.0:3000 \
    -e ELECTRS_VERBOSITY=4 \
    -e ELECTRS_MONITORING_ADDR=0.0.0.0:4224 \
    -e ELECTRS_DB_DIR=/home/electrs/.electrs/db \
    -e ELECTRS_INDEX_BATCH_SIZE=10 \
    -e ELECTRS_INDEX_LIMIT=1000 \
    "${IMAGE_NAME}"

# Wait for container to start
echo "Waiting for container to start..."
sleep 10

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
    echo "1. Change the RPC password in ${DATA_DIR}/electrs.conf"
    echo "2. Restart the container: docker restart ${CONTAINER_NAME}"
    echo "3. Monitor logs: docker logs -f ${CONTAINER_NAME}"
    echo "4. Access HTTP API at: http://YOUR_SERVER_IP:3000"
    echo "5. Connect Electrum wallets to: YOUR_SERVER_IP:50001"
    echo ""
    echo "For Community Applications integration, copy umbrel-electrs.xml to:"
    echo "/boot/config/plugins/dockerMan/templates-user/"
    echo ""
    echo "Note: Electrs requires a Bitcoin Core node to function properly."
    echo "Make sure your Bitcoin node is running and accessible."
    echo ""
    if [ -n "$BITCOIN_CONTAINER" ]; then
        echo "Bitcoin container detected: ${BITCOIN_CONTAINER}"
        echo "Electrs should automatically connect to it."
    else
        echo "No Bitcoin container detected. You may need to configure networking manually."
    fi
    echo ""
else
    echo "Error: Container failed to start. Check logs:"
    docker logs "${CONTAINER_NAME}"
    exit 1
fi
