#!/bin/bash

if_by_mac() {
  ip -br link | awk -v m="$1" '$3 == m {print $1}' | cut -d@ -f1
}

IF_I2=$(if_by_mac "00:00:10:11:04:02")
IF_I3=$(if_by_mac "00:00:10:11:04:03")
IF_I5=$(if_by_mac "00:00:10:11:04:05")
IF_SV=$(if_by_mac "00:00:10:11:04:06")   # Service Interface (ensD0)

echo "i4 links: to i2=$IF_I2 to i3=$IF_I3 to i5=$IF_I5 service=$IF_SV"
if [ -z "$IF_I2" ] || [ -z "$IF_I3" ] || [ -z "$IF_I5" ] || [ -z "$IF_SV" ]; then
  echo "ERROR: could not detect all i4 interfaces by MAC"
  exit 1
fi

sudo ip addr flush dev "$IF_I2"
sudo ip addr flush dev "$IF_I3"
sudo ip addr flush dev "$IF_I5"
sudo ip addr flush dev "$IF_SV"

sudo ip addr add 100.96.0.4/32 dev lo 2>/dev/null

# Infrastruktur
sudo ip addr add 172.19.0.18/30 dev "$IF_I2"  # i4 <-> i2
sudo ip addr add 172.19.0.6/30  dev "$IF_I3"  # i4 <-> i3
sudo ip addr add 172.19.0.9/30  dev "$IF_I5"  # i4 <-> i5

# Service
sudo ip addr add 100.24.0.1/24 dev "$IF_SV"

# Loopbacks im Uhrzeigersinn (i4 -> i3)
sudo ip route replace 100.96.0.2/32 via 172.19.0.5 dev "$IF_I3"
sudo ip route replace 100.96.0.3/32 via 172.19.0.5 dev "$IF_I3"
sudo ip route replace 100.96.0.5/32 via 172.19.0.5 dev "$IF_I3"

# Transfernetze gegen Uhrzeigersinn (i4 -> i5)
sudo ip route replace 172.19.0.0/30  via 172.19.0.10 dev "$IF_I5"
sudo ip route replace 172.19.0.12/30 via 172.19.0.10 dev "$IF_I5"

# Service Loopbacks lokal
sudo ip route replace 100.96.0.8/32 via 100.24.0.8 dev "$IF_SV"
sudo ip route replace 100.96.0.9/32 via 100.24.0.9 dev "$IF_SV"

# Default Richtung i2 (Internet)
sudo ip route replace default via 172.19.0.17 dev "$IF_I2"

# Hopcount Fix: webserver/dns -> 172.17.0.1 muss 3 Hops sein
sudo ip route replace 172.17.0.0/16 via 172.19.0.17 dev "$IF_I2"

sudo sysctl -w net.ipv4.ip_forward=1

ip -br address
ip route show
