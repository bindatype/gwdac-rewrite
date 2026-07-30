# pnpolw oracle comparison

The rebuilt source target and the checked-in arndt64 executable both exit 0
with empty stderr for the retained two-file fixture. After replacing only the
embedded calendar date, their PNPOL.PCT plot-command streams are byte-identical.
Their 50-byte PNPOL.TMP files are byte-identical without normalization.

The GWDAC executable is a separate behavioral lineage: it asks for an
additional grid-count input and emits a different PNPOL.PCT stream for the
same fixture. It is retained as deployment evidence, not treated as the source
oracle for webplt/pnpolw.for.

Neither checked-in PNPOL.PCT file matches a fresh run of its adjacent
executable with the surviving PNPOL.IN and PNPOL.INP pair. Those captures are
therefore unpaired evidence and must not be used as exact goldens.

Machine-readable results: pnpol-oracle-comparison.tsv
