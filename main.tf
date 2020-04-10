terraform {
  required_version = "= 0.12.24"

  backend "s3" {
    bucket         = "homegauge-unified-terraform-state"
    key            = "unified.tfstate"
    dynamodb_table = "remote-state-lock"
    region         = "us-east-1"
  }
}

provider "aws" {
  region = var.region 
  profile = var.profile  
}



data "aws_eks_cluster_auth" "main" {
  name = aws_eks_cluster.main.name
}

provider "kubernetes" {
  host                   = aws_eks_cluster.main.endpoint
  cluster_ca_certificate = base64decode(aws_eks_cluster.main.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.main.token
  load_config_file       = false
}


data "aws_vpc" "eks" {
  tags = {
    service = "production"
  }
}


resource "aws_eks_cluster" "main" {
  name     = var.cluster-name
  role_arn = aws_iam_role.eks.arn

  vpc_config {
    security_group_ids      = [aws_security_group.eks.id]
    subnet_ids              = [data.aws_subnet.private1a.id, data.aws_subnet.private1b.id, data.aws_subnet.private1c.id]
    endpoint_private_access = true
    endpoint_public_access  = true 
  }

  depends_on = [
    aws_iam_role_policy_attachment.main-cluster-AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.main-cluster-AmazonEKSServicePolicy,
  ]
}


output "eks" {
  value = "${data.aws_vpc.eks.id}"
}


