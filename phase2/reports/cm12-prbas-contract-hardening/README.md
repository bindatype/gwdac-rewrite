# CM12 PRBAS negative-contract hardening

Evidence label: **reference candidate**. This package validates candidate API
contracts and retained focused checks; it does not accept or publish the PRBAS
replacement and does not establish physics correctness.

## Scope

This bounded hardening pass makes the components of
`cm12_background_grid_state` private and adds one public-API probe. Callers can
construct, retain, and pass the typed state, but only `cm12_non_cm12_seam` can
read or mutate its initialization, reaction, solution-hash, or dispatch fields.

The probe checks four transitions:

1. A non-printable formula title is rejected with `cm12_invalid_argument` and
   the exact documented message.
2. A fresh grid state initializes successfully for reaction 2 at 200 MeV.
3. Reusing that state for reaction 1 is rejected with
   `cm12_invalid_argument` and the exact provenance message.
4. The rejected call does not corrupt the state: reaction 2 reuses it
   successfully at 300 MeV.

The public rejection predicate binds both reaction and solution SHA-256. This
probe directly exercises the reaction-mismatch branch of that predicate; it
does not fabricate a second CM12 solution merely to force a hash mismatch.

Frozen formula routines, scientific fixtures, expectations, and oracles were
not changed. No COMMON block, SAVE state, filesystem state, or CGI input was
added.

## Result

The host Fortran 2008 compilation passed. Its only diagnostics were the known
macOS clang deployment-target warnings; no warning-driven source correction
was made.

The focused build passed under Ubuntu 24.04.4 LTS, GNU Fortran 13.3.0, and
x86_64. `negative-contracts.tsv` contains all four expected rows and exact
status/message pairs. The retained focused request-orchestration, 18-row
hadronic-dispatch, and 40-form contribution outputs are byte-identical to the
preceding grid-state candidate package.

The full 24-fixture corpus was not run.

## Provenance

The authoritative checkout remains based on
`22493c500c5d84b6ffb2453f834edeced8442071`; the candidate is uncommitted. The
pinned container's `/workspace` archive reports source commit
`f6c81d01a1fe8b007c247acc2213f821a62dc4f2`, while the active seam source and
script are bind-mounted from this checkout. `source-scope.sha256` binds those
candidate files explicitly, and `build-manifest.txt` binds the compiled probe
and generated outputs.

## Gate

This is a bounded candidate hardening pass, not acceptance. No full corpus,
commit, integration, push, production access, formula port, frontend work,
`pdesd`, or Phase 3 work occurred. Pause before full-corpus authorization.
