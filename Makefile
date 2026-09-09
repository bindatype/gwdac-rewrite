.PHONY: reviewer-verify reviewer-verify-gate-identity reviewer-verify-runtime-refresh-contract reviewer-verify-evidence-sort-policy reviewer-verify-cm12-harness-contract reviewer-verify-checkpoint3a-contract reviewer-reproduce reviewer-reproduce-cm12 reviewer-reproduce-cm12-accepted reviewer-reproduce-runtime-refresh reviewer-reproduce-go5 reviewer-reproduce-go3pr2 reviewer-reproduce-unpatched-priming reviewer-verify-comma-a-editing reviewer-write-pnsd-manifest reviewer-write-runtime-refresh-aggregate

reviewer-verify:
	./reviewer/verify-committed-evidence --expected-commit "$$(git rev-parse HEAD)"

reviewer-verify-gate-identity:
	./reviewer/verify-gate-identity-fixtures

reviewer-verify-runtime-refresh-contract:
	./reviewer/verify-runtime-refresh-contract-fixtures

reviewer-verify-evidence-sort-policy:
	./reviewer/verify-evidence-sort-policy-fixtures

reviewer-verify-cm12-harness-contract:
	./reviewer/verify-cm12-harness-contract-fixtures

reviewer-verify-checkpoint3a-contract:
	./reviewer/verify-checkpoint3a-contract

reviewer-reproduce:
	./reviewer/reproduce-evidence

reviewer-reproduce-cm12:
	./reviewer/reproduce-evidence --scope cm12

reviewer-reproduce-cm12-accepted:
	./phase2/scripts/run-cm12-accepted-gate

reviewer-reproduce-runtime-refresh:
	./reviewer/reproduce-evidence --scope runtime-refresh

reviewer-reproduce-go5:
	./phase1/scripts/verify-prsdd-go5-diagnostic

reviewer-verify-comma-a-editing:
	./phase1/scripts/verify-gfortran-comma-a-editing

reviewer-write-pnsd-manifest:
	./phase1/scripts/write-pnsd-evidence-manifest

reviewer-write-runtime-refresh-aggregate:
	./reviewer/write-runtime-refresh-aggregate

reviewer-reproduce-go3pr2:
	./phase1/scripts/verify-go3pr2-adapter-diagnostic

reviewer-reproduce-unpatched-priming:
	./phase1/scripts/verify-unpatched-priming-measurement
