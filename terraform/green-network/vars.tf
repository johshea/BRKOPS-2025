variable "MERAKI_DASHBOARD_API_URL" {
  type        = string
  description = "Meraki API Base URL"
}

variable "MERAKI_DASHBOARD_API_KEY" {
  type        = string
  description = "Meraki ORG API Key"
  sensitive = true
}

variable "org_id" {
  type        = string
  description = ""
}

variable "network_name" {
  type        = string
  description = ""
}

