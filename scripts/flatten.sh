#!/usr/bin/env bash
# Download the flaws.cloud CloudTrail dataset (about 240 MB) and flatten the
# 20 gz chunks into a single NDJSON file ready for `rsigma eval`.
#
# Output: data/flaws_all.ndjson (about 2.3 GB uncompressed, 1,939,207 events)

set -euo pipefail

DATA_DIR="${DATA_DIR:-data}"
TAR_URL="https://summitroute.com/downloads/flaws_cloudtrail_logs.tar"
TAR_PATH="${DATA_DIR}/flaws_cloudtrail_logs.tar"
OUT_PATH="${DATA_DIR}/flaws_all.ndjson"

mkdir -p "${DATA_DIR}"

if [[ ! -f "${TAR_PATH}" ]]; then
  echo ">> downloading dataset (about 240 MB)..."
  curl -L --progress-bar -o "${TAR_PATH}" "${TAR_URL}"
fi

if [[ ! -d "${DATA_DIR}/flaws_cloudtrail_logs" ]]; then
  echo ">> extracting tar..."
  tar -xf "${TAR_PATH}" -C "${DATA_DIR}"
fi

if [[ ! -f "${OUT_PATH}" ]]; then
  echo ">> flattening 20 gz chunks to NDJSON..."
  for f in "${DATA_DIR}"/flaws_cloudtrail_logs/flaws_cloudtrail*.json.gz; do
    gzcat "${f}" | jq -c '.Records[]'
  done > "${OUT_PATH}"
fi

echo ">> ready"
wc -l "${OUT_PATH}"
ls -lh "${OUT_PATH}"
