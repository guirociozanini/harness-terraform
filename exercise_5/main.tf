provider "aws" {
  region     = "${var.region}"
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
  version    = "v2.70.0"
}

terraform {
  backend "s3" {
    bucket = "guilhermezanini-terraform-state"
    key    = "terraform.tfstate"
    region = "us-east-2"
  }
}

resource "aws_ecs_cluster" "ecs-cluster-1" {
  name = "${var.ecs_cluster_1}"
}

resource "aws_autoscaling_group" "ecs-autoscaling-group-1" {
  name                 = "ecs-asg-${var.ecs_cluster_1}"
  max_size             = "4"
  min_size             = "1"
  desired_capacity     = "${var.capacity}"
  vpc_zone_identifier  = ["subnet-0bacaae249a2fd391", "subnet-0bacaae249a2fd391"]
  launch_configuration = "${aws_launch_configuration.ecs-launch-configuration-1.name}"
  health_check_type    = "ELB"
}

resource "aws_launch_configuration" "ecs-launch-configuration-1" {
  name                 = "ecs-lb-${var.ecs_cluster_1}"
  image_id             = "ami-0b9a214f40c38d5eb"
  instance_type        = "t2.medium"
  iam_instance_profile = "ecsInstanceRole"

  root_block_device {
    volume_type           = "standard"
    volume_size           = 20
    delete_on_termination = true
  }

  lifecycle {
    create_before_destroy = true
  }

  security_groups             = "${var.ecs_security_groups}"
  associate_public_ip_address = "true"
  key_name                    = "harness-delegate"

  user_data = <<EOF
#!/bin/bash
echo ECS_CLUSTER=${var.ecs_cluster_1} >> /etc/ecs/ecs.config
EOF
}
