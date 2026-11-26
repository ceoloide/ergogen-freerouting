# Best practices documented at https://snyk.io/blog/10-best-practices-to-containerize-nodejs-web-applications-with-docker/
ARG KICAD_VERSION=9
ARG KICAD_BASE_TAG=latest
# Only FREEROUTING_VERSION=snapshot builds read this image; stable builds use an
# empty stage so they never depend on a nightly that may be deleted.
ARG FREEROUTING_SNAPSHOT_IMAGE=scratch
FROM ${FREEROUTING_SNAPSHOT_IMAGE} AS freerouting-snapshot
FROM ghcr.io/inti-cmnb/kicad${KICAD_VERSION}_auto:${KICAD_BASE_TAG}

ARG KICAD_VERSION=9
ARG ERGOGEN_VERSION=snapshot
ARG ERGOGEN_SNAPSHOT_URL=https://github.com/ceoloide/ergogen#568d7ae684ca914f8d200dd773b7fc26373a546e
ARG FREEROUTING_VERSION=2.6.0
ARG FREEROUTING_SNAPSHOT_URL=""

LABEL org.opencontainers.image.description="Minimal Docker image with Ergogen (${ERGOGEN_VERSION}), Freerouting (${FREEROUTING_VERSION}), and KiCad ${KICAD_VERSION} with KiBot and other automation scripts" \
      org.opencontainers.image.authors="Marco Massarelli <marco.massarelli@gmail.com>"

# Install wget and git (for snapshot installs), and clean cache in a single layer
RUN apt-get update && \
    apt-get install -y --no-install-recommends ca-certificates git wget xz-utils && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Install Node.js from the official release tarball (Ergogen 4.3.0+ requires
# Node 24, newer than what Debian ships) after verifying its checksum
ARG NODE_VERSION=24.22.3
RUN cd /tmp && \
    wget -q "https://nodejs.org/dist/v${NODE_VERSION}/node-v${NODE_VERSION}-linux-x64.tar.xz" && \
    wget -q "https://nodejs.org/dist/v${NODE_VERSION}/SHASUMS256.txt" && \
    grep " node-v${NODE_VERSION}-linux-x64.tar.xz\$" SHASUMS256.txt | sha256sum -c - && \
    tar -xJf "node-v${NODE_VERSION}-linux-x64.tar.xz" -C /usr/local --strip-components=1 \
      --exclude=CHANGELOG.md --exclude=LICENSE --exclude=README.md && \
    rm "node-v${NODE_VERSION}-linux-x64.tar.xz" SHASUMS256.txt && \
    node --version && npm --version

# Install Ergogen and clean npm cache. Snapshots are packed first: a global
# install straight from git fails while npm prepares the git dependency.
RUN if [ "${ERGOGEN_VERSION}" = "snapshot" ]; then \
      cd /tmp && \
      tarball="$(npm pack --silent "${ERGOGEN_SNAPSHOT_URL}" | tail -n 1)" && \
      npm install -g --no-fund --no-audit "/tmp/${tarball}" && \
      rm "/tmp/${tarball}"; \
    else \
      npm install -g --no-fund --no-audit ergogen@"${ERGOGEN_VERSION}"; \
    fi && \
    npm cache clean --force && \
    ergogen --version

# Download and install JDK 25, resolve dependencies, and remove installer
RUN wget -q https://download.oracle.com/java/25/latest/jdk-25_linux-x64_bin.deb && \
    apt-get update && \
    apt-get install -y --no-install-recommends ./jdk-25_linux-x64_bin.deb && \
    rm jdk-25_linux-x64_bin.deb && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Download or copy Freerouting Jar
RUN --mount=type=bind,from=freerouting-snapshot,target=/tmp/freerouting-snapshot \
    if [ "${FREEROUTING_VERSION}" = "snapshot" ]; then \
      if [ -n "${FREEROUTING_SNAPSHOT_URL}" ]; then \
        wget -q "${FREEROUTING_SNAPSHOT_URL}" -O /opt/freerouting.jar; \
      elif [ -f /tmp/freerouting-snapshot/app/freerouting-executable.jar ]; then \
        cp /tmp/freerouting-snapshot/app/freerouting-executable.jar /opt/freerouting.jar && chmod 0644 /opt/freerouting.jar; \
      else \
        echo "Set FREEROUTING_SNAPSHOT_IMAGE or FREEROUTING_SNAPSHOT_URL for snapshot builds" >&2; exit 1; \
      fi; \
    else \
      wget -q "https://github.com/freerouting/freerouting/releases/download/v${FREEROUTING_VERSION}/freerouting-${FREEROUTING_VERSION}.jar" -O /opt/freerouting.jar; \
    fi
