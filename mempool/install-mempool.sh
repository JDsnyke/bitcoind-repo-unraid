#!/bin/bash

# Umbrel Mempool Installation Script for Unraid
# This script installs the Umbrel Mempool app on Unraid systems

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration variables
APP_NAME="Umbrel Mempool"
CONTAINER_NAME="umbrel-mempool"
DB_CONTAINER_NAME="umbrel-mempool-db"
IMAGE_NAME="mempool/backend:v3.2.1"
DB_IMAGE_NAME="mysql:8.0"
DATA_DIR="/mnt/user/appdata/umbrel-mempool"
MYSQL_DATA_DIR="/mnt/user/appdata/umbrel-mempool-mysql"
CONFIG_FILE="$DATA_DIR/mempool.conf"
TEMPLATE_FILE="mempool.conf.template"

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

# Function to check if Bitcoin node is running
check_bitcoin_node() {
    print_status "Checking if Bitcoin node is running..."
    
    if ! docker ps --format "table {{.Names}}" | grep -q "umbrel-bitcoin"; then
        print_error "Bitcoin node (umbrel-bitcoin) is not running. Please install and start the Bitcoin node first."
        print_error "Installation order: 1) Bitcoin, 2) Mempool"
        exit 1
    fi
    
    print_status "Checking Bitcoin node sync status..."
    if ! docker exec umbrel-bitcoin bitcoin-cli -rpcuser=umbrel -rpcpassword=moneyprintergobrrr getblockchaininfo > /dev/null 2>&1; then
        print_warning "Bitcoin node is running but RPC connection failed. This may be normal during initial sync."
        print_warning "Please ensure Bitcoin node is fully synced before continuing."
        read -p "Continue anyway? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            print_error "Installation aborted. Please wait for Bitcoin sync to complete."
            exit 1
        fi
    else
        print_success "Bitcoin node is running and accessible"
    fi
}

# Function to check if Electrs is running (optional)
check_electrs() {
    print_status "Checking if Electrs is running (optional)..."
    
    if docker ps --format "table {{.Names}}" | grep -q "umbrel-electrs"; then
        print_success "Electrs detected - enhanced functionality will be available"
    else
        print_warning "Electrs not found - basic functionality only. Consider installing Electrs for enhanced features."
    fi
}

# Function to create data directories
create_data_dirs() {
    print_status "Creating data directories"
    
    # Create main data directory
    mkdir -p "$DATA_DIR"
    chown -R nobody:users "$DATA_DIR"
    chmod -R 755 "$DATA_DIR"
    
    # Create MySQL data directory
    mkdir -p "$MYSQL_DATA_DIR"
    chown -R nobody:users "$MYSQL_DATA_DIR"
    chmod -R 755 "$MYSQL_DATA_DIR"
    
    print_success "Data directories created with proper permissions"
}

# Function to create configuration file
create_config() {
    print_status "Creating Mempool configuration file"
    
    if [[ -f "$TEMPLATE_FILE" ]]; then
        cp "$TEMPLATE_FILE" "$CONFIG_FILE"
        print_success "Configuration file created from template"
    else
        print_warning "Template file not found, creating basic configuration"
        cat > "$CONFIG_FILE" << EOF
# Umbrel Mempool Configuration
NETWORK=mainnet
BITCOIN_HOST=umbrel-bitcoin
BITCOIN_PORT=8332
BITCOIN_USERNAME=umbrel
    BITCOIN_PASSWORD=moneyprintergobrrr
BITCOIN_P2P_HOST=umbrel-bitcoin
BITCOIN_P2P_PORT=8333
BITCOIN_DATA_DIR=/mnt/user/appdata/umbrel-bitcoin/.bitcoin
MYSQL_HOST=umbrel-mempool-db
MYSQL_PORT=3306
MYSQL_DATABASE=mempool
MYSQL_USERNAME=mempool
    MYSQL_PASSWORD=moneyprintergobrrr
HTTP_PORT=3000
API_PORT=8999
ENABLE_ELECTRS=true
ELECTRS_HOST=umbrel-electrs
ELECTRS_PORT=50001
EOF
        print_success "Basic configuration file created"
    fi
    
    # Set proper permissions
    chown nobody:users "$CONFIG_FILE"
    chmod 644 "$CONFIG_FILE"
}

# Function to stop and remove existing containers
cleanup_existing() {
    print_status "Checking for existing Mempool containers"
    
    # Stop and remove Mempool container
    if docker ps -a --format "table {{.Names}}" | grep -q "$CONTAINER_NAME"; then
        print_status "Stopping existing container: $CONTAINER_NAME"
        docker stop "$CONTAINER_NAME" || true
        docker rm "$CONTAINER_NAME" || true
        print_success "Existing Mempool container cleaned up"
    fi
    
    # Stop and remove MySQL container
    if docker ps -a --format "table {{.Names}}" | grep -q "$DB_CONTAINER_NAME"; then
        print_status "Stopping existing container: $DB_CONTAINER_NAME"
        docker stop "$DB_CONTAINER_NAME" || true
        docker rm "$DB_CONTAINER_NAME" || true
        print_success "Existing MySQL container cleaned up"
    fi
}

