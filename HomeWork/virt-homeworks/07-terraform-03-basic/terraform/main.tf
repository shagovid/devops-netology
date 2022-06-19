terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }

  backend "s3" {
    endpoint   = "storage.yandexcloud.net"
    bucket     = "shagovid-netology"
    region     = "ru-central1"
    key        = "workspaces/terraform.tfstate"
    access_key = "YCAJE2XdDu-h5d5jLPBUVV***"
    secret_key = "YCPXp8MiqPFHwVw_bxkaeVM2yzjYhJv6Otnl6***"

    skip_region_validation      = true
    skip_credentials_validation = true
  }
}

provider "yandex" {
  token     = "AQAAAAAy-YW1AATuwVxuQMvpEUfekNq1T8Y6***"
  cloud_id  = "b1gnfuebcnuet27p3***"
  folder_id = "b1ggs1btgl0dgp4le***"
  zone      = "ru-central1-a"
}

// Говорим Терраформу где искать образ для виртуальной машины
data "yandex_compute_image" "ubuntu" {
  family = "ubuntu-2004-lts"
}
data "yandex_compute_image" "centos" {
  family = "centos-7"
}
data "yandex_compute_image" "fedora" {
  family = "fedora-35"
}

// Создаем ресурсы, в зависимости от типа workspace
resource "yandex_compute_instance" "netology" {
  name = "terraform1"
  platform_id = "standard-v1"
  zone        = "ru-central1-a"

  resources {
    cores  = 2
    memory = 2
  }

  boot_disk {
    initialize_params {
      image_id = "fd89ovh4ticpo40dkbvd"
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.subnet_netology.id
    nat = true
  }

 /* metadata = {
    ssh-keys = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
  }*/
}

// Создаем несколько ресурсом с помощью цикла for_each
resource "yandex_compute_instance" "netology2" {
  for_each = local.instance_count2
  name = "${terraform.workspace}-${each.key}"
  platform_id = "standard-v1"
  zone        = "ru-central1-a"

  resources {
    cores  = 2
    memory = 2
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.fedora.id
      type = "network-hdd"
      size = 20
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.subnet_netology.id
    nat = true
  }

 /*  metadata = {
    ssh-keys = "user:${file("~/.ssh/id_rsa.pub")}"
  }*/

  allow_stopping_for_update = true

  lifecycle {
    create_before_destroy = true
  }
}

// Создаем частную сеть
resource "yandex_vpc_network" "network_netology" {
  name = terraform.workspace
}

//Создаем частную подсеть
resource "yandex_vpc_subnet" "subnet_netology" {
  name           = terraform.workspace
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.network_netology.id
  v4_cidr_blocks = ["10.128.0.0/24"]
}

// Переменные определяющие количество установок instance в зависимости от типа workspace
locals {
  instance_count = {
    stage = 1
    prod = 2
  }
}

// Переменные определяющие версию ОС в зависимости от типа workspace
locals {
  instance_type = {
    stage = data.yandex_compute_image.ubuntu.id
    prod = data.yandex_compute_image.centos.id
  }
}

// Переменные для цикла for_each
locals {
  instance_count2 = toset([
    "fedora1",
    "fedora2",
  ])
}