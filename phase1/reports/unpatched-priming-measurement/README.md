# Unpatched GO3/GO5 priming measurement

Date: 2026-08-07

Scope: run the already-built unpatched modern `prsdd-headless` binary against
the frozen production-adapter priming deck. The compatibility patch, legacy
source, fixture, accepted output, and production system were not changed.

## Result

The requested 1000 MeV, 90-degree five-column row survives removal of the
compatibility patch byte-for-byte:

```text
patched:     90.000  0.2098E+01  0.0000E+00   58.15  0.2932E+01
unpatched:   90.000  0.2098E+01  0.0000E+00   58.15  0.2932E+01
```

The GO5 priming summary also matches exactly:

```text
patched:    Total Data= 1533 Chi2=   5563.03
unpatched:  Total Data= 1533 Chi2=   5563.03
```

The unpatched process does not complete normally. After printing the witness
row and the following prompt, it aborts at `pru.f:4839` with a Fortran
end-of-file error in `PRRDX`, returns exit status 2, and never prints the normal
`Thanks for using SAID` marker. The accepted patched run exits 0.

Execution note: the runner was invoked normally, then invoked under shell
tracing to locate why the wrapper returned without normal output. Both
invocations reached engine exit status 2. The retained stdout, stderr, and exit
artifacts are from the traced setup rerun; shell tracing itself was not written
into the engine's stdout or stderr artifacts.

Therefore the numerical witness-row question is answered **yes**, but the
absolute compatibility gate **fails** on process completion. The patch is not
load-bearing for this one displayed row; it may still be load-bearing for clean
completion of the full priming deck. No patch disposition follows from this
measurement.

## Evidence labels

- **Reference:** the accepted patched `accepted-priming.stdout` at checkpoint
  `fa79871`.
- **Captured:** the unpatched stdout, stderr, exit status, extracted rows and
  totals, environment, and manifest in this directory.
- **Inferred:** the patch may affect post-output `PRRDX` completion; this
  measurement does not isolate the exact input record or runtime condition.
- Physics/domain approval remains pending.

## Reproduction

From the evidence-repository root:

```sh
phase1/scripts/verify-unpatched-priming-measurement
```

The verifier reproduces and validates the evidence package. Its own evidence
reproduction passes while reporting the compatibility gate as failed; this does
not normalize or tolerate the engine's exit status 2.

## Key artifacts

- `patched-row.txt`, `unpatched-row.txt`: exact extracted witness rows.
- `patched-total-chi2.txt`, `unpatched-total-chi2.txt`: exact GO5 summaries.
- `unpatched-priming.stdout`, `.stderr`, `.exit`: complete captured run.
- `result.tsv`: explicit engine and gate result.
- `environment.txt`: source, binary, fixture, compiler, and OS provenance.
- `manifest.sha256`: hashes for every evidence artifact in this directory.
