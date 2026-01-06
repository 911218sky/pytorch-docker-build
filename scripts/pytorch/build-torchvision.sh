#!/usr/bin/env bash
# Build torchvision from source for Jetson
set -ex

# Get PyTorch version to determine compatible torchvision version
PYTORCH_VERSION=$(python3 -c "import torch; print(torch.__version__.split('+')[0])")
echo "Building torchvision for PyTorch ${PYTORCH_VERSION}"

# Map PyTorch version to torchvision version
# https://github.com/pytorch/vision#installation
case "${PYTORCH_VERSION%%.*}" in
    "2")
        case "${PYTORCH_VERSION#*.}" in
            "7"*) VISION_VERSION="0.22.0" ;;
            "6"*) VISION_VERSION="0.21.0" ;;
            "5"*) VISION_VERSION="0.20.0" ;;
            "4"*) VISION_VERSION="0.19.0" ;;
            "3"*) VISION_VERSION="0.18.0" ;;
            "2"*) VISION_VERSION="0.17.0" ;;
            "1"*) VISION_VERSION="0.16.0" ;;
            "0"*) VISION_VERSION="0.15.0" ;;
            *) VISION_VERSION="0.22.0" ;;
        esac
        ;;
    *)
        VISION_VERSION="0.22.0"
        ;;
esac

echo "Using torchvision ${VISION_VERSION}"

# Clone and build
git clone --branch "v${VISION_VERSION}" --depth=1 https://github.com/pytorch/vision /opt/torchvision || \
git clone --depth=1 https://github.com/pytorch/vision /opt/torchvision

cd /opt/torchvision

export FORCE_CUDA=1
export MAX_JOBS=${MAX_JOBS:-4}

python3 setup.py bdist_wheel --dist-dir /opt

cd /
rm -rf /opt/torchvision

pip install /opt/torchvision*.whl

python3 -c 'import torchvision; print(f"torchvision {torchvision.__version__} installed")'

echo "torchvision build completed!"
