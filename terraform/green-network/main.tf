terraform {
  required_providers {
    meraki = {
      source = "core-infra-svcs/meraki"
      version = "0.6.2"
    }
  }
}

provider "meraki" {
  api_key  = var.MERAKI_DASHBOARD_API_KEY
}

// Load Yaml Files full of structure
locals {

  network   = yamldecode(file("./network_${var.network_name}/network.yaml"))
  appliance = yamldecode(file("./network_${var.network_name}/appliance.yaml"))
  switching = yamldecode(file("./network_${var.network_name}/switching.yaml"))
  wireless  = yamldecode(file("./network_${var.network_name}/wireless.yaml"))

  vlans    = local.appliance["vlans"]
  mx_vlans = flatten([for vlan in local.vlans :
    {
      "vlan_id"         = vlan.vlan_id
      "name"            = vlan.name
      "dns_nameservers" = vlan.dns
      "subnet"          = vlan.subnet
      "appliance_ip"    = vlan.appliance_ip
      #dhcp_handling = vlan.dhcp_handling
      #dns_nameservers = vlan.dns_nameservers
    }
  ])
  ssids = local.wireless["ssids"]
  wifi_ssids = flatten([for ssid in local.ssids :
    {
      "number"                 = ssid.number
      "name"                   = ssid.name
      "auth_mode"              = ssid.auth_mode
      "encryption_mode"        = ssid.encryption_mode
      "wpa_encryption_mode"    = ssid.wpa_encryption_mode
      "psk"                    = ssid.psk
      "ip_assignment_mode"     = ssid.ip_assignment_mode
      "default_vlan_id"        = ssid.default_vlan_id
      "adult_content_filtering_enabled" = ssid.adult_content_filtering_enabled
      "use_vlan_tagging" = ssid.use_vlan_tagging
      "enabled" =  ssid.enabled
      "lan_isolation_enabled" = ssid.lan_isolation_enabled
    }
    ])
}

// Create a new Network
resource "meraki_network" "network" {
  organization_id = var.org_id
  product_types   = local.network["product_types"]
  tags            = local.network["tags"]
  name            = local.network["name"]
  timezone        = local.network["timezone"]
  notes           = local.network["notes"]
}

// claim hardware into the network
resource "meraki_networks_devices_claim" "network_serials" {
  serials = sensitive(local.network["serials"])
  network_id = meraki_network.network.id
}

//  enable MX vlans
resource "meraki_networks_appliance_vlans_settings" "vlan_settings" {
  network_id = meraki_network.network.id
  vlans_enabled = true
}

# insert a timout to allow vlans = true to be recognized by the backend
resource "time_sleep" "wait_30_seconds" {
  depends_on = [meraki_networks_appliance_vlans_settings.vlan_settings]
  create_duration = "30s"
}

resource "meraki_devices" "device_info" {
  depends_on = [time_sleep.wait_30_seconds]
  #create an iterative to loop through serials
  for_each = toset(local.network["serials"])
  serial = sensitive(each.value)
  address = local.network["address"]
  notes = "configured by Terraform"
  move_map_marker = true
}

//deploy SSIDs
resource "meraki_networks_wireless_ssids" "all_ssids" {
  for_each = {
    for ssid in local.wifi_ssids : ssid.number => ssid
  }
  provider                        = meraki
  network_id                      = meraki_network.network.id
  number                          = each.value.number
  name                            = each.value.name
  auth_mode                       = each.value.auth_mode
  encryption_mode                 = each.value.encryption_mode
  wpa_encryption_mode             = each.value.wpa_encryption_mode
  psk                             = each.value.psk
  ip_assignment_mode              = each.value.ip_assignment_mode
  default_vlan_id                 = each.value.default_vlan_id
  adult_content_filtering_enabled = each.value.adult_content_filtering_enabled
  use_vlan_tagging                = each.value.use_vlan_tagging
  enabled                         = each.value.enabled
  lan_isolation_enabled           = each.value.lan_isolation_enabled
}

//define l2 - L3 Vlan attributes
resource "meraki_networks_appliance_vlans" "appliance_vlans" {
  for_each = {
    for vlan in local.mx_vlans : vlan.vlan_id => vlan}
  network_id = meraki_network.network.id
  vlan_id = each.value.vlan_id
  subnet = each.value.subnet
  appliance_ip = each.value.appliance_ip
  name = each.value.name
  #dhcp_handling = each.value.dhcphandling
  #dns_nameservers = each.value.dns
  }








