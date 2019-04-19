
resource "aws_eks_cluster" "main" {
  name                      = var.name
  role_arn                  = aws_iam_role.service.arn
  enabled_cluster_log_types = var.enabled_cluster_log_types

  vpc_config {
    subnet_ids         = var.subnet_ids
    security_group_ids = aws_security_group.cluster.*.id
  }
}

resource "aws_security_group" "cluster" {
  name = var.name

  # All subnets are required to belong to the same VPC. We don't actually
  # enforce that here, but the remote API will, so we'll just take the first
  # one and let the apply fail if the user produced a mismatched set of subnets.
  vpc_id = data.aws_subnet.selected[0].vpc_id
}
