# ---------- Base Image ----------
FROM ubuntu:22.04

# Set noninteractive frontend
ENV DEBIAN_FRONTEND=noninteractive

# ---------- Install Core Build Tools ----------
RUN apt-get update && apt-get install -y \
    build-essential \
    cmake \
    git \
    pkg-config \
    wget \
    curl \
    unzip \
    ca-certificates \
    sudo \
    software-properties-common \
    && rm -rf /var/lib/apt/lists/*

# ---------- Install C++ / QT ----------
RUN apt-get update && apt-get install -y \
    qtbase5-dev \
    qttools5-dev \
    qttools5-dev-tools \
    libqt5serialport5-dev \
    && rm -rf /var/lib/apt/lists/*

# ---------- Core Libraries ----------
RUN apt-get update && apt-get install -y \
    libssl-dev \
    libturbojpeg0-dev \
    libzstd-dev \
    protobuf-compiler \
    libprotobuf-dev \
    zlib1g-dev \
    && rm -rf /var/lib/apt/lists/*

# ---------- Linux Grabbers & System ----------
RUN apt-get update && apt-get install -y \
    libsystemd-dev \
    libavahi-client-dev \
    libavahi-common-dev \
    libv4l-dev \
    libx11-dev \
    libpipewire-0.3-dev \
    libegl1-mesa-dev \
    libgl1-mesa-dev \
    && rm -rf /var/lib/apt/lists/*

# ---------- CEC Support ----------
RUN apt-get update && apt-get install -y \
    libcec-dev \
    libp8-platform-dev \
    && rm -rf /var/lib/apt/lists/*

# ---------- Optional Raspberry Pi Libraries ----------
# Only needed for RPi builds (WS281x, SPI, etc.)
# RUN apt-get update && apt-get install -y \
#     raspberrypi-kernel-headers \
#     libbcm2835-dev \
#     && rm -rf /var/lib/apt/lists/*

# ---------- Environment Variables ----------
ENV CC=gcc
ENV CXX=g++
ENV CMAKE_BUILD_TYPE=Release
ENV PATH="/usr/local/bin:${PATH}"

# ---------- Create HyperHDR Build Directory ----------
WORKDIR /hyperhdr
RUN mkdir -p /hyperhdr/build
WORKDIR /hyperhdr/build

# ---------- Build Steps (optional) ----------
# You can uncomment these lines if you want to auto-build inside Docker
# COPY . /hyperhdr
# RUN cmake .. \
#     -DUSE_CCACHE_CACHING=OFF \
#     -DENABLE_ZSTD=ON \
#     -DENABLE_BONJOUR=ON \
#     -DENABLE_PROTOBUF=ON \
#     -DENABLE_CEC=ON \
#     -DENABLE_X11=ON \
#     && make -j$(nproc)

# Default command
CMD ["/bin/bash"]
