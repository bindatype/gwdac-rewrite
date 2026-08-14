# GO5 canonical-width correction

Date: 2026-08-14

Status: **candidate pass; implementation accepted; evidence not adopted**

## Scope and provenance

This addendum supersedes only the fixed-width claim in
`prsdd-go5-evidence-determinism-20260813`. The earlier report remains unchanged
as reviewed provenance. Commit
`12a2f4b81fb0bfaabbf760f247224129567acf56` replaces each eight-column runtime
date with the eight-character token `<RUN_DT>` and rejects any change in file
length, line count, or individual line length.

No frozen Fortran source, physics routine, fixture, tolerance, oracle, accepted
evidence file, production system, `main`, or `dev` reference changed during the
run.

Evidence labels:

- **Captured:** two complete candidate packages generated under
  `Pacific/Kiritimati` and `Etc/GMT+12`.
- **Reference:** the unchanged committed GO5 package and manifest.
- **Oracle:** checked-in historical `arndt64/said/prsdd`, SHA-256
  `8a3c925a3aa95314fb4ad4fa7a8cbfa0095df898ee6fa96dad2071d20789678a`.
- **Inferred:** no physics approval; stakeholder review remains pending.

The retained local candidate workspace is
`/tmp/gwdac-go5-determinism-12a2f4b`. It is supporting captured evidence, not a
published or accepted package.

## Command and result

```sh
GO5_CANDIDATE_WORKSPACE=/tmp/gwdac-go5-determinism-12a2f4b \
GO5_KEEP_WORKSPACE=1 \
make reviewer-reproduce-go5
```

The command exited 0 and reported `CANDIDATE PASS`. Each run contained 69 raw
and 69 canonical files and exactly 35 fixed-position substitutions. The
canonicalizer's file-, line-count-, and per-line-length assertions all passed.

Across the two date contexts:

- 9 modern date-bearing raw files differed;
- 2 historical date-bearing raw files remained exact because the checked-in
  executable does not follow `TZ`;
- 3 derived comparison artifacts differed and were regenerated from canonical
  inputs;
- 55 other raw files were byte-identical;
- all 69 canonical package files were byte-identical.

The complete non-exact raw set plus the two static historical date files is in
`date-relations.tsv`. The canonical manifest file SHA-256 was
`e3d3553d10add96d4d7ad210d9389b89f46df3c843a58462358123cf20ef333d`
in both runs.

Both runs retained the accepted patched binary SHA-256
`958889882d91fce225c04bc18021725fec757bde6ea047df1bf93a4136c7aa4f`,
priming observable `0.2098E+01`, accepted and fresh-patched database count 204,
and repeated unpatched and historical count 238. Candidate differences remain
reported rather than adopted.

This correction establishes only the reviewability of the GO5 evidence
generator. It does not accept candidate evidence or approve physics behavior.
