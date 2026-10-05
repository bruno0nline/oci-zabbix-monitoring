terraform {
  required_version = ">= 1.5.0"

  required_providers {
    oci = {
      source  = "oracle/oci"
      version = ">= 6.0.0"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.6.0"
    }
  }
}

# Autenticacao:
#  - Resource Manager / Cloud Shell: automatica (oci_profile = null)
#  - Local: perfil do ~/.oci/config de um ADMIN (nunca o svc-zabbix)
# IAM (compartment, grupo, policy) precisa ser criado na HOME REGION.
provider "oci" {
  region              = var.region
  config_file_profile = var.oci_profile
}
