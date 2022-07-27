resource "yandex_compute_instance" "srv02db01" {
  name                      = "srv02db01"
  zone                      = "ru-central1-a"
  hostname                  = "db01.${var.my_domain}"
  platform_id               = "standard-v2"
  allow_stopping_for_update = true

  resources {
    cores  = 4
    memory = 4
    core_fraction = local.instance_type[terraform.workspace]
  }

  boot_disk {
    initialize_params {
      image_id    = "${var.ubuntu-latest}"
      name        = "root-srv02db01"
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
    ip_address = "10.36.1.9"
  }

  metadata = {
    ssh-keys = "ubuntu:${file("~/.ssh/id_yc.pub")}"
  }
}
