#!/bin/bash

if_by_mac() {
  ip -br link | awk -v m="$1" '$3 == m {print $1}' | cut -d@ -f1
}

IF_I2=$(if_by_mac "00:00:10:11:05:02")
IF_I4=$(if_by_mac "00:00:10:11:05:04")
IF_HR=$(if_by_mac "00:00:10:11:05:10")   # Link zum homerouter

echo "i5 links: to i2=$IF_I2 to i4=$IF_I4 to homerouter=$IF_HR"
if [ -z "$IF_I2" ] || [ -z "$IF_I4" ] || [ -z "$IF_HR" ]; then
  echo "ERROR: could not detect all i5 interfaces by MAC"
  exit 1
fi

sudo ip addr flush dev "$IF_I2"
sudo ip addr flush dev "$IF_I4"
sudo ip addr flush dev "$IF_HR"

sudo ip addr add 100.96.0.5/32 dev lo 2>/dev/null

sudo ip addr add 172.19.0.13/30 dev "$IF_I2"   # i5 <-> i2
sudo ip addr add 172.19.0.10/30 dev "$IF_I4"   # i5 <-> i4
sudo ip addr add 10.10.0.1/30   dev "$IF_HR"   # i5 <-> homerouter

# Loopbacks im Uhrzeigersinn: i5 -> i4
sudo ip route replace 100.96.0.2/32 via 172.19.0.9 dev "$IF_I4"
sudo ip route replace 100.96.0.3/32 via 172.19.0.9 dev "$IF_I4"
sudo ip route replace 100.96.0.4/32 via 172.19.0.9 dev "$IF_I4"
sudo ip route replace 100.96.0.8/32 via 172.19.0.9 dev "$IF_I4"
sudo ip route replace 100.96.0.9/32 via 172.19.0.9 dev "$IF_I4"

# Transfernetze gegen Uhrzeigersinn: i5 -> i2
sudo ip route replace 172.19.0.0/30  via 172.19.0.14 dev "$IF_I2"
sudo ip route replace 172.19.0.4/30  via 172.19.0.14 dev "$IF_I2"
sudo ip route replace 172.19.0.16/30 via 172.19.0.14 dev "$IF_I2"

# Default Richtung i2 (Internet)
sudo ip route replace default via 172.19.0.14 dev "$IF_I2"

# Routen zu den Heimnetzen über homerouter
sudo ip route replace 10.10.0.0/30 dev "$IF_HR"
sudo ip route replace 192.168.0.0/24 via 10.10.0.2 dev "$IF_HR"
sudo ip route replace 192.168.1.0/24 via 10.10.0.2 dev "$IF_HR"

sysctl net.ipv4.ip_forward

ip -br address
ip route show
