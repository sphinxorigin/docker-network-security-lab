#!/bin/bash

set -e

echo "[i2-wrapper] Starte i2-Konfiguration..."

# DNS zunächst setzen
echo "nameserver 100.96.0.8" > /etc/resolv.conf

# Originales HTW-Skript ausführen
bash /original_i2_startup.sh

# ---------------------------------------------------------
# Internet-Interface automatisch erkennen
# Erwartete Adresse: 172.30.0.2/24
# ---------------------------------------------------------

INTERNET_IF=$(ip -o -4 addr show | awk '$4 ~ /^172\.30\.0\./ {print $2}' | cut -d@ -f1 | head -n1)

if [ -z "$INTERNET_IF" ]; then
    echo "[i2-wrapper] ERROR: Internet-Interface im Netz 172.30.0.0/24 nicht gefunden."
    ip -br addr
    exit 1
fi

echo "[i2-wrapper] Internet-Interface erkannt: $INTERNET_IF"

# Interface aktivieren
ip link set dev "$INTERNET_IF" up

# Kurz warten, damit Kernel die Connected Route wieder einträgt
sleep 1

# ---------------------------------------------------------
# Default Route ins Docker-Internet
# Docker-Gateway des Netzes 172.30.0.0/24 = 172.30.0.1
# ---------------------------------------------------------

ip route replace default via 172.30.0.1 dev "$INTERNET_IF"

echo "[i2-wrapper] Default-Route gesetzt:"
ip route show default

# ---------------------------------------------------------
# NAT / Masquerading
# Die Originaldatei verwendet fest eth0.
# Das ist unter Docker Desktop nicht zuverlässig.
# Deshalb wird die Regel hier korrigiert.
# ---------------------------------------------------------

iptables -t nat -D POSTROUTING -o eth0 -j MASQUERADE 2>/dev/null || true
iptables -t nat -A POSTROUTING -o "$INTERNET_IF" -j MASQUERADE

echo "[i2-wrapper] NAT über $INTERNET_IF aktiviert."

# ---------------------------------------------------------
# Zusätzliche Routingtabellen Richtung Subscription-Netz
# i5 = 172.19.0.13
# ---------------------------------------------------------

ip route replace 10.10.0.0/30 via 172.19.0.13
ip route replace 192.168.0.0/24 via 172.19.0.13
ip route replace 192.168.1.0/24 via 172.19.0.13

echo "[i2-wrapper] Subscription-Routen gesetzt."

# ---------------------------------------------------------
# IPv4 Forwarding sicherstellen
# ---------------------------------------------------------

sysctl -w net.ipv4.ip_forward=1

# Forwarding erlauben
iptables -P FORWARD ACCEPT

# ---------------------------------------------------------
# Status ausgeben
# ---------------------------------------------------------

echo
echo "========== i2 Interfaces =========="
ip -br addr

echo
echo "========== i2 Routing =========="
ip route

echo
echo "========== i2 NAT =========="
iptables -t nat -L POSTROUTING -n -v

echo
echo "[i2-wrapper] Setup abgeschlossen."

tail -f /dev/null