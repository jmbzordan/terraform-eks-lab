data "tls_certificate" "oidc_tls_certificate" {
   url = aws_eks_cluster.cluster_eks.identity[0].oidc[0].issuer
}

/*
 # Data conectara na URL e irá extrair as informações de certificado
 # Output para aws_eks_cluster.example.identity[0]
 
 oidc = tolist([
    {
       "oidc" = tolist([ 
          {
             "issuer" = "https://oidc.eks.us.sa-east-1.amazonaws.com/id/ "hash"
          },   
       ])
    }
 ])
*/