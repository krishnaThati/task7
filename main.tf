provider "aws" {
  region = "us-east-1"   # Change to your desired region
}

# Data block to reference the existing IAM role
data "aws_iam_role" "ecs_task_execution_role" {
  name = "task8_fullAccess"  # Ensure this IAM role exists
}

# Create an ECS Cluster
resource "aws_ecs_cluster" "medusa_cluster" {
  name = "medusa-cluster"
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

# Create an ECS Service to run the Task Definition
resource "aws_ecs_service" "medusa_service" {
  name            = "medusa-service"
  cluster         = aws_ecs_cluster.medusa_cluster.id  # Reference the cluster created above
  task_definition = aws_ecs_task_definition.medusa.arn
  desired_count   = 1
  launch_type     = "FARGATE"
  network_configuration {
    subnets          = ["sg-05de51d9b26afb3f8"]  # Specify your subnet IDs here
    assign_public_ip = true  # Optional: Set to true if you want the task to have a public IP
    security_groups  = ["subnet-0eea857c1cf095bf7"]  # Specify your security group ID here
  }
}
