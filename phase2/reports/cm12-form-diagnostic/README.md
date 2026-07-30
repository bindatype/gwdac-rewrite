# CM12 form-count attribution

Evidence label: **reference**. Physics/domain review remains pending; this
diagnostic establishes implementation correspondence only.

## Scope

- Source commit: `f6c81d01a1fe8b007c247acc2213f821a62dc4f2`
- Solution: `CM12` from provenance-checked `sdat/prsol.dat`
- Solution SHA-256:
  `dbcaae30bbf44aca6e5482fc2b10b81cb6e1033cf41061bc089d5f6a85576522`
- Request: pion-plus, `Elab=1000 MeV`, `Acm=90 degrees`
- Instrumentation checkpoint: `a67e4ea`

## Finding

The form-count gap is sufficient to explain the failed request kernel at the
authorized displayed precision.

- The solution has 60 active forms: 34 1xx forms and 26 non-1xx forms.
- Pion-plus uses 40 forms: 22 1xx forms and 18 non-1xx forms. The remaining
  20 forms are channel skips, including 8 of the 26 non-1xx forms.
- All 22 applicable 1xx scalar multipoles match the frozen calculation
  exactly at single precision.
- All 40 applicable per-form amplitude deltas replay exactly in frozen
  `family -> branch -> orbital_l` order.
- Replaying all 40 applicable forms reproduces all eight final amplitude
  components exactly.
- The all-form replay produces `2.03560233`, displayed as the exact oracle
  token `0.2036E+01`.
- Omitting the 18 applicable non-1xx forms produces `6.59295416`, displayed
  as `0.6593E+01`, in both frozen and experimental accumulation orders.

The small component-level difference between the two 1xx-only accumulation
orders is therefore not needed to explain the displayed DSG failure. Any
candidate extension must nevertheless preserve frozen
`family -> branch -> orbital_l` order.

## Evidence

- `cm12-form-attribution.tsv`: all 60 active forms, classification,
  disposition, multipole equality, and per-form delta equality.
- `cm12-form-attribution-summary.txt`: counts, exact-equality results,
  amplitudes, and DSG values.
- `legacy-form-trace.tsv`: normalized 40-form frozen trace.
- `legacy-target-summary.tsv`: frozen initial and final amplitudes.
- `manifest.txt`: binary, source, solution, fixture, and evidence hashes.
- `legacy-corpus/`: the forced-legacy amplitude and DSG runs from which the
  normalized evidence was derived.

This diagnostic authorizes only the conditional all-form orchestration
extension. It does not accept PRBAS replacement, authorize formula porting,
or authorize Phase 3.
