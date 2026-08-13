#!/bin/bash
/rename_by_subnet.sh "100.24.0.:ensD0"

# Gleicher Grund wie bei webserver: eigenes Skript flusht nicht, daher hier ergaenzt.
ip addr flush dev ensD0

bash /original_dns_startup.sh

cp /named.conf.local /etc/bind/named.conf.local
cp /named.conf.options /etc/bind/named.conf.options
cp /db.wirn.htw /etc/bind/db.wirn.htw

# /run/named existiert im frischen Container nicht (wird normalerweise von
# systemd-tmpfiles beim Boot angelegt) - named braucht es aber als "bind"-User
mkdir -p /run/named
chown bind:bind /run/named

echo "[dns] Starte BIND9..."
exec /usr/sbin/named -g -u bind
