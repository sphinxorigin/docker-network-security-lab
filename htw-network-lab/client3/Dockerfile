FROM debian:bookworm-slim

RUN apt-get update && \
    apt-get install -y --no-install-recommends iproute2 isc-dhcp-client iputils-ping procps gawk sudo && \
    rm -rf /var/lib/apt/lists/*

RUN echo "root ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
COPY original_client3_startup.sh /original_client3_startup.sh
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
