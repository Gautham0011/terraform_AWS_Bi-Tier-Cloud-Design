output "tg_arn" {
  value = aws_lb_target_group.lb_target_group.arn

}

output "alb_dns_name" {
  value = aws_lb.load_balancer.dns_name

}