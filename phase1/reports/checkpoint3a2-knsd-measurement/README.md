# Shared Checkpoint 3A.2 knsd measurement

Evidence label: **captured** for raw execution products and **inferred** for the
field classifications derived from their direct diffs. Physics review remains
pending.

This package uses the shared engine-parameterized Checkpoint 3A primitive at
outputs commit 2f6ede488a64711c88879e5dff0c80bb93f42d91. It measures only the
knsd startup/quit control. The unchanged dev and oracle images were each
verified to honor POSIX UTC-14 (+1400) and UTC+12 (-1200), with distinct civil
dates, before any engine build or execution. Requested and observed contexts,
image identities, and container identities are recorded in
context-preflight.tsv and each runtime operator/context.tsv.

The modern engine was built twice in independent roots. Historical and modern
executions were captured independently and packaged before any compatibility
comparison. The engine files under raw/build-* and
raw/runtime/*/{historical,modern} are unmodified captures; derived relation
tables sit beside them. No canonical copy or normalization exists.

Direct diffs attributed the random build-root suffix in build/manifest.txt to
execution metadata; the executable and all other build files were exact.
Each historical/modern stdout pair differed only in configured data-root display fields; no other bytes differed. Cross-context differences were confined to measured execution-date fields and the directly bound hashes of those artifacts; unchanged date-shaped fields remain protected scientific identity. Protected inputs were byte-identical before
and after execution.

This is a 3A measurement result, not a canonicalizer, Checkpoint 3B acceptance,
physics approval, or Gate 1 registration of this package.
