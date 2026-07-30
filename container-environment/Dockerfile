# syntax=docker/dockerfile:1
FROM --platform=linux/amd64 ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        binutils \
        build-essential \
        ca-certificates \
        file \
        gdb \
        gfortran \
        git \
        libgd-dev \
        libjpeg-dev \
        libpng-dev \
        libx11-dev \
        libxt-dev \
        make \
        perl \
        pkg-config \
        strace \
        tcsh \
        zlib1g-dev \
    && rm -rf /var/lib/apt/lists/*

COPY bin/bootstrap-repos /usr/local/bin/bootstrap-repos
COPY bin/verify-environment /usr/local/bin/verify-environment

WORKDIR /workspace
CMD ["sleep", "infinity"]
