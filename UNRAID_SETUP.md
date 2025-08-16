# Unraid-Specific Setup Guide

This guide covers Unraid-specific considerations for running the Umbrel Bitcoin and Electrs Community Applications.

## Unraid System Requirements

### Operating System
- **Unraid 6.8+** (recommended: 6.12+)
- **Community Applications plugin** installed
- **Docker** enabled and configured

### Hardware Requirements
- **CPU**: x86_64 with virtualization support
- **RAM**: Minimum 4GB, recommended 8GB+
- **Storage**: 
  - **Bitcoin**: ~500GB+ for mainnet (growing)
  - **Electrs**: ~50-100GB for mainnet
  - **Cache drive**: SSD recommended for better performance

### Network
- **Port forwarding**: Configure router for external access (optional)
- **Firewall**: Ensure necessary ports are open

## Unraid-Specific File Structure

### Appdata Share
The apps store data in the Unraid `appdata` share:
```
/mnt/user/appdata/
├── umbrel-bitcoin/          # Bitcoin blockchain data
│   ├── .bitcoin/
│   ├── bitcoin.conf
│   └── debug.log
└── umbrel-electrs/          # Electrs database and config
    ├── .electrs/
    ├── electrs.conf
    └── db/
```

### Boot Configuration
Community Application templates are stored in:
```
/boot/config/plugins/dockerMan/templates-user/
├── umbrel-bitcoin.xml
└── umbrel-electrs.xml
```

## Installation Methods

### Method 1: Community Applications Plugin (Recommended)

The Community Applications plugin provides the easiest installation method with automatic template management and updates.

#### Prerequisites
1. **Install Community Applications Plugin**:
   - Go to **Apps** tab in Unraid WebGUI
   - Click **Install Apps** if not already installed
   - Search for "Community Applications" and install

2. **Copy Application Templates**:
   ```bash
   # Copy all templates to the user templates directory
   cp bitcoin/umbrel-bitcoin.xml /boot/config/plugins/dockerMan/templates-user/
   cp electrs/umbrel-electrs.xml /boot/config/plugins/dockerMan/templates-user/
   cp lightning/umbrel-lightning.xml /boot/config/plugins/dockerMan/templates-user/
   cp mempool/umbrel-mempool.xml /boot/config/plugins/dockerMan/templates-user/
   cp monero/umbrel-monero.xml /boot/config/plugins/dockerMan/templates-user/
   ```

3. **Install Applications**:
   - Go to **Apps** tab in Unraid WebGUI
   - Search for "Umbrel Bitcoin" and install first
   - Wait for Bitcoin sync completion
   - Install additional apps as needed

### Method 2: Docker Tab (Alternative)

The Docker tab provides manual container creation with full control over configuration.

#### Step 1: Install Bitcoin Node

1. **Navigate to Docker Tab**:
   - Go to **Docker** tab in Unraid WebGUI
   - Click **Add Container**

2. **Basic Settings**:
   - **Name**: `umbrel-bitcoin`
   - **Repository**: `getumbrel/bitcoin:latest`
   - **Icon**: Click the icon field and paste: `https://raw.githubusercontent.com/getumbrel/umbrel-apps/master/bitcoin/icon.png`
   - **WebUI**: `http://[IP]:[PORT:8332]`
   - **Network Type**: Bridge

3. **Port Mappings**:
   - **Port 8332**: `8332:8332` (RPC)
   - **Port 8333**: `8333:8333` (P2P)
   - **Port 18332**: `18332:18332` (testnet RPC)
   - **Port 18333**: `18333:18333` (testnet P2P)

4. **Volumes**:
   - **Container Path**: `/home/umbrel/.bitcoin`
   - **Host Path**: `/mnt/user/appdata/umbrel-bitcoin`
   - **Access Mode**: Read/Write

5. **Environment Variables**:
   ```
   BITCOIN_NETWORK=bitcoin
   BITCOIN_RPC_USER=umbrel
   BITCOIN_RPC_PASSWORD=your_secure_password_here
   BITCOIN_RPC_BIND=0.0.0.0:8332
   BITCOIN_RPC_ALLOW_IP=0.0.0.0/0
   BITCOIN_DISABLE_WALLET=0
   BITCOIN_TXINDEX=1
   BITCOIN_BLOCKFILTERINDEX=1
   BITCOIN_PRUNING=0
   ```

