# Dockerfile for DMD Colab Pro custom container (Python 3.8, CUDA 11.3, PyTorch 1.10.1)
FROM nvidia/cuda:11.3.1-cudnn8-devel-ubuntu20.04

ENV DEBIAN_FRONTEND=noninteractive
SHELL ["/bin/bash", "-lc"]

# Basic OS deps
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential cmake git wget curl ca-certificates \
    python3.8 python3.8-dev python3-pip python3-distutils libsm6 libxext6 libxrender1 \
    pkg-config unzip && \
    rm -rf /var/lib/apt/lists/*

# Ensure python3 points to python3.8
RUN update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.8 1

# pip upgrade
RUN python3 -m pip install --upgrade pip setuptools wheel

# Install the exact torch & torchvision for CUDA 11.3
RUN pip install --no-cache-dir \
    "torch==1.10.1+cu113" "torchvision==0.11.2+cu113" -f https://download.pytorch.org/whl/torch_stable.html

# Install common python packages (match repo requirements)
RUN pip install --no-cache-dir numpy==1.24.4 scipy==1.10.1 scikit-learn==1.3.0 pillow==9.0.1 opencv-python-headless==4.6.0.66

# Install build deps for torch extension
RUN apt-get update && apt-get install -y --no-install-recommends gcc g++ python3-dev git \
    libopenblas-dev liblapack-dev && rm -rf /var/lib/apt/lists/*

# Install torch-linear-assignment (build from source to ensure CUDA extension compiled)
RUN git clone https://github.com/ivan-chai/torch-linear-assignment.git /opt/torch-linear-assignment && \
    cd /opt/torch-linear-assignment && \
    python3 -m pip install --no-cache-dir --no-build-isolation .

# Clone DMD repo and helper fptools (change branch/commit if needed)
RUN git clone --depth 1 https://github.com/Yu-Yy/DMD.git /opt/DMD && \
    git clone --depth 1 https://github.com/youngjetduan/fptools.git /opt/DMD/fptools

# Install any local project dependencies if the repo has setup.py (safe no-op otherwise)
WORKDIR /opt/DMD
RUN python3 -m pip install --no-cache-dir -e .

# Create logs folder
RUN mkdir -p /opt/DMD/logs

# Set environment
ENV PYTHONUNBUFFERED=1
ENV PYTHONDONTWRITEBYTECODE=1
ENV PATH="/opt/DMD:${PATH}"
WORKDIR /opt/DMD

# Default command: open a bash shell (Colab will provide a notebook runtime)
CMD ["/bin/bash"]
