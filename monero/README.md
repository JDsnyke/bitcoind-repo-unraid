# Umbrel Monero Community Application for Unraid

This repository contains the Community Application template for running the Umbrel Monero (XMR) node on Unraid servers.

## Overview

Umbrel Monero is a Monero (XMR) node implementation that provides privacy-focused cryptocurrency functionality and blockchain validation. Unlike the other apps in this repository, Monero is a standalone cryptocurrency that doesn't require Bitcoin to function.

## Features

- **Full Monero Node**: Complete Monero blockchain validation
- **Privacy-Focused**: Built-in privacy and anonymity features
- **RPC Access**: Programmatic access to Monero functionality
- **Wallet Support**: Optional wallet functionality
- **Multiple Networks**: Support for mainnet, testnet, and stagenet
- **ZMQ Support**: ZeroMQ integration for real-time data
- **Web Interface**: Optional web-based monitoring (port 18089)

## Prerequisites

1. **Unraid 6.8+** with Community Applications plugin installed
2. **Docker** enabled on your Unraid server
3. **Sufficient Storage**: Monero blockchain requires significant storage space
   - Mainnet: ~150GB+ (growing)
   - Testnet: ~50GB+ (growing)
   - Stagenet: ~25GB+ (growing)

## Installation

### Method 1: Community Applications (Recommended)

1. **Copy the template**:
   - Copy `umbrel-monero.xml` to `/boot/config/plugins/dockerMan/templates-user/`
   - Restart your Unraid server or refresh Community Applications

2. **Install through Apps tab**:
   - Go to the **Apps** tab in your Unraid WebGUI
   - Search for "Umbrel Monero"
   - Click **Install**
   - Configure the following settings:
     - **Network**: Choose mainnet, testnet, or stagenet
     - **RPC Credentials**: Set username and password
     - **Storage Path**: Default is `/mnt/user/appdata/umbrel-monero`
   - Click **Apply** to start the container

### Method 2: Manual Installation

Use the provided installation script:
```bash
sudo ./install-monero.sh
```

## Configuration

### Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `MONERO_NETWORK` | mainnet | Monero network (mainnet, testnet, or stagenet) |
| `MONERO_RPC_BIND_IP` | 0.0.0.0 | RPC bind IP address |
| `MONERO_RPC_BIND_PORT` | 18089 | RPC bind port |
| `MONERO_P2P_BIND_IP` | 0.0.0.0 | P2P bind IP address |
| `MONERO_P2P_BIND_PORT` | 18090 | P2P bind port |
| `MONERO_ZMQ_RPC_BIND_IP` | 0.0.0.0 | ZMQ RPC bind IP address |
| `MONERO_ZMQ_RPC_BIND_PORT` | 18091 | ZMQ RPC bind port |
| `MONERO_ZMQ_PUB_BIND_IP` | 0.0.0.0 | ZMQ PUB bind IP address |
| `MONERO_ZMQ_PUB_BIND_PORT` | 18092 | ZMQ PUB bind port |
| `MONERO_RPC_LOGIN` | monero:changeme | RPC login credentials (username:password) |
| `MONERO_RESTRICTED_RPC` | 1 | Restrict RPC access (1=enabled, 0=disabled) |
| `MONERO_DISABLE_RPC_LOGIN` | 0 | Disable RPC login requirement |
| `MONERO_SYNC_MODE` | fast | Sync mode (fast, safe, or unsafe) |
| `MONERO_PRUNING` | 0 | Enable pruning (0=disabled, or size in MB) |
| `MONERO_DB_SALVAGE` | 0 | Database salvage mode |
| `MONERO_MAX_CONCURRENCY` | 0 | Maximum concurrency (0=auto) |
| `MONERO_PREPARE_MULTISIG` | 0 | Prepare multisig wallet |
| `MONERO_OFFLINE` | 0 | Offline mode |
| `MONERO_DATA_DIR` | /home/monero/.bitmonero | Monero data directory |
| `MONERO_LOG_LEVEL` | 1 | Log level (0-4, higher = more verbose) |

### Ports

| Port | Protocol | Description |
|------|----------|-------------|
| 18089 | TCP | Monero RPC |
| 18090 | TCP | Monero P2P |
| 18091 | TCP | ZMQ RPC |
| 18092 | TCP | ZMQ PUB |

### Storage

