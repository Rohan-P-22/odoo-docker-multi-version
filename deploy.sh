#!/bin/bash

echo "🚀 Pull latest image..."
docker pull rohanp1722/odoo-multi-version:latest

echo "🔄 Restart Odoo18..."
cd /opt/odoo-docker/odoo18
docker compose down
docker compose up -d

echo "🔄 Restart Odoo19..."
cd /opt/odoo-docker/odoo19
docker compose down
docker compose up -d

echo "🔥 NEW DEPLOY WORKING 🔥"
echo "✅ Deployment complete!"
