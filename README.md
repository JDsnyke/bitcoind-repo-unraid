# Umbrel Blockchain Applications for Unraid

This repository contains Community Application templates for running multiple Umbrel blockchain applications on Unraid servers.

## Overview

This repository provides five complementary blockchain applications:

1. **Umbrel Bitcoin** - A full Bitcoin Core node for blockchain validation and RPC access
2. **Umbrel Electrs** - A fast Electrum server implementation for wallet connectivity
3. **Umbrel Lightning** - A Lightning Network node for fast Bitcoin transactions
4. **Umbrel Mempool** - A Bitcoin mempool explorer for transaction monitoring
5. **Umbrel Monero** - A Monero (XMR) node for privacy-focused cryptocurrency

## ⚠️ Unraid-Specific Considerations

**This repository is specifically designed for Unraid systems.** Key considerations:

- **Root access required** for manual installation scripts
- **Appdata share** (`/mnt/user/appdata/`) must exist
- **Community Applications plugin** recommended for installation
- **Docker** must be enabled and configured
- **User permissions** follow Unraid conventions (`nobody:users`)

📖 **See [UNRAID_SETUP.md](UNRAID_SETUP.md) for comprehensive Unraid-specific setup instructions.**

## Repository Structure

```
bitcoind-repo-unraid/
├── bitcoin/                    # Umbrel Bitcoin app
│   ├── umbrel-bitcoin.xml     # Community Application template
│   ├── README.md              # Bitcoin app documentation
│   ├── Dockerfile             # Container definition
│   ├── docker-compose.yml     # Local testing setup
│   ├── bitcoin.conf.template  # Configuration template
│   └── install-unraid.sh     # Installation script (requires root)
├── electrs/                   # Umbrel Electrs app
│   ├── umbrel-electrs.xml    # Community Application template
│   ├── README.md             # Electrs app documentation
│   ├── Dockerfile            # Container definition
│   ├── docker-compose.yml    # Local testing setup
│   ├── electrs.conf.template # Configuration template
│   └── install-electrs.sh    # Installation script (requires root)
├── lightning/                 # Umbrel Lightning app
│   ├── umbrel-lightning.xml  # Community Application template
│   ├── README.md             # Lightning app documentation
│   ├── Dockerfile            # Container definition
│   ├── docker-compose.yml    # Local testing setup
│   ├── lightning.conf.template # Configuration template
│   └── install-lightning.sh  # Installation script (requires root)
├── mempool/                  # Umbrel Mempool app
│   ├── umbrel-mempool.xml   # Community Application template
│   ├── README.md            # Mempool app documentation
│   ├── Dockerfile           # Container definition
│   ├── docker-compose.yml   # Local testing setup
│   ├── mempool.conf.template # Configuration template
│   └── install-mempool.sh   # Installation script (requires root)
├── monero/                   # Umbrel Monero app
│   ├── umbrel-monero.xml    # Community Application template
│   ├── README.md            # Monero app documentation
│   ├── Dockerfile           # Container definition
│   ├── docker-compose.yml   # Local testing setup
│   ├── monero.conf.template # Configuration template
│   └── install-monero.sh    # Installation script (requires root)
├── README.md                 # This file - main documentation
├── UNRAID_SETUP.md          # Unraid-specific setup guide
├── LICENSE                   # MIT license
└── .gitignore               # Git ignore file (includes Unraid paths)
```

## Quick Start

### Prerequisites
- **Unraid 6.8+** with Community Applications plugin installed
- **Docker** enabled on your Unraid server
- **Appdata share** (`/mnt/user/appdata/`) exists and accessible
- **Root access** for manual installation scripts
- **Sufficient Storage**: 
  - Bitcoin: ~500GB+ (mainnet), ~50GB+ (testnet)
  - Electrs: ~50-100GB (mainnet), ~10-20GB (testnet)
  - Lightning: ~10-50GB (mainnet), ~5-20GB (testnet)
  - Mempool: ~20-100GB (mainnet), ~10-50GB (testnet)
  - Monero: ~150GB+ (mainnet), ~50GB+ (testnet)