6. **Advanced Settings**:
   - **Post Arguments**: Leave empty (handled by environment variables)
   - **Extra Parameters**: Leave empty
   - **Console Shell**: `/bin/bash`
   - **Privileged**: Unchecked

7. **Click Apply** and wait for the container to start

#### Step 2: Install Electrs Server (After Bitcoin Sync)

1. **Add Container**:
   - **Name**: `umbrel-electrs`
   - **Repository**: `getumbrel/electrs:latest`
   - **Icon**: `https://raw.githubusercontent.com/getumbrel/umbrel-apps/master/electrs/icon.png`
   - **WebUI**: `http://[IP]:[PORT:3000]`
   - **Network Type**: Bridge

2. **Port Mappings**:
   - **Port 3000**: `3000:3000` (HTTP API)
   - **Port 50001**: `50001:50001` (Electrum RPC)
   - **Port 50002**: `50002:50002` (Electrum Index)
   - **Port 4224**: `4224:4224` (Monitoring)

3. **Volumes**:
   - **Container Path**: `/home/electrs/.electrs`
   - **Host Path**: `/mnt/user/appdata/umbrel-electrs`
   - **Access Mode**: Read/Write

4. **Environment Variables**:
   ```
   ELECTRS_NETWORK=bitcoin
   ELECTRS_DAEMON_RPC_ADDR=umbrel-bitcoin:8332
   ELECTRS_DAEMON_RPC_USER=umbrel
   ELECTRS_DAEMON_RPC_PASS=your_secure_password_here
   ELECTRS_DAEMON_P2P_ADDR=umbrel-bitcoin:8333
   ELECTRS_ELECTRUM_RPC_ADDR=0.0.0.0:50001
   ELECTRS_ELECTRUM_RPC_ADDR_INDEX=0.0.0.0:50002
   ELECTRS_HTTP_ADDR=0.0.0.0:3000
   ELECTRS_VERBOSITY=info
   ELECTRS_MONITORING_ADDR=0.0.0.0:4224
   ELECTRS_DB_DIR=/home/electrs/.electrs
   ELECTRS_INDEX_BATCH_SIZE=10
   ELECTRS_INDEX_LIMIT=1000
   ```

5. **Click Apply** and wait for the container to start

#### Step 3: Install Lightning Node (After Bitcoin Sync)

1. **Add Container**:
   - **Name**: `umbrel-lightning`
   - **Repository**: `getumbrel/lightning:latest`
   - **Icon**: `https://raw.githubusercontent.com/getumbrel/umbrel-apps/master/lightning/icon.png`
   - **WebUI**: `http://[IP]:[PORT:3000]`
   - **Network Type**: Bridge

2. **Port Mappings**:
   - **Port 3000**: `3000:3000` (Web Interface)
   - **Port 9735**: `9735:9735` (Lightning P2P)
   - **Port 8080**: `8080:8080` (REST API)

3. **Volumes**:
   - **Container Path**: `/home/lightning/.lightning`
   - **Host Path**: `/mnt/user/appdata/umbrel-lightning`
   - **Access Mode**: Read/Write

4. **Environment Variables**:
   ```
   LIGHTNING_NETWORK=bitcoin
   LIGHTNING_BITCOIN_RPC_HOST=umbrel-bitcoin
   LIGHTNING_BITCOIN_RPC_PORT=8332
   LIGHTNING_BITCOIN_RPC_USER=umbrel
   LIGHTNING_BITCOIN_RPC_PASSWORD=your_secure_password_here
   LIGHTNING_BITCOIN_RPC_PROTOCOL=http
   LIGHTNING_ALIAS=Umbrel Lightning
   LIGHTNING_COLOR=3399FF
   LIGHTNING_WEB_PORT=3000
   LIGHTNING_P2P_PORT=9735
   LIGHTNING_REST_PORT=8080
   LIGHTNING_LOG_LEVEL=info
   ```

