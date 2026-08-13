---
ace: effort
status: active
created: 2026-07-29
updated: 2026-08-13
tags:
  - gwdac
  - said
  - legacy-modernization
  - scientific-computing
systems:
  - bindatype/gwdac
  - bindatype/arndt64
---

# GWDAC Rewrite

## Objective

Replace the legacy GWDAC/SAID web application with a maintainable, reproducible, and testable implementation while preserving its scientifically meaningful behavior.

`bindatype/gwdac` is the historical web and CGI snapshot. Its computational companion, `bindatype/arndt64`, contains the Fortran source, build recipes, scientific data, libraries, and executables behind the site. The first job is now to establish a reproducible reference build from the canonical Fortran sources, prove how it corresponds to the deployed GWDAC behavior, and turn that behavior into tests. Language selection follows that baseline work.

## Executive Decision

Treat this as a source-recovery, behavior-characterization, and incremental rewrite project.

1. Preserve both repositories as forensic evidence.
2. Identify the canonical source and data set among the active, backup, old, and archived copies.
3. Build the Fortran engines reproducibly with a current `gfortran` in a case-sensitive Linux environment.
4. Compare rebuilt engines, checked-in executables, CGI command decks, and captured outputs.
5. Turn verified behavior into versioned tests and explicit scientific contracts.
6. Prototype one narrow scientific workflow in the two strongest candidate languages.
7. Select the target language with an architecture decision record.
8. Replace workflows vertically, keeping every completed slice runnable and testable.

Program boundary recorded 2026-08-08:

- The current finish line is a reproducible modern Ubuntu compatibility
  container that runs retained SAID workflows without `g77`, `libg2c`, or the
  obsolete production operating system and reproduces documented website
  behavior.
- Executive-decision items 6-8 remain the longer-term rewrite roadmap, but
  Phases 3-6 are deferred pending an explicit decision after the compatibility
  container is reviewed. They are not prerequisites for the intermediate win.

The first reference-build slice is `prsdd`, which the GWDAC
pion-photoproduction CGI wrappers invoke. The first rewrite slice is one narrow,
non-plotting `prsd` observable path driven by committed `go3pr` command decks.
`pnpolw` remains preserved, reproducible Phase 1 evidence, but it is outside the
active rewrite scope.

Scope decision recorded 2026-07-29:

- Retain pion photoproduction as the active workflow family, beginning with
  CM12 amplitude-derived predictions.
- Treat a SAID analyst or scientific consumer as the identified user role; a
  named stakeholder is not required for behavioral recovery.
- Require surviving, checksummed datasets and a runnable oracle for every
  active slice.
- Defer approval of formulas, units, conventions, and tolerances to later
  stakeholder review. Mark them pending rather than silently endorsing the
  legacy physics.
- Venture outside pion photoproduction only for a demonstrated computational
  dependency or an explicit stakeholder requirement.

## Repository Evidence

Audit date: 2026-07-29

