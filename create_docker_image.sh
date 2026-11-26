#!/bin/bash
set -euo pipefail

REPO="ceoloide/ergogen-freerouting"
KICAD_VERSIONS="9 10"
# Base image tag per KiCad version. kicad9_auto:latest currently points at a
# missing amd64 manifest upstream, so KiCad 9 is pinned to the last good tag.
KICAD9_BASE_TAG="1.9.1-1_k9.0.7_d13.2"
KICAD10_BASE_TAG="latest"
ERGOGEN_STABLE_VERSION="4.2.1"
ERGOGEN_SNAPSHOT_URL="https://github.com/ceoloide/ergogen#v4.3.0"
ERGOGEN_SNAPSHOT_VERSION="4.3.0"
FREEROUTING_VERSION="2.6.0"
# KiCad version that receives each moving tag
STABLE_KICAD="10"
LATEST_KICAD="10"
DEV_KICAD="9"
PUSH="false"

# Parse command-line arguments
while [ "$#" -gt 0 ]; do
  case "$1" in
    --kicad-versions=*)
      KICAD_VERSIONS="${1#*=}"
      ;;
    --kicad9-base-tag=*)
      KICAD9_BASE_TAG="${1#*=}"
      ;;
    --kicad10-base-tag=*)
      KICAD10_BASE_TAG="${1#*=}"
      ;;
    --ergogen-stable-version=*)
      ERGOGEN_STABLE_VERSION="${1#*=}"
      ;;
    --ergogen-snapshot-url=*)
      ERGOGEN_SNAPSHOT_URL="${1#*=}"
      ;;
    --ergogen-snapshot-version=*)
      ERGOGEN_SNAPSHOT_VERSION="${1#*=}"
      ;;
    --freerouting-version=*)
      FREEROUTING_VERSION="${1#*=}"
      ;;
    --push)
      PUSH="true"
      ;;
    *)
      echo "Unknown argument: $1" >&2
      exit 1
      ;;
  esac
  shift
done

if [ ! -f Dockerfile ]; then
  echo "Dockerfile not found in the folder."
  exit 1
fi

# Pin the Ergogen snapshot to a commit so the image tag names exactly what it
# contains, even when the URL points at a moving branch.
ERGOGEN_SNAPSHOT_REPO="${ERGOGEN_SNAPSHOT_URL%%#*}"
ERGOGEN_SNAPSHOT_REF="${ERGOGEN_SNAPSHOT_URL#*#}"
if [ "${ERGOGEN_SNAPSHOT_REF}" = "${ERGOGEN_SNAPSHOT_URL}" ]; then
  ERGOGEN_SNAPSHOT_REF="HEAD"
fi
if ! [[ "${ERGOGEN_SNAPSHOT_REF}" =~ ^[0-9a-f]{40}$ ]]; then
  resolved="$(git ls-remote "${ERGOGEN_SNAPSHOT_REPO}" "${ERGOGEN_SNAPSHOT_REF}" | head -n 1 | cut -f 1)"
  if [ -z "${resolved}" ]; then
    echo "Could not resolve ${ERGOGEN_SNAPSHOT_REF} in ${ERGOGEN_SNAPSHOT_REPO}" >&2
    exit 1
  fi
  ERGOGEN_SNAPSHOT_REF="${resolved}"
fi
ERGOGEN_SNAPSHOT_PINNED_URL="${ERGOGEN_SNAPSHOT_REPO}#${ERGOGEN_SNAPSHOT_REF}"
ERGOGEN_SNAPSHOT_LABEL="${ERGOGEN_SNAPSHOT_VERSION}-${ERGOGEN_SNAPSHOT_REF:0:7}"

echo "Variables:"
echo "KICAD_VERSIONS=${KICAD_VERSIONS}"
echo "KICAD9_BASE_TAG=${KICAD9_BASE_TAG}"
echo "KICAD10_BASE_TAG=${KICAD10_BASE_TAG}"
echo "ERGOGEN_STABLE_VERSION=${ERGOGEN_STABLE_VERSION}"
echo "ERGOGEN_SNAPSHOT_URL=${ERGOGEN_SNAPSHOT_PINNED_URL}"
echo "ERGOGEN_SNAPSHOT_LABEL=${ERGOGEN_SNAPSHOT_LABEL}"
echo "FREEROUTING_VERSION=${FREEROUTING_VERSION}"
echo "PUSH=${PUSH}"

base_tag_for() {
  case "$1" in
    9) echo "${KICAD9_BASE_TAG}" ;;
    10) echo "${KICAD10_BASE_TAG}" ;;
    *) echo "latest" ;;
  esac
}

# build <kicad> <ergogen build arg> <tag>...
build() {
  local kicad="$1" ergogen="$2"
  shift 2
  local tag_args=() tag
  for tag in "$@"; do
    tag_args+=(-t "${REPO}:${tag}")
  done
  docker build . \
    --build-arg KICAD_VERSION="${kicad}" \
    --build-arg KICAD_BASE_TAG="$(base_tag_for "${kicad}")" \
    --build-arg ERGOGEN_VERSION="${ergogen}" \
    --build-arg ERGOGEN_SNAPSHOT_URL="${ERGOGEN_SNAPSHOT_PINNED_URL}" \
    --build-arg FREEROUTING_VERSION="${FREEROUTING_VERSION}" \
    "${tag_args[@]}"
  if [ "${PUSH}" = "true" ]; then
    for tag in "$@"; do
      docker push "${REPO}:${tag}"
    done
  fi
}

for kicad in ${KICAD_VERSIONS}; do
  # Stable Ergogen
  tags=("k${kicad}_e${ERGOGEN_STABLE_VERSION}_f${FREEROUTING_VERSION}")
  if [ "${kicad}" = "${STABLE_KICAD}" ]; then
    tags+=("stable")
  fi
  build "${kicad}" "${ERGOGEN_STABLE_VERSION}" "${tags[@]}"

  # Snapshot Ergogen
  tags=("k${kicad}_e${ERGOGEN_SNAPSHOT_LABEL}_f${FREEROUTING_VERSION}" "k${kicad}_latest")
  if [ "${kicad}" = "${LATEST_KICAD}" ]; then
    tags+=("latest")
  fi
  if [ "${kicad}" = "${DEV_KICAD}" ]; then
    tags+=("dev")
  fi
  build "${kicad}" snapshot "${tags[@]}"
done
