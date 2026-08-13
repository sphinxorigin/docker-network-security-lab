#!/bin/bash
echo "nameserver 100.96.0.8" > /etc/resolv.conf
bash /original_i4_startup.sh

# Zusaetzliche Route zum Subscription-Netz (nicht im Original-Skript enthalten,
# auf Wunsch ergaenzt, damit i4 -> homerouter erreichbar ist - das war die
# eigentliche Ursache, warum der webserver->gameserver DNAT-Test nicht ankam).
# 172.19.0.10 = i5's Adresse auf der i4<->i5-Verbindung, direkt erreichbar.
ip route add 10.10.0.0/30   via 172.19.0.10 2>/dev/null || true
ip route add 192.168.0.0/24 via 172.19.0.10 2>/dev/null || true
ip route add 192.168.1.0/24 via 172.19.0.10 2>/dev/null || true
echo "[i4] Zusatzroute zum Subscription-Netz via i5 (172.19.0.10) gesetzt."

echo "[i4] Setup abgeschlossen, Container bleibt aktiv."
tail -f /dev/null
