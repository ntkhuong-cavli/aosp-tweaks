# Docker Commands Reference

## General Docker

```bash
# List all images
docker images

# Check storage in use
docker system df
```

### Cleanup

```bash
# Clean build cache
cd <docker_directory>
docker builder prune -a

# Full system prune (containers, images, networks, volumes)
cd <docker_directory>
docker system prune -af --volumes

# Bring down docker-compose stack with volumes
cd <docker_directory>
docker-compose down --volumes
```

### Image Management

```bash
# Remove a specific image
docker images          # get ID
docker rmi <ID>

# Rebuild a service (with or without cache)
docker-compose build --no-cache <service>
docker-compose build <service>
```

---

## Project Workflow

### Setup Environment

```bash
# cmds/env.sh — install docker-compose plugin
sudo apt update
sudo apt install docker-compose-plugin
```

### Build Images

Check docker-compose.yml for the image name (base/stick)

```bash
# cmds/build.sh
docker-compose build --no-cache base
# docker-compose build --no-cache cts
docker-compose build --no-cache stick

# Alternative: build directly from Dockerfile
# docker build -t cavli-test-docker:stick_testtools ./cts-stick
```

### Run Container

```bash
# cmds/run.sh

# Start the container
docker-compose up -d stick
# If you get any error, check the old container, remove it, then try bringing the container up again
docker ps -a # to get NAMES
docker stop <NAME>
docker rm <NAME>

# Attach a shell
docker exec -it stick_testtools bash

# Stop (inline)
# docker-compose stop stick
```

### Stop Container

```bash
# cmds/stop.sh
docker-compose stop stick

# Notes:
# - Inside the container, type "exit" to detach
# - Container started with --rm will be removed automatically on stop
# - Otherwise: docker ps  =>  docker stop <container_id>
```

### Save Image to File

```bash
# cmds/save.sh — usage:
bash cmds/save.sh <output_dir> [Dockerfile_path] [image_tag]

# Examples:
bash cmds/save.sh ./output ./cts-stick/Dockerfile stick_testtools
bash cmds/save.sh ./output ./cts/Dockerfile cqs290_cts

# Last tested:
bash cmds/save.sh /home/alvin/workspaces/002/cavli/projects/cts/aosp-tweaks/xTS_docker/release/deloy/STICK-LA5.0_CTS-14-R11_VSDK-9fc4089d_MEDIA-1.5_VTS-R22 ./targets/stick/Dockerfile stick_testtools
```

**save.sh behavior:**
- Image name is always `cavli-test-docker`
- Default tag: `stick_testtools`; default Dockerfile: `./Dockerfile`
- Parses version from `RUN echo "VERSION" > /etc/docker_image_version` in the Dockerfile
- Output file: `<output_dir>/docker-<VERSION>.tar`
- Validates: output dir exists, Dockerfile exists, image is built
- Warns and overwrites if output `.tar` already exists
- Temp file is written to `DOCKER_SAVE_TMPDIR` (default: `/home/alvin/documents/.docker-tmp`) then moved to the output dir — avoids "no space left" errors on the output disk

```bash
# Override tmp dir if needed:
DOCKER_SAVE_TMPDIR=/mnt/other-disk bash cmds/save.sh <output_dir> [Dockerfile_path] [image_tag]

# Ensure default tmp dir exists:
mkdir -p /home/alvin/documents/.docker-tmp
```
