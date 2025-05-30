# VPC for Cluster
data "aws_availability_zones" "azs" {}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.2"

  name = var.name
  cidr = var.vpc_cidr_block

  azs             = data.aws_availability_zones.azs.names
  private_subnets = var.private_subnet_cidr_blocks
  public_subnets  = var.public_subnet_cidr_blocks

  enable_nat_gateway     = true
  single_nat_gateway     = true
  one_nat_gateway_per_az = false

  public_subnet_tags = {
    "kubernetes.io/role/elb"            = 1
    "kubernetes.io/cluster/${var.name}" = "shared"
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb"   = 1
    "kubernetes.io/cluster/${var.name}" = "shared"
  }

}

# EKS Cluster
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.3"

  cluster_name                   = var.name
  cluster_version                = var.k8s_version
  cluster_endpoint_public_access = true

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  create_cluster_security_group = false
  create_node_security_group    = false

  enable_cluster_creator_admin_permissions = true

  cluster_addons = {
    coredns = {
      most_recent = true
    }
    eks-pod-identity-agent = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent = true
    }
  }

  eks_managed_node_groups = {
    eks-node = {
      instance_types = ["t3.medium"]
      min_size       = 2
      max_size       = 4
      desired_size   = 2
    }
  }

  tags = {
    "kubernetes.io/cluster/${var.name}" = "shared"
  }
}

module "eks_blueprints_addons" {
  source  = "aws-ia/eks-blueprints-addons/aws"
  version = "~> 1.21" #ensure to update this to the latest/desired version

  cluster_name      = module.eks.cluster_name
  cluster_endpoint  = module.eks.cluster_endpoint
  cluster_version   = module.eks.cluster_version
  oidc_provider_arn = module.eks.oidc_provider_arn

  enable_aws_load_balancer_controller = true
  enable_karpenter                    = true
  enable_kube_prometheus_stack        = true

  aws_load_balancer_controller = {
    chart         = "aws-load-balancer-controller"
    chart_version = "1.13.2"
    repository    = "https://aws.github.io/eks-charts"
    namespace     = "kube-system"
    values = [
      yamlencode({
        clusterName = module.eks.cluster_name
        region      = var.aws_region
        vpcId       = module.vpc.vpc_id
      })
    ]
  }

  kube_prometheus_stack = {
    chart         = "kube-prometheus-stack"
    chart_version = "72.7.0"
    repository    = "https://prometheus-community.github.io/helm-charts"
    namespace     = "monitoring"
    values = [
      yamlencode({
        grafana = {
          adminPassword = "admin"
          ingress = {
            enabled = true
            ingressClassName = "alb"
            annotations = {
              "alb.ingress.kubernetes.io/scheme"                             = "internet-facing"
              "alb.ingress.kubernetes.io/target-type"                        = "ip"
              "alb.ingress.kubernetes.io/certificate-arn"                    = "arn:aws:acm:eu-west-2:442042522885:certificate/9067718a-f937-44fe-9bd9-0b62ad9ff251"
              "alb.ingress.kubernetes.io/listen-ports"                       = "[{\"HTTP\": 80}, {\"HTTPS\": 443}]"
              "alb.ingress.kubernetes.io/ssl-redirect"                       = "443"
              "alb.ingress.kubernetes.io/group.name"                         = "my-alb"
              "alb.ingress.kubernetes.io/conditions.grafana-teachdev-online" = "[{\"field\":\"source-ip\",\"sourceIpConfig\":{\"values\":[\"105.113.52.90/32\"]}}]"
            }
            hosts = ["grafana.teachdev.online"]
            path  = "/"
          }
        }
        prometheus = {
          prometheusSpec = {
            serviceMonitorSelectorNilUsesHelmValues = false
            serviceMonitorSelector = {
              matchLabels = {
                "release" = "kube-prometheus-stack"
              }
            }
          }
        }
      })
    ]
  }

  tags = {
    "kubernetes.io/cluster/${var.name}" = "shared"
  }
}

module "ecr" {
  source  = "terraform-aws-modules/ecr/aws"
  version = "2.4.0"

  repository_name    = var.ecr_repo
  registry_scan_type = "BASIC"
  repository_type    = "private"

  create_lifecycle_policy         = false
  repository_image_tag_mutability = "MUTABLE"

  tags = {
    Terraform = "true"
  }
}