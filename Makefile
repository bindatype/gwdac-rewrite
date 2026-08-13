.PHONY: reviewer-verify reviewer-reproduce reviewer-reproduce-cm12 reviewer-reproduce-runtime-refresh

reviewer-verify:
	./reviewer/verify-committed-evidence

reviewer-reproduce:
	./reviewer/reproduce-evidence

reviewer-reproduce-cm12:
	./reviewer/reproduce-evidence --scope cm12

reviewer-reproduce-runtime-refresh:
	./reviewer/reproduce-evidence --scope runtime-refresh
