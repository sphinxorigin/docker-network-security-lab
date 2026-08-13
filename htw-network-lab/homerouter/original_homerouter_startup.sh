#!/bin/bash

set -e

# Interfaces (falls Namen mal variieren sollten, bleiben wir bei ens* wie im Labor)
IF_UP="ensI0"   # zu i5
IF_LAN="ensC0"  # clients
IF_SRV="ensS0"  # gameserver

# IPs setzen
sudo ip addr flush dev "$IF_UP"  || true
sudo ip addr flush dev "$IF_LAN" || true
sudo ip addr flush dev "$IF_SRV" || true

sudo ip addr add 10.10.0.2/30 dev "$IF_UP"
sudo ip addr add 192.168.0.1/24 dev "$IF_LAN"
sudo ip addr add 192.168.1.1/24 dev "$IF_SRV"

sudo ip neigh replace 10.10.0.1 lladdr 00:00:10:11:05:10 dev ensI0 nud permanent

# Forwarding an
sudo sysctl -w net.ipv4.ip_forward=1

# Optional: rp_filter aus (hilft bei asymmetrischen Wegen in Labs)
sudo sysctl -w net.ipv4.conf.all.rp_filter=0
sudo sysctl -w net.ipv4.conf.default.rp_filter=0
sudo sysctl -w net.ipv4.conf."$IF_UP".rp_filter=0
sudo sysctl -w net.ipv4.conf."$IF_LAN".rp_filter=0
sudo sysctl -w net.ipv4.conf."$IF_SRV".rp_filter=0

# iptables sauber resetten (wichtig!)
sudo iptables -F
sudo iptables -t nat -F
sudo iptables -X

sudo iptables -P INPUT ACCEPT
sudo iptables -P OUTPUT ACCEPT
sudo iptables -P FORWARD ACCEPT

# NAT ins ISP Netz (über i5)
sudo iptables -t nat -A POSTROUTING -o "$IF_UP" -j MASQUERADE

# DNAT: 10.10.0.2:12933 -> 192.168.1.10:12933
sudo iptables -t nat -A PREROUTING -i "$IF_UP" -p tcp --dport 12933 -j DNAT --to-destination 192.168.1.10:12933
sudo iptables -A FORWARD -i "$IF_UP" -o "$IF_SRV" -p tcp --dport 12933 -d 192.168.1.10 -j ACCEPT

# Default Route Richtung i5
sudo ip route replace default via 10.10.0.1 dev "$IF_UP"
# ARP Fix: i5 hat MAC 00:00:10:11:05:10
# (damit homerouter nicht von einer falschen Antwort "vergiftet" wird)
sudo ip neigh replace 10.10.0.1 lladdr 00:00:10:11:05:10 dev "$IF_UP" nud permanent

# DHCP: auf ensC0 lauschen
echo 'INTERFACESv4="ensC0"' | sudo tee /etc/default/isc-dhcp-server >/dev/null

# DHCP config: DNS = 100.96.0.8
sudo bash -lc 'cat > /etc/dhcp/dhcpd.conf << EOF
subnet 192.168.0.0 netmask 255.255.255.0 {
  range 192.168.0.100 192.168.0.200;
  option routers 192.168.0.1;
  option domain-name-servers 100.96.0.8;
}
EOF'

sudo service isc-dhcp-server restart

ip -br address
ip route show
ip neigh show dev "$IF_UP" | grep 10.10.0.1 || true


# Port-Forwarding zum Gameserver
iptables -t nat -A PREROUTING \
  -i ensI0 \
  -p tcp \
  --dport 12933 \
  -j DNAT \
  --to-destination 192.168.1.10:12933

# Rückweg absichern
iptables -t nat -A POSTROUTING \
  -o ensS0 \
  -p tcp \
  -d 192.168.1.10 \
  --dport 12933 \
  -j MASQUERADE

# Forwarding erlauben
iptables -A FORWARD \
  -i ensI0 \
  -o ensS0 \
  -p tcp \
  -d 192.168.1.10 \
  --dport 12933 \
  -j ACCEPT