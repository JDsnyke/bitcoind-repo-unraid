# Umbrel Bitcoin Docker Container
# Based on the Umbrel Bitcoin app: https://github.com/getumbrel/umbrel-apps/tree/master/bitcoin

FROM ubuntu:22.04

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive
ENV BITCOIN_VERSION=25.0
ENV BITCOIN_NETWORK=mainnet
ENV BITCOIN_RPC_USER=umbrel
ENV BITCOIN_RPC_PASSWORD=moneyprintergobrrr
ENV BITCOIN_RPC_BIND=0.0.0.0
ENV BITCOIN_RPC_ALLOW_IP=0.0.0.0/0
ENV BITCOIN_DISABLE_WALLET=1
ENV BITCOIN_TXINDEX=1
ENV BITCOIN_BLOCKFILTERINDEX=1
ENV BITCOIN_PRUNING=0

# Install dependencies
RUN apt-get update && apt-get install -y \
    wget \
    gnupg \
    software-properties-common \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Add Bitcoin PPA and install Bitcoin Core
RUN wget -O - https://bitcoin.org/bitcoin-core-release-signing-keys.asc | apt-key add - \
    && echo "deb [arch=amd64] https://bitcoin.org/bitcoin-core/ focal main" > /etc/apt/sources.list.d/bitcoin.list \
    && apt-get update \
    && apt-get install -y bitcoin-core=${BITCOIN_VERSION} \
    && rm -rf /var/lib/apt/lists/*

# Create umbrel user
RUN useradd -m -s /bin/bash umbrel \
    && mkdir -p /home/umbrel/.bitcoin \
    && chown -R umbrel:umbrel /home/umbrel/.bitcoin

# Create startup script
RUN echo '#!/bin/bash\n\
# Set Bitcoin Core arguments\n\
ARGS="--network=${BITCOIN_NETWORK}"\n\
ARGS="${ARGS} --rpcuser=${BITCOIN_RPC_USER}"\n\
ARGS="${ARGS} --rpcpassword=${BITCOIN_RPC_PASSWORD}"\n\
ARGS="${ARGS} --rpcbind=${BITCOIN_RPC_BIND}"\n\
ARGS="${ARGS} --rpcallowip=${BITCOIN_RPC_ALLOW_IP}"\n\
ARGS="${ARGS} --disablewallet=${BITCOIN_DISABLE_WALLET}"\n\
ARGS="${ARGS} --txindex=${BITCOIN_TXINDEX}"\n\
ARGS="${ARGS} --blockfilterindex=${BITCOIN_BLOCKFILTERINDEX}"\n\
\n\
if [ "${BITCOIN_PRUNING}" != "0" ]; then\n\
    ARGS="${ARGS} --prune=${BITCOIN_PRUNING}"\n\
fi\n\
\n\
# Start Bitcoin Core\n\
exec bitcoind ${ARGS}' > /usr/local/bin/start-bitcoin.sh \
    && chmod +x /usr/local/bin/start-bitcoin.sh

# Expose ports
EXPOSE 8332 8333 18332 18333

# Set working directory
WORKDIR /home/umbrel

# Switch to umbrel user
USER umbrel

# Set volume
VOLUME ["/home/umbrel/.bitcoin"]

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=300s --retries=3 \
    CMD curl -f --user ${BITCOIN_RPC_USER}:${BITCOIN_RPC_PASSWORD} \
    --data-binary '{"jsonrpc": "1.0", "id": "healthcheck", "method": "getblockchaininfo", "params": []}' \
    -H 'content-type: text/plain;' http://127.0.0.1:8332/ || exit 1

# Start Bitcoin Core
CMD ["/usr/local/bin/start-bitcoin.sh"]
