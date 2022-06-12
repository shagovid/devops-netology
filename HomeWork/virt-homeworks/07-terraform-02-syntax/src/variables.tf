# Заменить на ID своего облака
# https://console.cloud.yandex.ru/cloud?section=overview
variable "yandex_cloud_id" {
  default = "b1gnfuebcnuet27p3***"
}

# Заменить на Folder своего облака
# https://console.cloud.yandex.ru/cloud?section=overview
variable "yandex_folder_id" {
  default = "b1ggs1btgl0dgp4le***"
}


#Зона размещения инфраструктуры по-умолчанию
variable "yandex_zone_default" {
  default = "ru-central1-a"
}

#Токен предварительно можно получить командой: yc config list
#variable "yandex_token" {
#  default = "token here not recommended, use cli"
# example bash: TF_VAR_yandex_token=("XAQAAAAAy-YW1AATuwVxuQMvpEUfekNq1T8Y6***") terraform plan 
#}
variable "yandex_token" {
  type = string
}

# Заменить на ID своего образа
# ID можно узнать с помощью команды yc compute image list
variable "ubuntu" {
  default = "fd89ovh4ticpo40dkbvd"
}


