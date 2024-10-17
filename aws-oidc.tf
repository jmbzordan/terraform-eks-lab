resource "aws_iam_openid_connect_provider" "oidc" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = data.tls_certificate.oidc_tls_certificate.certificates[*].sha1_fingerprint
  url             = data.tls_certificate.oidc_tls_certificate.url
  tags            = { Name = "${var.project_name}-oidc-provider" }
}