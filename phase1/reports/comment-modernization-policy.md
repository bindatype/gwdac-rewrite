# Comment archaeology and modernization policy

Audit basis: `arndt64@f6c81d01a1fe8b007c247acc2213f821a62dc4f2`

## Evidence

The canonical `said/` tree contains 20 comment lines explicitly dated in 1979.
The earliest located example is:

```fortran
C  CALCULATE AND PLOT PARTIAL WAVE AMPLITUDES FOR NN PGM  2/13/79 ARNDT
```

Other retained comments describe October and November 1979 pion-nucleon
work. At least 25 source files contain VAX, IBM, CDC, workstation, or similar
platform-specific commentary. Examples include instructions to comment or
uncomment particular cards, remove `BACKSPACE`, or select platform-specific
`OPEN` statements.

## Policy

Do not rewrite comments wholesale in the frozen reference source. They are
part of the available provenance and may be the only explanation for a
scientific convention or compatibility branch.

Classify comments before changing them:

| Class | Treatment |
| --- | --- |
| Scientific intent, formula, units, or data provenance | Preserve, verify with a domain reviewer, then restate as a tested contract |
| Historical authorship and chronology | Preserve in source-history metadata or an archaeology note |
| Obsolete platform/build instructions | Replace only after the corresponding branch is removed and covered by a regression test |
| Description of current control flow | Rewrite beside the modern implementation if still useful; delete if the code is self-explanatory |
| Commented-out code or unexplained constants | Quarantine as evidence until source lineage and behavior are known |
| Incorrect or contradicted comment | Record the contradiction, prove behavior with a fixture, then correct it |

## Fixed-form constraint

Fortran fixed form gives column position semantic meaning. A historical comment
starts with `C`, `*`, or `!` in a specific position, while column 6 can mark a
continuation. Reflowing or reindenting comments in the frozen source can
accidentally create executable or continuation text. Comment edits therefore
require the same compile and oracle gates as code edits.

## Phase 2 method

1. Attach comment inventory to the canonical routine map.
2. Label each material comment as verified scientific contract, historical
   provenance, obsolete implementation note, or unresolved claim.
3. Move verified behavior into typed schemas, tests, and architecture
   documentation.
4. Write new comments for decisions and non-obvious invariants, not line-by-line
   translations of the Fortran.
5. Preserve the unchanged repository snapshot so deleted comments remain
   recoverable.

The goal is not to make the old source read as if it were written today. The
goal is to extract trustworthy knowledge from it and document the replacement
without carrying obsolete platform folklore forward.
