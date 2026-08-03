# Production/archive source content diff

Date: 2026-08-03

Evidence classes:

- **captured**: files in the read-only production snapshot and their
  independently verified production SHA-256 values;
- **reference**: files from `arndt64@f6c81d01a1fe8b007c247acc2213f821a62dc4f2`
  and the local content comparison; and
- **inferred**: behavioral relevance where the differing source was not paired
  with and exercised against a deployed executable.

Physics/domain review remains pending. This is a static source comparison, not
a scientific endorsement or a source-to-binary pairing claim.

## Scope and method

`source-comparison.tsv` identified eight differing files and two files absent
from the archive among 424 captured source/build files. The eight pairs were
compared with `git diff --no-index --unified=0`; added/deleted line counts and
hunk counts are retained in `files.tsv`. The two production-only files were
inspected directly and checked for references from the captured wrappers and
build files.

All reads came from these local roots:

```text
archive:    /Users/maclach/Documents/Codex/2026-07-29/gwdac/dev/arndt64
production: /Users/maclach/Documents/Codex/2026-07-29/gwdac/work/production-20260803
```

Production was not contacted or executed. Raw production files and full
unified diffs are not committed; the report retains exact paths, hashes,
line-level metrics, changed routines, and bounded findings without making a
license or redistribution decision.

Input evidence:

| File | SHA-256 |
|---|---|
| `../source-comparison.tsv` | `e7d8cc311929a38f9dff69fded4105193a0bb66938922c984afcd17de0c1f031` |
| `../production.sha256` | `0d4bbdf1dded207caefd5c749d29121a8940e4c1c8014ce455b2c678303a82a2` |

## Result

The drift is substantive, but it does **not** revise the CM12 conclusion. None
of the ten files is one of the nine archived-source-equivalent files used to
build the public `/home/arndt64/said/prsdd`; that source set and executable
remain byte-identical to the accepted archive witness.

The ten files instead divide into operational support drift, non-CM12 physics
drift, and unpaired support copies:

| Production file | Diff | Classification | Routine-level finding and relevance |
|---|---:|---|---|
| `/home/arndt/lib/junk.f` | `+118/-179`, 28 hunks | build/operational; semantic support | Deployed bytes equal `/home/arndt/said/saidopen.for`. `SAIDOPEN` redirects many datasets from `/home/arndt64` to `/home/arndt`; `PWPRT`, `SDDRAW`, `XYOFM`, and `SAIDLOG` also differ. This can change file selection and output/mail behavior; no physics formula change was identified. |
| `/home/arndt/libxzl.for` | `+219/-221`, 5 hunks | build/operational | `SYMBOL` expands title handling from 64 to 80 characters. Legacy `SAIDPS` and `SAIDLOG` implementations are active in production but commented out in the archive. Relevance is plotting, PostScript, and transaction/mail behavior. |
| `/home/arndt/said/nn1.f` | `+2/-3`, 2 hunks | semantic; physics-relevant | The `SOLNN` difference is comment wording only. In `GROSSPHS`, production returns for `LL > 7`; the archive allows `LL=8`. This can suppress the eighth partial wave when the GROSS path is selected. No runtime fixture currently establishes reachability or numerical impact. |
| `/home/arndt/said/prsd.f` | `+119/-94`, 44 hunks | semantic; physics-relevant; operational | Broad separate-lineage drift affects `PROBS`, `PROBSL`, `XFORM`, `PRSOL`, `PRDLT`, `EKDLT`, `PRSETC`, and adds `SANDSCL`. It adds `EDSG/GDSG`, changes an `S1/S3` sign, makes transforms reaction-mass-aware, removes the archive's CM-form dispatch in `PRDLT`, changes background-channel selection, and rewrites data paths. It is not the source used by public CM12 `prsdd`; pairing with `/home/arndt/said/prsd` remains unproved. |
| `/home/arndt/said/pru.f` | `+1/-2`, 2 hunks | semantic; compiler/ABI risk | Production removes the caller's `REAL*8 QLEGY` declaration and the typed `REAL*8 FUNCTION QLEGY` prefix. The function body retains `IMPLICIT REAL*8`, but callers can infer a default-real return, creating compiler-dependent calling behavior. This is compatibility evidence, not authorization for a warning-driven fix. |
| `/home/arndt/said/saidopen.for` | `+121/-185`, 30 hunks | build/operational; semantic support | Its deployed bytes equal `/home/arndt/lib/junk.f`. The major changes are `/home/arndt` dataset roots, removal of SAID64/randomized-output additions, `SAIDPSX` and `XYOFM` support changes, and older `SAIDLOG`/mail behavior. It can control which datasets are opened but does not itself establish a changed physics formula. |
| `/home/arndt64/said/epru.f` | `+0/-1011`, 2 hunks | unresolved support copy; build closure risk | Production contains only `SETTYPE`, `RFINFO`, `RFM`, `RFK`, and `RF`. It omits the archive's electroproduction entry, kinematics, Q2, Born/OPE/omega, input-decoding, `GEHLEN`, and `PXPYPZ` routines. Active public `eprsd` wrappers target `/home/arndt`, whose `epru.f` is separate; this partial `/home/arndt64` copy is not in the CM12 build, so deployed behavioral relevance is unresolved. |
| `/home/arndt64/said/prux.f` | `+17/-332`, 11 hunks | semantic; physics-relevant support copy | `PNPWI` selects `WI94`/`PNWI94` instead of `SP06`/`PNSP06`, and the embedded `PNSP06` routine is absent. `HOPEC` and `PROPEC` zero the u-channel, `PRBORN` returns after `PROPEC`, `PRREAD` adds `EDSG/GDSG`, and `QLEGY` typing differs. This file is not in the nine-file CM12 build; reachability from a deployed workflow is unresolved. |
| `/home/arndt/said/junk.f` | production-only, 20,634 lines | unresolved | This is a large unnamed-main pion-nucleon working source with more than 130 following routines. No captured wrapper or build script references `junk.f`; there is no evidence that a deployed executable was built from it. Treat it as unpaired source residue until provenance says otherwise. |
| `/home/arndt/said/mkS.sh` | production-only, 97 lines | build/operational | Interactive csh build menu for `nnsd`, `pnsd`, `prsd`, `knsd`, `pdsd`, `pdesd`, and electroproduction variants. It invokes `g77-3.4` and links legacy GD/PNG/X11 libraries. It is useful build-lineage evidence, not a modern build recipe or proof that every deployed binary came from the adjacent sources. |

## Consequences

1. Keep the existing CM12 website-fidelity conclusion unchanged. These ten
   files do not supply a newer CM12 `prsdd` formula or source lineage.
2. Treat the `/home/arndt` source as materially different for non-CM12 runtime
   refresh work. In particular, `nn1.f`, `prsd.f`, and `pru.f` require
   engine-specific fixtures before choosing archive or production source.
3. Do not assume that the partial `/home/arndt64/said/epru.f` or modified
   `prux.f` built an active executable. Their path, content, and timestamps are
   evidence of drift, not source-to-binary provenance.
4. Preserve the `QLEGY`, `GROSSPHS`, `PROBS`, CM-dispatch, background, and
   u-channel findings as candidates for the stakeholder defect register if a
   retained workflow reaches them. No source fix is authorized by this diff.
5. Use `mkS.sh` only as historical dependency/build evidence. The modern
   reproducible scripts remain the build authority for verified work.

## Machine-readable inventory

`files.tsv` records every non-exact file, exact live/archive paths and hashes,
line metrics, classification, affected routines, and bounded relevance.
