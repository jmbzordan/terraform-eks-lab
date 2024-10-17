resource "aws_iam_policy" "lb_controller_policy" {
   name        = "${var.project_name}-load-balancer-controller"
   path        = "/"
   description = "Policy do AWS Load Balancer Controller"
   policy      = file("./iam_lb_controller_policy.json")
   tags        = { Name = "${var.project_name}-load-balancer-controller" }
}