Web repository: [bindatype/gwdac](https://github.com/bindatype/gwdac)  
Audited checkout: `aacdf97` on `master`

Computational repository: [bindatype/arndt64](https://github.com/bindatype/arndt64)  
Audited checkout: `f6c81d0` on `master`

Both repositories are private. Licensing is not treated as a blocker under the
owner's current project direction.

System provenance: these repositories are a historical check-in of the code and web assets behind [said.arc.gwu.edu](https://said.arc.gwu.edu/), the GWU SAID partial-wave analysis service.

`bindatype/gwdac` contains:

- 335 tracked files in an approximately 12 MB checkout.
- No Fortran source or build system.
- Two compiled Fortran programs preserved as Linux x86-64 ELF executables: `gwdac/cgi-bin/prsd` and `gwdac/cgi-bin/pnpolw`.
- Approximately 81 executable shell scripts and 13 Perl scripts.
- 120 `.dat` files, primarily KCM scientific data tables.
- 52 `.html` or `.htm` files plus generated PostScript, image, transcript, and input artifacts.
- Four commits. Most application content entered the repository as a snapshot in 2015; a minimal README was added in 2026.

`bindatype/arndt64` contains:

- 3,464 tracked files in an approximately 637 MB checkout.
- 1,157 Fortran files in total.
- 740 Fortran files and approximately 942,000 lines outside the bundled PGPLOT tree, including substantial duplication in `said`, `said_bkp`, `said_old`, and archive directories.
- A likely canonical `said/` tree with 46 Fortran files and approximately 160,000 lines.
- The `prsd` source set: `said/prsd.f` (8,993 lines), `said/prsd2.f` (7,769 lines), and `said/pru.f` (11,201 lines), plus support libraries.
- Sources and build recipes for `pnsd`, `prsd`, `eprsd`, `nnsd`, `knsd`, `pdsd`, `pdesd`, and `pnpolw`.
- Checked-in binaries, object archives, scientific datasets, generated outputs, backup trees, custom plotting libraries, and a full bundled PGPLOT source tree.
- Two commits: the historical import and a 2026 README normalization.

Important technical findings:

- The hard-coded `/home/arndt64/said/...` paths in GWDAC correspond directly to the companion repository's layout.
- The GWDAC `prsd` and `pnpolw` binaries are not byte-identical to the similarly named binaries in `arndt64`. Source-to-deployment correspondence must be demonstrated with behavioral tests rather than assumed.
- `said/Makefile` already names `gfortran`, but still links `libg2c`, uses an account-specific `fsplit`, expects X11 and old graphics libraries, and preserves legacy flags such as `-fno-automatic` and `-fno-second-underscore`.
- A syntax-only pass of `prsd.f`, `prsd2.f`, and `pru.f` succeeds with current `gfortran` in legacy mode. It emits extensive warnings, including argument type/rank mismatches and apparent out-of-bounds array access. These must be treated as possible semantic defects, not merely silenced.
- The `prsd` build links the custom `gplot.a` library. The bundled PGPLOT tree is not referenced by the inspected `prsd` build and appears to be a separate historical dependency.
- Both old executables target an obsolete Linux userspace and depend on old graphics and runtime ABIs.
- The wrappers invoke executables and data through hard-coded home directories such as `/home/arndt`, `/home/arndt64`, `/home/ron`, and shell `~user` expansion.
- The repository contains generated inputs and outputs such as `SAID.INP`, `XXXX.INP`, `TPR`, `TPN`, `TNN`, and `PNPOL.PCT`. These are useful as weak golden fixtures but do not identify all parameters that produced them.
- Several CGI scripts construct shell variables with `eval`, interpolate untrusted query values, write shared filenames, and run commands directly. The legacy application must never be exposed on a network during recovery.
- `JPAC.html` and `jpac.html` collide on case-insensitive filesystems.
- `arndt64` has three more case-collision pairs: `pn/GO08.DAT` and `pn/go08.dat`, `pr/DU06X.DAT` and `pr/du06x.dat`, and `sim/SAID.PCT` and `sim/said.pct`.
- The recovery environment remains private and offline. Publication and
  redistribution policy are outside the current compatibility milestone.

## Recovered Product Shape

The surviving HTML describes a browser interface to SAID partial-wave analyses. Its main workflow families are:

| Family | Surviving operations | Referenced engine |
| --- | --- | --- |
| Pion-nucleon | database, observables, amplitudes, compare | `pnsd` / `pnsdd` |
| Pion-photoproduction | database, observables, amplitudes, compare, change | `prsd` / `prsdd` |
| Eta-photoproduction | database, observables | `eprsd` |
| Kaon-photoproduction | database, observables | `prsd` variants |
| Nucleon-nucleon | database, observables, amplitudes, compare | `nnsd` |
| Kaon-nucleon | database, observables, amplitudes, compare | `knsd`, `kabc`, `kzzz` |
| Pion-deuteron elastic | database, observables, amplitudes, compare | `pdesd` |
| Pion-deuteron to proton-proton | database, observables, amplitudes, compare | `pdsd` |
| Pole analysis | partial-wave pole calculations and plots | `pnpolw` |

The old CGI layer is not the scientific core. It converts web form values into a sequence of commands for an interactive scientific program, executes that program, trims the transcript, and sometimes converts generated PostScript into an image. The rewrite should make those layers explicit.

## Scope

### In Scope

- Recovering file formats, units, validation rules, menus, workflows, and numerical behavior from repository evidence.
- Preserving and versioning scientific datasets with provenance and checksums.
- Replacing CGI, shell, Perl, hard-coded paths, shared temporary files, and obsolete plotting.
- Providing a documented command-line interface and HTTP API.
- Providing a focused web interface after the scientific service is stable.
- Reimplementing only workflows that can be specified and validated.
- Archiving unsupported historical material without pretending it is operational.

### Out of Scope Until Evidence Exists

- Claiming numerical equivalence from a handful of committed output files.
- Assuming a checked-in executable was built from the adjacent source without proving behavioral correspondence.
- Translating all duplicated and archived source before identifying the canonical runtime path.
- Decompiling an entire binary when maintained source for that behavior can be established.
- Reproducing the exact HTML appearance, interactive terminal dialogue, or PostScript layout.
- Supporting undocumented workflows solely because a shell script with a similar name exists.

## Success Criteria

The rewrite is complete for a workflow only when:

- Inputs, outputs, units, ranges, defaults, and error behavior are documented.
- A versioned fixture corpus covers normal, boundary, malformed, and scientifically invalid inputs.
- Numerical results match the best available oracle within documented absolute and relative tolerances.
- Results identify the code version and dataset version used.
- The workflow is deterministic unless a documented algorithm requires randomness.
- Concurrent requests cannot share or overwrite working files.
- The implementation runs from a clean checkout through one supported build command.
- Unit, contract, regression, and end-to-end tests pass in CI.
- A domain reviewer accepts the scientific behavior and terminology.
- The old workflow can be retired without losing a unique capability.

## Delivery Plan

Estimates are team-weeks for a small team and are deliberately ranges. Phase 1 determines whether later estimates can be narrowed.

### Phase 0: Preserve and Contain

Estimate: 2-3 days

Deliverables:

- Read-only archival bundles for `gwdac@aacdf97` and `arndt64@f6c81d0`.
- SHA-256 checksums for source, binaries, libraries, datasets, inputs, and captured outputs.
- A machine-readable inventory with file type, size, executable status, and likely role.
- A security rule that legacy CGI and binaries run only in an isolated, network-disabled environment.
- A case-collision and portability report.
- A canonical-source map that distinguishes active code from backup, old, generated, vendored, and archive content.

Exit criteria:

- Every later transformation is traceable to an unchanged source artifact.
- No recovery activity requires exposing the old CGI service.

Environment decision recorded 2026-07-29:

- Complete bare mirrors are retained under `work/mirrors`, and verified portable
  bundles with SHA-256 checksums are retained under
  `outputs/repository-archives`.
- The reproducible build baseline uses Docker Desktop for Apple Silicon with an
  explicitly pinned `linux/amd64` container architecture.
- Case-sensitive working copies live in a Docker named volume. The repositories
  are restored there from the bundles rather than bind-mounted from macOS.
- The modern build image and the historical runtime oracle remain separate. The
  oracle is network-disabled, read-only, capability-free, and contains the
  obsolete library families required to execute the checked-in binaries.
- An x86-64 UTM VM is a fallback only if the historical executables cannot be
  reproduced in a container because they require behavior below the container
  boundary.
- Docker storage remains bounded by Docker Desktop's sparse-disk limit and
  periodic cache pruning; the project does not reserve all available host
  storage.

### Phase 1: Establish the Reproducible Fortran Baseline

Estimate: 2-4 weeks

This phase makes the recovered Fortran source buildable before any semantic refactoring or language rewrite.

Work:

- Select the canonical source set, beginning with `said/`, and record differences from `said_bkp`, `said_old`, and archived versions.
- Build in a pinned, case-sensitive Linux container with current `gfortran`.
- Replace hard-coded tool paths with repository-local or packaged tools.
- Rebuild local libraries from source so the result no longer links `libg2c`.
- Separate the computational build from X11, GD, PostScript, and interactive plotting where possible.
- Preserve legacy storage and calling behavior initially with explicit compatibility flags.
- Compile `prsdd`, then the other engines required by active GWDAC workflows.
- Run committed GWDAC command decks against rebuilt and checked-in engines.
- Capture stdout, stderr, exit status, opened files, generated files, and hashes.
- Create a warning register for argument mismatches, array bounds, implicit types, COMMON blocks, EQUIVALENCE, Hollerith data, and nonstandard I/O.

Exit criteria:

- `prsdd` builds from a clean checkout with a documented command and no `g77` or `libg2c`.
- At least one GWDAC pion-photoproduction command deck runs against the rebuilt executable.
- The rebuilt output is compared with the checked-in `gwdac` and `arndt64` binaries and captured transcripts.
- Every compiler warning is classified as compatibility debt, suspected defect, or confirmed defect.
- No warning-driven source fix is accepted without a regression fixture.

Decision gate:

- If a current `gfortran` build cannot reproduce the old behavior, preserve both builds as separate oracles and isolate the smallest source/compiler/runtime cause before continuing.

Progress recorded 2026-07-29:

- `prsdd` now builds from `arndt64@f6c81d01a1fe` in the pinned
  `linux/amd64` Ubuntu 24.04 container with GNU Fortran 13.3.0.
- The build derives all code from source: nine core units, 15 `saidopen`
  members, 101 `libxz` members, and the 145-member `gplot` closure.
- The rendering artifact has reproducible SHA-256
  `770a6147266b1b121c6a0a161a694723d5c7d10e3e46af7a19a557ad5415141c`
  and does not depend on `g77`, `libg2c`, `libgfortran.so.3`, or `libpng12`.
  The earlier `d538...` identity was path-dependent because GFortran embedded
  randomized temporary source paths; it is superseded by the corrected build.
- Three explicit build-copy overlays remove `/home/arndt64/sdat`, preserve a
  g77 blank-Hollerith read edge case, and make two `gplot` units acceptable to
  the current compiler. The archived repository remains unchanged.
- The captured CM12 `go3pr` deck completes with exit 0 and empty stderr. It
  produces 19 DSG rows at 0-180 degrees; the extracted table has SHA-256
  `80868398e786c36ff11ef6ef4388e7896fc867d69e319c843b1923d5819a86c3`
  on two independent isolated runs.
- The run harness repairs only the copied `pr/KCM` symlink, whose archived
  target is `/home/mparis/...`, by pointing it at the tracked
  `said/KCM.100330` dataset.
- All 534 emitted compiler warnings are classified in the Phase 1 warning
  register: 201 compatibility debt, 83 suspected defects, and 250 confirmed
  interface/indexing defects.
- A pinned, network-disabled historical-runtime image now supplies
  `libg2c.so.0`, `libgd.so.2`, `libpng12.so.0`, and compiler-matched
  `libgfortran.so.3` runtimes. GWDAC requires the GCC 4.4 runtime; arndt64
  requires the GCC 6 symbol set.
- Both checked-in executables complete the CM12 deck with exit 0, empty stderr,
  19 parsed rows, and the normal SAID exit message.
- The rebuilt source, checked-in arndt64 binary, checked-in GWDAC binary, and
  committed GWDAC `TPR` transcript produce byte-identical result tables with
  SHA-256
  `80868398e786c36ff11ef6ef4388e7896fc867d69e319c843b1923d5819a86c3`.
- Maximum absolute and relative differences are zero in all five displayed
  fields. `SAID.TMP`, `SAID.PCT`, `SAID.LOG`, and `fort.7` are also
  byte-identical across the three executable runs.
- Source-controlled file-open tracing records 71 paths for arndt64 and 70 for
  GWDAC. The sets differ only by arndt64 opening `fort.3`.
- For this fixture, exact equality at legacy displayed precision is now the
  regression rule. Hidden floating-point identity and tolerances for a
  higher-precision replacement remain unproven and require domain review.
- A second `prsdd-headless` target replaces the 145-member `gplot` renderer
  and PostScript exit path with a 13-entry compatibility boundary: twelve
  no-render calls plus a logging-only SAID exit adapter.
- The headless artifact has reproducible SHA-256
  `958889882d91fce225c04bc18021725fec757bde6ea047df1bf93a4136c7aa4f`,
  is 1,080,944 bytes, and needs only `libgfortran.so.5`, `libm.so.6`,
  `libgcc_s.so.1`, and `libc.so.6`.
- The original deck explicitly requests PostScript conversion with `C` and
  `Y`. A separate no-render deck ends at `GO99`. The rendering and headless
  builds produce byte-identical stdout, 19-row tables, `SAID.TMP`, `SAID.PCT`,
  `SAID.LOG`, and `fort.7` under that contract.
- The headless run produces neither `SAID.PS` nor `fort.3`; X11, Xt, GD, PNG,
  JPEG, font, PostScript-converter, and transitive image-library code is absent
  from its link.
- Both targets are byte-reproducible across independent clean temporary build
  roots after compiling copied Fortran sources by stable basename.
- The canonical-source map now covers 301 file paths and 1,230 active Fortran
  program units/routines. All 300 files in `said/` and `said_old/` are
  byte-identical. Of the 46 top-level Fortran files, only `pru.f` differs in
  `said_bkp/`.
- The only active-tree routine deltas are `QLEG` and `QLEGY`. The current
  source explicitly makes the `QLEGY` caller and function return `REAL*8`,
  removing the backup's implicit single-precision return mismatch.
- The 20-file `said.tar.gz` source snapshot has 17 files identical to current
  source. Its `nn1.f` and `prsd.f` are byte-identical to the dated
  `code-archive` versions; its `pru.f` is byte-identical to
  `said_bkp/pru.f`. `prsd03.f` and `pru03.f` are broad older generations, not
  canonical merge candidates.
- `pnpolw` now builds reproducibly from `webplt/pnpolw.for`, source-rebuilt
  `pnu`, `MOD01`, `saidopen`, `libxz`, and the 145-member `gplot` closure.
  Two independent builds have SHA-256
  `a69b66b3c488b7a70def8170e7ba7a836383aedf13bee74113390b928d6cce58`.
- The modern `pnpolw` needs current `libgfortran`, `libm`, X11, GD, `libgcc`,
  and libc. It does not need `g77`, `libg2c`, `libgfortran.so.3`, `libpng12`,
  or `libgd.so.1`.
- The retained `PNPOL.INP` and `PNPOL.IN` pair plus seven tracked datasets run
  with exit 0 and empty stderr. The rebuilt source and checked-in arndt64
  executable produce byte-identical date-normalized `PNPOL.PCT` streams and
  byte-identical `PNPOL.TMP`.
- The checked-in GWDAC `pnpolw` executable is a separate behavioral lineage:
  it asks for an additional grid count and emits a different plot-command
  stream for the same fixture. Neither old checked-in `PNPOL.PCT` is paired
  with the surviving two-file input fixture, so both remain weak captured
  evidence rather than exact goldens.
- The additional `pnpolw` build emits 140 classified warnings: 107
  compatibility debt, 25 suspected defects, and 8 confirmed interface,
  extent, COMMON-block, or indexing defects.

Phase 1 huddle gate:

- Resolved 2026-07-29: do not select or rebuild a third engine.
- Proceed to Phase 2 contract extraction for `prsdd`.
- Preserve `pnpolw` reproducibility evidence without removing its plotting or
  recovering the separate GWDAC grid lineage unless a later retained workflow
  requires it.

### Phase 2: Recover the Specification

Estimate: 2-5 weeks

Deliverables:

- A workflow catalog for retained pion-photoproduction HTML forms and CGI
  scripts.
- A call graph and shared-state map for the canonical Fortran source.
- A comment-provenance ledger classifying scientific intent, historical
  chronology, obsolete platform instructions, contradicted claims, and
  commented-out code by canonical routine.
- An inventory of COMMON blocks, EQUIVALENCE overlays, implicit types, file-unit conventions, and generated intermediates.
- Formal schemas for request parameters, interactive command decks, data tables, and result records.
- A glossary of domain terms, units, solution names, observables, amplitudes, and energy limits.
- A provenance registry for all retained datasets.
- Golden fixtures generated from runnable binaries and curated fixtures from committed outputs.
- A coverage matrix showing which behavior is observed, inferred, externally sourced, or unknown.

Implementation rule:

- Tests must encode scientific behavior, not shell transcripts. Parse legacy text into typed records before comparison.
- Do not modernize comments wholesale in the frozen fixed-form source.
  Preserve provenance, verify scientific claims, and replace obsolete
  implementation comments only after the associated branch is covered by a
  regression fixture or removed.

Exit criteria:

- One `prsd` path has a written input/output contract and at least ten
  representative fixtures.
- The retained non-plotting choice-1 pion-photoproduction amplitude path has a
  written input/output contract and representative fixtures.
- Domain assumptions and numerical tolerances are reviewable independently of implementation language.

Progress recorded 2026-07-29:

- `pion-photoproduction-dsg-v1` defines the CM12 request, typed result,
  validation policy, units review status, source path, dataset boundary, and
  oracle rule.
- Eleven fixtures cover all four pion channels, angular and energy grids,
  fixed laboratory and center-of-mass energies, boundary normalization,
  malformed selections, and below-threshold behavior.
- The modern headless build, checked-in arndt64 executable, and checked-in
  GWDAC executable produce byte-identical typed tables for all 138 records at
  displayed precision.
- The corpus characterizes three behaviors that the replacement should reject:
  silent cosine clamping, fixed-array corruption after an oversized grid, and
  zero/NaN below-threshold results.
- A checksummed provenance manifest records all 64 stable files opened by the
  baseline: 42 KCM tables, 18 `sdat` files, and four working-directory inputs.
  Open tracing does not yet prove which file contents affect each result.
- `pion-photoproduction-amplitude-v1` defines the non-plotting `AMPL` choice-1
  Walker/VPI-SU request, four-complex-amplitude result, explicit `mFm` unit,
  convention review boundary, source path, and oracle rule.
- Thirteen amplitude fixtures cover all four pion channels, angular,
  laboratory-energy, and center-of-mass-energy grids, the maximum 70-point
  grid, a single point, malformed recovery, cosine clamping, and amplitude
  choice coercion.
- The same three engines produce byte-identical amplitude tables for all 150
  records at the legacy one-decimal grid and two-decimal component precision.
- A valid `Wcm` sweep produces finite, exact-matching values while the modern
  runtime reports IEEE underflow and denormal flags; this is retained as
  compatibility debt pending numerical review.
- Reconstructing `DSG` from the rounded choice-1 components satisfies the
  canonical `PROBS` relation at all nine shared baseline angles within the
  calculated text-rounding bound. The maximum absolute difference is
  `0.001646790`.
- A reproducible field-level `/PRSC/` map now verifies 43 active declarations
  across `prsd.f`, `prsd2.f`, and `cmmwp.f`. Every declaration has the same
  ordered 60-member layout and occupies 22,370 four-byte words (89,480 bytes)
  under the frozen ABI.
- The map records zero-based storage offsets, implicit numeric types, six
  packed-A4 text arrays, semantic ownership, CM12 relevance, and conservative
  source-line lexical access evidence for 785 routine/field pairs.
- The retained path is now bounded as solution loading -> scalar kinematics
  and multipole evaluation -> four choice-1 helicity amplitudes -> DSG.
  `/GOMEGA/`, `/solnform/`, `ysKCM` COMMON blocks, saved initialization state,
  and file-backed KCM grids are explicitly included in the hidden-state
  boundary.
- The proposed `CM12Solution`/`CM12Dataset` pure-kernel interface removes
  COMMON state, packed text, fixed 70/99-element grids, and order-dependent
  caches. It keeps uncertainty propagation separate and defines scalar typed
  amplitude and DSG operations over immutable inputs.
- The 42-file CM12 K-matrix package is now parsed by an explicit immutable
  loader. It validates 14 S/P/D/F wave triplets, 275 records per file,
  per-record shape, and the shared 1080-2450 MeV Wcm grid.
- `cm12_evaluate_multipole` now implements the scalar `cmmwp`/`ysKCM`
  numerical seam without COMMON blocks, saved initialization, or file I/O.
  Form number, parameter slice, multipole identity, Wcm, and Born contribution
  are explicit inputs.
- Forty-two direct comparisons spanning all 14 waves at 1100, 1500, and 1900
  MeV Wcm are exactly equal to legacy `ysKCM` in both unrounded
  single-precision components.
- A compatibility build that routes legacy `cmmwp` calls through the seam
  reproduces all 138 DSG and 150 choice-1 amplitude records byte-for-byte at
  displayed precision. The binary no longer links `ysKCM`, `GETTM`,
  `mjl2cpw`, or `kos`.
- The native solution loader verifies the surviving `sdat/prsol.dat`
  SHA-256 before parsing 54 explicit CM12 records, 60 active forms, fixed
  isospin/helicity tables, and immutable background constants.
- The explicit background seam returns full Born and OPEC multipoles plus
  four HOPEC amplitudes. It is exact across an A-B-A order-independence test,
  and all 42 actual-solution multipole cases include nonzero Born terms while
  matching legacy `ysKCM` exactly.
- Pure `PRDA` accumulation matches six split-legacy cases at unrounded
  single precision. Pure DSG passes formula, below-threshold rejection, and
  invalid-domain tests.
- The compatibility adapter preserves the frozen `/PRSC/` `II` mutation and
  delegates only non-finite malformed-grid behavior to renamed legacy
  routines. Valid retained requests use the new typed seams, and both full
  corpora remain byte-identical at displayed precision.

PRBAS orchestration diagnostic chronology, 2026-07-29 through 2026-08-03:

- The first compiler-enforced pure request candidate evaluated only 34 CM12
  `1xx` multipoles. It failed 21 of 24 corpus fixtures, including a focused
  pion-plus DSG change from the displayed oracle `2.036` to `6.593`.
- A frozen-order attribution then accounted for all 40 forms applicable to that
  pion-plus request. Every per-form delta, the final amplitudes, and the exact
  frozen replay DSG `2.03560233` matched; the public oracle token remains
  `0.2036E+01` at displayed precision.
- Extending the experimental candidate to those 40 forms did not close the
  gate. Its focused DSG was `2.69659853`, 32.47% above the exact frozen replay,
  and none of the 18 non-`1xx` multipoles matched.
- The forced-legacy trace found the first meaningful divergence in hadronic
  dispatch. After one no-dispatch row caused by the frozen zero-energy reset,
  rows 2-18 selected `PNTEST` branch 7; the candidate directly selected
  `PNSM05` branch 10. `PNMOD` and `ADDRESK` were no-ops for those rows.
- A 468-row dispatch survey observed 10 no-dispatch rows and 458 `PNTEST` rows,
  with zero `PNSM05` selections. Saved title state and the legacy energy dither
  remain hidden orchestration boundaries.
- These candidates and diagnostics are captured/reference evidence only. They
  are not an accepted `PRBAS` replacement and do not alter the absolute 138-DSG
  and 150-amplitude oracle gate.
- Formula porting remains undecided. No formula, orchestration, fixture,
  tolerance, warning-driven source fix, or frozen Fortran comment was changed.

### Phase 3: Select the Target Language

Estimate: 1-2 weeks

Build the same narrow, non-plotting `prsd` calculation slice in the two strongest candidates. Compare them using:

- Numerical clarity and parity.
- Scientific library coverage.
- Ability to express complex numbers, linear algebra, interpolation, fitting, and uncertainty.
- Testability and observability.
- Deployment and packaging burden.
- Performance on representative workloads.
- Team maintainability and hiring risk.
- Long-term data-format and API support.

Candidate posture:

| Candidate | Best fit | Main concern |
| --- | --- | --- |
| Python with NumPy/SciPy | Default candidate for recovery, data parsing, API work, plotting, and scientific validation | Performance-sensitive kernels may need compilation |
| Julia | Strong candidate for a predominantly numerical system | Smaller operational ecosystem and team bus factor |
| Modern Fortran | Lowest-risk route for preserving recovered algorithms and creating a reference library | Does not by itself solve web, packaging, and maintainability concerns |
| C++ | Mature numerical and performance ecosystem | Higher implementation complexity and memory-safety burden |
| Rust | Strong service and systems safety | Higher cost for translating exploratory numerical code |

Provisional recommendation:

- Start the spike with Python and Julia.
- Select Python for the service and scientific core unless the Julia prototype shows a material numerical or performance advantage.
- Introduce a compiled kernel only after profiling demonstrates a need. Avoid a multi-language architecture by default.

Output:

- An architecture decision record containing benchmark results, parity results, operational tradeoffs, and the selected language.

### Phase 4: Build the Replacement Foundation

Estimate: 2-4 weeks

Create a new application beside the legacy snapshot with these boundaries:

```text
versioned datasets
        |
        v
parsers and validators
        |
        v
pure scientific core
        |
        v
typed use cases
      /   \
     v     v
   CLI    HTTP API
             |
             v
          web UI
```

Required foundation:

- Immutable, checksummed dataset packages.
- Typed domain models with explicit units.
- Pure calculation functions without filesystem or web dependencies.
- A CLI that can run every use case before a web route is added.
- A versioned HTTP API with machine-readable errors.
- Structured logs, run identifiers, timing, and dataset provenance.
- Modern plotting generated from typed results.
- Containerized development and deployment.
- CI for formatting, static analysis, tests, dependency review, and reproducible builds.

Exit criteria:

- A clean checkout runs tests and the first slice with documented commands.
- No scientific function depends on CGI variables, process working directory, or fixed filenames.

### Plotting Replacement To-Do

This is tracked but does not block the computational baseline.

- Confirm that the bundled `src/pgplot` tree is unused by required workflows, then archive it instead of porting it.
- Inventory the small public surface of the custom `gplot.a` library used by SAID. The current `prsd` source contains hundreds of calls through routines such as `PLOT`, `SYMBOL`, `ASYMB`, and `COLOR`.
- Introduce a backend-neutral plot specification so calculations return typed series, labels, ranges, and annotations rather than drawing directly.
- Use a no-op or recording compatibility backend while rebuilding the Fortran baseline.
- Evaluate PLplot only if a maintained Fortran-native renderer is required during transition.
- Use Matplotlib if Python is selected, or CairoMakie if Julia is selected, for the final headless PNG, SVG, and PDF renderer.
- Compare plot data and annotations structurally. Do not require pixel-identical reproduction of historical PostScript.

### Phase 5: Rewrite by Vertical Slice

Estimate: 2-6 weeks per workflow family, revised after the first two slices

Recommended order:

1. One non-plotting `prsd` pion-photoproduction observable workflow.
2. One non-plotting `prsd` pion-photoproduction amplitude workflow.
3. Remaining retained `prsd` observables, amplitudes, comparisons, and plots.
4. Web interface after the CLI and API contracts stabilize.
5. Other families only after an explicit scope decision backed by user need,
   datasets, an oracle, and review capacity.

For each slice:

1. Freeze the legacy contract and fixtures.
2. Implement typed input and data parsers.
3. Implement the calculation as pure functions.
4. Compare against the oracle across the fixture corpus.
5. Add CLI and API adapters.
6. Add the web interaction.
7. Obtain domain review.
8. Mark the corresponding legacy scripts as superseded.

Do not group all parsers, all math, or all UI into separate multi-month efforts. A vertical slice must deliver one complete, reviewable scientific capability.

### Phase 6: Validate and Cut Over

Estimate: 2-4 weeks after the required slices are complete

Deliverables:

- Side-by-side validation report with tolerances and known deviations.
- Performance, concurrency, and failure-mode tests.
- User documentation and dataset provenance documentation.
- Migration and rollback procedure.
- Read-only archive of the original site and executables.
- Removal of legacy binaries and CGI from the production attack surface.

Exit criteria:

- Required workflows meet the success criteria.
- Unknown or unsupported workflows are clearly identified.
- The replacement can be rebuilt and deployed without any personal home directory or obsolete compiler/runtime.

## Test Strategy

### Evidence Levels

Every expected result should carry one of these labels:

- `oracle`: generated by a reproducibly executed legacy binary.
- `captured`: taken from a committed historical output with incomplete execution context.
- `reference`: derived from a publication or independent implementation.
- `inferred`: reconstructed from scripts, formats, or domain reasoning.

Only `oracle` and independently corroborated `reference` results should block numerical releases by default. `captured` and `inferred` results remain valuable but must show their lower confidence.

### Numerical Comparison

- Compare parsed numeric fields, not whitespace or entire transcripts.
- Define absolute and relative tolerances per observable.
- Test singularities, thresholds, valid energy limits, interpolation boundaries, and complex-valued outputs.
- Preserve signed zeros, NaN handling, and unit conversions where they affect meaning.
- Record compiler, architecture, dataset, and algorithm version for every benchmark corpus.

### Test Layers

- Unit tests for formulas, transforms, validation, and parsing.
- Property tests for invariants such as symmetry, conservation relationships, and bounded domains where scientifically valid.
- Golden regression tests against the legacy oracle.
- Contract tests for CLI and HTTP schemas.
- End-to-end tests for a small set of representative browser workflows.
- Performance tests only after correctness is established.

## Data Strategy

- Separate source data, user input, intermediate artifacts, and generated output.
- Give each scientific dataset a manifest with source, date, checksum, format version, units, and applicable workflow.
- Never silently replace a dataset under an existing version.
- Preserve original byte streams in an archival area and expose normalized representations through parsers.
- Treat empty `.DAT` and `.USR` files as unresolved placeholders until their runtime role is understood.
- Remove personal paths from all runtime configuration.

## Security and Operations

- Never deploy or internet-enable the original CGI scripts.
- Do not use shell `eval` or interpolate request values into commands.
- Give every request an isolated temporary directory.
- Run scientific calculations with CPU, memory, wall-time, and output-size limits.
- Use allowlisted solution identifiers and typed numeric ranges.
- Disable outbound network access in calculation workers.
- Generate plots without X11 or a display server.
- Keep uploads out of scope until a valid scientific use case and security model are documented.

## Risks and Responses

| Risk | Consequence | Response |
| --- | --- | --- |
| Canonical source is ambiguous among active, backup, old, and archive trees | The team rewrites the wrong revision | Build a source provenance map and prove behavior against GWDAC command decks |
| Checked-in binaries do not match each other byte-for-byte | A successful build is mistaken for the deployed behavior | Compare parsed scientific outputs across every candidate oracle |
| Legacy undefined behavior changes under current `gfortran` | Numerically plausible but incorrect results | Preserve compatibility flags, classify warnings, and require fixtures before fixes |
| Obsolete local libraries and graphics block linking | The scientific baseline remains tied to `g77` era infrastructure | Rebuild source libraries, isolate plotting, and remove `libg2c` and X11 from the compute path |
| Captured outputs lack full provenance | False confidence in parity | Label evidence levels and require independent corroboration |
| Numerical drift | Scientifically incorrect results that look plausible | Typed outputs, tolerance policy, broad fixtures, and domain review |
| Scope expands to every historical script | Rewrite never reaches a usable release | Define required user workflows and retire unsupported artifacts explicitly |
| Premature language choice | Architecture optimized for assumptions | Decide after a representative two-language spike |
| Legacy web vulnerabilities | Compromise during recovery | Offline, sandboxed execution only |
| No repository license | Blocked redistribution or collaboration | Resolve ownership and licensing before public release |

## Immediate Backlog

### ARCH-001: Reproducible `prsdd` Reference Build

Status: complete for the CM12 baseline on 2026-07-29.

Acceptance criteria:

- Hash and classify both repository snapshots.
- Identify the canonical `prsd` source and support-library inputs.
- Create a case-sensitive Linux build using current `gfortran`.
- Rebuild local libraries from source without `g77` or `libg2c`.
- Build `prsdd` without requiring personal home-directory paths.
- Run one committed GWDAC `go3pr` command deck.
- Compare parsed outputs from the rebuilt executable, the checked-in `arndt64` executables, the GWDAC executable, and captured transcripts.
- Commit the build manifest, warning register, run manifest, and first golden fixture.

Evidence:

- `outputs/phase1/reports/go3pr-oracle-comparison.md`
- `outputs/phase1/reports/go3pr-oracle-comparison.tsv`
- `outputs/phase1/reports/go3pr-numeric-differences.tsv`
- `outputs/phase1/reports/historical-oracle-image.txt`
- `outputs/phase1/reports/go3pr-headless-comparison.md`
- `outputs/phase1/reports/go3pr-headless-artifact-comparison.tsv`
- `outputs/phase1/reports/build-reproducibility.md`

### ARCH-002: `prsd` Contract

Status: behavioral version 1 complete for CM12 `DSG` and choice-1 amplitudes;
physics review pending.

- Document one pion-photoproduction command deck from CGI parameters through Fortran input and typed output.
- Identify the source routines, COMMON blocks, files, and datasets exercised by that path.
- Build at least ten fixtures across normal, boundary, malformed, and scientifically invalid inputs.

Evidence:

- `outputs/phase2/contracts/pion-photoproduction-dsg-v1.md`
- `outputs/phase2/contracts/request.schema.json`
- `outputs/phase2/contracts/result.schema.json`
- `outputs/phase2/fixtures/corpus.tsv`
- `outputs/phase2/reports/prsdd-corpus-validation.md`
- `outputs/phase2/reports/prsdd-corpus-comparison.tsv`
- `outputs/phase2/reports/prsdd-opened-data-manifest.tsv`
- `outputs/phase2/contracts/pion-photoproduction-amplitude-v1.md`
- `outputs/phase2/contracts/amplitude-request.schema.json`
- `outputs/phase2/contracts/amplitude-result.schema.json`
- `outputs/phase2/fixtures/amplitudes/corpus.tsv`
- `outputs/phase2/reports/prsdd-amplitude-corpus-validation.md`
- `outputs/phase2/reports/prsdd-amplitude-corpus-comparison.tsv`
- `outputs/phase2/reports/prsdd-amplitude-dsg-consistency.md`
- `outputs/phase2/reports/prsdd-amplitude-dsg-consistency.tsv`

### ARCH-003: Fortran Compatibility Register

- Inventory and classify compiler warnings in the canonical `prsd` source set.
- Add bounds and runtime-check builds for diagnosis without treating their output as the reference.
- Turn confirmed defects into minimal regression fixtures before changing source.

### ARCH-004: Language Spike

- Implement the same parser and one calculation path in Python and Julia.
- Compare parity, code clarity, package size, startup, runtime, test ergonomics, and deployment.
- Record the decision in an ADR.

### ARCH-005: Workflow Inventory

- Map retained pion-photoproduction forms to their CGI wrappers, generated
  command decks, executable, data files, and output formatter.
- Mark other families `preserved_out_of_scope` unless a later scope decision
  activates them.

### ARCH-006: Plotting Replacement

- Confirm whether any required workflow uses bundled PGPLOT.
- Inventory the custom `gplot.a` call surface. The current `prsdd` compute
  boundary has been reduced to twelve renderer-facing routines.
- Define the backend-neutral plot specification.
- Select the renderer after the target-language ADR.

## First Three Weeks

Week 1:

- Preserve and inventory both repository snapshots.
- Resolve case-collision handling in a Linux workspace.
- Map the `prsdd` source and link dependencies.
- Create the compiler warning register.

Week 2:

- Produce a clean current-`gfortran` build of the required support libraries and `prsdd`.
- Remove `libg2c`, personal tool paths, and graphics from the required compute path.
- Run the first GWDAC command deck and capture all artifacts.

Week 3:

- Compare rebuilt and historical outputs and establish tolerances.
- Write the first `prsd` contract and golden corpus.
- Select the narrow calculation for the Python/Julia language spike.

## Open Decisions

- Which workflow families are still scientifically or operationally required?
- Who can approve numerical tolerances and domain terminology?
- Which of the multiple `arndt64` source and binary variants represents the last trusted production behavior?
- Are publications or independent implementations available to corroborate recovered workflows?
- What deployment form is required: public web service, internal service, CLI, library, or a combination?

None of these decisions blocks `ARCH-001`.

## Current Status

Status: Phase 0 preservation and retained-scope Phase 1 are complete. Accepted
Phase 2 work includes contracts, shared-state mapping, immutable CM12 solution
and dataset loading, scalar multipole evaluation, explicit background
isolation, pure amplitude accumulation, and pure DSG calculation. The modern
reference and both historical executables agree on 138 typed DSG records and
150 typed choice-1 amplitude records. Physics review remains pending.

Legacy `PRBAS` still owns command grids, request sequencing, title-dependent
hadronic dispatch, and saved-state behavior. The pure request candidates remain
failed diagnostics, not accepted replacements. The explicit background seam
still invokes frozen formula routines internally, and the formula-porting
decision remains open.

Read-only production inventory established that the public CM12 `prsdd` binary,
its nine build sources, all 18 KCM files, and the first CM12 solution record are
byte-identical to the archive. The deployed adapter and surrounding
`prsol.dat` are newer state. Offline replay proves that the adapter's `GO5`
priming changes the later pion-plus DSG token from `0.2036E+01` to
`0.2098E+01` on all three accepted executables, matching the captured website.
That history dependence is registered as `SAID-DEFECT-001`, preserved for
compatibility, and not scientifically endorsed.

The modern blank-A4 patch remains an accepted compatibility mitigation, not a
general fidelity correction. It changes the isolated GO5 database selection
from the historical/unpatched 238 records to 204. In the retained priming deck,
the unpatched executable still prints the exact witness row and exact
` Total Data= 1533 Chi2=   5563.03` summary but then aborts in `PRRDX` with
exit status 2; the patched build exits 0. Patch disposition requires a separate
fixture-backed decision.

In the normalized captured comparison, the patch restores 74 of 132 historical
citation fields; the unpatched build restores none, and 58 remain nonhistorical
in both. All 132 displayed `Chi,M=` numeric tails are byte-identical in this
comparison. No broader internal-physics equality is claimed.

The Legacy Runtime Refresh attempted all six additional engines on Ubuntu 24.04
with GNU Fortran 13.3.0. `pnsd` matches seven displayed SP06 DSG rows before a
post-table `PNRDX` formatted-read failure. `eprsd` and `nnsd` exactly match
retained historical decks; `pdsd` and `pdesd` exactly match startup/quit smoke
tests. `knsd` remains blocked because both binaries request a hard-coded
absolute dataset path; no source or path-layout fix was attempted.

The current program finish line is the modern Ubuntu compatibility container.
Phases 3-6 are deferred pending explicit direction. The private GitHub remote
holds the stable reconstructed baseline on `main` and current evidence on
`dev`. The reviewer harness now separates read-only committed-evidence
verification from disposable regeneration, uses deterministic labels and build
paths, and returns distinct integrity, compatibility, reproduction,
infrastructure, and usage exits. Its clean run verifies the 24-fixture CM12
gate and all five runtime-refresh sweep engines without modifying the
authoritative checkout. `main` remains at the stable accepted checkpoint until
a separate reviewed promotion is authorized.
