# syntax=docker/dockerfile:1
FROM --platform=linux/amd64 ubuntu:24.04@sha256:4fbb8e6a8395de5a7550b33509421a2bafbc0aab6c06ba2cef9ebffbc7092d90 AS trace-builder

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        gcc \
        libc6-dev \
    && rm -rf /var/lib/apt/lists/*

COPY bin/file-trace.c /tmp/file-trace.c
RUN gcc \
    -O2 \
    -Wall \
    -Wextra \
    -Werror \
    -fPIC \
    -shared \
    /tmp/file-trace.c \
    -ldl \
    -o /file-trace.so

FROM --platform=linux/amd64 ubuntu:24.04@sha256:4fbb8e6a8395de5a7550b33509421a2bafbc0aab6c06ba2cef9ebffbc7092d90

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        binutils \
        ca-certificates \
        coreutils \
        file \
        libfontconfig1 \
        libfreetype6 \
        libjpeg-turbo8 \
        libquadmath0 \
        libx11-6 \
        libxpm4 \
        libxt6t64 \
        zlib1g \
    && rm -rf /var/lib/apt/lists/*

COPY packages /tmp/legacy-packages
RUN cd /tmp/legacy-packages \
    && sha256sum -c SHA256SUMS \
    && mkdir -p /opt/oracle/root \
        /opt/oracle/gfortran-4.4 \
    && for package in ./*.deb; do \
        case "${package}" in \
            *libgfortran3_4.4.1-6*) \
                dpkg-deb --extract "${package}" /opt/oracle/gfortran-4.4 \
                ;; \
            *) \
                dpkg-deb --extract "${package}" /opt/oracle/root \
                ;; \
        esac; \
    done \
    && rm -rf /tmp/legacy-packages

ENV LD_LIBRARY_PATH=/opt/oracle/root/usr/lib:/opt/oracle/root/usr/lib/x86_64-linux-gnu:/opt/oracle/root/lib/x86_64-linux-gnu

# Recreate only the personal paths referenced by the preserved binaries.
RUN mkdir -p /home/arndt \
        /home/arndt64 \
        /home/mparis/SAID/said-current/said/pr \
    && ln -s /workspace/arndt64/sdat /home/arndt/sdat \
    && ln -s /workspace/arndt64/pr /home/arndt64/pr \
    && ln -s /workspace/arndt64/sdat /home/arndt64/sdat \
    && ln -s /workspace/arndt64/said /home/arndt64/said \
    && ln -s /workspace/arndt64/KN /home/arndt64/KN \
    && ln -s /workspace/arndt64/said/KCM.100330 \
        /home/mparis/SAID/said-current/said/pr/KCM \
    && ln -s /opt/oracle/root/usr/lib/x86_64-linux-gnu/libgd.so.2.0.0 \
        /opt/oracle/root/usr/lib/x86_64-linux-gnu/libgd.so.1

COPY bin/verify-oracle /usr/local/bin/verify-oracle
COPY --from=trace-builder /file-trace.so /opt/oracle/file-trace.so

WORKDIR /oracle-work
CMD ["sleep", "infinity"]
