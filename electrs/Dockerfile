# Umbrel Electrs Docker Container
# Based on the Umbrel Electrs app: https://github.com/getumbrel/umbrel-apps/tree/master/electrs

FROM rust:1.70-slim

# Set environment variables
ENV ELECTRS_VERSION=0.10.0
ENV ELECTRS_NETWORK=bitcoin
ENV ELECTRS_DAEMON_RPC_ADDR=bitcoin:8332
ENV ELECTRS_DAEMON_RPC_USER=umbrel
ENV ELECTRS_DAEMON_RPC_PASS=moneyprintergobrrr
ENV ELECTRS_DAEMON_P2P_ADDR=bitcoin:8333
ENV ELECTRS_ELECTRUM_RPC_ADDR=0.0.0.0:50001
ENV ELECTRS_ELECTRUM_RPC_ADDR_INDEX=0.0.0.0:50002
ENV ELECTRS_HTTP_ADDR=0.0.0.0:3000
ENV ELECTRS_VERBOSITY=4
ENV ELECTRS_MONITORING_ADDR=0.0.0.0:4224
ENV ELECTRS_DB_DIR=/home/electrs/.electrs/db
ENV ELECTRS_INDEX_BATCH_SIZE=10
ENV ELECTRS_INDEX_LIMIT=1000

# Install system dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    pkg-config \
    libssl-dev \
    libsqlite3-dev \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Create electrs user
RUN useradd -m -s /bin/bash electrs \
    && mkdir -p /home/electrs/.electrs/db \
    && chown -R electrs:electrs /home/electrs/.electrs

# Clone and build Electrs
RUN cd /tmp \
    && git clone --branch v${ELECTRS_VERSION} https://github.com/romanz/electrs.git \
    && cd electrs \
    && cargo build --release \
    && cp target/release/electrs /usr/local/bin/ \
    && chmod +x /usr/local/bin/electrs \
    && cd / \
    && rm -rf /tmp/electrs

# Create startup script
RUN echo '#!/bin/bash\n\
# Set Electrs arguments\n\
ARGS="--network ${ELECTRS_NETWORK}"\n\
ARGS="${ARGS} --daemon-rpc-addr ${ELECTRS_DAEMON_RPC_ADDR}"\n\
ARGS="${ARGS} --daemon-rpc-user ${ELECTRS_DAEMON_RPC_USER}"\n\
ARGS="${ARGS} --daemon-rpc-pass ${ELECTRS_DAEMON_RPC_PASS}"\n\
ARGS="${ARGS} --daemon-p2p-addr ${ELECTRS_DAEMON_P2P_ADDR}"\n\
ARGS="${ARGS} --electrum-rpc-addr ${ELECTRS_ELECTRUM_RPC_ADDR}"\n\
ARGS="${ARGS} --electrum-rpc-addr-index ${ELECTRS_ELECTRUM_RPC_ADDR_INDEX}"\n\
ARGS="${ARGS} --http-addr ${ELECTRS_HTTP_ADDR}"\n\
ARGS="${ARGS} --verbosity ${ELECTRS_VERBOSITY}"\n\
ARGS="${ARGS} --monitoring-addr ${ELECTRS_MONITORING_ADDR}"\n\
ARGS="${ARGS} --db-dir ${ELECTRS_DB_DIR}"\n\
ARGS="${ARGS} --index-batch-size ${ELECTRS_INDEX_BATCH_SIZE}"\n\
ARGS="${ARGS} --index-limit ${ELECTRS_INDEX_LIMIT}"\n\
\n\
# Start Electrs\n\
exec electrs ${ARGS}' > /usr/local/bin/start-electrs.sh \
    && chmod +x /usr/local/bin/start-electrs.sh

# Expose ports
EXPOSE 3000 50001 50002 4224

# Set working directory
WORKDIR /home/electrs

# Switch to electrs user
USER electrs

# Set volume
VOLUME ["/home/electrs/.electrs"]

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=300s --retries=3 \
    CMD curl -f http://127.0.0.1:3000/ || exit 1

# Start Electrs
CMD ["/usr/local/bin/start-electrs.sh"]
