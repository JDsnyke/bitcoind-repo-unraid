# Umbrel Lightning Community Application for Unraid

This repository contains the Community Application template for running the Umbrel Lightning Network node on Unraid servers.

## ⚠️ IMPORTANT: Bitcoin Node Required

**Umbrel Lightning requires a Bitcoin Core node to function.** You must install the [Umbrel Bitcoin](../bitcoin/) app first before installing Lightning.

## Overview

Umbrel Lightning is a Lightning Network node implementation that provides fast, low-cost Bitcoin transactions and payment routing capabilities. It allows you to participate in the Lightning Network, open payment channels, and facilitate instant Bitcoin transactions.

## Features

- **Lightning Network Node**: Full Lightning Network participation
- **Payment Channels**: Open and manage payment channels
- **Fast Transactions**: Sub-second Bitcoin payments
- **Low Fees**: Minimal transaction costs
- **Web Interface**: User-friendly web UI for Lightning operations
- **REST API**: Programmatic access to Lightning functionality
- **Channel Management**: Monitor and manage payment channels

## Prerequisites

1. **Unraid 6.8+** with Community Applications plugin installed
2. **Docker** enabled on your Unraid server
3. **Bitcoin Node**: **REQUIRED** - A running Bitcoin Core node (install [Umbrel Bitcoin](../bitcoin/) first)
4. **Sufficient Storage**: Lightning data requires storage space
   - Mainnet: ~10-50GB (depending on channel count)
   - Testnet: ~5-20GB
   - Regtest: Minimal

## Installation Order

**You must install the apps in this specific order:**

1. **First**: Install [Umbrel Bitcoin](../bitcoin/) and ensure it's fully synced
2. **Then**: Install Umbrel Lightning (this app)

## Installation

### Method 1: Community Applications (Recommended)

1. **Install Bitcoin first**:
   - Copy `../bitcoin/umbrel-bitcoin.xml` to `/boot/config/plugins/dockerMan/templates-user/`
   - Install "Umbrel Bitcoin" through the Apps tab
   - Wait for Bitcoin node to fully sync

2. **Install Lightning**:
   - Copy `umbrel-lightning.xml` to `/boot/config/plugins/dockerMan/templates-user/`
   - Install "Umbrel Lightning" through the Apps tab
   - Configure Bitcoin connection settings

### Method 2: Manual Installation

```bash
# First install Bitcoin node
cd ../bitcoin
sudo ./install-bitcoin.sh

# Wait for Bitcoin sync, then install Lightning
cd ../lightning
sudo ./install-lightning.sh
```

## Configuration

### Bitcoin Node Connection

**Critical**: These settings must match your Bitcoin node configuration:

| Variable | Default | Description | Must Match Bitcoin Node |
|----------|---------|-------------|-------------------------|
| `LIGHTNING_BITCOIN_RPC_USER` | umbrel | Bitcoin Core RPC username | ✅ Yes |
| `LIGHTNING_BITCOIN_RPC_PASSWORD` | changeme | Bitcoin Core RPC password | ✅ Yes |
| `LIGHTNING_BITCOIN_RPC_HOST` | umbrel-bitcoin | Bitcoin Core RPC hostname | ✅ Yes |
| `LIGHTNING_BITCOIN_RPC_PORT` | 8332 | Bitcoin Core RPC port | ✅ Yes |

### Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `LIGHTNING_NETWORK` | bitcoin | Bitcoin network (bitcoin, testnet, or regtest) |
| `LIGHTNING_BITCOIN_RPC_HOST` | umbrel-bitcoin | Bitcoin Core RPC hostname |
| `LIGHTNING_BITCOIN_RPC_PORT` | 8332 | Bitcoin Core RPC port |
| `LIGHTNING_BITCOIN_RPC_USER` | umbrel | Bitcoin Core RPC username |
| `LIGHTNING_BITCOIN_RPC_PASSWORD` | changeme | Bitcoin Core RPC password |
| `LIGHTNING_BITCOIN_RPC_PROTOCOL` | http | Bitcoin Core RPC protocol |
| `LIGHTNING_ALIAS` | Umbrel Lightning | Lightning node alias |
| `LIGHTNING_COLOR` | 3399FF | Lightning node color (hex) |
| `LIGHTNING_WEB_PORT` | 3000 | Web interface port |
| `LIGHTNING_P2P_PORT` | 9735 | Lightning P2P port |
| `LIGHTNING_REST_PORT` | 8080 | REST API port |
| `LIGHTNING_LOG_LEVEL` | info | Logging level |

### Ports

