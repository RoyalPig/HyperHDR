# Base image
FROM debian:stable-slim

# ----------------------------
# Environment variables
# ----------------------------
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ="America/Halifax"
ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8

# ----------------------------
# Install all dependencies
# ----------------------------
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    build-essential \
    cmake \
    git \
    libavcodec-dev \
    libavformat-dev \
    libavutil-dev \
    libswscale-dev \
    libudev-dev \
    libx11-dev \
    libxext-dev \
    libxrandr-dev \
    libv4l-dev \
    libusb-1.0-0-dev \
    pkg-config \
    curl \
    wget \
    ca-certificates \
    libssl-dev \
    qtbase5-dev \
    qttools5-dev \
    qttools5-dev-tools \
    libqt5core5a \
    libqt5gui5 \
    libqt5widgets5 \
    libqt5serialport5-dev \
    && rm -rf /var/lib/apt/lists/*

# ----------------------------
# Create non-root user
# ----------------------------
RUN useradd -m hyperhdr
WORKDIR /home/hyperhdr

# ----------------------------
# Copy HyperHDR source code into container
# ----------------------------
COPY . .

# ----------------------------
# Build HyperHDR from main folder
# ----------------------------
RUN mkdir build && cd build && \
    cmake .. -DCMAKE_BUILD_TYPE=Release && \
    make -j$(nproc)

# ----------------------------
# Expose HyperHDR ports
# ----------------------------
EXPOSE 8090 8092 19444 19445 19400

# ----------------------------
# Volume for persistent configuration
# ----------------------------
VOLUME ["/config"]

# ----------------------------
# Switch to non-root user
# ----------------------------
USER hyperhdr

# ----------------------------
# Start HyperHDR
# ----------------------------
CMD ["./build/hyperhdrd", "-p", "/config"]