The app stores Monero blockchain data in `/mnt/user/appdata/umbrel-monero` by default. This directory contains:
- Blockchain data
- Configuration files
- Logs
- Wallet files (if enabled)

## Usage

### Accessing the Node

- **RPC Interface**: Port 18089 (JSON-RPC)
- **P2P Protocol**: Port 18090 (peer-to-peer)
- **ZMQ Interface**: Ports 18091-18092 (ZeroMQ)
- **Web Interface**: Optional monitoring on port 18089

### RPC Examples

```bash
# Get blockchain info
curl -X POST http://your_server_ip:18089/json_rpc \
  -H "Content-Type: application/json" \
  -d '{"jsonrpc":"2.0","id":"0","method":"get_info"}'

# Get block count
curl -X POST http://your_server_ip:18089/json_rpc \
  -H "Content-Type: application/json" \
  -d '{"jsonrpc":"2.0","id":"0","method":"get_block_count"}'

# Get network info
curl -X POST http://your_server_ip:18089/json_rpc \
  -H "Content-Type: application/json" \
  -d '{"jsonrpc":"2.0","id":"0","method":"get_connections"}'
```

### ZMQ Integration

Monero supports ZeroMQ for real-time data:
- **Port 18091**: RPC interface
- **Port 18092**: Publisher interface
- **Real-time updates**: Block notifications, transaction updates

### Wallet Operations

If wallet functionality is enabled:
- **Create wallet**: Generate new Monero wallets
- **Import wallet**: Import existing wallets
- **Send transactions**: Make Monero payments
- **Receive payments**: Accept Monero transactions

## Security Considerations

1. **Change Default Credentials**: Always change the default RPC password
2. **Network Access**: Consider restricting external RPC access
3. **Firewall**: Ensure only necessary ports are exposed
4. **Updates**: Keep the container updated for security patches
5. **Wallet Security**: Secure wallet files and backup keys

## Performance Tuning

### Storage Optimization
- **Pruning**: Enable pruning for storage optimization
- **Sync Mode**: Choose appropriate sync mode for your needs
- **Database**: Monitor database performance and size

### Network Configuration
- **Max Connections**: Adjust based on your network capacity
- **P2P Ports**: Ensure proper port forwarding for external connections
- **RPC Access**: Limit RPC access to trusted networks

### Resource Allocation
- **Memory**: Monero can be memory-intensive during sync
- **CPU**: Adjust concurrency based on your hardware
- **Storage**: Use SSD for better performance

## Integration with Other Apps

### Standalone Operation
Unlike Bitcoin-based apps, Monero operates independently:
- **No Bitcoin dependency**: Self-contained cryptocurrency
- **Separate network**: Monero blockchain, not Bitcoin
- **Independent ports**: No port conflicts with Bitcoin apps

### Optional Integrations
- **Wallet applications**: Connect Monero wallets
- **Mining software**: Use for Monero mining
- **Trading platforms**: Integrate with exchanges

## Troubleshooting

### Common Issues

1. **Container Won't Start**:
   - Check Docker logs
   - Verify storage permissions
   - Ensure sufficient disk space

2. **Slow Sync**:
   - Check network connectivity
   - Verify storage performance
   - Consider using SSD for better performance

3. **RPC Connection Issues**:
   - Verify RPC credentials
   - Check firewall settings
   - Ensure correct port mapping

4. **High Resource Usage**:
   - Monitor during initial sync
   - Adjust concurrency settings
   - Check for memory leaks

### Getting Help

- **GitHub Issues**: [Umbrel Apps Issues](https://github.com/getumbrel/umbrel-apps/issues)
- **Unraid Forums**: [Community Applications Support](https://forums.unraid.net/forum/68-community-applications/)
- **Monero Documentation**: [Monero Documentation](https://www.getmonero.org/resources/user-guides/)
- **Monero Community**: [Monero Community](https://www.getmonero.org/community/)

## Contributing

This Community Application template is based on the [Umbrel Monero app](https://github.com/getumbrel/umbrel-apps/tree/master/monero). To contribute:

1. Fork the repository
2. Make your changes
3. Submit a pull request

## License

This project is licensed under the MIT License - see the [LICENSE](../LICENSE) file for details.

## Acknowledgments

- [Umbrel](https://github.com/getumbrel) for the Monero app
- [Monero Project](https://www.getmonero.org/) developers
- [Unraid Community](https://forums.unraid.net/) for the platform
