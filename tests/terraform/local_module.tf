module "local" {
  source = "./module"
}

module "another_local" {
  source = "../another/module"
}

module "remote" {
  source = "terraform-aws-modules/vpc/aws"
  version = "3.14.2"
}
