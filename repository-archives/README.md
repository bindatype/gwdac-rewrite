# GWDAC repository archives

These files are offline, complete-history snapshots of the private GitHub
repositories used by the GWDAC rewrite.

| Repository | Bundled branch | Commit |
| --- | --- | --- |
| `bindatype/gwdac` | `master` | `aacdf975295d11eb0ec7529edd8fd549025dcd4d` |
| `bindatype/arndt64` | `master` | `f6c81d01a1fe8b007c247acc2213f821a62dc4f2` |

Verify the archives:

```sh
shasum -a 256 -c SHA256SUMS
git bundle verify gwdac.bundle
git bundle verify arndt64.bundle
```

Restore case-sensitive working copies on Linux:

```sh
git clone gwdac.bundle gwdac
git clone arndt64.bundle arndt64
```

The corresponding bare mirrors are under `work/mirrors` in the Codex task
workspace. A second copy of this archive directory on independent storage is
still required for a true backup.
