# GWDAC amd64 development container

This environment provides a reproducible, case-sensitive Linux workspace for
the `gwdac` and `arndt64` rewrite. It deliberately targets `linux/amd64` so the
modern build environment and historical x86-64 executables share an
architecture.

## Prerequisites

- Docker Desktop for Apple Silicon is installed and running.
- Docker Desktop's Rosetta acceleration for amd64 emulation is enabled.
- The adjacent `repository-archives` directory contains the two verified Git
  bundles.

## Start and verify

```sh
docker compose build
docker compose up -d
docker compose exec dev bootstrap-repos
docker compose exec dev verify-environment
docker compose exec dev bash
```

The repositories are cloned into a Docker named volume rather than bind-mounted
from macOS. This preserves paths that differ only by letter case.

The development image includes a modern GNU Fortran toolchain and the current
GD, PNG, and X11 development packages. The separate network-disabled `oracle`
image now provides the pinned obsolete runtime libraries required by the
historical executables, including `libg2c.so.0`, `libgfortran.so.3`, and
`libpng12.so.0`.

The Phase 2 kernel source is mounted read-only at `/phase2/kernel`. Build and
validate the immutable solution/dataset loaders, background seam, and pure
amplitude/DSG kernels with:

```sh
docker compose exec -T dev bash /phase2/scripts/inventory-cm12-dataset
docker compose exec -T dev bash /phase2/scripts/build-cm12-seam
docker compose exec -T -e PRSD_ENGINE=seam dev \
  bash /phase2/scripts/run-prsdd-corpus
docker compose exec -T -e PRSD_ENGINE=seam dev \
  bash /phase2/scripts/run-prsdd-amplitude-corpus
docker compose exec -T dev bash /phase2/scripts/compare-cm12-seam
```

## Lifecycle

Stop the container without deleting the source volume:

```sh
docker compose down
```

Delete the container and its case-sensitive source volume:

```sh
docker compose down --volumes
```

Docker Desktop stores images and named volumes in a sparse virtual disk. The
host has ample free space, but the project should not reserve all available
storage; Docker Desktop's disk image limit and periodic cache pruning should
bound growth.
