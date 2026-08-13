#!/bin/bash
echo "nameserver 100.96.0.8" > /etc/resolv.conf
bash /original_i3_startup.sh

# Zusaetzliche Route zum Subscription-Netz (nicht im Original-Skript enthalten,
# auf Wunsch ergaenzt). i3 hat keine direkte Leitung zu i5, daher ueber i4
# (172.19.0.6 = i4's Adresse auf der i3<->i4-Verbindung) - gleiche Hop-Zahl wie ueber i2.
ip route add 10.10.0.0/30   via 172.19.0.6 2>/dev/null || true
ip route add 192.168.0.0/24 via 172.19.0.6 2>/dev/null || true
ip route add 192.168.1.0/24 via 172.19.0.6 2>/dev/null || true
echo "[i3] Zusatzroute zum Subscription-Netz via i4 (172.19.0.6) gesetzt."

echo "[i3] Setup abgeschlossen, Container bleibt aktiv."
tail -f /dev/null
