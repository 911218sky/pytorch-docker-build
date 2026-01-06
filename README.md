# PyTorch Docker Builder

Automated Docker image builder for PyTorch with customizable Python, PyTorch, and CUDA versions.

## Available Images

| Tag                     | PyTorch | CUDA | Python |
| ----------------------- | ------- | ---- | ------ |
| `2.7.1-cuda12.8-py3.11` | 2.7.1   | 12.8 | 3.11   |
| `2.7.1-cuda12.8-py3.12` | 2.7.1   | 12.8 | 3.12   |
| `2.8.0-cuda12.8-py3.11` | 2.8.0   | 12.8 | 3.11   |
| `2.8.0-cuda12.8-py3.12` | 2.8.0   | 12.8 | 3.12   |
| `2.9.0-cuda12.8-py3.11` | 2.9.0   | 12.8 | 3.11   |
| `2.9.0-cuda12.8-py3.12` | 2.9.0   | 12.8 | 3.12   |
| `2.9.0-cuda13.0-py3.11` | 2.9.0   | 13.0 | 3.11   |
| `2.9.0-cuda13.0-py3.12` | 2.9.0   | 13.0 | 3.12   |

## Quick Start

### Pull from Docker Hub

```bash
docker pull sky1218/pytorch:2.9.0-cuda13.0-py3.12
```

### Pull from GitHub Container Registry

```bash
docker pull ghcr.io/911218sky/pytorch:2.9.0-cuda13.0-py3.12
```

### Run with GPU Support

```bash
# From Docker Hub
docker run --gpus all -it sky1218/pytorch:2.9.0-cuda13.0-py3.12

# From GitHub Container Registry
docker run --gpus all -it ghcr.io/911218sky/pytorch:2.9.0-cuda13.0-py3.12

# Mount your code
docker run --gpus all -v $(pwd):/app -it sky1218/pytorch:2.9.0-cuda13.0-py3.12
```

## Trigger Builds

Use the trigger script to build images via GitHub Actions. All builds run in parallel.

### Prerequisites

