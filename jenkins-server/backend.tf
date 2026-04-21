terraform {
  backend "s3" {
    bucket = "tf-aws-eks-remote"
    key    = "jenkins/terraform.tfstate"
    region = "eu-north-1"
  }
}
