#!/usr/bin/env bash
# Build torchaudio from source for AMD64
# Saves wheel to /wheels for upload
set -ex

PYTORCH_VERSION=$(python3 -c "import torch; print(torch.__version__.split('+')[0])")
PYTHON_VERSION=$(python3 -c "import sys; print(f'{sys.version_info.major}.{sys.version_info.minor}')")
echo "Building torchaudio for PyTorch ${PYTORCH_VERSION} on AMD64"

# Map PyTorch to torchaudio version
case "${PYTORCH_VERSION%%.*}" in
    "2")
        case "${PYTORCH_VERSION#*.}" in
            "9"*) AUDIO_VERSION="2.9.0" ;;
            "8"*) AUDIO_VERSION="2.8.0" ;;
            "7"*) AUDIO_VERSION="2.7.0" ;;
            "6"*) AUDIO_VERSION="2.6.0" ;;
            "5"*) AUDIO_VERSION="2.5.0" ;;
            *) AUDIO_VERSION="2.7.0" ;;
        esac
        ;;
    *)
        AUDIO_VERSION="2.7.0"
        ;;
esac

mkdir -p /wheels

echo "========================================"
echo "Building torchaudio ${AUDIO_VERSION} from source..."
echo "========================================"

git clone --branch "v${AUDIO_VERSION}" --depth=1 https://github.com/pytorch/audio /opt/torchaudio || \
git clone --depth=1 https://github.com/pytorch/audio /opt/torchaudio

cd /opt/torchaudio

export USE_CUDA=1
export MAX_JOBS=${MAX_JOBS:-$(nproc)}
export TORCH_CUDA_ARCH_LIST="${TORCH_CUDA_ARCH_LIST:-8.0;8.6;8.9;9.0;10.0+PTX}"

python3 setup.py bdist_wheel --dist-dir /wheels
pip install /wheels/torchaudio*.whl

cd /
rm -rf /opt/torchaudio

python3 -c 'import torchaudio; print(f"torchaudio {torchaudio.__version__} installed")'
echo "========================================"
echo "Wheel saved to /wheels/"
ls -la /wheels/torchaudio*.whl
echo "========================================"
