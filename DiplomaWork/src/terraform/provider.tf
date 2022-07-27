# Provider
terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
  required_version = ">= 0.13"
  
  backend "s3" {
    endpoint   = "storage.yandexcloud.net"
    bucket     = "*****-netology"
    region     = "ru-central1"
    key        = "./status.tfstate"
    access_key = "*****2XdDu-h5d5jLPBU*****"
    secret_key = "*****8MiqPFHwVw_bxkaeVM2yzjYhJv6Otn*****"
    skip_region_validation      = true
    skip_credentials_validation = true
  }
}

provider "yandex" {
  token     = "*****Ay-YW1AATuwVxuQMvpEUfekNq1T8*****"
  cloud_id  = "*****uebcnuet27*****"
  folder_id = "*****1btgl0dgp4*****"
}
