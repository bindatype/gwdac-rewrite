# `/PRSC/` shared-state map

Date: 2026-07-29  
Canonical source: `bindatype/arndt64`, commit
`f6c81d01a1fe8b007c247acc2213f821a62dc4f2`  
Active source scope: `said/prsd.f`, `said/prsd2.f`, and `said/cmmwp.f`

## Result

The active program has 43 `/PRSC/` declarations: 31 in `prsd.f`, 11 in
`prsd2.f`, and one in `cmmwp.f`. Every declaration has the same ordered 60
members, dimensions, and normalized signature:

`5b12d7063b2b7daac59fbf94350ae82be828843893501c2062c6cbc095f6df46`

Under the ABI used by the frozen builds, the block occupies 22,370 four-byte
words, or 89,480 bytes. Offsets in `prsc-field-map.tsv` are zero-based and
assume that ABI. They document the legacy layout; they are not a proposed
serialization format.

The complete machine-readable maps are:

- `prsc-field-map.tsv`: ordered fields, offsets, implicit types, packed-text
  encoding, dimensions, semantic group, CM12 relevance, and target owner.
- `prsc-declaration-map.tsv`: every active declaration and its layout
  assertion.
- `prsc-routine-map.tsv`: each declaring routine and its referenced, written,
  call-argument, read, and declaration-only fields.
- `prsc-usage-map.tsv`: source-line lexical evidence for every field used by
  every declaring routine.

Archived and alternate sources such as `prsd03.f` and `prsd2x.f` are
historical evidence, not active declarations, and are intentionally excluded.

## Storage decomposition

| Semantic group | Fields | Bytes | Replacement disposition |
| --- | ---: | ---: | --- |
| Multipole solution grids | 2 | 40,320 | Remove from scalar kernel; return typed multipoles |
| Uncertainty state | 6 | 29,980 | Separate optional uncertainty component |
| Solution definition | 5 | 7,924 | Immutable `CM12Solution` |
| Experimental data | 5 | 5,600 | Outside the contracted calculation |
| Amplitude workspace | 5 | 2,432 | Scalar typed intermediates/results |
| Kinematics | 6 | 1,524 | Typed request and calculated kinematics |
| Packed A4 text | 6 | 420 | Decode at the loader boundary |
| Observable workspace | 2 | 400 | Scalar result plus optional batch adapter |
| Fit control | 3 | 404 | Outside the first pure kernel |
| Generic scratch | 1 | 400 | Delete |
| Grid indices and controls | 14 | 56 | Local loop variables or validated request fields |
| Command control | 3 | 12 | Legacy adapter only |
| Multipole workspace | 2 | 8 | Scalar typed result |

By target relevance, 15 fields are required inputs or outputs (9,212 bytes),
12 are internal legacy intermediates (40,792 bytes), nine belong only in a
batch/compatibility adapter (2,728 bytes), nine belong to optional uncertainty
work (30,384 bytes), and 15 are excluded from the retained kernel (6,364
bytes).

The six text arrays are not numeric despite their implicit types. `TITLE`,
`DTTL`, `TTLI`, and `HDAT` store packed A4 words in `REAL*4` slots; `MTTL` and
`ITTL` store packed A4 words in `INTEGER*4` slots. A replacement must decode
them once and must not expose their binary representation.

## Retained CM12 path

The contracted amplitude and DSG behavior crosses these `/PRSC/` routines:

