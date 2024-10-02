### Cloud Provider Credentials ####

####################################

# IBM Cloud API Key
variable "ibmcloud_api_key" {
  type    = string
  default = ""
  description = "IBM Cloud API Key"
}

# Cloud Provider ID
variable "cloud_provider" {
  type    = string
  default = "ibmcloud"
}

