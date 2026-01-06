#!/usr/bin/env bash
# Install torchvision for Jetson
# Priority: GitHub releases -> Jetson AI Lab PyPI -> Source build
set -ex

PYTORCH_VERSION=$(python3 -c "import torch; print(torch.__version__.split('+')[0])")
PYTHON_VERSION=$(python3 -c "import sys; print(f'{sys.version_info.major}.{sys.version_info.minor}')")
echo "Installing torchvision for PyTorch ${PYTORCH_VERSION}"

# GitHub releases
GITHUB_OWNER="${GITHUB_OWNER:-911218sky}"
GITHUB_REPO="${GITHUB_REPO:-pytorch-docker-build}"
GITHUB_RELEASE_URL="https://github.com/${GITHUB_OWNER}/${GITHUB_REPO}/releases/download"

# Map PyTorch to torchvision version
case "${PYTORCH_VERSION%%.*}" in
    "2")
        case "${PYTORCH_VERSION#*.}" in
            "9"*) VISION_VERSION="0.22.0" ;;
            "8"*) VISION_VERSION="0.21.0" ;;
            "7"*) VISION_VERSION="0.20.0" ;;
            "6"*) VISION_VERSION="0.19.0" ;;
            "5"*) VISION_VERSION="0.18.0" ;;
            *) VISION_VERSION="0.22.0" ;;
        esac
        ;;
    *)
        VISION_VERSION="0.22.0"
        ;;
esac

PYTHON_TAG="cp${PYTHON_VERSION//./}"
WHEEL_NAME="torchvision-${VISION_VERSION}-${PYTHON_TAG}-${PYTHON_TAG}-linux_aarch64.whl"

# Step 1: Try GitHub releases
echo "Step 1: Checking GitHub releases..."
RELEASE_TAG="jetson-wheels-v${PYTORCH_VERSION}"
WHEEL_URL="${GITHUB_RELEASE_URL}/${RELEASE_TAG}/${WHEEL_NAME}"

if curl --output /dev/null --silent --head --fail "${WHEEL_URL}"; then
    echo "Found wheel in GitHub releases"
    if pip install --no-cache-dir "${WHEEL_URL}"; then
        echo "✓ torchvision installed from GitHub releases"
        python3 -c 'import torchvision; print(f"torchvision {torchvision.__version__} installed")'
        exit 0
    fi
fi

# Step 2: Try Jetson AI Lab PyPI
echo "Step 2: Trying Jetson AI Lab PyPI..."
if pip install --no-cache-dir \
    --index-url https://pypi.jetson-ai-lab.dev/simple \
    --trusted-host pypi.jetson-ai-lab.dev \
    torchvision 2>/dev/null; then
    echo "✓ torchvision installed from Jetson AI Lab PyPI"
    python3 -c 'import torchvision; print(f"torchvision {torchvision.__version__} installed")'
    exit 0
fi

# Step 3: Build from source
echo "Step 3: Building torchvision ${VISION_VERSION} from source..."

mkdir -p /wheels

git clone --branch "v${VISION_VERSION}" --depth=1 https://github.com/pytorch/vision /opt/torchvision || \
git clone --depth=1 https://github.com/pytorch/vision /opt/torchvision

cd /opt/torchvision

export FORCE_CUDA=1
export MAX_JOBS=${MAX_JOBS:-4}

python3 setup.py bdist_wheel --dist-dir /wheels
pip install /wheels/torchvision*.whl

cd /
rm -rf /opt/torchvision

python3 -c 'import torchvision; print(f"torchvision {torchvision.__version__} installed")'
echo "Wheel saved to /wheels/"
ls -la /wheels/torchvision*.whl