5. **Click Apply** and wait for the container to start

#### Step 4: Install Mempool Explorer (After Bitcoin Sync)

1. **Add Container**:
   - **Name**: `umbrel-mempool`
   - **Repository**: `getumbrel/mempool:latest`
   - **Icon**: `https://raw.githubusercontent.com/getumbrel/umbrel-apps/master/mempool/icon.png`
   - **WebUI**: `http://[IP]:[PORT:3000]`
   - **Network Type**: Bridge

2. **Port Mappings**:
   - **Port 3000**: `3000:3000` (Web Interface)
   - **Port 8999**: `8999:8999` (REST API)

3. **Volumes**:
   - **Container Path**: `/app/mempool`
   - **Host Path**: `/mnt/user/appdata/umbrel-mempool`
   - **Access Mode**: Read/Write

4. **Environment Variables**:
   ```
   MEMPOOL_NETWORK=mainnet
   MEMPOOL_BITCOIN_HOST=umbrel-bitcoin
   MEMPOOL_BITCOIN_PORT=8332
   MEMPOOL_BITCOIN_USERNAME=umbrel
   MEMPOOL_BITCOIN_PASSWORD=your_secure_password_here
   MEMPOOL_BITCOIN_P2P_HOST=umbrel-bitcoin
   MEMPOOL_BITCOIN_P2P_PORT=8333
   MEMPOOL_BITCOIN_DATA_DIR=/mnt/user/appdata/umbrel-bitcoin/.bitcoin
   MEMPOOL_MYSQL_HOST=umbrel-mempool-db
   MEMPOOL_MYSQL_PORT=3306
   MEMPOOL_MYSQL_DATABASE=mempool
   MEMPOOL_MYSQL_USERNAME=mempool
   MEMPOOL_MYSQL_PASSWORD=your_mysql_password_here
   MEMPOOL_HTTP_PORT=3000
   MEMPOOL_API_PORT=8999
   MEMPOOL_ENABLE_ELECTRS=true
   MEMPOOL_ELECTRS_HOST=umbrel-electrs
   MEMPOOL_ELECTRS_PORT=50001
   ```

5. **Click Apply** and wait for the container to start

#### Step 5: Install Monero Node (Standalone)

1. **Add Container**:
   - **Name**: `umbrel-monero`
   - **Repository**: `getumbrel/monero:latest`
   - **Icon**: `https://raw.githubusercontent.com/getumbrel/umbrel-apps/master/monero/icon.png`
   - **WebUI**: `http://[IP]:[PORT:18089]`
   - **Network Type**: Bridge

2. **Port Mappings**:
   - **Port 18089**: `18089:18089` (RPC)
   - **Port 18090**: `18090:18090` (P2P)
   - **Port 18091**: `18091:18091` (ZMQ RPC)
   - **Port 18092**: `18092:18092` (ZMQ PUB)

3. **Volumes**:
   - **Container Path**: `/home/monero/.bitmonero`
   - **Host Path**: `/mnt/user/appdata/umbrel-monero`
   - **Access Mode**: Read/Write

4. **Environment Variables**:
   ```
   MONERO_NETWORK=mainnet
   MONERO_RPC_BIND_IP=0.0.0.0
   MONERO_RPC_BIND_PORT=18089
   MONERO_P2P_BIND_IP=0.0.0.0
   MONERO_P2P_BIND_PORT=18090
   MONERO_ZMQ_RPC_BIND_IP=0.0.0.0
   MONERO_ZMQ_RPC_BIND_PORT=18091
   MONERO_ZMQ_PUB_BIND_IP=0.0.0.0
   MONERO_ZMQ_PUB_BIND_PORT=18092
   MONERO_RPC_LOGIN=monero:your_secure_password_here
   MONERO_RESTRICTED_RPC=1
   MONERO_DISABLE_RPC_LOGIN=0
   MONERO_SYNC_MODE=fast
   MONERO_PRUNING=0
   MONERO_DB_SALVAGE=0
   MONERO_MAX_CONCURRENCY=0
   MONERO_PREPARE_MULTISIG=0
   MONERO_OFFLINE=0
   MONERO_DATA_DIR=/home/monero/.bitmonero
   MONERO_LOG_LEVEL=1
   ```

