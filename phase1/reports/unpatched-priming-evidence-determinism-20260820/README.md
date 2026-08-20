# Unpatched-priming evidence-determinism candidate

Date: 2026-08-20

Status: **candidate pass; not merged; evidence not adopted**

## Scope and provenance

This report records the isolated evidence-generator contract for the existing
unpatched GO3/GO5 priming measurement. The implementation is on branch
`codex/unpatched-priming-determinism` at
`e7578a4212135cfaa7d8ed9113116da92f55f5cf`, based on accepted evidence branch
checkpoint `7014a5a7486bb07f6c143938e4003a90337f7dc1`.

No frozen Fortran source, compatibility patch, fixture, tolerance, oracle,
accepted evidence file, production system, `main`, or `dev` reference changed.
The recorded engine exit `2` and failed compatibility status remain part of the
contract; this candidate does not convert them into a pass.

Evidence labels:

- **Captured:** two complete 10-file generated packages under
  `Pacific/Kiritimati` and `Etc/GMT+12`.
- **Reference:** the unchanged 11-entry committed unpatched-priming manifest;
  its README is checked but not generated.
- **Oracle:** the unchanged accepted patched priming stdout used for the
  witness-row and GO5-total comparison.
- **Inferred:** no physics approval; stakeholder review remains pending.

The retained local candidate workspace is:

```text
/var/folders/gj/_jywy_7d65x7p1zp14crb5_00000gp/T/gwdac-unpatched-priming-determinism-e7578a421213
```

It is supporting captured evidence, not a published or accepted package.

## Contract

`run-unpatched-priming-measurement` no longer writes its own manifest. The
caller supplies a disposable report root; a sorted 10-file inventory drives an
external manifest; an independent comparator checks the committed package; and
a pre/post full-file fingerprint rejects any write outside the candidate root.
The accepted patched stdout is injected as an explicit reference input rather
than assumed to exist below the writable report mount.

Five fixed-position run-date fields in `unpatched-priming.stdout` are the only
canonicalized bytes. The shared canonicalizer preserves file length, line
count, line lengths, protected solution tokens, and E-notation tokens. The
other nine generated artifacts permit no raw difference.

## Diagnostic checkpoints

Two fail-closed checkpoints preceded the passing run:

1. `422a3cb` stopped after build because isolation removed the implicit
   accepted-stdout path. Commit `e49b0f4` made that reference explicit.
2. `e49b0f4` stopped with 9 raw-exact files and one raw-different stdout. The
   difference was exactly five run-date fields. Commit `e7578a4` recorded that
   measured contract; no numerical or control-flow expectation changed.

Partial captures from both stopped runs were retained locally. Neither was
reported as a candidate pass.

## Command and result

```sh
UNPATCHED_PRIMING_KEEP_WORKSPACE=1 \
make reviewer-reproduce-unpatched-priming
```

The command exited 0 and reported `CANDIDATE PASS`.

Across the two date contexts:

- `unpatched-priming.stdout` differed raw at exactly five declared date fields;
- the other 9 generated artifacts were byte-identical;
- all 10 canonical artifacts were byte-identical;
- both canonical manifests matched the independently canonicalized committed
  package, with manifest SHA-256
  `dc6e477ccd3b38eb0f2965f2091c3004513d3d3d1a2f40b725f34865e26f2c4c`;
- each run compared with committed evidence as 9 raw-exact, 1 raw-different,
  0 candidate-only, and 1 reference-document-only file; and
- the candidate-root isolation fingerprint passed in both runs.

The raw dates were `8/21/26` in Kiritimati and `8/19/26` in GMT-12. The exact
file-level relation is in `two-run-comparison.tsv`.

Both runs retained the original behavioral result:

- witness row
  `90.000  0.2098E+01  0.0000E+00   58.15  0.2932E+01`;
- `Total Data= 1533 Chi2=   5563.03`;
- engine exit status `2`;
- no `Thanks for using SAID` marker;
- `PRRDX` end-of-file classification `yes`; and
- compatibility gate `fail`.

This is an evidence-determinism candidate only. It does not remediate the
unpatched engine abort, adopt regenerated evidence, or approve the physics.
