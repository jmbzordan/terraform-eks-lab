# Key Pair usado idealmente em primeiro momento quando se pensava em criar um k8s manualmente. Porém a ideia foi ajustada para um EKS.

# Cria um key pair para ser usado no ASG
resource "aws_key_pair" "key_pair" {
   key_name   = "k8s-key"
   public_key = file("./keys/aws-key.pub")
}
