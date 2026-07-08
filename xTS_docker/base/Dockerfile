FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    openjdk-17-jdk \
    python3 \
    python3-pip \
    usbutils \
    udev \
    curl \
    unzip \
    libstdc++6 \
    libc6 \
    libgcc1 \
    git-core \
    gnupg \
    flex \
    bison \
    build-essential \
    zip \
    curl \
    zlib1g-dev \
    x11proto-core-dev libx11-dev lib32z1-dev libgl1-mesa-dev \
    libxml2-utils xsltproc unzip fontconfig \
    libc6-dev-i386 \
    repo tree gitk vim \
    && rm -rf /var/lib/apt/lists/*

# Add etc files
COPY etc/ /opt/etc/

# Add other tools
RUN mkdir -p /opt/tools
COPY tools/ /opt/tools/
ENV PATH="/opt/tools/qdl:${PATH}"

# Add platform tools
RUN mkdir -p /opt/platform-tools
COPY platform-tools/ /opt/platform-tools/
RUN chmod +x /opt/platform-tools/bin/*

# Add scripts
COPY scripts/ /opt/scripts/
RUN chmod +x /opt/scripts/* || true

# Update Path
ENV PATH="/opt/platform-tools/bin:/opt/scripts:${PATH}"

WORKDIR /opt/workspace

CMD ["/bin/bash"]
