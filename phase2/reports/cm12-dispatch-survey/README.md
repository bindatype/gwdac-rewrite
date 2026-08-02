# CM12 pion-plus dispatch prevalence survey

Evidence label: **captured** runtime evidence, corroborated by the accepted
modern displayed-output corpus. This is compatibility evidence, not physics
approval.

## Question

Does the `M05` unmatched-title fallback observed at the focused 1000 MeV
fixture recur across the retained CM12 pion-plus request surface, or does a
different dispatch branch appear at other energies or through legacy request
recovery behavior?

The build-copy-only trace was broadened from `Elab=1000 MeV` to every
pion-plus energy while retaining the existing record format. No frozen source,
fixture, orchestration, formula, tolerance, or oracle was changed.

## Result

The survey ran 10 retained choice-1 amplitude fixtures containing 18 energy
groups and 468 form evaluations. All 10 displayed result tables are
byte-identical to their accepted modern corpus tables.

The unchanged three-engine oracle corpus was also rerun: the modern headless
reference, checked-in arndt64 executable, and checked-in GWDAC executable
remain exact for 24/24 fixtures and 288/288 typed records. The non-forced
experimental seam retains its previously recorded mismatch and is not counted
as an accepted execution path or a new regression from this diagnostic.

| Population | Rows | No dispatch | Branch 7 (`PNTEST`) | Branch 10 (`PNSM05`) | Other |
| --- | ---: | ---: | ---: | ---: | ---: |
| All traced forms | 468 | 10 | 458 | 0 | 0 |
| Candidate-relevant forms | 324 | 10 | 314 | 0 | 0 |

Each fresh executable invocation starts with blank saved title state. Its first
energy group has one zero-input row that returns without dispatch; the remaining
25 rows dispatch branch 7 after the incoming `M05` title fails to match a token.
For both five-energy sweeps, subsequent energy groups enter with saved `SP00`
state and all 26 rows continue through branch 7. No retained request selects
branch 10.

This resolves the bounded prevalence question. Further diagnostics of the same
dispatch path would repeat an established mechanism rather than distinguish a
remaining hypothesis, so Track 1 stops here. Selecting or implementing a
different dispatch remains separately gated.

## Reproduction

After building the Phase 2 seam in the pinned Ubuntu 24.04 x86-64 container:

```sh
docker compose -p gwdac-rewrite \
  -f container-environment/compose.yaml exec -T \
  -e PHASE1_REPORT_ROOT=/phase2/reports/cm12-dispatch-survey/build/cm12-seam-build \
  dev bash /phase2/scripts/run-cm12-dispatch-survey
```

Primary evidence:

- `fixture-summary.tsv`: per-fixture counts and exact-output gate.
- `energy-summary.tsv`: saved-title and dispatch behavior per energy group.
- `dispatch-detail.tsv`: all 468 normalized trace rows.
- `fixtures/*.pipeline.tsv`: per-fixture normalized traces.
- `fixtures/*.stdout.gz`: raw deterministic diagnostic transcripts.
- `manifest.txt`: source, solution, binary, input, accepted-output, and report
  hashes.
