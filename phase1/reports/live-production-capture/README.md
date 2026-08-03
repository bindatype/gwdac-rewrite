# Allowlisted live-production capture

Date: 2026-08-03

Evidence class: **captured/reference**

## Safety boundary

This is a one-way, production-to-local, read-only capture. No production file
was written, no production executable or CGI endpoint was run, and no service
configuration was changed. A `RESUME` command never authorizes production
writes, deployments, configuration changes, or live execution.

The capture was derived from deployed wrapper targets and already identified
source roots. It did not enumerate or copy unrelated maintainer home
directories.

Explicit exclusions include:

- `.ssh`, credentials, and unrelated home-directory content;
- `SAID.LOG`, `SAID.TMP`, `SAID.PCT`, `SAID.INP`, `TPR`, `XXXX`, `fort.*`,
  and other CGI runtime output;
- query-derived or user-derived files; and
- broad copies of `/home/www/gwdac/cgi-bin`, `sdat`, `pr`, `pn`, or home
  directories.

The three `.SES` files were included deliberately as named scientific
workflow inputs, not treated as disposable session logs.

## Capture manifest

Local capture root, outside Git:

```text
/Users/maclach/Documents/Codex/2026-07-29/gwdac/work/production-20260803
```

| Property | Value |
|---|---:|
| Explicit allowlisted paths | 542 |
| Captured bytes | 34,218,873 |
| `/home/arndt` paths | 388 |
| `/home/arndt64` paths | 49 |
| `/home/www` paths | 101 |
| `/home/ron` paths | 3 |
| `/etc/apache2` paths | 1 |

The capture includes source/build files with explicit extensions, wrappers
that reference deployed SAID engines, ten named deployed binaries, 18 KCM
files, `prsol.dat`, three named `.SES` inputs, the public form, formatter
scripts, and the Apache virtual-host configuration.

Allowlist SHA-256:
`8738ccf3ff0b1fd7e6fd63b61dcc4c64f2c5e3e6752498210c74fc8f697c8281`

Production hash-manifest SHA-256:
`0d4bbdf1dded207caefd5c749d29121a8940e4c1c8014ce455b2c678303a82a2`

Production and local SHA-256 manifests compared exactly for 542/542 files.
The committed evidence contains the allowlist and production hashes, but not
the captured binaries or datasets themselves.

## Source comparison

`source-comparison.tsv` compares 424 captured source/build files with the
archived `arndt64@f6c81d0` tree:

| Relation | Files |
|---|---:|
| Exact | 414 |
| Different | 8 |
| Missing from archive | 2 |

For the top-level `/home/arndt/said` files specifically, 26 are exact, four
differ, and two are absent from the archive. The non-exact files are:

```text
said/junk.f          archive_missing
said/mkS.sh          archive_missing
said/nn1.f           different
said/prsd.f          different
said/pru.f           different
said/saidopen.for    different
```

Additional non-exact support/current-lineage files are:

```text
/home/arndt/lib/junk.f          different
/home/arndt/libxzl.for          different
/home/arndt64/said/epru.f       different
/home/arndt64/said/prux.f       different
```

This refines the Track 2 gap: `/home/arndt` is a distinct deployed binary
lineage, but most surviving source/build content is copied unchanged from the
archive. The production binaries remain separate captured witnesses, and
source/binary pairing still requires per-engine evidence.

## Verification

From the local capture root:

```sh
shasum -a 256 -c \
  /Users/maclach/Documents/Codex/2026-07-29/gwdac/dev/outputs/phase1/reports/live-production-capture/production.sha256
```

Supporting files:

- `allowlist.txt`
- `manifest.txt`
- `production.sha256`
- `source-comparison.tsv`
