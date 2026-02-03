# ----------------------------
# Stage 1: Build libzip from source
# ----------------------------
FROM ubuntu:24.04 AS libzip-build

RUN apt-get update && apt-get install -y \
  build-essential \
  cmake \
  git \
  pkg-config \
  zlib1g-dev \
  && rm -rf /var/lib/apt/lists/*

WORKDIR /opt

RUN git clone --depth 1 https://github.com/nih-at/libzip.git
WORKDIR /opt/libzip

RUN mkdir build && cd build && \
    cmake .. -DCMAKE_BUILD_TYPE=Release -DBUILD_SHARED_LIBS=ON && \
    make -j$(nproc) && \
    make install


# ----------------------------
# Stage 2: Build mGBA from source
# ----------------------------
FROM ubuntu:24.04 AS builder

ARG MGBA_VERSION=0.10.5

RUN apt-get update && apt-get install -y \
  git \
  build-essential \
  cmake \
  pkg-config \
  libgtk-3-dev \
  libqt5svg5-dev \
  libqt5opengl5-dev \
  libgl1-mesa-dev \
  libsdl2-dev \
  libepoxy-dev \
  libpng-dev \
  libavcodec-dev \
  libavformat-dev \
  libavutil-dev \
  libswscale-dev \
  libedit-dev \
  zlib1g-dev \
  && rm -rf /var/lib/apt/lists/*

COPY --from=libzip-build /usr/local /usr/local

WORKDIR /opt
RUN git clone --branch ${MGBA_VERSION} --depth 1 https://github.com/mgba-emu/mgba.git
WORKDIR /opt/mgba

RUN mkdir build && cd build && \
    cmake .. && \
    make -j$(nproc) && \
    make install


# ----------------------------
# Stage 3: Runtime image
# ----------------------------
FROM ubuntu:24.04

RUN apt-get update && apt-get install -y \
  libqt5widgets5 \
  libqt5opengl5 \
  libsdl2-2.0-0 \
  libepoxy0 \
  libpng16-16 \
  libavcodec60 \
  libavformat60 \
  libavutil58 \
  libedit2 \
  ca-certificates \
  zlib1g \
  ffmpeg \
  && rm -rf /var/lib/apt/lists/*

COPY --from=builder /usr/local/bin/mgba /usr/local/bin/
COPY --from=builder /usr/local/bin/mgba-qt /usr/local/bin/
COPY --from=builder /usr/local/lib /usr/local/lib

RUN ldconfig

ENTRYPOINT ["mgba-qt"]
