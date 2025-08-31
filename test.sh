#!/usr/bin/env bash
set -euo pipefail

IMAGE_TAG="${1:-sky1218/pytorch:2.8.0-cuda12.9-py3.11}"
USE_GPU="${2:-gpu}"

SCRIPT="test.py"
if [[ ! -f "$SCRIPT" ]]; then
  echo "Error: $SCRIPT not found in current directory." >&2
  exit 2
fi

if ! command -v docker >/dev/null 2>&1; then
  echo "Error: docker not found in PATH." >&2
  exit 3
fi

echo "Running ${SCRIPT} inside Docker image: ${IMAGE_TAG}"
echo "Mounting current directory into /app inside the container."

# Decide whether to enable GPU
GPU_FLAG=()
if [[ "$USE_GPU" == "gpu" || "$USE_GPU" == "--gpu" ]]; then
  echo "⚡ GPU mode enabled (--gpus all)"
  GPU_FLAG=(--gpus all)
else
  echo "🖥️  CPU-only mode"
fi

# Run docker container with mount and run test.py
docker run --rm "${GPU_FLAG[@]}" \
  -v "$(pwd)":/app \
  -w /app \
  "${IMAGE_TAG}" \
  python3 "${SCRIPT}"

EXIT_CODE=$?

if [[ $EXIT_CODE -eq 0 ]]; then
  echo "Docker test: ✅ SUCCESS (exit code 0)"
else
  echo "Docker test: ❌ FAILED (exit code ${EXIT_CODE})"
fi

exit $EXIT_CODE