### Installation Order

**⚠️ IMPORTANT: You must install the apps in this specific order:**

1. **First**: Install Umbrel Bitcoin and ensure it's fully synced
2. **Then**: Install any combination of the following (in any order):
   - Umbrel Electrs (requires Bitcoin)
   - Umbrel Lightning (requires Bitcoin)
   - Umbrel Mempool (requires Bitcoin, optional Electrs)
   - Umbrel Monero (standalone, no dependencies)

## Installation

### Method 1: Community Applications (Recommended)

1. **Install Bitcoin Node**:
   ```bash
   # Copy Bitcoin template
   cp bitcoin/umbrel-bitcoin.xml /boot/config/plugins/dockerMan/templates-user/
   ```
   - Go to **Apps** tab in Unraid WebGUI
   - Search for "Umbrel Bitcoin" and install
   - Configure settings and wait for full sync

2. **Install Additional Apps** (after Bitcoin sync):
   ```bash
   # Copy additional app templates
   cp electrs/umbrel-electrs.xml /boot/config/plugins/dockerMan/templates-user/
   cp lightning/umbrel-lightning.xml /boot/config/plugins/dockerMan/templates-user/
   cp mempool/umbrel-mempool.xml /boot/config/plugins/dockerMan/templates-user/
   cp monero/umbrel-monero.xml /boot/config/plugins/dockerMan/templates-user/
   ```
   - Go to **Apps** tab in Unraid WebGUI
   - Install desired apps and configure settings

### Method 2: Docker Tab (Alternative)

1. **Install Bitcoin Node**:
   - Go to **Docker** tab in Unraid WebGUI
   - Click **Add Container**
   - **Name**: `umbrel-bitcoin`
   - **Repository**: `getumbrel/bitcoin:latest`
   - **Network Type**: Bridge
   - **Port Mappings**: 
     - `8332:8332` (RPC)
     - `8333:8333` (P2P)
     - `18332:18332` (testnet RPC)
     - `18333:18333` (testnet P2P)
   - **Volumes**: `/mnt/user/appdata/umbrel-bitcoin:/home/umbrel/.bitcoin`
   - **Environment Variables**:
     - `BITCOIN_NETWORK=bitcoin`
     - `BITCOIN_RPC_USER=umbrel`
     - `BITCOIN_RPC_PASSWORD=your_secure_password`
     - `BITCOIN_RPC_BIND=0.0.0.0:8332`
     - `BITCOIN_RPC_ALLOW_IP=0.0.0.0/0`
     - `BITCOIN_DISABLE_WALLET=0`
     - `BITCOIN_TXINDEX=1`
     - `BITCOIN_BLOCKFILTERINDEX=1`
     - `BITCOIN_PRUNING=0`
   - Click **Apply** and wait for full sync

