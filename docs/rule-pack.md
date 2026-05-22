# Rule pack provenance

Every rule in this repo traces to a public source. This file is the inventory.

## SigmaHQ rules (`rules/sigmahq/`)

55 rules copied verbatim from [SigmaHQ/sigma master branch](https://github.com/SigmaHQ/sigma/tree/master/rules/cloud/aws/cloudtrail) on 2026-05-22. License: [Detection Rule License (DRL) 1.1](https://github.com/SigmaHQ/Detection-Rule-License). To refresh, replace this directory with a fresh clone of `sigma/rules/cloud/aws/cloudtrail/`.

These rules already carry MITRE ATT&CK tags and follow the standard `logsource: { product: aws, service: cloudtrail }` convention, so they slot into RSigma without any field mapping.

Lint state on 2026-05-22 with `rsigma rule lint rules/sigmahq/`: 52 pass, 3 with non-fatal `wildcard_only_value` warnings on lone-wildcard `|contains` patterns (recommended fix: switch to `|exists: true`). The warnings do not affect detection behavior; they are style suggestions.

## easttimor-derived rules (`rules/easttimor/`)

Sigma rules translated from the API Watchlist in [easttimor/aws-incident-response](https://github.com/easttimor/aws-incident-response). License: MIT (matches upstream).

Each rule has a header comment citing the originating section in the upstream README. See [`rules/easttimor/README.md`](../rules/easttimor/README.md) for the translation pattern.

Status: this directory is a worked example, not a complete translation of the upstream watchlist. The full upstream playbook contains roughly 80 distinct detections; community contributions to extend the pack are welcome.

## Correlation rules (`rules/correlations/`)

Custom correlation rules layered on top of the detection rules in this pack. License: MIT.

| Rule | Type | Window | What it detects |
|---|---|---|---|
| `aws_post_compromise_recon_burst.yml` | `event_count` | 2 minutes | A burst of `Describe*` calls from a single principal, modeling the post-credential-theft reconnaissance pattern surfaced in the article's findings (the IMDS abuse incident on 2020-06-09) |

## Adding a rule

1. Create a YAML file under the appropriate subdirectory.
2. Include a header comment citing the source (URL plus license).
3. Generate a fresh UUID with `uuidgen`.
4. Run `rsigma rule lint rules/` and fix any warnings.
5. Run `./scripts/replay.sh` to verify the rule loads against the corpus.
6. Open a PR with the rule and a description of what it detects.
