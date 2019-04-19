variable "name" {
  type = string
}

variable "instance_type" {
  type = string
}

variable "gpu_support" {
  type    = bool
  default = false
}

variable "cluster" {
  type = object({
    name                            = string
    vpc_id                          = string
    subnet_ids                      = set(string)
    control_plane_security_group_id = string
    node_iam_role_name              = string
    kubernetes_version              = string
  })
}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "scaling" {
  type = object({
    min = number
    max = number
  })
}

variable "desired_count" {
  type    = number
  default = null
}

module "ami" {
  source = "../ami"

  kubernetes_version = var.cluster.kubernetes_version
  gpu_support        = var.gpu_support
}

locals {
  cluster_owned_tags = merge(var.tags, {
    "kubernetes.io/cluster/${var.cluster.name}" = "owned"
  })
}
