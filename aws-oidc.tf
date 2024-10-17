/*
Recurso necessário para habilitar função IAM role para service account, ou seja, aplicar uma role para uma service account de uma aplicação. 
Esse recurso é utilizado pelo AWS Load Balance Controller, logo deve ser habilitado
Para criarmos esse recurso, é necessário definir um resource aws_iam_openid_connect_provider no terraform. Esse resource requer um argumento 
chamado "thumbprint_list" que é uma lista de thumbprints de certificados de servidores para o certificado de servidores do OpenID Connect identity provider.
Para extrair a thumbprint_list em terraform, é utilizado um data.tls_certificate conforme documentação do terraform Segue a implementação juntamente com a
declaração do datasource em datasources.tf
*/
resource "aws_iam_openid_connect_provider" "oidc" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = data.tls_certificate.oidc_tls_certificate.certificates[*].sha1_fingerprint
  url             = data.tls_certificate.oidc_tls_certificate.url
  tags            = { Name = "${var.project_name}-oidc-provider" }
}