# launch template for ec2 instances
resource "aws_launch_template" "launch_template" {
  name          = "${var.project_name}-template"
  image_id      = var.ami
  instance_type = var.instance_type

  #this public key pair must be created manually on the AWS UI and you need to download the private key to you local machine to use it to ssh to the ec2 instances
  key_name = "test"

  block_device_mappings {
    device_name = "/dev/sdd"

    ebs {
      volume_type           = "gp3"
      volume_size           = 8
      delete_on_termination = true
    }
  }

  user_data = base64encode(templatefile("${path.module}/user_data.sh", {
    server_port = var.server_port
    db_name     = var.db_name
    #db_address = var.db_address
    db_endpoint     = var.db_endpoint
    db_port         = var.db_port
    db_az           = var.db_az
    replica_name    = var.replica_name
    replica_address = var.replica_address
    replica_port    = var.replica_port
    replica_az      = var.replica_az
    #server_text = var.server_text
  }))

  # user_data = base64encode(<<-EOF
  #         #!/bin/bash
  #         yum install -y httpd
  #         systemctl enable httpd
  #         systemctl start httpd

  #         echo "Hello from $(hostname)" > /var/www/html/index.html
  #         EOF
  #)

  vpc_security_group_ids = [var.asg_sg_id]

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "optional"
    http_put_response_hop_limit = 10
  }

  lifecycle {
    create_before_destroy = true
  }

}

# Auto scaling groups to spin up ec2 instaces in two AZs
resource "aws_autoscaling_group" "asg" {

  name             = "${var.project_name}-ASG"
  min_size         = var.min_size
  max_size         = var.max_size
  desired_capacity = 2
  region           = var.aws_region

  health_check_grace_period = 300
  health_check_type         = "ELB"

  target_group_arns = [var.target_group_arn]


  vpc_zone_identifier = [
    var.public_subnet_A_id,
    var.public_subnet_B_id
  ]

  launch_template {
    id      = aws_launch_template.launch_template.id
    version = "$Latest"
  }

  # lifecycle {
  #   create_before_destroy = true
  # }

  instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = 50
    }
  }
}

resource "aws_autoscaling_schedule" "scale_out_during_business_hours" {
  count = var.enable_autscaling ? 1 : 0

  scheduled_action_name = "${var.project_name}-scale-out-during-business-hours"
  min_size              = 2
  max_size              = 10
  desired_capacity      = 4
  recurrence            = "0 9 * * *"

  autoscaling_group_name = aws_autoscaling_group.asg.name

}

resource "aws_autoscaling_schedule" "scale_in_at_night" {
  count = var.enable_autscaling ? 1 : 0

  scheduled_action_name = "${var.project_name}-scale-in-at-night"
  min_size              = 2
  max_size              = 20
  desired_capacity      = 2
  recurrence            = "0 17 * * *"

  autoscaling_group_name = aws_autoscaling_group.asg.name
}