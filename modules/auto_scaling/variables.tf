variable "project_name" {
  type        = string
  description = "Project Name"

}

variable "asg_sg_id" {
  type        = string
  description = "ASG security group id"

}

variable "ami" {
  type        = string
  description = "AMI type for ec2 instances"
  default     = "ami-00ca32bbc84273381"

}

variable "instance_type" {
  type        = string
  description = "ec2 instance type"
  default     = "t3.micro"
}

variable "aws_region" {
  type        = string
  description = "AWS default region for reources"
  default     = "us-east-1"

}

variable "min_size" {
  type        = number
  default     = 2
  description = "Minimum number of EC2 instances in ASG"

}

variable "max_size" {
  type        = number
  default     = 2
  description = "Minimum number of EC2 instances in ASG"

}

variable "desired_cap" {
  type        = number
  default     = 3
  description = "Desired number of EC2 instances in ASG to always run"

}

variable "target_group_arn" {
  type        = string
  description = "arn of target group to backend the ASG"

}

variable "public_subnet_A_id" {

}

variable "public_subnet_B_id" {

}

variable "enable_autscaling" {
  description = "If set to true, enable auto scaling"
  type        = bool

}

variable "server_port" {
  description = "https server ingress and egress ports"
  type        = number
  default     = 80
}

variable "server_text" {
  description = "the text the webserver displays"
  type        = string
  default     = "Hello, This your HA app project setup!"

}

variable "db_name" {
  type = string

}

variable "db_address" {
  type = string

}

variable "db_port" {

}

variable "db_endpoint" {

}

variable "replica_address" {
  type = string

}

variable "replica_port" {

}

variable "replica_name" {
  type = string

}

variable "db_az" {

}

variable "replica_az" {

}