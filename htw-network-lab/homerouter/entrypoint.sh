#!/bin/bash
/rename_by_subnet.sh "10.10.10.:ensI0" "192.168.0.:ensC0" "192.168.1.:ensS0"
bash /homerouter_startup.sh
echo "[homerouter] Setup abgeschlossen, Container bleibt aktiv."
tail -f /dev/null
