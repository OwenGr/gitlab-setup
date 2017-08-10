provider "aws" {
  region = "${var.aws_region}"
}

module "global" {
  source = "./global"

  aws_dns_zone          = "${var.aws_dns_zone}"
  bastion_dns_subdomain = "${var.bastion_dns_subdomain}"
  aws_az1               = "${var.aws_az1}"
  aws_az2               = "${var.aws_az2}"
  vpc_id                = "${var.vpc_id}"
  gateway_id            = "${var.gateway_id}"
  public1_subnet_id     = "${var.public1_subnet_id}"
  public2_subnet_id     = "${var.public2_subnet_id}"
  private1_subnet_id    = "${var.private1_subnet_id}"
  private2_subnet_id    = "${var.private2_subnet_id}"
  sg_ssh_cidr           = "${var.sg_ssh_cidr}"
  admin_ssh_public_key  = "${var.admin_ssh_public_key}"
  bastion_instance_type = "${var.bastion_instance_type}"
}

module "gitlab" {
  source = "./gitlab"

  aws_region                   = "${var.aws_region}"
  aws_dns_zone                 = "${var.aws_dns_zone}"
  gitlab_max                   = "${var.gitlab_max}"
  gitlab_min                   = "${var.gitlab_min}"
  gitlab_static_instances      = "${var.gitlab_static_instances}"
  gitlab_desired               = "${var.gitlab_desired}"
  gitlab_db_name               = "${var.gitlab_db_name}"
  gitlab_db_username           = "${var.gitlab_db_username}"
  gitlab_db_password           = "${var.gitlab_db_password}"
  gitlab_root_password         = "${var.gitlab_root_password}"
  gitlab_ci_registration_token = "${var.gitlab_ci_registration_token}"
  public1_subnet_id            = "${var.public1_subnet_id}"
  public2_subnet_id            = "${var.public2_subnet_id}"
  ldap_host_name               = "${var.ldap_host_name}"
  ldap_bind_dn                 = "${var.ldap_bind_dn}"
  ldap_password                = "${var.ldap_password}"
  ldap_base                    = "${var.ldap_base}"

  admin_ssh_key      = "${module.global.admin_ssh_key}"
  vpc_id             = "${module.global.vpc_id}"
  dns_zone_id        = "${module.global.dns_zone_id}"
  dns_zone_name      = "${module.global.dns_zone_name}"
  sg_bastions_id     = "${module.global.sg_bastions_id}"
  private_subnet_ids = "${module.global.private_subnet_ids}"
  public_subnet_ids  = "${module.global.public_subnet_ids}"

  public1_subnet_cidr = "${module.global.public1_subnet_cidr}"
  public2_subnet_cidr = "${module.global.public2_subnet_cidr}"

  gitlab_instance_type = "${var.gitlab_instance_type}"
  ci_instance_type     = "${var.ci_instance_type}"
  cache_instance_type  = "${var.cache_instance_type}"
  db_instance_type     = "${var.db_instance_type}"
}

/*
module "gitlab_ci" {
  source               = "./gitlab_ci"

  gitlab_host  = "${module.gitlab.gitlab_hostname}"
  gitlab_ci_registration_token = "${var.gitlab_ci_registration_token}"
  gitlab_init_bucket = "${module.gitlab.gitlab_init_bucket}"

  admin_ssh_key = "${module.global.admin_ssh_key}"
  vpc_id = "${module.global.vpc_id}"
  dns_zone_id = "${module.global.dns_zone_id}"
  dns_zone_name = "${module.global.dns_zone_name}"
  sg_bastions_id = "${module.global.sg_bastions_id}"
  sg_gitlab_id = "${module.gitlab.sg_gitlab_id}"
  private_subnet_ids = "${module.global.private_subnet_ids}"
}
/**/

