# Phase 1 compiler warning register

Reference build: `arndt64@f6c81d01a1fe8b007c247acc2213f821a62dc4f2`  
Compiler: GNU Fortran 13.3.0 on Ubuntu 24.04 x86-64  
Classification date: 2026-07-29

The clean `prsdd` build emits 534 warnings: 8 while rebuilding the local
libraries, 467 in the nine core source files, 59 in the required `gplot`
closure, and none while linking.

| Class | Count | Meaning |
| --- | ---: | --- |
| Compatibility debt | 201 | Deliberate or likely legacy representation/calling behavior retained for the reference build |
| Suspected defect | 83 | Type or precision behavior that may change a scientific result and requires a focused fixture |
| Confirmed defect | 250 | A statically invalid interface extent or array index, even if the exercised path does not fail |

## Complete classification

| Build area | Count | Class | Emitted categories |
| --- | ---: | --- | --- |
| Local libraries | 4 | Compatibility debt | Scalar/rank-1 argument aliasing |
| Local libraries | 2 | Compatibility debt | Character/real and character/Hollerith storage transfer |
| Local libraries | 2 | Suspected defect | `REAL(4)`/`INTEGER(4)` argument mismatch |
| Core | 247 | Confirmed defect | Actual arrays shorter than declared dummy extents: `x`, `y`, `y2` are 143/200; `ntl` is 13/18 |
| Core | 134 | Compatibility debt | Scalar/array rank aliasing, including `ttl`, `h`, `w`, `title`, and `gth` |
| Core | 56 | Suspected defect | `REAL(8)` values passed to `REAL(4)` arguments `yp1` and `ypn` |
| Core | 21 | Suspected defect | `INTEGER(4)`/`REAL(4)` call mismatches, including `ntl` |
| Core | 6 | Compatibility debt | Hollerith, character, and numeric storage reinterpretation |
| Core | 3 | Confirmed defect | Compile-time out-of-bounds references: `prsd.f` uses element 16 of a 15-element array twice; `pru.f` uses element 8 of a 2-element array |
| `gplot` | 32 | Compatibility debt | One-byte/two-byte character and integer transfer through mismatched arguments |
| `gplot` | 23 | Compatibility debt | BOZ literals and nonstandard BOZ initialization/assignment |
| `gplot` | 2 | Suspected defect | `INTEGER(4)` values passed to `LOGICAL(1)` arguments |
| `gplot` | 1 | Suspected defect | `INTEGER(4)`/`REAL(4)` argument mismatch |
| `gplot` | 1 | Suspected defect | Missing alternate-return specifier |

The category counts above sum to every warning line in:

- `local-libraries-build.log`
- `prsdd-core-build.log`
- `gplot-build.log`
- `prsdd-link.log`

## pnpolw extension

The clean `pnpolw` build emits 140 warnings: 44 in `pnpolw.for`, 37 while
rebuilding `pnu`, `MOD01`, `saidopen`, and `libxz`, 59 in the same `gplot`
closure, and none while linking.

| Build area | Compatibility debt | Suspected defect | Confirmed defect | Total |
| --- | ---: | ---: | ---: | ---: |
| `pnpolw.for` | 27 | 10 | 7 | 44 |
| Scientific/support libraries | 25 | 11 | 1 | 37 |
| `gplot` | 55 | 4 | 0 | 59 |
| Total | 107 | 25 | 8 | 140 |

Compatibility debt is primarily scalar/array aliasing, Hollerith/character
storage transfer, and the existing `gplot` BOZ and byte-width conventions.
Suspected defects are integer/real and `ISYM` type mismatches. Confirmed defects
are declared-extent violations, one compile-time out-of-bounds loop, and an
inconsistent `SFIT` COMMON-block size.

The new category counts sum to every warning line in:

- `pnpolw-core-build.log`
- `pnpolw-libraries-build.log`
- `pnpolw-gplot-build.log`
- `pnpolw-link.log`

## `pnsd` extension

The clean `pnsd` build emits 633 warnings: 8 while rebuilding the local
libraries, 566 in `pnsd.f`, `pn1.f`, `pn2.f`, and `pnu.f`, 59 in the same
`gplot` closure, and none while linking.

| Build area | Compatibility debt | Suspected defect | Confirmed defect | Total |
| --- | ---: | ---: | ---: | ---: |
| Local libraries | 6 | 2 | 0 | 8 |
| `pnsd` core | 503 | 36 | 27 | 566 |
| `gplot` | 55 | 4 | 0 | 59 |
| Total | 564 | 42 | 27 | 633 |

The 400 additional compatibility-debt diagnostics are exposed by compiling the
`pnsd` main unit with `-std=gnu` to restore g77 A-editing behavior. The SP06
runtime fixture gates that setting and the exact historical artifact relation;
no source or warning-driven fix was attempted.

## Runtime-check finding

A disposable `-fcheck=all` build stops in `PNMOD` at `prsd.f:7953` because it
indexes `NFG(-1)` below the declared lower bound of 1. This is an additional
confirmed indexing defect, not one of the 534 normal-build warnings. The
checked build is diagnostic only and is not a numerical oracle.

## Handling rule

The reference build retains compatibility flags and does not broadly repair
these warnings. Each suspected or confirmed defect must receive a minimal
regression fixture before source changes are accepted. Compatibility-debt
warnings should be removed later by explicit interfaces and typed transfer
operations, with the committed command-deck outputs acting as regression
evidence.
