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

# Add Julia to PATH
ENV PATH="/root/.juliaup/bin:${PATH}"

# Verify installations
RUN git --version && julia --version

# Set working directory
WORKDIR /workspace


# Default command
CMD ["/bin/bash"]
