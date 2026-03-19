# OpenClaw AWS Terraform

Deploy OpenClaw on AWS using Terraform with OpenRouter integration.

## Prerequisites

- AWS Account with credentials configured
- Terraform >= 1.0
- OpenRouter API key from https://openrouter.ai/
- SSH key pair in AWS

## Quick Start

### 1. Configure AWS credentials
```bash
aws configure
```

### 2. Create SSH key pair

**Option A: Using AWS CLI**
```bash
aws ec2 create-key-pair \
  --key-name openclaw-key \
  --query 'KeyMaterial' \
  --output text > ~/.ssh/openclaw-key.pem

chmod 400 ~/.ssh/openclaw-key.pem
```

**Option B: Using AWS Console**
1. Go to EC2 Console → Key Pairs
2. Click "Create key pair"
3. Name: `openclaw-key`
4. Key pair type: RSA
5. Private key format: .pem
6. Click "Create key pair"
7. Save the downloaded .pem file to `~/.ssh/`
8. Run: `chmod 400 ~/.ssh/openclaw-key.pem`

### 3. Create configuration file
```bash
cp terraform.tfvars.example terraform.tfvars
```

### 4. Edit configuration

Edit `terraform.tfvars`:
```hcl
key_name           = "openclaw-key"  # Use the key name you created
openrouter_api_key = "sk-or-v1-xxxxxxxxxxxxx"  # Get from https://openrouter.ai/
openrouter_model   = "anthropic/claude-4.5-sonnet"
allowed_ssh_cidr   = ["YOUR_IP/32"]  # Your IP for security
```

To get your IP:
```bash
curl https://checkip.amazonaws.com
```

### 5. Deploy:
```bash
terraform init
terraform plan
terraform apply
```

### 6. Get the URL:
```bash
terraform output openclaw_url
```

## Configuration

### Instance Type

Default is `t4g.micro` (ARM-based, cost-effective). Change in `terraform.tfvars`:
```hcl
instance_type = "t4g.micro"
```

### OpenRouter Models

Edit `user-data.sh` to change the model:
```yaml
OPENROUTER_MODEL=anthropic/claude-3.5-sonnet  # Default
OPENROUTER_MODEL=anthropic/claude-3-haiku     # Cheaper
OPENROUTER_MODEL=google/gemini-pro            # Alternative
```

See all models at https://openrouter.ai/models

### Cost Optimization

Enable spot instances in `terraform.tfvars`:
```hcl
use_spot_instance = true
```

Disable Elastic IP to save costs:
```hcl
use_elastic_ip = false
```

## Management

### SSH Access
```bash
ssh -i ~/.ssh/your-key.pem ubuntu@<instance-ip>
```

### View Logs
```bash
ssh -i ~/.ssh/your-key.pem ubuntu@<instance-ip>
cd /opt/openclaw
docker compose logs -f
```

### Update OpenClaw
```bash
ssh -i ~/.ssh/your-key.pem ubuntu@<instance-ip>
cd /opt/openclaw
docker compose pull
docker compose up -d
```

### Destroy Infrastructure
```bash
terraform destroy
```

## Helper Commands

A Makefile is included for convenience:
```bash
make help      # Show all available commands
make init      # Initialize Terraform
make plan      # Show deployment plan
make apply     # Deploy infrastructure
make destroy   # Destroy all resources
make ssh       # SSH into instance
make url       # Show OpenClaw URL
make logs      # Show OpenClaw logs
make status    # Show instance status
```

## Project Structure

```
.
├── compute.tf                 # EC2 instance
├── data.tf                    # Data sources
├── iam.tf                     # IAM roles and policies
├── networking.tf              # VPC, subnets, security groups
├── outputs.tf                 # Output values
├── variables.tf               # Input variables
├── versions.tf                # Provider versions
├── user-data.sh              # Instance initialization script
├── terraform.tfvars.example  # Example configuration
├── Makefile                  # Helper commands
└── README.md                 # This file
```

## Security

- Restrict SSH access to your IP only
- Use security groups to limit access
- Keep OpenRouter API key secure
- Regular system updates

## Troubleshooting

### Cannot connect to instance
Check security group allows your IP:
```bash
aws ec2 describe-security-groups --group-ids <sg-id>
```

### OpenClaw not starting
Check logs via SSH:
```bash
docker compose logs
```

### OpenRouter API errors
Verify API key is correct and has credits at https://openrouter.ai/

## Resources

- OpenClaw: https://github.com/openclaw/openclaw
- OpenRouter: https://openrouter.ai/
- Terraform AWS Provider: https://registry.terraform.io/providers/hashicorp/aws/latest/docs
