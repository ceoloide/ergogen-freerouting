# Best practices documented at https://snyk.io/blog/10-best-practices-to-containerize-nodejs-web-applications-with-docker/
ARG KICAD_VERSION=8
ARG ERGOGEN_VERSION=snapshot
ARG ERGOGEN_SNAPSHOT_URL=https://github.com/ceoloide/ergogen#bezier
ARG FREEROUTING_VERSION=2.1.0
ARG FREEROUTING_SNAPSHOT_URL="https://github.com/freerouting/freerouting/releases/download/SNAPSHOT/freerouting-SNAPSHOT-20250916_121300.jar"

FROM ghcr.io/inti-cmnb/kicad${KICAD_VERSION}_auto:latest
LABEL Description="Minimal Docker image with Ergogen (${ERGOGEN_VERSION}), Freerouting (${FREEROUTING_VERSION}), and KiCad ${KICAD_VERSION} with KiBot and other automation scripts" \
      Author="Marco Massarelli <marco.massarelli@gmail.com>"

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
