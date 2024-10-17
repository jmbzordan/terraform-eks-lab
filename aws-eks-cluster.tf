resource "aws_eks_cluster" "cluster_eks" {
   name                      = "${var.project_name}-cluster"
   role_arn                  = aws_iam_role.iam_cluster_role.arn

   vpc_config {
      subnet_ids              = local.public_subnet_list    # Subnets publicas onde será criado o cluster EKS. Lembrando que EKS é a parte do control plane, ao qual o usuário se conectar pelo kubectl com a API server.
      endpoint_private_access = true                        # Necessário que o cluster EKS seja um endpoint privado, para comunicação interna entre eks e data plane (worker nodes), e qualquer comunicação vinda de dentro da VPC
      endpoint_public_access  = true                        # Porém também é necessário que ele seja um endpoint publico, para comunicação externa
   }
  
   # Ensure that IAM Role permissions are created before and deleted after EKS Cluster handling.
   # Otherwise, EKS will not be able to properly delete EKS managed EC2 infrastructure such as Security Groups.
   depends_on                = [ aws_iam_role_policy_attachment.cluster_role_attachment ]
   tags                      = { Name = "${var.project_name}-cluster" }
}