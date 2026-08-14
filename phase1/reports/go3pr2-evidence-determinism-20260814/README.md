# GO3PR2 evidence-determinism candidate

Date: 2026-08-14

Status: **candidate pass; not merged; evidence not adopted**

## Scope and provenance

This report records the first post-GO5 application of the isolated evidence
generator contract. The implementation is on branch
`codex/evidence-contract-rollout` at
`18bb3eaf005c2bd456bf76b3d038444fdf69a7b3`. No frozen Fortran source,
physics routine, fixture, tolerance, oracle, accepted evidence file, production
system, `main`, or accepted GO3PR2 package changed.

Evidence labels:

- **Captured:** two complete 34-file candidate packages generated under
  `Pacific/Kiritimati` and `Etc/GMT+12`.
- **Reference:** the unchanged committed GO3PR2 package and five-entry manifest.
- **Oracle:** the accepted modern headless, checked-in arndt64, and checked-in
  GWDAC executable results.
- **Inferred:** no physics approval; stakeholder review remains pending.

The retained local candidate workspace is
`/tmp/gwdac-go3pr2-determinism-18bb3ea`. It is supporting captured evidence,
not a published or accepted package.

## Contract

`run-go3pr2-adapter-diagnostic` no longer writes its own `manifest.sha256`.
The caller supplies a disposable report root; a sorted 34-file allowlist drives
an external manifest; the committed expectation is read and checked by a
separate comparator; and a pre/post full-file fingerprint rejects any write
outside the candidate root. Runtime scratch remains in disposable Docker
volumes.

Raw captures are retained unchanged. The shared position-anchored canonicalizer
uses the eight-character `<RUN_DT>` token and rejects any change in file length,
line count, individual line length, protected solution tokens, or E-notation
tokens.

## Diagnostic correction

The first full run at `6bd8c5c` stopped because four modern `.formatted` and
`.section` files still contained copied display dates. Their canonical hashes
differed even though their source stdout was already canonical-exact.

The date-field audit found the same copied fields in eight historical formatter
artifacts. Commit `18bb3eaf005c2bd456bf76b3d038444fdf69a7b3` added all 12
omitted artifacts to the explicit date contract, rather than patching only the
four observed failures. Reprocessing the retained raw packages passed before
the full clean run was repeated.

## Command and result

```sh
GO3PR2_CANDIDATE_WORKSPACE=/tmp/gwdac-go3pr2-determinism-18bb3ea \
GO3PR2_KEEP_WORKSPACE=1 \
make reviewer-reproduce-go3pr2
```

The command exited 0 and reported `CANDIDATE PASS`. Each run contained 34 raw
and 34 canonical files and exactly 51 fixed-position substitutions.

Across the two date contexts:

- 6 modern date-bearing artifacts differed raw;
- 12 historical date-bearing artifacts remained exact because both checked-in
  executables ignored `TZ`;
- 16 non-date artifacts were byte-identical;
- all 34 canonical package files were byte-identical.

The canonical manifest file SHA-256 was
`5f7d3723738bc4bac949ab4ee9c20c138b581227146f85fbe9aa3aff35ea20cb`
in both runs. The complete relation is in `two-run-comparison.tsv`.

Both runs retained these displayed-precision witnesses across all three
executables:

- archived observable `0.2036E+01`;
- live and captured-website observable `0.2098E+01`;
- modern binary `958889882d91fce225c04bc18021725fec757bde6ea047df1bf93a4136c7aa4f`;
- arndt64 binary `8a3c925a3aa95314fb4ad4fa7a8cbfa0095df898ee6fa96dad2071d20789678a`;
- GWDAC binary `f37ba4e753fb1ff96081a9bc28a74e5fa667f70a93043efb6cf65bef94104aba`.

The independent comparison reported 2 committed result files exact, 0
different, 32 explicit candidate-only files, and 3 reference-only fixtures in
each run. Those candidate-only files are reported, not adopted.
