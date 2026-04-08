#!/bin/bash
set -e

echo "Saving OLD image IDs before pull..."
OLD_IMAGE_18=$(docker images rohanp1722/odoo-multi-version:18-latest -q)
OLD_IMAGE_19=$(docker images rohanp1722/odoo-multi-version:19-latest -q)
echo "Old odoo18 image: $OLD_IMAGE_18"
echo "Old odoo19 image: $OLD_IMAGE_19"

echo "Pulling latest images..."
docker pull rohanp1722/odoo-multi-version:18-latest
docker pull rohanp1722/odoo-multi-version:19-latest

echo "Updating Odoo18..."
cd /opt/odoo-docker/odoo18
docker compose up -d --no-deps odoo18

echo "Waiting for Odoo18 to start..."
MAX_WAIT=120
ELAPSED=0
while [ $ELAPSED -lt $MAX_WAIT ]; do
  STATUS=$(docker inspect --format='{{.State.Health.Status}}' odoo18)
  if [ "$STATUS" = "healthy" ] || [ "$STATUS" = "unhealthy" ]; then
    break
  fi
  echo "  Still starting... (${ELAPSED}s)"
  sleep 5
  ELAPSED=$((ELAPSED + 5))
done

echo "Odoo18 status: $STATUS"
if [ "$STATUS" != "healthy" ]; then
  echo "Odoo18 FAILED Rolling back..."
  docker tag $OLD_IMAGE_18 rohanp1722/odoo-multi-version:18-latest
  docker compose up -d --no-deps odoo18
  echo "Odoo18 rolled back"
  exit 1
fi

echo "Odoo18 OK"

echo "Updating Odoo19..."
cd /opt/odoo-docker/odoo19
docker compose up -d --no-deps odoo19

echo "Waiting for Odoo19 to start..."
MAX_WAIT=120
ELAPSED=0
while [ $ELAPSED -lt $MAX_WAIT ]; do
  STATUS=$(docker inspect --format='{{.State.Health.Status}}' odoo19)
  if [ "$STATUS" = "healthy" ] || [ "$STATUS" = "unhealthy" ]; then
    break
  fi
  echo "  Still starting... (${ELAPSED}s)"
  sleep 5
  ELAPSED=$((ELAPSED + 5))
done

echo "Odoo19 status: $STATUS"
if [ "$STATUS" != "healthy" ]; then
  echo "Odoo19 FAILED Rolling back..."
  docker tag $OLD_IMAGE_19 rohanp1722/odoo-multi-version:19-latest
  docker compose up -d --no-deps odoo19
  echo "Odoo19 rolled back"
  exit 1
fi

echo "Odoo19 OK"
echo "DEPLOY DONE"
