output "alb_sg_id" {
    value = aws_security_group.alb_sg.id
  
}

output "asg_sg_id" {
    value = aws_security_group.asg_sg.id
  
}

output "db_sg_id" {
    value = aws_security_group.db_sg.id
  
}