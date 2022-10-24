data "aws_region" "current" {}

locals {
  environment = "develop"
  tags = {
    terraform   = true
    environment = local.environment
  }

  # visual block demo
  service_db_parameters = {
    db_host = jsondecode(data.aws_secretsmanager_secret_version.rds_cluster_secret.secret_string)["db_host"]
    db_port = jsondecode(data.aws_secretsmanager_secret_version.rds_cluster_secret.secret_string)["db_port"]
    db_user = jsondecode(data.aws_secretsmanager_secret_version.rds_cluster_secret.secret_string)["db_user"]
    db_pass = jsondecode(data.aws_secretsmanager_secret_version.rds_cluster_secret.secret_string)["db_pass"]

  }
}

module "develop_vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "2.78"

  name = "platoon-dev"
  cidr = "10.1.0.0/16"

  azs = [
    "${data.aws_region.current.name}a",
    "${data.aws_region.current.name}b",
    "${data.aws_region.current.name}c"
  ]
  private_subnets     = ["10.1.1.0/24", "10.1.2.0/24", "10.1.3.0/24"]
  database_subnets    = ["10.1.4.0/24", "10.1.5.0/24", "10.1.6.0/24"]
  elasticache_subnets = ["10.1.7.0/24", "10.1.8.0/24", "10.1.9.0/24"]
  public_subnets      = ["10.1.101.0/24", "10.1.102.0/24", "10.1.103.0/24"]

  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true
  enable_dns_support   = true

  public_subnet_tags = {
    "kubernetes.io/role/elb" = "1"
  }

  tags = local.tags
}
