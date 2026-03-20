# OpenClaw AWS Terraform

Deploy OpenClaw on AWS using Terraform with OpenRouter integration.

## Prerequisites

- AWS Account with credentials configured
- Terraform >= 1.0
- OpenRouter API key from https://openrouter.ai/
- SSH key pair in AWS

## Quick Start

1. **Configure AWS credentials**
   ```bash
   aws configure
   ```

2. **Create SSH key pair**
   ```bash
   aws ec2 create-key-pair \
     --key-name openclaw-key \
     --query 'KeyMaterial' \
     --output text > ~/.ssh/openclaw-key.pem

   chmod 400 ~/.ssh/openclaw-key.pem
   ```

3. **Setup configuration**
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   ```

   Edit `terraform.tfvars` and set:
   - `key_name` = your SSH key name
   - `openrouter_api_key` = your OpenRouter API key
   - `allowed_ssh_cidr` = your IP (get with `curl https://checkip.amazonaws.com`)

4. **Deploy**
   ```bash
   terraform init
   terraform apply
   ```

5. **Get URL**
   ```bash
   terraform output openclaw_url
   ```

## Default Configuration

- **Region**: ap-southeast-1
- **Instance**: t4g.medium (4GB RAM)
- **Model**: anthropic/claude-4.5-sonnet
- **Port**: 8080
- **Spot Instance**: Enabled
- **Elastic IP**: Disabled

## Configuration Options

### Change Model
```hcl
openrouter_model = "anthropic/claude-4.5-sonnet"
openrouter_model = "google/gemini-3-pro-preview"
openrouter_model = "x-ai/grok-4.1-fast"
```
See all models: https://openrouter.ai/models

### Telegram Bot (Optional)
```hcl
telegram_bot_token = "your-bot-token"  # Get from @BotFather
```

### Cost Settings
```hcl
use_spot_instance = true   # Use spot for lower cost
use_elastic_ip    = false  # Disable for lower cost
```

## Management

**SSH Access**
```bash
ssh -i ~/.ssh/openclaw-key.pem ubuntu@<instance-ip>
```

**View Logs**
```bash
ssh -i ~/.ssh/openclaw-key.pem ubuntu@<instance-ip>
docker compose -f /opt/openclaw/docker-compose.yml logs -f
```

**Destroy**
```bash
terraform destroy
```

## Makefile Commands

```bash
make help      # Show all commands
make apply     # Deploy infrastructure
make destroy   # Destroy all resources
make ssh       # SSH into instance
make url       # Show OpenClaw URL
make logs      # Show logs
```

## Resources

- OpenClaw: https://github.com/openclaw/openclaw
- OpenRouter: https://openrouter.ai/