2. **Install Additional Apps** (after Bitcoin sync):
   
   **Electrs**:
   - **Name**: `umbrel-electrs`
   - **Repository**: `getumbrel/electrs:latest`
   - **Port Mappings**: `3000:3000`, `50001:50001`, `50002:50002`, `4224:4224`
   - **Volumes**: `/mnt/user/appdata/umbrel-electrs:/home/electrs/.electrs`
   - **Environment Variables**:
     - `ELECTRS_NETWORK=bitcoin`
     - `ELECTRS_DAEMON_RPC_ADDR=umbrel-bitcoin:8332`
     - `ELECTRS_DAEMON_RPC_USER=umbrel`
     - `ELECTRS_DAEMON_RPC_PASS=your_secure_password`
     - `ELECTRS_DAEMON_P2P_ADDR=umbrel-bitcoin:8333`

   **Lightning**:
   - **Name**: `umbrel-lightning`
   - **Repository**: `getumbrel/lightning:latest`
   - **Port Mappings**: `3000:3000`, `9735:9735`, `8080:8080`
   - **Volumes**: `/mnt/user/appdata/umbrel-lightning:/home/lightning/.lightning`
   - **Environment Variables**:
     - `LIGHTNING_NETWORK=bitcoin`
     - `LIGHTNING_BITCOIN_RPC_HOST=umbrel-bitcoin`
     - `LIGHTNING_BITCOIN_RPC_USER=umbrel`
     - `LIGHTNING_BITCOIN_RPC_PASSWORD=your_secure_password`

   **Mempool**:
   - **Name**: `umbrel-mempool`
   - **Repository**: `getumbrel/mempool:latest`
   - **Port Mappings**: `3000:3000`, `8999:8999`
   - **Volumes**: `/mnt/user/appdata/umbrel-mempool:/app/mempool`
   - **Environment Variables**:
     - `MEMPOOL_NETWORK=mainnet`
     - `MEMPOOL_BITCOIN_HOST=umbrel-bitcoin`
     - `MEMPOOL_BITCOIN_USERNAME=umbrel`
     - `MEMPOOL_BITCOIN_PASSWORD=your_secure_password`

   **Monero** (standalone):
   - **Name**: `umbrel-monero`
   - **Repository**: `getumbrel/monero:latest`
   - **Port Mappings**: `18089:18089`, `18090:18090`, `18091:18091`, `18092:18092`
   - **Volumes**: `/mnt/user/appdata/umbrel-monero:/home/monero/.bitmonero`
   - **Environment Variables**:
     - `MONERO_NETWORK=mainnet`
     - `MONERO_RPC_LOGIN=monero:your_secure_password`

### Method 3: Manual Installation (Root Required)

```bash
# First install Bitcoin node
cd bitcoin
sudo ./install-unraid.sh

# Wait for Bitcoin sync, then install additional apps
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

## Quick Docker Tab Reference

For users installing through the **Docker** tab, here are the key settings for each app:

### Bitcoin Node (Required First)
| Setting | Value |
|---------|-------|
| **Name** | `umbrel-bitcoin` |
| **Repository** | `getumbrel/bitcoin:latest` |
| **Ports** | `8332:8332`, `8333:8333`, `18332:18332`, `18333:18333` |
| **Volume** | `/mnt/user/appdata/umbrel-bitcoin:/home/umbrel/.bitcoin` |
| **Network** | Bridge |

### Electrs Server
| Setting | Value |
|---------|-------|
| **Name** | `umbrel-electrs` |
| **Repository** | `getumbrel/electrs:latest` |
| **Ports** | `3000:3000`, `50001:50001`, `50002:50002`, `4224:4224` |
| **Volume** | `/mnt/user/appdata/umbrel-electrs:/home/electrs/.electrs` |
| **Network** | Bridge |

### Lightning Node
| Setting | Value |
|---------|-------|
| **Name** | `umbrel-lightning` |
| **Repository** | `getumbrel/lightning:latest` |
| **Ports** | `3001:3000`, `9735:9735`, `8081:8080` |
| **Volume** | `/mnt/user/appdata/umbrel-lightning:/home/lightning/.lightning` |
| **Network** | Bridge |

### Mempool Explorer
| Setting | Value |
|---------|-------|
| **Name** | `umbrel-mempool` |
| **Repository** | `getumbrel/mempool:latest` |
| **Ports** | `3002:3000`, `8999:8999` |
| **Volume** | `/mnt/user/appdata/umbrel-mempool:/app/mempool` |
| **Network** | Bridge |

### Monero Node
| Setting | Value |
|---------|-------|
| **Name** | `umbrel-monero` |
| **Repository** | `getumbrel/monero:latest` |
| **Ports** | `18089:18089`, `18090:18090`, `18091:18091`, `18092:18092` |
| **Volume** | `/mnt/user/appdata/umbrel-monero:/home/monero/.bitmonero` |
| **Network** | Bridge |

**Note**: Port conflicts are resolved by using different host ports (3001, 3002) while keeping container ports the same. See [UNRAID_SETUP.md](UNRAID_SETUP.md) for detailed Docker tab installation instructions.

## Architecture

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Electrum      │    │   Umbrel        │    │   Umbrel        │
│   Wallets       │◄──►│   Electrs       │◄──►│   Bitcoin       │
│                 │    │   (Port 50001)  │    │   (Port 8332)   │
└─────────────────┘    └─────────────────┘    └─────────────────┘
                                │
                                ▼
                       ┌─────────────────┐
                       │   Umbrel        │
                       │   Lightning     │
                       │   (Port 9735)   │
                       └─────────────────┘
                                │
                                ▼
                       ┌─────────────────┐
                       │   Umbrel        │
                       │   Mempool       │
                       │   (Port 3000)   │
                       └─────────────────┘

┌─────────────────┐    ┌─────────────────┐
│   Monero        │    │   Umbrel        │
│   Wallets       │◄──►│   Monero        │
│                 │    │   (Port 18089)  │
└─────────────────┘    └─────────────────┘
```

