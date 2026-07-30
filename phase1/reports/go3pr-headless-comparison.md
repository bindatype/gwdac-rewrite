# CM12 headless-link comparison

Generated: 2026-07-29T13:28:25Z

## Result

The rendering and headless current-GFortran builds produce byte-identical
stdout and generated non-renderer artifacts when run with the CM12 no-render
deck. Both result tables also match the frozen historical-oracle table.

- Frozen result-table SHA-256: `80868398e786c36ff11ef6ef4388e7896fc867d69e319c843b1923d5819a86c3`
- Headless executable SHA-256: `958889882d91fce225c04bc18021725fec757bde6ea047df1bf93a4136c7aa4f`
- Headless executable size: `1080944` bytes
- ELF dependencies: `libgfortran.so.5,libm.so.6,libgcc_s.so.1,libc.so.6`
- Exit status: `0`; stderr: empty; parsed rows: `19`
- `SAID.TMP`, `SAID.PCT`, `SAID.LOG`, and `fort.7`: byte-identical
- `SAID.PS` and `fort.3`: not produced
- X11, Xt, GD, PNG, JPEG, font, PostScript converter, and transitive
  image-library code: absent from the headless link

## Contract

The original historical deck requests PostScript conversion with its final
`C` and `Y` responses. It remains the historical executable oracle. The
no-render deck ends at `GO99`, preserving the same scientific request while
excluding rendering from the contract. The frozen 19-row numerical table is
identical under both decks.

The headless ABI shim preserves SAID's transaction log and exit messages, but
intentionally disables drawing, cursor input, renderer control, mail-back, and
PostScript conversion. Plot equivalence is outside this target's contract.
