# Umbrel Electrs Community Application for Unraid

This repository contains the Community Application template for running the Umbrel Electrs server on Unraid servers.

## ⚠️ IMPORTANT: Bitcoin Node Required

**Umbrel Electrs requires a Bitcoin Core node to function.** You must install the [Umbrel Bitcoin](../bitcoin/) app first before installing Electrs.

## Overview

Umbrel Electrs is a fast, lightweight Bitcoin Electrum server implementation written in Rust. It provides Electrum protocol support for Bitcoin wallets and applications, allowing you to run your own Electrum server that connects to your Bitcoin node.

## Prerequisites

1. **Unraid 6.8+** with Community Applications plugin installed
2. **Docker** enabled on your Unraid server
3. **Bitcoin Node**: **REQUIRED** - A running Bitcoin Core node (install [Umbrel Bitcoin](../bitcoin/) first)
4. **Sufficient Storage**: Electrs database requires storage space
   - Mainnet: ~50-100GB (depending on indexing options)
   - Testnet: ~10-20GB
   - Regtest: Minimal

## Installation Order

**You must install the apps in this specific order:**

1. **First**: Install [Umbrel Bitcoin](../bitcoin/) and ensure it's fully synced
2. **Then**: Install Umbrel Electrs (this app)

## Features

- **Fast Electrum Protocol**: High-performance Electrum server implementation
- **Rust-based**: Written in Rust for optimal performance and memory safety
- **Lightweight**: Efficient resource usage compared to traditional Electrum servers
- **Multiple Interfaces**: HTTP API, Electrum RPC, and Prometheus monitoring
- **Index-based Queries**: Fast transaction and address lookups
- **Easy Integration**: Simple setup with Bitcoin Core nodes

## Installation

### Method 1: Community Applications (Recommended)

1. **Install Bitcoin first**:
   - Copy `../bitcoin/umbrel-bitcoin.xml` to `/boot/config/plugins/dockerMan/templates-user/`
   - Install "Umbrel Bitcoin" through the Apps tab
   - Wait for Bitcoin node to fully sync

2. **Install Electrs**:
   - Copy `umbrel-electrs.xml` to `/boot/config/plugins/dockerMan/templates-user/`
   - Install "Umbrel Electrs" through the Apps tab
   - Configure Bitcoin connection settings (see Configuration section)

### Method 2: Manual Installation

```bash
# First install Bitcoin node
cd ../bitcoin
./install-unraid.sh

# Wait for Bitcoin sync, then install Electrs
cd ../electrs
./install-electrs.sh
```

## Configuration

### Bitcoin Node Connection

**Critical**: These settings must match your Bitcoin node configuration:

| Variable | Default | Description | Must Match Bitcoin Node |
|----------|---------|-------------|-------------------------|
| `ELECTRS_DAEMON_RPC_USER` | umbrel | Bitcoin Core RPC username | ✅ Yes |
| `ELECTRS_DAEMON_RPC_PASS` | changeme | Bitcoin Core RPC password | ✅ Yes |
| `ELECTRS_DAEMON_RPC_ADDR` | bitcoin:8332 | Bitcoin Core RPC address | ✅ Yes |
| `ELECTRS_DAEMON_P2P_ADDR` | bitcoin:8333 | Bitcoin Core P2P address | ✅ Yes |

### Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `ELECTRS_NETWORK` | bitcoin | Bitcoin network (bitcoin, testnet, or regtest) |
| `ELECTRS_DAEMON_RPC_ADDR` | bitcoin:8332 | Bitcoin Core RPC address (hostname:port) |
| `ELECTRS_DAEMON_RPC_USER` | umbrel | Bitcoin Core RPC username |
| `ELECTRS_DAEMON_RPC_PASS` | changeme | Bitcoin Core RPC password (change this!) |
| `ELECTRS_DAEMON_P2P_ADDR` | bitcoin:8333 | Bitcoin Core P2P address (hostname:port) |
| `ELECTRS_ELECTRUM_RPC_ADDR` | 0.0.0.0:50001 | Electrum RPC bind address |
| `ELECTRS_ELECTRUM_RPC_ADDR_INDEX` | 0.0.0.0:50002 | Electrum index RPC bind address |
| `ELECTRS_HTTP_ADDR` | 0.0.0.0:3000 | HTTP API bind address |
| `ELECTRS_VERBOSITY` | 4 | Logging verbosity (0-5) |
| `ELECTRS_MONITORING_ADDR` | 0.0.0.0:4224 | Prometheus monitoring bind address |
| `ELECTRS_DB_DIR` | /home/electrs/.electrs/db | Database directory path |
| `ELECTRS_INDEX_BATCH_SIZE` | 10 | Index batch size for processing |
| `ELECTRS_INDEX_LIMIT` | 1000 | Index limit for queries |

