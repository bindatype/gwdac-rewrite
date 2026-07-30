# CM12 60-form candidate handoff

Date: 2026-07-30

Evidence label: captured for the candidate output and legacy replay; inferred
for the suspected remaining boundary. Physics/domain review remains pending.

## Status

This checkpoint is intentionally failing and is not an accepted PRBAS
replacement.

- The previously committed diagnostic proved that the 18 reaction-applicable
  non-1xx forms fully explain the displayed pion-plus, 1000 MeV, 90-degree
  discrepancy when the frozen multipoles are replayed.
- The candidate extends request orchestration to all 40 applicable forms in
  frozen family, branch, orbital-l order.
- The candidate's direct translation of forms 3, 21, and 25 does not reproduce
  the frozen multipoles: `exact_non_cm12_multipoles=0` of 18.
- The candidate target DSG is `2.69659853`; the oracle and exact legacy replay
  are `2.03560233`.
- The candidate target A1 is
  `(1.65152276,-5.49336576)`; the oracle and exact legacy replay are
  `(-10.2181225,-4.52479029)`.
- The absolute 24-fixture/288-record corpus gate has not been run for this
  failing candidate.

## Build state

The frozen `prsd.f` and `pru.f` source hashes were rechecked in the container:

```text
prsd.f 892ac95dff98595d1c4b3c14c01f1f6ef8273fa3ed1c68f36c5b16afe436790e
pru.f  462395fee5d67538e49ddbef24a9b0c292a63f6183da1cb56dff9d391dfa89ba
```

The diagnostic hadronic trace was split into
`phase2/kernel/cm12_prsd_hadronic_trace.patch`. Sequential zero-fuzz dry-runs
of `cm12_prsd_pure.patch` followed by that trace patch pass. The subsequent
full build was stopped for this handoff before completion.

## Next isolation point

Run the instrumented legacy target and compare each emitted
`CM12DIAG HADRONIC` row (`EPX`, `EPXX`, `TER`, `TEI`, `QCM`, and `ZKCM`) with
the values used by `cm12_non_cm12_seam.f90`. The leading hypothesis is an
unmapped legacy hadronic-input or energy-scaling boundary around
`PNPWI`/`PNSM05`; it is not yet confirmed.

Do not change orchestration again, alter fixtures or tolerances, decide formula
porting, or begin Phase 3 from this checkpoint.
