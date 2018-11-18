# PAD-151-Proxy-Server
Task for lab2 at PAD, FAF-151

## Working with containers

If you chose to run containers individually, use
```bash
docker build -t <image-name> .
docker --rm -it -p <host-port>:<container-port> <image-name> bash
```

But when your container depends on another one, you could issue `docker-compose up` command to build and run them.

When making new changes in the source files the images does *not* sync with them, therefore you're expected to restart the desired service with `docker-compose restart <service-name>`.
