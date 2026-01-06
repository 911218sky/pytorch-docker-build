#!/usr/bin/env bash
# Install torchaudio for Jetson
# Priority: GitHub releases -> Jetson AI Lab PyPI -> Source build
set -ex

PYTORCH_VERSION=$(python3 -c "import torch; print(torch.__version__.split('+')[0])")
PYTHON_VERSION=$(python3 -c "import sys; print(f'{sys.version_info.major}.{sys.version_info.minor}')")
echo "Installing torchaudio for PyTorch ${PYTORCH_VERSION}"

# GitHub releases
GITHUB_OWNER="${GITHUB_OWNER:-911218sky}"
GITHUB_REPO="${GITHUB_REPO:-pytorch-docker-build}"
GITHUB_RELEASE_URL="https://github.com/${GITHUB_OWNER}/${GITHUB_REPO}/releases/download"

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

PYTHON_TAG="cp${PYTHON_VERSION//./}"
WHEEL_NAME="torchaudio-${AUDIO_VERSION}-${PYTHON_TAG}-${PYTHON_TAG}-linux_aarch64.whl"

# Step 1: Try GitHub releases
echo "Step 1: Checking GitHub releases..."
RELEASE_TAG="jetson-wheels-v${PYTORCH_VERSION}"
WHEEL_URL="${GITHUB_RELEASE_URL}/${RELEASE_TAG}/${WHEEL_NAME}"

if curl --output /dev/null --silent --head --fail "${WHEEL_URL}"; then
    echo "Found wheel in GitHub releases"
    if pip install --no-cache-dir "${WHEEL_URL}"; then
        echo "✓ torchaudio installed from GitHub releases"
        python3 -c 'import torchaudio; print(f"torchaudio {torchaudio.__version__} installed")'
        exit 0
    fi
fi

# Step 2: Try Jetson AI Lab PyPI
echo "Step 2: Trying Jetson AI Lab PyPI..."
if pip install --no-cache-dir \
    --index-url https://pypi.jetson-ai-lab.dev/simple \
    --trusted-host pypi.jetson-ai-lab.dev \
    torchaudio 2>/dev/null; then
    echo "✓ torchaudio installed from Jetson AI Lab PyPI"
    python3 -c 'import torchaudio; print(f"torchaudio {torchaudio.__version__} installed")'
    exit 0
fi

# Step 3: Build from source
echo "Step 3: Building torchaudio ${AUDIO_VERSION} from source..."

mkdir -p /wheels

git clone --branch "v${AUDIO_VERSION}" --depth=1 https://github.com/pytorch/audio /opt/torchaudio || \
git clone --depth=1 https://github.com/pytorch/audio /opt/torchaudio

cd /opt/torchaudio

export USE_CUDA=1
export MAX_JOBS=${MAX_JOBS:-4}

python3 setup.py bdist_wheel --dist-dir /wheels
pip install /wheels/torchaudio*.whl

cd /
rm -rf /opt/torchaudio

python3 -c 'import torchaudio; print(f"torchaudio {torchaudio.__version__} installed")'
echo "Wheel saved to /wheels/"
ls -la /wheels/torchaudio*.whl
