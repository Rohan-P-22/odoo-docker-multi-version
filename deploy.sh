#!/bin/bash
set -e

echo "💾 Saving OLD image ID before pull..."
OLD_IMAGE=$(docker images rohanp1722/odoo-multi-version:latest -q)
echo "Old image: $OLD_IMAGE"

echo "🚀 Pulling latest image..."
docker pull rohanp1722/odoo-multi-version:latest

NEW_IMAGE=$(docker images rohanp1722/odoo-multi-version:latest -q)
echo "New image: $NEW_IMAGE"

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
  docker tag $OLD_IMAGE rohanp1722/odoo-multi-version:rollback
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
  docker tag $OLD_IMAGE rohanp1722/odoo-multi-version:rollback
  docker compose up -d --no-deps odoo19
  echo "🔙 Odoo19 rolled back!"
  exit 1
fi

echo "✅ Odoo19 OK"
echo "🔥 AUTO-ROLLBACK DEPLOY DONE 🔥"
