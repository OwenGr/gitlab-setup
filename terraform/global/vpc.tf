data "aws_vpc" "gitlab" {
  id = "${var.vpc_id}"
}

data "aws_internet_gateway" "default" {
  internet_gateway_id = "${var.gateway_id}"
}

/********************/
/*  Public subnets */
/********************/

/*  Public subnet 1 */

data "aws_subnet" "public1" {
  id = "${var.public1_subnet_id}"
}

/*  Public subnet 2 */
data "aws_subnet" "public2" {
  id = "${var.public2_subnet_id}"
}

/********************/
/*  Private subnets */
/********************/

/* private subnet 1 */
data "aws_subnet" "private1" {
  id = "${var.private1_subnet_id}"
}

/* private subnet 2 */
data "aws_subnet" "private2" {
  id = "${var.private2_subnet_id}"
}

/* NAT Gateway between subnets */

resource "aws_eip" "nat1" {
  vpc = true
}

resource "aws_nat_gateway" "nat1" {
  allocation_id = "${aws_eip.nat1.id}"
  subnet_id     = "${data.aws_subnet.public1.id}"
}

resource "aws_eip" "nat2" {
  vpc = true
}

resource "aws_nat_gateway" "nat2" {
  allocation_id = "${aws_eip.nat2.id}"
  subnet_id     = "${data.aws_subnet.public2.id}"
}

/* Elastic IPs */

resource "aws_eip" "bastion1" {
  vpc      = true
  instance = "${aws_instance.bastion1.id}"
}