# Function to pull Docker images
pull_images() {
    print_status "Pulling Docker images"
    
    docker pull "$IMAGE_NAME"
    docker pull "$DB_IMAGE_NAME"
    
    print_success "Docker images pulled successfully"
}

# Function to start MySQL container
start_mysql() {
    print_status "Starting MySQL container"
    
    docker run -d \
        --name "$DB_CONTAINER_NAME" \
        --restart unless-stopped \
        -e MYSQL_ROOT_PASSWORD=rootpassword \
        -e MYSQL_DATABASE=mempool \
        -e MYSQL_USER=mempool \
        -e MYSQL_PASSWORD=moneyprintergobrrr \
        -v "$MYSQL_DATA_DIR:/var/lib/mysql" \
        --network bridge \
        "$DB_IMAGE_NAME"
    
    print_success "MySQL container started"
    
    # Wait for MySQL to be ready
    print_status "Waiting for MySQL to be ready..."
    sleep 10
    until docker exec "$DB_CONTAINER_NAME" mysqladmin ping -h localhost -u mempool -pmoneyprintergobrrr --silent; do
        echo "MySQL not ready, waiting..."
        sleep 5
    done
    print_success "MySQL is ready"
}

# Function to start Mempool container
start_mempool() {
    print_status "Starting Mempool container"
    
    docker run -d \
        --name "$CONTAINER_NAME" \
        --restart unless-stopped \
        -p 3003:3000 \
        -p 8999:8999 \
        -v "$DATA_DIR:/app/mempool" \
        -e MEMPOOL_NETWORK=mainnet \
        -e MEMPOOL_BITCOIN_HOST=umbrel-bitcoin \
        -e MEMPOOL_BITCOIN_PORT=8332 \
        -e MEMPOOL_BITCOIN_USERNAME=umbrel \
        -e MEMPOOL_BITCOIN_PASSWORD=moneyprintergobrrr \
        -e MEMPOOL_BITCOIN_P2P_HOST=umbrel-bitcoin \
        -e MEMPOOL_BITCOIN_P2P_PORT=8333 \
        -e MEMPOOL_BITCOIN_DATA_DIR=/mnt/user/appdata/umbrel-bitcoin/.bitcoin \
        -e MEMPOOL_MYSQL_HOST=umbrel-mempool-db \
        -e MEMPOOL_MYSQL_PORT=3306 \
        -e MEMPOOL_MYSQL_DATABASE=mempool \
        -e MEMPOOL_MYSQL_USERNAME=mempool \
        -e MEMPOOL_MYSQL_PASSWORD=moneyprintergobrrr \
        -e MEMPOOL_HTTP_PORT=3000 \
        -e MEMPOOL_API_PORT=8999 \
        -e MEMPOOL_ENABLE_ELECTRS=true \
        -e MEMPOOL_ELECTRS_HOST=umbrel-electrs \
        -e MEMPOOL_ELECTRS_PORT=50001 \
        --network bridge \
        "$IMAGE_NAME"
    
    print_success "Mempool container started"
}

# Function to check container status
check_status() {
    print_status "Checking container status..."
    sleep 10
    
    # Check MySQL container
    if docker ps --format "table {{.Names}}" | grep -q "$DB_CONTAINER_NAME"; then
        print_success "MySQL container is running"
    else
        print_error "MySQL container failed to start"
        docker logs "$DB_CONTAINER_NAME" || true
        exit 1
    fi
    
    # Check Mempool container
    if docker ps --format "table {{.Names}}" | grep -q "$CONTAINER_NAME"; then
        print_success "Mempool container is running"
        
        print_status "Mempool container logs (last 10 lines):"
        docker logs --tail 10 "$CONTAINER_NAME"
        
        print_status "Container status:"
        docker ps --filter "name=$CONTAINER_NAME" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
        
    else
        print_error "Mempool container failed to start"
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
    echo "1. Wait for Mempool to fully sync (this may take some time)"
    echo "2. Access the web interface: http://your_server_ip:3003"
    echo "3. Access the REST API: http://your_server_ip:8999"
    echo "4. Check MySQL database: umbrel-mempool-db container"
    echo
    print_status "Important notes:"
    echo "- Mempool requires a fully synced Bitcoin node to function"
    echo "- Default passwords are 'moneyprintergobrrr' - CHANGE THESE in production!"
    echo "- Data is stored in: $DATA_DIR"
    echo "- MySQL data is stored in: $MYSQL_DATA_DIR"
    echo "- Check container logs: docker logs $CONTAINER_NAME"
    echo
    print_warning "Remember: Mempool is a Bitcoin-dependent app. Bitcoin node must be running and synced."
    print_warning "Electrs integration is optional but recommended for enhanced functionality."
}

# Main installation function
main() {
    echo -e "${BLUE}================================${NC}"
    echo -e "${BLUE}  Umbrel Mempool Installer${NC}"
    echo -e "${BLUE}================================${NC}"
    echo
    
    # Run all checks
    check_root
    check_unraid
    check_docker
    check_ca_plugin
    check_appdata
    check_bitcoin_node
    check_electrs
    
    # Perform installation
    create_data_dirs
    create_config
    cleanup_existing
    pull_images
    start_mysql
    start_mempool
    check_status
    
    # Display completion message
    display_next_steps
}

# Run main function
main "$@"