## Configuration

### Bitcoin Node (Required for most apps)
- **RPC Ports**: 8332 (mainnet), 18332 (testnet)
- **P2P Ports**: 8333 (mainnet), 18333 (testnet)
- **Storage**: `/mnt/user/appdata/umbrel-bitcoin`
- **Required Indexes**: `txindex=1`, `blockfilterindex=1`
- **User**: `nobody:users` (Unraid default)

### Electrs Server
- **HTTP API**: Port 3000
- **Electrum RPC**: Port 50001
- **Electrum Index**: Port 50002
- **Monitoring**: Port 4224
- **Storage**: `/mnt/user/appdata/umbrel-electrs`
- **User**: `nobody:users` (Unraid default)

### Lightning Node
- **Web Interface**: Port 3000
- **Lightning P2P**: Port 9735
- **REST API**: Port 8080
- **Storage**: `/mnt/user/appdata/umbrel-lightning`
- **User**: `nobody:users` (Unraid default)

### Mempool Explorer
- **Web Interface**: Port 3000
- **REST API**: Port 8999
- **Storage**: `/mnt/user/appdata/umbrel-mempool`
- **User**: `nobody:users` (Unraid default)

### Monero Node
- **RPC Interface**: Port 18089
- **P2P Protocol**: Port 18090
- **ZMQ RPC**: Port 18091
- **ZMQ PUB**: Port 18092
- **Storage**: `/mnt/user/appdata/umbrel-monero`
- **User**: `nobody:users` (Unraid default)

### Critical Configuration

**Bitcoin-dependent apps must use the same RPC credentials:**
- **RPC Username**: `umbrel` (default)
- **RPC Password**: Set the same secure password for all apps
- **Network**: All apps must use the same network (mainnet, testnet, or regtest)

## Usage Examples

### Bitcoin RPC
```bash
# Get blockchain info
curl --user umbrel:your_password \
  --data-binary '{"jsonrpc": "1.0", "id": "test", "method": "getblockchaininfo", "params": []}' \
  -H 'content-type: text/plain;' http://your_server_ip:8332/
```

### Electrs HTTP API
```bash
# Get server status
curl http://your_server_ip:3000/

# Get block height
curl http://your_server_ip:3000/blocks/tip/height
```

### Lightning REST API
```bash
# Get node info
curl http://your_server_ip:8080/v1/info

# List channels
curl http://your_server_ip:8080/v1/channels
```

### Mempool API
```bash
# Get fee recommendations
curl http://your_server_ip:8999/api/v1/fees/recommended

# Get mempool stats
curl http://your_server_ip:8999/api/v1/fees/mempool-blocks
```

### Monero RPC
```bash
# Get blockchain info
curl -X POST http://your_server_ip:18089/json_rpc \
  -H "Content-Type: application/json" \
  -d '{"jsonrpc":"2.0","id":"0","method":"get_info"}'
```

### Connect Applications

1. **Electrum Wallet**: Connect to `your_server_ip:50001`
2. **Lightning Wallet**: Connect to `your_server_ip:9735`
3. **Monero Wallet**: Connect to `your_server_ip:18089`
4. **Web Interfaces**: Access via respective ports

## Integration Features

### Automatic Detection
- Apps automatically detect Bitcoin container
- Uses container names for networking (`umbrel-bitcoin:8332`, etc.)
- Shared Docker network for secure communication

