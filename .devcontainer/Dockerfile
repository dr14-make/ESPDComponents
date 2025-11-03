FROM ubuntu:24.04

# Avoid prompts from apt
ENV DEBIAN_FRONTEND=noninteractive

# Install basic utilities and git
RUN apt-get update && apt-get install -y \
    git \
    curl \
    wget \
    ca-certificates \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Install juliaup and Julia 1.11.7
RUN curl -fsSL https://install.julialang.org | sh -s -- --yes --default-channel 1.11.7

RUN curl -sSfL https://raw.githubusercontent.com/JuliaComputing/jh/main/install.sh | sh

# Add Julia to PATH
ENV PATH="/root/.juliaup/bin:/root/.local/bin:${PATH}"

# Verify installations
RUN git --version && julia --version

# Default command
CMD ["/bin/bash"]
