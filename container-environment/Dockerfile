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

# Compatibility alias for the archived KN/INPUT deck, which repoints unit
# 11 to /home/arndt64/KN/KNSOL.USR as interactive input. SAIDOPEN applies
# SAID_DATA_ROOT to its FIL() table during initialization, before the deck
# override is read, so the portable-data-root patch cannot intercept this
# path. The archived deck is reference evidence and is not modified.
RUN mkdir -p /home/arndt64 \
    && ln -s /workspace/arndt64/KN /home/arndt64/KN

COPY bin/bootstrap-repos /usr/local/bin/bootstrap-repos
COPY bin/verify-environment /usr/local/bin/verify-environment

WORKDIR /workspace
CMD ["sleep", "infinity"]
