#!/usr/bin/env bash
# Build torchvision from source for AMD64
# Saves wheel to /wheels for upload
set -ex

PYTORCH_VERSION=$(python3 -c "import torch; print(torch.__version__.split('+')[0])")
PYTHON_VERSION=$(python3 -c "import sys; print(f'{sys.version_info.major}.{sys.version_info.minor}')")
echo "Building torchvision for PyTorch ${PYTORCH_VERSION} on AMD64"

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

mkdir -p /wheels

echo "========================================"
echo "Building torchvision ${VISION_VERSION} from source..."
echo "========================================"

git clone --branch "v${VISION_VERSION}" --depth=1 https://github.com/pytorch/vision /opt/torchvision || \
git clone --depth=1 https://github.com/pytorch/vision /opt/torchvision

cd /opt/torchvision

export FORCE_CUDA=1
export MAX_JOBS=${MAX_JOBS:-$(nproc)}
export TORCH_CUDA_ARCH_LIST="${TORCH_CUDA_ARCH_LIST:-5.2;6.0;6.1;7.0;7.5;8.0;8.6;8.9;9.0+PTX}"

python3 setup.py bdist_wheel --dist-dir /wheels
pip install /wheels/torchvision*.whl

cd /
rm -rf /opt/torchvision

python3 -c 'import torchvision; print(f"torchvision {torchvision.__version__} installed")'
echo "========================================"
echo "Wheel saved to /wheels/"
ls -la /wheels/torchvision*.whl
echo "========================================"
