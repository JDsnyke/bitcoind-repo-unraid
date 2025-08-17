FROM alpine:3.18

# Set environment variables
ENV LIGHTNING_VERSION=latest
ENV LIGHTNING_NETWORK=bitcoin
ENV LIGHTNING_BITCOIN_RPC_HOST=umbrel-bitcoin
ENV LIGHTNING_BITCOIN_RPC_PORT=8332
ENV LIGHTNING_BITCOIN_RPC_USER=umbrel
ENV LIGHTNING_BITCOIN_RPC_PASSWORD=moneyprintergobrrr
ENV LIGHTNING_BITCOIN_RPC_PROTOCOL=http
ENV LIGHTNING_ALIAS="Umbrel Lightning"
ENV LIGHTNING_COLOR=3399FF
ENV LIGHTNING_WEB_PORT=3000
ENV LIGHTNING_P2P_PORT=9735
ENV LIGHTNING_REST_PORT=8080
ENV LIGHTNING_LOG_LEVEL=info

# Install dependencies
RUN apk add --no-cache \
    bash \
    curl \
    jq \
    socat \
    && rm -rf /var/cache/apk/*

# Create lightning user
RUN addgroup -g 1000 lightning && \
    adduser -D -s /bin/bash -u 1000 -G lightning lightning

# Create startup script
RUN echo '#!/bin/bash' > /usr/local/bin/start-lightning.sh && \
    echo 'set -e' >> /usr/local/bin/start-lightning.sh && \
    echo '' >> /usr/local/bin/start-lightning.sh && \
    echo 'echo "Starting Umbrel Lightning..."' >> /usr/local/bin/start-lightning.sh && \
    echo '' >> /usr/local/bin/start-lightning.sh && \
    echo '# Wait for Bitcoin node to be ready' >> /usr/local/bin/start-lightning.sh && \
    echo 'echo "Waiting for Bitcoin node..."' >> /usr/local/bin/start-lightning.sh && \
    echo 'until curl -s -f -u "$LIGHTNING_BITCOIN_RPC_USER:$LIGHTNING_BITCOIN_RPC_PASSWORD" "http://$LIGHTNING_BITCOIN_RPC_HOST:$LIGHTNING_BITCOIN_RPC_PORT" > /dev/null 2>&1; do' >> /usr/local/bin/start-lightning.sh && \
    echo '    echo "Bitcoin node not ready, waiting..."' >> /usr/local/bin/start-lightning.sh && \
    echo '    sleep 10' >> /usr/local/bin/start-lightning.sh && \
    echo 'done' >> /usr/local/bin/start-lightning.sh && \
    echo '' >> /usr/local/bin/start-lightning.sh && \
    echo 'echo "Bitcoin node is ready!"' >> /usr/local/bin/start-lightning.sh && \
    echo '' >> /usr/local/bin/start-lightning.sh && \
    echo '# Start Lightning node' >> /usr/local/bin/start-lightning.sh && \
    echo 'echo "Starting Lightning node with network: $LIGHTNING_NETWORK"' >> /usr/local/bin/start-lightning.sh && \
    echo 'exec lightningd \' >> /usr/local/bin/start-lightning.sh && \
    echo '    --network="$LIGHTNING_NETWORK" \' >> /usr/local/bin/start-lightning.sh && \
    echo '    --bitcoin-rpc-host="$LIGHTNING_BITCOIN_RPC_HOST" \' >> /usr/local/bin/start-lightning.sh && \
    echo '    --bitcoin-rpc-port="$LIGHTNING_BITCOIN_RPC_PORT" \' >> /usr/local/bin/start-lightning.sh && \
    echo '    --bitcoin-rpc-user="$LIGHTNING_BITCOIN_RPC_USER" \' >> /usr/local/bin/start-lightning.sh && \
    echo '    --bitcoin-rpc-password="$LIGHTNING_BITCOIN_RPC_PASSWORD" \' >> /usr/local/bin/start-lightning.sh && \
    echo '    --bitcoin-rpc-protocol="$LIGHTNING_BITCOIN_RPC_PROTOCOL" \' >> /usr/local/bin/start-lightning.sh && \
    echo '    --alias="$LIGHTNING_ALIAS" \' >> /usr/local/bin/start-lightning.sh && \
    echo '    --color="$LIGHTNING_COLOR" \' >> /usr/local/bin/start-lightning.sh && \
    echo '    --web-port="$LIGHTNING_WEB_PORT" \' >> /usr/local/bin/start-lightning.sh && \
    echo '    --p2p-port="$LIGHTNING_P2P_PORT" \' >> /usr/local/bin/start-lightning.sh && \
    echo '    --rest-port="$LIGHTNING_REST_PORT" \' >> /usr/local/bin/start-lightning.sh && \
    echo '    --log-level="$LIGHTNING_LOG_LEVEL" \' >> /usr/local/bin/start-lightning.sh && \
    echo '    --daemon' >> /usr/local/bin/start-lightning.sh

RUN chmod +x /usr/local/bin/start-lightning.sh

# Expose ports
EXPOSE 3000 9735 8080

# Set working directory
WORKDIR /home/lightning

# Switch to lightning user
USER lightning

# Create data directory
RUN mkdir -p /home/lightning/.lightning

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD curl -f http://localhost:3000/ || exit 1

# Start Lightning
CMD ["/usr/local/bin/start-lightning.sh"]
