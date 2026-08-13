FROM debian:bookworm-slim

RUN apt-get update && \
    apt-get install -y --no-install-recommends iproute2 iputils-ping procps gawk sudo netcat-traditional net-tools && \
    rm -rf /var/lib/apt/lists/*

RUN echo "root ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

COPY original_gameserver_startup.sh /original_gameserver_startup.sh
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /original_gameserver_startup.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