| Port | Protocol | Description |
|------|----------|-------------|
| 3000 | TCP | Web interface |
| 9735 | TCP | Lightning P2P protocol |
| 8080 | TCP | REST API |

### Storage

The app stores Lightning data in `/mnt/user/appdata/umbrel-lightning` by default:
- Lightning node data
- Channel information
- Configuration files
- Logs

## Integration with Bitcoin Node

Lightning requires a Bitcoin Core node to function. You can:

1. **Use the Umbrel Bitcoin app** (recommended):
   - Install both apps from Community Applications
   - Configure Lightning to connect to the Bitcoin container
   - Use container names for networking (`umbrel-bitcoin:8332`)

2. **Connect to external Bitcoin node**:
   - Update `LIGHTNING_BITCOIN_RPC_HOST` to your node's IP
   - Ensure RPC credentials match exactly
   - Verify network compatibility

### Bitcoin Node Requirements

Your Bitcoin node must have:
- **RPC enabled** and accessible
- **Wallet enabled** (Lightning requires wallet functionality)
- **Same network** as Lightning (mainnet, testnet, or regtest)
- **Fully synced** blockchain

## Usage

### Accessing Lightning

- **Web Interface**: http://[YOUR_SERVER_IP]:3000
- **REST API**: http://[YOUR_SERVER_IP]:8080
- **P2P Protocol**: [YOUR_SERVER_IP]:9735

### Web Interface Features

1. **Dashboard**: Overview of Lightning node status
2. **Channels**: Manage payment channels
3. **Payments**: Send and receive Lightning payments
4. **Network**: View Lightning Network information
5. **Settings**: Configure node parameters

### REST API Examples

```bash
# Get node info
curl http://your_server_ip:8080/v1/info

# List channels
curl http://your_server_ip:8080/v1/channels

# Get network info
curl http://your_server_ip:8080/v1/network
```

### Lightning Operations

1. **Open Channel**: Connect to another Lightning node
2. **Send Payment**: Make instant Bitcoin payments
3. **Receive Payment**: Accept Lightning payments
4. **Close Channel**: Terminate payment channels
5. **Monitor Status**: Track channel health and balance

## Security Considerations

1. **RPC Credentials**: Change default Bitcoin Core RPC password
2. **Network Access**: Consider restricting external access
3. **Firewall**: Only expose necessary ports
4. **Channel Security**: Use trusted Lightning nodes
5. **Backup**: Regularly backup Lightning data

## Performance Tuning

### Resource Allocation

- **Memory**: Lightning is memory-efficient but monitor usage
- **CPU**: Moderate CPU usage for channel operations
- **Storage**: SSD recommended for better performance
- **Network**: Stable internet connection required

### Channel Management

- **Channel Size**: Balance between capacity and cost
- **Node Selection**: Choose reliable Lightning nodes
- **Fee Strategy**: Configure appropriate routing fees
- **Monitoring**: Regular channel health checks

## Troubleshooting

### Common Issues

1. **Connection to Bitcoin node fails**:
   - Verify Bitcoin node is running and synced
   - Check RPC credentials match exactly
   - Ensure network connectivity
   - Verify wallet is enabled on Bitcoin node

2. **Channel opening fails**:
   - Check Bitcoin node has sufficient funds
   - Verify Lightning Network connectivity
   - Check channel size limits
   - Ensure proper fee configuration

3. **Payment routing issues**:
   - Verify channel liquidity
   - Check network connectivity
   - Verify fee settings
   - Check channel health status

4. **Web interface not accessible**:
   - Verify container is running
   - Check port mappings
   - Verify firewall settings
   - Check container logs

### Getting Help

- **GitHub Issues**: [Umbrel Apps Issues](https://github.com/getumbrel/umbrel-apps/issues)
- **Unraid Forums**: [Community Applications Support](https://forums.unraid.net/forum/68-community-applications/)
- **Lightning Documentation**: [Lightning Network](https://lightning.network/)
- **Bitcoin Core Docs**: [Bitcoin Core Documentation](https://bitcoin.org/en/bitcoin-core/)

## Contributing

This Community Application template is based on the [Umbrel Lightning app](https://github.com/getumbrel/umbrel-apps/tree/master/lightning). To contribute:

1. Fork the repository
2. Make your changes
3. Submit a pull request

## License

This project is licensed under the MIT License - see the [LICENSE](../LICENSE) file for details.

## Acknowledgments

- [Umbrel](https://github.com/getumbrel) for the Lightning app
- [Lightning Network](https://lightning.network/) developers
- [Unraid Community](https://forums.unraid.net/) for the platform
