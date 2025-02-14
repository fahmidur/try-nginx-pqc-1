FROM ubuntu:24.04

RUN apt update -y
RUN apt install -y \
    openssl \
    libssl-dev \
    build-essential \
    cmake \
    ninja-build \
    git \
    nginx

RUN mkdir /opt/repos
WORKDIR /opt/repos
RUN git clone https://github.com/open-quantum-safe/oqs-provider.git
WORKDIR /opt/repos/oqs-provider
RUN scripts/fullbuild.sh
RUN cmake --install _build
RUN scripts/runtests.sh
RUN echo "--- runtests.sh COMPLETE ---"

RUN mkdir /opt/oqs-installer
WORKDIR /opt/oqs-installer
COPY ./openssl_cnf_append.txt .
RUN cat /etc/ssl/openssl.cnf ./openssl_cnf_append.txt > /etc/ssl/openssl.cnf


