data "aws_ami" "eks_node" {
  owners      = ["602401143452"]
  most_recent = true

  filter {
    name   = "name"
    values = [
      var.gpu_support ? "amazon-eks-gpu-node-${var.kubernetes_version}-*" : "amazon-eks-node-${var.kubernetes_version}-*"
    ]
  }
}
