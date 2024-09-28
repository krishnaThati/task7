provider "aws" {
  region = "us-east-1"  # Change to your desired region
}

# Data block to reference the existing IAM role
data "aws_iam_role" "ecs_task_execution_role" {
  name = "task8_fullAccess"  # Ensure this IAM role exists
}

# Define the ECS Task Definition
resource "aws_ecs_task_definition" "medusa" {
  family                   = "medusa-app"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = data.aws_iam_role.ecs_task_execution_role.arn
  container_definitions    = jsonencode([{
    name      = "medusa"
    image     = "202533508516.dkr.ecr.us-east-1.amazonaws.com/task7:latest"
    cpu       = 256
    memory    = 512
    essential = true
    portMappings = [{
      containerPort = 80
      hostPort      = 80
    }]
  }])
}
