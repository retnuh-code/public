placeholder



cd

rm -rf ~/public


# 🛑 WARNING: This deletes EVERYTHING Docker-related. Use only if you're sure.

# Stop and remove all containers
docker rm -f $(docker ps -aq) 2>/dev/null

# Remove all images
docker rmi -f $(docker images -q) 2>/dev/null

# Remove all volumes
docker volume rm $(docker volume ls -q) 2>/dev/null

# Prune all unused networks
docker network prune -f

# Clear builder cache
docker builder prune -a -f

# Optional: reset Docker system-wide (clears everything)
docker system prune -a --volumes -f


git clone https://github.com/retnuh-code/public.git
cd ~/public/LibreShelf
docker compose build --no-cache
docker compose up -d
