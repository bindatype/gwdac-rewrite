# PRBAS Ambient-Input Eligibility Inventory

Evidence label: **inferred**, except where a later captured runtime value is
explicitly cited. This inventory defines the hidden legacy state that must be
made explicit or rejected before the typed PRBAS path can be accepted. It does
not change eligibility or claim physics approval.

| Legacy input | Current typed treatment | Checkpoint A classification |
| --- | --- | --- |
| `/PRSC/ IR0`, `IR`, `NE`, `NA`, `E`, `A`, `NNBT` | Explicitly checked by `retained_request_is_valid` | Modeled eligibility input |
| `/PRSC/ NF`, `PEM`, `TITLE`, `NNL` | `NF`, `PEM`, and title are loaded by the provenance-checked immutable solution; the typed loop is fixed at six waves | Require captured `NNL=6`; solution content remains hash-bound |
| `/PRSC/ TTLI(1)` | Typed dispatch initializes from immutable solution title instead of ambient `TTLI` | Unmodeled lifecycle input; capture at every live entry |
| `/PRSC/ IT` | Not checked by typed eligibility; legacy `IT=100` resets saved `EPIM` and returns from `PRDLT` | Unmodeled control input; capture and determine whether canonical requests exclude `100` |
| `/PRSC/ PEM(25,6,2,6)` (`KILL`) | Available through immutable parameters but used as an ambient sentinel by legacy PRBAS | Capture; determine whether an explicit eligibility assertion is required |
| `/GOMEGA/ GOM1..GP2`, `IRCT` | Loaded into immutable solution background and passed to pure Born/background calculations | Modeled, provenance-checked solution input |
| `/GOMEGA/ BCOFF` | Typed dispatch owns a local `background_reset_pending`; legacy `PRDLT` compares ambient `BCOFF` with saved `BCOFFM` | Unmodeled lifecycle input and leading ownership hypothesis; capture only in Checkpoint A |
| `/PRKC/ IPRK` | Not checked or modeled by typed formula evaluation; legacy changes momentum scaling at `prsd.f:2501` and `prsd.f:2527` when `IPRK=1` | Unmodeled eligibility input; captured canonical value is `0`, and unsupported values must be rejected or modeled before acceptance |
| `/PGLOB/ PG`, `NFG` | Not modeled by typed formula evaluation; legacy `ADDRESK` can modify `TER`/`TEI` | Unmodeled eligibility input; capture nonzero counts before acceptance |
| Saved `PRDLT` state (`EPIM`, `BCOFFM`, `QB`, related cache) | Replaced incompletely by local typed grid state; frozen formula routines retain their own caches | Hidden lifecycle boundary; the same-process second-`go2` capture tests reload behavior without correcting it |
| `PNPWI` `PNMOD` short-circuit | The typed path calls the retained `PNTEST` formula directly and does not model `PNMOD` state | Unmodeled formula-owned control path; the retained CM12 contract must exclude or explicitly reject a nonzero `PNMOD` override |
| `PNPWI` energy early return and clamp | Typed dispatch rejects nonpositive energy and has no separate `0 < E < 2 MeV` clamp; legacy returns early at `E <= 0` and clamps positive values below 2 MeV | Outside the captured 849.957 MeV path; require an explicit eligibility boundary rather than infer parity |

Source basis: archived `said/prsd.f` routines `PRBAS`, `PRSOL`, and `PRDLT` at
source commit `f6c81d01a1fe8b007c247acc2213f821a62dc4f2`. Runtime observations produced
by this checkpoint are **captured**, not oracles.

The final retained `live.in` typed entry captured `IR=2`, `IR0=0`, `NNBT=0`,
`IT=1`, `NNL=6`, `IPRK=0`, zero nonzero `NFG` and `PG` entries, `BCOFF=0`,
`KILL=0`, and title words `CM12`, `M05`, `M05`. These observations narrow the
canonical request but do not yet add eligibility checks. The same-process
forced-legacy capture independently shows `EPX=0` at row 1 after the first
load and retained `EPX=8.4995721435546875E+002` after the second load.
