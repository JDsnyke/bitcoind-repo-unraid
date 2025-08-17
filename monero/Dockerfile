FROM ubuntu:22.04

# Set environment variables
ENV MONERO_VERSION=latest
ENV MONERO_NETWORK=mainnet
ENV MONERO_RPC_BIND_IP=0.0.0.0
ENV MONERO_RPC_BIND_PORT=18089
ENV MONERO_P2P_BIND_IP=0.0.0.0
ENV MONERO_P2P_BIND_PORT=18090
ENV MONERO_ZMQ_RPC_BIND_IP=0.0.0.0
ENV MONERO_ZMQ_RPC_BIND_PORT=18091
ENV MONERO_ZMQ_PUB_BIND_IP=0.0.0.0
ENV MONERO_ZMQ_PUB_BIND_PORT=18092
ENV MONERO_RPC_LOGIN=monero:moneyprintergobrrr
ENV MONERO_RESTRICTED_RPC=1
ENV MONERO_DISABLE_RPC_LOGIN=0
ENV MONERO_SYNC_MODE=fast
ENV MONERO_PRUNING=0
ENV MONERO_DB_SALVAGE=0
ENV MONERO_MAX_CONCURRENCY=0
ENV MONERO_PREPARE_MULTISIG=0
ENV MONERO_OFFLINE=0
ENV MONERO_DATA_DIR=/home/monero/.bitmonero
ENV MONERO_LOG_LEVEL=1

# Install system dependencies
RUN apt-get update && apt-get install -y \
    wget \
    gnupg \
    ca-certificates \
    curl \
    jq \
    && rm -rf /var/lib/apt/lists/*

# Add Monero repository
RUN wget -qO - https://www.getmonero.org/downloads/hashes.txt | grep -oP 'https://[^"]*monero-linux-x64-v[0-9]+\.[0-9]+\.[0-9]+\.tar\.bz2' | head -1 | xargs wget -O /tmp/monero.tar.bz2

# Extract Monero
RUN tar -xjf /tmp/monero.tar.bz2 -C /tmp && \
    mv /tmp/monero-v* /opt/monero && \
    rm /tmp/monero.tar.bz2

# Create monero user
RUN groupadd -g 1000 monero && \
    useradd -m -s /bin/bash -u 1000 -g monero monero

# Create startup script
RUN echo '#!/bin/bash' > /usr/local/bin/start-monero.sh && \
    echo 'set -e' >> /usr/local/bin/start-monero.sh && \
    echo '' >> /usr/local/bin/start-monero.sh && \
    echo 'echo "Starting Umbrel Monero..."' >> /usr/local/bin/start-monero.sh && \
    echo '' >> /usr/local/bin/start-monero.sh && \
    echo '# Start Monero daemon' >> /usr/local/bin/start-monero.sh && \
    echo 'echo "Starting Monero daemon with network: $MONERO_NETWORK"' >> /usr/local/bin/start-monero.sh && \
    echo 'exec /opt/monero/monerod \' >> /usr/local/bin/start-monero.sh && \
    echo '    --network="$MONERO_NETWORK" \' >> /usr/local/bin/start-monero.sh && \
    echo '    --rpc-bind-ip="$MONERO_RPC_BIND_IP" \' >> /usr/local/bin/start-monero.sh && \
    echo '    --rpc-bind-port="$MONERO_RPC_BIND_PORT" \' >> /usr/local/bin/start-monero.sh && \
    echo '    --p2p-bind-ip="$MONERO_P2P_BIND_IP" \' >> /usr/local/bin/start-monero.sh && \
    echo '    --p2p-bind-port="$MONERO_P2P_BIND_PORT" \' >> /usr/local/bin/start-monero.sh && \
    echo '    --zmq-rpc-bind-ip="$MONERO_ZMQ_RPC_BIND_IP" \' >> /usr/local/bin/start-monero.sh && \
    echo '    --zmq-rpc-bind-port="$MONERO_ZMQ_RPC_BIND_PORT" \' >> /usr/local/bin/start-monero.sh && \
    echo '    --zmq-pub-bind-ip="$MONERO_ZMQ_PUB_BIND_IP" \' >> /usr/local/bin/start-monero.sh && \
    echo '    --zmq-pub-bind-port="$MONERO_ZMQ_PUB_BIND_PORT" \' >> /usr/local/bin/start-monero.sh && \
    echo '    --rpc-login="$MONERO_RPC_LOGIN" \' >> /usr/local/bin/start-monero.sh && \
    echo '    --restricted-rpc="$MONERO_RESTRICTED_RPC" \' >> /usr/local/bin/start-monero.sh && \
    echo '    --disable-rpc-login="$MONERO_DISABLE_RPC_LOGIN" \' >> /usr/local/bin/start-monero.sh && \
    echo '    --sync-mode="$MONERO_SYNC_MODE" \' >> /usr/local/bin/start-monero.sh && \
    echo '    --prune="$MONERO_PRUNING" \' >> /usr/local/bin/start-monero.sh && \
    echo '    --db-salvage="$MONERO_DB_SALVAGE" \' >> /usr/local/bin/start-monero.sh && \
    echo '    --max-concurrency="$MONERO_MAX_CONCURRENCY" \' >> /usr/local/bin/start-monero.sh && \
    echo '    --prepare-multisig="$MONERO_PREPARE_MULTISIG" \' >> /usr/local/bin/start-monero.sh && \
    echo '    --offline="$MONERO_OFFLINE" \' >> /usr/local/bin/start-monero.sh && \
    echo '    --data-dir="$MONERO_DATA_DIR" \' >> /usr/local/bin/start-monero.sh && \
    echo '    --log-level="$MONERO_LOG_LEVEL"' >> /usr/local/bin/start-monero.sh

RUN chmod +x /usr/local/bin/start-monero.sh

# Expose ports
EXPOSE 18089 18090 18091 18092

# Set working directory
WORKDIR /home/monero

# Switch to monero user
USER monero

# Create data directory
RUN mkdir -p /home/monero/.bitmonero

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD curl -f http://localhost:18089/json_rpc -X POST -H "Content-Type: application/json" -d '{"jsonrpc":"2.0","id":"0","method":"get_info"}' || exit 1

# Start Monero
CMD ["/usr/local/bin/start-monero.sh"]
