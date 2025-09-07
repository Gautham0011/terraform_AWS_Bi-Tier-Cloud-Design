variable "project_name" {
  type        = string
  description = "this defines the project topic"
  default     = "HA-app"

}

variable "aws_region" {
  type        = string
  description = "default AWS region where you want to all the resources to be deployed"
  default     = "us-east-1"

}

variable "vpc_cidr" {
  type        = string
  description = "VPC CIDR block"

}

variable "public_subnet_A" {
  type        = string
  description = "define Public subnet A"

}

variable "public_subnet_B" {
  type        = string
  description = "define Public subnet B"

}

variable "private_subnet_A" {
  type        = string
  description = "define Private subnet A"

}

variable "private_subnet_B" {
  type        = string
  description = "define Private subnet B"

}


variable "db_name" {
  type        = string
  description = "mysql DB nane"

}

variable "db_username" {
  type = string

}

variable "db_password" {
  type = string

}

