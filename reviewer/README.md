# Reviewer harness

The reviewer harness separates two operations that must not be conflated:

1. `verify-committed-evidence` reads and hashes committed evidence without
   invoking Docker, compilers, legacy executables, or generators.
2. `reproduce-evidence` clones the exact reviewed commit into a temporary
   workspace and runs generators only there. The authoritative checkout is
   fingerprinted before and after the run.

Neither command changes physics source, fixtures, tolerances, or oracle output.

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

## Exit contract

| Exit | Meaning |
|---:|---|
| `0` | all requested checks passed |
| `10` | committed evidence integrity failure |
| `20` | reproduced compatibility/regression mismatch |
| `30` | reproduction command or output failure |
| `40` | missing or failed infrastructure prerequisite |
| `64` | command-line usage error |

The verifier covers the security, adapter, GO5, unpatched-priming, and
runtime-refresh manifest packages. It also independently compares all committed
DSG and amplitude fixture tables across the modern build, both checked-in
historical executables, and the accepted immutable seam.
