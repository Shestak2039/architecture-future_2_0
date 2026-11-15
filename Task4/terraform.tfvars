cloud_id  = "b1gjcebbh5ucapvm1bts"
folder_id = "b1gtop38t4rureaidu4k"

sa_key_file         = "key.json"
ssh_public_key_path = "~/.ssh/id_ed25519.pub"

bastion = {
  cores         = 2
  memory        = 2
  core_fraction = 20
  disk_size     = 8
}

workers = {
  etl = {
    cores          = 2
    memory         = 2
    core_fraction  = 20
    disk_type      = "network-hdd"
    boot_disk_size = 8
    data_disk_size = 4
  }
  query = {
    cores          = 2
    memory         = 4
    core_fraction  = 50
    disk_type      = "network-ssd"
    boot_disk_size = 8
    data_disk_size = 2
  }
}
