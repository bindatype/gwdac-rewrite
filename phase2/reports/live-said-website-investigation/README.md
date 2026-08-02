# Live SAID website reproduction check

Date: 2026-08-02

Evidence labels:

- **captured**: current public form fields and returned DSG value;
- **reference**: the committed frozen target result;
- **inferred**: conclusions about why the live and frozen values differ.

Physics/domain review remains pending.

## Request

Public form:
`https://said.arc.gwu.edu/analysis/go3pr.html`

The live form was submitted with these values:

```text
solution=CM12
reaction=PI+_N
observable=DSG
independent_variable=Acm
lower=90
increment=1
upper=90
fixed_variable=Elab
fixed_value=1000 MeV
plot=NO
data_range=995..1005 MeV
```

Equivalent GET parameters:

```text
sl=CM12
rt=2
ot=DSG
iv=A
il=90
ii=1
iu=90
fv=E
fn=1000
jpeg=GO99
u=995
l=1005
```

Direct result URL:
`https://said.arc.gwu.edu/cgi-bin/go3pr2?sl=CM12&rt=2&ot=DSG&iv=A&il=90&ii=1&iu=90&fv=E&fn=1000&jpeg=GO99&u=995&l=1005`

## Captured Result

The live website returned:

```text
PI+N DSG AT Elab = 1000.00
Acm=90.000
DSG=0.2098E+01
```

The committed frozen target returns:

```text
Acm=90.000
DSG=0.2036E+01
```

The public result therefore differs at displayed precision:

```text
live=2.098
frozen=2.036
displayed_delta=0.062
```

## Interpretation

The current public website is not a fourth corroborating execution authority
for the frozen repository behavior. Its CM12 result differs from the modern
headless build and both checked-in historical executables used by the frozen
corpus.

The public output displays `SM05` in the solution heading, but that text alone
does not prove the internal hadronic dispatch: the frozen program also prints
the human-readable solution heading even though its fixed-field parser passes
`M05` to `PNPWI` and falls back to `PNTEST`/SP00.

The public Observables form does not expose the internal choice-1 `AMPL`
request used by the diagnostic corpus. A direct `ot=AMPL` request produced no
usable result. The public interface can reproduce the user-visible DSG
calculation, but it cannot by itself establish whether production dispatched
SP00 or SM05.

The cause of the live/frozen difference is **unresolved**. Plausible boundaries
include a different production executable, changed CM12 data/title alignment,
or other production-only source or data changes. No one of those explanations
is established by this website check.

## Manual Reproduction

1. Open the Pion Photoproduction `Observables` page.
2. Select `Chew-Mandelstam fit CM12`.
3. Select reaction `PI+_N`.
4. Enter observable `DSG`.
5. Select independent variable `Acm`.
6. Enter lower `90`, increment `1`, and upper `90`.
7. Select fixed variable `Elab` and enter `1000`.
8. Select `NO` for the JPEG plot.
9. Enter plotted-data limits `995` and `1005`.
10. Select `Start` and locate the `Acm=90.000` result row.

## Stop

This was a read-only public-interface investigation. No production data,
repository fixture, oracle, formula, orchestration, or source was changed.
Determining why production returns `2.098` requires separate authorization.
