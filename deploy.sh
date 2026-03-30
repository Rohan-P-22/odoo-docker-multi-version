#!/bin/bash

echo "📥 Pulling latest code..."
cd /opt/odoo-docker
git pull origin main

echo "🚀 Pull latest image..."
docker pull rohanp1722/odoo-multi-version:latest

echo "🔄 Restart Odoo18..."
cd /opt/odoo-docker/odoo18
docker compose up -d --scale odoo18=3

echo "🔄 Restart Odoo19..."
cd /opt/odoo-docker/odoo19
docker compose up -d --scale odoo19=3

echo "💾 Saving current image..."
OLD_IMAGE=$(docker images rohanp1722/odoo-multi-version:latest -q)

# -------------------------
# ODOO18 UPDATE
# -------------------------
echo "🔄 Updating Odoo18..."

cd /opt/odoo-docker/odoo18
docker compose up -d --no-deps odoo18

echo "⏳ Checking Odoo18 health..."

sleep 10

STATUS=$(docker inspect --format='{{.State.Health.Status}}' odoo18)

if [ "$STATUS" != "healthy" ]; then
  echo "❌ Odoo18 FAILED! Rolling back..."

  docker tag $OLD_IMAGE rohanp1722/odoo-multi-version:latest
  docker compose up -d --no-deps odoo18

  exit 1
fi

echo "✅ Odoo18 OK"

# -------------------------
# ODOO19 UPDATE
# -------------------------
echo "🔄 Updating Odoo19..."

cd /opt/odoo-docker/odoo19
docker compose up -d --no-deps odoo19

echo "⏳ Checking Odoo19 health..."

sleep 10

STATUS=$(docker inspect --format='{{.State.Health.Status}}' odoo19)

if [ "$STATUS" != "healthy" ]; then
  echo "❌ Odoo19 FAILED! Rolling back..."

  docker tag $OLD_IMAGE rohanp1722/odoo-multi-version:latest
  docker compose up -d --no-deps odoo19

  exit 1
fi

echo "✅ Odoo19 OK"

echo "🔥 AUTO-ROLLBACK DEPLOY DONE 🔥"
