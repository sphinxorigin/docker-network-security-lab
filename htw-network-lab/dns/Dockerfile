FROM debian:bookworm-slim

RUN apt-get update && \
    apt-get install -y --no-install-recommends iproute2 iptables iputils-ping procps sudo bind9 tcpdump && \
    rm -rf /var/lib/apt/lists/*

RUN echo "root ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

COPY original_dns_startup.sh /original_dns_startup.sh
COPY rename_by_subnet.sh /rename_by_subnet.sh
COPY named.conf.local /named.conf.local
COPY named.conf.options /named.conf.options
COPY db.wirn.htw /db.wirn.htw
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /original_dns_startup.sh /rename_by_subnet.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
