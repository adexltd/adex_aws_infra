resource "aws_security_group" "ec2_security_group" {
  name        = "${var.name}-sg"
  description = "EC2 security group"
  vpc_id      = var.vpc_id
}

resource "aws_security_group_rule" "ec2_security_group_http" {
  type              = "ingress"
  security_group_id = aws_security_group.ec2_security_group.id

  from_port   = 80
  to_port     = 80
  protocol    = "TCP"
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "ec2_security_group_https" {
  type              = "ingress"
  security_group_id = aws_security_group.ec2_security_group.id

  from_port   = 443
  to_port     = 443
  protocol    = "TCP"
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "ec2_security_group_ssh" {
  type              = "ingress"
  security_group_id = aws_security_group.ec2_security_group.id

  from_port   = 22
  to_port     = 22
  protocol    = "TCP"
  cidr_blocks = ["202.229.192.169/32"]
}

resource "aws_security_group_rule" "ec2_security_group_ssh_ashok" {
  type              = "ingress"
  security_group_id = aws_security_group.ec2_security_group.id

  from_port   = 22
  to_port     = 22
  protocol    = "TCP"
  cidr_blocks = ["202.51.76.202/32"]
}

resource "aws_security_group_rule" "ec2_security_group_egress" {
  security_group_id = aws_security_group.ec2_security_group.id

  type        = "egress"
  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]
}


# IAM Role
resource "aws_iam_role" "ec2_iam_role" {
  name               = "${var.name}-role"
  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "sts:AssumeRole",
            "Principal": {
               "Service": "ec2.amazonaws.com"
            },
            "Effect": "Allow",
            "Sid": ""
        }
    ]
}
EOF

  tags = merge(
    var.tags,
    {
      Name = "${var.name}-role"
    }
  )
}
# attach AWS managed policy to the role
resource "aws_iam_role_policy_attachment" "ec2_role_ssm" {
  role       = aws_iam_role.ec2_iam_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "${var.name}-profile"
  role = aws_iam_role.ec2_iam_role.name
}

resource "aws_instance" "ec2" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [aws_security_group.ec2_security_group.id]
  iam_instance_profile   = aws_iam_instance_profile.ec2_profile.id
  key_name               = var.key_name

  root_block_device {
    volume_size = var.ebs_volume_size
    volume_type = "gp3"
    encrypted   = true
  }

  volume_tags = merge(
    var.tags, {
      Name = var.name,
  })

  tags = merge(
    var.tags, {
      Name = var.name
    },
  )
}
