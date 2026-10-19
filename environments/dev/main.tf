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

module "iam_oidc" {
  source = "../../modules/iam-oidc"

  name               = var.name
  github_org         = var.github_org
  app_repo_name      = var.app_repo_name
  ecr_repository_arn = module.ecr.repository_arn
}