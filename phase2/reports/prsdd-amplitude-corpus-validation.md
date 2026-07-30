# `prsdd` CM12 Walker-helicity-amplitude corpus validation

Generated: 2026-07-29T18:05:23Z

## Result

All 13 corpus cases completed with exit status 0 and the normal SAID
exit message on the modern headless build and both checked-in historical
executables. The 150 typed records, each containing four complex
amplitudes, are byte-identical across all three engines at the legacy program's
displayed precision. All stderr streams are empty except for the expected
modern IEEE underflow/denormal diagnostic on the finite `Wcm` sweep.

- Normal requests: 7
- Boundary requests: 3
- Malformed selections with legacy recovery: 2
- Legacy amplitude-choice coercion: 1
- Comparison SHA-256: `b7923b7d4f5f4182e82c7ab446cb2affe7bac733102af6484afbef3fed38addc`

The choice-zero, unknown-observable recovery, and invalid-reaction recovery
fixtures produce the same typed table as the valid baseline request. Silent
cosine and amplitude-choice clamping are recorded compatibility behavior; the
replacement API should reject those inputs.

## Release rule

The parsed amplitude records, not terminal transcripts, are the blocking
regression artifacts. Exact equality is required at the legacy one-decimal grid
and two-decimal amplitude precision until a higher-precision interface and
domain-approved tolerance policy exist.

## Immutable-seam follow-up

The CM12 immutable-loader compatibility build passes the same 13
cases and produces all 150 four-complex-amplitude records
byte-identically to the modern reference. Direct scalar evidence is recorded
separately in `cm12-seam-validation.md`.
