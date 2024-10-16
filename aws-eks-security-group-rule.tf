# Não é necessário criar security group pois o EKS já cria automaticamente um security group. É necessário injetar uma regra para que ele aceite conexão externa na 443 somente
# Para isso será necessário criar um resource aws_security_group_rule
resource "aws_security_group_rule" "security_group_rule" {
   depends_on        = [ aws_eks_cluster.cluster_eks ]
   type              = "ingress"
   from_port         = 443
   to_port           = 443 
   protocol          = "tcp"
   cidr_blocks       = [ aws_vpc.vpc.cidr_block ]
   security_group_id = aws_eks_cluster.cluster_eks.vpc_config[0].cluster_security_group_id
}