module "networking" {
  source = "../../modules/networking"

  name                     = var.name
  vpc_cidr_block           = var.vpc_cidr_block
  public_subnet_cidrs      = var.public_subnet_cidrs
  private_app_subnet_cidrs = var.private_app_subnet_cidrs
  private_db_subnet_cidrs  = var.private_db_subnet_cidrs
}

module "alb" {
  source = "../../modules/alb"

  name              = var.name
  vpc_cidr_block    = module.networking.vpc_cidr_block
  vpc_id            = module.networking.vpc_id
  public_subnet_ids = module.networking.public_subnet_ids
  nextjs_port       = var.nextjs_port
  springboot_port   = var.springboot_port
}

module "ecs_cluster" {
  source = "../../modules/ecs-cluster"

  name                  = var.name
  vpc_id                = module.networking.vpc_id
  alb_security_group_id = module.alb.alb_security_group_id
  nextjs_port           = var.nextjs_port
  springboot_port       = var.springboot_port
}

module "rds" {
  source = "../../modules/rds"

  name                        = var.name
  vpc_id                      = module.networking.vpc_id
  private_db_subnet_ids       = module.networking.private_db_subnet_ids
  ecs_tasks_security_group_id = module.ecs_cluster.tasks_security_group_id

  username       = var.db_username
  db_name        = var.db_name
  engine_version = var.engine_version

  instance_class    = var.instance_class
  allocated_storage = var.allocated_storage
  multi_az          = var.multi_az
}

module "ecr" {
  source = "../../modules/ecr"
  name   = var.name
}

# ---- Application runtime: secrets, roles, private DNS, services ----

module "app_secrets" {
  source = "../../modules/app-secrets"
  name   = var.name
}

module "ecs_task_roles" {
  source = "../../modules/ecs-task-roles"

  name = var.name
  secret_arns = [
    module.app_secrets.jwt_secret_arn,
    module.rds.db_secret_arn,
  ]
}

module "service_discovery" {
  source = "../../modules/service-discovery"

  name   = var.name
  vpc_id = module.networking.vpc_id
}

module "iam_oidc" {
  source = "../../modules/iam-oidc"

  name               = var.name
  github_org         = var.github_org
  app_repo_name      = var.app_repo_name
  ecr_repository_arn = module.ecr.repository_arn
  ecs_task_role_arns = [module.ecs_task_roles.task_execution_role_arn]
}

module "backend_service" {
  source = "../../modules/ecs-service"

  service_name                      = "${var.name}-backend"
  cluster_id                        = module.ecs_cluster.cluster_id
  container_name                    = "backend"
  container_image                   = "${module.ecr.repository_url}:bootstrap"
  container_port                    = var.springboot_port
  cpu                               = 512
  memory                            = 1024
  execution_role_arn                = module.ecs_task_roles.task_execution_role_arn
  subnet_ids                        = module.networking.private_app_subnet_ids
  security_group_ids                = [module.ecs_cluster.tasks_security_group_id]
  target_group_arn                  = module.alb.springboot_target_group_arn
  health_check_grace_period_seconds = 180
  log_group_name                    = module.ecs_cluster.log_group_name
  aws_region                        = var.aws_region
  service_registry_arn              = module.service_discovery.backend_service_arn

  environment = {
    SPRING_PROFILES_ACTIVE = "aws"
    SERVER_PORT            = tostring(var.springboot_port)
    SPRING_DATASOURCE_URL  = "jdbc:postgresql://${module.rds.db_endpoint}/${var.db_name}?sslmode=require"
    JAVA_TOOL_OPTIONS      = "-XX:MaxRAMPercentage=75.0"
  }

  secrets = {
    SPRING_DATASOURCE_USERNAME = "${module.rds.db_secret_arn}:username::"
    SPRING_DATASOURCE_PASSWORD = "${module.rds.db_secret_arn}:password::"
    JWT_SECRET                 = module.app_secrets.jwt_secret_arn
  }

  # The target group must be attached to a listener before a service can use it.
  depends_on = [module.alb]
}

module "frontend_service" {
  source = "../../modules/ecs-service"

  service_name                      = "${var.name}-frontend"
  cluster_id                        = module.ecs_cluster.cluster_id
  container_name                    = "frontend"
  container_image                   = "${module.ecr.repository_url}:bootstrap"
  container_port                    = var.nextjs_port
  cpu                               = 256
  memory                            = 512
  execution_role_arn                = module.ecs_task_roles.task_execution_role_arn
  subnet_ids                        = module.networking.private_app_subnet_ids
  security_group_ids                = [module.ecs_cluster.tasks_security_group_id]
  target_group_arn                  = module.alb.nextjs_target_group_arn
  health_check_grace_period_seconds = 60
  log_group_name                    = module.ecs_cluster.log_group_name
  aws_region                        = var.aws_region

  environment = {
    PORT             = tostring(var.nextjs_port)
    INTERNAL_API_URL = "http://${module.service_discovery.backend_dns_name}:${var.springboot_port}/api"
  }

  depends_on = [module.alb]
}

module "pipeline_config" {
  source = "../../modules/pipeline-config"

  name = var.name
  values = {
    "alb-dns-name"          = module.alb.alb_dns_name
    "ecs-cluster-name"      = module.ecs_cluster.cluster_name
    "backend-service-name"  = module.backend_service.service_name
    "frontend-service-name" = module.frontend_service.service_name
  }
}
