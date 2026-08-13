#!/bin/bash
# Kompatibilitaets-Wrapper: Docker vergibt beim Start eigene Interface-Namen
# (eth0, eth1, ...), aber homerouter/dns/webserver erwarten feste Namen
# (ensI0/ensC0/ensS0 bzw. ensD0). Wir erkennen jedes Interface anhand des von
# Docker automatisch zugewiesenen Subnetzes und benennen es passend um -
# danach laeuft das unveraenderte Original-Skript.
#
# Aufruf: rename_by_subnet.sh "<subnet-prefix>:<zielname>" "<subnet-prefix>:<zielname>" ...
# Beispiel: rename_by_subnet.sh "10.10.0.:ensI0" "192.168.0.:ensC0" "192.168.1.:ensS0"

for mapping in "$@"; do
  prefix="${mapping%%:*}"
  target="${mapping##*:}"
  ifname=$(ip -o -4 addr show | awk -v p="$prefix" 'index($4,p)==1 {print $2}' | cut -d@ -f1)
  if [ -n "$ifname" ] && [ "$ifname" != "$target" ]; then
    ip link set dev "$ifname" down
    ip link set dev "$ifname" name "$target"
    ip link set dev "$target" up
    echo "[rename-wrapper] $ifname ($prefix*) -> $target"
  elif [ -z "$ifname" ]; then
    echo "[rename-wrapper] WARNUNG: kein Interface mit Subnetz $prefix gefunden"
  fi
done
