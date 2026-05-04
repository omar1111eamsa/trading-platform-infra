.PHONY: setup hooks validate plan

setup: hooks
	@echo "✅ SysteM dev environment ready"

hooks:
	@echo "Installing pre-commit hooks..."
	pip install pre-commit detect-secrets
	pre-commit install
	pre-commit install --hook-type commit-msg
	@echo "✅ pre-commit hooks installed"

validate:
	cd terraform/ovh && terraform fmt -check && terraform validate
	yamllint gitops/

plan:
	cd terraform/ovh && terraform plan
