terraform {
  required_version = ">= 1.5"

  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
}

provider "yandex" {
  service_account_key_file = var.sa_key_file
  cloud_id                 = var.cloud_id
  folder_id                = var.folder_id
  zone                     = var.zone
}

locals {
  ssh_key = "${var.vm_user}:${file(var.ssh_public_key_path)}"
  labels = {
    project    = var.project
    managed_by = "terraform"
  }
}

data "yandex_compute_image" "ubuntu" {
  family = var.image_family
}

resource "yandex_vpc_network" "main" {
  name   = "${var.project}-net"
  labels = local.labels
}

resource "yandex_vpc_gateway" "nat" {
  name = "${var.project}-nat"
  shared_egress_gateway {}
}

resource "yandex_vpc_route_table" "private" {
  name       = "${var.project}-private-rt"
  network_id = yandex_vpc_network.main.id

  static_route {
    destination_prefix = "0.0.0.0/0"
    gateway_id         = yandex_vpc_gateway.nat.id
  }
}

resource "yandex_vpc_subnet" "public" {
  name           = "${var.project}-public"
  zone           = var.zone
  network_id     = yandex_vpc_network.main.id
  v4_cidr_blocks = [var.public_subnet_cidr]
}

resource "yandex_vpc_subnet" "private" {
  name           = "${var.project}-private"
  zone           = var.zone
  network_id     = yandex_vpc_network.main.id
  v4_cidr_blocks = [var.private_subnet_cidr]
  route_table_id = yandex_vpc_route_table.private.id
}

resource "yandex_compute_disk" "bastion_boot" {
  name     = "${var.project}-bastion-boot"
  type     = "network-hdd"
  zone     = var.zone
  size     = var.bastion.disk_size
  image_id = data.yandex_compute_image.ubuntu.image_id
  labels   = local.labels
}

resource "yandex_compute_instance" "bastion" {
  name        = "${var.project}-bastion"
  platform_id = "standard-v3"
  zone        = var.zone
  labels      = local.labels

  resources {
    cores         = var.bastion.cores
    memory        = var.bastion.memory
    core_fraction = var.bastion.core_fraction
  }

  boot_disk {
    disk_id = yandex_compute_disk.bastion_boot.id
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.public.id
    nat       = true
  }

  metadata = {
    ssh-keys = local.ssh_key
  }
}

resource "yandex_compute_disk" "boot" {
  for_each = var.workers

  name     = "${var.project}-${each.key}-boot"
  type     = each.value.disk_type
  zone     = var.zone
  size     = each.value.boot_disk_size
  image_id = data.yandex_compute_image.ubuntu.image_id
  labels   = local.labels
}

resource "yandex_compute_disk" "data" {
  for_each = var.workers

  name   = "${var.project}-${each.key}-data"
  type   = each.value.disk_type
  zone   = var.zone
  size   = each.value.data_disk_size
  labels = local.labels
}

resource "yandex_compute_instance" "worker" {
  for_each = var.workers

  name        = "${var.project}-${each.key}"
  platform_id = "standard-v3"
  zone        = var.zone
  labels      = local.labels

  resources {
    cores         = each.value.cores
    memory        = each.value.memory
    core_fraction = each.value.core_fraction
  }

  boot_disk {
    disk_id = yandex_compute_disk.boot[each.key].id
  }

  secondary_disk {
    disk_id = yandex_compute_disk.data[each.key].id
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.private.id
    nat       = false
  }

  metadata = {
    ssh-keys = local.ssh_key
  }
}
