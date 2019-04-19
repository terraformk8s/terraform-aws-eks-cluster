variable "name" {
  type = string
}

variable "enabled_cluster_log_types" {
  type    = set(string)
  default = []
}

variable "kubernetes_version" {
  type    = "string"
  default = null
}

variable "subnet_ids" {
  type    = set(string)
}

variable "tags" {
  type    = map(string)
  default = {}
}

data "aws_subnet" "selected" {
  count = length(var.subnet_ids)

  id = tolist(var.subnet_ids)[count.index]
}
