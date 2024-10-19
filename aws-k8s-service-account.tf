resource "kubernetes_service_account" "k8s_sa" {
   metadata {
      name = "terraform-example"
      namespace = "kube-system"
      annotations = {
         "eks.amazonaws.com/role-arn" = aws_iam_role.lb_controller_role.arn
      }
   }
}