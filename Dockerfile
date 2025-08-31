FROM python:3.11.13-slim

# non-interactive
ENV DEBIAN_FRONTEND=noninteractive \
    PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

# install deps, pip, torch and cleanup in one RUN to reduce image size
RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
        build-essential \
        git \
        curl \
        ca-certificates \
        pkg-config \
        libjpeg-dev \
        zlib1g-dev \
        libpng-dev \
        libsndfile1 \
        ffmpeg; \
    \
    python -m pip install --upgrade pip setuptools wheel; \
    python -m pip install --no-cache-dir \
      torch torchvision --index-url https://download.pytorch.org/whl/cu129; \
    \
    apt-get purge -y --auto-remove build-essential pkg-config; \
    apt-get clean; \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /root/.cache/pip

WORKDIR /app