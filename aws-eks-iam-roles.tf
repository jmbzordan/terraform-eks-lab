# Primeiramente criamos um IAM Role, que irá ter uma policy atrelada. Posteriormente, serão declaradas no resource Cluster e managed node
resource "aws_iam_role" "iam_cluster_role" {
   name               = "${var.project_name}-iam-cluster-role"
   assume_role_policy = jsonencode({ 
                           Version   = "2012-10-17"
                           Statement = [{ 
                             Action    = "sts:AssumeRole"
                             Effect    = "Allow"
                             Sid       = ""
                             Principal = { Service = "eks.amazonaws.com" }
                           }]
                        })
   tags               = { Name = "${var.project_name}-iam-cluster-role" }
}

# Recurso que atrela a policy já existe e apontada como necessária na documentação de criação do EKS.
# https://docs.aws.amazon.com/pt_br/eks/latest/userguide/using-service-linked-roles-eks.html
# Documentação de policies para cluster EKS
resource "aws_iam_role_policy_attachment" "cluster_role_attachment" {
   role       = aws_iam_role.iam_cluster_role.name
   policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"         #hard coded pois é um requisito do EKS e não pode ser mudada.
}

# Role para o managed group
resource "aws_iam_role" "iam_mng_role" {
   name               = "${var.project_name}-iam-managed-node-group-role"
   assume_role_policy = jsonencode({ 
                           Version   = "2012-10-17"
                           Statement = [{ 
                             Action    = "sts:AssumeRole"
                             Effect    = "Allow"
                             Sid       = ""
                             Principal = { Service = "ec2.amazonaws.com" }    # É necessário alterar para ec2
                           }]
                        })
   tags               = { Name = "${var.project_name}-iam-managed-node-group-role" }
}

# Policies que serão atreladas a role do managed node group e apontadas como requisitos pela documentação do EKS
# https://docs.aws.amazon.com/pt_br/eks/latest/userguide/using-service-linked-roles-eks-nodegroups.html
# Documentação de policies para nós EKS
resource "aws_iam_role_policy_attachment" "mng_worker_role_attachment" {
   role       = aws_iam_role.iam_mng_role.name
   policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"              #hard coded pois é um requisito do EKS e não pode ser mudada.
}


resource "aws_iam_role_policy_attachment" "mng_ecr_role_attachment" {
   role       = aws_iam_role.iam_mng_role.name
   policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"     #hard coded pois é um requisito do EKS e não pode ser mudada.
}


resource "aws_iam_role_policy_attachment" "mng_cni_role_attachment" {
   role       = aws_iam_role.iam_mng_role.name
   policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"                   #hard coded pois é um requisito do EKS e não pode ser mudada.
}