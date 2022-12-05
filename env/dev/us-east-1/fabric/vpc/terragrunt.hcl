include {
  path = find_in_parent_folders()
}

terraform {
  source = "${get_parent_terragrunt_dir()}/..//_modules/vpc"
}

locals {
  global_environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  region_vars           = read_terragrunt_config(find_in_parent_folders("region.hcl"))

  name   = "sparrow-${local.global_environment_vars.locals.environment}"
  region = local.region_vars.locals.aws_region
  tags = {
    Owner       = "sparrow"
    Environment = "${local.global_environment_vars.locals.environment}"
  }
}

inputs = {
  name = local.name
  cidr = "10.0.0.0/20"
  azs              = ["${local.region}a", "${local.region}c"]
  public_subnets   = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnets  = ["10.0.3.0/24", "10.0.4.0/24"]
}