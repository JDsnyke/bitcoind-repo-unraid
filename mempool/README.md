# Umbrel Mempool Community Application for Unraid

This repository contains the Community Application template for running the Umbrel Mempool explorer on Unraid servers.

## ⚠️ IMPORTANT: Bitcoin Node Required

**Umbrel Mempool requires a Bitcoin Core node to function.** You must install the [Umbrel Bitcoin](../bitcoin/) app first before installing Mempool.

## Overview

Umbrel Mempool is a Bitcoin mempool explorer that provides real-time transaction monitoring, fee estimation, and blockchain analytics. It offers a beautiful web interface to explore the Bitcoin network, monitor transaction fees, and analyze blockchain data.

## Features

- **Real-time Mempool Monitoring**: Live transaction pool visualization
- **Fee Estimation**: Accurate fee recommendations for transactions
- **Block Explorer**: Comprehensive blockchain data exploration
- **Network Statistics**: Live Bitcoin network metrics and analytics
- **Transaction Tracking**: Monitor specific transactions and addresses
- **Beautiful Web Interface**: Modern, responsive design
- **REST API**: Programmatic access to mempool data
- **Electrs Integration**: Enhanced functionality with Electrs (optional)

## Prerequisites

1. **Unraid 6.8+** with Community Applications plugin installed
2. **Docker** enabled on your Unraid server
3. **Bitcoin Node**: **REQUIRED** - A running Bitcoin Core node (install [Umbrel Bitcoin](../bitcoin/) first)
4. **Electrs** (optional): For enhanced functionality (install [Umbrel Electrs](../electrs/) first)
5. **Sufficient Storage**: Mempool data requires storage space
   - Mainnet: ~20-100GB (depending on indexing options)
   - Testnet: ~10-50GB
   - Signet: ~5-25GB

## Installation Order

**You must install the apps in this specific order:**

1. **First**: Install [Umbrel Bitcoin](../bitcoin/) and ensure it's fully synced
2. **Optional**: Install [Umbrel Electrs](../electrs/) for enhanced functionality
3. **Then**: Install Umbrel Mempool (this app)

## Installation

### Method 1: Community Applications (Recommended)

1. **Install Bitcoin first**:
   - Copy `../bitcoin/umbrel-bitcoin.xml` to `/boot/config/plugins/dockerMan/templates-user/`
   - Install "Umbrel Bitcoin" through the Apps tab
   - Wait for Bitcoin node to fully sync

2. **Optional - Install Electrs**:
   - Copy `../electrs/umbrel-electrs.xml` to `/boot/config/plugins/dockerMan/templates-user/`
   - Install "Umbrel Electrs" through the Apps tab

3. **Install Mempool**:
   - Copy `umbrel-mempool.xml` to `/boot/config/plugins/dockerMan/templates-user/`
   - Install "Umbrel Mempool" through the Apps tab
   - Configure Bitcoin and database connection settings

### Method 2: Manual Installation

```bash
# First install Bitcoin node
cd ../bitcoin
sudo ./install-bitcoin.sh

# Optional: Install Electrs
cd ../electrs
sudo ./install-electrs.sh

# Wait for services to be ready, then install Mempool
cd ../mempool
sudo ./install-mempool.sh
```

## Configuration

### Bitcoin Node Connection

**Critical**: These settings must match your Bitcoin node configuration:

| Variable | Default | Description | Must Match Bitcoin Node |
|----------|---------|-------------|-------------------------|
| `MEMPOOL_BITCOIN_USERNAME` | umbrel | Bitcoin Core RPC username | ✅ Yes |
| `MEMPOOL_BITCOIN_PASSWORD` | changeme | Bitcoin Core RPC password | ✅ Yes |
| `MEMPOOL_BITCOIN_HOST` | umbrel-bitcoin | Bitcoin Core RPC hostname | ✅ Yes |
| `MEMPOOL_BITCOIN_PORT` | 8332 | Bitcoin Core RPC port | ✅ Yes |

### Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `MEMPOOL_NETWORK` | mainnet | Bitcoin network (mainnet, testnet, or signet) |
| `MEMPOOL_BITCOIN_HOST` | umbrel-bitcoin | Bitcoin Core hostname |
| `MEMPOOL_BITCOIN_PORT` | 8332 | Bitcoin Core RPC port |
| `MEMPOOL_BITCOIN_USERNAME` | umbrel | Bitcoin Core RPC username |
| `MEMPOOL_BITCOIN_PASSWORD` | changeme | Bitcoin Core RPC password |
| `MEMPOOL_BITCOIN_P2P_HOST` | umbrel-bitcoin | Bitcoin Core P2P hostname |
| `MEMPOOL_BITCOIN_P2P_PORT` | 8333 | Bitcoin Core P2P port |
| `MEMPOOL_BITCOIN_DATA_DIR` | /mnt/user/appdata/umbrel-bitcoin/.bitcoin | Bitcoin data directory |
| `MEMPOOL_MYSQL_HOST` | umbrel-mempool-db | MySQL database hostname |
| `MEMPOOL_MYSQL_PORT` | 3306 | MySQL database port |
| `MEMPOOL_MYSQL_DATABASE` | mempool | MySQL database name |
| `MEMPOOL_MYSQL_USERNAME` | mempool | MySQL database username |
| `MEMPOOL_MYSQL_PASSWORD` | changeme | MySQL database password |
| `MEMPOOL_HTTP_PORT` | 3000 | HTTP web interface port |
| `MEMPOOL_API_PORT` | 8999 | API server port |
| `MEMPOOL_ENABLE_ELECTRS` | true | Enable Electrs integration |
| `MEMPOOL_ELECTRS_HOST` | umbrel-electrs | Electrs hostname |
| `MEMPOOL_ELECTRS_PORT` | 50001 | Electrs port |

