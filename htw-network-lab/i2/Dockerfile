FROM debian:bookworm-slim

RUN apt-get update && \
    apt-get install -y --no-install-recommends iproute2 iptables iputils-ping procps gawk sudo mtr-tiny traceroute e2fsprogs dnsutils netcat-traditional && \
    rm -rf /var/lib/apt/lists/*

RUN echo "root ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

COPY original_i2_startup.sh /original_i2_startup.sh
COPY wrapper.sh /wrapper.sh
RUN chmod +x /original_i2_startup.sh /wrapper.sh

ENTRYPOINT ["/wrapper.sh"]
