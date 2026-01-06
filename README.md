# 🚀 PyTorch Docker Builder

[![Build Status](https://github.com/911218sky/pytorch-docker-build/actions/workflows/build-pytorch.yml/badge.svg)](https://github.com/911218sky/pytorch-docker-build/actions)
[![Docker Hub](https://img.shields.io/badge/Docker%20Hub-sky1218%2Fpytorch-blue)](https://hub.docker.com/r/sky1218/pytorch)

自動化 PyTorch Docker 映像建構工具，支援自訂 Python、PyTorch 和 CUDA 版本。

**特色功能：**

- ✅ 支援 **預編譯 wheel** 快速安裝
- ✅ 支援 **從源代碼編譯** (含 RTX 5090 SM 10.0)
- ✅ 支援 **CUDA 13.x** + Ubuntu 24.04
- ✅ 支援 **NVIDIA Jetson** ARM64 架構
- ✅ 自動上傳 wheel 到 GitHub Releases

---

## 📦 可用映像

### AMD64 (x86_64) - 桌面/伺服器

| 標籤                    | PyTorch | CUDA | Python | 備註          |
| ----------------------- | ------- | ---- | ------ | ------------- |
| `2.7.1-cuda12.8-py3.11` | 2.7.1   | 12.8 | 3.11   | 穩定版        |
| `2.7.1-cuda12.8-py3.12` | 2.7.1   | 12.8 | 3.12   | 穩定版        |
| `2.8.0-cuda12.8-py3.11` | 2.8.0   | 12.8 | 3.11   |               |
| `2.8.0-cuda12.8-py3.12` | 2.8.0   | 12.8 | 3.12   |               |
| `2.9.0-cuda12.8-py3.11` | 2.9.0   | 12.8 | 3.11   | 最新版        |
| `2.9.0-cuda12.8-py3.12` | 2.9.0   | 12.8 | 3.12   | 最新版        |
| `2.9.0-cuda13.0-py3.11` | 2.9.0   | 13.0 | 3.11   | RTX 5090 支援 |
| `2.9.0-cuda13.0-py3.12` | 2.9.0   | 13.0 | 3.12   | RTX 5090 支援 |

> 💡 `-source` 後綴的標籤表示從源代碼編譯

### ARM64 (Jetson) - 邊緣運算

| 標籤                 | PyTorch | JetPack | Python |
| -------------------- | ------- | ------- | ------ |
| `2.7.1-jp6.0-py3.11` | 2.7.1   | 6.0     | 3.11   |
| `2.7.1-jp6.0-py3.12` | 2.7.1   | 6.0     | 3.12   |
| `2.8.0-jp6.0-py3.11` | 2.8.0   | 6.0     | 3.11   |
| `2.9.0-jp6.0-py3.11` | 2.9.0   | 6.0     | 3.11   |

---

## ⚡ 快速開始

### 拉取映像

```bash
# Docker Hub
docker pull sky1218/pytorch:2.9.0-cuda12.8-py3.12

# GitHub Container Registry
docker pull ghcr.io/911218sky/pytorch:2.9.0-cuda12.8-py3.12
```

### 執行容器

```bash
# 啟用 GPU 支援
docker run --gpus all -it sky1218/pytorch:2.9.0-cuda12.8-py3.12

# 掛載程式碼
docker run --gpus all -v $(pwd):/app -it sky1218/pytorch:2.9.0-cuda12.8-py3.12

# 驗證 CUDA
docker run --gpus all sky1218/pytorch:2.9.0-cuda12.8-py3.12 python -c "import torch; print(f'CUDA: {torch.cuda.is_available()}')"
```

---

## 🔧 建構方式

### 方式 1：使用預編譯 wheel（推薦，快速）

直接從 PyTorch 官方下載預編譯的 wheel，通常在 5 分鐘內完成。

```bash
# 使用腳本觸發
./trigger-build.sh 2.9.0-cuda12.8-py3.12

# 或直接使用 GitHub CLI
gh workflow run build-pytorch.yml \
  -f 'versions=[{"torch":"2.9.0","cuda":"12.8","python":"3.12"}]' \
  -f build_from_source=false
```

### 方式 2：從源代碼編譯（自訂 CUDA 架構）

適用於需要特定 GPU 架構支援的情況，例如 RTX 5090 (SM 10.0)。

```bash
gh workflow run build-pytorch.yml \
  -f 'versions=[{"torch":"2.9.0","cuda":"13.0","python":"3.12"}]' \
  -f build_from_source=true \
  -f 'cuda_arch_list=8.0;8.6;8.9;9.0;10.0+PTX' \
  -f max_jobs=4
```

**參數說明：**

| 參數                | 說明             | 預設值                     |
| ------------------- | ---------------- | -------------------------- |
| `versions`          | 版本矩陣 JSON    | -                          |
| `build_from_source` | 是否從源代碼編譯 | `false`                    |
| `cuda_arch_list`    | CUDA 架構列表    | `8.0;8.6;8.9;9.0;10.0+PTX` |
| `max_jobs`          | 平行編譯任務數   | `4`                        |

**CUDA 架構對照表：**

| 架構 | GPU 系列             |
| ---- | -------------------- |
| 8.0  | A100                 |
| 8.6  | RTX 3090, A40        |
| 8.9  | RTX 4090, L40        |
| 9.0  | H100                 |
| 10.0 | RTX 5090 (Blackwell) |

---

## 📥 下載預編譯 Wheel

從源代碼編譯的 wheel 會自動上傳到 [GitHub Releases](https://github.com/911218sky/pytorch-docker-build/releases)。

```bash
# 下載範例
wget https://github.com/911218sky/pytorch-docker-build/releases/download/amd64-wheels-v2.9.0-cuda13.0/torch-2.9.0-cp312-cp312-linux_x86_64.whl

# 直接安裝
pip install https://github.com/911218sky/pytorch-docker-build/releases/download/amd64-wheels-v2.9.0-cuda13.0/torch-2.9.0-cp312-cp312-linux_x86_64.whl
```

---

## 🤖 Jetson 支援

### 拉取 Jetson 映像

```bash
docker pull sky1218/pytorch-jetson:2.7.1-jp6.0-py3.11
```

### 在 Jetson 上執行

```bash
docker run --runtime nvidia -it sky1218/pytorch-jetson:2.7.1-jp6.0-py3.11
```

### 觸發 Jetson 建構

```bash
./trigger-build-jetson.sh 2.7.1-jp6.0-py3.11
```

### 建構策略

Jetson 映像使用 2 層策略：

```
1. GitHub Releases  ──→  檢查已快取的 wheel（最快）
         │
         ↓ (找不到)
2. 從源代碼編譯    ──→  在 ARM64 runner 上編譯（2-4 小時）
         │
         ↓ (完成後)
3. 上傳 wheel      ──→  發布到 GitHub Releases 供下次使用
```

---

## 🏗️ 本地建構

### AMD64

```bash
docker build \
  --build-arg PYTHON_VERSION=3.12 \
  --build-arg TORCH_VERSION=2.9.0 \
  --build-arg CUDA_VERSION=cu130 \
  -f Dockerfile.template \
  -t my-pytorch:latest .
```

### 從源代碼編譯（本地）

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

### Jetson（需要 ARM64 或 QEMU）

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

## ⚙️ GitHub Actions 設定

在 Repository Settings → Secrets 中添加：

| Secret               | 說明                    |
| -------------------- | ----------------------- |
| `DOCKERHUB_USERNAME` | Docker Hub 帳號         |
| `DOCKERHUB_TOKEN`    | Docker Hub Access Token |

Token 申請：https://hub.docker.com/settings/security

---

## 📁 專案結構

```
.
├── .github/workflows/
│   ├── build-pytorch.yml      # AMD64 建構 workflow
│   └── build-jetson.yml       # Jetson 建構 workflow
├── scripts/pytorch/
│   ├── build-from-source.sh          # Jetson PyTorch 編譯
│   ├── build-from-source-amd64.sh    # AMD64 PyTorch 編譯
│   ├── build-torchvision.sh          # Jetson torchvision
│   ├── build-torchvision-amd64.sh    # AMD64 torchvision
│   ├── build-torchaudio.sh           # Jetson torchaudio
│   └── build-torchaudio-amd64.sh     # AMD64 torchaudio
├── Dockerfile.template               # 預編譯 wheel 安裝
├── Dockerfile.source.template        # 源代碼編譯
├── Dockerfile.jetson.template        # Jetson 專用
├── trigger-build.sh                  # AMD64 觸發腳本
└── trigger-build-jetson.sh           # Jetson 觸發腳本
```

---

## 🔗 連結

| 資源                      | 連結                                                       |
| ------------------------- | ---------------------------------------------------------- |
| Docker Hub (AMD64)        | https://hub.docker.com/r/sky1218/pytorch                   |
| Docker Hub (Jetson)       | https://hub.docker.com/r/sky1218/pytorch-jetson            |
| GitHub Releases           | https://github.com/911218sky/pytorch-docker-build/releases |
| GitHub Container Registry | https://ghcr.io/911218sky/pytorch                          |

---

## 📄 License

MIT License
