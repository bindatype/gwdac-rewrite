# Reviewer harness

The reviewer harness separates two operations that must not be conflated:

1. `verify-committed-evidence` reads and hashes committed evidence without
	invoking Docker, compilers, legacy executables, or generators.
2. `reproduce-evidence` clones the exact reviewed commit into a temporary
   workspace and runs generators only there. The authoritative checkout is
   fingerprinted before and after the run.

Neither command changes physics source, fixtures, tolerances, or oracle output.

`verify-committed-evidence` passes when the reviewed commit is checked out
cleanly. It also compares each tracked evidence file with its committed object,
so a checkout with a locally modified evidence file returns exit 10 by design;
that result identifies working-tree drift rather than a defect in the published
commit. Every invocation must provide the expected full commit ID. The verifier
compares it with `HEAD` and includes the commit in both its opening identity and
final result; missing and mismatched identities return exit 10 before evidence
verification. Before reporting a pass, the verifier also proves that its own
script, exit contract, and manifest configuration match that same commit.

## Commands

From the repository root:

```sh
make reviewer-verify
make reviewer-verify-gate-identity
make reviewer-verify-runtime-refresh-contract
make reviewer-verify-evidence-sort-policy
make reviewer-verify-cm12-harness-contract
make reviewer-reproduce
```

The gate-identity fixture proves that missing and mismatched expected commits
are rejected and that the rejection record is itself bound to actual `HEAD`.
The runtime-refresh contract fixture proves the aggregate writer is
locale-independent and byte-identical to the committed artifact. It then creates
a disposable commit whose `pnsd` checkpoint is stale while its summary and every
dependent hash are internally consistent; Gate 1 must reject that commit by
comparing the registered package state with the checkpoint tree.

`reviewer/config/runtime-refresh-packages.tsv` is the single machine-readable
source for engine manifests and full package checkpoint IDs. The aggregate
writer reads that registry, and Gate 1 independently validates its order,
checkpoint semantics, summary short IDs, and all package hashes. Regenerate the
aggregate only through:

```sh
make reviewer-write-runtime-refresh-aggregate
```

Evidence-producing shell pipelines pin collation directly as
`LC_ALL=C sort`. `reviewer/verify-evidence-sort-policy` checks every tracked
Bash script under `phase1/scripts`; its fixture proves that an unpinned pipeline
can reorder unchanged path/hash pairs under a hostile locale and is rejected.
The policy is intentionally local to the evidence-producing command. It does
not impose a process-wide locale on compiler or runtime output.

The CM12 harness contract check keeps immutable diagnostic-reference input
separate from redirected run output, requires formal reproduction to enforce
typed-candidate equality, and confirms that all three retained Phase 2 corpus
packages are registered for integrity verification. Its fixture suite proves
that recoupling reference input to the output root, relaxing candidate
enforcement, discarding candidate failures, or dropping a package registration
is rejected.

The full reproducer runs the 24-fixture, 288-record CM12 gate, the exact `pnsd`
oracle contract, and the five-engine runtime-refresh smoke sweep. Run one group
when diagnosing infrastructure:

```sh
reviewer/reproduce-evidence --scope cm12
reviewer/reproduce-evidence --scope runtime-refresh
```

Set `REVIEWER_KEEP_WORKSPACE=1` to retain the disposable clone for inspection.
The default deletes it after reporting the result.

The GO5 evidence-determinism candidate has its own bounded reproducer:

```sh
GO5_KEEP_WORKSPACE=1 make reviewer-reproduce-go5
```

It runs the modern and historical GO5 diagnostic twice, under
`Pacific/Kiritimati` and `Etc/GMT+12`. Raw differences must stay inside the
explicit date and derived-artifact contract. The modern runtime follows `TZ`; the
checked-in historical executable does not, so three date-sensitive comparison
artifacts are re-derived from canonical inputs. All 69 canonical package files
must be byte-identical. Each raw package is compared with the committed GO5 manifest by
a separate command. The generators do not write that manifest or modify the
accepted report tree. Evidence files are written only below the caller's
candidate root; case-sensitive execution scratch remains in disposable Docker
volumes and is deleted at teardown. A pass identifies a review candidate, not
adopted evidence or physics approval.

The unpatched-priming package has a separate bounded reproducer:

```sh
UNPATCHED_PRIMING_KEEP_WORKSPACE=1 make reviewer-reproduce-unpatched-priming
```

It builds and runs the unpatched binary twice under `Pacific/Kiritimati` and
`Etc/GMT+12`. Nine non-date artifacts must remain raw-exact. The five declared
run-date fields in `unpatched-priming.stdout` must expose the timezone change,
and all 10 canonical artifacts must match each other and the committed package.
The committed README is the eleventh evidence file and remains a checked
reference document rather than a generated artifact. The expected engine exit
`2`, `PRRDX` EOF, exact witness row, and failed compatibility status are
preserved; a candidate pass does not reclassify that retained behavioral
failure.

## Exit contract

| Exit | Meaning |
|---:|---|
| `0` | all requested checks passed |
| `10` | committed evidence integrity failure |
| `20` | reproduced compatibility/regression mismatch |
| `30` | reproduction command or output failure |
| `40` | missing or failed infrastructure prerequisite |
| `64` | command-line usage error |

The verifier covers the security, adapter, GO5, GO5 reconciliation,
unpatched-priming, `pnsd`, runtime-refresh, and three retained Phase 2 corpus
manifest packages. `PACKAGE PASS` establishes that committed bytes match their
manifest; it does not accept a candidate or endorse a package's scientific
conclusion. The verifier also independently compares all committed DSG and
amplitude fixture tables across the modern build and both checked-in historical
executables.

Formal CM12 reproduction requires the typed PRBAS candidate to match all 24
fixtures and 288 displayed records, in addition to the retained three-executable
oracle agreement. Candidate mismatches are compatibility failures. The request
probe mismatch allowance is disabled; every nonzero build or generator exit
remains a reproduction failure unless it accompanies a classified compatibility
failure.

Coverage differs from integrity verification. The GO5/`PRRDX` diagnostic and
the unpatched-priming measurement are checked against their committed manifests,
but `reproduce-evidence` does not re-run either diagnostic. It reproduces only
the strict CM12 gate, the `pnsd` two-build and exact-artifact contract, and the
five runtime-refresh engine outcomes described above.
