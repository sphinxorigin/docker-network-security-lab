#!/bin/bash

# Helper: Interface anhand MAC finden
if_by_mac() {
  ip -br link | awk -v m="$1" '$3 == m {print $1}' | cut -d@ -f1
}

IF_I3=$(if_by_mac "00:00:10:11:02:03")
IF_I4=$(if_by_mac "00:00:10:11:02:04")
IF_I5=$(if_by_mac "00:00:10:11:02:05")

echo "i2 links: to i3=$IF_I3 to i4=$IF_I4 to i5=$IF_I5"
if [ -z "$IF_I3" ] || [ -z "$IF_I4" ] || [ -z "$IF_I5" ]; then
  echo "ERROR: could not detect all i2 interfaces by MAC"
  exit 1
fi

# Clean IPs on those links
sudo ip addr flush dev "$IF_I3"
sudo ip addr flush dev "$IF_I4"
sudo ip addr flush dev "$IF_I5"

# Loopback
sudo ip addr add 100.96.0.2/32 dev lo 2>/dev/null

# IPs setzen
sudo ip addr add 172.19.0.1/30  dev "$IF_I3"   # i2 <-> i3
sudo ip addr add 172.19.0.17/30 dev "$IF_I4"   # i2 <-> i4
sudo ip addr add 172.19.0.14/30 dev "$IF_I5"   # i2 <-> i5

# Routing: Loopbacks im Uhrzeigersinn (i2 -> i5)
sudo ip route replace 100.96.0.3/32 via 172.19.0.13 dev "$IF_I5"
sudo ip route replace 100.96.0.4/32 via 172.19.0.13 dev "$IF_I5"
sudo ip route replace 100.96.0.5/32 via 172.19.0.13 dev "$IF_I5"
sudo ip route replace 100.96.0.8/32 via 172.19.0.13 dev "$IF_I5"
sudo ip route replace 100.96.0.9/32 via 172.19.0.13 dev "$IF_I5"

# Routing: Transfernetze gegen Uhrzeigersinn (i2 -> i3)
sudo ip route replace 172.19.0.4/30 via 172.19.0.2 dev "$IF_I3"
sudo ip route replace 172.19.0.8/30 via 172.19.0.2 dev "$IF_I3"

# Route zum Service-Netz (Rückweg für dns/webserver) über i4
sudo ip route replace 100.24.0.0/24 via 172.19.0.18 dev "$IF_I4"

# Internet weiterleiten
sudo sysctl -w net.ipv4.ip_forward=1

# iptables sauber machen (damit nichts "klebt")
sudo iptables -F
sudo iptables -t nat -F
sudo iptables -X

sudo iptables -P FORWARD ACCEPT
sudo iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE

ip -br address
ip route show

