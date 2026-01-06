#!/usr/bin/env bash
# Build PyTorch from source for Jetson
# Saves wheel to /wheels for upload to GitHub releases
# Adapted from: https://github.com/dusty-nv/jetson-containers
set -ex

TORCH_VERSION="${TORCH_VERSION:-2.7.0}"
PYTORCH_BUILD_VERSION="${PYTORCH_BUILD_VERSION:-${TORCH_VERSION}}"

echo "========================================"
echo "Building PyTorch ${PYTORCH_BUILD_VERSION}"
echo "========================================"

# Create wheels directory for upload
mkdir -p /wheels

# Clone PyTorch repository
git clone --branch "v${PYTORCH_BUILD_VERSION}" --depth=1 --recursive https://github.com/pytorch/pytorch /opt/pytorch || \
git clone --depth=1 --recursive https://github.com/pytorch/pytorch /opt/pytorch

cd /opt/pytorch

# Apply cpuinfo patch for ARM (https://github.com/pytorch/pytorch/issues/138333)
CPUINFO_PATCH=third_party/cpuinfo/src/arm/linux/aarch64-isa.c
if [ -f "${CPUINFO_PATCH}" ]; then
    sed -i 's|cpuinfo_log_error|cpuinfo_log_warning|' ${CPUINFO_PATCH}
    echo "Applied cpuinfo patch"
fi

# Install PyTorch requirements
pip install -r requirements.txt || true

# Set build flags
export USE_PRIORITIZED_TEXT_FOR_LD=1  # mandatory for ARM
export PYTORCH_BUILD_NUMBER=1
export USE_CUDA=1
export USE_CUDNN=1
export TORCH_CUDA_ARCH_LIST="${TORCH_CUDA_ARCH_LIST:-5.3;6.2;7.2;8.7}"
export USE_NCCL=${USE_NCCL:-0}
export USE_DISTRIBUTED=${USE_DISTRIBUTED:-0}
export USE_MKLDNN=0
export USE_FBGEMM=0
export USE_QNNPACK=0
export USE_NNPACK=0
export USE_XNNPACK=${USE_XNNPACK:-1}
export USE_PYTORCH_QNNPACK=${USE_PYTORCH_QNNPACK:-1}
export BUILD_TEST=0
export USE_MPI=0
export USE_TENSORRT=0
export USE_FLASH_ATTENTION=1
export USE_MEM_EFF_ATTENTION=1
export USE_NATIVE_ARCH=0

# BLAS settings for ARM
export USE_BLAS=1
export BLAS=OpenBLAS

# NVCC flags for compression
export TORCH_NVCC_FLAGS="-Xfatbin -compress-all -compress-mode=size"

# Build wheel
echo "Starting PyTorch build with MAX_JOBS=${MAX_JOBS:-4}"
python3 setup.py bdist_wheel --dist-dir /wheels

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

