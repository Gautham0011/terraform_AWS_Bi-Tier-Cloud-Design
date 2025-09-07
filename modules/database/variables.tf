variable "project_name" {
  type        = string
  description = "Project Name"

}

variable "pvt_subnetA" {
  type        = string
  description = "Allow SSH from private subnet from AZ-A"

}

variable "pvt_subnetB" {
  type        = string
  description = "Allow SSH from private subnet from AZ-B"

}

variable "db_name" {
  type        = string
  description = "mysql DB nane"

}

variable "db_sg_id" {
  type        = string
  description = "databse security group"

}

variable "db_username" {
  type = string

}

variable "db_password" {
  type = string

}