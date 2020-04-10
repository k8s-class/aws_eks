resource "aws_security_group" "eks" {
  name        = "terraform-eks"
  description = "Cluster communication with worker nodes"
  vpc_id      = data.aws_vpc.eks.id 

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [
      data.aws_subnet.private1a.cidr_block,
      data.aws_subnet.private1b.cidr_block,
      data.aws_subnet.private1c.cidr_block,
    ]
  }
}

resource "aws_security_group" "main-node" {
  name        = "terraform-eks-main-node"
  description = "Security group for all nodes in the cluster"
  vpc_id      = data.aws_vpc.eks.id 

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group_rule" "main-node-ingress-self" {
  type              = "ingress"
  description       = "Allow node to communicate with each other"
  from_port         = 0
  protocol          = "-1"
  security_group_id = aws_security_group.main-node.id
  to_port           = 65535
  cidr_blocks       = [
    data.aws_subnet.private1a.cidr_block,
    data.aws_subnet.private1b.cidr_block,
    data.aws_subnet.private1c.cidr_block,
  ]
}

resource "aws_security_group_rule" "main-node-ingress-cluster" {
  type                     = "ingress"
  description              = "Allow worker Kubelets and pods to receive communication from the cluster control plane"
  from_port                = 1025
  protocol                 = "tcp"
  security_group_id        = aws_security_group.main-node.id
  source_security_group_id = aws_security_group.eks.id
  to_port                  = 65535
}


