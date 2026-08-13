# Bundle-aware committed-history credential scan

Date: 2026-08-12

Evidence label: **captured** scanner execution and **reference** repository
identity. This is a retrospective scan of already-published private history,
not proof that no secret can exist under rules the scanner does not recognize.

## Scope and result

Gitleaks 8.30.1 was run with its default rules against all refs and full
committed history in three repositories:

| Repository history | Commits | Scanned head | Findings |
| --- | ---: | --- | ---: |
| authoritative `dev/outputs` | 26 | `dev@c59040711fed2748de9eb294ba15d7e5fff33d63` | 0 |
| embedded `arndt64.bundle` restored as a repository | 2 | `f6c81d01a1fe8b007c247acc2213f821a62dc4f2` | 0 |
| embedded `gwdac.bundle` restored as a repository | 4 | `aacdf975295d11eb0ec7529edd8fd549025dcd4d` | 0 |

The bundle histories were restored and scanned as Git repositories rather than
treated as opaque bundle files. This closes the known blind spot in earlier
text-blob scans. No secret value was printed or retained.

The six modified and 59 untracked working-tree status entries were outside this
committed-history publication check and were not staged, committed, or pushed.
Any future publication must scan the exact staged change separately.

The exact seven-file documentation/security checkpoint staged after this scan
was also scanned as a redacted patch with the same Gitleaks release and default
rules. It produced zero findings. That staged-patch check was repeated after
the final documentation and manifest content was established.

## Scanner provenance

- Release: `gitleaks/gitleaks` `v8.30.1`
- Asset: `gitleaks_8.30.1_darwin_arm64.tar.gz`
- Asset SHA-256:
  `b40ab0ae55c505963e365f271a8d3846efbc170aa17f2607f13df610a9aeb6a5`
- Release checksum-file SHA-256:
  `061476c21adaf5441516f96f185c1a4706a83cd6329b9b38762271b3d4a52fae`
- Empty redacted JSON report SHA-256, identical for all three runs:
  `37517e5f3dc66819f61f5a7bb8ace1921282415f10551d2defa5c3eb0985b570`

The release checksum listed the same SHA-256 for the downloaded Darwin arm64
asset before execution.

## Command shape

Each repository was scanned separately with:

```sh
gitleaks git --no-banner --no-color --redact=100 --log-level error \
  --exit-code 0 --log-opts="--all --full-history" \
  --report-format json --report-path <temporary-redacted-report> <repository>
```

Raw reports and the scanner binary remained in temporary storage and are not
part of this repository. Because all reports were empty JSON arrays, this
checkpoint retains only scanner provenance, scope, repository identities,
commit counts, hashes, and zero-finding counts.
