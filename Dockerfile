# Best practices documented at https://snyk.io/blog/10-best-practices-to-containerize-nodejs-web-applications-with-docker/
ARG kicad_ver=8
FROM ghcr.io/inti-cmnb/kicad${kicad_ver}_auto:latest
LABEL Description="Minimal Docker image with Ergogen, Freerouting (2.1.0), and KiCad ${kicad_ver} with KiBot and other automation scripts" \
      Author="Marco Massarelli <marco.massarelli@gmail.com>"

RUN apt-get update && apt-get upgrade -y
RUN apt-get install -y --no-install-recommends nodejs npm wget
RUN npm install -g https://github.com/ergogen/ergogen#develop

RUN wget https://download.oracle.com/java/21/latest/jdk-21_linux-x64_bin.deb && \
  dpkg -i jdk-21_linux-x64_bin.deb
RUN wget https://github.com/freerouting/freerouting/releases/download/v2.1.0/freerouting-2.1.0.jar && \
	mv freerouting-2.1.0.jar /opt/freerouting.jar
RUN apt-get -y autoremove && \
	rm -rf /var/lib/apt/lists/* /var/cache/debconf/templates.dat-old /var/lib/dpkg/status-old
