# GO5 evidence-determinism candidate

Date: 2026-08-13

Status: **candidate pass; not adopted**

## Scope and provenance

This report records the bounded GO5 evidence-determinism seam implemented at
`gwdac-rewrite@12e3c79`. No frozen Fortran source, physics routine, fixture,
tolerance, oracle, accepted evidence file, production system, `main`, or `dev`
reference changed.

Evidence labels:

- **Captured:** two complete candidate packages generated under
  `Pacific/Kiritimati` and `Etc/GMT+12`.
- **Reference:** the committed 64-file GO5 manifest at the implementation
  checkpoint.
- **Oracle:** checked-in historical `arndt64/said/prsdd`, SHA-256
  `8a3c925a3aa95314fb4ad4fa7a8cbfa0095df898ee6fa96dad2071d20789678a`.
- **Inferred:** no physics approval; stakeholder review remains pending.

The retained local candidate workspace is
`/tmp/gwdac-go5-determinism-12e3c79`. It is supporting captured evidence, not a
published or accepted package.

## Command

```sh
GO5_CANDIDATE_WORKSPACE=/tmp/gwdac-go5-determinism-12e3c79 \
GO5_KEEP_WORKSPACE=1 \
make reviewer-reproduce-go5
```

The command exited 0 and reported `CANDIDATE PASS`.

## Result

Each run rebuilt the accepted binary and all four diagnostic variants in fresh,
case-sensitive Docker volumes. Both runs reproduced these retained witnesses:

- accepted patched binary SHA-256
  `958889882d91fce225c04bc18021725fec757bde6ea047df1bf93a4136c7aa4f`;
- accepted priming observable `0.2098E+01` and total data `1533`;
- accepted and fresh-patched database total data `204`;
- repeated unpatched and historical database total data `238`;
- all seven modern cases and the historical executable exited 0.

The explicit package inventory contains 69 files, including all seven
`build-unpatched/` provenance files. The generators no longer write their own
manifest. Candidate manifests are outside the packages and are compared by a
separate command with the unchanged committed reference manifest.

Across the two date contexts:

- 9 modern date-bearing raw files differed;
- 2 historical date-bearing raw files remained exact because the checked-in
  executable does not follow `TZ`;
- 3 raw historical comparison artifacts differed and were re-derived from
  canonical inputs;
- 55 other raw files were byte-identical;
- all 69 canonical package files were byte-identical;
- canonical manifest SHA-256 was
  `b9ac7f8639165a2dca6d9547f87673eada95d0a7d2166efdc7712dd6fa8518ce`
  in both runs.

The canonicalizer made exactly 35 fixed-position substitutions per run. It
preserved the static `08/18/14` solution date, `07/09` entry date, `CHI/DP=`,
`Chi,M=`, and E-notation tokens. The complete file-level relation is in
`two-run-comparison.tsv`.

## Isolation and review state

The authoritative checkout was fingerprinted before, during, and after the
run. Its 2,360-file fingerprint remained SHA-256
`ead1ccdffb440c7f1ea4db77cec15df1897f38008279dc9f48179bea1b28d2e3`.
`reviewer-verify` passed all 11 registered pre-report packages plus the 138 DSG
and 150 amplitude records across the modern, arndt64, and GWDAC engines.

Candidate A compared with committed evidence as 41 raw-exact, 21
raw-different, 7 explicit candidate-only, and 2 reference-document-only files.
Candidate B was 40, 22, 7, and 2 respectively. These differences are reported,
not accepted. No candidate output was copied into the accepted GO5 package.

This checkpoint proves the GO5 contract pattern only. Per the huddle decision,
the same candidate-root, explicit-inventory, independent-comparator contract is
required for the other four self-manifesting generators before `PACKAGE`
acceptance. That rollout is not part of this implementation slice.
