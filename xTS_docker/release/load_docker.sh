#!/bin/bash
set -e

IMAGE_NAME="cavli-test-docker:stick_testtools"
FORCE=false

# Check arguments
if [[ -z "$1" ]]; then
    echo "Usage: $0 <image_tar_path> [--force]"
    exit 1
fi

IMAGE_PATH="$1"

if [[ "$2" == "--force" ]]; then
    FORCE=true
fi

echo "=== Docker Image Loader ==="

# Check file exists
if [[ ! -f "$IMAGE_PATH" ]]; then
    echo "[ERROR] File not found: $IMAGE_PATH"
    exit 1
fi

# Check if image exists
IMAGE_EXIST=false
if sudo docker image inspect "$IMAGE_NAME" >/dev/null 2>&1; then
    IMAGE_EXIST=true
fi

# If exists and not force → stop
if [[ "$IMAGE_EXIST" == true && "$FORCE" == false ]]; then
    echo "[WARN] Image already exists: $IMAGE_NAME"
    echo "[INFO] Use --force to overwrite it"
    exit 0
fi

# Force remove old containers and image
if [[ "$FORCE" == true && "$IMAGE_EXIST" == true ]]; then
    echo "[INFO] Force mode enabled. Removing containers and image..."

    # Find containers using this image
    CONTAINERS=$(sudo docker ps -a --filter "ancestor=$IMAGE_NAME" -q)

    if [[ -n "$CONTAINERS" ]]; then
        echo "[INFO] Removing containers using $IMAGE_NAME..."

        if sudo docker rm -f $CONTAINERS; then
            echo "[OK] Containers removed"
        else
            echo "[ERROR] Failed to remove containers"
            exit 1
        fi
    else
        echo "[INFO] No containers using this image"
    fi

    # Remove image
    echo "[INFO] Removing image $IMAGE_NAME..."

    if sudo docker rmi -f "$IMAGE_NAME"; then
        echo "[OK] Image removed"
    else
        echo "[ERROR] Failed to remove image: $IMAGE_NAME"
        exit 1
    fi
fi

# Load image
echo "[INFO] Loading image from: $IMAGE_PATH"
sudo docker load -i "$IMAGE_PATH"

# Verify
if sudo docker image inspect "$IMAGE_NAME" >/dev/null 2>&1; then
    echo "[OK] Image loaded successfully: $IMAGE_NAME"
else
    echo "[ERROR] Image load failed: $IMAGE_NAME not found"
    exit 1
fi
