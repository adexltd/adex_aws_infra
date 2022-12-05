include {
  path = find_in_parent_folders()
}

terraform {
  source = "${get_parent_terragrunt_dir()}/..//_modules/ec2"
}

dependency "vpc" {
  config_path = "${get_parent_terragrunt_dir()}/${local.global_environment_vars.locals.environment}/${local.regional_vars.locals.aws_region}/fabric/vpc"
}
locals {
  global_environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  regional_vars           = read_terragrunt_config(find_in_parent_folders("region.hcl"))
  name   = "Sparrow-${local.global_environment_vars.locals.environment}"
  region = local.regional_vars.locals.aws_region
  tags = {
    Owner       = "Sparrow"
    Environment = "${local.global_environment_vars.locals.environment}"
  }

  ami_id = "ami-0574da719dca65348"
}

inputs = {
  name = local.name
  ami_id = local.ami_id
  vpc_id = dependency.vpc.outputs.vpc_id
  subnet_id = element(dependency.vpc.outputs.private_subnets,0)
  instance_type = "t2.micro"
  key_name ="terraform"
  tags= local.tags
}
