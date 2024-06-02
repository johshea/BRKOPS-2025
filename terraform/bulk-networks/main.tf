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


locals {
  network_names=["Scarlet_Witch", "CAP", "Wasp", "Goliath", "Jocasta"]
}


// count based with list to create new networks
resource "meraki_network" "networks_bulk-1" {
  #count           = 10
  count = length(local.network_names)
  organization_id = var.org_id
  product_types   = ["appliance", "wireless", "switch", "cellularGateway"]
  tags            = ["Terraform_Provisioned", "CiscoLive_2024", "616_Avengers"]
  #name           = "cl2024-LV_${count.index}_Terraform"
  name            = local.network_names[count.index]
  timezone        = "America/Louisville"
  notes           = "Prebuilt Network Deployments"
}

//iterable(for_each) with map to create new networks
resource "meraki_network" "networks_bulk-2" {
  organization_id = var.org_id
  for_each = { for n in var.meraki_networks : n.name => n }
  product_types = ["appliance", "wireless", "switch", "cellularGateway"]
  tags          = ["Terraform_Provisioned", "CiscoLive_2024", "616_Avengers"]
  name          = each.value.name
  timezone      = each.value.timezone
  notes         = "Prebuilt Network Deployments"
}







