# SAID compatibility defect register

Date established: 2026-08-03

This register records deployed behavior that may be scientifically incorrect
but is relevant to reproducing the public SAID website. A registered item is
not a scientific finding or an approved correction. Physics/domain review is
pending unless an entry says otherwise.

## SAID-DEFECT-001: request-history-dependent CM12 pion-plus DSG

| Field | Value |
|---|---|
| Status | Preserved compatibility behavior; stakeholder disposition pending |
| Evidence class | **captured/oracle/reference** for the displayed values; **inferred** for the untraced internal state mutation |
| Public compatibility target | `public-go3pr2-v1` |
| Scope | CM12, `PI+_N`, DSG, `Elab=1000 MeV`, `Acm=90 degrees`, data range `995..1005 MeV` |
| Website-fidelity token | `0.2098E+01` after the deployed `GO5` priming sequence |
| Engine-level token | `0.2036E+01` from fresh-process `GO3` |
| Scientific approval | None |

### Observed behavior

The captured public `go3pr2` adapter executes this sequence after selecting
the solution and before its later `GO3` request:

```text
Q
go5
100 -200
1
DSG
Q
```

The modern headless executable, checked-in arndt64 executable, and checked-in
GWDAC executable all display `0.2036E+01` for the fresh-process request and
`0.2098E+01` for the `GO5`-primed request. The captured website also displays
`0.2098E+01`. All six offline runs exited zero and reached normal SAID
completion.

The captured `wtrim3` formatter selects the third `WEB` section. It exposes
the later value but does not calculate or alter it. The exact global state
changed by `GO5` has not been traced.

### Compatibility decision

`public-go3pr2-v1` names the end-to-end website-fidelity target and therefore
preserves the deployed displayed token `0.2098E+01`. Fresh-process `GO3` and
its `0.2036E+01` token remain a separate engine-level contract. Neither value
is declared scientifically correct by this decision.

No kernel, probe, `STOP 6` target, Phase 2 contract, accepted fixture, or
tolerance was changed when this entry was established. A corrected variant,
if stakeholders approve one later, must be separately named and tested. If
preserving this behavior becomes a concrete modernization blocker, work stops
at that boundary for an explicit decision rather than silently correcting the
behavior or freezing the entire project.

### Evidence and provenance

Repository state establishing this entry: `dev@619fa494d44005f4ae2161b2b29ecc4116166783`.

| Evidence | SHA-256 |
|---|---|
| `phase1/reports/go3pr2-adapter-diagnostic/README.md` | `14b9c1a9ca4f199ea12f9cc6468151e5485383c746df8d10db9912d3d30ba8e6` |
| `phase1/reports/go3pr2-adapter-diagnostic/comparison.tsv` | `0882fdebcba19765071a2953190bdab9fc6c191c6c5bd0589df30fff78d36cf5` |
| `phase1/reports/go3pr2-adapter-diagnostic/results.tsv` | `559e2f0c19a27ed03bd32f836ee53be26b38be64cde5ff35ac28e2a3a2336bb0` |
| `phase1/reports/go3pr2-adapter-diagnostic/manifest.sha256` | `8537af9f579817a34edba7899c1e9d7812860a5e9830285d8a44b7e30c50ff7c` |
| `phase2/reports/live-said-website-investigation/README.md` | `c252049c4ce2c0bf128c53dc0a8e7c3c6e8488e66668fd48bc460505b5722974` |

The offline reproduction commands and fixture/executable hashes are recorded
in `phase1/reports/go3pr2-adapter-diagnostic/README.md`. Production was not
contacted or executed to create this register entry.
