#!/bin/bash
set -e

echo "=== Before Install: Cleaning up old containers and resources ==="

cd /home/ubuntu/myapp || true

# Stop all running containers
if [ "$(docker ps -q)" ]; then
    echo "Stopping all running containers..."
    docker stop $(docker ps -q)
else
    echo "No running containers found."
fi

# Remove all stopped containers
if [ "$(docker ps -aq)" ]; then
    echo "Removing stopped containers..."
    docker rm -f $(docker ps -aq)
else
    echo "No stopped containers found."
fi

# Optional: remove unused Docker networks
if [ "$(docker network ls --filter "dangling=true" -q)" ]; then
    echo "Removing unused Docker networks..."
    docker network prune -f
fi

# Optional: remove dangling images
if [ "$(docker images -f "dangling=true" -q)" ]; then
    echo "Removing dangling Docker images..."
    docker rmi $(docker images -f "dangling=true" -q)
fi

# Optional: remove unused volumes
if [ "$(docker volume ls -qf "dangling=true")" ]; then
    echo "Removing unused Docker volumes..."
    docker volume prune -f
fi

echo "Docker cleanup completed."
