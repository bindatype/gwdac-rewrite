# Choice-1 amplitude to DSG consistency

Generated: 2026-07-29T16:04:35Z

The nine shared CM12 `pi+n`, 1000 MeV angle points satisfy the canonical
`PROBS` relation:

`DSG = (q_cm / k_cm) * sum(|A_i|^2) / 200`

using the masses and kinematics in `PRBAS`. Because the amplitude transcript
rounds every real and imaginary component to 0.01 mFm, this is a
rounding-bounded consistency test rather than an exact equality test.

- Maximum absolute difference: `0.001646790`
- Minimum remaining rounding margin: `0.001735811`
- Consistency table SHA-256: `09bb11d71de8283b31042d6d4b3b8351c3e5b3f5d03bdd6cbe1be59a65b79eef`
- Result: every difference is within the bound implied by component and final
  DSG display rounding.

This confirms that the frozen choice-1 records are the amplitude values consumed
by the existing DSG path at the observable precision available from the legacy
text interface. It does not independently validate the physical normalization.

The immutable-loader seam reproduces both source tables byte-for-byte, so this
rounding-bounded invariant is unchanged for the seam build.
