#!/bin/bash
set -e

IMAGE="cavli-test-docker:stick_testtools"
CONTAINER="cavli-test-cts"
FORCE=false

# Check arguments
if [[ "$1" == "--force" ]]; then
    FORCE=true
fi

echo "=== CTS Docker Setup ==="

# 1. Install docker if not exists
if ! command -v docker >/dev/null 2>&1; then
    echo "[INFO] Docker not found. Installing..."
    sudo apt update
    sudo apt install -y docker.io
    sudo systemctl enable docker
    sudo systemctl start docker
else
    echo "[OK] Docker already installed"
fi

# 2. Force cleanup (container only)
if [[ "$FORCE" == true ]]; then
    echo "[INFO] Force mode enabled. Removing old container..."

    if sudo docker ps -a --format '{{.Names}}' | grep -w "$CONTAINER" >/dev/null; then
        sudo docker rm -f "$CONTAINER"
        echo "[OK] Old container removed"
    else
        echo "[INFO] No existing container to remove"
    fi
fi

# 3. Check if container exists
if sudo docker ps -a --format '{{.Names}}' | grep -w "$CONTAINER" >/dev/null; then
    echo "[INFO] Container $CONTAINER already exists"

    # Get image used by existing container
    EXISTING_IMAGE=$(sudo docker inspect --format='{{.Config.Image}}' "$CONTAINER")

    if [[ "$EXISTING_IMAGE" != "$IMAGE" ]]; then
        echo "[WARN] Container image mismatch!"
        echo "[INFO] Existing: $EXISTING_IMAGE"
        echo "[INFO] Requested: $IMAGE"
        echo "[INFO] Recreating container..."

        sudo docker rm -f "$CONTAINER"

        sudo docker run -d \
          --name "$CONTAINER" \
          --privileged \
          --device=/dev/bus/usb:/dev/bus/usb \
          -v /dev:/dev \
          -v /etc/localtime:/etc/localtime:ro \
          -v /etc/timezone:/etc/timezone:ro \
          -it \
          "$IMAGE" \
          bash
    else
        # Start if stopped
        if ! sudo docker ps --format '{{.Names}}' | grep -w "$CONTAINER" >/dev/null; then
            echo "[INFO] Starting existing container..."
            sudo docker start "$CONTAINER"
        fi
    fi
else
    echo "[INFO] Creating new CTS container..."

    sudo docker run -d \
      --name "$CONTAINER" \
      --privileged \
      --device=/dev/bus/usb:/dev/bus/usb \
      -v /dev:/dev \
      -v /etc/localtime:/etc/localtime:ro \
      -v /etc/timezone:/etc/timezone:ro \
      -it \
      "$IMAGE" \
      bash
fi

# 4. Enter container
echo "[INFO] Attaching to CTS container..."
sudo docker exec -it "$CONTAINER" bash
