terraform {
  required_providers {
    meraki = {
      source = "core-infra-svcs/meraki"
      version = "0.6.3"
    }
  }
}

provider "meraki" {
  api_key  = var.MERAKI_DASHBOARD_API_KEY
}

// Create new Meraki organization Networks in bulk
resource "meraki_network" "networks_bulk" {
  count           = 10
  organization_id = var.org_id
  product_types   = ["appliance", "wireless", "switch", "cellularGateway"]
  tags            = ["Terraform_Provisioned", "CiscoLive_2024"]
  name            = "Network_${count.index}_Terraform"
  timezone        = "America/Louisville"
  notes           = "Prebuilt Network Deployments"
}








