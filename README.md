# sbox-server-wine-docker
 s&box server container using Alpine Linux & Wine

## Quick Setup
```
# Latest Public Build
sudo docker run giodotblue/sbox-server:latest +game facepunch.walker

# Latest Staging Build
sudo docker run giodotblue/sbox-server:staging-latest +game facepunch.walker

# Specific Staging Build
sudo docker run giodotblue/sbox-server:staging-17-06-2025 +game facepunch.walker
```

## Usage
Make sure [Docker and Docker Compose](https://docs.docker.com/engine/install/) are installed.

Edit the docker-compose.yml to your liking and then run:
```
docker compose up -d
```
