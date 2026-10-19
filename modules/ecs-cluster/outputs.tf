output "cluster_id" {
  value = aws_ecs_cluster.main.id
}

output "cluster_name" {
  value = aws_ecs_cluster.main.name
}

output "tasks_security_group_id" {
  value = aws_security_group.ecs_tasks.id
}

output "log_group_name" {
  value = aws_cloudwatch_log_group.ecs.name
}