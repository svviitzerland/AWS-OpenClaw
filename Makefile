.PHONY: help init plan apply destroy ssh url logs status

help:
	@echo "Available commands:"
	@echo "  make init     - Initialize Terraform"
	@echo "  make plan     - Show deployment plan"
	@echo "  make apply    - Deploy infrastructure"
	@echo "  make destroy  - Destroy all resources"
	@echo "  make ssh      - SSH into instance"
	@echo "  make url      - Show OpenClaw URL"
	@echo "  make logs     - Show OpenClaw logs"
	@echo "  make status   - Show instance status"

init:
	terraform init

plan:
	terraform plan

apply:
	terraform apply

destroy:
	terraform destroy

ssh:
	@$$(terraform output -raw ssh_command)

url:
	@terraform output -raw openclaw_url

logs:
	@ssh -i ~/.ssh/$$(grep 'key_name' terraform.tfvars | cut -d'"' -f2).pem \
		ubuntu@$$(terraform output -raw instance_public_ip) \
		"cd /opt/openclaw && docker compose logs --tail=50 -f"

status:
	@aws ec2 describe-instances \
		--instance-ids $$(terraform output -raw instance_id) \
		--query 'Reservations[0].Instances[0].State.Name' \
		--output text
