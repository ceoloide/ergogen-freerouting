#!/bin/bash

# Function to get the latest snapshot URL
get_snapshot_url() {
  curl -s -H "Accept: application/vnd.github.v3+json" \
  "https://api.github.com/repos/freerouting/freerouting/releases/tags/SNAPSHOT" | \
  grep "browser_download_url" | \
  grep "\.jar\"" | \
  cut -d '"' -f 4 | \
  head -n 1
}

ERGOGEN_STABLE="4.1.0"
FREEROUTING_STABLE_URL="https://github.com/freerouting/freerouting/releases/download/v2.1.0/freerouting-2.1.0.jar"
FREEROUTING_SNAPSHOT_URL=$(get_snapshot_url)

if [ ! -f Dockerfile ]; then
  echo "Dockerfile not found in the folder."
  exit 1
fi

# Build and push stable/stable
docker build . \
  --build-arg ERGOGEN_VERSION=${ERGOGEN_STABLE} \
  --build-arg FREEROUTING_URL=${FREEROUTING_STABLE_URL} \
  -t ceoloide/ergogen-freerouting:${ERGOGEN_STABLE}_2.1.0 \
  -t ceoloide/ergogen-freerouting:latest
docker push ceoloide/ergogen-freerouting:${ERGOGEN_STABLE}_2.1.0
docker push ceoloide/ergogen-freerouting:latest

# Build and push stable/snapshot
docker build . \
  --build-arg ERGOGEN_VERSION=${ERGOGEN_STABLE} \
  --build-arg FREEROUTING_URL=${FREEROUTING_SNAPSHOT_URL} \
  -t ceoloide/ergogen-freerouting:${ERGOGEN_STABLE}_snapshot
docker push ceoloide/ergogen-freerouting:${ERGOGEN_STABLE}_snapshot

# Build and push snapshot/stable
docker build . \
  --build-arg ERGOGEN_VERSION=snapshot \
  --build-arg FREEROUTING_URL=${FREEROUTING_STABLE_URL} \
  -t ceoloide/ergogen-freerouting:snapshot_2.1.0
docker push ceoloide/ergogen-freerouting:snapshot_2.1.0

# Build and push snapshot/snapshot
docker build . \
  --build-arg ERGOGEN_VERSION=snapshot \
  --build-arg FREEROUTING_URL=${FREEROUTING_SNAPSHOT_URL} \
  -t ceoloide/ergogen-freerouting:snapshot
docker push ceoloide/ergogen-freerouting:snapshot
