#!/bin/bash

if_by_mac() {
  ip -br link | awk -v m="$1" '$3 == m {print $1}' | cut -d@ -f1
}

IF_I2=$(if_by_mac "00:00:10:11:03:02")
IF_I4=$(if_by_mac "00:00:10:11:03:04")

echo "i3 links: to i2=$IF_I2 to i4=$IF_I4"
if [ -z "$IF_I2" ] || [ -z "$IF_I4" ]; then
  echo "ERROR: could not detect all i3 interfaces by MAC"
  exit 1
fi

sudo ip addr flush dev "$IF_I2"
sudo ip addr flush dev "$IF_I4"

sudo ip addr add 100.96.0.3/32 dev lo 2>/dev/null

sudo ip addr add 172.19.0.2/30 dev "$IF_I2"   # i3 <-> i2
sudo ip addr add 172.19.0.5/30 dev "$IF_I4"   # i3 <-> i4

# Loopbacks im Uhrzeigersinn: i3 -> i2
sudo ip route replace 100.96.0.2/32 via 172.19.0.1 dev "$IF_I2"
sudo ip route replace 100.96.0.4/32 via 172.19.0.1 dev "$IF_I2"
sudo ip route replace 100.96.0.5/32 via 172.19.0.1 dev "$IF_I2"
sudo ip route replace 100.96.0.8/32 via 172.19.0.1 dev "$IF_I2"
sudo ip route replace 100.96.0.9/32 via 172.19.0.1 dev "$IF_I2"

# Transfernetze gegen Uhrzeigersinn: i3 -> i4
sudo ip route replace 172.19.0.8/30  via 172.19.0.6 dev "$IF_I4"
sudo ip route replace 172.19.0.12/30 via 172.19.0.6 dev "$IF_I4"
sudo ip route replace 172.19.0.16/30 via 172.19.0.6 dev "$IF_I4"

# Default Richtung i2 (Internet)
sudo ip route replace default via 172.19.0.1 dev "$IF_I2"