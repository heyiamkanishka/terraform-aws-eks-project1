terraform {
  backend "s3" {
    bucket = "tf-aws-eks-remote"
    key    = "eks/terraform.tfstate"
    region = "eu-north-1"
  }
}
