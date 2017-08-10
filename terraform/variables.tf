variable "aws_region" {
  description = "AWS EC2 Region for the VPC"
  default     = "us-west-2"
}

variable "aws_dns_zone" {
  description = "AWS Route53 zone"
}

variable "gitlab_dns_subdomain" {
  description = "Gitlab DNS subdomain"
  default     = "gitlab"
}

variable "bastion_dns_subdomain" {
  description = "Bastion DNS subdomain"
  default     = "bastion1"
}

variable "aws_az1" {
  description = "AWS EC2 availability zone 2"
  default     = "eu-west-1a"
}

variable "aws_az2" {
  description = "AWS EC2 availability zone 2"
  default     = "eu-west-1b"
}

variable "vpc_id" {
  description = "The AWS VPC to deploy to"
}

variable "gateway_id" {
  description = "The AWS Internet Gateway to use"
}

variable "public1_subnet_id" {}

variable "public2_subnet_id" {}

variable "private1_subnet_id" {}

variable "private2_subnet_id" {}

variable "sg_ssh_cidr" {
  description = "CIDR allowed for SSH connection to public subnet"
  default     = "0.0.0.0/0"
}

variable "admin_ssh_public_key" {
  description = "SSH public key to connect to EC2 instances"
}

variable "gitlab_static_instances" {
  description = "Gitlab static instances number"
  default     = 0
}

variable "gitlab_max" {
  description = "Gitlab autoscale maximum instance number"
  default     = 3
}

variable "gitlab_min" {
  description = "Gitlab autoscale minimum instance number"
  default     = 1
}

variable "gitlab_desired" {
  description = "Gitlab autoscale desired instance number"
  default     = 2
}

variable "gitlab_db_name" {
  description = "Gitlab database name"
  default     = "gitlab"
}

variable "gitlab_db_username" {
  description = "Gitlab database username"
  default     = "gitlab"
}

variable "gitlab_db_password" {
  description = "Gitlab database password"
}

variable "gitlab_root_password" {
  description = "Gitlab Root account initial password"
}

variable "gitlab_ci_registration_token" {
  description = "Gitlab initial CI registration token"
}

variable "ldap_host_name" {}
variable "ldap_bind_dn" {}
variable "ldap_password" {}
variable "ldap_base" {}

variable ci_instance_type {
  description = "The AWS instance type to use for the GitLab CI Runners"
  default     = "t2.micro"
}

variable gitlab_instance_type {
  description = "The AWS instance type to use for the main GitLab servers"
  default     = "t2.medium"
}

variable cache_instance_type {
  description = "The AWS instance type to use for the Redis Cache (ElastiCache)"
  default     = "cache.t2.small"
}

variable db_instance_type {
  description = "The AWS instance type to use for the RDS database"
  default     = "db.t2.micro"
}

variable bastion_instance_type {
  description = "The AWS instance type to use for the bastion server"
  default     = "t2.micro"
}
