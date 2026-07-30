# Superseded tracing diagnostics

The two `*.strace` files in this directory are retained only as diagnostic
evidence. Docker Desktop's Apple Silicon x86-64 emulation emitted undecodable
`syscall_0x...` records, so these files are not valid opened-file inventories.

The accepted runs use the source-controlled `LD_PRELOAD` recorder in
`historical-runtime/bin/file-trace.c`. Their raw traces and sorted opened-file
inventories remain in the parent report directory.
