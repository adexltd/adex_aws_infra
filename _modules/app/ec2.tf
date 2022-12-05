module "ec2_instance" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 3.0"

  name = "sparrow-instance"
  ami                    = "ami-ebd02392"
  instance_type          = "t2.micro"
  key_name               = "terraform"
  monitoring             = true
  vpc_security_group_ids = #vpc id
  subnet_id              = #subnet id

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}