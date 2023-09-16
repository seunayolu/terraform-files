/*provider "kubernetes" {
  # load_config_file = "false"
  host = data.aws_eks_cluster.class-eks.endpoint
  token = data.aws_eks_cluster_auth.class-eks-auth.token
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.class-eks.certificate_authority.0.data)
}

data "aws_eks_cluster" "class-eks" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "class-eks-auth" {
  name = module.eks.cluster_id
}*/

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "19.16.0"

  cluster_name = "class-eks-cluster"
  cluster_version = "1.27"

  subnet_ids = module.vpc.private_subnets
  vpc_id = module.vpc.vpc_id

  tags = {
    environment = "development"
    application = "class-eks"
  }

  eks_managed_node_groups = {
    dev = {
      min_size = 1
      max_size = 3
      desired_size = 3

      instance_types = ["t2.small"]
    }
  }

}