### Configuration Synchronization
- RPC credentials automatically synchronized
- Network settings automatically matched
- Port configurations optimized for container communication

### Cross-App Functionality
- **Electrs + Mempool**: Enhanced transaction lookup
- **Bitcoin + Lightning**: Full Lightning Network support
- **Bitcoin + Electrs**: Electrum wallet compatibility
- **Monero**: Independent operation

## Unraid-Specific Features

### User Management
- **Default user**: `nobody:users` (UID: 99, GID: 100)
- **Permission handling**: Automatic ownership and permission setting
- **Root requirements**: Scripts check for root access

### Storage Integration
- **Appdata share**: Automatic detection and validation
- **Cache optimization**: Support for Unraid cache drive usage
- **Volume mapping**: Proper Unraid path handling

### Community Applications
- **Template integration**: Ready for Community Applications plugin
- **Automatic updates**: Through Unraid's update system
- **Configuration persistence**: Survives Unraid reboots

## Security Considerations

1. **Change Default Passwords**: Always change RPC passwords from defaults
2. **Network Access**: Consider restricting external RPC access
3. **Firewall**: Only expose necessary ports
4. **Updates**: Keep containers updated for security patches
5. **Root Access**: Manual scripts require root privileges

## Performance Tuning

### Bitcoin Ecosystem
- **Pruning**: Enable for storage optimization
- **Indexing**: Configure based on your needs
- **Cache Drive**: Use Unraid cache drive for better performance

### Monero
- **Sync Mode**: Choose appropriate sync mode
- **Pruning**: Enable for storage optimization
- **Resource Allocation**: Monitor memory and CPU usage

### General Optimization
- **Storage**: Use SSD/cache drive for better performance
- **Memory**: Monitor usage across all containers
- **Network**: Ensure stable connections between containers

## Troubleshooting

### Common Issues

1. **App dependencies not met**:
   - Verify Bitcoin node is running and synced
   - Check RPC credentials match exactly
   - Ensure network compatibility
   - Verify required indexes are enabled

2. **Port conflicts**:
   - Change port mappings if needed
   - Check for other services using same ports
   - Use different ports for each app

3. **Permission issues**:
   - Check appdata share exists and is accessible
   - Verify user ownership (`nobody:users`)
   - Ensure proper file permissions

### Unraid-Specific Issues

- **Root access required**: Scripts must run as root
- **Appdata share missing**: Create `/mnt/user/appdata/` share first
- **Docker not enabled**: Enable Docker in Unraid settings
- **Community Applications**: Install plugin before using templates

### Getting Help

- **Unraid Setup Guide**: [UNRAID_SETUP.md](UNRAID_SETUP.md) for detailed Unraid instructions
- **GitHub Issues**: [Umbrel Apps Issues](https://github.com/getumbrel/umbrel-apps/issues)
- **Unraid Forums**: [Community Applications Support](https://forums.unraid.net/forum/68-community-applications/)
- **Bitcoin Core Docs**: [Bitcoin Core Documentation](https://bitcoin.org/en/bitcoin-core/)
- **Electrs Docs**: [Electrs GitHub](https://github.com/romanz/electrs)
- **Lightning Docs**: [Lightning Network](https://lightning.network/)
- **Mempool Docs**: [Mempool.space](https://mempool.space/)
- **Monero Docs**: [Monero Documentation](https://www.getmonero.org/resources/user-guides/)

## Contributing

These Community Application templates are based on the [Umbrel Apps](https://github.com/getumbrel/umbrel-apps). To contribute:

1. Fork the repository
2. Make your changes
3. Submit a pull request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- [Umbrel](https://github.com/getumbrel) for the blockchain applications
- [Unraid Community](https://forums.unraid.net/) for the platform
- [Bitcoin Core](https://bitcoin.org/) developers for the Bitcoin implementation
- [Electrs](https://github.com/romanz/electrs) developers for the Rust implementation
- [Lightning Network](https://lightning.network/) developers
- [Mempool.space](https://mempool.space/) developers
- [Monero Project](https://www.getmonero.org/) developers
