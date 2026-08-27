# Shared Checkpoint 3A.1 pdsd measurement

Evidence label: **captured** for raw execution products and **inferred** for the
field classifications derived from their direct diffs. Physics review remains
pending.

This package uses the shared engine-parameterized Checkpoint 3A primitive at
outputs commit 0ed942172a2b828f3368cf0687cb27bc8c5985c5. It measures only the
pdsd startup/quit control. The unchanged dev and oracle images were each
verified to honor POSIX UTC-14 (+1400) and UTC+12 (-1200), with distinct civil
dates, before any engine build or execution. Requested and observed contexts,
image identities, and container identities are recorded in
context-preflight.tsv and each runtime operator/context.tsv.

The modern engine was built twice in independent roots. Historical and modern
executions were captured independently and packaged before any compatibility
comparison. The engine files under raw/build-* and
raw/runtime/*/{historical,modern} are unmodified captures; derived relation
tables sit beside them. No canonical copy or normalization exists.

Direct diffs found one volatile build metadata field: the random build-root
suffix in build/manifest.txt. The executable and all other build files were
exact. Historical and modern runtime packages were each exact across the two
effective timezone contexts, and each historical/modern pair retained the
exact startup/quit relation. Protected inputs were byte-identical before and
after execution.

This corrected package supersedes local candidate f96abae without rewriting or
deleting that audit commit. It is a 3A measurement result, not a canonicalizer,
Checkpoint 3B acceptance, physics approval, or Gate 1 registration of this
package.
