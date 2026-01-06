# 🚀 PyTorch Docker Builder

[![Build Status](https://github.com/911218sky/pytorch-docker-build/actions/workflows/build-pytorch.yml/badge.svg)](https://github.com/911218sky/pytorch-docker-build/actions)
[![Docker Hub](https://img.shields.io/badge/Docker%20Hub-sky1218%2Fpytorch-blue)](https://hub.docker.com/r/sky1218/pytorch)

Automated PyTorch Docker image builder with customizable Python, PyTorch, and CUDA versions.

**Features:**

- ✅ **Pre-compiled wheel** installation (fast)
- ✅ **Build from source** (supports RTX 5090 SM 10.0)
- ✅ **CUDA 13.x** support with Ubuntu 24.04
- ✅ **NVIDIA Jetson** ARM64 support
- ✅ Auto-upload wheels to GitHub Releases

---

## 📦 Available Images

### AMD64 (x86_64) - Desktop/Server

| Tag                     | PyTorch | CUDA | Python | Notes    |
| ----------------------- | ------- | ---- | ------ | -------- |
| `2.7.1-cuda12.8-py3.11` | 2.7.1   | 12.8 | 3.11   | Stable   |
| `2.7.1-cuda12.8-py3.12` | 2.7.1   | 12.8 | 3.12   | Stable   |
| `2.8.0-cuda12.8-py3.11` | 2.8.0   | 12.8 | 3.11   |          |
| `2.8.0-cuda12.8-py3.12` | 2.8.0   | 12.8 | 3.12   |          |
| `2.9.0-cuda12.8-py3.11` | 2.9.0   | 12.8 | 3.11   | Latest   |
| `2.9.0-cuda12.8-py3.12` | 2.9.0   | 12.8 | 3.12   | Latest   |
| `2.9.0-cuda13.0-py3.11` | 2.9.0   | 13.0 | 3.11   | RTX 5090 |
| `2.9.0-cuda13.0-py3.12` | 2.9.0   | 13.0 | 3.12   | RTX 5090 |

> 💡 Tags with `-source` suffix are built from source code

### ARM64 (Jetson) - Edge Computing

| Tag                  | PyTorch | JetPack | Python |
| -------------------- | ------- | ------- | ------ |
| `2.7.1-jp6.0-py3.11` | 2.7.1   | 6.0     | 3.11   |
| `2.7.1-jp6.0-py3.12` | 2.7.1   | 6.0     | 3.12   |
| `2.8.0-jp6.0-py3.11` | 2.8.0   | 6.0     | 3.11   |
| `2.9.0-jp6.0-py3.11` | 2.9.0   | 6.0     | 3.11   |

---

## ⚡ Quick Start

### Pull Image

```bash
# Docker Hub
docker pull sky1218/pytorch:2.9.0-cuda12.8-py3.12

# GitHub Container Registry
docker pull ghcr.io/911218sky/pytorch:2.9.0-cuda12.8-py3.12
```

### Run Container

```bash
# Enable GPU support
docker run --gpus all -it sky1218/pytorch:2.9.0-cuda12.8-py3.12

# Mount your code
docker run --gpus all -v $(pwd):/app -it sky1218/pytorch:2.9.0-cuda12.8-py3.12

# Verify CUDA
docker run --gpus all sky1218/pytorch:2.9.0-cuda12.8-py3.12 python -c "import torch; print(f'CUDA: {torch.cuda.is_available()}')"
```

---

## 🔧 Build Methods

### Method 1: Pre-compiled Wheel (Recommended, Fast)

Downloads pre-compiled wheels from PyTorch official. Usually completes in ~5 minutes.

```bash
# Using trigger script
./trigger-build.sh 2.9.0-cuda12.8-py3.12

# Using GitHub CLI directly
gh workflow run build-pytorch.yml \
  -f 'versions=[{"torch":"2.9.0","cuda":"12.8","python":"3.12"}]' \
  -f build_from_source=false
```

### Method 2: Build from Source (Custom CUDA Architectures)

For specific GPU architecture support, e.g., RTX 5090 (SM 10.0).

```bash
gh workflow run build-pytorch.yml \
  -f 'versions=[{"torch":"2.9.0","cuda":"13.0","python":"3.12"}]' \
  -f build_from_source=true \
  -f 'cuda_arch_list=8.0;8.6;8.9;9.0;10.0+PTX' \
  -f max_jobs=4
```

**Parameters:**

| Parameter           | Description               | Default                    |
| ------------------- | ------------------------- | -------------------------- |
| `versions`          | Version matrix JSON       | -                          |
| `build_from_source` | Build from source code    | `false`                    |
| `cuda_arch_list`    | CUDA architecture list    | `8.0;8.6;8.9;9.0;10.0+PTX` |
| `max_jobs`          | Parallel compilation jobs | `4`                        |

**CUDA Architecture Reference:**

| SM   | GPU Series           |
| ---- | -------------------- |
| 8.0  | A100                 |
| 8.6  | RTX 3090, A40        |
| 8.9  | RTX 4090, L40        |
| 9.0  | H100                 |
| 10.0 | RTX 5090 (Blackwell) |

---

## 📥 Download Pre-built Wheels

Source-built wheels are automatically uploaded to [GitHub Releases](https://github.com/911218sky/pytorch-docker-build/releases).

```bash
# Direct install
pip install https://github.com/911218sky/pytorch-docker-build/releases/download/amd64-wheels-v2.9.0-cuda13.0/torch-2.9.0-cp312-cp312-linux_x86_64.whl
```

---

## 🤖 Jetson Support

### Pull Jetson Image

```bash
docker pull sky1218/pytorch-jetson:2.7.1-jp6.0-py3.11
```

### Run on Jetson

```bash
docker run --runtime nvidia -it sky1218/pytorch-jetson:2.7.1-jp6.0-py3.11
```

### Trigger Jetson Build

```bash
./trigger-build-jetson.sh 2.7.1-jp6.0-py3.11
```

### Build Strategy

Jetson images use a 2-tier strategy:

```
1. GitHub Releases  ──→  Check cached wheels (fastest)
         │
         ↓ (not found)
2. Build from source ──→  Compile on ARM64 runner (2-4 hours)
         │
         ↓ (complete)
3. Upload wheels     ──→  Publish to GitHub Releases for reuse
```

---

## 🏗️ Local Build

### AMD64 (Pre-compiled)

```bash
docker build \
  --build-arg PYTHON_VERSION=3.12 \
  --build-arg TORCH_VERSION=2.9.0 \
  --build-arg CUDA_VERSION=cu130 \
  -f Dockerfile.template \
  -t my-pytorch:latest .
```

### AMD64 (From Source)

```bash
docker build \
  --build-arg CUDA_BASE_VERSION=13.0.1 \
  --build-arg UBUNTU_VERSION=24.04 \
  --build-arg PYTHON_VERSION=3.12 \
  --build-arg TORCH_VERSION=2.9.0 \
  --build-arg CUDA_VERSION=13.0 \
  --build-arg MAX_JOBS=8 \
  --build-arg TORCH_CUDA_ARCH_LIST="8.9;9.0;10.0+PTX" \
  -f Dockerfile.source.template \
  -t my-pytorch:source .
```

### Jetson (Requires ARM64 or QEMU)

```bash
docker buildx build \
  --platform linux/arm64 \
  --build-arg L4T_VERSION=r36.2.0 \
  --build-arg TORCH_VERSION=2.7.1 \
  --build-arg PYTHON_VERSION=3.11 \
  --build-arg MAX_JOBS=2 \
  -f Dockerfile.jetson.template \
  -t my-pytorch-jetson:latest .
```

---

## ⚙️ GitHub Actions Setup

Add these secrets in Repository Settings → Secrets:

| Secret               | Description             |
| -------------------- | ----------------------- |
| `DOCKERHUB_USERNAME` | Docker Hub username     |
| `DOCKERHUB_TOKEN`    | Docker Hub Access Token |

Get token: https://hub.docker.com/settings/security

---

## 📄 License

This project is licensed under the **GNU General Public License v3.0** - see the [LICENSE](LICENSE) file for details.
