terraform {
  required_providers {
    ibm = {
      source = "IBM-Cloud/ibm"
      version = ">= 1.60.0"
    }
    restapi = {
      source = "Mastercard/restapi"
      version = "1.19.1"
    }
  }
}