
# Docker Commands Cheat Sheet

## Container Lifecycle

```bash
docker run <image>                     # Run a container
docker run -it ubuntu bash            # Run with interactive shell
docker run -d -p 8080:80 nginx        # Run in detached mode and map ports
docker ps                             # List running containers
docker ps -a                          # List all containers
docker stop <container_id>           # Stop a running container
docker start <container_id>          # Start a stopped container
docker restart <container_id>        # Restart a container
docker rm <container_id>             # Remove a stopped container
```

---

## Images & Layers

```bash
docker images                           # List images
docker rmi image_id                     # Remove image
docker tag local-image user/repo:tag   # Tag image for Docker Hub
docker build -t myapp:1.0 .             # Build image from Dockerfile
docker history myapp:1.0                # Show image layer history
```

---
## Executing Commands in Containers

```bash
docker exec -it <container_id> bash   # Start a bash session inside a running container
docker attach <container_id>          # Attach to a running container
```

---

## Volumes & Bind Mounts

```bash
docker volume create data_vol           # Create volume
docker run -v data_vol:/data nginx      # Mount volume
docker run -v $(pwd)/html:/usr/share/nginx/html nginx  # Bind mount
docker volume inspect data_vol          # Inspect volume
docker volume rm data_vol               # Delete volume
```

---

## Networking

```bash
docker network ls                       # List networks
docker network create mynet             # Create user-defined bridge network
docker run --network=mynet nginx        # Attach container to network
docker inspect container_id             # View IP address in network
```

---


## Multi-stage Builds

```dockerfile
# First stage: builder
FROM golang:1.21 AS builder
WORKDIR /app
COPY . .
RUN go build -o myapp

# Final stage: lightweight image
FROM alpine:latest
COPY --from=builder /app/myapp /usr/bin/myapp
CMD ["myapp"]
```

---

## Docker Compose

```bash
docker-compose up -d                    # Start services
docker-compose down                     # Stop and remove services
docker-compose logs -f                  # View logs
docker-compose exec web bash            # Access service container
```

---

## Security & Best Practices

- Use **non-root user** in Dockerfile: `USER appuser`
- Avoid hardcoding secrets; use `--env-file` or Docker Secrets
- Regularly scan images with `docker scan` or third-party tools

---

## Debugging & Monitoring

```bash
docker stats                            # Resource usage
docker logs web                         # View logs
docker inspect web                      # View detailed container info
docker events                           # Real-time events stream
```

---
## Cleanup

```bash
docker system prune                   # Remove unused data (containers, networks, images)
docker container prune                # Remove all stopped containers
docker image prune                    # Remove unused images
docker volume prune                   # Remove unused volumes
```

## References

- https://docs.docker.com/engine/reference/commandline/docker/
- https://docs.docker.com/develop/dev-best-practices/
- https://docs.docker.com/storage/volumes/
