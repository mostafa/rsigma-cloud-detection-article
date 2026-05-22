# rsigma-cloud-detection-article

Companion repo for [Cloud Detection at Scale on a Laptop](https://mostafa.dev/cloud-detection-at-scale-on-a-laptop): how RSigma streams 1.9 million CloudTrail events through a community IR playbook in 17 seconds.

## What's in here

| Path | What it is |
|---|---|
| `rules/sigmahq/` | The 55-rule SigmaHQ AWS CloudTrail pack used for the runs in the article |
| `rules/easttimor/` | Sigma rules derived from the [easttimor/aws-incident-response](https://github.com/easttimor/aws-incident-response) API Watchlist, with provenance footers |
| `rules/correlations/` | Custom correlation rules layered on top of the detection rules |
| `pipelines/cloudtrail_normalize.yml` | RSigma processing pipeline for CloudTrail field normalization |
| `vector.toml` | Reference Vector configuration for the production OTLP path (Vector -> RSigma daemon) |
| `scripts/flatten.sh` | One-liner that turns the flaws.cloud tar into NDJSON |
| `scripts/replay.sh` | One-shot replay of the corpus through `rsigma eval` |
| `scripts/bench.sh` | Toggles `--bloom-prefilter` / `--cross-rule-ac` and captures comparison metrics |
| `grafana/dashboards/cloud-detection.json` | Grafana dashboard, panels grouped by ATT&CK tactic |
| `docs/rule-pack.md` | Per-rule provenance table mapping each Sigma rule to its source |
| `docs/attack-coverage.md` | Coverage breakdown by ATT&CK tactic, generated from real runs |

## Quick start

Prerequisites: `rsigma` (build with `cargo install rsigma --features daachorse-index` or pull `ghcr.io/timescale/rsigma:0.11.0`), `jq`, `curl`, about 3 GB of free disk.

```bash
# 1. Download the dataset (240 MB) and flatten to NDJSON
./scripts/flatten.sh

# 2. One-shot detection pass against the SigmaHQ rule pack
./scripts/replay.sh

# 3. Toggle the v0.11.0 optimizer layers and compare
./scripts/bench.sh
```

Expected baseline output on an Apple Silicon laptop:

```
Loaded 55 rules from rules/sigmahq/
Processed 1939207 events, 68576 matches.
       16.76 real        16.04 user         0.60 sys
            14319616  maximum resident set size
```

About 17 seconds of wall time. Roughly 115k events per second. Less than 15 MB of resident memory. No SIEM, no Athena cost, no infrastructure.

## Running the production pipeline

For continuous detection rather than one-shot replay, use Vector + the RSigma daemon:

```bash
# Terminal 1: start the daemon
rsigma engine daemon \
  --rules rules/sigmahq/ \
  --pipeline pipelines/cloudtrail_normalize.yml \
  --input http \
  --api-addr 127.0.0.1:9090

# Terminal 2: stream the corpus through Vector
vector --config vector.toml
```

See [`vector.toml`](./vector.toml) for the reference configuration.

## License

MIT for the article scaffolding, scripts, and easttimor-derived rules. SigmaHQ rules under `rules/sigmahq/` retain the Detection Rule License (DRL 1.1). The flaws.cloud dataset itself is owned by Scott Piper / Summit Route and is downloaded at runtime; it is not redistributed here.

See [LICENSE](./LICENSE) for full attribution.
