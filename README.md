## 🚀 Quick Start

### 1. Give permission to scripts:
```bash
chmod +x build.sh test.sh
````

### 2. Build Docker image

#### Single-platform (default: `linux/amd64`)

```bash
./build.sh myuser/pytorch:local
```

#### Multi-platform (must push to registry):

```bash
./build.sh myuser/pytorch:local linux/amd64,linux/arm64
```

---

## ✅ Test the image

### Run test locally (uses host Python):

```bash
./test.sh
```

### Run test in Docker image:

```bash
./test.sh myuser/pytorch:local
```

---

## 🧪 What `test.py` does

* Checks `import torch`
* Verifies `torch.cuda.is_available()`
* Runs basic tensor ops (e.g., matrix multiply)
* Checks for `torchvision` / `torchaudio` if available
* Prints versions and test results
* Returns exit code `0` on success, `>0` on failure

---


## 📦 Example

```bash
# Build for amd64
./build.sh pytorch:local linux/amd64

# Run test inside image
./test.sh pytorch:local
```