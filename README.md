# PyTorch Docker Builder

Automated Docker image builder for PyTorch with customizable Python, PyTorch, and CUDA versions.

## Available Images

| Tag | PyTorch | CUDA | Python |
|-----|---------|------|--------|
| `2.7.1-cuda12.8-py3.11` | 2.7.1 | 12.8 | 3.11 |
| `2.7.1-cuda12.8-py3.12` | 2.7.1 | 12.8 | 3.12 |
| `2.8.0-cuda12.8-py3.11` | 2.8.0 | 12.8 | 3.11 |
| `2.8.0-cuda12.8-py3.12` | 2.8.0 | 12.8 | 3.12 |
| `2.9.0-cuda12.8-py3.11` | 2.9.0 | 12.8 | 3.11 |
| `2.9.0-cuda12.8-py3.12` | 2.9.0 | 12.8 | 3.12 |
| `2.9.0-cuda13.0-py3.11` | 2.9.0 | 13.0 | 3.11 |
| `2.9.0-cuda13.0-py3.12` | 2.9.0 | 13.0 | 3.12 |

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
  {"torch": "2.9.0", "cuda": "13.0", "python": "3.12"},
  {"torch": "2.8.0", "cuda": "12.8", "python": "3.11"}
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

| Secret | Description |
|--------|-------------|
| `DOCKERHUB_USERNAME` | Your Docker Hub username |
| `DOCKERHUB_TOKEN` | Docker Hub access token |

Generate a token at: https://hub.docker.com/settings/security

## Image Contents

Each image includes:
- Python (slim base)
- PyTorch + torchvision + torchaudio (with CUDA support)
- Common dependencies: git, curl, ffmpeg, image libraries

## Links

- Docker Hub: https://hub.docker.com/r/sky1218/pytorch
- GitHub: https://github.com/911218sky/pytorch-docker-build

## License

MIT
