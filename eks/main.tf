# ====================== VPC ======================
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"     # Add this line - important

  name = "jenkins-vpc2"
  cidr = var.vpc_cidr

  azs             = data.aws_availability_zones.azs.names
  private_subnets = var.private_subnets
  public_subnets  = var.public_subnets

  enable_dns_hostnames = true
  enable_dns_support   = true

  # === CRITICAL FOR NAT GATEWAY ===
  enable_nat_gateway     = true
  single_nat_gateway     = true
  enable_vpn_gateway     = false

  # This is the missing piece in most cases
  create_igw             = true

  # Optional but recommended
  map_public_ip_on_launch = true

  public_subnet_tags = {
    "kubernetes.io/cluster/my-eks-cluster" = "shared"
    "kubernetes.io/role/elb"               = "1"
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/my-eks-cluster" = "shared"
    "kubernetes.io/role/internal-elb"      = "1"
  }

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}

# ====================== EKS ======================
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 21.0"

  name                    = "my-eks-cluster"
  kubernetes_version      = "1.33"
  create_cloudwatch_log_group = false

  endpoint_public_access  = true
  endpoint_private_access = true

  enable_cluster_creator_admin_permissions = true

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  eks_managed_node_groups = {
    nodes = {
      min_size       = 1
      max_size       = 3
      desired_size   = 2

      instance_types = ["t3.small"]

      disk_size = 30
    }
  }

  tags = {
    Environment = "dev"
    Terraform   = "true"
  }
}