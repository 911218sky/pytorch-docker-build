#!/usr/bin/env python3

import sys
import traceback

def main():
    try:
        import torch
    except Exception as e:
        print("ERROR: failed to import torch:", e, file=sys.stderr)
        traceback.print_exc()
        return 2

    try:
        info = {}
        info["python_version"] = sys.version.split()[0]  # 只印簡短版本（例如 3.11.6）
        info["torch_version"] = getattr(torch, "__version__", "unknown")
        info["cuda_available"] = torch.cuda.is_available()

        # basic tensor ops (CPU)
        a = torch.randn(2, 3)
        b = torch.randn(3, 4)
        c = a @ b
        info["tensor_shape"] = list(c.shape)
        info["tensor_sum"] = float(c.sum().item())

        if info["tensor_shape"] != [2, 4]:
            print("ERROR: unexpected result shape:", info["tensor_shape"], file=sys.stderr)
            return 3

        # optional imports
        try:
            import torchvision
            info["torchvision_installed"] = True
            info["torchvision_version"] = getattr(torchvision, "__version__", "unknown")
        except Exception:
            info["torchvision_installed"] = False

        try:
            import torchaudio
            info["torchaudio_installed"] = True
            info["torchaudio_version"] = getattr(torchaudio, "__version__", "unknown")
        except Exception:
            info["torchaudio_installed"] = False

        # Summary output
        print("✅ PyTorch runtime test: SUCCESS")
        print("Python version:         ", info["python_version"])
        print("torch version:          ", info["torch_version"])
        print("cuda available:         ", info["cuda_available"])
        print("result tensor shape:    ", info["tensor_shape"])
        print("result tensor sum:      ", info["tensor_sum"])
        print("torchvision installed:  ", info["torchvision_installed"])
        print("torchaudio installed:   ", info["torchaudio_installed"])

        return 0

    except Exception as e:
        print("ERROR during runtime test:", e, file=sys.stderr)
        traceback.print_exc()
        return 4

if __name__ == "__main__":
    sys.exit(main())