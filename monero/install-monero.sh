#!/bin/bash

# Umbrel Monero Installation Script for Unraid
# This script installs the Umbrel Monero app on Unraid systems

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration variables
APP_NAME="Umbrel Monero"
CONTAINER_NAME="umbrel-monero"
IMAGE_NAME="ghcr.io/sethforprivacy/simple-monerod:v0.18.4.1"
DATA_DIR="/mnt/user/appdata/umbrel-monero"
CONFIG_FILE="$DATA_DIR/monero.conf"
TEMPLATE_FILE="monero.conf.template"

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to check if running as root
check_root() {
    if [[ $EUID -ne 0 ]]; then
        print_error "This script must be run as root (use sudo)"
        exit 1
    fi
}

# Function to check if Unraid is running
check_unraid() {
    if [[ ! -f "/etc/unraid-version" ]]; then
        print_error "This script is designed for Unraid systems only"
        exit 1
    fi
    print_success "Unraid system detected"
}

# Function to check if Docker is running
check_docker() {
    if ! systemctl is-active --quiet docker; then
        print_error "Docker service is not running. Please start Docker first."
        exit 1
    fi
    print_success "Docker service is running"
}

# Function to check if Community Applications plugin is installed
check_ca_plugin() {
    if [[ ! -d "/boot/config/plugins/community.applications" ]]; then
        print_warning "Community Applications plugin not found. Installation will continue but you may need to install it manually."
    else
        print_success "Community Applications plugin detected"
    fi
}

# Function to check if appdata share exists
check_appdata() {
    if [[ ! -d "/mnt/user/appdata" ]]; then
        print_error "Appdata share does not exist. Please create the appdata share first."
        exit 1
    fi
    print_success "Appdata share found"
}

# Function to check available disk space
check_disk_space() {
    print_status "Checking available disk space..."
    
    # Get available space in GB
    AVAILABLE_SPACE=$(df -BG /mnt/user/appdata | awk 'NR==2 {print $4}' | sed 's/G//')
    
    if [[ $AVAILABLE_SPACE -lt 200 ]]; then
        print_warning "Available disk space: ${AVAILABLE_SPACE}GB"
        print_warning "Monero blockchain requires significant storage space (~150GB+ for mainnet)"
        print_warning "Consider using a larger drive or enabling pruning"
        read -p "Continue anyway? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            print_error "Installation aborted. Please ensure sufficient disk space."
            exit 1
        fi
    else
        print_success "Available disk space: ${AVAILABLE_SPACE}GB (sufficient)"
    fi
}

# Function to create data directory
create_data_dir() {
    print_status "Creating data directory: $DATA_DIR"
    mkdir -p "$DATA_DIR"
    
    # Set proper ownership for Unraid
    chown -R nobody:users "$DATA_DIR"
    chmod -R 755 "$DATA_DIR"
    print_success "Data directory created with proper permissions"
}

# Function to create configuration file
create_config() {
    print_status "Creating Monero configuration file"
    
    if [[ -f "$TEMPLATE_FILE" ]]; then
        cp "$TEMPLATE_FILE" "$CONFIG_FILE"
        print_success "Configuration file created from template"
    else
        print_warning "Template file not found, creating basic configuration"
        cat > "$CONFIG_FILE" << EOF
# Umbrel Monero Configuration
network=mainnet
rpc-bind-ip=0.0.0.0
rpc-bind-port=18089
rpc-login=monero:moneyprintergobrrr
restricted-rpc=1
disable-rpc-login=0
p2p-bind-ip=0.0.0.0
p2p-bind-port=18090
zmq-rpc-bind-ip=0.0.0.0
zmq-rpc-bind-port=18091
zmq-pub-bind-ip=0.0.0.0
zmq-pub-bind-port=18092
data-dir=/home/monero/.bitmonero
sync-mode=fast
prune=0
db-salvage=0
max-concurrency=0
prepare-multisig=0
offline=0
log-level=1
EOF
        print_success "Basic configuration file created"
    fi
    
    # Set proper permissions
    chown nobody:users "$CONFIG_FILE"
    chmod 644 "$CONFIG_FILE"
}

# Function to stop and remove existing container
cleanup_existing() {
    print_status "Checking for existing Monero container"
    
    if docker ps -a --format "table {{.Names}}" | grep -q "$CONTAINER_NAME"; then
        print_status "Stopping existing container: $CONTAINER_NAME"
        docker stop "$CONTAINER_NAME" || true
        
        print_status "Removing existing container: $CONTAINER_NAME"
        docker rm "$CONTAINER_NAME" || true
        
        print_success "Existing container cleaned up"
    else
        print_status "No existing Monero container found"
    fi
}

