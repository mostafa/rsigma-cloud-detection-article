# ATT&CK coverage breakdown

Generated from the actual detection results captured on 2026-05-22 by running `scripts/replay.sh` against the full 1,939,207-event flaws.cloud corpus with the 55-rule SigmaHQ pack. Update this file by re-running the replay after adding rules or refreshing the SigmaHQ pack.

## Run summary

| Metric | Value |
|---|---|
| Events processed | 1,939,207 |
| Wall time | 16.76 s |
| Throughput | 115,705 ev/s |
| Maximum resident set size | 14.3 MB |
| Total detection matches | 68,576 |
| Rules loaded | 55 |
| Rules that fired | 15 |
| Rules with zero matches | 40 |

## Severity distribution

| Severity | Match count | Share |
|---|---:|---:|
| low | 54,848 | 80.0% |
| medium | 11,151 | 16.3% |
| high | 2,577 | 3.8% |
| critical | 0 | 0.0% |

## Top fires by rule

| Rank | Rule | Severity | Matches |
|---:|---|---|---:|
| 1 | AWS STS AssumeRole Misuse | low | 42,315 |
| 2 | Potential Bucket Enumeration on AWS | low | 12,122 |
| 3 | AWS Root Credentials | medium | 10,997 |
| 4 | Malicious Usage Of IMDS Credentials Outside Of AWS Infrastructure | high | 2,573 |
| 5 | AWS STS GetSessionToken Misuse | medium | 209 |
| 6 | AWS S3 Data Management Tampering | medium | 202 |
| 7 | AWS Snapshot Backup Exfiltration | medium | 56 |
| 8 | AWS IAM Backdoor Users Keys | high | 53 |
| 9 | AWS Key Pair Import Activity | medium | 16 |
| 10 | Ingress/Egress Security Group Modification | low | 15 |
| 11 | AWS Successful Console Login Without MFA | medium | 6 |
| 12 | AWS CloudTrail Important Change | medium | 4 |
| 13 | AWS Bucket Deleted | medium | 4 |
| 14 | AWS User Login Profile Was Modified | medium | 3 |
| 15 | AWS Config Disabling Channel/Recorder | medium | 1 |

## ATT&CK tactic breakdown

A single match can carry multiple tactic tags, so the totals overlap.

| Tactic | Match count |
|---|---:|
| Privilege Escalation | 56,172 |
| Defense Evasion | 56,125 |
| Lateral Movement | 42,524 |
| Persistence | 13,648 |
| Initial Access | 13,607 |
| Discovery | 12,122 |
| Exfiltration | 258 |

## Optimizer-layer comparison

| Run | Wall time | Throughput | RSS | Matches |
|---|---:|---:|---:|---:|
| Baseline (default optimizer) | 16.76 s | 115,705 ev/s | 14.32 MB | 68,576 |
| `--bloom-prefilter` | 16.93 s | 114,544 ev/s | 14.25 MB | 68,576 |
| `--bloom-prefilter --cross-rule-ac` | 18.93 s | 102,440 ev/s | 14.45 MB | 68,576 |
| `--cross-rule-ac` | 19.15 s | 101,266 ev/s | 14.39 MB | 68,576 |

Match counts identical across all four runs (correctness invariant). The opt-in layers do not help on a 55-rule pack; the cross-rule AC index actively slows the run by 12% because the per-event scan cost is not amortized at this scale. See [BENCHMARKS.md](https://github.com/timescale/rsigma/blob/main/BENCHMARKS.md) for the rule-count sweeps where the layers shine (1,000+ rules).

## Dead-weight rules (zero matches on flaws.cloud)

40 of 55 rules never fired. This is a coverage signal about the corpus, not the rule pack: flaws.cloud is a deliberately small lab without EFS, traffic mirroring, GuardDuty findings, trufflehog activity, RDS snapshots, etc. On a real production CloudTrail these rules would still be valuable.

Sample of dead-weight rules:

- `aws_cloudtrail_guardduty_detector_deleted_or_updated`
- `aws_cloudtrail_new_acl_entries`
- `aws_cloudtrail_new_route_added`
- `aws_cloudtrail_pua_trufflehog`
- `aws_cloudtrail_region_enabled`
- `aws_cloudtrail_security_group_change_loadbalancer`
- `aws_cloudtrail_security_group_change_rds`
- `aws_cloudtrail_ssm_malicious_usage`
- `aws_cloudtrail_vpc_flow_logs_deleted`
- `aws_console_getsignintoken`
- `aws_delete_identity`
- `aws_delete_saml_provider`
- `aws_disable_bucket_versioning`
- `aws_ec2_disable_encryption`
- `aws_ec2_startup_script_change`
- `aws_ec2_vm_export_failure`
- `aws_ecs_task_definition_cred_endpoint_query`
- `aws_efs_fileshare_modified_or_deleted`
- `aws_efs_fileshare_mount_modified_or_deleted`
- (...and 21 more)

Run `./scripts/replay.sh && diff <(jq -r '.rule_title' results/baseline.ndjson | sort -u) <(grep -h '^title:' rules/sigmahq/*.yml | sed 's/^title: //' | sort -u)` to regenerate this list.

## Reproducibility

```bash
./scripts/flatten.sh    # download dataset and flatten to NDJSON
./scripts/replay.sh     # baseline run (writes results/baseline.ndjson)
./scripts/bench.sh      # full optimizer comparison

# Then regenerate the tables above:
jq -r '.rule_title' results/baseline.ndjson | sort | uniq -c | sort -rn
jq -r '.level' results/baseline.ndjson | sort | uniq -c | sort -rn
jq -r '.tags[] | select(startswith("attack.ta") or test("^attack\\.[a-z_-]+$") and (test("^attack\\.t[0-9]") | not))' \
  results/baseline.ndjson | sort | uniq -c | sort -rn
```
