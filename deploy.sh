#!/bin/bash
set -e

echo "💾 Saving OLD image IDs before pull..."
OLD_IMAGE_18=$(docker images rohanp1722/odoo-multi-version:18-latest -q)
OLD_IMAGE_19=$(docker images rohanp1722/odoo-multi-version:19-latest -q)
echo "Old odoo18 image: $OLD_IMAGE_18"
echo "Old odoo19 image: $OLD_IMAGE_19"

echo "🚀 Pulling latest images..."
docker pull rohanp1722/odoo-multi-version:18-latest
docker pull rohanp1722/odoo-multi-version:19-latest

# -------------------------
# ODOO18 UPDATE
# -------------------------
echo "🔄 Updating Odoo18..."
cd /opt/odoo-docker/odoo18
docker compose up -d --no-deps odoo18

echo "⏳ Waiting for Odoo18 to start (60s)..."
sleep 60

STATUS=$(docker inspect --format='{{.State.Health.Status}}' odoo18)
echo "Odoo18 status: $STATUS"

if [ "$STATUS" != "healthy" ]; then
  echo "❌ Odoo18 FAILED! Rolling back..."
  docker tag $OLD_IMAGE_18 rohanp1722/odoo-multi-version:18-latest
  docker compose up -d --no-deps odoo18
  echo "🔙 Odoo18 rolled back!"
  exit 1
fi

echo "✅ Odoo18 OK"

# -------------------------
# ODOO19 UPDATE
# -------------------------
echo "🔄 Updating Odoo19..."
cd /opt/odoo-docker/odoo19
docker compose up -d --no-deps odoo19

echo "⏳ Waiting for Odoo19 to start (60s)..."
sleep 60

STATUS=$(docker inspect --format='{{.State.Health.Status}}' odoo19)
echo "Odoo19 status: $STATUS"

if [ "$STATUS" != "healthy" ]; then
  echo "❌ Odoo19 FAILED! Rolling back..."
  docker tag $OLD_IMAGE_19 rohanp1722/odoo-multi-version:19-latest
  docker compose up -d --no-deps odoo19
  echo "🔙 Odoo19 rolled back!"
  exit 1
fi

echo "✅ Odoo19 OK"
echo "🔥 AUTO-ROLLBACK DEPLOY DONE 🔥"
