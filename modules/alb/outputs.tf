# outputs.tf

output "alb_dns_name" {
  value       = aws_lb.main.dns_name
  description = "The URL you'll actually hit in a browser — no custom domain, per ADR-0003."
}

output "alb_security_group_id" {
  value = aws_security_group.alb.id
}

output "nextjs_target_group_arn" {
  value = aws_lb_target_group.nextjs.arn
}

output "springboot_target_group_arn" {
  value = aws_lb_target_group.springboot.arn
}