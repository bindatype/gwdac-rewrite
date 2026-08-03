# Read-only live production inventory

Date: 2026-08-03

Host reached: `said.access.phys.arc.gwu.edu`

Reported host name: `assa79.phys.va.gwu.edu`
Evidence class: **captured/reference**

## Scope and safety

This inventory used read-only SSH commands to inspect paths, configuration,
file metadata, Git metadata, ELF dependencies, and SHA-256 hashes. It did not
execute a SAID engine, submit an HTTP/CGI request, or change a server file. A
broad source/data copy was deliberately not made because the CGI and data
trees co-locate runtime output and potentially user-derived files.

The findings are static deployment evidence, not a new behavioral oracle and
not physics approval.

## Deployed topology

The live service is a hybrid of four filesystem lineages rather than a single
Git checkout:

| Role | Live root | Finding |
|---|---|---|
| Apache document and CGI root | `/home/www/gwdac` | Public HTML, shell/Perl adapters, CGI-local KCM data, and checked-in CGI executables |
| CM12 pion-photoproduction | `/home/arndt64` | Active `prsdd`, archived-source-equivalent CM12 sources, and expanded `sdat/prsol.dat` |
| Most other public engines | `/home/arndt` | Older non-Git source/data tree and the binaries targeted by most non-CM12 wrappers |
| External pion-nucleon sessions | `/home/ron/pn` | Surviving `XP08.SES`, `XP15.SES`, and `SP06.SES` dependencies |

Apache uses `/home/www/gwdac/html` as `DocumentRoot`, aliases `/img/` to
`/home/www/gwdac/img/`, and maps `/cgi-bin/` to
`/home/www/gwdac/cgi-bin/`. The observable form
`html/analysis/go3pr.html` posts to `/cgi-bin/go3pr2`; `go3pr2` invokes
`/home/arndt64/said/prsdd` from the CGI working directory.

The installed Git repositories are historical import markers, not deployment
authorities. `/home/www/.git` points at `bindatype/gwdac` commit
`199a8f1ad6d733f5cc6cecfe8b6da3139dd07efa`; `/home/arndt64/.git` points at
`bindatype/arndt64` commit
`bb410ba04df673ffbb9a6072721dc37e32832dc3`. Both commits date to 2015, and
the user confirmed that nobody maintained production through GitHub after
those imports. Live working-tree content and wrapper targets therefore take
precedence over Git HEAD when describing deployment.

## CM12 reconciliation

The deployed CM12 computational artifacts are older than the surrounding
public adapter state, not a newer Fortran lineage:

- All nine selected `prsdd` build sources in `/home/arndt64/said` are
  byte-identical to the archived `arndt64@f6c81d0` files.
- The deployed `/home/arndt64/said/prsdd` is byte-identical to the checked-in
  arndt64 executable: SHA-256
  `8a3c925a3aa95314fb4ad4fa7a8cbfa0095df898ee6fa96dad2071d20789678a`.
- All 18 CGI-local `KCM/kcm*.dat` files match the immutable Phase 2 dataset
  manifest, 18/18 by SHA-256.
- Live `/home/arndt64/sdat/prsol.dat` is an expanded solution container:
  453,101 bytes, 6,459 lines, 57 records, SHA-256
  `9f7b49e9bbc3fb76e7d8a11848cfcd7d7c31423b2548ff7a8080f90fdd6c931f`.
  The archive has 285,902 bytes, 4,086 lines, 39 records, SHA-256
  `dbcaae30bbf44aca6e5482fc2b10b81cb6e1033cf41061bc089d5f6a85576522`.
- The complete first CM12 record is nevertheless exact between production
  and archive: 121 lines, 8,534 bytes, SHA-256
  `b1f03e20f94d8149b6ecce06669060b7fbaf693e42d0ff680479b54dc38c24b8`.
  It retains the `PNs=M05` field involved in the open dispatch finding.

The public adapter is different. Live `go3pr2` injects a `GO5` DSG request
before `GO3` and calls `./wtrim3`; the archived wrapper does neither. Its live
SHA-256 is
`3595bb9a9b29a1d959146ea27f3babc4bc83b348975535fea857c011a79c105b`,
versus archived
`f9ce0a1ee8d01db94e3743e199e6dc47cd874236f4ca1afe5c81d4748efe0a1e`.
The alternate `go3pr` wrapper is exact to the archive, but the public form does
not target it.

This narrows `ARCH-007`: production does not provide a later CM12 source,
binary, KCM set, or CM12 record that resolves the `M05`/`SM05` question. The
modified public adapter is a concrete deployment difference, but no causal
claim is made about the separately captured website value because no live CGI
execution was performed here.

## Other engines

Most public non-CM12 wrappers target `/home/arndt/said`, not the checked-in
`/home/arndt64/said` executables used by the first Legacy Runtime Refresh
preflight. The two sets have different hashes. The `/home/arndt` tree has no
Git provenance; its shared source files are largely copied from arndt64, but
`epru.f`, `nn1.f`, `prsd.f`, `pru.f`, and `saidopen.for` differ, and
`junk.f` exists only there.

The active binaries still depend on obsolete runtime families including
`libg2c.so.0`, old GD/PNG libraries, and X11. Source/binary pairing is not
uniformly demonstrable: notably, the deployed `pdsd` and `pdesd` binaries
predate the corresponding surviving source mtimes, and the active arndt64
`epru.f` postdates its deployed `eprsd` binary.

Some wrappers reference `/home/arndt64/said/prsd`, which is absent. This is a
static configuration risk only; reachability and behavior were not tested.

## Consequences

1. Preserve the accepted archived witnesses; add this production inventory as
   a separate captured/reference lineage rather than silently replacing an
   oracle.
2. Treat `go3pr2` request priming and CGI working-directory state as explicit
   inputs when production behavior is reconciled offline.
3. Use the `/home/arndt` binary hashes and wrapper map when selecting a
   production witness for the remaining runtime-refresh engines.
4. Obtain a reviewed, path-limited export before making a local production
   snapshot; exclude CGI output, logs, temporary files, and user-derived
   state rather than copying `/home/www/gwdac/cgi-bin` wholesale.
5. Keep the scientific disposition of `M05`/`SM05` open for stakeholders.

Supporting manifests:

- `cm12-artifacts.tsv`
- `engine-binaries.tsv`
- `source-roots.tsv`

## Follow-up: 2026-08-03

The separately authorized offline adapter diagnostic resolved the captured
website-value mechanism at displayed precision. Replaying the live `GO5`
priming before the same `GO3` request changes all three accepted executable
results from `0.2036E+01` to `0.2098E+01`, exactly matching the website.
`wtrim3` only selects the later output section. See
`../go3pr2-adapter-diagnostic/README.md`.

The path-allowlisted production capture is documented in
`../live-production-capture/README.md`. Production remained read-only.
