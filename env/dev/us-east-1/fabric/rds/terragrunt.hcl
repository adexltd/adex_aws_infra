include {
  path = find_in_parent_folders()
}

terraform {
  source = "${get_parent_terragrunt_dir()}/..//_modules/rds"
}

dependency "vpc" {
  config_path = "${get_parent_terragrunt_dir()}/${local.global_environment_vars.locals.environment}/${local.regional_vars.locals.aws_region}/fabric/vpc"
}

locals {
  global_environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  regional_vars           = read_terragrunt_config(find_in_parent_folders("region.hcl"))

  identifier   = "Sparrow-${local.global_environment_vars.locals.environment}"
  region = local.regional_vars.locals.aws_region
  tags = {
    Owner       = "Sparrow"
    Environment = "${local.global_environment_vars.locals.environment}"
  }
}

inputs = {
  identifier                              = local.identifier
  vpc_id                            = dependency.vpc.outputs.vpc_id
  subnet_ids                        = dependency.vpc.outputs.database_subnets
  instance_class                    = "db.t3.micro"
  cidr_blocks_to_allow_access_to_db = dependency.vpc.outputs.private_subnets_cidr_blocks
  tags                              = local.tags
}
