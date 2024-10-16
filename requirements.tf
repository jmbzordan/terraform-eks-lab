terraform {
   required_version = ">= 1.3.0"
   required_providers {
     aws            = {
                         version = ">= 5.67.0"
                         source  = "hashicorp/aws"
     }

     tls            = {
                         version = ">= 4.0.6"
                         source  = "hashicorp/tls"
     }
   }

   backend "s3" {
      bucket = "johnz-remote-state"
      key    = "kubernetes-state/terraform.tfstate"
      region = "sa-east-1"
   }
}