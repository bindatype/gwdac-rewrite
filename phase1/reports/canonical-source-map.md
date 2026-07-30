# Canonical SAID source map

Audit basis: `arndt64@f6c81d01a1fe8b007c247acc2213f821a62dc4f2`  
Audit date: 2026-07-29

## Decision

Use `said/` as the canonical active SAID source tree.

`said_old/` is not an independent old lineage: all 300 files are byte-identical
to `said/`. `said_bkp/` is a close predecessor with 297 files. Its only
top-level Fortran source difference is the older `pru.f`; its other differences
are the Makefile and generated objects/executables.

Do not merge archive variants into the baseline. Preserve them as historical
evidence and consult them only when a retained workflow or regression isolates
a behavior absent from the canonical tree.

## File level

The union contains 301 paths: 278 are identical across all three trees and 23
match between `said/` and `said_old/` while differing or being absent in
`said_bkp/`. No path differs between `said/` and `said_old/`.

| Evidence | File result | Behavioral relevance |
| --- | --- | --- |
| `said/` vs `said_old/` | Entire 300-file trees are byte-identical | None; `said_old` is a redundant mirror |
| Top-level Fortran across all trees | 45 of 46 files are identical; only `pru.f` differs in `said_bkp` | High for `pru.f`; none for the other 45 |
| `said/Makefile` vs backup | `g77` becomes `gfortran`; `pn1.o` becomes `pn1x.o` | High for build provenance, indirect for scientific behavior |
| Generated `.o`, `.a`, and executables | Compiler/build-product identities differ; several products are absent in the backup | Not canonical source |
| `said.tar.gz` | Same tarball in all trees; contains 20 Fortran files | Historical snapshot |
| `code-archive/` | Same two dated files in all trees | Historical source evidence |
| `mk-archive/` | Same nine old build files in all trees | Historical build evidence |
| `saidi/` | Same 11-file alternate interactive/open layer in all trees | Alternate infrastructure, not canonical compute |

The machine-readable file map, including SHA-256 identities and relevance
classification, is `canonical-source-file-map.tsv`.

## Routine level

The active map indexes 1,230 program units/routines from the 46 top-level
Fortran files. Only two routine bodies differ:

| File | Routine | Current change | Relevance |
| --- | --- | --- | --- |
| `pru.f` | `QLEG` | Declares `QLEGY` as `REAL*8` before calling it | High: fixes the caller-side return ABI/type |
| `pru.f` | `QLEGY` | Changes `FUNCTION QLEGY` to `REAL*8 FUNCTION QLEGY` | High: fixes the function return type |

Without those declarations, implicit typing makes `QLEGY` single precision at
the call boundary despite the routine calculating a double-precision result.
The current `said/pru.f` is therefore the stronger canonical source. The
tarball `pru.f` and `said_bkp/pru.f` are byte-identical predecessors.

The complete routine map is `canonical-source-routine-map.tsv`.

## Archive level

The three tarball files that differ from current source connect directly to
other retained variants:

| Archive candidate | Relationship to current | Routine delta |
| --- | --- | --- |
| `said.tar.gz/nn1.f` | Byte-identical to `code-archive/nn1.f-orig-2011.02.24` | `SOLNN` and `GROSSPHS` changed; 34 routines identical |
| `said.tar.gz/prsd.f` | Byte-identical to `code-archive/prsd.f-2011.03.11-orig` | 21 changed, 51 identical, `SANDSCL` archive-only |
| `said.tar.gz/pru.f` | Byte-identical to `said_bkp/pru.f` | Only `QLEG` and `QLEGY` changed; 103 routines identical |
| `cmmwp.f-110401` | Localized predecessor | One changed and one identical program unit |
| `prsd03.f` | Broad older generation | 21 changed, 26 identical, 25 current-only routines |
| `pru03.f` | Broad older generation | 66 changed, 29 identical, 10 current-only, 2 archive-only routines |

The remaining 17 Fortran files in `said.tar.gz` are byte-identical to their
current counterparts. The full archive routine map is
`canonical-source-archive-routine-map.tsv`.

## pnpolw lineage

`pnpolw` is outside the three SAID trees. Its reproducible source lineage is:

- `webplt/pnpolw.for` for the web pole engine;
- `said/pnu.f` for pion-nucleon scientific support;
- root `mod01.for` for the fitting/model engine;
- `said/saidopen.for` and root `libxzl.for` for shared support; and
- the source-built 145-member `gplot` closure.

That selection is behaviorally supported: the modern source build and the
checked-in `webplt/pnpolw` executable emit byte-identical normalized
`PNPOL.PCT` and exact `PNPOL.TMP` for the retained fixture. The distinct GWDAC
binary asks for an additional grid count and is retained as a separate
deployment lineage.

## Operating rule

New reference builds must name every source file and patch explicitly, never
consume checked-in objects or archives, and add an archive variant only after a
fixture demonstrates a required behavior that current canonical source lacks.
