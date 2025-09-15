output "database_host" {
  value = aws_db_instance.rds_db.address

}

output "replica_host" {
  value = aws_db_instance.rds_replica.address

}

output "db_name" {
  value = aws_db_instance.rds_db.db_name

}

output "replica_name" {
  value = aws_db_instance.rds_replica.db_name

}

output "db_endpoint" {
  value = aws_db_instance.rds_db.endpoint

}

output "db_port" {
  value       = aws_db_instance.rds_db.port
  description = "The port the database is listening on"
}

output "replica_port" {
  value       = aws_db_instance.rds_replica.port
  description = "The port the replica-database is listening on"
}

output "database_az" {
  value = aws_db_instance.rds_db.availability_zone
}

output "replica_az" {
  value = aws_db_instance.rds_replica.availability_zone
}