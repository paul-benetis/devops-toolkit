# Fetch the default VPC
data "aws_vpc" "default" {
  default = true
}

# Fetch the subnets in that VPC
data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

module "ecs" {
  source = "terraform-aws-modules/ecs/aws"

  cluster_name = "ecs-myapp"

  cluster_configuration = {
    execute_command_configuration = {
      logging = "OVERRIDE"
      log_configuration = {
        cloud_watch_log_group_name = "/aws/ecs/ecs-myapp"
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

  name                           = "myapp"
  cluster_arn                    = module.ecs.cluster_arn
  ignore_task_definition_changes = true

  cpu    = 1024
  memory = 4096

  # Container definition(s)
  container_definitions = {

    myapp = {
      cpu       = 512
      memory    = 1024
      essential = true
      image     = "amazon/amazon-ecs-sample"
      port_mappings = [
        {
          name          = "myapp"
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
    alb_ingress_3000 = {
      type        = "ingress"
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      description = "Service port"
      cidr_blocks = ["0.0.0.0/0"]
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
