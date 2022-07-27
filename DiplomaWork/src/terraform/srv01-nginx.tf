resource "yandex_compute_instance" "srv01nginx" {
  name                      = "srv01nginx"
  zone                      = "ru-central1-b"
  hostname                  = "${var.my_domain}"
  platform_id               = "standard-v2"
  allow_stopping_for_update = true

  resources {
    cores  = 2
    memory = 2
    core_fraction = local.instance_type[terraform.workspace]
  }

  boot_disk {
    initialize_params {
      image_id    = "${var.ubuntu-nat}"
      name        = "root-srv01nginx"
      type        = "network-nvme"
      size        = "10"
    }
  }

  scheduling_policy {
    preemptible = true
  }

  network_interface {
    subnet_id = "${yandex_vpc_subnet.pub-subnet.id}"
    nat       = true
    ip_address = "10.36.0.8"
  }

  metadata = {
    ssh-keys = "ubuntu:${file("~/.ssh/id_yc.pub")}"
  }
}

