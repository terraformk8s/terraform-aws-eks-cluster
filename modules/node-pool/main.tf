resource "aws_launch_configuration" "main" {
  name_prefix   = var.name
  image_id      = module.ami.id
  instance_type = var.instance_type

  security_groups      = [aws_security_group.node.id]
  iam_instance_profile = aws_iam_instance_profile.main.name

  user_data = <<-EOT
    #!/bin/bash
    set -o xtrace
    /etc/eks/bootstrap.sh "${var.cluster.name}"
  EOT

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "main" {
  name_prefix          = var.name
  launch_configuration = aws_launch_configuration.main.name

  min_size         = var.scaling.min
  max_size         = var.scaling.max
  desired_capacity = var.desired_count

  vpc_zone_identifier = var.cluster.subnet_ids

  dynamic "tag" {
    for_each = local.cluster_owned_tags
    content {
      key   = tag.key
      value = tag.value

      propagate_at_launch = true
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_iam_instance_profile" "main" {
  name_prefix = var.name
  role        = var.cluster.node_iam_role_name
}

resource "aws_security_group" "node" {
  vpc_id      = var.cluster.vpc_id
  name_prefix = var.name

  ingress {
    description = "Allow nodes to communicate with each other"

    self      = true

    protocol  = "-1"
    from_port = 0
    to_port   = 0
  }
  egress {
    cidr_blocks = ["0.0.0.0/0"]
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
  }

  ingress {
    description = "Allow incoming messages from the cluster control plane"

    security_groups = [var.cluster.control_plane_security_group_id]

    protocol  = "tcp"
    from_port = 1025
    to_port   = 65535
  }
  egress {
    description = "Allow pods running extension API servers on port 443 to receive communication from cluster control plane"

    security_groups = [var.cluster.control_plane_security_group_id]

    protocol  = "tcp"
    from_port = 443
    to_port   = 443
  }

  tags = local.cluster_owned_tags

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group_rule" "control_plane_to_node" {
  security_group_id = var.cluster.control_plane_security_group_id

  description = "Allow control plane to communicate with nodes in pool ${var.name}"

  type                     = "egress"
  source_security_group_id = aws_security_group.node.id

  protocol  = "tcp"
  from_port = 1025
  to_port   = 65535
}

resource "aws_security_group_rule" "control_plane_to_node_443" {
  security_group_id = var.cluster.control_plane_security_group_id

  description = "Allow the cluster control plane to communicate with pods running extension API servers on port 443 in pool ${var.name}"

  type                     = "egress"
  source_security_group_id = aws_security_group.node.id

  protocol  = "tcp"
  from_port = 443
  to_port   = 443
}

resource "aws_security_group_rule" "node_to_control_plane" {
  security_group_id = var.cluster.control_plane_security_group_id

  description = "Allow nodes in pool ${var.name} to communicate with control plane API server"

  type                     = "ingress"
  source_security_group_id = aws_security_group.node.id

  protocol  = "tcp"
  from_port = 443
  to_port   = 443
}
