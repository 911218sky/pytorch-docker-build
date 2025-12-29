# PyTorch Docker Builder

Automated Docker image builder for PyTorch with customizable Python, PyTorch, and CUDA versions. Images are pushed to [sky1218/pytorch](https://hub.docker.com/r/sky1218/pytorch).

## Available Images

| Tag | PyTorch | CUDA | Python |
|-----|---------|------|--------|
| `2.8.0-cuda12.9-py3.12` | 2.8.0 | 12.9 | 3.12 |
| `2.8.0-cuda12.9-py3.11` | 2.8.0 | 12.9 | 3.11 |
| `2.7.1-cuda12.8-py3.12` | 2.7.1 | 12.8 | 3.12 |
| `2.6.0-cuda12.6-py3.11` | 2.6.0 | 12.6 | 3.11 |
| `2.5.1-cuda12.4-py3.11` | 2.5.1 | 12.4 | 3.11 |

## Quick Start

```bash
# Pull an image
docker pull sky1218/pytorch:2.8.0-cuda12.9-py3.11

# Run with GPU support
docker run --gpus all -it sky1218/pytorch:2.8.0-cuda12.9-py3.11

# Mount your code
docker run --gpus all -v $(pwd):/app -it sky1218/pytorch:2.8.0-cuda12.9-py3.11
```

## Trigger Builds

Use the trigger script to build images via GitHub Actions. All builds run in parallel.

### Prerequisites

1. Install [GitHub CLI](https://cli.github.com/)
2. Login: `gh auth login`

### Usage

```bash
# Build a single version
./trigger-build.sh 2.8.0-cuda12.9-py3.11

# Build multiple versions (runs in parallel)
./trigger-build.sh 2.8.0-cuda12.9-py3.11 2.7.1-cuda12.8-py3.12 2.5.1-cuda12.4-py3.11

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
- `2.8.0-cuda12.9-py3.11`
- `2.5.1-cuda12.4-py3.12`

### Using versions.json

Create a `versions.json` file:

```json
[
  {"torch": "2.8.0", "cuda": "12.9", "python": "3.12"},
  {"torch": "2.8.0", "cuda": "12.9", "python": "3.11"},
  {"torch": "2.7.1", "cuda": "12.8", "python": "3.12"}
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
./build.sh sky1218/pytorch:2.8.0-cuda12.9-py3.11

# Using docker build directly
docker build \
  --build-arg PYTHON_VERSION=3.11 \
  --build-arg TORCH_VERSION=2.8.0 \
  --build-arg CUDA_VERSION=cu129 \
  -f Dockerfile.template \
  -t sky1218/pytorch:2.8.0-cuda12.9-py3.11 .
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
- PyTorch + torchvision (with CUDA support)
- Common dependencies: git, curl, ffmpeg, image libraries

## License

MIT
