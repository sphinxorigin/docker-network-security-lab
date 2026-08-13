#!/bin/bash
bash /original_client1_startup.sh
echo "[client1] Setup abgeschlossen, Container bleibt aktiv."
tail -f /dev/null
