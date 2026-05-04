terraform {
  required_version = ">= 1.6.0"

  required_providers {
    ovh = {
      source  = "ovh/ovh"
      version = "~> 0.40"
    }
  }

  #   backend "s3" {
  #     bucket                      = "terraform-state"
  #     key                         = "ovh/terraform.tfstate"
  #     region                      = "ovh"
  #     endpoint                    = "s3.de2.io.cloud.ovh.net"
  #     skip_credentials_validation = true
  #     skip_requesting_account_id  = true
  #     skip_metadata_api_check     = true
  #     force_path_style            = true
  #   }
}

provider "ovh" {
  endpoint           = var.ovh_endpoint
  application_key    = var.ovh_application_key
  application_secret = var.ovh_application_secret
  consumer_key       = var.ovh_consumer_key
}
