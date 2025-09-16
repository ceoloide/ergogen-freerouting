# Best practices documented at https://snyk.io/blog/10-best-practices-to-containerize-nodejs-web-applications-with-docker/
ARG kicad_ver=8
FROM ghcr.io/inti-cmnb/kicad${kicad_ver}_auto:latest
LABEL Description="Minimal Docker image with Ergogen, Freerouting (2.1.0), and KiCad ${kicad_ver} with KiBot and other automation scripts" \
      Author="Marco Massarelli <marco.massarelli@gmail.com>"

ARG ERGOGEN_VERSION=snapshot
ARG ERGOGEN_SNAPSHOT_URL=https://github.com/ergogen/ergogen#develop
ARG FREEROUTING_VERSION=2.1.0
ARG FREEROUTING_SNAPSHOT_URL=""

RUN apt-get update && apt-get upgrade -y
RUN apt-get install -y --no-install-recommends nodejs npm wget curl
RUN if [ "${ERGOGEN_VERSION}" = "snapshot" ]; then \
  npm install -g ${ERGOGEN_SNAPSHOT_URL}; \
  else \
  npm install -g ergogen@${ERGOGEN_VERSION}; \
  fi

RUN wget https://download.oracle.com/java/21/latest/jdk-21_linux-x64_bin.deb && \
  dpkg -i jdk-21_linux-x64_bin.deb
RUN if [ "${FREEROUTING_VERSION}" = "snapshot" ]; then \
  wget ${FREEROUTING_SNAPSHOT_URL} -O /opt/freerouting.jar; \
  else \
  wget https://github.com/freerouting/freerouting/releases/download/v${FREEROUTING_VERSION}/freerouting-${FREEROUTING_VERSION}.jar -O /opt/freerouting.jar; \
  fi
RUN apt-get -y autoremove && \
	rm -rf /var/lib/apt/lists/* /var/cache/debconf/templates.dat-old /var/lib/dpkg/status-old
