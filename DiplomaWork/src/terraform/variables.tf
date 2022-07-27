# ID облака yandex cloud
# https://console.cloud.yandex.ru/cloud?section=overview
variable "yandex_cloud_id" {
  default = "*****uebcnuet27*****"
}

# Folder облака yandex cloud
# https://console.cloud.yandex.ru/cloud?section=overview
variable "yandex_folder_id" {
  default = "*****1btgl0dgp4*****"
}

# Domain name для deployable infrastructure
# Можно оставить закомментированной для тестов
variable "my_domain" {
  default = "kuberwars.online"
}

# По умолчанию используем временные сертификаты Let's Encrypt
# Если нужны реальные сертификаты, то заменить на "false"
variable "my_le_staging" {
  default = "true"
}

# Образы для ВМ.

# ID образа Ubuntu 20.04 LTS
# 
variable "ubuntu-latest" {
  default = "fd89ovh4ticpo40dkbvd"
}

# ID Образа Ubuntu 18.04 для Nat
# 
variable "ubuntu-nat" {
  default = "fd84mnpg35f7s7b0f5lg"
}

#
# Токен для работы Gitlab runner
variable "my_gitlab_runner" {
  default = "o1PZATGl+oOKkyN+72jRq0usrREGzHpD4cg81xJcJnr="
}

#
# Внутренний пароль для репликации между базами MySQL
variable "my_replicator_psw" {
  default = "M1cros0ft@MS"
}

# Пароли для доступа к Gitlab и Grafana.

#
# Пароль для доступа к Grafana от пользователя `admin`
variable "my_grafana_psw" {
  default = "M1cros0ft@G"
}

#
# Пароль для доступа к Gitlab от пользователя `root`
variable "my_gitlab_psw" {
  default = "M1cros0ft@Git"
}


