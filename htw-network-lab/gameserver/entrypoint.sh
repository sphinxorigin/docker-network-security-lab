#!/bin/bash
bash /original_gameserver_startup.sh
echo "[gameserver] Setup abgeschlossen, warte auf Verbindungen (Port 12933)..."
# Minimaler TCP-Listener, der die DNAT-Regel testbar macht (Original-Skript startet keinen Dienst)
while true; do
  { echo -e "connected to the awesome game server\r"; } | nc -l -p 12933 -q 1 2>/dev/null || sleep 1
done
