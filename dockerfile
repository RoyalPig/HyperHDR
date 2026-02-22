# =========================
# Stage 1: Build HyperHDR
# =========================
FROM ubuntu:22.04 AS builder

# Avoid interactive prompts
ENV DEBIAN_FRONTEND=noninteractive

# Install build dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    git cmake build-essential qtbase5-dev libqt5serialport5-dev libqt5sql5-sqlite \
    libqt5svg5-dev libqt5x11extras5-dev libusb-1.0-0-dev python3-minimal rpm libcec-dev \
    libxcb-image0-dev libxcb-util0-dev libxcb-shm0-dev libglvnd-dev libxcb-render0-dev \
    libxcb-randr0-dev libxrandr-dev libxrender-dev libavahi-core-dev libavahi-compat-libdnssd-dev \
    libjpeg-dev libturbojpeg0-dev libssl-dev zlib1g-dev ca-certificates curl wget dialog apt-utils \
    libasound2-dev libflatbuffers-dev libzstd-dev

# Set working directory
WORKDIR /src

# Copy your HyperHDR fork into the container
COPY . .

# Initialize git submodules (important!)
RUN git submodule update --init --recursive

# Build HyperHDR
RUN mkdir build && cd build && \
    cmake .. \
      -DUSE_SYSTEM_FLATBUFFERS_LIBS=ON \
      -DUSE_SYSTEM_ZSTD_LIBS=ON && \
    make -j$(nproc) && \
    make install

# =========================
# Stage 2: Runtime image
# =========================
FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# Install runtime dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    qtbase5-dev libqt5serialport5-dev libqt5sql5-sqlite libqt5svg5-dev \
    libqt5x11extras5-dev libusb-1.0-0-dev libcec-dev \
    libavahi-core-dev libavahi-compat-libdnssd-dev \
    libjpeg-dev libturbojpeg0-dev libssl-dev zlib1g-dev \
    libasound2-dev ca-certificates \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Copy HyperHDR binaries and shared files from build stage
COPY --from=builder /usr/local/bin/HyperHDR /usr/local/bin/HyperHDR
COPY --from=builder /usr/local/share/HyperHDR /usr/local/share/HyperHDR

# Set working directory for config / volume mapping
WORKDIR /config

# Expose ports
EXPOSE 8090 19444 19445

# Default command
CMD ["HyperHDR"]
