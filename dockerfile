# ----------------------------
# Stage 1: Build HyperHDR
# ----------------------------
FROM ubuntu:22.04 AS builder

# Prevent interactive prompts
ENV DEBIAN_FRONTEND=noninteractive

# Install build dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    git cmake build-essential libasound2-dev \
    qtbase5-dev libqt5serialport5-dev libqt5sql5-sqlite libqt5svg5-dev libqt5x11extras5-dev \
    libusb-1.0-0-dev libcec-dev libavahi-core-dev libavahi-compat-libdnssd-dev \
    libjpeg-dev libturbojpeg0-dev libssl-dev zlib1g-dev ca-certificates curl wget dialog \
    libxcb-image0-dev libxcb-util0-dev libxcb-shm0-dev libglvnd-dev libxcb-render0-dev \
    libxcb-randr0-dev libxrandr-dev libxrender-dev python3-minimal rpm \
    flatbuffers-compiler libflatbuffers-dev \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Clone your fork and init submodules
WORKDIR /src
RUN git clone --recursive https://github.com/RoyalPig/HyperHDR.git .
RUN git submodule update --init --recursive

# Create build directory
RUN mkdir build
WORKDIR /src/build

# Build HyperHDR
RUN cmake .. -DCMAKE_INSTALL_PREFIX=/opt/hyperhdr \
    -DUSE_SYSTEM_FLATBUFFERS_LIBS=ON \
    -DUSE_SYSTEM_LUNASVG_LIBS=OFF \
    -DUSE_SYSTEM_NANOPB_LIBS=OFF \
    -DUSE_SYSTEM_STB_LIBS=OFF \
    -DENABLE_WS281XPWM=OFF \
    -DENABLE_SOUNDCAPWINDOWS=OFF \
    -DENABLE_SOUNDCAPMACOS=OFF
RUN make -j$(nproc)
RUN make install

# ----------------------------
# Stage 2: Runtime image
# ----------------------------
FROM ubuntu:22.04

# Install runtime dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    libasound2 libqt5core5a libqt5gui5 libqt5widgets5 libqt5serialport5 \
    libqt5sql5-sqlite libqt5svg5 libqt5x11extras5 libusb-1.0-0 libavahi-core7 \
    libavahi-compat-libdnssd1 libjpeg-turbo8 libturbojpeg0-dev zlib1g ca-certificates \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Copy HyperHDR from build stage
COPY --from=builder /opt/hyperhdr /opt/hyperhdr

# Add to PATH
ENV PATH="/opt/hyperhdr/bin:${PATH}"

# Expose ports
EXPOSE 8090 19444 19445

# Config volume
VOLUME ["/config"]

# Run HyperHDR in foreground
CMD ["HyperHDR", "--no-daemon"]
