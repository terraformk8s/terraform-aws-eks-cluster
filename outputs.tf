output "name" {
  value = aws_eks_cluster.main.name
}

output "vpc_id" {
  value = aws_eks_cluster.main.vpc_config[0].vpc_id
}

output "subnet_ids" {
  value = toset(aws_eks_cluster.main.vpc_config[0].subnet_ids)
}

output "kubernetes_version" {
  value = aws_eks_cluster.main.version
}

output "control_plane_security_group_id" {
  value = aws_security_group.cluster.id
}

output "node_iam_role_name" {
  value = aws_iam_role.node.name

  # Make sure all of the policies are attached before we consider the role ready.
  depends_on = [
    aws_iam_role_policy_attachment.node_worker,
    aws_iam_role_policy_attachment.node_cni,
    aws_iam_role_policy_attachment.node_container_registry,
    kubernetes_config_map.aws_map_roles,
  ]
}

output "hostname" {
  value = aws_eks_cluster.main.endpoint
}
