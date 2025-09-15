output "project_name" {
  value       = var.project_name
  description = "This is you project name"

}

output "public_url" {
  value       = module.alb.alb_dns_name
  description = "Browse the LoadBalancer DNS url to reach your HA app"

}