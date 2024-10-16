resource "aws_iam_role" "iam_role" {
   name               = "${var.project_name}-iam-role"
   assume_role_policy = jsonencode({ 
                           Version   = "2012-10-17"
                           Statement = [{ 
                             Action    = "sts:AssumeRole"
                             Effect    = "Allow"
                             Sid       = ""
                             Principal = { Service = "eks.amazonaws.com" }
                           }]
                        })
   tags               = { Name = "${var.project_name}-iam-role" }
}


resource "aws_iam_role_policy_attachment" "cluster_role_attachment" {
   role       = aws_iam_role.iam_role.name
   policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"         #hard coded pois é um requisito do EKS e não pode ser mudada.
}