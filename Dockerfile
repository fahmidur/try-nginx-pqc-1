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
COPY ./assert-oqsprovider-active.pl .
RUN cp /etc/ssl/openssl.cnf /etc/ssl/openssl.cnf.1.bak
RUN cat /etc/ssl/openssl.cnf.1.bak ./openssl_cnf_append.txt > /etc/ssl/openssl.cnf
RUN openssl list -providers | ./assert-oqsprovider-active.pl

# Create a self-signed cert
RUN mkdir /opt/certs
WORKDIR /opt/certs
RUN openssl req -x509 -nodes \
  -days 365 \
  -newkey rsa:2048 \
  -keyout /opt/certs/pqc.key \
  -out /opt/certs/pqc.crt \
  -subj "/C=US/ST=California/L=Los Angeles/O=Example/OU=IT/CN=echo-pqc-1.lvh.me"

RUN apt install -y \
  curl \
  wget \
  vim-tiny

WORKDIR /etc/nginx/sites-enabled
RUN rm default
COPY ./echo-pqc-1.nginx .

CMD ["nginx", "-g", "daemon off;"]


# CMD ["nginx"]


