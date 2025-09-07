variable "aws_region" {
  type        = string
  default     = "us-east-1"
  description = "AWS region for remote backend resources"

}

variable "aws_replica_region" {
  type        = string
  default     = "us-west-1"
  description = "AWS secondary/replica region"

}