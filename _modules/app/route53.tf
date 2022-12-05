resource "aws_route53_record" "alb" {
  count   = var.route53_zone_id != null && var.alb_record_name != null ? 1 : 0
  zone_id = var.route53_zone_id
  name    = var.alb_record_name
  type    = "A"

  alias {
    name                   = aws_lb.lb.dns_name
    zone_id                = aws_lb.lb.zone_id
    evaluate_target_health = true
  }
}