# Function to pull Docker image
pull_image() {
    print_status "Pulling Docker image: $IMAGE_NAME"
    docker pull "$IMAGE_NAME"
    print_success "Docker image pulled successfully"
}

# Function to start Monero container
start_container() {
    print_status "Starting Monero container"
    
    docker run -d \
        --name "$CONTAINER_NAME" \
        --restart unless-stopped \
        -p 18089:18089 \
        -p 18090:18090 \
        -p 18091:18091 \
        -p 18092:18092 \
        -v "$DATA_DIR:/home/monero/.bitmonero" \
        -e MONERO_NETWORK=mainnet \
        -e MONERO_RPC_BIND_IP=0.0.0.0 \
        -e MONERO_RPC_BIND_PORT=18089 \
        -e MONERO_P2P_BIND_IP=0.0.0.0 \
        -e MONERO_P2P_BIND_PORT=18090 \
        -e MONERO_ZMQ_RPC_BIND_IP=0.0.0.0 \
        -e MONERO_ZMQ_RPC_BIND_PORT=18091 \
        -e MONERO_ZMQ_PUB_BIND_IP=0.0.0.0 \
        -e MONERO_ZMQ_PUB_BIND_PORT=18092 \
        -e MONERO_RPC_LOGIN=monero:moneyprintergobrrr \
        -e MONERO_RESTRICTED_RPC=1 \
        -e MONERO_DISABLE_RPC_LOGIN=0 \
        -e MONERO_SYNC_MODE=fast \
        -e MONERO_PRUNING=0 \
        -e MONERO_DB_SALVAGE=0 \
        -e MONERO_MAX_CONCURRENCY=0 \
        -e MONERO_PREPARE_MULTISIG=0 \
        -e MONERO_OFFLINE=0 \
        -e MONERO_DATA_DIR=/home/monero/.bitmonero \
        -e MONERO_LOG_LEVEL=1 \
        --network bridge \
        "$IMAGE_NAME"
    
    print_success "Monero container started"
}

# Function to check container status
check_status() {
    print_status "Checking container status..."
    sleep 10
    
    if docker ps --format "table {{.Names}}" | grep -q "$CONTAINER_NAME"; then
        print_success "Monero container is running"
        
        print_status "Container logs (last 10 lines):"
        docker logs --tail 10 "$CONTAINER_NAME"
        
        print_status "Container status:"
        docker ps --filter "name=$CONTAINER_NAME" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
        
    else
        print_error "Monero container failed to start"
        print_status "Container logs:"
        docker logs "$CONTAINER_NAME" || true
        exit 1
    fi
}

# Function to display next steps
display_next_steps() {
    echo
    print_success "=== Installation Complete ==="
    echo
    print_status "Next steps:"
    echo "1. Wait for Monero blockchain to fully sync (this may take several days)"
    echo "2. Access the RPC interface: http://your_server_ip:18089"
    echo "3. Connect Monero wallets to: your_server_ip:18089"
    echo "4. Use ZMQ for real-time updates: your_server_ip:18091-18092"
    echo
    print_status "Important notes:"
    echo "- Monero is a standalone cryptocurrency (no Bitcoin dependency)"
    echo "- Default RPC password is 'moneyprintergobrrr' - CHANGE THIS in production!"
    echo "- Data is stored in: $DATA_DIR"
    echo "- Check container logs: docker logs $CONTAINER_NAME"
    echo "- Initial sync will download ~150GB+ of blockchain data"
    echo
    print_warning "Storage requirements:"
    echo "- Mainnet: ~150GB+ (growing)"
    echo "- Testnet: ~50GB+ (growing)"
    echo "- Stagenet: ~25GB+ (growing)"
    echo
    print_status "Performance tips:"
    echo "- Use SSD storage for better performance"
    echo "- Consider enabling pruning for storage optimization"
    echo "- Monitor resource usage during initial sync"
}

# Main installation function
main() {
    echo -e "${BLUE}================================${NC}"
    echo -e "${BLUE}  Umbrel Monero Installer${NC}"
    echo -e "${BLUE}================================${NC}"
    echo
    
    # Run all checks
    check_root
    check_unraid
    check_docker
    check_ca_plugin
    check_appdata
    check_disk_space
    
    # Perform installation
    create_data_dir
    create_config
    cleanup_existing
    pull_image
    start_container
    check_status
    
    # Display completion message
    display_next_steps
}

# Run main function
main "$@"
