FROM debian:bookworm-slim

RUN apt-get update && \
    apt-get install -y --no-install-recommends iproute2 iptables iputils-ping procps sudo isc-dhcp-server netcat-traditional && \
    rm -rf /var/lib/apt/lists/*

RUN echo "root ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

COPY original_homerouter_startup.sh /original_homerouter_startup.sh
COPY rename_by_subnet.sh /rename_by_subnet.sh
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /original_homerouter_startup.sh /rename_by_subnet.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
