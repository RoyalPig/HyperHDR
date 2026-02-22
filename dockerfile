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
# Install dependencies
# ----------------------------
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    cmake \
    g++ \
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
    qt5-default \
    qtbase5-dev \
    libqt5core5a \
    libqt5gui5 \
    libqt5widgets5 \
    && rm -rf /var/lib/apt/lists/*

# ----------------------------
# Create non-root user
# ----------------------------
RUN useradd -m hyperhdr
WORKDIR /home/hyperhdr

# ----------------------------
# Copy HyperHDR source code into the container
# ----------------------------
COPY . .

# ----------------------------
# Build HyperHDR from main folder
# ----------------------------
RUN mkdir build && cd build && \
    cmake .. -DCMAKE_BUILD_TYPE=Release && \
    make -j$(nproc)

# ----------------------------
# Expose ports used by HyperHDR
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
