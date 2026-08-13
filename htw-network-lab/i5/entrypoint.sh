#!/bin/bash
echo "nameserver 100.96.0.8" > /etc/resolv.conf
bash /original_i5_startup.sh

# Zusaetzliche Route zum Service-Netz als Ganzes (nicht im Original-Skript
# enthalten - i5 kennt bisher nur einzelne Loopback-/32-Adressen dort, aber
# nicht z.B. webserver's Netz-Adresse 100.24.0.9 selbst). i2 hat diese Route
# bereits (100.24.0.0/24 via i4); hier symmetrisch ergaenzt, damit Antworten
# von homerouter zurueck zu webserver nicht unnoetig ueber i2 umgeleitet werden.
ip route add 100.24.0.0/24 via 172.19.0.9 2>/dev/null || true
echo "[i5] Zusatzroute zum Service-Netz via i4 (172.19.0.9) gesetzt."

echo "[i5] Setup abgeschlossen, Container bleibt aktiv."
tail -f /dev/null
