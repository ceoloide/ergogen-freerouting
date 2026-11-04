# Best practices documented at https://snyk.io/blog/10-best-practices-to-containerize-nodejs-web-applications-with-docker/
ARG KICAD_VERSION=9
ARG FREEROUTING_SNAPSHOT_IMAGE="ghcr.io/freerouting/freerouting:nightly@sha256:b7c4223089549082ba1ff1588858665690e652e27b5d230ddc1548de7d77fb6d"
FROM ${FREEROUTING_SNAPSHOT_IMAGE} AS freerouting-snapshot
FROM ghcr.io/inti-cmnb/kicad${KICAD_VERSION}_auto:latest

ARG KICAD_VERSION=9
ARG ERGOGEN_VERSION=snapshot
ARG ERGOGEN_SNAPSHOT_URL=https://github.com/ceoloide/ergogen#v4.3.0
ARG FREEROUTING_VERSION=2.5.0
ARG FREEROUTING_SNAPSHOT_URL=""

LABEL org.opencontainers.image.description="Minimal Docker image with Ergogen (${ERGOGEN_VERSION}), Freerouting (${FREEROUTING_VERSION}), and KiCad ${KICAD_VERSION} with KiBot and other automation scripts" \
      org.opencontainers.image.authors="Marco Massarelli <marco.massarelli@gmail.com>"

# Install Node.js, npm, wget, and clean cache in a single layer
RUN apt-get update && \
    apt-get install -y --no-install-recommends nodejs npm wget && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Install Ergogen and clean npm cache
RUN if [ "${ERGOGEN_VERSION}" = "snapshot" ]; then \
      npm install -g "${ERGOGEN_SNAPSHOT_URL}"; \
    else \
      npm install -g ergogen@"${ERGOGEN_VERSION}"; \
    fi && \
    npm cache clean --force

# Download and install JDK 25, resolve dependencies, and remove installer
RUN wget -q https://download.oracle.com/java/25/latest/jdk-25_linux-x64_bin.deb && \
    apt-get update && \
    apt-get install -y --no-install-recommends ./jdk-25_linux-x64_bin.deb && \
    rm jdk-25_linux-x64_bin.deb && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Download or copy Freerouting Jar
RUN --mount=type=bind,from=freerouting-snapshot,source=/app/freerouting-executable.jar,target=/tmp/freerouting-snapshot.jar \
    if [ "${FREEROUTING_VERSION}" = "snapshot" ]; then \
      if [ -n "${FREEROUTING_SNAPSHOT_URL}" ]; then \
        wget -q "${FREEROUTING_SNAPSHOT_URL}" -O /opt/freerouting.jar; \
      else \
        cp /tmp/freerouting-snapshot.jar /opt/freerouting.jar && chmod 0644 /opt/freerouting.jar; \
      fi; \
    else \
      wget -q "https://github.com/freerouting/freerouting/releases/download/v${FREEROUTING_VERSION}/freerouting-${FREEROUTING_VERSION}.jar" -O /opt/freerouting.jar; \
    fi
