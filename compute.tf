resource "aws_instance" "openclaw" {
  ami                    = data.aws_ami.ubuntu_arm.id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.openclaw.id]
  iam_instance_profile   = aws_iam_instance_profile.openclaw.name
  key_name               = var.key_name

  dynamic "instance_market_options" {
    for_each = var.use_spot_instance ? [1] : []
    content {
      market_type = "spot"
      spot_options {
        max_price                      = var.spot_max_price
        spot_instance_type             = "persistent"
        instance_interruption_behavior = "stop"
      }
    }
  }

  user_data = templatefile("${path.module}/user-data.sh", {
    openrouter_api_key = var.openrouter_api_key
    openrouter_model   = var.openrouter_model
    openclaw_port      = var.openclaw_port
    openclaw_version   = var.openclaw_version
    telegram_bot_token = var.telegram_bot_token
  })

  root_block_device {
    volume_size = 20
    volume_type = "gp3"
  }

  tags = {
    Name = "${var.project_name}-instance"
  }
}

resource "aws_eip" "openclaw" {
  count    = var.use_elastic_ip ? 1 : 0
  instance = aws_instance.openclaw.id
  domain   = "vpc"

  tags = {
    Name = "${var.project_name}-eip"
  }
}
