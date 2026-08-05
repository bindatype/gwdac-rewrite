# `prsdd` GO5 / `PRRDX` diagnostic

Date: 2026-08-05

Scope: bounded, offline diagnosis of the modern `prsdd` GO5 database-list path.
No production host was contacted. No production, physics formula, orchestration,
fixture tolerance, or default compatibility behavior was changed.

## Result

The proposed generic `PRRDX` failure does **not** reproduce in `prsdd`.
The database-list deck reaches `pru.f:4839` 3,740 times. Every internal read
returns `IOSTAT=0` in both the accepted patched build and the unpatched modern
build, and both processes exit normally.

The existing `prrdx-gfortran-blank-a4.patch` does change behavior:

| Executable | Patch state | Total data | Exit |
|---|---:|---:|---:|
| accepted modern headless | applied | 204 | 0 |
| fresh modern headless | applied | 204 | 0 |
| modern headless | omitted | 238 | 0 |
| checked-in `arndt64/said/prsdd` | historical binary | 238 | 0 |

The fresh default build is byte-identical to the accepted binary at SHA-256
`958889882d91fce225c04bc18021725fec757bde6ea047df1bf93a4136c7aa4f`.
The unpatched build is deterministic across two runs.

The first internal divergence occurs on read 1 in `MMO`:

| Variant | Integer | A4 memory bytes |
|---|---:|---|
| patched | 540483652 | `D 7 ` |
| unpatched | 538976324 | `D   ` |

The one-byte write to `CSTR(57:57)` changes 3,634 parsed fields across 2,580
of 3,740 reads despite both variants reporting `IOSTAT=0`. This is systemic,
not an isolated record.

## Historical comparison

Evidence labels:

- **Oracle:** checked-in historical `prsdd`, SHA-256
  `8a3c925a3aa95314fb4ad4fa7a8cbfa0095df898ee6fa96dad2071d20789678a`.
- **Captured local diagnostic:** modern patched, unpatched, and traced runs in
  the pinned Ubuntu 24.04 / gfortran 13.3.0 container.
- **Reference:** the accepted modern headless artifact and frozen GO3 priming
  result `0.2098E+01`.
- **Inferred:** interpretation of the remaining `pnsd`-specific precondition.

Neither modern stdout is byte-identical to the historical stdout. The
historical binary preserves punctuation and longer deletion annotations that
both modern builds render differently, and it uses the retained plotting
backend. A diagnostic selection projection removes only those title/deletion
display lines and the plotting footer. Under that projection, historical and
unpatched outputs are byte-identical; historical and patched are not. This
projection is diagnostic evidence, not a replacement regression tolerance.

Therefore:

1. The accepted blank-A4 patch is not a valid general GO5 compatibility fix on
   the current compiler; it changes historical data selection from 238 to 204.
2. Removing it is not authorized here and would not by itself restore complete
   historical rendering, so the default build remains unchanged.
3. The prior `pnsd` abort is not evidence of a generic `PRRDX` failure. Static
   comparison leaves `PNREAD`, the `IF=XX`/`CS3` mutation, and the `pnsd` data
   record shape as `PNRDX`-specific preconditions. Isolating which one triggers
   the abort requires a separately authorized `pnsd` trace.

Physics/domain approval remains pending. This result concerns runtime and data
selection fidelity only.

## Reproduction

From the evidence-repository root, the single CI-runnable entry point restores
the frozen source bundle, creates the accepted artifact when absent, runs both
containers, and verifies the evidence manifest:

```sh
phase1/scripts/verify-prsdd-go5-diagnostic
```

Its underlying commands are:

```sh
docker compose up -d dev oracle
docker compose exec -T dev env REUSE_DIAGNOSTIC_BUILDS=yes \
  /phase1/scripts/run-prsdd-go5-diagnostic
docker compose exec -T oracle \
  /phase1/scripts/run-historical-prsdd-go5-diagnostic
```

The historical service is network-disabled and read-only. `manifest.sha256`
checks every evidence artifact in this directory.

## Key artifacts

- `results.tsv`: modern run matrix, hashes, exits, totals, and trace status.
- `historical-results.tsv`: historical totals and exact/projection relations.
- `read-value-summary.tsv`: read and field divergence counts.
- `read-values.diff`: first 120 lines of the parsed-value diff.
- `patched-read-values.txt`, `unpatched-read-values.txt`: full parsed traces.
- `historical-vs-patched.diff`, `historical-vs-unpatched.diff`: full stdout
  comparisons.
- `source-path-comparison.tsv`: bounded `PRRDX`/`PNRDX` source comparison.
- `environment.txt`, `historical-environment.txt`: source, compiler, runtime,
  binary, fixture, and patch provenance.
