data "aws_eks_cluster_auth" "main" {
  name = aws_eks_cluster.main.name
}

provider "kubernetes" {
  host                   = aws_eks_cluster.main.endpoint
  cluster_ca_certificate = base64decode(aws_eks_cluster.main.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.main.token
  load_config_file       = false
}

resource "kubernetes_config_map" "aws_map_roles" {
  metadata {
    name      = "aws-auth"
    namespace = "kube-system"
  }

  # This configures the K8S cluster to allow API requests from any EC2 instances
  # that hold our node role.
  data = {
    mapRoles = <<-EOT
      - rolearn: ${aws_iam_role.node.id}
        username: system:node:{{EC2PrivateDNSName}}
        groups:
          - system:bootstrappers
          - system:nodes
    EOT
  }
}
