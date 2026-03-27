#!/bin/bash

echo "🚀 Pull latest image..."
docker pull rohanp1722/odoo-multi-version:latest

echo "🔄 Restart Odoo18..."
cd /opt/odoo-docker/odoo18
docker compose pull
docker compose up -d --build

echo "🔄 Restart Odoo19..."
cd /opt/odoo-docker/odoo19
docker compose pull
docker compose up -d --build

echo "🔥 NEW DEPLOY WORKING 🔥"
echo "✅ Deployment complete!"
