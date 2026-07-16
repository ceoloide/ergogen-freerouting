#!/bin/bash
set -euo pipefail

# Function to get the latest snapshot URL
get_snapshot_url() {
  curl -s -H "Accept: application/vnd.github.v3+json" \
  "https://api.github.com/repos/freerouting/freerouting/releases/tags/SNAPSHOT" | \
  grep "browser_download_url" | \
  grep "\.jar\"" | \
  cut -d '"' -f 4 | \
  head -n 1
}

KICAD_VERSION="8"
ERGOGEN_STABLE_VERSION="4.2.1"
ERGOGEN_SNAPSHOT_URL="https://github.com/ceoloide/ergogen#v4.3.0"
FREEROUTING_STABLE_VERSION="2.2.4"
FREEROUTING_SNAPSHOT_URL=""
PUSH="false"

# Parse command-line arguments
while [ "$#" -gt 0 ]; do
  case "$1" in
    --kicad-version=*)
      KICAD_VERSION="${1#*=}"
      ;;
    --ergogen-stable-version=*)
      ERGOGEN_STABLE_VERSION="${1#*=}"
      ;;
    --ergogen-snapshot-url=*)
      ERGOGEN_SNAPSHOT_URL="${1#*=}"
      ;;
    --freerouting-stable-version=*)
      FREEROUTING_STABLE_VERSION="${1#*=}"
      ;;
    --freerouting-snapshot-url=*)
      FREEROUTING_SNAPSHOT_URL="${1#*=}"
      ;;
    --push)
      PUSH="true"
      ;;
  esac
  shift
done

if [ -z "${FREEROUTING_SNAPSHOT_URL}" ]; then
  FREEROUTING_SNAPSHOT_URL=$(get_snapshot_url)
fi

echo "Variables:"
echo "KICAD_VERSION=${KICAD_VERSION}"
echo "ERGOGEN_STABLE_VERSION=${ERGOGEN_STABLE_VERSION}"
echo "ERGOGEN_SNAPSHOT_URL=${ERGOGEN_SNAPSHOT_URL}"
echo "FREEROUTING_STABLE_VERSION=${FREEROUTING_STABLE_VERSION}"
echo "FREEROUTING_SNAPSHOT_URL=${FREEROUTING_SNAPSHOT_URL}"
echo "PUSH=${PUSH}"

if [ ! -f Dockerfile ]; then
  echo "Dockerfile not found in the folder."
  exit 1
fi

# Build stable/stable
docker build . \
  --build-arg KICAD_VERSION="${KICAD_VERSION}" \
  --build-arg ERGOGEN_VERSION="${ERGOGEN_STABLE_VERSION}" \
  --build-arg FREEROUTING_VERSION="${FREEROUTING_STABLE_VERSION}" \
  -t ceoloide/ergogen-freerouting:"${ERGOGEN_STABLE_VERSION}_${FREEROUTING_STABLE_VERSION}"
if [ "${PUSH}" = "true" ]; then
  docker push ceoloide/ergogen-freerouting:"${ERGOGEN_STABLE_VERSION}_${FREEROUTING_STABLE_VERSION}"
fi

# Build stable/snapshot
docker build . \
  --build-arg KICAD_VERSION="${KICAD_VERSION}" \
  --build-arg ERGOGEN_VERSION="${ERGOGEN_STABLE_VERSION}" \
  --build-arg FREEROUTING_VERSION=snapshot \
  --build-arg FREEROUTING_SNAPSHOT_URL="${FREEROUTING_SNAPSHOT_URL}" \
  -t ceoloide/ergogen-freerouting:"${ERGOGEN_STABLE_VERSION}_snapshot"
if [ "${PUSH}" = "true" ]; then
  docker push ceoloide/ergogen-freerouting:"${ERGOGEN_STABLE_VERSION}_snapshot"
fi

# Build snapshot/stable
docker build . \
  --build-arg KICAD_VERSION="${KICAD_VERSION}" \
  --build-arg ERGOGEN_VERSION=snapshot \
  --build-arg ERGOGEN_SNAPSHOT_URL="${ERGOGEN_SNAPSHOT_URL}" \
  --build-arg FREEROUTING_VERSION="${FREEROUTING_STABLE_VERSION}" \
  -t ceoloide/ergogen-freerouting:"snapshot_${FREEROUTING_STABLE_VERSION}"
if [ "${PUSH}" = "true" ]; then
  docker push ceoloide/ergogen-freerouting:"snapshot_${FREEROUTING_STABLE_VERSION}"
fi

# Build snapshot/snapshot (dev / latest)
docker build . \
  --build-arg KICAD_VERSION="${KICAD_VERSION}" \
  --build-arg ERGOGEN_VERSION=snapshot \
  --build-arg ERGOGEN_SNAPSHOT_URL="${ERGOGEN_SNAPSHOT_URL}" \
  --build-arg FREEROUTING_VERSION=snapshot \
  --build-arg FREEROUTING_SNAPSHOT_URL="${FREEROUTING_SNAPSHOT_URL}" \
  -t ceoloide/ergogen-freerouting:snapshot \
  -t ceoloide/ergogen-freerouting:latest
if [ "${PUSH}" = "true" ]; then
  docker push ceoloide/ergogen-freerouting:snapshot
  docker push ceoloide/ergogen-freerouting:latest
fi
