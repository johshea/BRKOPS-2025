output "network_id" {
  value = meraki_network.network.id
}

output "vlan_data" {
  value  = local.mx_vlans
}

output "ssid_data" {
  value = local.wifi_ssids
}

output "api_key" {
  value = var.MERAKI_DASHBOARD_API_KEY
  sensitive = true
}