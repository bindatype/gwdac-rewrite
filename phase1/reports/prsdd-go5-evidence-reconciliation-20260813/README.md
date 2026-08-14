# GO5 evidence-reconciliation diagnostic

Date: 2026-08-13

Scope: evidence-only regeneration and three-way comparison of the committed
`prsdd` GO5/`PRRDX` package. No regenerated evidence was adopted. No source,
fixture, tolerance, oracle, production system, or authoritative dirty artifact
was changed.

## Evidence labels

- **Reference:** committed evidence at `gwdac-rewrite@3b56542`.
- **Captured:** the pre-existing dirty copies in the authoritative `dev`
  checkout.
- **Captured:** clean regeneration from documentation checkpoint `d327ba2` in
  disposable worktree `/tmp/gwdac-step2-go5` and isolated Compose project
  `gwdac-step2-go5`.
- **Oracle:** checked-in historical `arndt64/said/prsdd`, SHA-256
  `8a3c925a3aa95314fb4ad4fa7a8cbfa0095df898ee6fa96dad2071d20789678a`.

The underlying frozen source commit remained
`f6c81d01a1fe8b007c247acc2213f821a62dc4f2`.

## Command and result

The clean checkout ran:

```sh
COMPOSE_PROJECT_NAME=gwdac-step2-go5 \
  phase1/scripts/verify-prsdd-go5-diagnostic
```

The verifier exited 0 and reported `prsdd GO5 diagnostic: PASS`. The retained
mechanism-level results reproduced:

| Variant | Total data | Exit | Relevant relation |
|---|---:|---:|---|
| accepted patched, database deck | 204 | 0 | accepted and fresh patched stdout exact |
| unpatched, database deck | 238 | 0 | repeated unpatched stdout exact |
| historical `arndt64` | 238 | 0 | selection projection exact to unpatched |

The accepted priming witness remained `0.2098E+01`. The accepted patched binary
remained SHA-256
`958889882d91fce225c04bc18021725fec757bde6ea047df1bf93a4136c7aa4f`.

## Four-file hypothesis rejected

The proposed reconciliation expected only three stable-label diffs and their
manifest hashes to change. Clean regeneration instead produced:

```text
21 modified tracked files
7 untracked files
```

Nineteen modified files and all seven new files are inside the GO5 package; two
modified files are shared Phase 1 build reports outside it. The package manifest
grew from 64 to 71 entries, replacing 18 existing digest rows and adding seven
`build-unpatched/` rows.

The complete classification is in `candidate-delta.tsv`. The additional changes
are explainable but are not the authorized four-file adoption candidate:

- 11 captured outputs differ only by the legacy runtime date (`8/ 5/26` versus
  the container's UTC `8/14/26`);
- two historical comparison files differ by stable labels plus that date;
- `read-values.diff` differs only in its stable labels;
- `deck-comparison.diff` differs only in unstabilized diff headers;
- three package GPlot logs and the shared GPlot log differ only by the new
  stable build-path rendering;
- the shared build manifest adds the two explicit `PRRDX` provenance fields;
- seven previously uncommitted `build-unpatched/` logs now enter the generated
  package manifest.

After replacing only legacy runtime dates with `<DATE>`, all 11 output files are
otherwise exact to committed evidence. After additionally removing the first
two diff-header lines, both historical comparison bodies are exact; the
`read-values.diff` and `deck-comparison.diff` bodies are exact without date
normalization. Normalizing only the old random build path makes all four changed
GPlot logs exact. No physics-result delta was found by this comparison, but
physics/domain review remains pending.

## Three-way result

`three-way-hashes.tsv` records the exact hashes for the four files in the
original hypothesis. The authoritative dirty copies differ from the commit only
in the three old timestamped diff headers and their manifest hashes. The clean
candidate differs from both because it contains stable labels, a later runtime
date, broader build-log normalization, and seven additional manifest entries.

Therefore **no regenerated file is accepted or adopted at this checkpoint**.
The next decision must explicitly choose whether to stabilize the remaining
runtime date and deck-diff header, define the intended manifest coverage for
`build-unpatched/`, and reconcile the shared build-report side effects. The two
other authoritative tracked changes and all pre-existing untracked reports are
outside this diagnostic.
