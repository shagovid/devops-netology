resource "yandex_compute_instance" "srv06runner" {
  name                      = "srv06runner"
  zone                      = "ru-central1-a"
  hostname                  = "runner.${var.my_domain}"
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
      name        = "root-srv06runner"
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
    ip_address = "10.36.1.13"
  }

  metadata = {
    ssh-keys = "ubuntu:${file("~/.ssh/id_yc.pub")}"
  }
}

