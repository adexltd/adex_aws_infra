resource "random_pet" "server" {
  keepers = {
    # Generate a new pet name each time we switch to a new AMI id
    ami_id = var.ami_id != null ? var.ami_id : chomp(trimspace(data.aws_s3_bucket_object.ami_id_file.body))
  }
}

resource "random_id" "id" {
  keepers = {
    # Generate a new pet name each time we switch to a new AMI id
    ami_id = var.ami_id != null ? var.ami_id : chomp(trimspace(data.aws_s3_bucket_object.ami_id_file.body))
  }
  byte_length = 6
}
resource "aws_launch_template" "launch_template" {
  name_prefix = "Sparrow-${var.env}-alt-internal-${random_id.id.id}"
  # image_id    = var.ami_id != null ? var.ami_id : data.aws_s3_bucket_object.ami_id_file.body
  image_id = random_pet.server.keepers.ami_id

  block_device_mappings {
    device_name = "/dev/sda1"

    ebs {
      volume_size           = 25
      delete_on_termination = true
    }
  }
  iam_instance_profile {
    arn = aws_iam_instance_profile.instance_profile.arn
  }
  monitoring {
    enabled = true
  }
  instance_type                        = var.instance_type
  instance_initiated_shutdown_behavior = "terminate"
  key_name                             = var.key_name
  user_data                            = base64encode(data.template_file.script.rendered)
  vpc_security_group_ids               = [aws_security_group.instance.id]

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "Sparrow-${var.env}-api-server"
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "asg" {
  name_prefix      = "Sparrow-${var.env}-asg-internal--${aws_launch_template.launch_template.name}"
  min_size         = var.min_size
  max_size         = var.max_size
  desired_capacity = var.desired_capacity
  launch_template {
    id      = aws_launch_template.launch_template.id
    version = aws_launch_template.launch_template.latest_version
  }
  vpc_zone_identifier = var.private_subnets
  instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = 50
    }
  }
  target_group_arns = [aws_lb_target_group.tg.arn]
  # lifecycle {
  #   ignore_changes = [desired_capacity, target_group_arns]
  # }
  lifecycle {
    create_before_destroy = true
  }

  tag {
    key                 = "Name"
    value               = "Sparrow-${var.env}-asg-internal"
    propagate_at_launch = true
  }
  # depends_on = [aws_autoscaling_attachment.asg_attachement]

  force_delete = true
}

# resource "aws_autoscaling_attachment" "asg_attachement" {
#   autoscaling_group_name = aws_autoscaling_group.asg.id
#   alb_target_group_arn   = aws_lb_target_group.tg.arn
# }

########################################################
# Scaling
# Down
resource "aws_autoscaling_policy" "scale_down" {
  name                   = "Sparrow-${var.env}-asp-scale_down"
  autoscaling_group_name = aws_autoscaling_group.asg.name
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = -1
  cooldown               = 120
}

resource "aws_cloudwatch_metric_alarm" "scale_down" {
  alarm_name          = "Sparrow-${var.env}-scale_down"
  alarm_description   = "Monitors CPU utilization for api_server ASG"
  alarm_actions       = [aws_autoscaling_policy.scale_down.arn]
  comparison_operator = "LessThanOrEqualToThreshold"
  namespace           = "AWS/EC2"
  metric_name         = "CPUUtilization"
  threshold           = "10"
  evaluation_periods  = "2"
  period              = "120"
  statistic           = "Average"

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.asg.name
  }
}
# up
resource "aws_autoscaling_policy" "scale_up" {
  name                   = "Sparrow-${var.env}-asp-scale_up"
  autoscaling_group_name = aws_autoscaling_group.asg.name
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = -1
  cooldown               = 120
}

resource "aws_cloudwatch_metric_alarm" "scale_up" {
  alarm_name          = "Sparrow-${var.env}-scale_up"
  alarm_description   = "Monitors CPU utilization for api_server ASG"
  alarm_actions       = [aws_autoscaling_policy.scale_down.arn]
  comparison_operator = "GreaterThanOrEqualToThreshold"
  namespace           = "AWS/EC2"
  metric_name         = "CPUUtilization"
  threshold           = "70"
  evaluation_periods  = "2"
  period              = "120"
  statistic           = "Average"

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.asg.name
  }
}
