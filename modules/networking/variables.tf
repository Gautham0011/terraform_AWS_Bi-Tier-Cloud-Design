variable "project_name" {
  type        = string
  description = "name of your project"

}

variable "vpc_cidr" {
  type        = string
  description = "VPC CIDR block"

}

variable "aws_region" {
  type        = string
  description = "aws default region"

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

