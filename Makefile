.PHONY: reviewer-verify reviewer-reproduce reviewer-reproduce-cm12 reviewer-reproduce-runtime-refresh reviewer-reproduce-go5

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
