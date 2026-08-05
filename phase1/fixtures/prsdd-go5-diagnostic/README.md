# `prsdd` GO5 diagnostic decks

Evidence class: captured/static-reference, as labeled below

`go3pr2-priming.in` is byte-identical to the accepted live production-adapter
fixture. It preserves the `GO5` priming sequence used by captured production
before the CM12 `GO3` request.

`go5pr-database-list.in` is mechanically expanded from the captured current
`go5pr` wrapper and current form defaults: `SM95`, reaction `2` (`PI+_N`),
`DSG`, Elab 300 through 320 MeV, and years 1950 through 2050. The captured
`modulus2` helper maps `300 320` to `300 320` unchanged.

The first deck is an accepted oracle fixture. The second is a captured-wrapper
reference deck; Glen's public run through the older `/home/arndt/said/prsd`
corroborates the operation class but is not a byte-level oracle for modern
`prsdd`.
