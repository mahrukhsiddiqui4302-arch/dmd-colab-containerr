FROM nvidia/cuda:11.3.1-cudnn8-devel-ubuntu20.04

ENV DEBIAN_FRONTEND=noninteractive
SHELL ["/bin/bash", "-lc"]

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential cmake git wget curl ca-certificates \
    python3.8 python3.8-dev python3-pip python3-distutils libsm6 libxext6 libxrender1 \
    pkg-config unzip && \
    rm -rf /var/lib/apt/lists/*

RUN update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.8 1

RUN python3 -m pip install --upgrade pip setuptools wheel

RUN pip install --no-cache-dir \
    "torch==1.10.1+cu113" "torchvision==0.11.2+cu113" \
    -f https://download.pytorch.org/whl/torch_stable.html

RUN pip install --no-cache-dir numpy==1.24.4 scipy==1.10.1 scikit-learn==1.3.0 pillow==9.0.1 opencv-python-headless==4.6.0.66

RUN apt-get update && apt-get install -y --no-install-recommends gcc g++ python3-dev git \
    libopenblas-dev liblapack-dev && rm -rf /var/lib/apt/lists/*

## Clone DMD repo
RUN git clone --depth 1 https://github.com/Yu-Yy/DMD.git /opt/DMD && \
    git clone --depth 1 https://github.com/youngjetduan/fptools.git /opt/DMD/fptools

## Create logs folder
RUN mkdir -p /opt/DMD/logs

ENV PYTHONUNBUFFERED=1
ENV PYTHONDONTWRITEBYTECODE=1
ENV PATH="/opt/DMD:${PATH}"

WORKDIR /opt/DMD

CMD ["/bin/bash"]


