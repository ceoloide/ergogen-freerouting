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

ERGOGEN_STABLE_VERSION="4.1.0"
ERGOGEN_SNAPSHOT_URL="https://github.com/ergogen/ergogen#develop"
FREEROUTING_STABLE_VERSION="2.1.0"
FREEROUTING_SNAPSHOT_URL=$(get_snapshot_url)

if [ ! -f Dockerfile ]; then
  echo "Dockerfile not found in the folder."
  exit 1
fi

# Build and push stable/stable
docker build . \
  --build-arg ERGOGEN_VERSION=${ERGOGEN_STABLE_VERSION} \
  --build-arg FREEROUTING_VERSION=${FREEROUTING_STABLE_VERSION} \
  -t ceoloide/ergogen-freerouting:${ERGOGEN_STABLE_VERSION}_${FREEROUTING_STABLE_VERSION} \
  -t ceoloide/ergogen-freerouting:latest
docker push ceoloide/ergogen-freerouting:${ERGOGEN_STABLE_VERSION}_${FREEROUTING_STABLE_VERSION}
docker push ceoloide/ergogen-freerouting:latest

# Build and push stable/snapshot
docker build . \
  --build-arg ERGOGEN_VERSION=${ERGOGEN_STABLE_VERSION} \
  --build-arg FREEROUTING_VERSION=snapshot \
  --build-arg FREEROUTING_SNAPSHOT_URL=${FREEROUTING_SNAPSHOT_URL} \
  -t ceoloide/ergogen-freerouting:${ERGOGEN_STABLE_VERSION}_snapshot
docker push ceoloide/ergogen-freerouting:${ERGOGEN_STABLE_VERSION}_snapshot

# Build and push snapshot/stable
docker build . \
  --build-arg ERGOGEN_VERSION=snapshot \
  --build-arg ERGOGEN_SNAPSHOT_URL=${ERGOGEN_SNAPSHOT_URL} \
  --build-arg FREEROUTING_VERSION=${FREEROUTING_STABLE_VERSION} \
  -t ceoloide/ergogen-freerouting:snapshot_${FREEROUTING_STABLE_VERSION}
docker push ceoloide/ergogen-freerouting:snapshot_${FREEROUTING_STABLE_VERSION}

# Build and push snapshot/snapshot
docker build . \
  --build-arg ERGOGEN_VERSION=snapshot \
  --build-arg ERGOGEN_SNAPSHOT_URL=${ERGOGEN_SNAPSHOT_URL} \
  --build-arg FREEROUTING_VERSION=snapshot \
  --build-arg FREEROUTING_SNAPSHOT_URL=${FREEROUTING_SNAPSHOT_URL} \
  -t ceoloide/ergogen-freerouting:snapshot
docker push ceoloide/ergogen-freerouting:snapshot
