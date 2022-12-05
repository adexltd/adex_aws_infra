terraform_version_constraint  = ">= 0.13"
terragrunt_version_constraint = ">= 0.25"
locals {
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  region_vars = read_terragrunt_config(find_in_parent_folders("region.hcl"))
  env_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))

  account_name         = local.account_vars.locals.account_name
  aws_profile          = local.account_vars.locals.aws_profile
  account_id           = local.account_vars.locals.aws_account_id
  aws_region           = local.region_vars.locals.aws_region
  tf_state_bucket_name = "${get_env("TG_BUCKET_PREFIX", "sparrow-bucket")}-terraform-state-${local.account_name}-${local.aws_region}"
}
# Generate an AWS provider block
generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
provider "aws" {
  region = "${local.aws_region}"
  profile= "${local.aws_profile}" 
}
EOF
}
# Configure Terragrunt to automatically store tfstate files in an S3 bucket
remote_state {
  backend = "s3"
  config = {
    encrypt        = true
    bucket         = "${local.tf_state_bucket_name}"
    key            = "${path_relative_to_include()}/terraform.tfstate"
    region         = local.aws_region
    profile        = local.aws_profile
    dynamodb_table = "terraform-locks"
    s3_bucket_tags = {
      managedby = "Terragrunt"
      }
  }
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
}

inputs = merge(
  local.account_vars.locals,
  local.region_vars.locals,
  local.env_vars.locals,
  { "tf_state_bucket_name" = local.tf_state_bucket_name }
)
