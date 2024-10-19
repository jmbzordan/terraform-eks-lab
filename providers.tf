provider "aws" {
   region = "sa-east-1"
}

provider "tls" {   
}

# Provider necessário para conectar no cluster EKS criado e criar uma Service Account
# Pode ser usado para criar qualquer recurso de kubernetes no cluster EKS
# https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs -- Documentação do provider 
provider "kubernetes" {
   host                    = aws_eks_cluster.cluster_eks.endpoint                                        # Atributo "endpoint" do resource aws_eks_cluster
   cluster_ca_certificate  = base64decode(aws_eks_cluster.cluster_eks.certificate_authority[0].data)             # Atributo "certificate_authority" do resource aws_eks_cluster
   exec {
      api_version          = "client.authentication.k8s.io/v1beta1"                                     # kubectl api-resources
      args                 = ["eks", "get-token", "--cluster-name", aws_eks_cluster.cluster_eks.name]   # Argumentos internos. Não é necessário alterar
      command              = "aws"                                                                      # Client AWS
   }
}

# Declaração do provider Helm, gerenciador de pacotes para o kubernetes responsável por instalar pacotes no cluster kubernetes
# https://registry.terraform.io/providers/hashicorp/helm/latest/docs
# Provider se autentica no clustere da mesma forma que o provider kubernetes
provider "helm" {
   kubernetes {
      host                    = aws_eks_cluster.cluster_eks.endpoint                                        # Atributo "endpoint" do resource aws_eks_cluster
      cluster_ca_certificate  = base64decode(aws_eks_cluster.cluster_eks.certificate_authority[0].data)     # Atributo "certificate_authority" do resource aws_eks_cluster
      exec {
         api_version          = "client.authentication.k8s.io/v1beta1"                                     # kubectl api-resources
         args                 = ["eks", "get-token", "--cluster-name", aws_eks_cluster.cluster_eks.name]   # Argumentos internos. Não é necessário alterar
         command              = "aws"                                                                      # Client AWS
      }
   }
}