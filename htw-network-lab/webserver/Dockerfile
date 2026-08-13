FROM debian:bookworm-slim

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    iproute2 \
    iptables \
    iputils-ping \
    procps \
    sudo \
    netcat-openbsd \
    e2fsprogs \
    dnsutils \
    curl \
    python3 \
    python3-flask && \
    rm -rf /var/lib/apt/lists/*

RUN echo "root ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

COPY original_webserver_startup.sh /original_webserver_startup.sh
COPY rename_by_subnet.sh /rename_by_subnet.sh
COPY entrypoint.sh /entrypoint.sh
COPY app.py /app.py

RUN chmod +x /original_webserver_startup.sh /rename_by_subnet.sh /entrypoint.sh

CMD ["/entrypoint.sh"]