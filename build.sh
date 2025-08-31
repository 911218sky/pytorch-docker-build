#!/usr/bin/env bash
set -euo pipefail

# Defaults
TAG="${1:-sky1218/pytorch:2.7.1-cuda12.8-py3.11}"
# linux/amd64,linux/arm64
PLATFORMS="${2:-}"
DOCKERFILE="${3:-Dockerfile}"
CONTEXT="."

# If you want the script to push for multi-platform builds, set PUSH=1
PUSH="${PUSH:-0}"

echo "Tag:       $TAG"
echo "Platforms: ${PLATFORMS:-(not specified)}"
echo "Dockerfile:$DOCKERFILE"
echo "Push mode: $PUSH"
echo

# Basic checks
if ! command -v docker >/dev/null 2>&1; then
  echo "Error: docker not found in PATH." >&2
  exit 1
fi

if [[ ! -f "$DOCKERFILE" ]]; then
  echo "Error: Dockerfile not found: $DOCKERFILE" >&2
  exit 2
fi

if ! docker buildx version >/dev/null 2>&1; then
  echo "Error: docker buildx not available. Make sure you have a modern Docker CLI." >&2
  exit 3
fi

# Create and bootstrap a builder if none exists
if ! docker buildx inspect default >/dev/null 2>&1; then
  echo "No default buildx builder found — creating one..."
  docker buildx create --use --name mybuilder || true
  docker buildx inspect --bootstrap
fi

# Multi-platform handling
if [[ "$PLATFORMS" == *","* ]]; then
  echo "Detected multiple platforms."
  if [[ "$PUSH" != "1" ]]; then
    echo
    echo "Note: Multi-platform builds must be pushed to a registry (buildx --push)."
    echo "Please login (docker login) and run with PUSH=1, e.g.:"
    echo "  docker login <your-registry>"
    echo "  PUSH=1 ./build.sh ${TAG} ${PLATFORMS} ${DOCKERFILE}"
    exit 4
  fi

  echo "Running multi-platform build and pushing to registry..."
  docker buildx build \
    --platform "$PLATFORMS" \
    -f "$DOCKERFILE" \
    -t "$TAG" \
    --push \
    "$CONTEXT"

  echo
  echo "Multi-platform build pushed: $TAG"
  exit 0
fi

# Single-platform: build and load the image into local Docker
echo "Single-platform build (image will be loaded into local Docker)..."

if [[ -n "$PLATFORMS" ]]; then
  # platform explicitly provided (single platform)
  docker buildx build \
    --platform "$PLATFORMS" \
    -f "$DOCKERFILE" \
    -t "$TAG" \
    --load \
    "$CONTEXT"
else
  # no platform specified: do not pass --platform
  docker buildx build \
    -f "$DOCKERFILE" \
    -t "$TAG" \
    --load \
    "$CONTEXT"
fi

echo
echo "Build finished and image loaded locally: $TAG"
echo "Run: docker run --rm $TAG"