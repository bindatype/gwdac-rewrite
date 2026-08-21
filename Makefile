.PHONY: reviewer-verify reviewer-reproduce reviewer-reproduce-cm12 reviewer-reproduce-runtime-refresh reviewer-reproduce-go5 reviewer-reproduce-go3pr2 reviewer-reproduce-unpatched-priming reviewer-verify-comma-a-editing

reviewer-verify:
	./reviewer/verify-committed-evidence

reviewer-reproduce:
	./reviewer/reproduce-evidence

reviewer-reproduce-cm12:
	./reviewer/reproduce-evidence --scope cm12

reviewer-reproduce-runtime-refresh:
	./reviewer/reproduce-evidence --scope runtime-refresh

reviewer-reproduce-go5:
	./phase1/scripts/verify-prsdd-go5-diagnostic

reviewer-verify-comma-a-editing:
	./phase1/scripts/verify-gfortran-comma-a-editing

reviewer-reproduce-go3pr2:
	./phase1/scripts/verify-go3pr2-adapter-diagnostic

reviewer-reproduce-unpatched-priming:
	./phase1/scripts/verify-unpatched-priming-measurement
