# Resource helm, responsavel por instalar pacotes no kubernetes. Basta pegar o exemplo na documantação e alterá-lo para o pacote desejado
# https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release - Documentação do provider
# https://docs.aws.amazon.com/eks/latest/userguide/lbc-helm.html - Documentação dos passos para instalação do load balancer controller pelo Helm, ou sejá, com infos do helm para utilizar nesse resource como repositório
resource "helm_release" "helm_controller" {
  name       = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  version    = "1.4.7"                                   # helm search repo aws-load-balancer-controller para pegar versão do chart

  set {                                                  # Aqui os sets podem ser vistos la documentacao no step 2, item 3
    name  = "clusterName"
    value = aws_eks_cluster.cluster_eks.name
  }

  set {
    name  = "serviceAccount.create"
    value = "true"
  }

  set {
    name  = "serviceAccount.name"
    value = "aws-load-balancer-controller"
  }
}