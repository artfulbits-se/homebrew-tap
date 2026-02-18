# Pre-warmed Homebrew image for e-bash formula testing
# Build: docker build -t e-bash-test .
# Run:   docker run --rm -v $(pwd)/Formula:/formula:ro e-bash-test

FROM homebrew/brew:latest

USER root

# Pre-install common dependencies to speed up testing
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

USER linuxbrew

# Pre-update Homebrew and install common e-bash dependencies
RUN brew update && \
    brew install bash coreutils git jq && \
    brew cleanup

# Set environment for faster runs
ENV HOMEBREW_NO_AUTO_UPDATE=1
ENV HOMEBREW_NO_ENV_HINTS=1

WORKDIR /home/linuxbrew

# Default command runs style check
CMD ["brew", "style", "/formula/e-bash.rb", "/formula/e-bash-night.rb"]
