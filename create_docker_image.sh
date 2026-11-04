#!/bin/bash
set -euo pipefail

KICAD_VERSION="9"
ERGOGEN_STABLE_VERSION="4.2.1"
ERGOGEN_SNAPSHOT_URL="https://github.com/ceoloide/ergogen#v4.3.0"
FREEROUTING_STABLE_VERSION="2.5.0"
FREEROUTING_SNAPSHOT_IMAGE="ghcr.io/freerouting/freerouting:nightly@sha256:b7c4223089549082ba1ff1588858665690e652e27b5d230ddc1548de7d77fb6d"
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
    --freerouting-snapshot-image=*)
      if [ -n "${1#*=}" ]; then
        FREEROUTING_SNAPSHOT_IMAGE="${1#*=}"
      fi
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

echo "Variables:"
echo "KICAD_VERSION=${KICAD_VERSION}"
echo "ERGOGEN_STABLE_VERSION=${ERGOGEN_STABLE_VERSION}"
echo "ERGOGEN_SNAPSHOT_URL=${ERGOGEN_SNAPSHOT_URL}"
echo "FREEROUTING_STABLE_VERSION=${FREEROUTING_STABLE_VERSION}"
echo "FREEROUTING_SNAPSHOT_IMAGE=${FREEROUTING_SNAPSHOT_IMAGE}"
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
  -t ceoloide/ergogen-freerouting:"k${KICAD_VERSION}_${ERGOGEN_STABLE_VERSION}_${FREEROUTING_STABLE_VERSION}" \
  -t ceoloide/ergogen-freerouting:"k${KICAD_VERSION}_latest"
if [ "${PUSH}" = "true" ]; then
  docker push ceoloide/ergogen-freerouting:"k${KICAD_VERSION}_${ERGOGEN_STABLE_VERSION}_${FREEROUTING_STABLE_VERSION}"
  docker push ceoloide/ergogen-freerouting:"k${KICAD_VERSION}_latest"
fi

# Build stable/snapshot
docker build . \
  --build-arg KICAD_VERSION="${KICAD_VERSION}" \
  --build-arg ERGOGEN_VERSION="${ERGOGEN_STABLE_VERSION}" \
  --build-arg FREEROUTING_VERSION=snapshot \
  --build-arg FREEROUTING_SNAPSHOT_IMAGE="${FREEROUTING_SNAPSHOT_IMAGE}" \
  --build-arg FREEROUTING_SNAPSHOT_URL="${FREEROUTING_SNAPSHOT_URL}" \
  -t ceoloide/ergogen-freerouting:"k${KICAD_VERSION}_${ERGOGEN_STABLE_VERSION}_snapshot"
if [ "${PUSH}" = "true" ]; then
  docker push ceoloide/ergogen-freerouting:"k${KICAD_VERSION}_${ERGOGEN_STABLE_VERSION}_snapshot"
fi

# Build snapshot/stable
docker build . \
  --build-arg KICAD_VERSION="${KICAD_VERSION}" \
  --build-arg ERGOGEN_VERSION=snapshot \
  --build-arg ERGOGEN_SNAPSHOT_URL="${ERGOGEN_SNAPSHOT_URL}" \
  --build-arg FREEROUTING_VERSION="${FREEROUTING_STABLE_VERSION}" \
  -t ceoloide/ergogen-freerouting:"k${KICAD_VERSION}_snapshot_${FREEROUTING_STABLE_VERSION}"
if [ "${PUSH}" = "true" ]; then
  docker push ceoloide/ergogen-freerouting:"k${KICAD_VERSION}_snapshot_${FREEROUTING_STABLE_VERSION}"
fi

# Build snapshot/snapshot (dev)
if [ "${KICAD_VERSION}" = "9" ]; then
  docker build . \
    --build-arg KICAD_VERSION="${KICAD_VERSION}" \
    --build-arg ERGOGEN_VERSION=snapshot \
    --build-arg ERGOGEN_SNAPSHOT_URL="${ERGOGEN_SNAPSHOT_URL}" \
    --build-arg FREEROUTING_VERSION=snapshot \
    --build-arg FREEROUTING_SNAPSHOT_IMAGE="${FREEROUTING_SNAPSHOT_IMAGE}" \
    --build-arg FREEROUTING_SNAPSHOT_URL="${FREEROUTING_SNAPSHOT_URL}" \
    -t ceoloide/ergogen-freerouting:"k${KICAD_VERSION}_snapshot" \
    -t ceoloide/ergogen-freerouting:dev
  if [ "${PUSH}" = "true" ]; then
    docker push ceoloide/ergogen-freerouting:"k${KICAD_VERSION}_snapshot"
    docker push ceoloide/ergogen-freerouting:dev
  fi
else
  docker build . \
    --build-arg KICAD_VERSION="${KICAD_VERSION}" \
    --build-arg ERGOGEN_VERSION=snapshot \
    --build-arg ERGOGEN_SNAPSHOT_URL="${ERGOGEN_SNAPSHOT_URL}" \
    --build-arg FREEROUTING_VERSION=snapshot \
    --build-arg FREEROUTING_SNAPSHOT_IMAGE="${FREEROUTING_SNAPSHOT_IMAGE}" \
    --build-arg FREEROUTING_SNAPSHOT_URL="${FREEROUTING_SNAPSHOT_URL}" \
    -t ceoloide/ergogen-freerouting:"k${KICAD_VERSION}_snapshot"
  if [ "${PUSH}" = "true" ]; then
    docker push ceoloide/ergogen-freerouting:"k${KICAD_VERSION}_snapshot"
  fi
fi
