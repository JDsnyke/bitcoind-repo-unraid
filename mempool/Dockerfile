FROM node:18-alpine

# Set environment variables
ENV MEMPOOL_VERSION=latest
ENV MEMPOOL_NETWORK=mainnet
ENV MEMPOOL_BITCOIN_HOST=umbrel-bitcoin
ENV MEMPOOL_BITCOIN_PORT=8332
ENV MEMPOOL_BITCOIN_USERNAME=umbrel
ENV MEMPOOL_BITCOIN_PASSWORD=changeme
ENV MEMPOOL_BITCOIN_P2P_HOST=umbrel-bitcoin
ENV MEMPOOL_BITCOIN_P2P_PORT=8333
ENV MEMPOOL_BITCOIN_DATA_DIR=/mnt/user/appdata/umbrel-bitcoin/.bitcoin
ENV MEMPOOL_MYSQL_HOST=umbrel-mempool-db
ENV MEMPOOL_MYSQL_PORT=3306
ENV MEMPOOL_MYSQL_DATABASE=mempool
ENV MEMPOOL_MYSQL_USERNAME=mempool
ENV MEMPOOL_MYSQL_PASSWORD=changeme
ENV MEMPOOL_HTTP_PORT=3000
ENV MEMPOOL_API_PORT=8999
ENV MEMPOOL_ENABLE_ELECTRS=true
ENV MEMPOOL_ELECTRS_HOST=umbrel-electrs
ENV MEMPOOL_ELECTRS_PORT=50001

# Install system dependencies
RUN apk add --no-cache \
    bash \
    curl \
    git \
    python3 \
    make \
    g++ \
    && rm -rf /var/cache/apk/*

# Create mempool user
RUN addgroup -g 1000 mempool && \
    adduser -D -s /bin/bash -u 1000 -G mempool mempool

# Set working directory
WORKDIR /app

# Clone Mempool repository
RUN git clone https://github.com/mempool/mempool.git . && \
    git checkout v2.5.0

# Install Node.js dependencies
RUN npm ci --only=production

# Build the application
RUN npm run build

# Create startup script
RUN echo '#!/bin/bash' > /usr/local/bin/start-mempool.sh && \
    echo 'set -e' >> /usr/local/bin/start-mempool.sh && \
    echo '' >> /usr/local/bin/start-mempool.sh && \
    echo 'echo "Starting Umbrel Mempool..."' >> /usr/local/bin/start-mempool.sh && \
    echo '' >> /usr/local/bin/start-mempool.sh && \
    echo '# Wait for Bitcoin node to be ready' >> /usr/local/bin/start-mempool.sh && \
    echo 'echo "Waiting for Bitcoin node..."' >> /usr/local/bin/start-mempool.sh && \
    echo 'until curl -s -f -u "$MEMPOOL_BITCOIN_USERNAME:$MEMPOOL_BITCOIN_PASSWORD" "http://$MEMPOOL_BITCOIN_HOST:$MEMPOOL_BITCOIN_PORT" > /dev/null 2>&1; do' >> /usr/local/bin/start-mempool.sh && \
    echo '    echo "Bitcoin node not ready, waiting..."' >> /usr/local/bin/start-mempool.sh && \
    echo '    sleep 10' >> /usr/local/bin/start-mempool.sh && \
    echo 'done' >> /usr/local/bin/start-mempool.sh && \
    echo '' >> /usr/local/bin/start-mempool.sh && \
    echo 'echo "Bitcoin node is ready!"' >> /usr/local/bin/start-mempool.sh && \
    echo '' >> /usr/local/bin/start-mempool.sh && \
    echo '# Start Mempool' >> /usr/local/bin/start-mempool.sh && \
    echo 'echo "Starting Mempool with network: $MEMPOOL_NETWORK"' >> /usr/local/bin/start-mempool.sh && \
    echo 'exec npm start' >> /usr/local/bin/start-mempool.sh

RUN chmod +x /usr/local/bin/start-mempool.sh

# Expose ports
EXPOSE 3000 8999

# Switch to mempool user
USER mempool

# Create data directory
RUN mkdir -p /app/mempool

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD curl -f http://localhost:3000/ || exit 1

# Start Mempool
CMD ["/usr/local/bin/start-mempool.sh"]
