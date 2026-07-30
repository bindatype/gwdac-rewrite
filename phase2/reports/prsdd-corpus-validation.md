# `prsdd` CM12 contract-corpus validation

Generated: 2026-07-29T18:05:24Z

## Result

All 11 corpus cases completed with exit status 0 and the normal SAID
exit message on the modern headless build and both checked-in historical
executables. The 138 typed result records are byte-identical across all
three engines at the legacy program's displayed precision. Valid and recoverable
requests have empty stderr; the modern runtime reports expected IEEE exceptions
for the two retained defect-characterization cases.

- Normal requests: 6
- Boundary requests: 2
- Malformed selections with legacy recovery: 2
- Scientifically invalid below-threshold request: 1
- Comparison SHA-256: `aab9df253ca782994f51396002b3e426bcb079ce9bf7ac85b758e8ac60119d4a`

The oracle establishes behavioral correspondence, not physical correctness.
The below-threshold zero/NaN result, state corruption after an oversized grid,
and silent cosine clamping are recorded legacy behaviors that the replacement
API should reject explicitly unless stakeholder review requires compatibility.

## Release rule

The parsed typed tables, not terminal transcripts, are the blocking regression
artifacts. Exact equality is required at the legacy displayed precision until a
higher-precision oracle and domain-approved tolerance policy exist.

## Immutable-seam follow-up

The CM12 immutable-loader compatibility build passes the same 11
cases and produces all 138 typed records byte-identically to the
modern reference. Direct scalar evidence is recorded separately in
`cm12-seam-validation.md`.
