include {
  path = find_in_parent_folders()
}

terraform {
  source = "${get_parent_terragrunt_dir()}/../_modules/alb"
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

}

inputs = {
  name = local.name
  vpc_id = dependency.vpc.outputs.vpc_id
  subnet_ids = dependency.vpc.outputs.public_subnets
  #certificate_arn = "insert certificate arn"
  tags= local.tags
}
