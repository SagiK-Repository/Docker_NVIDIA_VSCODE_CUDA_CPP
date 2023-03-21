# Base image
FROM nvidia/cuda:11.4.1-devel-ubuntu20.04

# Set working directory
WORKDIR /workspace

# Install necessary packages
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
    build-essential \
    curl \
    git \
    wget \
    vim \
    && \
    rm -rf /var/lib/apt/lists/*

# Install VSCode
RUN curl -fsSL https://code-server.dev/install.sh | sh

# Install Remote Development extension
RUN /usr/bin/code-server --install-extension ms-vscode-remote.vscode-remote-extensionpack

# Set environment variables
ENV PATH="/usr/local/cuda-11.4/bin:${PATH}"
ENV LD_LIBRARY_PATH="/usr/local/cuda-11.4/lib64:${LD_LIBRARY_PATH}"

# Set the root password for VSCode
RUN echo "root:root" | chpasswd && \
    sed -i 's|password:.*|password: root|g' ~/.config/code-server/config.yaml

# Expose code-server port
EXPOSE 8080

# Start code-server
CMD ["code-server", "--bind-addr", "0.0.0.0:8080", "."]
