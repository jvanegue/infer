FROM ubuntu:22.04

LABEL maintainer "Infer team"

#ENV HTTP_PROXY "http://proxy:port"
#ENV HTTPS_PROXY "http://proxy.:port"
#RUN export http_proxy=$HTTP_PROXY
#RUN export https_proxy=$HTTP_PROXY

# mkdir the man/man1 directory due to Debian bug #863199
RUN apt-get update

RUN mkdir -p /usr/share/man/man1 && \
    apt-get install --yes --no-install-recommends \
      curl \
      libc6-dev \
      openjdk-11-jdk-headless \
      sqlite3 \
      xz-utils \
      zlib1g-dev && \
    rm -rf /var/lib/apt/lists/*

# Download the Infer release
RUN INFER_VERSION=v1.1.0; \
    cd /opt && \
    curl -sL \
      https://github.com/facebook/infer/releases/download/${INFER_VERSION}/infer-linux64-${INFER_VERSION}.tar.xz | \
    tar xJ && \
    rm -f /infer && \
    ln -s ${PWD}/infer-linux64-$INFER_VERSION /infer

# Install infer
ENV PATH /infer/bin:${PATH}
