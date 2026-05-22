# easttimor-derived Sigma rules (work in progress)

This directory contains Sigma rules translated from the [easttimor/aws-incident-response](https://github.com/easttimor/aws-incident-response) API Watchlist (MIT-licensed). Each rule:

1. Has a header comment citing the originating section in the upstream README.
2. Carries explicit MITRE ATT&CK technique and tactic tags from the upstream documentation.
3. Uses CloudTrail's native field names (`eventName`, `eventSource`, `userIdentity.*`).

## Translation pattern

The upstream repo expresses detections as Athena SQL queries:

```sql
SELECT *
FROM cloudtrail_000000000000
WHERE year = '####' AND month = '##' AND day = '##'
  AND eventSource = 'iam.amazonaws.com'
  AND eventName IN ('AttachUserPolicy', 'PutRolePolicy', ...)
```

Mechanical translation to Sigma:

- `eventSource = 'x'` becomes a scalar selection key
- `eventName IN (...)` becomes a Sigma list under the same selection
- Year/month/day partition predicates are dropped (Sigma rules are time-window agnostic; correlation rules layer time semantics on top)
- ATT&CK technique IDs documented inline in the README go into `tags:`
- `falsepositives:` requires hand-written judgement from the rule author

## Status

This is intentionally a small worked example showing the translation pattern. The full upstream watchlist contains roughly 80 detections. Pull requests welcome; please preserve the provenance footers and ATT&CK tags exactly as documented upstream.

## License

MIT for the translated rules. Upstream watchlist is also MIT.
