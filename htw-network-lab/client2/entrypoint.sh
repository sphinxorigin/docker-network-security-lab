#!/bin/bash
bash /original_client2_startup.sh
echo "[client2] Setup abgeschlossen, Container bleibt aktiv."
tail -f /dev/null