5. **Click Apply** and wait for the container to start

### Method 3: Manual Installation Scripts

#### Important Notes for Docker Tab Installation

##### Port Conflicts
When installing multiple apps through the Docker tab, you may encounter port conflicts:

- **Port 3000**: Used by Electrs, Lightning, and Mempool
- **Solution**: Change one or more apps to use different ports:
  - Electrs: Keep port 3000
  - Lightning: Change to port 3001
  - Mempool: Change to port 3002

##### Container Networking
For proper communication between containers:

1. **Use Container Names**: All containers should use the exact names specified:
   - `umbrel-bitcoin`
   - `umbrel-electrs`
   - `umbrel-lightning`
   - `umbrel-mempool`
   - `umbrel-monero`

2. **Network Type**: Use **Bridge** network type for all containers

3. **Container Communication**: Apps communicate using container names:
   - `umbrel-bitcoin:8332` (Bitcoin RPC)
   - `umbrel-bitcoin:8333` (Bitcoin P2P)
   - `umbrel-electrs:50001` (Electrs RPC)

##### Alternative Port Configurations

If you need to avoid port conflicts, here are alternative port mappings:

**Lightning with Alternative Ports**:
- **Port 3001**: `3001:3000` (Web Interface)
- **Port 9735**: `9735:9735` (Lightning P2P)
- **Port 8081**: `8081:8080` (REST API)

**Mempool with Alternative Ports**:
- **Port 3002**: `3002:3000` (Web Interface)
- **Port 8999**: `8999:8999` (REST API)

**Update Environment Variables** accordingly when changing ports.

##### Verification Steps

After installation, verify each container:

1. **Check Container Status**: All containers should show "Running" status
2. **Check Logs**: Look for any error messages in container logs
3. **Test Connectivity**: Verify apps can communicate with each other
4. **Check Ports**: Ensure no port conflicts exist

##### Troubleshooting Docker Tab Issues

**Container Won't Start**:
- Check for port conflicts
- Verify volume paths exist
- Check environment variable syntax
- Review container logs

**Apps Can't Communicate**:
- Verify container names match exactly
- Check network type is set to Bridge
- Ensure all containers are running
- Verify environment variables reference correct container names

**Permission Issues**:
- Ensure appdata share exists
- Check share permissions
- Verify user/group settings

##### Manual Installation Scripts

For advanced users who prefer command-line installation:

```bash
# Install Bitcoin first
cd bitcoin
sudo ./install-unraid.sh

# Wait for sync, then install additional apps
cd ../electrs
sudo ./install-electrs.sh

cd ../lightning
sudo ./install-lightning.sh

cd ../mempool
sudo ./install-mempool.sh

# Monero can be installed independently
cd ../monero
sudo ./install-monero.sh
```

**Requirements for Manual Installation**:
- Root access (`sudo` or run as root)
- Appdata share exists (`/mnt/user/appdata/`)
- Docker service running
- Community Applications plugin installed

## Unraid-Specific Configuration

### User Permissions
- **Default user**: `nobody:users` (UID: 99, GID: 100)
- **Data directories**: Owned by `nobody:users` with 755 permissions
- **Configuration files**: 644 permissions

### Volume Mappings
```yaml
# Bitcoin
volumes:
  - /mnt/user/appdata/umbrel-bitcoin:/home/umbrel/.bitcoin

# Electrs
volumes:
  - /mnt/user/appdata/umbrel-electrs:/home/electrs/.electrs
```

### Network Configuration
- **Bridge mode**: Default Docker networking
- **Container names**: `umbrel-bitcoin` and `umbrel-electrs`
- **Internal communication**: Uses container names for networking

## Unraid Best Practices

### Storage Configuration
1. **Use cache drive** for better performance
2. **Monitor array health** regularly
3. **Set appropriate share settings**:
   - **Use Cache**: `Prefer` or `Only`
   - **Split Level**: `Automatically split only as required`

### Docker Settings
1. **Enable Docker** in Settings → Docker
2. **Set Docker storage location** to cache drive if possible
3. **Configure Docker network** settings

