variable "project_name" {
  type        = string
  description = "Project Name"

}

variable "vpc_id" {

}

variable "pvt_subnetA" {
  type        = string
  description = "Allow SSH from private subnet from AZ-A"

}

variable "pvt_subnetB" {
  type        = string
  description = "Allow SSH from private subnet from AZ-B"

}