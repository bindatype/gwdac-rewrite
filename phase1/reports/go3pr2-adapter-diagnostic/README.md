# Offline production-adapter diagnostic

Date: 2026-08-03

Evidence classes:

- **oracle**: the accepted modern headless, checked-in arndt64, and checked-in
  GWDAC executable results;
- **captured**: the current public website token, live `go3pr2` delta, and
  byte-exact live `wtrim3` formatter;
- **reference**: the offline replay of the captured adapter sequence;
- **inferred**: statements about untraced internal state changed by `GO5`.

Physics/domain review remains pending.

## Result

The current website discrepancy is reproduced completely at displayed
precision by the live adapter's request priming. No newer formula, executable,
CM12 record, or KCM dataset is needed:

| Executable | Archived-style deck | Live `GO5`-primed deck | Captured website |
|---|---:|---:|---:|
| Modern headless | `0.2036E+01` | `0.2098E+01` | `0.2098E+01` |
| Checked-in arndt64 | `0.2036E+01` | `0.2098E+01` | `0.2098E+01` |
| Checked-in GWDAC | `0.2036E+01` | `0.2098E+01` | `0.2098E+01` |

The six runs exited zero and reached the normal SAID completion message. This
is a deterministic sequence effect across all three accepted executables, not
a tolerance adjustment or oracle change.

## Isolated difference

Both fixtures represent the captured public request:

```text
solution=CM12
reaction=PI+_N
observable=DSG
Acm=90 degrees
Elab=1000 MeV
data range=995..1005 MeV
```

The live fixture adds only the commands observed in production between
solution selection and `GO3`:

```text
Q
go5
100 -200
1
DSG
Q
```

Fixture hashes:

| Fixture | SHA-256 |
|---|---|
| `archived.in` | `8ccb1ef6c38c1a0c0401129de35bbabe8bb4405fb341dd9a7aef430a0e4c6e7e` |
| `live.in` | `22c693d850379b63804ff693e4cb5d716d5173a49b73a6813d654f56cc7db3d7` |

The final pre-`qt` record in each deck intentionally contains one space,
matching the wrapper's `echo " "`. The captured `wtrim3` also retains its
original trailing space on `while(<>)  { `. Consequently `git show --check`
reports those three provenance-preserving lines; they are not accidental
formatting debt and must not be normalized without changing the fixture and
capture hashes.

Executable hashes:

| Witness | SHA-256 |
|---|---|
| Modern `prsdd-headless` | `958889882d91fce225c04bc18021725fec757bde6ea047df1bf93a4136c7aa4f` |
| Checked-in arndt64 `prsdd` | `8a3c925a3aa95314fb4ad4fa7a8cbfa0095df898ee6fa96dad2071d20789678a` |
| Checked-in GWDAC `prsd` | `f37ba4e753fb1ff96081a9bc28a74e5fa667f70a93043efb6cf65bef94104aba` |

## Formatter isolation

The captured `wtrim3` has SHA-256
`86e15848e4d178b11a35aa671fb427932b9f0e95870bbd28a49374a5b14e98e3`.
It differs from archived `wtrim` only by selecting output after the third
`WEB` marker rather than the first. For all six runs, its output was
byte-identical to a parameterized section extractor. It exposes the later
`GO3` section; it does not calculate or alter `0.2098E+01`.

The exact internal state changed by `GO5` is not traced here. The supported
claim is narrower: executing the captured `GO5` sequence before the same
`GO3` request changes the later displayed DSG result on every accepted
executable.

## Runtime note

Only the modern headless live-deck run wrote to stderr:

```text
Note: The following floating-point exceptions are signalling: IEEE_UNDERFLOW_FLAG IEEE_DENORMAL
```

It still exited zero and reached normal completion. The note is captured in
`modern/modern-headless-live.stderr` with SHA-256
`cde5e7d17e64813704a51a756095eaf585d28601c664fa68a1f27038b6399fcc`.
No warning-driven source or runtime change was made.

## Reproduction

With the existing local containers and accepted Phase 1 build artifacts:

```sh
cd outputs/container-environment
docker compose exec -T dev env ADAPTER_DIAGNOSTIC_MODE=modern \
  /phase1/scripts/run-go3pr2-adapter-diagnostic
docker compose exec -T oracle env ADAPTER_DIAGNOSTIC_MODE=historical \
  /phase1/scripts/run-go3pr2-adapter-diagnostic
docker compose exec -T dev env ADAPTER_DIAGNOSTIC_MODE=compare \
  /phase1/scripts/run-go3pr2-adapter-diagnostic
```

Machine-readable results:

- `results.tsv`
- `comparison.tsv`
- `manifest.sha256`
- `captured-artifacts.sha256`

Per-mode result tables are retained under `modern/` and `historical/`.
Deterministically compressed raw stdout plus stderr and exit files for all six
runs are retained under `captured/`. The runner regenerates uncompressed
working files under the per-mode directories.

## Boundary

No production executable or CGI endpoint was run, and no production file was
changed. `RESUME` authorized this local diagnostic only; it never grants
production write, deployment, configuration, or execution authority.

The diagnostic resolves the mechanism for the captured website token at
displayed precision. It does not decide whether fresh-process `GO3` behavior
or public `GO5`-primed behavior is scientifically preferred, and it does not
authorize a compatibility change.
