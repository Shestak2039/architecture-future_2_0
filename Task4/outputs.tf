output "bastion_public_ip" {
  description = "Публичный IP bastion для входа по SSH"
  value       = yandex_compute_instance.bastion.network_interface[0].nat_ip_address
}

output "workers_private_ips" {
  description = "Внутренние IP рабочих ВМ"
  value       = { for name, vm in yandex_compute_instance.worker : name => vm.network_interface[0].ip_address }
}

output "network_id" {
  description = "ID сети"
  value       = yandex_vpc_network.main.id
}

output "nat_gateway_id" {
  description = "ID NAT-шлюза"
  value       = yandex_vpc_gateway.nat.id
}
