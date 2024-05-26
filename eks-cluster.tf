module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = var.clusterName
  cluster_version = "1.29"

  cluster_endpoint_public_access = true

  cluster_addons = {
    coredns = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent = true
    }
  }

  vpc_id                   = module.vpc.vpc_id
  subnet_ids               = module.vpc.private_subnets
  control_plane_subnet_ids = module.vpc.public_subnets

  tags = {
    environment = "development"
    application = "classeks"
  }

  eks_managed_node_groups = {
    class_one = {
      min_size     = 2
      max_size     = 4
      desired_size = 2

      instance_types = [var.instance_type[2]]
    }
  }

  # Cluster Access Entry

  enable_cluster_creator_admin_permissions = true
  authentication_mode                      = "API_AND_CONFIG_MAP"

  /*access_entries = {
    darey_eks = {
      kubernetes_group = []
      principal_arn = "arn:aws:iam::249269726433:role/MasterClass-eksClusterRole"

      policy_associations = {
        darey_eks = {
          policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSViewPolicy"
          access_scope = {
            namespaces = ["default"]
            type = "namespace"
          }
        }
      }
    }
  }*/
}