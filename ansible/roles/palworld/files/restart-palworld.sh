#!/bin/bash

# Broadcast a restart warning message
docker compose exec palworld rcon-cli "Broadcast Rebooting_in_5_minutes..."

# Wait 4 minutes before continuing
sleep 240

# Broadcast a restart warning message
docker compose exec palworld rcon-cli "Broadcast Rebooting_in_1_minute..."

# Wait 55 seconds before continuing
sleep 55

# Broadcast a restart warning message
docker compose exec palworld rcon-cli "shutdown 60 Rebooting_in_5_seconds..."
sleep 1
docker compose exec palworld rcon-cli "shutdown 60 Rebooting_in_4_seconds..."
sleep 1
docker compose exec palworld rcon-cli "shutdown 60 Rebooting_in_3_seconds..."
sleep 1
docker compose exec palworld rcon-cli "shutdown 60 Rebooting_in_2_seconds..."
sleep 1
docker compose exec palworld rcon-cli "shutdown 60 Rebooting_in_1_seconds..."

# Stop the container, update it, and start/recreate it
docker compose stop
docker compose pull
docker compose up -d
