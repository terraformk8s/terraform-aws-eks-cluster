resource "random_pet" "name" {
}

locals {
  cluster_name = random_pet.name.id
  tags = {
    Name = "terraform-aws-eks-cluster test ${local.cluster_name}"
  }
  cluster_shared_tags = merge(local.tags, {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
  })
}

module "cluster" {
  source = "../../"

  name               = local.cluster_name
  kubernetes_version = ""
  subnet_ids         = aws_subnet.test.*.id

  tags = local.tags
}

module "nodes_t2_micro" {
  source = "../../modules/node-pool"

  cluster = module.cluster
  name    = "${module.cluster.name}-t2micro"

  instance_type = "t2.micro"
  desired_count = 1
  scaling = {
    min = 1
    max = 1
  }

  tags = local.tags
}

resource "aws_vpc" "test" {
  cidr_block = "10.0.0.0/16"

  tags = local.cluster_shared_tags
}

resource "aws_subnet" "test" {
  count = 2

  vpc_id     = aws_vpc.test.id
  cidr_block = cidrsubnet(aws_vpc.test.cidr_block, 1, count.index)

  tags = local.cluster_shared_tags
}

data "aws_availability_zones" "available" {
  state = "available"
}
