# syntax=docker/dockerfile:1

# Build CarlaSetup.Dockerfile before building this image
# docker build -t carla-20:latest -f Docker/CarlaEditor.Dockerfile .

FROM ubuntu:20.04 as build

ENV DEBIAN_FRONTEND=noninteractive

RUN rm -f /etc/apt/apt.conf.d/docker-clean;\
    echo 'Binary::apt::APT::Keep-Downloaded-Packages "true";' > /etc/apt/apt.conf.d/keep-cache

RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    apt-get update && \ 
    apt-get install wget software-properties-common -y && \
    add-apt-repository ppa:ubuntu-toolchain-r/test -y && \
    add-apt-repository ppa:deadsnakes/ppa -y && \
    wget -O - https://apt.llvm.org/llvm-snapshot.gpg.key|apt-key add - && \
    apt-add-repository "deb http://apt.llvm.org/focal/ llvm-toolchain-focal main" && \ 
    apt-get update -y

RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    apt update && \
    apt upgrade -y && \
    apt-get install -y --no-install-recommends \
        build-essential \
        clang-10 \
        lld-10 \
        g++-7 \
        cmake \
        ninja-build \
        libvulkan1 \
        python3.10 \
        python3-dev \
        python3-pip \
        libpng-dev \
        libtiff5-dev \
        libjpeg-dev \
        tzdata \
        sed \
        curl \
        unzip \
        autoconf \
        automake \
        libtool \
        rsync \
        libxml2-dev \
        git \
        aria2 

RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    pip3 install --upgrade pip

RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    pip3 install --user -Iv setuptools==47.3.1 && \
    pip3 install --user distro && \
    pip3 install --user wheel auditwheel

RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    add-apt-repository ppa:graphics-drivers/ppa \
    && apt update \
    && apt upgrade -y \
    && apt-get install -y --no-install-recommends \
        nvidia-driver-525 \
        xserver-xorg \
        mesa-utils

# Install packages required to avoid launch error "Error: FLinuxApplication::CreateLinuxApplication() : InitSDL() failed"
# cf. https://github.com/adamrehn/pixel-streaming-linux/issues/4
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    apt update && \
    apt-get install -y --no-install-recommends \
        x11-xserver-utils \ 
        libxrandr2 

RUN update-alternatives --install /usr/bin/clang clang /usr/lib/llvm-10/bin/clang 180
RUN update-alternatives --install /usr/bin/clang++ clang++ /usr/lib/llvm-10/bin/clang++ 180
RUN dpkg -l | grep python3.10 > /tmp/tmp2.txt && cat /tmp/tmp2.txt

RUN update-alternatives --install /usr/bin/python python /usr/bin/python3.10 180


ENV UE4_ROOT /home/UnrealEngine

RUN useradd --create-home --uid 1000 carla
USER carla
WORKDIR /home/carla/
CMD /bin/bash