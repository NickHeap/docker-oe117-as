# docker-oe117-db

## docker commands

### Build the docker image

```bash
docker build -t oe117-as:0.1 -t oe117-as:latest .
```

### Run the container

```bash
docker run -it --rm --name oe117-as -p 20931:20931 -p 3090:3090 -p 21100-21200:21100-21200 oe117-as:latest
```

### Run the container with a mapped volume

```bash
docker run -it --rm --name oe117-as -p 20931:20931 -p 3090:3090 -p 21100-21200:21100-21200 -v S:/workspaces/docker-volumes/appserver:/var/lib/openedge/code oe117-as:latest
```

### Run bash in the container

```bash
docker run -it --rm --name oe117-as -p 20931:20931 -p 3090:3090 -p 21100-21200:21100-21200 oe117-as:latest bash
```

### Exec bash in the running container

```bash
docker exec -it oe117-as bash
```

### Stop the container

```bash
docker stop oe117-as
```

### Clean the container

```bash
docker rm oe117-as
```
