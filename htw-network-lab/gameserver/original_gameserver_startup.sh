#!/bin/bash

if_by_mac() {
  ip -br link | awk -v m="$1" '$3 == m {print $1}' | cut -d@ -f1
}

IF_SV=$(if_by_mac "00:00:10:11:11:10")

echo "gameserver: if=$IF_SV"
if [ -z "$IF_SV" ]; then
  echo "ERROR: could not detect gameserver interface by MAC"
  exit 1
fi

sudo ip addr flush dev "$IF_SV"
sudo ip addr add 192.168.1.10/24 dev "$IF_SV"
sudo ip route replace default via 192.168.1.1 dev "$IF_SV"

ip -br address
ip route show