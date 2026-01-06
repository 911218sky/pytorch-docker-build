#!/usr/bin/env bash
# Install PyTorch for Jetson
# Priority:
# 1. Try own GitHub releases (previously built wheels)
# 2. Build from source and upload to GitHub releases
#
# Adapted from: https://github.com/dusty-nv/jetson-containers
set -ex

TORCH_VERSION="${TORCH_VERSION:-2.7.0}"
PYTHON_VERSION="${PYTHON_VERSION:-3.11}"
PYTORCH_BUILD_VERSION="${PYTORCH_BUILD_VERSION:-${TORCH_VERSION}}"

# GitHub releases URL for our wheels
GITHUB_OWNER="${GITHUB_OWNER:-911218sky}"
GITHUB_REPO="${GITHUB_REPO:-pytorch-docker-build}"
GITHUB_RELEASE_URL="https://github.com/${GITHUB_OWNER}/${GITHUB_REPO}/releases/download"

# Wheel naming
PYTHON_TAG="cp${PYTHON_VERSION//./}"  # e.g., cp311
WHEEL_NAME="torch-${TORCH_VERSION}-${PYTHON_TAG}-${PYTHON_TAG}-linux_aarch64.whl"

echo "========================================"
echo "Installing PyTorch ${TORCH_VERSION} for Python ${PYTHON_VERSION}"
echo "========================================"

# Step 1: Try our own GitHub releases
echo "Step 1: Checking own GitHub releases..."
RELEASE_TAG="jetson-wheels-v${TORCH_VERSION}"
WHEEL_URL="${GITHUB_RELEASE_URL}/${RELEASE_TAG}/${WHEEL_NAME}"

if curl --output /dev/null --silent --head --fail "${WHEEL_URL}"; then
    echo "Found wheel in GitHub releases: ${WHEEL_URL}"
    if pip install --no-cache-dir "${WHEEL_URL}"; then
        echo "✓ PyTorch installed from GitHub releases"
        python3 -c 'import torch; print(f"PyTorch {torch.__version__} installed successfully")'
        exit 0
    fi
fi

# Step 2: Build from source
echo "========================================"
echo "Step 2: Building PyTorch from source..."
echo "========================================"
exec /tmp/pytorch/build-from-source.sh
