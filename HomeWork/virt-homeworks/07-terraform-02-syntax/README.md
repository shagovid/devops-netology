# Домашнее задание к занятию "7.2. Облачные провайдеры и синтаксис Terraform." (Вариант с Yandex.Cloud).

Зачастую разбираться в новых инструментах гораздо интересней понимая то, как они работают изнутри. 
Поэтому в рамках первого *необязательного* задания предлагается завести свою учетную запись в Yandex.Cloud. 

## Задача 1. Регистрация в ЯО и знакомство с основами.

1. Подробная инструкция на русском языке содержится [здесь](https://cloud.yandex.ru/docs/solutions/infrastructure-management/terraform-quickstart).
2. Обратите внимание на период бесплатного использования после регистрации аккаунта. 
3. Используйте раздел "Подготовьте облако к работе" для регистрации аккаунта. Далее раздел "Настройте провайдер" для подготовки
базового терраформ конфига.
4. Воспользуйтесь [инструкцией](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs) на сайте терраформа, что бы 
не указывать авторизационный токен в коде, а терраформ провайдер брал его из переменных окружений.
```bash
curl https://storage.yandexcloud.net/yandexcloud-yc/install.sh | bash
    После завершения установки перезапустите командную оболочку.

user@user-VPCSB2X9R:~$ yc init
Welcome! This command will take you through the configuration process.
Pick desired action:
 [1] Re-initialize this profile 'default' with new settings 
 [2] Create a new profile
Please enter your numeric choice: 1
Please go to https://oauth.yandex.ru/authorize?response_type=token&client_id=1a6990aa636648e9b2ef855fa7bec2fb in order to obtain OAuth token.

Please enter OAuth token: [AQAAAAAy-*********************q1T8Y6Mn4] 
You have one cloud available: 'cloud-shagovid' (id = b1gnfuebcnuet27p3hqi). It is going to be used by default.
Please choose folder to use:
 [1] default (id = b1ggs1btgl0dgp4ledfs)
 [2] Create a new folder
Please enter your numeric choice: 1
Your current folder has been set to 'default' (id = b1ggs1btgl0dgp4ledfs).
Do you want to configure a default Compute zone? [Y/n] Y
Which zone do you want to use as a profile default?
 [1] ru-central1-a
 [2] ru-central1-b
 [3] ru-central1-c
 [4] Don't set default zone
Please enter your numeric choice: 1
Your profile default Compute zone has been set to 'ru-central1-a'.
```

## Задача 2. Создание aws ec2 или yandex_compute_instance через терраформ. 

1. В каталоге `terraform` вашего основного репозитория, который был создан в начале курсе, создайте файл `main.tf` и `versions.tf`.
2. Зарегистрируйте провайдер 
   Для [yandex.cloud](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs). Подробную инструкцию можно найти 
   [здесь](https://cloud.yandex.ru/docs/solutions/infrastructure-management/terraform-quickstart).
3. Внимание! В гит репозиторий нельзя пушить ваши личные ключи доступа к аккаунту. Поэтому в предыдущем задании мы указывали
их в виде переменных окружения. 
```bash 
user@user-VPCSB2X9R:~/HW$ cat main.tf
provider "yandex" {
  token     = var.yandex_token
  cloud_id  = var.yandex_cloud_id
  folder_id = var.yandex_folder_id
  zone      = var.yandex_zone_default
}

user@user-VPCSB2X9R:~/HW$ cat versions.tf
terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
  required_version = ">= 0.13"


}

vagrant@server2:~/homework-tf-02/syntax$ cat variables.tf 
# Заменить на ID своего облака
# https://console.cloud.yandex.ru/cloud?section=overview
variable "yandex_cloud_id" {
  default = "b1ghsk460b4nn8sps0p2"
}

# Заменить на Folder своего облака
# https://console.cloud.yandex.ru/cloud?section=overview
variable "yandex_folder_id" {
  default = "b1gq9soqejoerr49t4a4"
}


#Зона размещения инфраструктуры по-умолчанию
variable "yandex_zone_default" {
  default = "ru-central1-a"
}

#Токен. вообще можно взять из yc config list
#variable "yandex_token" {
#  default = "token here not recommended, use cli"
# example bash: TF_VAR_yandex_token=("XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX") terraform plan 
#}
variable "yandex_token" {
  type = string
}

# Заменить на ID своего образа
# ID можно узнать с помощью команды yc compute image list
variable "ubuntu" {
  default = "fd89ovh4ticpo40dkbvd"
}

```
4. В файле `main.tf` воспользуйтесь блоком `data "aws_ami` для поиска ami образа последнего Ubuntu.  
```bash
user@user-VPCSB2X9R:~/HW$ yc compute image list --folder-id standard-images | grep ubuntu-2004-lts
| fd89ka9p6idl8htbmhok | ubuntu-20-04-lts-v20220124                                     | ubuntu-2004-lts                                 | f2eei02oardlpedocvan           | READY  |
| fd89ovh4ticpo40dkbvd | ubuntu-20-04-lts-v20220530                                     | ubuntu-2004-lts                                 | f2ek1vhoppg2l2afslmq           | READY  |                       
..................

user@user-VPCSB2X9R:~/HW$ yc compute image get fd89ovh4ticpo40dkbvd
id: fd89ovh4ticpo40dkbvd
folder_id: standard-images
created_at: "2022-05-30T10:45:00Z"
name: ubuntu-20-04-lts-v20220530
description: ubuntu 20.04 lts
family: ubuntu-2004-lts
storage_size: "4651483136"
min_disk_size: "5368709120"
product_ids:
- f2ek1vhoppg2l2afslmq
status: READY
os:
  type: LINUX
pooled: true

```
5. В файле `main.tf` создайте ресурс [yandex_compute_image](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/compute_image).
```bash
user@user-VPCSB2X9R:~/HW$ cat main.tf 
provider "yandex" {
  token     = var.yandex_token
  cloud_id  = var.yandex_cloud_id
  folder_id = var.yandex_folder_id
  zone      = var.yandex_zone_default
}


resource "yandex_compute_instance" "vm-1" {
  name = "terraform1"
  platform_id = "standard-v1"
  hostname    = "tf1.netology.ru"
  
  resources {
    cores  = 2
    memory = 2
  }

  boot_disk {
    initialize_params {
      image_id = var.ubuntu
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.subnet-1.id
    nat       = true
  }

  metadata = {
    ssh-keys  = "${file("~/.ssh/id_rsa.pub")}"
    user-data = "${file("~/HW/user-meta.txt")}"
  }
}


resource "yandex_vpc_network" "network-1" {
  name = "network1"
}

resource "yandex_vpc_subnet" "subnet-1" {
  name           = "subnet1"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.network-1.id
  v4_cidr_blocks = ["192.168.10.0/24"]
}

```


6. Также в случае использования aws:
   1. Добавьте data-блоки `aws_caller_identity` и `aws_region`.
   2. В файл `outputs.tf` поместить блоки `output` с данными об используемых в данный момент: 
       * AWS account ID,
       * AWS user ID,
       * AWS регион, который используется в данный момент, 
       * Приватный IP ec2 инстансы,
       * Идентификатор подсети в которой создан инстанс.  
```bash
user@user-VPCSB2X9R:~/HW$ cat outputs.tf 
output "internal_ip_address_vm_1" {
  value = yandex_compute_instance.vm-1.network_interface.0.ip_address
}

output "external_ip_address_vm_1" {
  value = yandex_compute_instance.vm-1.network_interface.0.nat_ip_address
}

output "subnet-1" {
  value = yandex_vpc_subnet.subnet-1.id
}

data "yandex_iam_user" "admin" {
  login = "xxxxxxxxxxxxxxxxx@yandex.ru"
}

output "yandex_iam_user" {
  value = "${data.yandex_iam_user.admin.user_id}"
}

data "yandex_iam_service_account" "builder" {
  name = "my-robot"
}

output "yandex_iam_service_account" {
  value = "${data.yandex_iam_service_account.builder.service_account_id}"
}

```
7. Если вы выполнили первый пункт, то добейтесь того, что бы команда `terraform plan` выполнялась без ошибок. 
```bash
user@user-VPCSB2X9R:~/HW$ terraform init

Initializing the backend...

Initializing provider plugins...
- Finding latest version of yandex-cloud/yandex...
- Installing yandex-cloud/yandex v0.75.0...
- Installed yandex-cloud/yandex v0.75.0 (unauthenticated)

Terraform has created a lock file .terraform.lock.hcl to record the provider
selections it made above. Include this file in your version control repository
so that Terraform can guarantee to make the same selections by default when
you run "terraform init" in the future.

Terraform has been successfully initialized!

You may now begin working with Terraform. Try running "terraform plan" to see
any changes that are required for your infrastructure. All Terraform commands
should now work.

If you ever set or change modules or backend configuration for Terraform,
rerun this command to reinitialize your working directory. If you forget, other
commands will detect it and remind you to do so if necessary.


user@user-VPCSB2X9R:~/HW$ terraform plan
var.yandex_token
  Enter a value: AQAAAAAy-YW1AATuwVxuQMvpEUfekNq1T8Y6***


Terraform used the selected providers to generate the following execution plan.
Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # yandex_compute_instance.vm-1 will be created
  + resource "yandex_compute_instance" "vm-1" {
      + created_at                = (known after apply)
      + folder_id                 = (known after apply)
      + fqdn                      = (known after apply)
      + hostname                  = "tf1.netology.ru"
      + id                        = (known after apply)
      + metadata                  = {
          + "ssh-keys"  = <<-EOT
                ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDLrKBwEo+0GcNWpQ1TW/jtqgYcqO+W5AZ7rPXsoigBYOIb9JKbRakXpNOOgBgmLq1W/d91MCX9AR6ER5Qp8cdOAEPpXvMXzzKceO++52CoRUN0gfL/e5i/TMr9dXN4rLXEn4WG1lnmzVfhXm7kxem3b73DExnhwRDsR1XEsTiWn+o5h3wqMzRW/wo1Iqk1pQKOa3jaxWumyIspHuVJvlXYiVt/67P2WbYUAsVxDl6f/jqusI0OuucmzsADa5BfFhXPa627LfPEr6PptuXSSdOmpHlgMNCc8Am0HzEw2j8U6++vnz8em9ePG+WUqmCXcwHTy0o9+MqZ47ERz4+aC*** user@user-VPCSB2X9R
            EOT
          + "user-data" = ""
        }
      + name                      = "terraform1"
      + network_acceleration_type = "standard"
      + platform_id               = "standard-v1"
      + service_account_id        = (known after apply)
      + status                    = (known after apply)
      + zone                      = (known after apply)

      + boot_disk {
          + auto_delete = true
          + device_name = (known after apply)
          + disk_id     = (known after apply)
          + mode        = (known after apply)

          + initialize_params {
              + block_size  = (known after apply)
              + description = (known after apply)
              + image_id    = "fd89ovh4ticpo40dkbvd"
              + name        = (known after apply)
              + size        = (known after apply)
              + snapshot_id = (known after apply)
              + type        = "network-hdd"
            }
        }

      + network_interface {
          + index              = (known after apply)
          + ip_address         = (known after apply)
          + ipv4               = true
          + ipv6               = (known after apply)
          + ipv6_address       = (known after apply)
          + mac_address        = (known after apply)
          + nat                = true
          + nat_ip_address     = (known after apply)
          + nat_ip_version     = (known after apply)
          + security_group_ids = (known after apply)
          + subnet_id          = (known after apply)
        }

      + placement_policy {
          + host_affinity_rules = (known after apply)
          + placement_group_id  = (known after apply)
        }

      + resources {
          + core_fraction = 100
          + cores         = 2
          + memory        = 2
        }

      + scheduling_policy {
          + preemptible = (known after apply)
        }
    }

  # yandex_vpc_network.network-1 will be created
  + resource "yandex_vpc_network" "network-1" {
      + created_at                = (known after apply)
      + default_security_group_id = (known after apply)
      + folder_id                 = (known after apply)
      + id                        = (known after apply)
      + labels                    = (known after apply)
      + name                      = "network1"
      + subnet_ids                = (known after apply)
    }

  # yandex_vpc_subnet.subnet-1 will be created
  + resource "yandex_vpc_subnet" "subnet-1" {
      + created_at     = (known after apply)
      + folder_id      = (known after apply)
      + id             = (known after apply)
      + labels         = (known after apply)
      + name           = "subnet1"
      + network_id     = (known after apply)
      + v4_cidr_blocks = [
          + "192.168.10.0/24",
        ]
      + v6_cidr_blocks = (known after apply)
      + zone           = "ru-central1-a"
    }

Plan: 3 to add, 0 to change, 0 to destroy.

Changes to Outputs:
  + external_ip_address_vm_1   = (known after apply)
  + internal_ip_address_vm_1   = (known after apply)
  + subnet-1                   = (known after apply)
  + yandex_iam_service_account = "ajeitl8r83tsgm7ln***"
  + yandex_iam_user            = "ajelestcfkkc0kkqc***"

───────────────────────────────────────────────────────────────────────────────

Note: You didn't use the -out option to save this plan, so Terraform can't
guarantee to take exactly these actions if you run "terraform apply" now.

user@user-VPCSB2X9R:~/HW$ terraform apply
var.yandex_token
  Enter a value: AQAAAAAy-YW1AATuwVxuQMvpEUfekNq1T8Y6***


Terraform used the selected providers to generate the following execution plan.
Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # yandex_compute_instance.vm-1 will be created
  + resource "yandex_compute_instance" "vm-1" {
      + created_at                = (known after apply)
      + folder_id                 = (known after apply)
      + fqdn                      = (known after apply)
      + hostname                  = "tf1.netology.ru"
      + id                        = (known after apply)
      + metadata                  = {
          + "ssh-keys"  = <<-EOT
                ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDLrKBwEo+0GcNWpQ1TW/jtqgYcqO+W5AZ7rPXsoigBYOIb9JKbRakXpNOOgBgmLq1W/d91MCX9AR6ER5Qp8cdOAEPpXvMXzzKceO++52CoRUN0gfL/e5i/TMr9dXN4rLXEn4WG1lnmzVfhXm7kxem3b73DExnhwRDsR1XEsTiWn+o5h3wqMzRW/wo1Iqk1pQKOa3jaxWumyIspHuVJvlXYiVt/67P2WbYUAsVxDl6f/jqusI0OuucmzsADa5BfFhXPa627LfPEr6PptuXSSdOmpHlgMNCc8Am0HzEw2j8U6++vnz8em9ePG+WUqmCXcwHTy0o9+MqZ47ERz4+aC*** user@user-VPCSB2X9R
            EOT
          + "user-data" = ""
        }
      + name                      = "terraform1"
      + network_acceleration_type = "standard"
      + platform_id               = "standard-v1"
      + service_account_id        = (known after apply)
      + status                    = (known after apply)
      + zone                      = (known after apply)

      + boot_disk {
          + auto_delete = true
          + device_name = (known after apply)
          + disk_id     = (known after apply)
          + mode        = (known after apply)

          + initialize_params {
              + block_size  = (known after apply)
              + description = (known after apply)
              + image_id    = "fd89ovh4ticpo40dkbvd"
              + name        = (known after apply)
              + size        = (known after apply)
              + snapshot_id = (known after apply)
              + type        = "network-hdd"
            }
        }

      + network_interface {
          + index              = (known after apply)
          + ip_address         = (known after apply)
          + ipv4               = true
          + ipv6               = (known after apply)
          + ipv6_address       = (known after apply)
          + mac_address        = (known after apply)
          + nat                = true
          + nat_ip_address     = (known after apply)
          + nat_ip_version     = (known after apply)
          + security_group_ids = (known after apply)
          + subnet_id          = (known after apply)
        }

      + placement_policy {
          + host_affinity_rules = (known after apply)
          + placement_group_id  = (known after apply)
        }

      + resources {
          + core_fraction = 100
          + cores         = 2
          + memory        = 2
        }

      + scheduling_policy {
          + preemptible = (known after apply)
        }
    }

  # yandex_vpc_network.network-1 will be created
  + resource "yandex_vpc_network" "network-1" {
      + created_at                = (known after apply)
      + default_security_group_id = (known after apply)
      + folder_id                 = (known after apply)
      + id                        = (known after apply)
      + labels                    = (known after apply)
      + name                      = "network1"
      + subnet_ids                = (known after apply)
    }

  # yandex_vpc_subnet.subnet-1 will be created
  + resource "yandex_vpc_subnet" "subnet-1" {
      + created_at     = (known after apply)
      + folder_id      = (known after apply)
      + id             = (known after apply)
      + labels         = (known after apply)
      + name           = "subnet1"
      + network_id     = (known after apply)
      + v4_cidr_blocks = [
          + "192.168.10.0/24",
        ]
      + v6_cidr_blocks = (known after apply)
      + zone           = "ru-central1-a"
    }

Plan: 3 to add, 0 to change, 0 to destroy.

Changes to Outputs:
  + external_ip_address_vm_1   = (known after apply)
  + internal_ip_address_vm_1   = (known after apply)
  + subnet-1                   = (known after apply)
  + yandex_iam_service_account = "ajeitl8r83tsgm7ln***"
  + yandex_iam_user            = "ajelestcfkkc0kkqc***"

Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes

yandex_vpc_network.network-1: Creating...
yandex_vpc_network.network-1: Creation complete after 0s [id=enpqdkva6fc7prvc25cs]
yandex_vpc_subnet.subnet-1: Creating...
yandex_vpc_subnet.subnet-1: Creation complete after 0s [id=e9bmimtkbbrnbefki2lo]
yandex_compute_instance.vm-1: Creating...
yandex_compute_instance.vm-1: Still creating... [10s elapsed]
yandex_compute_instance.vm-1: Still creating... [20s elapsed]
yandex_compute_instance.vm-1: Creation complete after 24s [id=fhmuap7vledbhsod4rrp]

Apply complete! Resources: 3 added, 0 changed, 0 destroyed.

Outputs:

external_ip_address_vm_1 = "51.250.95.*"
internal_ip_address_vm_1 = "192.168.10.4"
subnet-1 = "e9bmimtkbbrnbefki***"
yandex_iam_service_account = "ajeitl8r83tsgm7ln***"
yandex_iam_user = "ajelestcfkkc0kkqc***"

```

![YC](/07-terraform-02-syntax/img/Screenshot_1.png)


В качестве результата задания предоставьте:

1. Ответ на вопрос: при помощи какого инструмента (из разобранных на прошлом занятии) можно создать свой образ ami?   

---

***Ответ***

Свой образ для YC можно создать при помощи `packer`

---

 
2. Ссылку на репозиторий с исходной конфигурацией терраформа.  
 
---

***Ответ***

*Ссылка на соответствующий [репозиторий](https://github.com/shagovid/devops-netology/tree/main/HomeWork/virt-homeworks/07-terraform-02-syntax/src)*

---

### Как cдавать задание

Выполненное домашнее задание пришлите ссылкой на .md-файл в вашем репозитории.

---
