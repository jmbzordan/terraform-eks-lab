# Conforme documentação, policy necessário para criação do Load Balance Controller
# https://docs.aws.amazon.com/eks/latest/userguide/lbc-manifest.html - Documentação de instalação do AWS load balancer
# https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.7.2/docs/install/iam_policy.json - Link para JSON  da policy necessária
resource "aws_iam_policy" "lb_controller_policy" {
   name        = "${var.project_name}-load-balancer-controller"
   path        = "/"
   description = "Policy do AWS Load Balancer Controller"
   policy      = file("./iam_lb_controller_policy.json")                    # JSON da policy que será atrelada ao resource. Extraída da documentação
   tags        = { Name = "${var.project_name}-load-balancer-controller" }
}