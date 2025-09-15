output "launch_template_name" {
  value = aws_launch_template.launch_template.name

}

output "ASG_name" {
  value = aws_autoscaling_group.asg.name

}