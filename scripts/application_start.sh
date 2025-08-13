#!/bin/bash
set -e

echo "=== Application Start: Deploying containers with Docker Compose ==="

cd /home/ubuntu/myapp

# Make sure we have the latest images from Docker Hub
echo "Pulling latest images..."
docker-compose pull

# Start containers in detached mode
echo "Starting containers..."
docker-compose up -d

# Show status
echo "Deployment completed. Current container status:"
docker ps
