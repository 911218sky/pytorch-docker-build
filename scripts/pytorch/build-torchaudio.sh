#!/usr/bin/env bash
# Build torchaudio from source for Jetson
set -ex

# Get PyTorch version to determine compatible torchaudio version
PYTORCH_VERSION=$(python3 -c "import torch; print(torch.__version__.split('+')[0])")
echo "Building torchaudio for PyTorch ${PYTORCH_VERSION}"

# Map PyTorch version to torchaudio version
# https://github.com/pytorch/audio#dependencies
case "${PYTORCH_VERSION%%.*}" in
    "2")
        case "${PYTORCH_VERSION#*.}" in
            "7"*) AUDIO_VERSION="2.7.0" ;;
            "6"*) AUDIO_VERSION="2.6.0" ;;
            "5"*) AUDIO_VERSION="2.5.0" ;;
            "4"*) AUDIO_VERSION="2.4.0" ;;
            "3"*) AUDIO_VERSION="2.3.0" ;;
            "2"*) AUDIO_VERSION="2.2.0" ;;
            "1"*) AUDIO_VERSION="2.1.0" ;;
            "0"*) AUDIO_VERSION="2.0.0" ;;
            *) AUDIO_VERSION="2.7.0" ;;
        esac
        ;;
    *)
        AUDIO_VERSION="2.7.0"
        ;;
esac

echo "Using torchaudio ${AUDIO_VERSION}"

# Clone and build
git clone --branch "v${AUDIO_VERSION}" --depth=1 https://github.com/pytorch/audio /opt/torchaudio || \
git clone --depth=1 https://github.com/pytorch/audio /opt/torchaudio

cd /opt/torchaudio

export USE_CUDA=1
export MAX_JOBS=${MAX_JOBS:-4}

python3 setup.py bdist_wheel --dist-dir /opt

cd /
rm -rf /opt/torchaudio

pip install /opt/torchaudio*.whl

python3 -c 'import torchaudio; print(f"torchaudio {torchaudio.__version__} installed")'

echo "torchaudio build completed!"
