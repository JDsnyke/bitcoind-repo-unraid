# Umbrel Bitcoin Community Application for Unraid

This repository contains the Community Application template for running the Umbrel Bitcoin node on Unraid servers.

## Overview

Umbrel Bitcoin is a Bitcoin Core node packaged for easy deployment on Unraid servers. It provides a full Bitcoin node with RPC access and block validation capabilities, allowing you to run your own Bitcoin node for enhanced privacy, security, and network support.

## Features

- **Full Bitcoin Node**: Complete Bitcoin blockchain validation
- **RPC Access**: Programmatic access to Bitcoin Core functionality
- **Multiple Networks**: Support for mainnet, testnet, and regtest
- **Enhanced Security**: Optimized configuration for production use
- **Performance Tuning**: Configurable database cache and memory settings
- **Easy Management**: Simple installation and configuration through Unraid Community Applications
- **Optimized Storage**: Configurable pruning and indexing options
- **Easy Management**: Simple installation and configuration through Unraid Community Applications

## Prerequisites

1. **Unraid 6.8+** with Community Applications plugin installed
2. **Docker** enabled on your Unraid server
3. **Sufficient Storage**: Bitcoin blockchain requires significant storage space
   - Mainnet: ~500GB+ (growing)
   - Testnet: ~50GB+ (growing)
   - Regtest: Minimal

## Installation

### Method 1: Community Applications (Recommended)

1. **Copy the template**:
   - Copy `umbrel-bitcoin.xml` to `/boot/config/plugins/dockerMan/templates-user/`
   - Restart your Unraid server or refresh Community Applications

2. **Install through Apps tab**:
   - Go to the **Apps** tab in your Unraid WebGUI
   - Search for "Umbrel Bitcoin"
   - Click **Install**
   - Configure the following settings:
     - **Network**: Choose mainnet, testnet, or regtest
     - **RPC Username**: Default is "umbrel"
     - **RPC Password**: **IMPORTANT**: Change from default "moneyprintergobrrr"
     - **Storage Path**: Default is `/mnt/user/appdata/umbrel-bitcoin`
   - Click **Apply** to start the container

### Method 2: Manual Installation

Use the provided installation script:
```bash
./install-bitcoin.sh
```



## Configuration

### Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `BITCOIN_NETWORK` | mainnet | Bitcoin network (mainnet, testnet, or regtest) |
| `BITCOIN_RPC_USER` | umbrel | RPC username for Bitcoin Core |
| `BITCOIN_RPC_PASSWORD` | moneyprintergobrrr | RPC password (CHANGE THIS!) |
| `BITCOIN_RPC_BIND` | 0.0.0.0 | RPC bind address |
| `BITCOIN_RPC_ALLOW_IP` | 0.0.0.0/0 | Allowed IPs for RPC access |
| `BITCOIN_DISABLE_WALLET` | 1 | Disable wallet functionality |
| `BITCOIN_TXINDEX` | 1 | Enable transaction index |
| `BITCOIN_BLOCKFILTERINDEX` | 1 | Enable block filter index |
| `BITCOIN_PRUNING` | 0 | Enable pruning (0=disabled, or size in MB) |

### Ports

| Port | Protocol | Description |
|------|----------|-------------|
| 8332 | TCP | Bitcoin RPC (mainnet) |
| 8333 | TCP | Bitcoin P2P (mainnet) |
| 18332 | TCP | Bitcoin RPC (testnet) |
| 18333 | TCP | Bitcoin P2P (testnet) |


### Storage

The app stores Bitcoin blockchain data in `/mnt/user/appdata/umbrel-bitcoin` by default. This directory contains:
- Blockchain data
- Configuration files
- Logs
- Indexes



- **Network Privacy**: All Bitcoin traffic can be routed through Tor

#### I2P Integration
- **SAM Protocol**: Available on port 7656
- **Network Privacy**: Alternative privacy network for Bitcoin connections
- **Hidden Services**: I2P hidden service support for additional privacy

#### Configuration
Tor and I2P are automatically configured and started with the Bitcoin node. The services run in separate containers and are managed automatically.

## Usage

### Accessing the Node

- **WebUI**: http://[YOUR_SERVER_IP]:8332
- **RPC Access**: Use Bitcoin Core RPC commands
- **Logs**: View container logs in Unraid Docker tab

### RPC Examples

```bash
# Get blockchain info
curl --user umbrel:your_password --data-binary '{"jsonrpc": "1.0", "id": "curltest", "method": "getblockchaininfo", "params": []}' -H 'content-type: text/plain;' http://your_server_ip:8332/

# Get network info
curl --user umbrel:your_password --data-binary '{"jsonrpc": "1.0", "id": "curltest", "method": "getnetworkinfo", "params": []}' -H 'content-type: text/plain;' http://your_server_ip:8332/
```

### Monitoring

- **Blockchain Sync**: Monitor sync progress through RPC calls
- **Storage Usage**: Check storage consumption in Unraid
- **Network Activity**: Monitor network usage in Unraid

## Integration with Other Apps

### Umbrel Electrs
This Bitcoin node is designed to work seamlessly with the [Umbrel Electrs](../electrs/) app:

1. **Install Bitcoin first**: This Bitcoin node must be running before installing Electrs
2. **Automatic detection**: Electrs will automatically detect and connect to this Bitcoin container
3. **Shared network**: Both apps use the same Docker network for communication
4. **RPC credentials**: Use the same RPC username/password for both apps

### Configuration for Electrs Integration
When using with Electrs, ensure these settings:
- **RPC Username**: `umbrel` (default)
- **RPC Password**: Set a secure password (same for both apps)
- **RPC Bind**: `0.0.0.0` (allows Electrs container to connect)
- **RPC Allow IP**: `0.0.0.0/0` (allows container network access)

## Security Considerations

1. **Change Default Password**: Always change the default RPC password
2. **Network Access**: Consider restricting RPC access to specific IPs
3. **Firewall**: Ensure only necessary ports are exposed
4. **Updates**: Keep the container updated for security patches

## Performance Tuning

### Storage Optimization
- **Pruning**: Enable pruning for storage optimization (requires re-sync)
- **Indexing**: Configure transaction and block filter indexing based on your needs
- **Database Cache**: Adjust based on available RAM

### Network Configuration
- **Max Connections**: Default 125 connections
- **Upload Target**: Limit upload bandwidth if needed
- **Listen Mode**: Enable for P2P network participation

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

4. **Electrs Connection Issues**:
   - Verify Bitcoin node is fully synced
   - Check RPC credentials match between apps
   - Ensure both containers are on the same network

### Getting Help

- **GitHub Issues**: [Umbrel Apps Issues](https://github.com/getumbrel/umbrel-apps/issues)
- **Unraid Forums**: [Community Applications Support](https://forums.unraid.net/forum/68-community-applications/)
- **Bitcoin Core Documentation**: [Bitcoin Core Docs](https://bitcoin.org/en/bitcoin-core/)

## Contributing

This Community Application template is based on the [Umbrel Bitcoin app](https://github.com/getumbrel/umbrel-apps/tree/master/bitcoin). To contribute:

1. Fork the repository
2. Make your changes
3. Submit a pull request

## License

This project is licensed under the MIT License - see the [LICENSE](../LICENSE) file for details.

## Acknowledgments

- [Umbrel](https://github.com/getumbrel) for the Bitcoin app
- [Unraid Community](https://forums.unraid.net/) for the platform
- [Bitcoin Core](https://bitcoin.org/) developers for the Bitcoin implementation
