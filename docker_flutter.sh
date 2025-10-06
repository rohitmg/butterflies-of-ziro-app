#!/usr/bin/env bash
set -euo pipefail

# Usage:
#   ./docker_flutter.sh <variant> [--verbose]
#
# Variants:
#   debug     → flutter build apk --debug
#   release   → flutter build apk --release
#   appbundle → flutter build appbundle --release

VARIANT=${1:-}
VERBOSE=${2:-}

if [[ -z "$VARIANT" ]]; then
  echo "Error: missing build variant (debug | release | appbundle)"
  exit 1
fi

# Use a project-specific image name
IMAGE_NAME="butterflies-of-ziro-build"

# Build output
BUILD_VOLUME="$(pwd)/build:/app/build"

# Project source mount (reflects live Dart changes)
PROJECT_VOLUME="$(pwd):/app"

# Named Docker volumes for caches
GRADLE_VOLUME="flutter_gradle_cache:/root/.gradle"
PUB_VOLUME="flutter_pub_cache:/root/.pub-cache"

# Ensure Docker volumes exist
docker volume inspect flutter_gradle_cache >/dev/null 2>&1 || docker volume create flutter_gradle_cache
docker volume inspect flutter_pub_cache >/dev/null 2>&1 || docker volume create flutter_pub_cache

# Mount keystores if they exist
KEYPROPS_MOUNT=""
[[ -f "android/key.properties" ]] && KEYPROPS_MOUNT="-v $(pwd)/android/key.properties:/app/android/key.properties"
[[ -f "$HOME/.android/debug.keystore" ]] && KEYPROPS_MOUNT="$KEYPROPS_MOUNT -v $HOME/.android/debug.keystore:/root/.android/debug.keystore"

# Clean up dangling images before building
docker image prune -f

# Build Docker image if it doesn't exist
docker image inspect "$IMAGE_NAME" >/dev/null 2>&1 || docker build -t "$IMAGE_NAME" .

# Memory cap
MEM_LIMIT=${MEM_LIMIT:-8g}

# Pick build command
case "$VARIANT" in
  debug)
    BUILD_CMD="flutter build apk --debug $VERBOSE"
    ;;
  release)
    BUILD_CMD="flutter build apk --release $VERBOSE"
    ;;
  appbundle)
    BUILD_CMD="flutter build appbundle --release $VERBOSE"
    ;;
  *)
    echo "Unknown variant: $VARIANT"
    exit 1
    ;;
esac

# Run build as your current user to avoid permission conflicts
docker run --rm \
  --user "$(id -u):$(id -g)" \
  -v "$PROJECT_VOLUME" \
  -v "$BUILD_VOLUME" \
  -v "$GRADLE_VOLUME" \
  -v "$PUB_VOLUME" \
  $KEYPROPS_MOUNT \
  --memory $MEM_LIMIT \
  "$IMAGE_NAME" \
  bash -c "
    flutter clean && \
    $BUILD_CMD
  "

# No need for sudo chown anymore!
# sudo chown -R $USER:$USER build/