| Routine | Source line | Role | Principal `/PRSC/` state |
| --- | ---: | --- | --- |
| main program | `prsd.f:1` | Parses the legacy deck, loads a solution, invokes `PRBAS`, and formats choice-1 amplitudes or observables | Request grids, solution metadata, `HR`/`HI`, `OBS` |
| `SETEK` | `prsd.f:1281` | Selects reaction metadata and channel offsets | `IR`, `IR0`, `CIS`, `NMTTL` |
| `PRSOL` | `prsd.f:1795` | Reads and dispatches a legacy solution | `TITLE`, `NF`, `PEM`, `NNL`, fit/uncertainty arrays |
| `PRBAS` | `prsd.f:1349` | Computes kinematics, evaluates all retained multipoles, accumulates amplitudes, and invokes the observable calculation | `E`, `A`, `NF`, `PEM`, `EMR`/`EMI`, `HR`/`HI`, `HRX`/`HIX`, `ETHR` |
| `PRDLT` | `prsd.f:2314` | Dispatches one multipole evaluation; form numbers 101-199 call `cmmwp` | `MM`, `JJ`, `LL`, `E(IE)`, `NF`, `PEM`, `DER`, `DEI` |
| `cmmwp` | `cmmwp.f:2` | Adapts a CM12 multipole request to `ys`/`ysKCM` | `E(IE)`, `NF`, one `PEM` slice, `DER`, `DEI` |
| `PRDA` | `prsd.f:4970` | Adds one complex multipole to four Walker/VPI-SU helicity amplitudes | `DER`, `DEI`, `CIS`, `CH`, `BAS`, `HRX`, `HIX` |
| `PROBS` | `prsd.f:1492` | Calculates DSG and other observables from the active amplitudes | `HRX`, `HIX`, `QCM`, `ZKCM`, `ETHR`, `IT`, `OBSPRD` |

For contracted DSG (`IT=1`), the essential `PROBS` relation is

```text
DSG = (QCM / ZKCM) * sum(k=1..4, HRX(k)^2 + HIX(k)^2) / 200
```

subject to the legacy threshold and zero-amplitude branches already captured
by the DSG contract corpus.

## State that `/PRSC/` does not reveal

Removing this COMMON block alone would not produce a pure calculation:

| Legacy state | Relevant behavior | Required treatment |
| --- | --- | --- |
| `/GOMEGA/` | `HOPEC` and `PROPEC` consume the pion coupling/form-factor values in the background contribution used by `PRBAS` | Put reviewed background constants in immutable solution/configuration data |
| `/solnform/` | `cmmwp` copies `NF` into `nfmp` only on its first invocation | Store form selectors in `CM12Solution`; remove first-call mutation |
| `/psol/`, `/tgrid/`, `/cmmgrid/` | `ysKCM` holds file-loaded hadronic and K-matrix grids | Load a checksummed immutable `CM12Dataset` before evaluation |
| `SAVE` variables in `PRBAS`, `PRDLT`, `PRDA`, `cmmwp`, and `ysKCM` | Cache initialization, prior angles, and prior kinematic values | Make caches immutable/precomputed or request-local; no order-dependent results |
| File units and current directory | `ysKCM` discovers and reads the surviving KCM tables | Manifest-driven loader with explicit paths and provenance |

`/PRKC/` and `/PGLOB/` are visible in the generic `PRDLT` dispatcher but are
not inputs to its early CM12 101-199 branch. They remain outside the first
CM12 kernel unless a fixture demonstrates otherwise.

## Access-map interpretation

The usage reports are conservative lexical maps, not interprocedural
data-flow proofs:

- `direct-write` is a field on an assignment left-hand side or in a `DATA`
  initialization.
- `io-input` is a field targeted by a `READ`.
- `call-argument` means a field is passed to a subprogram whose intent is
  implicit and may mutate it.
- `read-or-control` includes expression, branch, array-index, and output-I/O
  use.
- A field absent from a routine body is `declaration-only` even though every
  routine reserves the entire COMMON layout.

The maps should guide extraction and test placement. They do not justify
changing scientific formulas without stakeholder review.

## Extraction conclusion

Do not reproduce `/PRSC/` as a large struct. The first replacement slice
should load immutable solution and dataset objects, evaluate one scalar
kinematic point, return four complex amplitudes, and calculate DSG from those
amplitudes. Grid construction, transcript formatting, fit state, uncertainty
propagation, experiment tables, and plotting belong in separate adapters or
later components.

The computational fields in that conclusion are now extracted.
`CM12Dataset` and `CM12Solution` replace KCM and solution-definition state;
the scalar multipole, four-amplitude accumulation, and DSG operations use no
COMMON state, saved initialization, or file I/O. The background seam exposes
immutable constants and explicit Born/OPEC/HOPEC outputs while retaining the
legacy formulas behind the seam.

The compatibility process still uses `/PRSC/` for command parsing, grid
iteration, kinematic work arrays, transcript behavior, and one preserved
malformed-input fallback. It is an oracle adapter, not the target API. The
remaining extraction boundary is pure single-request orchestration in place
of `PRBAS`; work is paused until `RESUME`.
