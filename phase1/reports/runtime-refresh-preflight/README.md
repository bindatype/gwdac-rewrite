# Legacy Runtime Refresh preflight

Evidence label: **reference** inventory evidence from the archived arndt64
`f6c81d01a1fe8b007c247acc2213f821a62dc4f2` and GWDAC
`aacdf975295d11eb0ec7529edd8fd549025dcd4d` snapshots. No engine was built or
accepted by this checkpoint.

## Result

The archived `said/mkS.ksh` identifies complete source lists for all six
runtime-refresh candidates. Every listed source file, local startup file,
dataset referenced by the corresponding `SAIDOPEN` branch, and checked-in
historical executable survives.

| Rank | Engine | Source/data closure | Deck | Captured transcript | Preflight disposition |
| ---: | --- | --- | --- | --- | --- |
| 1 | `pnsd` | Complete | `pn/PNF.INP` | `pn/PNF.OUT` | Build and oracle-pairing attempt |
| 2 | `eprsd` | Complete | `pr/epr/EPRF.INP` | `pr/epr/EPRF.OUT` | Build and oracle-pairing attempt |
| 3 | `nnsd` | Complete | `nn/NNF.INP` | `nn/NNF.OUT` | Build and oracle-pairing attempt |
| 4 | `knsd` | Complete | `KN/INPUT` | GWDAC `TKN`, unpaired | Build attempt; oracle contract needs reconstruction |
| 5 | `pdsd` | Complete | Missing | GWDAC `TPD` | Buildable; behavioral gate blocked on a deck |
| 6 | `pdesd` | Complete | Missing | GWDAC `TPDE` | Buildable; behavioral gate blocked on a deck |

The first three deck/transcript pairs are plausible surviving pairs, not yet
proven pairs. Only executing the checked-in historical binary with the deck can
promote them from reference evidence to an oracle fixture. `pnsd` remains the
strongest first attempt because it also has the widest surviving web-wrapper
coverage.

All six historical executables depend on obsolete runtime families including
`libgfortran.so.3`, `libg2c.so.0`, `libpng12.so.0`, and legacy GD. Those are
oracle-container requirements, not dependencies permitted in a modern build.

## Reproduction

```sh
docker compose -p gwdac-rewrite \
  -f container-environment/compose.yaml exec -T \
  dev bash /phase1/scripts/inventory-runtime-refresh
```

`engine-matrix.tsv` contains the counts and dispositions. Each
`manifests/<engine>.txt` records the source commits, paths, ELF dependencies,
and SHA-256 hashes for its source, local inputs, datasets, executable, deck,
and transcript. `manifest.txt` hashes the complete preflight output.

These six engines are runtime-refresh candidates, not newly retained product
workflows. Build success will establish compiler feasibility only; behavioral
acceptance still requires an executable/deck oracle, and scientific acceptance
remains outside this milestone.
