# `pnsd` warning classification

Evidence label: **reference**

Source: `arndt64@f6c81d01a1fe8b007c247acc2213f821a62dc4f2`

Compiler: GNU Fortran 13.3.0 on Ubuntu 24.04 x86-64

The clean source build emits 233 warnings. No warning-driven source change was
made.

| Build area | Compatibility debt | Suspected defect | Confirmed defect | Total |
| --- | ---: | ---: | ---: | ---: |
| Local libraries | 6 | 2 | 0 | 8 |
| `pnsd` core | 103 | 36 | 27 | 166 |
| `gplot` | 55 | 4 | 0 | 59 |
| Total | 164 | 42 | 27 | 233 |

Compatibility debt comprises legacy scalar/array aliasing, Hollerith and
character storage transfer, and the retained `gplot` BOZ and byte-width
conventions. Suspected defects comprise integer/real argument mismatches and
one extra actual argument. Confirmed defects comprise 24 declared-extent
violations and three compile-time out-of-bounds references.

The normal build does not warn about the internal formatted read at
`pnu.f:4569`. The committed SP06 runtime fixture exposes that separate
compatibility defect: modern libgfortran stops with an end-of-file error
after producing the seven requested DSG rows, while the historical executable
continues and exits normally. This report records the defect; it does not fix
it.