### Ports

| Port | Protocol | Description |
|------|----------|-------------|
| 3000 | TCP | HTTP API interface |
| 50001 | TCP | Electrum RPC protocol |
| 50002 | TCP | Electrum index RPC protocol |
| 4224 | TCP | Prometheus metrics (optional) |

### Storage

The app stores Electrs data in `/mnt/user/appdata/umbrel-electrs` by default:
- Database files
- Configuration
- Logs
- Index data

## Integration with Bitcoin Node

Electrs requires a Bitcoin Core node to function. You can:

1. **Use the Umbrel Bitcoin app** (recommended):
   - Install both apps from Community Applications
   - Configure Electrs to connect to the Bitcoin container
   - Use container names for networking (`bitcoin:8332`, `bitcoin:8333`)

2. **Connect to external Bitcoin node**:
   - Update `ELECTRS_DAEMON_RPC_ADDR` to your node's IP
   - Ensure RPC credentials match exactly
   - Verify network compatibility

### Bitcoin Node Requirements

Your Bitcoin node must have:
- **RPC enabled** and accessible
- **Transaction indexing** enabled (`txindex=1`)
- **Block filter indexing** enabled (`blockfilterindex=1`)
- **Wallet disabled** (recommended for security)
- **Same network** as Electrs (mainnet, testnet, or regtest)

## Usage

### Accessing Electrs

- **HTTP API**: http://[YOUR_SERVER_IP]:3000
- **Electrum RPC**: [YOUR_SERVER_IP]:50001
- **Electrum Index RPC**: [YOUR_SERVER_IP]:50002
- **Prometheus Metrics**: http://[YOUR_SERVER_IP]:4224/metrics

### Connecting Electrum Wallets

1. **Electrum Wallet**:
   - Open Electrum wallet
   - Go to **Tools** → **Network**
   - Add custom server: `[YOUR_SERVER_IP]:50001:s`
   - Connect to your server

2. **Other Electrum-compatible wallets**:
   - Use the same connection details
   - Port 50001 for standard RPC
   - Port 50002 for index-based queries

### HTTP API Examples

```bash
# Get server status
curl http://your_server_ip:3000/

# Get block height
curl http://your_server_ip:3000/blocks/tip/height

# Get transaction info
curl http://your_server_ip:3000/tx/[TXID]
```

### Monitoring

- **Container Logs**: View in Unraid Docker tab
- **Prometheus Metrics**: Available at port 4224
- **Database Size**: Monitor storage usage in Unraid
- **Performance**: Check resource usage in Unraid

## Security Considerations

1. **RPC Credentials**: Change default Bitcoin Core RPC password
2. **Network Access**: Consider restricting external access
3. **Firewall**: Only expose necessary ports
4. **Updates**: Keep containers updated for security

## Performance Tuning

### Database Optimization

- **Index Batch Size**: Adjust `ELECTRS_INDEX_BATCH_SIZE` based on your hardware
- **Index Limit**: Modify `ELECTRS_INDEX_LIMIT` for query performance
- **Storage**: Use SSD for better database performance

### Resource Allocation

- **Memory**: Electrs is memory-efficient but monitor usage
- **CPU**: Rust implementation provides good performance
- **Network**: Ensure stable connection to Bitcoin node

## Troubleshooting

### Common Issues

1. **Connection to Bitcoin node fails**:
   - Verify Bitcoin node is running and synced
   - Check RPC credentials match exactly
   - Ensure network connectivity
   - Verify Bitcoin node has required indexes enabled

2. **Slow indexing**:
   - Check Bitcoin node sync status
   - Verify storage performance
   - Adjust batch size settings

3. **Port conflicts**:
   - Change port mappings if needed
   - Check for other services using same ports

4. **Bitcoin node not found**:
   - Ensure Bitcoin container is running
   - Check container names match
   - Verify both apps are on same Docker network

### Getting Help

- **GitHub Issues**: [Umbrel Apps Issues](https://github.com/getumbrel/umbrel-apps/issues)
- **Unraid Forums**: [Community Applications Support](https://forums.unraid.net/forum/68-community-applications/)
- **Electrs Documentation**: [Electrs GitHub](https://github.com/romanz/electrs)

## Contributing

This Community Application template is based on the [Umbrel Electrs app](https://github.com/getumbrel/umbrel-apps/tree/master/electrs). To contribute:

1. Fork the repository
2. Make your changes
3. Submit a pull request

## License

This project is licensed under the MIT License - see the [LICENSE](../LICENSE) file for details.

## Acknowledgments

- [Umbrel](https://github.com/getumbrel) for the Electrs app
- [Electrs](https://github.com/romanz/electrs) developers for the Rust implementation
- [Unraid Community](https://forums.unraid.net/) for the platform
