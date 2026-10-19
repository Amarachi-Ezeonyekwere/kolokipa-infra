output "vpc_id" {
  value = module.networking.vpc_id
}

output "public_subnet_ids" {
  value = module.networking.public_subnet_ids
}

output "private_app_subnet_ids" {
  value = module.networking.private_app_subnet_ids
}

output "private_db_subnet_ids" {
  value = module.networking.private_db_subnet_ids
}

output "vpc_endpoints_security_group_id" {
  value = module.networking.vpc_endpoints_security_group_id
}

output "alb_dns_name" {
  value = module.alb.alb_dns_name
}

output "alb_security_group_id" {
  value = module.alb.alb_security_group_id
}

output "nextjs_target_group_arn" {
  value = module.alb.nextjs_target_group_arn
}

output "springboot_target_group_arn" {
  value = module.alb.springboot_target_group_arn
}

output "ecs_cluster_name" {
  value = module.ecs_cluster.cluster_name
}

output "ecs_tasks_security_group_id" {
  value = module.ecs_cluster.tasks_security_group_id
}

output "db_endpoint" {
  value = module.rds.db_endpoint
}

output "db_secret_arn" {
  value = module.rds.db_secret_arn
}

output "db_security_group_id" {
  value = module.rds.db_security_group_id
}

output "ecr_repository_url" {
  value = module.ecr.repository_url
}

output "github_actions_role_arn" {
  value = module.iam_oidc.github_actions_role_arn
}