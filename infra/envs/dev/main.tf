locals {
  name_prefix = "${var.env}-${var.system}"
  #   aws_account_id = data.aws_caller_identity.current.account_id
  #   region         = data.aws_region.current.region
}

# data "aws_caller_identity" "current" {}
# data "aws_region" "current" {}

module "network" {
  source = "../../stacks/core-network"

  name_prefix     = local.name_prefix
  vpc_cidr_block  = var.vpc_cidr_block
  public_subnets  = var.public_subnets
  private_subnets = var.private_subnets
}

module "compute" {
  source = "../../stacks/compute"

  env                           = var.env
  name_prefix                   = local.name_prefix
  vpc_id                        = module.network.vpc_id
  vpc_cidr_block                = var.vpc_cidr_block
  private_subnet_ids            = module.network.private_subnet_ids
  public_subnet_ids             = module.network.public_subnet_ids
  gateway_vpce_prefix_list_maps = module.network.gateway_vpce_prefix_list_maps
  hosted_zone_name              = "viz.butterthon-dev.jp"
  backend_domain                = "api.viz.butterthon-dev.jp"
}

module "cicd" {
  source = "../../stacks/cicd"

  name_prefix           = local.name_prefix
  github_subject_prefix = var.github_subject_prefix
  github_allowed_refs   = var.github_allowed_refs
  ecs_service_arns      = [module.compute.backend_service_arn]
  pass_role_arns = [
    module.compute.backend_task_role_arn,
    module.compute.backend_task_execution_role_arn,
  ]
}
