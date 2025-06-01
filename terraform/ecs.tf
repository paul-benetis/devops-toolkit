resource "aws_lb_target_group" "app" {
  name                 = var.app_name
  port                 = 8080
  protocol             = "HTTP"
  vpc_id               = data.aws_vpc.default.id
  target_type          = "ip"
  deregistration_delay = 30

  health_check {
    path                = "/health"
    protocol            = "HTTP"
    matcher             = "200-399"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.app_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app.arn
  }
}

module "ecs" {
  source = "terraform-aws-modules/ecs/aws"

  cluster_name = "ecs-${var.app_name}"

  cluster_configuration = {
    execute_command_configuration = {
      logging = "OVERRIDE"
      log_configuration = {
        cloud_watch_log_group_name = "/aws/ecs/ecs-${var.app_name}"
      }
    }
  }

  fargate_capacity_providers = {
    FARGATE = {
      default_capacity_provider_strategy = {
        weight = 50
      }
    }
    FARGATE_SPOT = {
      default_capacity_provider_strategy = {
        weight = 50
      }
    }
  }
}

module "ecs_service" {
  source = "terraform-aws-modules/ecs/aws//modules/service"

  name                           = var.app_name
  cluster_arn                    = module.ecs.cluster_arn
  ignore_task_definition_changes = true

  assign_public_ip = true

  cpu    = 1024
  memory = 4096

  runtime_platform = {
    cpu_architecture = "ARM64"
    operating_system = "LINUX"
  }

  load_balancer = [
    {
      target_group_arn = aws_lb_target_group.app.arn
      container_name   = var.app_name
      container_port   = 8080
    }
  ]

  # Container definition(s)
  container_definitions = {

    app = {
      cpu       = 512
      memory    = 1024
      essential = true
      image     = "905207152945.dkr.ecr.us-east-1.amazonaws.com/paul-benetis/devops-toolkit:a58d47f1d081e2471d612c7231852e4cbb8112e6"
      port_mappings = [
        {
          name          = var.app_name
          containerPort = 8080
          protocol      = "tcp"
        }
      ]

      # Example image used requires access to write to root filesystem
      readonly_root_filesystem = false

      enable_cloudwatch_logging = false
    }
  }

  subnet_ids = data.aws_subnets.default.ids

  security_group_rules = {
    alb_ingress_8080 = {
      type                     = "ingress"
      from_port                = 8080
      to_port                  = 8080
      protocol                 = "tcp"
      description              = "Service port"
      source_security_group_id = aws_security_group.app_alb_sg.id
    }
    egress_all = {
      type        = "egress"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
}
