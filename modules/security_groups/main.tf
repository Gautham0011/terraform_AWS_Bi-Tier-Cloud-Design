locals {
  http_port    = 80
  any_port     = 0
  any_protocol = "-1"
  tcp_protocol = "tcp"
  all_ips      = "0.0.0.0/0"
}

# load balancer security group
resource "aws_security_group" "alb_sg" {
  name        = "${var.project_name}-alb-sg"
  description = "Allow http public facing traffic"
  vpc_id      = var.vpc_id

}

resource "aws_security_group_rule" "allow_http_inbound" {
  type              = "ingress"
  security_group_id = aws_security_group.alb_sg.id

  from_port   = local.http_port
  to_port     = local.http_port
  protocol    = local.tcp_protocol
  cidr_blocks = [local.all_ips]

}

resource "aws_vpc_security_group_egress_rule" "allow_all_outbound" {
  security_group_id = aws_security_group.alb_sg.id

  # from_port   = local.any_port
  # to_port     = local.any_port
  ip_protocol = local.any_protocol
  cidr_ipv4   = local.all_ips

}

# EC2 ASG security group
resource "aws_security_group" "asg_sg" {
  name        = "${var.project_name}-asg-sg"
  description = "Allow LB traffic ASG"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = local.http_port
    to_port     = local.http_port
    protocol    = local.tcp_protocol
    cidr_blocks = [local.all_ips]
  }

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = local.tcp_protocol
    cidr_blocks = [
      var.pvt_subnetA,
      var.pvt_subnetB
    ]
  }

  egress {
    from_port   = local.any_port
    to_port     = local.any_port
    protocol    = local.any_protocol
    cidr_blocks = [local.all_ips]
  }

}

# DB security group
resource "aws_security_group" "db_sg" {
  name        = "${var.project_name}-db-sg"
  description = "Enable mysql access on port 3306 from ec2"
  vpc_id      = var.vpc_id

}

resource "aws_vpc_security_group_ingress_rule" "allow_db_inbound" {
  security_group_id            = aws_security_group.db_sg.id
  referenced_security_group_id = aws_security_group.asg_sg.id
  from_port                    = 3306
  ip_protocol                  = local.tcp_protocol
  to_port                      = 3306
}

resource "aws_vpc_security_group_egress_rule" "allow_db_outbound" {
  security_group_id = aws_security_group.db_sg.id
  cidr_ipv4         = local.all_ips
  ip_protocol       = local.any_protocol
}