### Backup Strategy
1. **Backup appdata share** regularly
2. **Export Docker container configurations**
3. **Document custom settings** and configurations

## Troubleshooting

### Common Unraid Issues

#### Permission Problems
```bash
# Fix permissions for appdata directories
chown -R nobody:users /mnt/user/appdata/umbrel-bitcoin
chown -R nobody:users /mnt/user/appdata/umbrel-electrs
chmod -R 755 /mnt/user/appdata/umbrel-bitcoin
chmod -R 755 /mnt/user/appdata/umbrel-electrs
```

#### Docker Issues
```bash
# Check Docker status
docker info
docker system df

# Clean up Docker
docker system prune -a
docker volume prune
```

#### Network Issues
```bash
# Check container networking
docker network ls
docker network inspect bridge

# Test container connectivity
docker exec umbrel-electrs ping umbrel-bitcoin
```

### Log Locations
- **Container logs**: Docker tab in Unraid WebGUI
- **System logs**: Tools → System Logs
- **Docker logs**: `/var/lib/docker/containers/`

### Performance Monitoring
- **Dashboard**: Monitor CPU, RAM, and network usage
- **Docker tab**: Check container resource usage
- **Array status**: Monitor disk health and performance

## Security Considerations

### Unraid-Specific Security
1. **Root access**: Scripts require root privileges
2. **Network isolation**: Use Unraid firewall rules
3. **User permissions**: Follow Unraid user management best practices
4. **Backup security**: Secure backup locations and access

### RPC Security
1. **Change default passwords** immediately
2. **Restrict RPC access** to local network if possible
3. **Use firewall rules** to limit external access
4. **Monitor access logs** regularly

## Maintenance

### Regular Tasks
1. **Update containers** through Community Applications
2. **Monitor disk space** and array health
3. **Check container logs** for errors
4. **Backup configurations** and data

### Update Procedures
1. **Backup data** before updates
2. **Update Community Applications** first
3. **Update containers** one at a time
4. **Test functionality** after updates

### Monitoring
- **Unraid Dashboard**: System health and performance
- **Docker tab**: Container status and logs
- **Community Applications**: Update notifications
- **Custom monitoring**: Prometheus metrics (Electrs port 4224)

## Advanced Configuration

### Custom Docker Networks
```bash
# Create custom network
docker network create bitcoin-network

# Run containers with custom network
docker run --network bitcoin-network umbrel-bitcoin
```

### Resource Limits
```yaml
# Limit container resources
deploy:
  resources:
    limits:
      memory: 2G
      cpus: '1.0'
    reservations:
      memory: 1G
      cpus: '0.5'
```

### Volume Optimization
```yaml
# Use bind mounts for better performance
volumes:
  - type: bind
    source: /mnt/cache/appdata/umbrel-bitcoin
    target: /home/umbrel/.bitcoin
```

## Support and Resources

### Unraid Resources
- **Unraid Forums**: [forums.unraid.net](https://forums.unraid.net/)
- **Unraid Documentation**: [docs.unraid.net](https://docs.unraid.net/)
- **Community Applications**: [forums.unraid.net/forum/68-community-applications](https://forums.unraid.net/forum/68-community-applications/)

### Bitcoin Resources
- **Bitcoin Core**: [bitcoin.org](https://bitcoin.org/)
- **Umbrel Apps**: [github.com/getumbrel/umbrel-apps](https://github.com/getumbrel/umbrel-apps)

### Electrs Resources
- **Electrs**: [github.com/romanz/electrs](https://github.com/romanz/electrs)
- **Electrum**: [electrum.org](https://electrum.org/)

## Troubleshooting Checklist

- [ ] Unraid version 6.8+
- [ ] Community Applications plugin installed
- [ ] Docker enabled and running
- [ ] Appdata share exists and accessible
- [ ] Sufficient storage space available
- [ ] Bitcoin node fully synced before Electrs installation
- [ ] RPC credentials match between apps
- [ ] Container networking working properly
- [ ] Port mappings configured correctly
- [ ] Firewall rules allow necessary traffic
