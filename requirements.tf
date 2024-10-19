terraform {
   required_version = ">= 1.3.0"        # Versão do terraform
   required_providers {
      aws        = {
         version = ">= 5.67.0"
         source  = "hashicorp/aws"
      }
      tls        = {
         version = ">= 4.0.6"
         source  = "hashicorp/tls"
      }
      kubernetes = {
         version = "2.17.0"
         source  = "hashicorp/kubernetes"
      }
      helm       = {
         version = "2.16.1"
         source  = "hashicorp/helm"
      }
   }

   backend "s3" {
      bucket = "johnz-remote-state"
      key    = "kubernetes-state/terraform.tfstate"
      region = "sa-east-1"
   }
}