# Primeiramente criamos um IAM Role, que irá ter uma policy atrelada. Posteriormente, serão declaradas no resource Cluster e managed node
# https://docs.aws.amazon.com/eks/latest/userguide/cluster-iam-role.html
# Documentação para criação da estrutura IAM cluster role
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

# https://docs.aws.amazon.com/eks/latest/userguide/create-node-role.html
# DOcumentação para criação de toda estrutura IAM de nodes EKS
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

# https://docs.aws.amazon.com/eks/latest/userguide/lbc-manifest.html
# Documentação com todo necessário de IAM para funcionamento do AWS Load Balancer
# Aqui encontramos o assume role policy para cópia. Veja abaixo que é necessário adaptar ao seu código, estruturando-o com sua variáveis onde necessário
resource "aws_iam_role" "lb_controller_role" {
   name = "${var.project_name}-lb-controller-role"

   assume_role_policy = <<EOF
   {
       "Version": "2012-10-17",
       "Statement": [{
          "Effect": "Allow",
          "Principal": {
             "Federated": "arn:aws:iam::${data.aws_caller_identity.current_caller_identity.account_id}:oidc-provider/oidc.eks.${data.aws_region.current_region.name}.amazonaws.com/id/${local.oidc_issuer}"
          },
          "Action": "sts:AssumeRoleWithWebIdentity",
          "Condition": {
             "StringEquals": {
                "oidc.eks.${data.aws_region.current_region.name}.amazonaws.com/id/${local.oidc_issuer}:aud": "sts.amazonaws.com",
                "oidc.eks.${data.aws_region.current_region.name}.amazonaws.com/id/${local.oidc_issuer}:sub": "system:serviceaccount:kube-system:aws-load-balancer-controller"
             }
          }
       }]
   }
   EOF
   tags = { Name = "${var.project_name}-iam-managed-node-group-role" }
}