#!/bin/bash

set -e

echo "nameserver 100.24.0.8" > /etc/resolv.conf

/rename_by_subnet.sh "100.24.0.:ensD0"

bash /original_webserver_startup.sh || true

echo "[webserver] Starte VulnCorp Flask-App auf Port 8080..."
exec python3 /app.py