resource "aws_db_subnet_group" "database_subnet" {
  name       = "${var.project_name}-db-subnet"
  subnet_ids = [var.pvt_subnetA, var.pvt_subnetB]
}

data "aws_availability_zones" "available" {
  state = "available"
}


resource "aws_db_instance" "rds_db" {
  identifier              = "${var.project_name}-db"
  engine                  = "mysql"
  engine_version          = "8.0.42"
  allocated_storage       = 20
  storage_type            = "gp2"
  instance_class          = "db.t3.micro"
  skip_final_snapshot     = true
  backup_retention_period = 7
  db_name                 = var.db_name

  storage_encrypted   = false
  publicly_accessible = false

  multi_az               = false
  availability_zone      = data.aws_availability_zones.available.names[0]
  db_subnet_group_name   = aws_db_subnet_group.database_subnet.id
  vpc_security_group_ids = [var.db_sg_id]

  username = var.db_username
  password = var.db_password

}

resource "aws_db_instance" "rds_replica" {
  replicate_source_db = aws_db_instance.rds_db.identifier
  instance_class      = "db.t3.micro"
  identifier          = "replica-instance"
  allocated_storage   = 20
  skip_final_snapshot = true
  #backup_retention_period = 7

  storage_encrypted   = false
  publicly_accessible = false

  multi_az          = false
  availability_zone = data.aws_availability_zones.available.names[1]

  depends_on = [aws_db_instance.rds_db]

  tags = {
    Name = "${var.project_name}-rds-replica"
  }
}