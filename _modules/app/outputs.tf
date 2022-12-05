output "domain_name" {
  description = "Custom Domain Endpoint"
  value       = var.alb_record_name != null ? join("", aws_route53_record.alb.*.name) : aws_lb.lb.dns_name
}
output "lb_id" {
  description = "LB ID"
  value       = aws_lb.lb.id
}

output "lb_arn" {
  description = "LB ARN"
  value       = aws_lb.lb.arn
}

output "target_group_arn_suffix" {
  value       = aws_lb_target_group.tg.arn_suffix
  description = "Target Group ARN Suffix to be used with CloudWatch Metrics"
}
output "lb_arn_suffix" {
  value       = aws_lb.lb.arn_suffix
  description = "Load balancer ARN Suffix to be used with CloudWatch Metrics"
}
