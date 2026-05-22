#!/usr/bin/env bash
# One-shot detection pass against the flattened flaws.cloud corpus.
#
# Output: results/baseline.ndjson (one detection match per line)

set -euo pipefail

DATA="${DATA:-data/flaws_all.ndjson}"
RULES="${RULES:-rules/sigmahq/}"
RESULTS_DIR="${RESULTS_DIR:-results}"

mkdir -p "${RESULTS_DIR}"

if [[ ! -f "${DATA}" ]]; then
  echo "missing ${DATA}; run scripts/flatten.sh first" >&2
  exit 1
fi

echo ">> running rsigma against ${DATA}"
echo ">> rules: ${RULES}"

/usr/bin/time -l rsigma engine eval \
  -r "${RULES}" \
  -e "@${DATA}" \
  > "${RESULTS_DIR}/baseline.ndjson" \
  2> "${RESULTS_DIR}/baseline.time"

echo ">> done"
grep -E "Processed|real|maximum" "${RESULTS_DIR}/baseline.time"
echo ">> matches: $(wc -l < "${RESULTS_DIR}/baseline.ndjson")"
