#!/usr/bin/env bash
# Build PyTorch from source for AMD64/x86_64
# Saves wheel to /wheels for caching
set -ex

TORCH_VERSION="${TORCH_VERSION:-2.8.0}"
PYTORCH_BUILD_VERSION="${PYTORCH_BUILD_VERSION:-${TORCH_VERSION}}"
CUDA_VERSION="${CUDA_VERSION:-12.9}"

echo "========================================"
echo "Building PyTorch ${PYTORCH_BUILD_VERSION} for AMD64"
echo "CUDA Version: ${CUDA_VERSION}"
echo "========================================"

# Create wheels directory for upload
mkdir -p /wheels

# Check if PyTorch source is mounted
if [ ! -d "/opt/pytorch" ]; then
    echo "Error: /opt/pytorch not found. Please mount the PyTorch source code."
    exit 1
fi

cd /opt/pytorch

# Install PyTorch requirements
pip install -r requirements.txt || true

# Set build flags for AMD64
export PYTORCH_BUILD_NUMBER=1
export USE_CUDA=1
export BUILD_CAFFE2=0
export USE_DISTRIBUTED=0
export USE_MPI=0
export USE_GLOO=0
export USE_KINETO=0
export USE_TENSORRT=0
export USE_FLASH_ATTENTION=1
export USE_MEM_EFF_ATTENTION=1

# CUDA architecture list for common GPUs
# https://developer.nvidia.com/cuda-gpus
export TORCH_CUDA_ARCH_LIST="${TORCH_CUDA_ARCH_LIST:-8.0;8.6;8.9;9.0;10.0+PTX}"

# NVCC flags for compression
export TORCH_NVCC_FLAGS="-Xfatbin -compress-all"

# Build wheel
echo "Starting PyTorch build with MAX_JOBS=${MAX_JOBS:-$(nproc)}"
MAX_JOBS=${MAX_JOBS:-$(nproc)} python3 setup.py bdist_wheel --dist-dir /wheels

# Clean up source
cd /
rm -rf /opt/pytorch

# Install the built wheel
pip install /wheels/torch*.whl

# Verify installation
python3 -c 'import torch; print(f"PyTorch {torch.__version__} installed successfully"); print(f"CUDA available: {torch.cuda.is_available()}")'

echo "========================================"
echo "PyTorch build completed!"
echo "Wheel saved to: /wheels/"
ls -la /wheels/torch*.whl
echo "========================================"
