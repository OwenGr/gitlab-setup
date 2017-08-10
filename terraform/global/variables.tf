variable "aws_dns_zone" {
  description = "AWS Route53 zone"
}

variable "bastion_dns_subdomain" {
  description = "Bastion DNS subdomain"
  default     = "bastion1"
}

variable "aws_az1" {
  description = "AWS EC2 availability zone 2"
  default     = "us-west-2a"
}

variable "aws_az2" {
  description = "AWS EC2 availability zone 2"
  default     = "us-west-2b"
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
  default     = "50.201.227.0/24"
}

variable "admin_ssh_public_key" {
  description = "SSH public key to connect to EC2 instances"
}

variable "bastion_instance_type" {}
