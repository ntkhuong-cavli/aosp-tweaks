#!/bin/bash
set -e

# bash cmds/save.sh <output_dir> [Dockerfile_path] [image_tag]

# # Examples:
# bash cmds/save.sh ./output ./cts-stick/Dockerfile stick_testtools
# bash cmds/save.sh ./output ./cts/Dockerfile cqs290_cts
#
# Last tested with:
# bash cmds/save.sh ./stick_cts-14.0_r10-media_1.5-vsdk_I19b0fb0-vts ./cts-stick/Dockerfile stick_testtools
#

IMAGE_NAME="cavli-test-docker"

IMAGE_OUTDIR="$1"
DOCKERFILE_PATH="${2:-Dockerfile}"   # Default: ./Dockerfile
IMAGE_TAG="${3:-stick_testtools}"    # Default: stick_testtools

echo "=== Docker Image Saver ==="

# Check args
if [[ -z "$IMAGE_OUTDIR" ]]; then
    echo "Usage: $0 <output_dir> [Dockerfile_path] [image_tag]"
    echo "Example: $0 ./output ./cts-stick/Dockerfile stick_testtools"
    exit 1
fi

# Check directory
if [[ ! -d "$IMAGE_OUTDIR" ]]; then
    echo "[ERROR] Output directory not found: $IMAGE_OUTDIR"
    exit 1
fi

# Check Dockerfile
if [[ ! -f "$DOCKERFILE_PATH" ]]; then
    echo "[ERROR] Dockerfile not found: $DOCKERFILE_PATH"
    exit 1
fi

# Check image exists
if ! docker image inspect "$IMAGE_NAME:$IMAGE_TAG" >/dev/null 2>&1; then
    echo "[ERROR] Image not found: $IMAGE_NAME:$IMAGE_TAG"
    exit 1
fi

# Parse version from Dockerfile
echo "[INFO] Parsing version from Dockerfile..."

IMAGE_VER=$(grep -E 'echo\s+".*"\s*>\s*/etc/docker_image_version' "$DOCKERFILE_PATH" \
    | sed -E 's/.*echo\s+"([^"]+)".*/\1/' \
    | head -n1)

if [[ -z "$IMAGE_VER" ]]; then
    echo "[ERROR] Cannot find version in Dockerfile"
    echo "Expected: RUN echo \"VERSION\" > /etc/docker_image_version"
    exit 1
fi

echo "[OK] Detected version: $IMAGE_VER"

# Output file
OUTPUT_FILE="${IMAGE_OUTDIR}/docker-${IMAGE_VER}.tar"

# Warn if output file already exists
if [[ -f "$OUTPUT_FILE" ]]; then
    echo "[WARN] Output file already exists, overwriting:"
    echo "       $OUTPUT_FILE"
fi

# Save image
echo "[INFO] Saving image to:"
echo "       $OUTPUT_FILE"

docker save "$IMAGE_NAME:$IMAGE_TAG" -o "$OUTPUT_FILE"

# Verify
if [[ -f "$OUTPUT_FILE" ]]; then
    SIZE=$(du -h "$OUTPUT_FILE" | cut -f1)
    echo "[OK] Image saved successfully"
    echo "[INFO] File size: $SIZE"
else
    echo "[ERROR] Save failed"
    exit 1
fi
