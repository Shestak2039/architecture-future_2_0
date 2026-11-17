variable "cloud_id" {
  description = "ID облака в Yandex Cloud"
  type        = string
}

variable "folder_id" {
  description = "ID каталога, в котором создается инфраструктура"
  type        = string
}

variable "sa_key_file" {
  description = "Путь к авторизованному ключу сервисного аккаунта"
  type        = string
  default     = "key.json"
}

variable "zone" {
  description = "Зона доступности"
  type        = string
  default     = "ru-central1-a"
}

variable "project" {
  description = "Префикс для имен ресурсов"
  type        = string
  default     = "future-data"
}

variable "image_family" {
  description = "Семейство образов ОС для ВМ"
  type        = string
  default     = "ubuntu-2204-lts"
}

variable "vm_user" {
  description = "Пользователь для входа по SSH"
  type        = string
  default     = "ubuntu"
}

variable "ssh_public_key_path" {
  description = "Путь к публичному SSH-ключу"
  type        = string
  default     = "~/.ssh/id_ed25519.pub"
}

variable "public_subnet_cidr" {
  description = "Адреса публичной подсети (bastion)"
  type        = string
  default     = "10.10.1.0/24"
}

variable "private_subnet_cidr" {
  description = "Адреса приватной подсети (рабочие ВМ)"
  type        = string
  default     = "10.10.2.0/24"
}

variable "bastion" {
  description = "Параметры ВМ bastion"
  type = object({
    cores         = number
    memory        = number
    core_fraction = number
    disk_size     = number
  })
}

variable "workers" {
  description = "Рабочие ВМ платформы данных. Ключ - имя ВМ"
  type = map(object({
    cores          = number
    memory         = number
    core_fraction  = number
    disk_type      = string
    boot_disk_size = number
    data_disk_size = number
  }))
}
