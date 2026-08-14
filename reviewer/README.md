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
commit.

## Commands

From the repository root:

```sh
make reviewer-verify
make reviewer-reproduce
```

The full reproducer runs the 24-fixture, 288-record CM12 gate and all five
runtime-refresh engines. Run one group when diagnosing infrastructure:

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
`Pacific/Kiritimati` and `Etc/GMT+12`. Raw captures must differ only in the 13
explicitly declared date-bearing files; all 69 canonical package files must be
byte-identical. Each raw package is compared with the committed GO5 manifest by
a separate command. The generators do not write that manifest or modify the
accepted report tree. A pass identifies a review candidate, not adopted
evidence or physics approval.

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
unpatched-priming, and runtime-refresh manifest packages. It also independently compares all committed
DSG and amplitude fixture tables across the modern build and both checked-in
historical executables. The experimental PRBAS candidate is still run during
reproduction, but its known mismatches are diagnostic evidence and do not enter
the accepted three-executable oracle gate. Reviewer reproduction permits only
the candidate request probe's documented exit 6; every other nonzero build or
generator exit remains a reproduction failure.

Coverage differs from integrity verification. The GO5/`PRRDX` diagnostic and
the unpatched-priming measurement are checked against their committed manifests,
but `reproduce-evidence` does not re-run either diagnostic. It reproduces only
the CM12 gate, including the diagnostic PRBAS candidate, and the five runtime-
refresh engine outcomes described above.
