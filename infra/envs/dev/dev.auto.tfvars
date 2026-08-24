env            = "dev"
system         = "elasticache-poc"
vpc_cidr_block = "10.0.0.0/16"
public_subnets = {
  "us-west-2a" = "10.0.3.0/24"
  "us-west-2c" = "10.0.4.0/24"
}
private_subnets = {
  "us-west-2a" = "10.0.1.0/24"
  "us-west-2c" = "10.0.2.0/24"
}
# OIDCトークンのsubクレームの接頭辞。
github_subject_prefix = "repo:butterthon-dev@106649779/elasticache-encryption-poc@1338529116"
