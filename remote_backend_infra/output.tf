output "s3_bucket" {
  value = aws_s3_bucket.tf-state-bucket.arn

}

output "dynamodb_table_name" {
  value = aws_dynamodb_table.terraform_locks.name

}