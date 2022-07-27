resource "yandex_compute_instance" "srv05gitlab" {
  name                      = "srv05gitlab"
  zone                      = "ru-central1-a"
  hostname                  = "gitlab.${var.my_domain}"
  platform_id               = "standard-v2"
  allow_stopping_for_update = true

  resources {
    cores  = 4
    memory = 8
    core_fraction = local.instance_type[terraform.workspace]
  }

  boot_disk {
    initialize_params {
      image_id    = "${var.ubuntu-latest}"
      name        = "root-srv05gitlab"
      type        = "network-nvme"
      size        = "10"
    }
  }

  scheduling_policy {
    preemptible = true
  }

  network_interface {
    subnet_id = "${yandex_vpc_subnet.priv-subnet.id}"
#    nat       = true
    ip_address = "10.36.1.12"
  }

  metadata = {
    ssh-keys = "ubuntu:${file("~/.ssh/id_yc.pub")}"
  }
}

