# `pnsd` warning classification

Evidence label: **reference**

Source: `arndt64@f6c81d01a1fe8b007c247acc2213f821a62dc4f2`

Compiler: GNU Fortran 13.3.0 on Ubuntu 24.04 x86-64

The clean source build emits 633 warnings. No warning-driven source change was
made.

| Build area | Compatibility debt | Suspected defect | Confirmed defect | Total |
| --- | ---: | ---: | ---: | ---: |
| Local libraries | 6 | 2 | 0 | 8 |
| `pnsd` core | 503 | 36 | 27 | 566 |
| `gplot` | 55 | 4 | 0 | 59 |
| Total | 564 | 42 | 27 | 633 |

Compatibility debt comprises legacy scalar/array aliasing, Hollerith and
character storage transfer, deleted-feature labeled DO forms, and the retained
`gplot` BOZ and byte-width conventions. The 400 additional compatibility-debt
diagnostics are emitted because the `pnsd` main unit uses `-std=gnu` to restore
g77 A-editing semantics. Suspected defects comprise integer/real argument
mismatches and one extra actual argument. Confirmed defects comprise 24
declared-extent violations and three compile-time out-of-bounds references.

The compiler does not warn about the process-global formatted-input difference
at `pnu.f:4569`. The committed SP06 fixture now gates the narrow main-unit
compiler setting that restores the historical behavior. No Fortran source or
warning site was changed.
