data "aws_ami" "gitlab" {
  owners      = ["self"]
  most_recent = true

  filter {
    name   = "tag:application"
    values = ["gitlab"]
  }
}

resource "aws_iam_role" "gitlab_iam_role" {
  name = "gitlab_iam_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "gitlab_iam_role_policy" {
  name = "gitlab_iam_role_policy"
  role = "${aws_iam_role.gitlab_iam_role.id}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": ["s3:ListBucket"],
      "Resource": ["arn:aws:s3:::${aws_s3_bucket.gitlab_init.bucket}"]
    },
    {
      "Effect": "Allow",
      "Action": [
        "s3:GetObject"
      ],
      "Resource": ["arn:aws:s3:::${aws_s3_bucket.gitlab_init.bucket}/gitlab/*"]
    }
  ]
}
EOF
}

resource "aws_iam_instance_profile" "gitlab_instance_profile" {
  name = "gitlab_instance_profile"
  role = "${aws_iam_role.gitlab_iam_role.name}"
}

resource "aws_security_group" "gitlab" {
  name        = "gitlab"
  description = "Allow inbound traffic on gitlab instances"
  vpc_id      = "${var.vpc_id}"

  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "TCP"
    security_groups = ["${var.sg_bastions_id}"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_launch_configuration" "gitlab" {
  name_prefix          = "gitlab-autoscale-"
  image_id             = "${data.aws_ami.gitlab.id}"
  instance_type        = "${var.gitlab_instance_type}"
  key_name             = "${var.admin_ssh_key}"
  security_groups      = ["${aws_security_group.gitlab.id}"]
  iam_instance_profile = "${aws_iam_instance_profile.gitlab_instance_profile.id}"

  user_data = <<EOF
#cloud-config
runcmd:
  - aws s3 cp --recursive s3://gitlab-init-secret/gitlab/ /root/launch
  - cd /root/launch
  - bash ./gitlab_bootstrap.sh

output: { all : '| tee -a /var/log/cloud-init-output.log' }
EOF

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [
    "aws_efs_file_system.gitlab_data",
    "aws_efs_mount_target.gitlab1",
    "aws_efs_mount_target.gitlab2",
    "aws_elasticache_cluster.gitlab_cache",
    "aws_db_instance.gitlab",
    "aws_s3_bucket.gitlab_init",
    "aws_s3_bucket_object.gitlab_env_yml",
    "aws_s3_bucket_object.gitlab_env_sh",
    "aws_s3_bucket_object.gitlab_config",
    "aws_s3_bucket_object.gitlab_bootstrap",
  ]
}

resource "aws_autoscaling_group" "gitlab" {
  name                      = "gitlab"
  max_size                  = "${var.gitlab_max}"
  min_size                  = "${var.gitlab_min}"
  desired_capacity          = "${var.gitlab_desired}"
  vpc_zone_identifier       = ["${var.private_subnet_ids["private1"]}", "${var.private_subnet_ids["private2"]}"]
  health_check_grace_period = 300
  health_check_type         = "ELB"
  default_cooldown          = 300
  force_delete              = true
  load_balancers            = ["${aws_elb.gitlab.name}"]
  launch_configuration      = "${aws_launch_configuration.gitlab.name}"
  wait_for_capacity_timeout = "15m"

  lifecycle {
    create_before_destroy = true
  }

  tag {
    key                 = "application"
    value               = "gitlab"
    propagate_at_launch = true
  }

  tag {
    key                 = "Name"
    value               = "gitlab-autoscale"
    propagate_at_launch = true
  }

  depends_on = [
    "aws_efs_file_system.gitlab_data",
    "aws_efs_mount_target.gitlab1",
    "aws_efs_mount_target.gitlab2",
    "aws_elasticache_cluster.gitlab_cache",
    "aws_db_instance.gitlab",
    "aws_s3_bucket.gitlab_init",
    "aws_s3_bucket_object.gitlab_env_yml",
    "aws_s3_bucket_object.gitlab_env_sh",
    "aws_s3_bucket_object.gitlab_config",
    "aws_s3_bucket_object.gitlab_bootstrap",
  ]
}

resource "aws_elb_attachment" "gitlab" {
  count    = "${var.gitlab_static_instances}"
  elb      = "${aws_elb.gitlab.id}"
  instance = "${element(aws_instance.gitlab.*.id, count.index)}"
}

resource "aws_instance" "gitlab" {
  count                                = "${var.gitlab_static_instances}"
  ami                                  = "${data.aws_ami.gitlab.id}"
  instance_type                        = "${var.gitlab_instance_type}"
  associate_public_ip_address          = false
  subnet_id                            = "${var.private_subnet_ids["private1"]}"
  vpc_security_group_ids               = ["${aws_security_group.gitlab.id}"]
  instance_initiated_shutdown_behavior = "terminate"
  key_name                             = "${var.admin_ssh_key}"
  iam_instance_profile                 = "${aws_iam_instance_profile.gitlab_instance_profile.id}"

  user_data = <<EOF
#cloud-config
runcmd:
  - aws s3 cp --recursive s3://gitlab-init-secret/gitlab/ /root/launch
  - cd /root/launch
  - bash ./gitlab_bootstrap.sh

output: { all : '| tee -a /var/log/cloud-init-output.log' }
EOF

  tags {
    Name        = "gitlab-static-${count.index + 1}"
    application = "gitlab"
  }

  depends_on = [
    "aws_efs_file_system.gitlab_data",
    "aws_efs_mount_target.gitlab1",
    "aws_efs_mount_target.gitlab2",
    "aws_elasticache_cluster.gitlab_cache",
    "aws_db_instance.gitlab",
    "aws_s3_bucket.gitlab_init",
    "aws_s3_bucket_object.gitlab_env_yml",
    "aws_s3_bucket_object.gitlab_env_sh",
    "aws_s3_bucket_object.gitlab_config",
    "aws_s3_bucket_object.gitlab_bootstrap",
  ]
}
