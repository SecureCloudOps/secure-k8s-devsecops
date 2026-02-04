.PHONY: tf-plan-dev tf-apply-dev tf-destroy-dev

tf-plan-dev:
	terraform -chdir=terraform/envs/dev plan

tf-apply-dev:
	@echo "Apply/Destroy must be run via GitHub Actions workflow_dispatch"
	@exit 1

tf-destroy-dev:
	@echo "Apply/Destroy must be run via GitHub Actions workflow_dispatch"
	@exit 1
