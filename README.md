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

### JetPack 6.0 Specifications

- **L4T Version**: R36.2.0
- **Ubuntu**: 22.04
- **CUDA**: 12.2 (bundled with L4T base image)
- **Python**: Via Miniforge (prebuilt ARM64)
- **PyTorch**: Official ARM64 prebuilt wheels

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
docker pull sky1218/pytorch-jetson:2.9.0-jp6.0-py3.12

# From GitHub Container Registry
docker pull ghcr.io/911218sky/pytorch-jetson:2.9.0-jp6.0-py3.12
```

### Run on Jetson

```bash
# Run with GPU support on Jetson
docker run --runtime nvidia -it sky1218/pytorch-jetson:2.9.0-jp6.0-py3.12

# Mount your code
docker run --runtime nvidia -v $(pwd):/app -it sky1218/pytorch-jetson:2.9.0-jp6.0-py3.12
```

### Trigger Jetson Builds

```bash
# Build single version
./trigger-build-jetson.sh 2.9.0-jp6.0-py3.12

# Build multiple versions
./trigger-build-jetson.sh 2.9.0-jp6.0-py3.11 2.8.0-jp6.0-py3.12

# Build from JSON file
./trigger-build-jetson.sh -f versions-jetson.jsonc

# Build all default Jetson versions
./trigger-build-jetson.sh

# Show help
./trigger-build-jetson.sh --help
```

### Local Jetson Build

Build locally for Jetson (requires ARM64 or QEMU).

```bash
# Using docker buildx for cross-platform build
docker buildx build \
  --platform linux/arm64 \
  --build-arg L4T_VERSION=r36.2.0 \
  --build-arg TORCH_VERSION=2.9.0 \
  --build-arg PYTHON_VERSION=3.12 \
  -f Dockerfile.jetson.template \
  -t sky1218/pytorch-jetson:2.9.0-jp6.0-py3.12 .
```

#### Build Arguments

| Argument         | Description            | Default   |
| ---------------- | ---------------------- | --------- |
| `L4T_VERSION`    | L4T base image version | `r36.2.0` |
| `TORCH_VERSION`  | PyTorch version        | `2.9.0`   |
| `PYTHON_VERSION` | Python version         | `3.11`    |

## Links

- Docker Hub (x86): https://hub.docker.com/r/sky1218/pytorch
- Docker Hub (Jetson): https://hub.docker.com/r/sky1218/pytorch-jetson
- GitHub: https://github.com/911218sky/pytorch-docker-build

## License

MIT
