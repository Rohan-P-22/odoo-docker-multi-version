#!/bin/bash

echo "🚀 Pull latest image..."
docker pull rohanp1722/odoo-multi-version:latest

# -------------------------
# ODOO18 ZERO DOWNTIME
# -------------------------
echo "🔄 Updating Odoo18..."

cd /opt/odoo-docker/odoo18

# Start new container without stopping old
docker compose up -d --no-deps --build odoo18

echo "⏳ Waiting for Odoo18 to be healthy..."
sleep 15

# Restart nginx (optional if using reverse proxy)
docker compose restart nginx18

echo "✅ Odoo18 updated!"

# -------------------------
# ODOO19 ZERO DOWNTIME
# -------------------------
echo "🔄 Updating Odoo19..."

cd /opt/odoo-docker/odoo19

docker compose up -d --no-deps --build odoo19

echo "⏳ Waiting for Odoo19..."
sleep 15

docker compose restart nginx19

echo "✅ Odoo19 updated!"

echo "🔥 ZERO DOWNTIME DEPLOY DONE 🔥"
