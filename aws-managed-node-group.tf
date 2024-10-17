resource "aws_eks_node_group" "mng" {
   depends_on = [
      aws_iam_role_policy_attachment.mng_worker_role_attachment,
      aws_iam_role_policy_attachment.mng_cni_role_attachment,
      aws_iam_role_policy_attachment.mng_ecr_role_attachment
   ]
   # Verificar na documentação os argumentos disponíveis para declaração como tipo da instancia, etc.
   cluster_name       = aws_eks_cluster.cluster_eks.name
   node_group_name    = "Managed-Node-Group"
   node_role_arn      = aws_iam_role.iam_mng_role.arn
   subnet_ids         = local.private_subnet_list
   scaling_config {
      desired_size    = 1
      max_size        = 1
      min_size        = 1
   }
   update_config {
      max_unavailable = 1
   }
   tags               = { Name = "${var.project_name}-managed-node-group" }
}