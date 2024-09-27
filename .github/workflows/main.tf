# Specify the provider
provider "aws" {
  region = "us-east-1"  # Replace with your preferred region
}

# Data block to reference the existing IAM role
data "aws_iam_role" "ecsTaskExecutionRole" {
  name = "krishnaTaskDef"  # Reference the existing role name
}

# Create an ECS Cluster
resource "aws_ecs_cluster" "main" {
  name = "medusa-cluster"
}

# Define the ECS Task Definition
resource "aws_ecs_task_definition" "medusa" {
  family                   = "medusa-app"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = data.aws_iam_role.ecsTaskExecutionRole.arn  # Use the existing role ARN
  container_definitions    = jsonencode([{
    name      = "medusa"
    image     = "202533508516.dkr.ecr.us-east-1.amazonaws.com/task7:latest"  # Replace with your ECR image URI
    cpu       = 256
    memory    = 512
    essential = true
    portMappings = [{
      containerPort = 80
      hostPort      = 80
    }]
  }])
}

# Define the ECS Service
resource "aws_ecs_service" "medusa" {
  name            = "medusa-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.medusa.arn
  desired_count   = 1
  launch_type     = "FARGATE"
  platform_version = "LATEST"

  network_configuration {
    subnets         = var.subnet_ids  # Use variable for subnets
    security_groups = var.security_group_ids  # Use variable for security groups
    assign_public_ip = true
  }

  deployment_controller {
    type = "ECS"
  }
}

# Variable definitions
variable "subnet_ids" {
  description = "The subnets where the ECS tasks will run"
  type        = list(string)
  default     = ["subnet-0eea857c1cf095bf7", "subnet-065b60dbd16e27db5"]  # Default subnets
}

variable "security_group_ids" {
  description = "The security groups to associate with the ECS service"
  type        = list(string)
  default     = ["sg-05de51d9b26afb3f8"]  # Replace with your actual security group ID
}

# Output the cluster name
output "ecs_cluster_name" {
  value = aws_ecs_cluster.main.name
}

# Output the service name
output "ecs_service_name" {
  value = aws_ecs_service.medusa.name
}
