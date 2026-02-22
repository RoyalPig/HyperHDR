# =========================
# Stage 1: Build HyperHDR
# =========================
FROM ubuntu:23.10 AS builder

# Install build dependencies
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    git cmake build-essential qtbase5-dev libqt5serialport5-dev libqt5sql5-sqlite libqt5svg5-dev \
    libqt5x11extras5-dev libusb-1.0-0-dev python3-minimal rpm libcec-dev \
    libxcb-image0-dev libxcb-util0-dev libxcb-shm0-dev libglvnd-dev libxcb-render0-dev \
    libxcb-randr0-dev libxrandr-dev libxrender-dev libavahi-core-dev libavahi-compat-libdnssd-dev \
    libjpeg-dev libturbojpeg0-dev libssl-dev zlib1g-dev ca-certificates curl wget dialog apt-utils \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Copy your forked HyperHDR source into container
COPY . /src
WORKDIR /src

# Build HyperHDR
RUN mkdir build && cd build && \
    cmake .. && \
    make -j$(nproc) && \
    make install

# =========================
# Stage 2: Minimal runtime
# =========================
FROM ubuntu:23.10

# Install runtime dependencies
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    qtbase5-dev libqt5serialport5-dev libqt5sql5-sqlite libqt5svg5-dev libqt5x11extras5-dev \
    libusb-1.0-0-dev libcec-dev libavahi-core-dev libavahi-compat-libdnssd-dev \
    libjpeg-dev libturbojpeg0-dev libssl-dev zlib1g-dev ca-certificates \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Copy HyperHDR binaries from build stage
COPY --from=builder /usr/local/bin/HyperHDR /usr/local/bin/HyperHDR
COPY --from=builder /usr/local/share/HyperHDR /usr/local/share/HyperHDR

# Set working directory for config volume
WORKDIR /config

# Expose ports for webUI + APIs
EXPOSE 8090 19444 19445

# Run HyperHDR
CMD ["HyperHDR"]