### Ports

| Port | Protocol | Description |
|------|----------|-------------|
| 3000 | TCP | Web interface |
| 8999 | TCP | REST API |

### Storage

The app stores Mempool data in `/mnt/user/appdata/umbrel-mempool` by default:
- Application data
- Configuration files
- Cache data
- Logs

## Integration with Other Apps

### Bitcoin Node
Mempool requires a Bitcoin Core node to function:
- **RPC access** for blockchain data
- **P2P connection** for network monitoring
- **Data directory access** for blockchain files

### Electrs (Optional)
Enhanced functionality with Electrs:
- **Faster address lookups**
- **Better transaction indexing**
- **Improved performance**

### Database
Mempool uses MySQL for data storage:
- **Transaction data**
- **Fee estimates**
- **Network statistics**
- **User preferences**

## Usage

### Accessing Mempool

- **Web Interface**: http://[YOUR_SERVER_IP]:3000
- **REST API**: http://[YOUR_SERVER_IP]:8999

### Web Interface Features

1. **Dashboard**: Overview of Bitcoin network status
2. **Mempool**: Real-time transaction pool visualization
3. **Blocks**: Block explorer and information
4. **Fees**: Transaction fee estimation and analysis
5. **Network**: Network statistics and metrics
6. **API**: API documentation and testing

### REST API Examples

```bash
# Get mempool stats
curl http://your_server_ip:8999/api/v1/fees/recommended

# Get block information
curl http://your_server_ip:8999/api/v1/block/0000000000000000000000000000000000000000000000000000000000000000

# Get transaction details
curl http://your_server_ip:8999/api/v1/tx/your_transaction_id

# Get address information
curl http://your_server_ip:8999/api/v1/address/your_bitcoin_address
```

### Key Features

1. **Fee Estimation**: Get accurate fee recommendations
2. **Transaction Tracking**: Monitor specific transactions
3. **Address Lookup**: Explore address history and balance
4. **Network Monitoring**: Real-time network statistics
5. **Block Explorer**: Comprehensive block information

## Security Considerations

1. **RPC Credentials**: Change default Bitcoin Core RPC password
2. **Database Security**: Change default MySQL password
3. **Network Access**: Consider restricting external access
4. **Firewall**: Only expose necessary ports
5. **Updates**: Keep containers updated for security

## Performance Tuning

### Resource Allocation

- **Memory**: Monitor memory usage, especially with large mempools
- **CPU**: Moderate CPU usage for data processing
- **Storage**: SSD recommended for better database performance
- **Network**: Stable connection to Bitcoin node required

### Database Optimization

- **MySQL tuning**: Optimize database settings for your hardware
- **Indexing**: Ensure proper database indexing
- **Cleanup**: Regular data cleanup for old transactions
- **Backup**: Regular database backups

## Troubleshooting

### Common Issues

1. **Connection to Bitcoin node fails**:
   - Verify Bitcoin node is running and synced
   - Check RPC credentials match exactly
   - Ensure network connectivity
   - Verify Bitcoin node has required indexes enabled

2. **Database connection issues**:
   - Check MySQL container is running
   - Verify database credentials
   - Check database permissions
   - Verify network connectivity

3. **Web interface not accessible**:
   - Verify container is running
   - Check port mappings
   - Verify firewall settings
   - Check container logs

4. **Slow performance**:
   - Check Bitcoin node sync status
   - Verify storage performance
   - Check database performance
   - Monitor resource usage

### Getting Help

- **GitHub Issues**: [Umbrel Apps Issues](https://github.com/getumbrel/umbrel-apps/issues)
- **Unraid Forums**: [Community Applications Support](https://forums.unraid.net/forum/68-community-applications/)
- **Mempool Documentation**: [Mempool.space](https://mempool.space/)
- **Bitcoin Core Docs**: [Bitcoin Core Documentation](https://bitcoin.org/en/bitcoin-core/)

## Contributing

This Community Application template is based on the [Umbrel Mempool app](https://github.com/getumbrel/umbrel-apps/tree/master/mempool). To contribute:

1. Fork the repository
2. Make your changes
3. Submit a pull request

## License

This project is licensed under the MIT License - see the [LICENSE](../LICENSE) file for details.

## Acknowledgments

- [Umbrel](https://github.com/getumbrel) for the Mempool app
- [Mempool.space](https://mempool.space/) developers
- [Unraid Community](https://forums.unraid.net/) for the platform