1. Install [GitHub CLI](https://cli.github.com/)
2. Login: `gh auth login`

### Usage

```bash
# Build a single version
./trigger-build.sh 2.8.0-cuda12.8-py3.11

# Build multiple versions (runs in parallel)
./trigger-build.sh 2.8.0-cuda12.8-py3.11 2.7.1-cuda12.8-py3.12 2.9.0-cuda13.0-py3.11

# Build from JSON file
./trigger-build.sh -f versions.json

# Build all default versions
./trigger-build.sh

# Show help
./trigger-build.sh --help
```

### Version Format

```
TORCH_VERSION-cudaCUDA_VERSION-pyPYTHON_VERSION
```

Examples:

- `2.8.0-cuda12.8-py3.11`
- `2.9.0-cuda13.0-py3.12`

### Using versions.json

Create a `versions.json` file:

```json
[
  { "torch": "2.9.0", "cuda": "13.0", "python": "3.12" },
  { "torch": "2.8.0", "cuda": "12.8", "python": "3.11" }
]
```

Then run:

```bash
./trigger-build.sh -f versions.json
```

## Local Build

Build locally without GitHub Actions:

```bash
# Using build.sh
./build.sh sky1218/pytorch:2.9.0-cuda13.0-py3.12

# Using docker build directly
docker build \
  --build-arg PYTHON_VERSION=3.12 \
  --build-arg TORCH_VERSION=2.9.0 \
  --build-arg CUDA_VERSION=cu130 \
  -f Dockerfile.template \
  -t sky1218/pytorch:2.9.0-cuda13.0-py3.12 .
```

## GitHub Actions Setup

To use the automated build workflow, add these secrets to your repository:

| Secret               | Description              |
| -------------------- | ------------------------ |
| `DOCKERHUB_USERNAME` | Your Docker Hub username |
| `DOCKERHUB_TOKEN`    | Docker Hub access token  |

Generate a token at: https://hub.docker.com/settings/security

## Image Contents

Each image includes:

- Python (slim base)
- PyTorch + torchvision + torchaudio (with CUDA support)
- Common dependencies: git, curl, ffmpeg, image libraries

## Jetson Support (ARM64)

This project supports NVIDIA Jetson Orin devices with ARM64 architecture (JetPack 6.x).

### Build Method

PyTorch is **built from source** using scripts adapted from [dusty-nv/jetson-containers](https://github.com/dusty-nv/jetson-containers). This is necessary because:

- NVIDIA official Jetson PyTorch wheels only support Python 3.10
- Official wheels only go up to PyTorch 2.5

#### How the Build Works

```
┌─────────────────────────────────────────────────────────────────┐
│                    GitHub Actions Workflow                       │
├─────────────────────────────────────────────────────────────────┤
│  1. Setup QEMU for ARM64 emulation                              │
│  2. Pull nvcr.io/nvidia/l4t-base:r36.2.0 (includes CUDA)        │
│  3. Install Miniforge (provides Python 3.11/3.12 for ARM64)     │
│  4. Run build scripts (adapted from dusty-nv/jetson-containers):│
│     ├── scripts/pytorch/build.sh       (PyTorch from source)   │
│     ├── scripts/pytorch/build-torchvision.sh                   │
│     └── scripts/pytorch/build-torchaudio.sh                    │
│  5. Push to Docker Hub & GitHub Container Registry              │
└─────────────────────────────────────────────────────────────────┘
```

### Supported Configurations

| JetPack | L4T Version | CUDA | Ubuntu |
| ------- | ----------- | ---- | ------ |
| 6.0     | r36.2.0     | 12.2 | 22.04  |
| 6.1     | r36.4.0     | 12.6 | 22.04  |

### Available Jetson Images

| Tag                  | PyTorch | JetPack | Python |
| -------------------- | ------- | ------- | ------ |
| `2.7.1-jp6.0-py3.11` | 2.7.1   | 6.0     | 3.11   |
| `2.7.1-jp6.0-py3.12` | 2.7.1   | 6.0     | 3.12   |
| `2.8.0-jp6.0-py3.11` | 2.8.0   | 6.0     | 3.11   |
| `2.8.0-jp6.0-py3.12` | 2.8.0   | 6.0     | 3.12   |
| `2.9.0-jp6.0-py3.11` | 2.9.0   | 6.0     | 3.11   |
| `2.9.0-jp6.0-py3.12` | 2.9.0   | 6.0     | 3.12   |

### Pull Jetson Images

```bash
# From Docker Hub
docker pull sky1218/pytorch-jetson:2.7.0-jp6.0-py3.11

# From GitHub Container Registry
docker pull ghcr.io/911218sky/pytorch-jetson:2.7.0-jp6.0-py3.11
```

### Run on Jetson

```bash
# Run with GPU support on Jetson
docker run --runtime nvidia -it sky1218/pytorch-jetson:2.7.0-jp6.0-py3.11

# Mount your code
docker run --runtime nvidia -v $(pwd):/app -it sky1218/pytorch-jetson:2.7.0-jp6.0-py3.11
```

### Trigger Jetson Builds

```bash
# Build single version
./trigger-build-jetson.sh 2.7.0-jp6.0-py3.11

# Build multiple versions
./trigger-build-jetson.sh 2.7.0-jp6.0-py3.11 2.7.0-jp6.0-py3.12

# Build from JSON file
./trigger-build-jetson.sh -f versions-jetson.jsonc

# Build all default Jetson versions
./trigger-build-jetson.sh

# Show help
./trigger-build-jetson.sh --help
```

### Local Jetson Build

Build locally for Jetson (requires ARM64 or QEMU).

> ⚠️ **Note**: PyTorch is built **from source**. Build time: **2-4 hours** with QEMU emulation.

```bash
# Using docker buildx for cross-platform build
docker buildx build \
  --platform linux/arm64 \
  --build-arg L4T_VERSION=r36.2.0 \
  --build-arg TORCH_VERSION=2.7.0 \
  --build-arg PYTHON_VERSION=3.11 \
  --build-arg MAX_JOBS=2 \
  -f Dockerfile.jetson.template \
  -t sky1218/pytorch-jetson:2.7.0-jp6.0-py3.11 .
```

#### Build Arguments

| Argument         | Description                                 | Default   |
| ---------------- | ------------------------------------------- | --------- |
| `L4T_VERSION`    | L4T base image version                      | `r36.2.0` |
| `TORCH_VERSION`  | PyTorch version to build from source        | `2.7.0`   |
| `PYTHON_VERSION` | Python version (via Miniforge)              | `3.11`    |
| `MAX_JOBS`       | Parallel compile jobs (lower = less memory) | `4`       |

## Links

- Docker Hub (x86): https://hub.docker.com/r/sky1218/pytorch
- Docker Hub (Jetson): https://hub.docker.com/r/sky1218/pytorch-jetson
- GitHub: https://github.com/911218sky/pytorch-docker-build

## License

MIT
