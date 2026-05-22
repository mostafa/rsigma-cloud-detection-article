#!/usr/bin/env bash
# Compare the v0.11.0 optimizer layers: default, --bloom-prefilter,
# --bloom-prefilter --cross-rule-ac. Each run produces a .ndjson and a .time
# file under results/.
#
# The cross-rule AC layer requires rsigma built with --features daachorse-index.

set -euo pipefail

DATA="${DATA:-data/flaws_all.ndjson}"
RULES="${RULES:-rules/sigmahq/}"
RESULTS_DIR="${RESULTS_DIR:-results}"

mkdir -p "${RESULTS_DIR}"

if [[ ! -f "${DATA}" ]]; then
  echo "missing ${DATA}; run scripts/flatten.sh first" >&2
  exit 1
fi

run() {
  local label="$1"; shift
  echo ">> [${label}] flags: $*"
  /usr/bin/time -l rsigma engine eval \
    -r "${RULES}" \
    -e "@${DATA}" \
    "$@" \
    > "${RESULTS_DIR}/${label}.ndjson" \
    2> "${RESULTS_DIR}/${label}.time"
  grep -E "Processed|real|maximum" "${RESULTS_DIR}/${label}.time"
  echo ">> matches: $(wc -l < "${RESULTS_DIR}/${label}.ndjson")"
  echo
}

run baseline
run bloom        --bloom-prefilter
run bloom_ca     --bloom-prefilter --cross-rule-ac
run ca_only      --cross-rule-ac

echo ">> summary"
for label in baseline bloom bloom_ca ca_only; do
  real=$(awk '/real/{print $1}' "${RESULTS_DIR}/${label}.time")
  matches=$(wc -l < "${RESULTS_DIR}/${label}.ndjson")
  printf "  %-12s  %ss  %s matches\n" "${label}" "${real}" "${matches}"
done
