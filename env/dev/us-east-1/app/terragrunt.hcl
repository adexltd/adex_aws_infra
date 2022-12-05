include {
  path = find_in_parent_folders()
}
terraform {
  source = "${get_parent_terragrunt_dir()}/..//_modules/app"
}

dependencies {
  paths = ["${get_parent_terragrunt_dir()}/${local.global_environment_vars.locals.environment}/${local.regional_vars.locals.aws_region}/fabric/buckets/artifact_bucket", "${get_parent_terragrunt_dir()}/${local.global_environment_vars.locals.environment}/${local.regional_vars.locals.aws_region}/fabric/vpc", "${get_parent_terragrunt_dir()}/${local.global_environment_vars.locals.environment}/${local.regional_vars.locals.aws_region}/fabric/rds"]
}
dependency "vpc" {
  config_path = "${get_parent_terragrunt_dir()}/${local.global_environment_vars.locals.environment}/${local.regional_vars.locals.aws_region}/fabric/vpc"
}
dependency "database" {
  config_path = "${get_parent_terragrunt_dir()}/${local.global_environment_vars.locals.environment}/${local.regional_vars.locals.aws_region}/fabric/rds"
}
locals {
  global_environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  regional_vars           = read_terragrunt_config(find_in_parent_folders("region.hcl"))
  key_name                = "Sparrow-${local.global_environment_vars.locals.environment}-internal-key"

  tags = {
    Owner       = "Sparrow"
    Environment = "${local.global_environment_vars.locals.environment}"
  }
}
inputs = {
  env                       = local.global_environment_vars.locals.environment
  key_name                  = local.key_name
  vpc_id                    = dependency.vpc.outputs.vpc_id
  public_subnets            = dependency.vpc.outputs.public_subnets
  private_subnets           = dependency.vpc.outputs.private_subnets
  ami_id                    = "ami-0574da719dca65348"
  tags                      = local.tags
}